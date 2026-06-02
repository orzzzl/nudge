import 'package:flutter/material.dart';

import '../../../app/cute_palette.dart';
import '../../../app/widgets/candy.dart';
import '../stats_summary.dart';

/// Left space reserved for y-axis labels. Shared by the painter (which plots
/// points in `[_kChartLeftGutter, width]`) and the hit-test, so a tap maps to
/// the same bucket the dot is drawn at.
const double _kChartLeftGutter = 32;

/// A hand-drawn (no chart dep) line chart card for one metric over [points],
/// stock-style: a soft gridded area, a matcha polyline, and a tap/drag readout
/// that highlights the nearest bucket and shows its date + value. Empty buckets
/// are zero-filled, so the line is continuous (no gaps).
class StatsLineChart extends StatefulWidget {
  const StatsLineChart({
    required this.title,
    required this.points,
    required this.valueOf,
    required this.yMax,
    required this.valueLabel,
    required this.yAxisLabel,
    required this.dateLabel,
    super.key,
  });

  final String title;
  final List<StatsPoint> points;

  /// The plotted value for a point, or null to gap the line (e.g. no completion).
  final double? Function(StatsPoint) valueOf;

  /// Top of the y-axis (e.g. max planned hours, or 1.0 for completion).
  final double yMax;

  /// Formats a point's value for the readout (e.g. "3.5 h" / "80%").
  final String Function(StatsPoint) valueLabel;

  /// Formats a y-axis gridline value (e.g. "3.5h" / "50%").
  final String Function(double) yAxisLabel;

  /// Formats a bucket start for axis/readout labels (locale + range aware).
  final String Function(DateTime) dateLabel;

  @override
  State<StatsLineChart> createState() => _StatsLineChartState();
}

class _StatsLineChartState extends State<StatsLineChart> {
  int? _selected;

  void _selectAt(double dx, double width) {
    final n = widget.points.length;
    if (n == 0) {
      return;
    }
    // Map within the plot area (after the y-axis gutter), matching the painter.
    final plotW = width - _kChartLeftGutter;
    final ratio = plotW <= 0
        ? 0.0
        : ((dx - _kChartLeftGutter) / plotW).clamp(0.0, 1.0);
    final index = n == 1 ? 0 : (ratio * (n - 1)).round();
    if (index != _selected) {
      setState(() => _selected = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = (_selected != null && _selected! < widget.points.length)
        ? widget.points[_selected!]
        : null;

    return CandyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: CuteColors.textMuted2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Readout: the selected bucket's date + value (or latest hint).
              if (selected != null)
                Text(
                  '${widget.dateLabel(selected.start)}  ·  '
                  '${widget.valueLabel(selected)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: CuteColors.matchaVivid,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Empty ranges still render a flat zero line (buckets are zero-filled),
          // so there's no separate empty state.
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _selectAt(d.localPosition.dx, width),
                onHorizontalDragUpdate: (d) =>
                    _selectAt(d.localPosition.dx, width),
                child: SizedBox(
                  height: 132,
                  width: width,
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      points: widget.points,
                      valueOf: widget.valueOf,
                      yMax: widget.yMax,
                      selected: _selected,
                      labelFor: widget.dateLabel,
                      yAxisLabel: widget.yAxisLabel,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.valueOf,
    required this.yMax,
    required this.selected,
    required this.labelFor,
    required this.yAxisLabel,
  });

  final List<StatsPoint> points;
  final double? Function(StatsPoint) valueOf;
  final double yMax;
  final int? selected;
  final String Function(DateTime) labelFor;
  final String Function(double) yAxisLabel;

  static const _labelGutter = 22.0; // bottom space for x-axis labels

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - _labelGutter;
    final plotLeft = _kChartLeftGutter;
    final plotW = size.width - _kChartLeftGutter;
    final n = points.length;
    final safeMax = yMax <= 0 ? 1.0 : yMax;

    double xAt(int i) =>
        n == 1 ? plotLeft + plotW / 2 : plotLeft + plotW * i / (n - 1);
    double yAt(double v) => chartH - (v / safeMax).clamp(0.0, 1.0) * chartH;

    // Gridlines (baseline + two above) in faint cream, with a y-axis label at
    // the left of each (0 / mid / max).
    final grid = Paint()
      ..color = CuteColors.borderCream
      ..strokeWidth = 1.5;
    final yLabelStyle = TextStyle(
      color: CuteColors.textFaint2,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    for (final frac in [0.0, 0.5, 1.0]) {
      final y = chartH - frac * chartH;
      canvas.drawLine(Offset(plotLeft, y), Offset(size.width, y), grid);
      final tp = TextPainter(
        text: TextSpan(text: yAxisLabel(safeMax * frac), style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _kChartLeftGutter - 4);
      tp.paint(
        canvas,
        Offset(_kChartLeftGutter - 6 - tp.width, y - tp.height / 2),
      );
    }

    // Polyline, broken into segments of consecutive non-null values.
    final line = Paint()
      ..shader = const LinearGradient(
        colors: [CuteColors.matchaGradientTop, CuteColors.matchaGradientBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartH))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path? segment;
    for (var i = 0; i < n; i++) {
      final v = valueOf(points[i]);
      if (v == null) {
        if (segment != null) {
          canvas.drawPath(segment, line);
          segment = null;
        }
        continue;
      }
      final p = Offset(xAt(i), yAt(v));
      if (segment == null) {
        segment = Path()..moveTo(p.dx, p.dy);
      } else {
        segment.lineTo(p.dx, p.dy);
      }
    }
    if (segment != null) {
      canvas.drawPath(segment, line);
    }

    // Dots.
    final dot = Paint()..color = CuteColors.matchaGradientBottom;
    for (var i = 0; i < n; i++) {
      final v = valueOf(points[i]);
      if (v == null) {
        continue;
      }
      canvas.drawCircle(Offset(xAt(i), yAt(v)), 2.5, dot);
    }

    // Selected marker: a vertical guide + an enlarged ringed dot.
    if (selected != null && selected! < n) {
      final v = valueOf(points[selected!]);
      final x = xAt(selected!);
      final guide = Paint()
        ..color = CuteColors.peachGradientBottom.withAlpha(120)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), guide);
      if (v != null) {
        final c = Offset(x, yAt(v));
        canvas.drawCircle(
          c,
          5,
          Paint()..color = CuteColors.peachGradientBottom,
        );
        canvas.drawCircle(c, 2.5, Paint()..color = CuteColors.white);
      }
    }

    // Sparse x-axis labels (first / thirds / last), de-duplicated.
    final indices = <int>{0, (n - 1) ~/ 3, 2 * (n - 1) ~/ 3, n - 1};
    final textStyle = TextStyle(
      color: CuteColors.textFaint2,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
    for (final i in indices) {
      if (i < 0 || i >= n) {
        continue;
      }
      final tp = TextPainter(
        text: TextSpan(text: labelFor(points[i].start), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      var dx = xAt(i) - tp.width / 2;
      dx = dx.clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) {
    return old.points != points || old.selected != selected || old.yMax != yMax;
  }
}
