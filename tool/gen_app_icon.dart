import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/features/pet/pet_mood.dart';
import 'package:nudge/features/pet/pet_view.dart';

/// Renders the 团团 mascot into the launcher-icon source PNGs.
///
/// This is a generator, not a test — it lives under `tool/` so the normal
/// `flutter test` (which only scans `test/`) never runs it. Run it manually:
///
///   flutter test tool/gen_app_icon.dart
///   dart run flutter_launcher_icons
///
/// It writes two 1024² images to `assets/icon/`:
///  - `app_icon.png`            — cream background + 团团 (iOS / legacy Android)
///  - `app_icon_foreground.png` — transparent, smaller 团团 (Android adaptive)
void main() {
  const cream = Color(0xFFFFF3E6);

  testWidgets('full icon (cream background)', (tester) async {
    await _render(
      tester,
      const ColoredBox(
        color: cream,
        child: Center(child: PetView(mood: PetMood.happy, size: 880)),
      ),
      'assets/icon/app_icon.png',
    );
  });

  testWidgets('adaptive foreground (transparent, safe-zone)', (tester) async {
    // Smaller so 团团 survives the system's circular/rounded adaptive mask.
    await _render(
      tester,
      const Center(child: PetView(mood: PetMood.happy, size: 660)),
      'assets/icon/app_icon_foreground.png',
    );
  });
}

Future<void> _render(WidgetTester tester, Widget child, String path) async {
  Directory('assets/icon').createSync(recursive: true);
  await tester.binding.setSurfaceSize(const Size(1024, 1024));

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: SizedBox(width: 1024, height: 1024, child: child),
    ),
  );
  await tester.pump();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // toImage / toByteData are genuinely async (off the fake-async test clock), so
  // they must run inside runAsync or the await never completes.
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('Wrote $path');
  });
}
