import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/cute_palette.dart';
import 'pet_mood.dart';

const _bodyTop = Color(0xFFB8E6C4);
const _bodyShadow = Color(0xFF6CC488);
const _ink = Color(0xFF3A4A3F);
const _cheek = Color(0x99FF9B8A);
const _sadLeaf = Color(0xFF8BC99B);

class PetView extends StatelessWidget {
  const PetView({required this.mood, this.size = 24, super.key});

  final PetMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _TuanTuanPainter(mood)),
    );
  }
}

class _TuanTuanPainter extends CustomPainter {
  const _TuanTuanPainter(this.mood);

  final PetMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final bodyRect = Rect.fromLTWH(
      size.width * 0.14,
      size.height * 0.28,
      size.width * 0.72,
      size.height * 0.60,
    );
    final bodyPath = _bodyPath(bodyRect);
    final shadowOffset = Offset(0, side * 0.075);

    canvas.drawPath(
      bodyPath.shift(shadowOffset),
      Paint()
        ..color = _bodyShadow
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bodyTop, CuteColors.matchaGradientTop],
        ).createShader(bodyRect),
    );

    _drawInnerHighlight(canvas, bodyPath, bodyRect);
    _drawSprout(canvas, bodyRect, side);
    _drawFace(canvas, bodyRect, side);

    if (mood == PetMood.happy) {
      _drawSparkle(canvas, size, side);
    }
  }

  Path _bodyPath(Rect rect) {
    final width = rect.width;
    final height = rect.height;
    final centerX = rect.center.dx;

    return Path()
      ..moveTo(centerX, rect.top)
      ..cubicTo(
        rect.right - width * 0.08,
        rect.top,
        rect.right,
        rect.top + height * 0.18,
        rect.right,
        rect.top + height * 0.50,
      )
      ..cubicTo(
        rect.right,
        rect.bottom - height * 0.16,
        rect.right - width * 0.20,
        rect.bottom,
        centerX,
        rect.bottom,
      )
      ..cubicTo(
        rect.left + width * 0.20,
        rect.bottom,
        rect.left,
        rect.bottom - height * 0.16,
        rect.left,
        rect.top + height * 0.50,
      )
      ..cubicTo(
        rect.left,
        rect.top + height * 0.18,
        rect.left + width * 0.08,
        rect.top,
        centerX,
        rect.top,
      )
      ..close();
  }

  void _drawInnerHighlight(Canvas canvas, Path bodyPath, Rect bodyRect) {
    canvas.save();
    canvas.clipPath(bodyPath);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          bodyRect.center.dx,
          bodyRect.top + bodyRect.height * 0.22,
        ),
        width: bodyRect.width * 0.74,
        height: bodyRect.height * 0.34,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withAlpha(120), Colors.white.withAlpha(0)],
        ).createShader(bodyRect),
    );
    canvas.restore();
  }

  void _drawSprout(Canvas canvas, Rect bodyRect, double side) {
    final stemPaint = Paint()
      ..color = mood == PetMood.sad ? _sadLeaf : CuteColors.matchaVivid
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = side * 0.035;
    final leafPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: mood == PetMood.sad
                ? const [_sadLeaf, CuteColors.matcha]
                : const [CuteColors.mintConfirm, CuteColors.matchaGradientTop],
          ).createShader(
            Rect.fromCenter(
              center: Offset(bodyRect.center.dx, bodyRect.top - side * 0.08),
              width: side * 0.36,
              height: side * 0.24,
            ),
          );

    final base = Offset(bodyRect.center.dx, bodyRect.top + side * 0.03);
    final tip = switch (mood) {
      PetMood.sad => Offset(
        bodyRect.center.dx + side * 0.10,
        bodyRect.top - side * 0.14,
      ),
      PetMood.neutral => Offset(
        bodyRect.center.dx + side * 0.01,
        bodyRect.top - side * 0.17,
      ),
      PetMood.happy => Offset(
        bodyRect.center.dx - side * 0.02,
        bodyRect.top - side * 0.19,
      ),
    };
    canvas.drawLine(base, tip, stemPaint);

    final leafCenter = switch (mood) {
      PetMood.sad => Offset(
        bodyRect.center.dx + side * 0.13,
        bodyRect.top - side * 0.15,
      ),
      PetMood.neutral => Offset(
        bodyRect.center.dx - side * 0.06,
        bodyRect.top - side * 0.18,
      ),
      PetMood.happy => Offset(
        bodyRect.center.dx - side * 0.08,
        bodyRect.top - side * 0.20,
      ),
    };
    final angle = switch (mood) {
      PetMood.sad => 0.72,
      PetMood.neutral => -0.28,
      PetMood.happy => -0.44,
    };

    canvas.save();
    canvas.translate(leafCenter.dx, leafCenter.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, -side * 0.12)
      ..cubicTo(
        side * 0.16,
        -side * 0.09,
        side * 0.19,
        side * 0.06,
        0,
        side * 0.13,
      )
      ..cubicTo(
        -side * 0.19,
        side * 0.06,
        -side * 0.16,
        -side * 0.09,
        0,
        -side * 0.12,
      )
      ..close();
    canvas.drawPath(leaf, leafPaint);
    canvas.drawPath(
      leaf,
      Paint()
        ..color = Colors.white.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.012,
    );
    canvas.restore();
  }

  void _drawFace(Canvas canvas, Rect bodyRect, double side) {
    final eyePaint = Paint()..color = _ink;
    final cheekPaint = Paint()..color = _cheek;
    final leftEye = Offset(
      bodyRect.left + bodyRect.width * 0.36,
      bodyRect.top + bodyRect.height * 0.46,
    );
    final rightEye = Offset(
      bodyRect.left + bodyRect.width * 0.64,
      bodyRect.top + bodyRect.height * 0.46,
    );
    final cheekY = bodyRect.top + bodyRect.height * 0.61;
    final cheekRadius = Radius.elliptical(side * 0.055, side * 0.034);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyRect.left + bodyRect.width * 0.25, cheekY),
        width: cheekRadius.x * 2,
        height: cheekRadius.y * 2,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyRect.left + bodyRect.width * 0.75, cheekY),
        width: cheekRadius.x * 2,
        height: cheekRadius.y * 2,
      ),
      cheekPaint,
    );

    switch (mood) {
      case PetMood.happy:
        _drawHappyEyes(canvas, leftEye, rightEye, side, eyePaint);
        _drawMouth(canvas, bodyRect, side, _Mouth.smile);
      case PetMood.neutral:
        _drawNeutralEyes(canvas, leftEye, rightEye, side, eyePaint);
        _drawMouth(canvas, bodyRect, side, _Mouth.flat);
      case PetMood.sad:
        _drawSadEyes(canvas, leftEye, rightEye, side);
        _drawMouth(canvas, bodyRect, side, _Mouth.frown);
    }
  }

  void _drawHappyEyes(
    Canvas canvas,
    Offset leftEye,
    Offset rightEye,
    double side,
    Paint eyePaint,
  ) {
    final eyeRadius = side * 0.045;
    final highlightPaint = Paint()..color = Colors.white.withAlpha(220);

    for (final eye in [leftEye, rightEye]) {
      canvas.drawCircle(eye, eyeRadius, eyePaint);
      canvas.drawCircle(
        eye.translate(-eyeRadius * 0.35, -eyeRadius * 0.35),
        eyeRadius * 0.33,
        highlightPaint,
      );
    }
  }

  void _drawNeutralEyes(
    Canvas canvas,
    Offset leftEye,
    Offset rightEye,
    double side,
    Paint eyePaint,
  ) {
    final eyeRadius = Radius.elliptical(side * 0.040, side * 0.026);
    for (final eye in [leftEye, rightEye]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: eye,
          width: eyeRadius.x * 2,
          height: eyeRadius.y * 2,
        ),
        eyePaint,
      );
    }
  }

  void _drawSadEyes(
    Canvas canvas,
    Offset leftEye,
    Offset rightEye,
    double side,
  ) {
    final sadEyePaint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = side * 0.035;

    canvas.drawLine(
      leftEye.translate(-side * 0.045, -side * 0.012),
      leftEye.translate(side * 0.045, side * 0.018),
      sadEyePaint,
    );
    canvas.drawLine(
      rightEye.translate(-side * 0.045, side * 0.018),
      rightEye.translate(side * 0.045, -side * 0.012),
      sadEyePaint,
    );
  }

  void _drawMouth(Canvas canvas, Rect bodyRect, double side, _Mouth mouth) {
    final center = Offset(
      bodyRect.center.dx,
      bodyRect.top + bodyRect.height * 0.68,
    );
    final halfWidth = side * 0.075;
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = side * 0.025;

    switch (mouth) {
      case _Mouth.smile:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - halfWidth, center.dy - side * 0.010)
            ..quadraticBezierTo(
              center.dx,
              center.dy + side * 0.060,
              center.dx + halfWidth,
              center.dy - side * 0.010,
            ),
          paint,
        );
      case _Mouth.flat:
        canvas.drawLine(
          center.translate(-halfWidth * 0.82, 0),
          center.translate(halfWidth * 0.82, 0),
          paint,
        );
      case _Mouth.frown:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - halfWidth, center.dy + side * 0.035)
            ..quadraticBezierTo(
              center.dx,
              center.dy - side * 0.035,
              center.dx + halfWidth,
              center.dy + side * 0.035,
            ),
          paint,
        );
    }
  }

  void _drawSparkle(Canvas canvas, Size size, double side) {
    final center = Offset(size.width * 0.82, size.height * 0.23);
    final sparklePaint = Paint()
      ..color = CuteColors.peachGradientBottom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, side * 0.018);
    final radius = side * 0.055;

    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      sparklePaint,
    );
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TuanTuanPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}

enum _Mouth { smile, flat, frown }
