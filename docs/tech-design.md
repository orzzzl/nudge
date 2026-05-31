# Nudge / 轻推 — MVP 技术设计文档

> 目标：iOS + Android 一份代码；中美双市场运营；宠物「团团」可私人定制；
> 代码注释英文、UI 中英文双语。架构需为未来云同步 / 养成系统 / AI 教练留出扩展位。

---

## 0. 一句话结论

**Flutter + Riverpod + Drift(SQLite) + Rive，MVP 做成本地优先（offline-first、无账号、无服务器）。**
本地优先一举绕开中美市场最棘手的三件事：跨境数据合规、Android 推送割裂、AI 服务区域可用性。

---

## 1. 跨平台框架：为什么选 Flutter（而非 React Native）

| 维度 | Flutter | React Native | 对本项目的权重 |
|---|---|---|---|
| 自绘宠物动画 | ✅ Skia/Impeller 自绘，**Rive 官方一等支持** | 依赖原生/三方，动画一致性差 | 🔴 高（团团是核心） |
| UI 跨端一致性 | ✅ 完全一致 | 依赖原生组件，需调 | 🟡 中 |
| 本地通知 / 后台调度 | ✅ 成熟插件 | ✅ 可用 | 🟡 中 |
| 中国构建无 Google 依赖 | ✅ 引擎自带，不强依赖 GMS | RN 本身可以，但生态多绑 Firebase | 🔴 高 |
| 团队上手 / 包体积 | 学习曲线略陡、包略大 | JS 生态熟 | 🟢 低 |

**决定性理由**：团团需要"换色 / 配饰 / 随心情变表情"的可定制矢量动画，Flutter + Rive 的运行时状态机（State Machine）是目前做这件事最顺的组合；且 Flutter 自带渲染引擎，不强依赖被中国墙掉的 Google Play Services。

---

## 2. 中美双市场 = 架构第一驱动力

这是全文最重要的一节。三个必须正面处理的差异：

### 2.1 推送（最大的坑）
- **iOS**：两地都走 APNs，无问题。
- **Android**：FCM 在中国被墙。美国 Android 用 FCM；中国 Android 需走**厂商通道**（小米/华为/OPPO/vivo）或聚合推送（个推 GeTui / 极光 JPush / 友盟）。

> **MVP 的破局点**：核心提醒是**定时型**（"两小时到了"）。这类提醒用**本地定时通知**（`flutter_local_notifications` + 设备本地调度）即可实现，**完全不需要任何推送服务**。
> 服务端推送只有"再唤回"类（如"3 小时没计划了"）才需要——这部分**推迟到 v2**。
> → MVP 阶段，推送这个坑直接消失。

### 2.2 数据合规 / 跨境
- 中国《个人信息保护法（PIPL）》要求数据本地化；在境内放服务器/域名还要 **ICP 备案**。
- 一旦上服务器：中国用户数据需落在境内云（阿里云/腾讯云），美国数据落 AWS/GCP，跨境传输受限。

> **MVP 破局点**：**全部数据存在设备本地，无账号、无服务器** → 不触发 PIPL 跨境、不用 ICP 备案、不用建双地域后端。云同步是 v2 的事，届时用**按区域分库**架构应对（见 §10）。

### 2.3 AI 自然语言解析
- Claude / OpenAI 在中国大陆访问受限；中国市场需国产模型（通义千问 Qwen / DeepSeek / 文心）。

> **MVP 破局点**：意图解析（任务名 + 时长）用**本地规则解析**（正则 + 关键词，见 §8）。把解析能力放在一个 `IntentParser` 接口后面，未来可按区域接不同 LLM，UI 与业务逻辑零改动。

### 2.4 应用分发（影响构建配置）
- iOS：两地 App Store（中国区可能需独立主体/资质）。
- Android：美国 Google Play；中国走华为/小米/应用宝等**多家商店** → 需要 **build flavors**（`cn` / `global`）来切渠道、切推送实现、切 AI 后端。

---

## 3. 整体架构（分层 + 依赖倒置）

```
┌────────────────────────────────────────────────┐
│  Presentation  (Flutter widgets + Riverpod)     │  聊天页 / 乖乖图 / 结账弹窗
├────────────────────────────────────────────────┤
│  Application   (Notifiers / UseCases)           │  CreatePlan, CheckInPlan, GetWeeklyStats...
├────────────────────────────────────────────────┤
│  Domain        (Entities + Repository 接口)      │  Plan, PetConfig, IntentParser(接口)
├────────────────────────────────────────────────┤
│  Data          (Repository 实现 + 数据源)         │  Drift本地库 / Notification / Parser实现
└────────────────────────────────────────────────┘
            ▲ 接口在 Domain，实现在 Data —— 依赖倒置
```

