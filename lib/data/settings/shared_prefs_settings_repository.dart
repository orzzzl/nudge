import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/app_settings.dart';
import '../../domain/settings_repository.dart';

const _dndKey = 'settings.dnd';
const _localeOverrideKey = 'settings.localeOverride';

class SharedPrefsSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeOverrideName = prefs.getString(_localeOverrideKey);

    return AppSettings(
      dnd: prefs.getBool(_dndKey) ?? AppSettings.defaults.dnd,
      localeOverride: _localeOverrideFromName(localeOverrideName),
    );
  }

  @override
  Future<void> setDnd(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dndKey, value);
  }

  @override
  Future<void> setLocaleOverride(LocaleOverride value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeOverrideKey, value.name);
  }

  LocaleOverride _localeOverrideFromName(String? name) {
    if (name == null) {
      return AppSettings.defaults.localeOverride;
    }

    return LocaleOverride.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AppSettings.defaults.localeOverride,
    );
  }
}
