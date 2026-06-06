import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/plan.dart';
import '../../domain/plan_repository.dart';
import '../../domain/reminder_scheduler.dart';

/// A single bubble in the chat transcript. Variants carry only data — the widget
/// layer resolves them to localized text, so no user-facing strings live here.
sealed class ChatMessage {
  const ChatMessage();
}

/// Opening prompt from the mascot.
class GreetingMessage extends ChatMessage {
  const GreetingMessage();
}

/// Right-aligned bubble echoing what the user just committed to.
class UserPlanMessage extends ChatMessage {
  const UserPlanMessage({required this.title, required this.durationSec});

  final String title;
  final int durationSec;
}

/// Mascot confirmation after a plan is created.
class ConfirmationMessage extends ChatMessage {
  const ConfirmationMessage({required this.title, required this.durationSec});

  final String title;
  final int durationSec;
}

/// Mascot acknowledgement after a check-in.
class ResultMessage extends ChatMessage {
  const ResultMessage({required this.status});

  final PlanStatus status;
}

class ChatState {
  const ChatState({
    required this.messages,
    required this.activePlan,
    required this.pendingCheckIn,
  });

  final List<ChatMessage> messages;
  final Plan? activePlan;
  final Plan? pendingCheckIn;

  ChatState copyWith({
    List<ChatMessage>? messages,
    Plan? activePlan,
    Plan? pendingCheckIn,
    bool clearActivePlan = false,
    bool clearPendingCheckIn = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      activePlan: clearActivePlan ? null : (activePlan ?? this.activePlan),
      pendingCheckIn: clearPendingCheckIn
          ? null
          : (pendingCheckIn ?? this.pendingCheckIn),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  Timer? _checkInTimer;
  StreamSubscription<int>? _checkInTapSubscription;
  int? _lastPromptedPlanId;

  /// A leftover plan still unsettled this long after its end time is treated as
  /// abandoned on restore — no point nagging a check-in for something that
  /// ended yesterday.
  static const _staleAbandonAfter = Duration(hours: 10);

  @override
  ChatState build() {
    _checkInTapSubscription = _reminderScheduler.onCheckInTapped.listen((
      planId,
    ) {
      unawaited(_promptCheckInById(planId));
    });
    // A scheduled notification's sound is fixed when it's scheduled, so flipping
    // DND mid-block must re-schedule the active plan's reminder — that way the
    // setting as of the latest change before time-up wins, not whatever it was
    // when the plan started.
    ref.listen(settingsControllerProvider.select((s) => s.dnd), (_, dnd) {
      unawaited(_rescheduleActiveReminder(silent: dnd));
    });
    ref.onDispose(() {
      _checkInTimer?.cancel();
      unawaited(_checkInTapSubscription?.cancel() ?? Future<void>.value());
    });

    unawaited(_restoreActivePlan());
    unawaited(_restoreInitialTappedPlan());

    return const ChatState(
      messages: [GreetingMessage()],
      activePlan: null,
      pendingCheckIn: null,
    );
  }

  PlanRepository get _repository => ref.read(planRepositoryProvider);

  ReminderScheduler get _reminderScheduler =>
      ref.read(reminderSchedulerProvider);

  Future<void> _restoreActivePlan() async {
    final restoredPlan = await _repository.getActivePlan();
    if (restoredPlan == null || state.activePlan != null) {
      return;
    }
    if (await _abandonIfStale(restoredPlan)) {
      return;
    }

    state = state.copyWith(activePlan: restoredPlan);
    _armCheckInTimer(restoredPlan);
  }

  /// A leftover plan that ended >10h ago and was never settled is treated as
  /// abandoned: mark it so and cancel its reminder, instead of opening a
  /// check-in for a task the user has clearly moved on from. Returns true when
  /// it handled (dropped) the plan, so callers stop and skip the prompt.
  ///
  /// This guards both entry points — restore and a tapped notification — so a
  /// stale reminder tapped long after the fact can't slip past the window.
  Future<bool> _abandonIfStale(Plan plan) async {
    final planId = plan.id;
    if (planId == null || plan.status != PlanStatus.running) {
      return false;
    }
    final overdueBy = DateTime.now().difference(plan.endAt);
    if (overdueBy <= _staleAbandonAfter) {
      return false;
    }
    await _repository.checkIn(id: planId, status: PlanStatus.abandoned);
    await _reminderScheduler.cancel(planId);
    return true;
  }

  /// Re-arms the active plan's OS reminder on the loud or silent channel after
  /// DND changes. No-op if there's no active plan or it has already ended.
  Future<void> _rescheduleActiveReminder({required bool silent}) async {
    final plan = state.activePlan;
    final planId = plan?.id;
    if (plan == null || planId == null) {
      return;
    }
    if (!plan.endAt.isAfter(DateTime.now())) {
      return;
    }
    await _reminderScheduler.scheduleCheckInReminder(
      planId: planId,
      title: plan.title,
      at: plan.endAt,
      silent: silent,
    );
  }

  Future<void> _restoreInitialTappedPlan() async {
    final planId = await _reminderScheduler.takeInitialTappedPlanId();
    if (!ref.mounted || planId == null) {
      return;
    }

    await _promptCheckInById(planId);
  }

  Future<void> _promptCheckInById(int planId) async {
    final plan = await _repository.getPlanById(planId);
    if (plan == null) {
      return;
    }
    if (await _abandonIfStale(plan)) {
      return;
    }
    if (!ref.mounted) {
      return;
    }

    _promptCheckIn(plan);
  }

  void _armCheckInTimer(Plan plan) {
    _checkInTimer?.cancel();
    _checkInTimer = null;

    if (plan.status != PlanStatus.running) {
      return;
    }

    final delay = plan.endAt.difference(DateTime.now());
    if (delay <= Duration.zero) {
      _promptCheckIn(plan);
      return;
    }

    _checkInTimer = Timer(delay, () => _promptCheckIn(plan));
  }

  void _promptCheckIn(Plan plan) {
    final planId = plan.id;
    if (planId == null ||
        planId == _lastPromptedPlanId ||
        plan.status != PlanStatus.running) {
      return;
    }

    _lastPromptedPlanId = planId;
    state = state.copyWith(pendingCheckIn: plan);
  }

  void consumePendingCheckIn() {
    state = state.copyWith(clearPendingCheckIn: true);
  }

  /// Create a running plan from the fixed-format input and start its block now.
  Future<void> createPlan({
    required String title,
    required int durationSec,
    required String locale,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || state.activePlan != null) {
      return;
    }

    final plan = await _repository.createPlan(
      title: trimmed,
      durationSec: durationSec,
      startAt: DateTime.now(),
      locale: locale,
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        UserPlanMessage(title: trimmed, durationSec: durationSec),
        ConfirmationMessage(title: trimmed, durationSec: durationSec),
      ],
      activePlan: plan,
    );
    _armCheckInTimer(plan);

    final planId = plan.id;
    if (planId != null) {
      await _reminderScheduler.scheduleCheckInReminder(
        planId: planId,
        title: trimmed,
        at: plan.endAt,
        // In-app DND: deliver the time-up reminder silently (no sound/vibration).
        silent: ref.read(settingsControllerProvider).dnd,
      );
    }
  }

  /// Record the outcome of the active plan and clear it for the next one.
  Future<void> checkIn(PlanStatus status) async {
    final plan = state.pendingCheckIn ?? state.activePlan;
    final id = plan?.id;
    if (id == null) {
      return;
    }

    await _repository.checkIn(id: id, status: status);
    await _reminderScheduler.cancel(id);
    if (state.activePlan?.id == id) {
      _checkInTimer?.cancel();
      _checkInTimer = null;
    }

    state = state.copyWith(
      messages: [
        ...state.messages,
        ResultMessage(status: status),
      ],
      clearActivePlan: state.activePlan?.id == id,
      clearPendingCheckIn: true,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