**留给未来的"接缝"（seams）——这是"为扩展预留空间"的核心做法：**

| 接缝（接口） | MVP 实现 | 未来可替换为 |
|---|---|---|
| `PlanRepository` | 本地 Drift | 本地 + 云同步（按区域分库） |
| `IntentParser` | 规则解析 | Claude（海外）/ Qwen（中国） |
| `Notifier` | 本地通知 | + 厂商/FCM 远程推送 |
| `PetRenderer` | Rive + 本地配置 | + 商店/解锁/UGC 定制 |

只要 UI 和业务逻辑只依赖接口，换实现时上层不动。

---

## 4. 技术选型清单

| 关注点 | 选择 | 理由 |
|---|---|---|
| 框架 | **Flutter 3.x（Dart）** | 见 §1 |
| 状态管理 | **Riverpod** | 编译期安全、可测试、provider 可组合 |
| 本地数据库 | **Drift（SQLite 之上）** | 类型安全、**响应式查询(Stream)**、**强迁移能力**，关系型契合"计划→统计"聚合 |
| 宠物动画 | **Rive** | 运行时状态机，换色/配饰/表情，定制天然 |
| 本地通知 | **flutter_local_notifications** | 设备本地定时，绕开推送割裂 |
| 国际化 | **flutter gen_l10n + ARB** | 官方方案，`zh.arb` / `en.arb` |
| 时区/时间 | **timezone + intl** | 定时通知必须时区正确 |
| 崩溃/监控 | **Sentry** | **中美都可用**（可私有化），避开 Firebase 在华问题 |
| 路由 | **go_router** | 声明式、深链支持（点通知跳结账页） |
| 序列化 | **freezed + json_serializable** | 不可变实体、少样板 |

> 为什么不是 Isar/Hive：Hive 无关系查询、schema 演进弱；Isar 性能好但维护状态近年不稳。**Drift 的迁移系统**对"要长期演进 + 未来上云"更稳妥。

---

## 5. 数据库设计（Drift / SQLite）

```dart
// All comments in English per project convention.

// A single planned time-box. The whole MVP rests on this one table.
class Plans extends Table {
  IntColumn  get id          => integer().autoIncrement()();
  TextColumn get title       => text().withLength(min: 1, max: 200)();   // "write weekly report"
  IntColumn  get durationMin => integer()();                             // planned length in minutes
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt   => dateTime()();
  // running | done | partial | missed | abandoned  — stored as text for forward-compat
  TextColumn get status      => text().withDefault(const Constant('running'))();
  TextColumn get note        => text().nullable()();                     // optional check-in note
  // Locale captured at creation time; lets us re-parse / display correctly across markets.
  TextColumn get locale      => text().withDefault(const Constant('zh'))();
  DateTimeColumn get createdAt => dateTime()();
}

// Pet customization is a versioned JSON blob -> schema can grow without DB migration.
class PetConfigs extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  IntColumn  get schemaVer => integer().withDefault(const Constant(1))(); // future-proofing
  TextColumn get configJson=> text()();   // { baseColor, accessories[], unlockedItems[], ... }
  DateTimeColumn get updatedAt => dateTime()();
}
```

**为什么 `status` / `configJson` 用文本/JSON 而非枚举/分表**：双市场 + 快速迭代下，**向前兼容**比强约束更值钱——新增状态或新的定制项不必做破坏性迁移。

**统计无需建表**：`DayStat`（受计划时长、完成率）由对 `Plans` 的**响应式聚合查询**实时算出，乖乖图用 Drift 的 `Stream` 自动刷新。

**迁移策略**：Drift `schemaVersion` 自增 + `MigrationStrategy`；每次改表写迁移并加测试。`PetConfigs.schemaVer` 让定制数据独立于 DB 版本演进。

---

## 6. 宠物「团团」与"私人定制"

**渲染**：Rive 文件内建一个 **State Machine**，暴露输入：
- `mood`（happy / neutral / sad）← 由本周完成率/出席驱动，乖乖图和结账页共用。
- 外观输入：`baseColor`、`accessory`（帽子/叶子/围巾…）、`expression`。

**定制数据模型（可扩展）**：
```dart
@freezed
class PetConfig with _$PetConfig {
  const factory PetConfig({
    required int schemaVer,            // bump when shape changes
    required String baseColor,         // hex
    @Default([]) List<String> accessories,
    @Default([]) List<String> unlockedItems,  // future: 养成/商店解锁
  }) = _PetConfig;
}
```
- MVP：开放**换色 + 1~2 类配饰**，纯本地、免费。
- 预留位：`unlockedItems` 为未来"越乖越解锁新形态 / 定制商店 / 甚至 UGC 皮肤"留口；改 schema 只升 `schemaVer`，不动主库。

