import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/cute_palette.dart';
import '../../app/providers.dart';
import '../../app/widgets/candy.dart';
import '../../domain/todo.dart';
import '../../l10n/generated/app_localizations.dart';
import 'todos_controller.dart';

/// New / edit form for a todo (mockup ①b), reused by both flows: [initial] null
/// = create (task 27); non-null = edit a prefilled todo (task 28). Title +
/// priority + due (hidden for permanent) + optional note, then a single action
/// that creates or updates and pops back.
class TodoEditScreen extends ConsumerStatefulWidget {
  const TodoEditScreen({this.initial, super.key});

  final Todo? initial;

  @override
  ConsumerState<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends ConsumerState<TodoEditScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late TodoPriority _priority;
  DateTime? _dueDate;

  bool get _isEdit => widget.initial != null;
  bool get _isPermanent => _priority == TodoPriority.permanent;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _note = TextEditingController(text: initial?.note ?? '');
    _priority = initial?.priority ?? TodoPriority.p2;
    _dueDate = initial?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) {
      setState(
        () => _dueDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.todoNeedTitle),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    final noteText = _note.text.trim();
    final note = noteText.isEmpty ? null : noteText;
    final due = _isPermanent ? null : _dueDate;
    final repository = ref.read(todoRepositoryProvider);

    if (_isEdit) {
      await repository.updateTodo(
        id: widget.initial!.id!,
        title: title,
        priority: _priority,
        dueDate: due,
        clearDueDate: due == null,
        note: note,
        clearNote: note == null,
      );
    } else {
      await repository.createTodo(
        title: title,
        priority: _priority,
        dueDate: due,
        note: note,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('todoEditScreen'),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEdit ? l10n.todoEditItemTitle : l10n.todoNewItemTitle,
          style: const TextStyle(
            color: CuteColors.matcha,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _SectionLabel(l10n.todoFormTitleLabel),
                  TextField(
                    key: const Key('todoTitleField'),
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: CuteColors.textBrown,
                    ),
                    decoration: _fieldDecoration(theme, l10n.todoFormTitleHint),
                  ),
                  _SectionLabel(l10n.todoFormPriorityLabel),
                  _PriorityRow(
                    selected: _priority,
                    permanentLabel: l10n.todoPriorityPermanent,
                    onChanged: (p) => setState(() {
                      _priority = p;
                      if (p == TodoPriority.permanent) {
                        _dueDate = null;
                      }
                    }),
                  ),
                  if (!_isPermanent) ...[
                    _SectionLabel(l10n.todoFormDueLabel),
                    _DueRow(
                      today: _today,
                      dueDate: _dueDate,
                      sameDay: _sameDay,
                      pickLabel: l10n.todoDuePick,
                      todayLabel: l10n.todoDueToday,
                      tomorrowLabel: l10n.todoDueTomorrow,
                      onToday: () => setState(
                        () => _dueDate = _sameDay(_dueDate, _today)
                            ? null
                            : _today,
                      ),
                      onTomorrow: () {
                        final tomorrow = _today.add(const Duration(days: 1));
                        setState(
                          () => _dueDate = _sameDay(_dueDate, tomorrow)
                              ? null
                              : tomorrow,
                        );
                      },
                      onPick: _pickDate,
                    ),
                  ],
                  _SectionLabel(l10n.todoFormNoteLabel),
                  TextField(
                    key: const Key('todoNoteField'),
                    controller: _note,
                    minLines: 4,
                    maxLines: 8,
                    style: const TextStyle(
                      fontSize: 15,
                      color: CuteColors.textBrown,
                      height: 1.4,
                    ),
                    decoration: _fieldDecoration(theme, l10n.todoFormNoteHint),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: CandyButton(
                label: _isEdit
                    ? l10n.todoSaveButton
                    : '＋ ${l10n.todoCreateButton}',
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(ThemeData theme, String hint) {
    OutlineInputBorder border() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: CuteColors.borderPeach2, width: 2),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: CuteColors.textFaint2,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: CuteColors.fieldBg,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(),
    );
  }
}

/// Edit-route entry that resolves the todo by id when it wasn't passed as
/// `extra` (e.g. a cold deep-link). The normal path — detail "⋯ -> edit" —
/// passes the todo directly, so this loader rarely renders.
class TodoEditLoader extends ConsumerWidget {
  const TodoEditLoader({required this.todoId, super.key});

  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoByIdProvider(todoId));

    return todoAsync.maybeWhen(
      data: (todo) =>
          todo == null ? const TodoEditScreen() : TodoEditScreen(initial: todo),
      orElse: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: CuteColors.textMuted2,
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({
    required this.selected,
    required this.permanentLabel,
    required this.onChanged,
  });

  final TodoPriority selected;
  final String permanentLabel;
  final ValueChanged<TodoPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final priority in TodoPriority.values)
          _PriorityChip(
            priority: priority,
            label: switch (priority) {
              TodoPriority.p0 => 'P0',
              TodoPriority.p1 => 'P1',
              TodoPriority.p2 => 'P2',
              TodoPriority.permanent => '♾️ $permanentLabel',
            },
            selected: priority == selected,
            onTap: () => onChanged(priority),
          ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final TodoPriority priority;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (text, bg, border) = switch (priority) {
      TodoPriority.p0 => (
        CuteColors.todoP0Text,
        CuteColors.todoP0Bg,
        CuteColors.todoP0Border,
      ),
      TodoPriority.p1 => (
        CuteColors.todoP1Text,
        CuteColors.todoP1Bg,
        CuteColors.todoP1Border,
      ),
      TodoPriority.p2 => (
        CuteColors.todoP2Text,
        CuteColors.todoP2Bg,
        CuteColors.todoP2Border,
      ),
      TodoPriority.permanent => (
        CuteColors.todoPermText,
        CuteColors.todoPermFlagBg,
        CuteColors.todoPermFlagBorder,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          // Selected = solid fill in the priority colour, white text.
          color: selected ? text : bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? text : border, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: selected ? CuteColors.white : text,
          ),
        ),
      ),
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({
    required this.today,
    required this.dueDate,
    required this.sameDay,
    required this.pickLabel,
    required this.todayLabel,
    required this.tomorrowLabel,
    required this.onToday,
    required this.onTomorrow,
    required this.onPick,
  });

  final DateTime today;
  final DateTime? dueDate;
  final bool Function(DateTime?, DateTime) sameDay;
  final String pickLabel;
  final String todayLabel;
  final String tomorrowLabel;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final tomorrow = today.add(const Duration(days: 1));
    final isToday = sameDay(dueDate, today);
    final isTomorrow = sameDay(dueDate, tomorrow);
    final isCustom = dueDate != null && !isToday && !isTomorrow;
    final pickText = isCustom
        ? MaterialLocalizations.of(context).formatShortDate(dueDate!)
        : '$pickLabel 📅';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DueChip(label: todayLabel, selected: isToday, onTap: onToday),
        _DueChip(label: tomorrowLabel, selected: isTomorrow, onTap: onTomorrow),
        _DueChip(
          key: const Key('todoDuePickChip'),
          label: pickText,
          selected: isCustom,
          onTap: onPick,
        ),
      ],
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? null : CuteColors.white,
          gradient: selected ? CuteColors.matchaGradient : null,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? CuteColors.matchaGradientBottom
                : CuteColors.borderMint,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? CuteColors.white : CuteColors.matcha,
          ),
        ),
      ),
    );
  }
}
