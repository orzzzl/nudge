import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsDndLabel),
            subtitle: Text(l10n.settingsDndDescription),
            value: settings.dnd,
            onChanged: controller.setDnd,
          ),
          const Divider(height: 1),
          ListTile(title: Text(l10n.settingsLanguageLabel)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SegmentedButton<LocaleOverride>(
              segments: [
                ButtonSegment(
                  value: LocaleOverride.system,
                  label: Text(l10n.settingsLanguageSystem),
                ),
                ButtonSegment(
                  value: LocaleOverride.en,
                  label: Text(l10n.settingsLanguageEnglish),
                ),
                ButtonSegment(
                  value: LocaleOverride.zh,
                  label: Text(l10n.settingsLanguageChinese),
                ),
              ],
              selected: {settings.localeOverride},
              onSelectionChanged: (selection) {
                controller.setLocaleOverride(selection.single);
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(l10n.settingsAboutLabel),
            subtitle: packageInfo.when(
              data: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(info.appName),
                  Text(l10n.settingsVersionValue(info.version)),
                ],
              ),
              loading: () =>
                  const SizedBox(width: 120, child: LinearProgressIndicator()),
              error: (_, _) => Text(l10n.appTitle),
            ),
          ),
        ],
      ),
    );
  }
}
