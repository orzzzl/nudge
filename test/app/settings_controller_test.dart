import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/app/providers.dart';
import 'package:nudge/domain/app_settings.dart';
import 'package:nudge/domain/settings_repository.dart';

void main() {
  test('loads defaults and persists setting mutations', () async {
    final repository = _InMemorySettingsRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    expect(container.read(settingsControllerProvider), AppSettings.defaults);
    await container.pump();
    expect(container.read(settingsControllerProvider), AppSettings.defaults);

    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setDnd(true);
    await controller.setLocaleOverride(LocaleOverride.zh);

    const persistedSettings = AppSettings(
      dnd: true,
      localeOverride: LocaleOverride.zh,
    );
    expect(repository.settings, persistedSettings);
    expect(container.read(settingsControllerProvider), persistedSettings);

    final restartedContainer = _container(repository);
    addTearDown(restartedContainer.dispose);
    expect(
      restartedContainer.read(settingsControllerProvider),
      AppSettings.defaults,
    );
    await restartedContainer.pump();
    expect(
      restartedContainer.read(settingsControllerProvider),
      persistedSettings,
    );
  });
}

ProviderContainer _container(SettingsRepository repository) {
  return ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
  );
}

class _InMemorySettingsRepository implements SettingsRepository {
  AppSettings settings = AppSettings.defaults;

  @override
  Future<AppSettings> load() async {
    return settings;
  }

  @override
  Future<void> setDnd(bool value) async {
    settings = settings.copyWith(dnd: value);
  }

  @override
  Future<void> setLocaleOverride(LocaleOverride value) async {
    settings = settings.copyWith(localeOverride: value);
  }
}
