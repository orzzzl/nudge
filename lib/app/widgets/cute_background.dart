import 'package:flutter/material.dart';

import '../cute_palette.dart';

/// The warm cream backdrop with three soft radial-gradient blobs, mirroring the
/// mockup's `body` background. The navigation shell wraps its body in this and
/// makes the `Scaffold` transparent, so every tab sits on the same backdrop.
///
/// Mockup source:
///   radial-gradient(circle at 15% 12%, #ffe9d6 0%, transparent 35%)
///   radial-gradient(circle at 85% 85%, #e2f5e6 0%, transparent 38%)
///   radial-gradient(circle at 70% 25%, #f3e6ff 0%, transparent 30%)
class CuteBackground extends StatelessWidget {
  const CuteBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: CuteColors.cream),
      child: Stack(
        children: [
          // CSS percentage positions map to Alignment via x,y = pct/50 - 1.
          const _Blob(
            color: CuteColors.blobPeach,
            center: Alignment(-0.7, -0.76),
            radius: 0.55,
          ),
          const _Blob(
            color: CuteColors.blobMatcha,
            center: Alignment(0.7, 0.7),
            radius: 0.6,
          ),
          const _Blob(
            color: CuteColors.blobLavender,
            center: Alignment(0.4, -0.5),
            radius: 0.5,
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.center,
    required this.radius,
  });

  final Color color;
  final Alignment center;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: radius,
            colors: [color, color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}
