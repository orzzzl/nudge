import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import 'cute_palette.dart';
import 'widgets/candy.dart';

class NudgeNavigationShell extends StatelessWidget {
  const NudgeNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Transparent so the app-root CuteBackground (in NudgeApp.builder) shows
    // through here too.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.appTitle,
              style: const TextStyle(
                color: CuteColors.matcha,
                fontWeight: FontWeight.w900,
                fontSize: 21,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 6),
            const Text('🌱', style: TextStyle(fontSize: 15)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _GearButton(
              tooltip: localizations.settingsEntryTooltip,
              onTap: () => context.push('/settings'),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: localizations.chatTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: localizations.statsTabLabel,
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// The mockup's settings entry: a soft round button (peach-cream fill + a small
/// candy shadow), not the default flat icon button.
class _GearButton extends StatelessWidget {
  const _GearButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CuteColors.fieldBg2,
              shape: BoxShape.circle,
              boxShadow: candyShadow(CuteColors.gearShadow, dy: 2),
            ),
            child: const Icon(
              Icons.settings,
              size: 18,
              color: CuteColors.textMuted2,
            ),
          ),
        ),
      ),
    );
  }
}
