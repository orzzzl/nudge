import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cute_palette.dart';
import '../../app/widgets/candy.dart';
import '../../domain/plan.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pet/pet_mood.dart';
import '../pet/pet_providers.dart';
import '../pet/pet_view.dart';
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
    final mood = ref.watch(petMoodProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      // Tapping anywhere outside the text field dismisses the keyboard — a
      // chat screen should never trap the keyboard open.
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  // Dragging the message list also dismisses the keyboard.
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(
                      message: state.messages[index],
                      mood: mood,
                    );
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

/// The three mockup bubble looks: the user's peach gradient (`me`), the
/// mascot's white greeting/result (`ai`), and the mint plan confirmation.
enum _BubbleStyle { me, ai, confirm }

/// Renders one [ChatMessage] variant as a localized, sender-aligned bubble.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mood});

  final ChatMessage message;
  final PetMood mood;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (style, text) = switch (message) {
      GreetingMessage() => (_BubbleStyle.ai, l10n.chatGreeting),
      UserPlanMessage(:final title, :final minutes) => (
        _BubbleStyle.me,
        '$title · ${l10n.durationChipLabel(minutes)}',
      ),
      ConfirmationMessage(:final title, :final minutes) => (
        _BubbleStyle.confirm,
        l10n.planConfirmation(title, minutes),
      ),
      ResultMessage(:final status) => (
        _BubbleStyle.ai,
        _resultText(l10n, status),
      ),
    };

    final isUser = style == _BubbleStyle.me;
    const round = Radius.circular(22);
    const tight = Radius.circular(7);

    final decoration = switch (style) {
      // me — peach gradient, white text, tightened bottom-right, candy shadow.
      _BubbleStyle.me => BoxDecoration(
        gradient: CuteColors.peachGradient,
        borderRadius: const BorderRadius.only(
          topLeft: round,
          topRight: round,
          bottomLeft: round,
          bottomRight: tight,
        ),
        boxShadow: candyShadow(CuteColors.peachCandyShadow, dy: 4),
      ),
      // ai — white, cream border, tightened bottom-left.
      _BubbleStyle.ai => BoxDecoration(
        color: CuteColors.white,
        border: Border.all(color: CuteColors.borderNeutral, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: round,
          topRight: round,
          bottomLeft: tight,
          bottomRight: round,
        ),
      ),
      // confirm — mint bg + mint border + green text.
      _BubbleStyle.confirm => BoxDecoration(
        color: CuteColors.mintConfirm,
        border: Border.all(color: CuteColors.borderMint, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: round,
          topRight: round,
          bottomLeft: tight,
          bottomRight: round,
        ),
      ),
    };

    final textColor = switch (style) {
      _BubbleStyle.me => CuteColors.white,
      _BubbleStyle.ai => CuteColors.textBrown,
      _BubbleStyle.confirm => CuteColors.matcha,
    };

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: decoration,
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            PetView(mood: mood, size: 22),
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
