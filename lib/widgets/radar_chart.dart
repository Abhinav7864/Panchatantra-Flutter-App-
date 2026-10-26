import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EloRadarChart extends StatelessWidget {
  final Map<String, double> eloRatings; // values typically 800 - 1600
  final double size;

  const EloRadarChart({
    super.key,
    required this.eloRatings,
    this.size = 240,
  });

  static const List<Map<String, String>> dimensions = [
    {'key': 'C1_recall', 'label': 'Recall (C1)'},
    {'key': 'C2_sequence', 'label': 'Plot (C2)'},
    {'key': 'C3_motive', 'label': 'Motive (C3)'},
    {'key': 'M1_perspective', 'label': 'Empathy (M1)'},
    {'key': 'M2_moral_dilemma', 'label': 'Ethics (M2)'},
    {'key': 'M3_niti_strategy', 'label': 'Niti (M3)'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(eloRatings: eloRatings),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, double> eloRatings;

  _RadarPainter({required this.eloRatings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.72;
    const count = 6;
    const angleStep = (2 * math.pi) / count;

    // Draw concentric web polygons (levels 25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = AppColors.headerLight.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int level = 1; level <= 4; level++) {
      final levelRadius = radius * (level / 4);
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spoke lines
    final spokePaint = Paint()
      ..color = AppColors.headerLight.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), spokePaint);
    }

    // Compute child Elo polygon points
    // Map Elo range [800..1400] to [0.2..1.0]
    final dataPath = Path();
    final pointOffsets = <Offset>[];

    for (int i = 0; i < count; i++) {
      final dim = EloRadarChart.dimensions[i]['key']!;
      final elo = eloRatings[dim] ?? 1000.0;
      final normalized = ((elo - 800.0) / 600.0).clamp(0.2, 1.0);
      final pointRadius = radius * normalized;

      final angle = -math.pi / 2 + i * angleStep;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);
      final offset = Offset(x, y);

      pointOffsets.add(offset);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Fill data polygon
    final fillPaint = Paint()
      ..color = AppColors.headerPrimary.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Stroke data polygon
    final outlinePaint = Paint()
      ..color = AppColors.headerPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(dataPath, outlinePaint);

    // Draw vertex dots
    final dotPaint = Paint()..color = AppColors.accentCyan;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final pt in pointOffsets) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 5, dotBorderPaint);
    }

    // Draw Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < count; i++) {
      final label = EloRadarChart.dimensions[i]['label']!;
      final angle = -math.pi / 2 + i * angleStep;
      final labelRadius = radius + 20;
      final lx = center.dx + labelRadius * math.cos(angle);
      final ly = center.dy + labelRadius * math.sin(angle);

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(lx - textPainter.width / 2, ly - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.eloRatings != eloRatings;
  }
}
