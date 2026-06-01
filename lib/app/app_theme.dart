import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cute_palette.dart';

/// The cute "macaron" theme — the single chokepoint for color, shape, and type
/// (see [CuteColors]). Per-screen content gets its bespoke styling in task 15;
/// this builds the foundation + the shared shell look.
ThemeData buildAppTheme() {
  // Map the FULL set of roles, not just primary/secondary/surface — the default
  // ColorScheme.light leaves the *container* and surfaceContainer* roles at
  // Material's lavender/purple-grey, which leaks through any widget that uses
  // them (e.g. the stats hero's primaryContainer). Everything reads matcha /
  // peach / cream now so stock teal/purple is impossible anywhere.
  final colorScheme = const ColorScheme.light().copyWith(
    primary: CuteColors.matcha,
    onPrimary: CuteColors.white,
    primaryContainer: CuteColors.matchaGradientBottom,
    onPrimaryContainer: CuteColors.white,
    secondary: CuteColors.peachGradientBottom,
    onSecondary: CuteColors.white,
    secondaryContainer: CuteColors.borderPeach,
    onSecondaryContainer: CuteColors.textBrown,
    tertiary: CuteColors.matchaVivid,
    onTertiary: CuteColors.white,
    tertiaryContainer: CuteColors.mintConfirm,
    onTertiaryContainer: CuteColors.matcha,
    surface: CuteColors.surface,
    onSurface: CuteColors.textBrown,
    onSurfaceVariant: CuteColors.textMuted,
    surfaceContainerLowest: CuteColors.white,
    surfaceContainerLow: CuteColors.surface,
    surfaceContainer: CuteColors.cream,
    surfaceContainerHigh: CuteColors.borderCream,
    surfaceContainerHighest: CuteColors.borderCream,
    outline: CuteColors.borderNeutral,
    outlineVariant: CuteColors.borderCream,
    surfaceTint: Colors.transparent,
    inversePrimary: CuteColors.matchaGradientTop,
  );

  final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
    // Transparent so CuteBackground's gradient shows through every screen.
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: CuteColors.matcha,
      // Dark status-bar icons — they sit on the light cream backdrop now.
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CuteColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 66,
      indicatorColor: CuteColors.mintConfirm,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: selected ? CuteColors.matcha : CuteColors.textFaint,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? CuteColors.matcha : CuteColors.textFaint,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: CuteColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CuteColors.white,
      side: const BorderSide(color: CuteColors.borderPeach, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CuteColors.fieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: CuteColors.borderPeach2, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: CuteColors.borderPeach2, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: CuteColors.peachGradientBottom,
          width: 2,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: CuteColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: CuteColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );
}

/// Baloo 2 for Latin with a rounded Chinese fallback (ZCOOL KuaiLe) so zh text
/// is also rounded; heavy weights throughout to match the mockup (w600–w900).
TextTheme _buildTextTheme(TextTheme base) {
  final zhFallback = GoogleFonts.zcoolKuaiLe().fontFamily;
  final rounded = GoogleFonts.baloo2TextTheme(base).apply(
    bodyColor: CuteColors.textBrown,
    displayColor: CuteColors.textBrown,
    fontFamilyFallback: zhFallback == null ? null : [zhFallback],
  );

  TextStyle? heavier(TextStyle? style, FontWeight weight) =>
      style?.copyWith(fontWeight: weight);

  return rounded.copyWith(
    displayLarge: heavier(rounded.displayLarge, FontWeight.w900),
    displayMedium: heavier(rounded.displayMedium, FontWeight.w900),
    displaySmall: heavier(rounded.displaySmall, FontWeight.w900),
    headlineLarge: heavier(rounded.headlineLarge, FontWeight.w900),
    headlineMedium: heavier(rounded.headlineMedium, FontWeight.w800),
    headlineSmall: heavier(rounded.headlineSmall, FontWeight.w800),
    titleLarge: heavier(rounded.titleLarge, FontWeight.w800),
    titleMedium: heavier(rounded.titleMedium, FontWeight.w800),
    titleSmall: heavier(rounded.titleSmall, FontWeight.w700),
    bodyLarge: heavier(rounded.bodyLarge, FontWeight.w600),
    bodyMedium: heavier(rounded.bodyMedium, FontWeight.w600),
    labelLarge: heavier(rounded.labelLarge, FontWeight.w800),
    labelMedium: heavier(rounded.labelMedium, FontWeight.w700),
  );
}
