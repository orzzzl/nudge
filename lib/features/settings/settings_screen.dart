import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cute_palette.dart';
import '../../app/providers.dart';
import '../../app/widgets/candy.dart';
import '../../domain/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          CandyCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            // ListTile paints its splash on the nearest Material; without this
            // the CandyCard's DecoratedBox would swallow it (asserts in debug).
            child: Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(l10n.settingsDndLabel),
                subtitle: Text(l10n.settingsDndDescription),
                value: settings.dnd,
                onChanged: controller.setDnd,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.settingsLanguageLabel),
          CandyCard(
            child: SegmentedButton<LocaleOverride>(
              segments: [
                ButtonSegment(
                  value: LocaleOverride.system,
                  label: Text(l10n.settingsLanguageSystem),
                ),
                ButtonSegment(
                  value: LocaleOverride.en,
                  label: Text(l10n.settingsLanguageEnglish),
                ),
                ButtonSegment(
                  value: LocaleOverride.zh,
                  label: Text(l10n.settingsLanguageChinese),
                ),
              ],
              selected: {settings.localeOverride},
              onSelectionChanged: (selection) {
                controller.setLocaleOverride(selection.single);
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.settingsAboutLabel),
          CandyCard(
            child: packageInfo.when(
              data: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.appName,
                    style: const TextStyle(
                      color: CuteColors.textBrown,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.settingsVersionValue(info.version),
                    style: const TextStyle(color: CuteColors.textMuted),
                  ),
                ],
              ),
              loading: () =>
                  const SizedBox(width: 120, child: LinearProgressIndicator()),
              error: (_, _) => Text(l10n.appTitle),
            ),
          ),
        ],
      ),
    );
  }
}

/// A muted brown w800 section label above a settings card (mockup `.section-t`).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: CuteColors.textMuted2,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
