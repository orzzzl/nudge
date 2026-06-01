import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import 'app_router.dart';
import 'app_theme.dart';
import 'providers.dart';
import 'widgets/cute_background.dart';

class NudgeApp extends ConsumerWidget {
  const NudgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    ref.watch(reminderSchedulerInitializationProvider);

    return MaterialApp.router(
      locale: settings.resolvedLocale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: appRouter,
      theme: buildAppTheme(),
      // The cream gradient sits behind EVERY route (shell, settings, check-in) —
      // each screen's Scaffold is transparent and shows it through. One paint at
      // the root keeps it static under page transitions.
      builder: (context, child) =>
          CuteBackground(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
