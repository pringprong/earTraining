import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'colors.dart';
import 'helper.dart';

class ScatterPlot extends StatelessWidget {
  final List<LevelTestResults> results;
  final LevelInfo levelInfo;

  const ScatterPlot({
    required this.results,
    required this.levelInfo,
    super.key,
  });

  DateTime _parseTimestamp(String s) {
    // try ISO first, then fallback to common readable format used elsewhere
    DateTime? dt;
    try {
      dt = DateFormat('yyyy-MM-dd HH:mm').parseLoose(s);
    } catch (_) {
      dt = DateTime.now();
    }
    return dt;
  }

  @override
  Widget build(BuildContext context) {
    final points =
        results.map((r) {
          final dt = _parseTimestamp(r.timestamp);
          final score = r.score;
          final color = getTestResultColor(
            score,
            levelInfo.NumQuestions,
            levelInfo.PassingScore,
          );
          return _Point(dt, score.toDouble(), color, r.timestamp);
        }).toList();

    return CustomPaint(
      painter: _ScatterPlotPainter(points, levelInfo.NumQuestions),
      size: Size.infinite,
    );
  }
}

class _Point {
  final DateTime dt;
  final double y;
  final Color color;
  final String rawTs;
  _Point(this.dt, this.y, this.color, this.rawTs);
}

class _ScatterPlotPainter extends CustomPainter {
  final List<_Point> points;
  final int maxScore;
  _ScatterPlotPainter(this.points, this.maxScore);

  final double padding = 28.0;
  final TextStyle axisLabelStyle = TextStyle(
    color: Colors.white70,
    fontSize: 10,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis =
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 1;
    final paintGrid =
        Paint()
          ..color = Colors.white10
          ..strokeWidth = 1;
    final width = size.width;
    final height = size.height;
    if (points.isEmpty) return;

    // compute x range
    points.sort((a, b) => a.dt.compareTo(b.dt));
    DateTime minX = points.first.dt;
    DateTime maxX = points.last.dt;
    if (minX == maxX) {
      // make a tiny range
      minX = minX.subtract(Duration(minutes: 1));
      maxX = maxX.add(Duration(minutes: 1));
    }
    final totalSeconds = maxX.difference(minX).inSeconds.toDouble();

    // compute y range
    final yMax =
        (maxScore > 0)
            ? maxScore.toDouble()
            : (points.map((p) => p.y).fold(0.0, (a, b) => a > b ? a : b));
    final yMin = 0.0;

    // draw axes
    final left = padding;
    final right = width - padding;
    final top = padding;
    final bottom = height - padding;

    // X axis
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paintAxis);
    // Y axis
    canvas.drawLine(Offset(left, bottom), Offset(left, top), paintAxis);

    // horizontal grid lines & y labels
    final int yTicks = (yMax <= 5) ? yMax.toInt().clamp(1, 5) : 5;
    for (int i = 0; i <= yTicks; i++) {
      final t = yMin + (yMax - yMin) * (i / yTicks);
      final dy =
          bottom -
          ((t - yMin) / ((yMax - yMin) == 0 ? 1 : (yMax - yMin))) *
              (bottom - top);
      canvas.drawLine(Offset(left, dy), Offset(right, dy), paintGrid);
      final tp = TextPainter(
        text: TextSpan(text: t.toInt().toString(), style: axisLabelStyle),
        textDirection: ui.TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(4, dy - tp.height / 2));
    }

    // Precompute point positions
    final List<Offset> positions = [];
    for (final p in points) {
      final xFrac =
          p.dt.difference(minX).inSeconds.toDouble() /
          (totalSeconds == 0 ? 1 : totalSeconds);
      final x = left + xFrac * (right - left);
      final yFrac = (p.y - yMin) / ((yMax - yMin) == 0 ? 1 : (yMax - yMin));
      final y = bottom - yFrac * (bottom - top);
      positions.add(Offset(x, y));
    }

    // draw connecting lines: color = color of the second point in the segment
    for (int i = 0; i < positions.length - 1; i++) {
      final p1 = positions[i];
      final p2 = positions[i + 1];
      final segColor = points[i + 1].color;
      final linePaint =
          Paint()
            ..color = segColor.withValues(alpha: 0.9)
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true;
      canvas.drawLine(p1, p2, linePaint);
    }

    // draw points
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final pos = positions[i];
      final paintPoint = Paint()..color = p.color;
      canvas.drawCircle(pos, 6.0, paintPoint);
      // small white border
      canvas.drawCircle(
        pos,
        6.0,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white24
          ..strokeWidth = 1,
      );
    }

    // draw earliest/latest labels
    final DateFormat df = DateFormat('yyyy-MM-dd HH:mm');
    final earliest = df.format(points.first.dt.toLocal());
    final latest = df.format(points.last.dt.toLocal());
    final tp1 = TextPainter(
      text: TextSpan(text: earliest, style: axisLabelStyle),
      textDirection: ui.TextDirection.ltr,
    );
    tp1.layout(maxWidth: width / 2);
    tp1.paint(canvas, Offset(left, bottom + 4));
    final tp2 = TextPainter(
      text: TextSpan(text: latest, style: axisLabelStyle),
      textDirection: ui.TextDirection.ltr,
    );
    tp2.layout(maxWidth: width / 2);
    tp2.paint(canvas, Offset(right - tp2.width, bottom + 4));

    // Y-axis title
    final tpY = TextPainter(
      text: TextSpan(text: 'Score', style: axisLabelStyle),
      textDirection: ui.TextDirection.ltr,
    );
    tpY.layout();
    tpY.paint(canvas, Offset(left - tpY.width - 6, top));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
