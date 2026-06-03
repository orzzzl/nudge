import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The unit a user picks a duration in. Internally everything is stored in
/// seconds; the unit only decides the presets shown and how the typed amount is
/// multiplied. Seconds is **not** a user-facing unit — sub-minute blocks exist
/// only for internal/e2e testing, which create them by calling the controller /
/// repository with a `durationSec` directly rather than through this picker.
enum DurationUnit {
  minutes(60, [30, 60, 90, 120]),
  hours(3600, [1, 2, 3, 4]);

  const DurationUnit(this.secondsPer, this.presets);

  final int secondsPer;
  final List<int> presets;
}

/// Fixed-format plan input: a task-name field, a minutes/hours unit toggle, and
/// duration presets plus a custom amount. No sentence parsing and no AI — the
/// duration is computed from the chosen unit and reported to [onStart] in
/// **seconds** (the storage unit).
class PlanComposer extends StatefulWidget {
  const PlanComposer({required this.onStart, super.key});

  /// Called with the task name and the chosen duration in seconds.
  final void Function(String title, int durationSec) onStart;

  @override
  State<PlanComposer> createState() => _PlanComposerState();
}

class _PlanComposerState extends State<PlanComposer> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _customController = TextEditingController();

  // The units a user can choose between.
  static const List<DurationUnit> _units = [
    DurationUnit.minutes,
    DurationUnit.hours,
  ];

  DurationUnit _unit = DurationUnit.minutes;
  int _selectedValue = 60; // in _unit's terms; defaults to the 60-min preset

  @override
  void initState() {
    super.initState();
    // Rebuild so the start button enables/disables as the fields change.
    _titleController.addListener(_onChanged);
    _customController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _customController.removeListener(_onChanged);
    _titleController.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _selectUnit(DurationUnit unit) {
    setState(() {
      _unit = unit;
      _selectedValue = unit.presets.first;
      _customController.clear();
    });
  }

  /// The custom amount typed in the current unit, or null when the field is
  /// empty. A non-empty but unparseable/non-positive value is invalid.
  int? get _customValue {
    final text = _customController.text.trim();
    if (text.isEmpty) {
      return null;
    }
    final value = int.tryParse(text);
    return (value != null && value > 0) ? value : null;
  }

  bool get _customInvalid =>
      _customController.text.trim().isNotEmpty && _customValue == null;

  // A typed custom amount overrides the selected preset.
  int get _durationSec => (_customValue ?? _selectedValue) * _unit.secondsPer;

  bool get _canStart =>
      _titleController.text.trim().isNotEmpty &&
      !_customInvalid &&
      _durationSec > 0;

  String _unitLabel(AppLocalizations l10n, DurationUnit unit) => switch (unit) {
    DurationUnit.minutes => l10n.unitMinutes,
    DurationUnit.hours => l10n.unitHours,
  };

  String _valueLabel(AppLocalizations l10n, int value) => switch (_unit) {
    DurationUnit.minutes => l10n.durationChipLabel(value),
    DurationUnit.hours => l10n.durationHoursLabel(value),
  };

  void _start() {
    if (!_canStart) {
      return;
    }
    widget.onStart(_titleController.text, _durationSec);
    _titleController.clear();
    _customController.clear();
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
            key: const Key('composerTitleField'),
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
          // Unit toggle (分钟 / 小时, plus 秒 in debug). Only shown when there's a
          // real choice — in release that's minutes vs hours.
          if (_units.length > 1)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final unit in _units)
                  _DurationChip(
                    label: _unitLabel(l10n, unit),
                    selected: _unit == unit,
                    onTap: () => _selectUnit(unit),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in _unit.presets)
                _DurationChip(
                  label: _valueLabel(l10n, value),
                  // The preset is "active" only when no custom amount is typed.
                  selected: _customValue == null && _selectedValue == value,
                  onTap: () => setState(() {
                    _selectedValue = value;
                    _customController.clear();
                  }),
                ),
              // Custom amount in the selected unit; overrides the preset chips.
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _start(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: CuteColors.textBrown,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.composerCustomHint,
                    errorText: _customInvalid ? '' : null,
                    suffixText: _unitLabel(l10n, _unit),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: CuteColors.textFaint2,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: CuteColors.fieldBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: CuteColors.borderPeach,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: CuteColors.borderPeach,
                        width: 2,
                      ),
                    ),
                  ),
                ),
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
