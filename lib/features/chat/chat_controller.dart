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

  @override
  ChatState build() {
    _checkInTapSubscription = _reminderScheduler.onCheckInTapped.listen((
      planId,
    ) {
      unawaited(_promptCheckInById(planId));
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

    state = state.copyWith(activePlan: restoredPlan);
    _armCheckInTimer(restoredPlan);
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
    if (!ref.mounted || plan == null) {
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
        // In-app 勿扰: deliver the time-up reminder silently (no sound/vibration).
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
