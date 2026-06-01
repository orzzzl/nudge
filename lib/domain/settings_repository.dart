import 'app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> load();

  Future<void> setDnd(bool value);

  Future<void> setLocaleOverride(LocaleOverride value);
}