---

## 7. 国际化（中英双语）

- **方案**：Flutter `gen_l10n`，`lib/l10n/app_en.arb` + `app_zh.arb`，UI 文案零硬编码。
- **不只是翻译**，三个易被忽略的点：
  1. **解析要分语种**：`IntentParser` 按 locale 选规则（"1小时/半小时/90分钟" vs "1 hour/half an hour"）。
  2. **时间格式**：`intl` 按 locale 显示（上午/下午 vs AM/PM）。
  3. **文案语气**：团团的话术中英分别本地化，不要直译（"团团不会怪你的" ≠ 生硬英译）。
- 语言跟随系统，设置页可手动覆盖。

---

## 8. 意图解析（IntentParser 接口）

```dart
// Domain-level contract. UI/logic depend ONLY on this, never on the impl.
abstract class IntentParser {
  // Returns task title + minutes from a free-form utterance; null minutes -> ask follow-up.
  Future<ParsedIntent> parse(String text, {required Locale locale});
}
```
- **MVP 实现 `RuleBasedParser`**：正则抽时长（中文数字/阿拉伯数字/"半"小时/"个把钟头"；英文 "an hour/30 min"），剩余即任务名。零网络、零成本、双市场可用。
- **未来实现**：`LlmParser`（海外 Claude、中国 Qwen/DeepSeek），构建 flavor 决定注入哪个。上层完全不感知。

---

## 9. 提醒与后台调度（本地优先）

- 建计划时，按 `endAt` 用 `flutter_local_notifications` **本地排程**一条通知。
- 用 `timezone` 保证跨时区/出行正确；处理 iOS 限制与 Android Doze/精确闹钟权限（`SCHEDULE_EXACT_ALARM`）。
- 点通知 → `go_router` 深链直达**结账弹窗**。
- **勿扰**：用户开启后，仅暂停"再唤回"类提醒，到点结账提醒仍可由用户在设置里单独控制。
- 远程推送（再唤回、跨设备）= **v2**，届时在 `Notifier` 接口后加区域适配器（海外 FCM / 中国厂商或极光）。

---

## 10. 构建 flavors 与区域化

```
flavors:
  global  ->  FCM(未来) | Claude(未来) | Sentry | Google Play / 海外 App Store
  cn      ->  厂商推送(未来) | Qwen(未来) | Sentry | 华为/小米/应用宝 / 中国区 App Store
```
- 一份代码，**编译期**通过 flavor + 依赖注入选实现（推送/AI/渠道）。
- MVP 因本地优先，两个 flavor 差异极小，但**架子先搭好**，上云/上推送时不返工。

**未来上云（v2+）的数据合规预案**：账号体系 + 按区域分库——中国用户数据落境内云、美国落海外云，区域在注册时绑定、不跨境；客户端按 flavor 指向各自区域的 API 网关。

---

## 11. 推荐目录结构

```
lib/
  app/            # bootstrap, router, theme, flavor config
  l10n/           # app_en.arb, app_zh.arb
  core/           # result types, errors, extensions
  domain/         # entities (Plan, PetConfig), repository & parser interfaces
  data/
    db/           # Drift database + DAOs + migrations
    repositories/ # PlanRepositoryImpl, PetRepositoryImpl
    parser/       # RuleBasedParser (LlmParser later)
    notify/       # LocalNotifier (RemoteNotifier later)
  features/
    chat/         # 聊天主界面 + 结账弹窗
    stats/        # 乖乖图
    pet/          # Rive 团团 渲染与定制
    settings/     # 勿扰、语言、定制入口
```

---

## 12. MVP 切线（先做 / 后做）

**v0（本地优先，可验证核心循环）**
- 聊天建计划（规则解析）、本地定时通知、三态结账、乖乖图（受计划时长 + 完成率 + streak）、团团换色/表情、中英双语、勿扰。
- 全本地、无账号、无服务器、无远程推送、无 LLM。

**v1**：黄金时段洞察、被动模式、常用任务复用、团团多配饰。
**v2**：账号 + 云同步（区域分库）、远程再唤回推送（区域适配）、LLM 解析与 AI 教练（区域模型）、团团养成/解锁商店。

---

## 13. 一句话回顾选型

> **Flutter + Riverpod + Drift + Rive，本地优先。**
> 框架为团团的可定制动画与中国无 GMS 环境而选；本地优先为中美合规、推送割裂、AI 可用性三道难题各开一扇绕行门；所有跨区域差异都藏在 `Repository / IntentParser / Notifier / PetRenderer` 四个接口和 `cn/global` 两个 flavor 之后，未来上云上推送上 AI 都不必重写上层。
