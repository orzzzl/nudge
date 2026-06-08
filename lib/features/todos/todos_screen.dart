import 'package:flutter/material.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import '../../app/cute_palette.dart';

/// Placeholder for the "list" (todo) tab. The real grouped list lands in
/// task 26; for now it shows a gentle empty state so the third tab is wired up
/// and navigable.
class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📋', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 16),
                Text(
                  localizations.todosEmptyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuteColors.textBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.todosEmptyBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuteColors.textMuted2,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
