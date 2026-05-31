import 'package:flutter/material.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _start(),
            decoration: InputDecoration(
              hintText: l10n.composerTaskHint,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.composerDurationLabel, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final minutes in PlanComposer.durationOptionsMin)
                ChoiceChip(
                  label: Text(l10n.durationChipLabel(minutes)),
                  selected: _selectedMinutes == minutes,
                  onSelected: (_) => setState(() => _selectedMinutes = minutes),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _canStart ? _start : null,
            child: Text(l10n.startButton),
          ),
        ],
      ),
    );
  }
}
