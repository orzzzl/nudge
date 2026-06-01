import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/plan.dart';
import '../../l10n/generated/app_localizations.dart';
import 'chat_controller.dart';
import 'widgets/check_in_sheet.dart';
import 'widgets/countdown_capsule.dart';
import 'widgets/plan_composer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool _isCheckInSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<Plan?>(chatControllerProvider.select((s) => s.pendingCheckIn), (
      _,
      plan,
    ) {
      if (plan == null || _isCheckInSheetOpen) {
        return;
      }

      unawaited(_openPendingCheckIn(plan));
    });

    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  return _MessageBubble(message: state.messages[index]);
                },
              ),
            ),
            if (state.activePlan == null)
              PlanComposer(
                onStart: (title, durationMin) => controller.createPlan(
                  title: title,
                  durationMin: durationMin,
                  locale: Localizations.localeOf(context).languageCode,
                ),
              )
            else
              CountdownCapsule(
                plan: state.activePlan!,
                onCheckIn: () => _checkIn(context, ref, state.activePlan!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPendingCheckIn(Plan plan) async {
    _isCheckInSheetOpen = true;
    final controller = ref.read(chatControllerProvider.notifier);

    try {
      final status = await showCheckInSheet(context, plan: plan);
      if (!mounted) {
        return;
      }
      if (status != null) {
        await controller.checkIn(status);
      }
    } finally {
      if (mounted) {
        controller.consumePendingCheckIn();
      }
      _isCheckInSheetOpen = false;
    }
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref, Plan plan) async {
    final status = await showCheckInSheet(context, plan: plan);
    if (status != null) {
      await ref.read(chatControllerProvider.notifier).checkIn(status);
    }
  }
}

/// Renders one [ChatMessage] variant as a localized, sender-aligned bubble.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (isUser, text) = switch (message) {
      GreetingMessage() => (false, l10n.chatGreeting),
      UserPlanMessage(:final title, :final minutes) => (
        true,
        '$title · ${l10n.durationChipLabel(minutes)}',
      ),
      ConfirmationMessage(:final title, :final minutes) => (
        false,
        l10n.planConfirmation(title, minutes),
      ),
      ResultMessage(:final status) => (false, _resultText(l10n, status)),
    };

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isUser
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const Text('🌱', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }

  String _resultText(AppLocalizations l10n, PlanStatus status) {
    return switch (status) {
      PlanStatus.done => l10n.resultDone,
      PlanStatus.partial => l10n.resultPartial,
      PlanStatus.missed => l10n.resultMissed,
      PlanStatus.running || PlanStatus.abandoned => l10n.resultPartial,
    };
  }
}
