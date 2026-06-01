import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Fixed-format plan input: a task-name field plus duration chips. No sentence
/// parsing and no AI — the duration comes from a tapped chip as exact minutes.
class PlanComposer extends StatefulWidget {
  const PlanComposer({required this.onStart, super.key});

  /// Called with the task name and the chosen duration in minutes.
  final void Function(String title, int durationMin) onStart;

  static const List<int> durationOptionsMin = [30, 60, 90, 120];

  @override
  State<PlanComposer> createState() => _PlanComposerState();
}

class _PlanComposerState extends State<PlanComposer> {
  final TextEditingController _titleController = TextEditingController();
  int _selectedMinutes = 60;

  @override
  void initState() {
    super.initState();
    // Rebuild so the start button enables/disables as the field changes.
    _titleController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canStart => _titleController.text.trim().isNotEmpty;

  void _start() {
    if (!_canStart) {
      return;
    }
    widget.onStart(_titleController.text, _selectedMinutes);
    _titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      // Cream composer panel sitting above the gradient (mockup `.composer`).
      decoration: const BoxDecoration(
        color: CuteColors.surface,
        border: Border(
          top: BorderSide(color: CuteColors.borderCream, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              l10n.composerDurationLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: CuteColors.textMuted2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _start(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: CuteColors.textBrown,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: l10n.composerTaskHint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: CuteColors.textFaint2,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: CuteColors.fieldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: CuteColors.borderPeach2,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: CuteColors.borderPeach2,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in PlanComposer.durationOptionsMin)
                _DurationChip(
                  label: l10n.durationChipLabel(minutes),
                  selected: _selectedMinutes == minutes,
                  onTap: () => setState(() => _selectedMinutes = minutes),
                ),
            ],
          ),
          const SizedBox(height: 14),
          CandyButton(
            label: l10n.startButton,
            onPressed: _canStart ? _start : null,
          ),
        ],
      ),
    );
  }
}

/// A candy duration chip (mockup `.dchip`): selected = peach gradient + shadow +
/// white, unselected = white with a peach border + brown text.
class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? null : CuteColors.white,
            gradient: selected ? CuteColors.peachGradient : null,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? CuteColors.peachGradientBottom
                  : CuteColors.borderPeach,
              width: 2,
            ),
            boxShadow: selected
                ? candyShadow(CuteColors.peachCandyShadow, dy: 3)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? CuteColors.white : CuteColors.chipBrown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
