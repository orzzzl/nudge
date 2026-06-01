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
  const UserPlanMessage({required this.title, required this.minutes});

  final String title;
  final int minutes;
}

/// Mascot confirmation after a plan is created.
class ConfirmationMessage extends ChatMessage {
  const ConfirmationMessage({required this.title, required this.minutes});

  final String title;
  final int minutes;
}

/// Mascot acknowledgement after a check-in.
class ResultMessage extends ChatMessage {
  const ResultMessage({required this.status});

  final PlanStatus status;
}

class ChatState {
  const ChatState({required this.messages, required this.activePlan});

  final List<ChatMessage> messages;
  final Plan? activePlan;

  ChatState copyWith({
    List<ChatMessage>? messages,
    Plan? activePlan,
    bool clearActivePlan = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      activePlan: clearActivePlan ? null : (activePlan ?? this.activePlan),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    unawaited(_restoreActivePlan());

    return const ChatState(messages: [GreetingMessage()], activePlan: null);
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
  }

  /// Create a running plan from the fixed-format input and start its block now.
  Future<void> createPlan({
    required String title,
    required int durationMin,
    required String locale,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || state.activePlan != null) {
      return;
    }

    final plan = await _repository.createPlan(
      title: trimmed,
      durationMin: durationMin,
      startAt: DateTime.now(),
      locale: locale,
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        UserPlanMessage(title: trimmed, minutes: durationMin),
        ConfirmationMessage(title: trimmed, minutes: durationMin),
      ],
      activePlan: plan,
    );

    final planId = plan.id;
    if (planId != null) {
      await _reminderScheduler.scheduleCheckInReminder(
        planId: planId,
        title: trimmed,
        at: plan.endAt,
      );
    }
  }

  /// Record the outcome of the active plan and clear it for the next one.
  Future<void> checkIn(PlanStatus status) async {
    final plan = state.activePlan;
    final id = plan?.id;
    if (id == null) {
      return;
    }

    await _repository.checkIn(id: id, status: status);
    await _reminderScheduler.cancel(id);

    state = state.copyWith(
      messages: [
        ...state.messages,
        ResultMessage(status: status),
      ],
      clearActivePlan: true,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
