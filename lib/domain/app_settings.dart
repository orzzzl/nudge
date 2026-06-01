import 'dart:ui';

enum LocaleOverride { system, en, zh }

class AppSettings {
  const AppSettings({required this.dnd, required this.localeOverride});

  static const defaults = AppSettings(
    dnd: false,
    localeOverride: LocaleOverride.system,
  );

  final bool dnd;
  final LocaleOverride localeOverride;

  Locale? get resolvedLocale {
    return switch (localeOverride) {
      LocaleOverride.system => null,
      LocaleOverride.en => const Locale('en'),
      LocaleOverride.zh => const Locale('zh'),
    };
  }

  AppSettings copyWith({bool? dnd, LocaleOverride? localeOverride}) {
    return AppSettings(
      dnd: dnd ?? this.dnd,
      localeOverride: localeOverride ?? this.localeOverride,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppSettings &&
            other.dnd == dnd &&
            other.localeOverride == localeOverride;
  }

  @override
  int get hashCode => Object.hash(dnd, localeOverride);
}
