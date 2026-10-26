import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum LearningWorld { reading, numbers, drawing, puzzles }

/// Small, colorful illustrations used inside the four learning-world cards.
class LearningWorldArt extends StatelessWidget {
  final LearningWorld world;
  final double width;
  final double height;

  const LearningWorldArt({
    super.key,
    required this.world,
    this.width = 128,
    this.height = 104,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: switch (world) {
        LearningWorld.reading => CustomPaint(painter: _ReadingArtPainter()),
        LearningWorld.numbers => const _NumbersArt(),
        LearningWorld.drawing => CustomPaint(painter: _DrawingArtPainter()),
        LearningWorld.puzzles => CustomPaint(painter: _PuzzleArtPainter()),
      },
    );
  }
}

class _NumbersArt extends StatelessWidget {
  const _NumbersArt();

  @override
  Widget build(BuildContext context) {
    const numbers = [
      ('1', Color(0xFFFFF7E5), -14, 12, 8),
      ('2', Color(0xFF72C9A1), 14, 32, 30),
      ('3', Color(0xFFF58B70), -8, 66, 46),
      ('4', Color(0xFF7F63BC), 10, 8, 58),
      ('5', Color(0xFFF3D15A), -18, 55, 74),
      ('6', Color(0xFF4FB5D6), 18, 92, 66),
      ('7', Color(0xFFE86586), -10, 100, 44),
      ('8', Color(0xFF72C9A1), 10, 48, 16),
      ('9', Color(0xFFF58B70), -12, 62, 88),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: numbers.map((entry) {
            final (text, color, rotation, left, top) = entry;
            return Positioned(
              left: left.toDouble(),
              top: top.toDouble(),
              child: Transform.rotate(
                angle: rotation * math.pi / 180,
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReadingArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 128, size.height / 104);
    canvas.save();
    canvas.translate((size.width - 128 * s) / 2, (size.height - 104 * s) / 2);
    canvas.scale(s);

    // Glow behind the reader.
    canvas.drawCircle(
      const Offset(64, 48),
      39,
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
    canvas.drawCircle(
      const Offset(104, 26),
      7,
      Paint()..color = const Color(0xFFF8D45F),
    );
    _star(canvas, const Offset(23, 24), 8, const Color(0xFFFFF1B5));

    // Tiny reader behind the book.
    final skin = Paint()..color = const Color(0xFFF5C29A);
    final hair = Paint()..color = const Color(0xFF5A382C);

    canvas.drawCircle(const Offset(64, 35), 25, hair);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(64, 42), width: 39, height: 37),
      skin,
    );
    canvas.drawCircle(const Offset(55, 43), 2.6, Paint()..color = AppColors.textDark);
    canvas.drawCircle(const Offset(73, 43), 2.6, Paint()..color = AppColors.textDark);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(64, 50), width: 12, height: 8),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF9A5045)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(48, 51),
      4,
      Paint()..color = const Color(0xFFFFA7A0).withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      const Offset(80, 51),
      4,
      Paint()..color = const Color(0xFFFFA7A0).withValues(alpha: 0.8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 63, 40, 30),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF4BA9D6),
    );

    // Open book.
    final cover = Paint()..color = const Color(0xFF9F3F61);
    final pages = Paint()..color = const Color(0xFFFFF8E7);
    final coverPath = Path()
      ..moveTo(10, 78)
      ..quadraticBezierTo(36, 69, 64, 78)
      ..quadraticBezierTo(92, 69, 118, 78)
      ..lineTo(118, 98)
      ..quadraticBezierTo(92, 89, 64, 99)
      ..quadraticBezierTo(36, 89, 10, 98)
      ..close();
    canvas.drawPath(coverPath, cover);

    final leftPage = Path()
      ..moveTo(14, 77)
      ..quadraticBezierTo(38, 70, 62, 78)
      ..lineTo(62, 93)
      ..quadraticBezierTo(38, 85, 14, 94)
      ..close();
    final rightPage = Path()
      ..moveTo(66, 78)
      ..quadraticBezierTo(90, 70, 114, 77)
      ..lineTo(114, 94)
      ..quadraticBezierTo(90, 85, 66, 93)
      ..close();
    canvas.drawPath(leftPage, pages);
    canvas.drawPath(rightPage, pages);

    final line = Paint()
      ..color = const Color(0xFFE2CDB6)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(23, 82), const Offset(52, 80), line);
    canvas.drawLine(const Offset(23, 87), const Offset(52, 85), line);
    canvas.drawLine(const Offset(76, 80), const Offset(105, 82), line);
    canvas.drawLine(const Offset(76, 85), const Offset(105, 87), line);

    // Little hands.
    canvas.drawCircle(const Offset(23, 77), 5, skin);
    canvas.drawCircle(const Offset(106, 77), 5, skin);

    canvas.restore();
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DrawingArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 128, size.height / 104);
    canvas.save();
    canvas.translate((size.width - 128 * s) / 2, (size.height - 104 * s) / 2);
    canvas.scale(s);

    // Easel legs.
    final wood = Paint()..color = const Color(0xFF8B5E42);
    final woodLight = Paint()..color = const Color(0xFFB47C59);
    canvas.save();
    canvas.translate(64, 64);
    canvas.rotate(-0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3, 0, 7, 42),
        const Radius.circular(4),
      ),
      wood,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(64, 64);
    canvas.rotate(0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, 0, 7, 42),
        const Radius.circular(4),
      ),
      wood,
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(61, 32, 6, 50),
        const Radius.circular(3),
      ),
      woodLight,
    );

    // Canvas.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 14, 64, 54),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFFF8F2E7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 14, 64, 54),
        const Radius.circular(7),
      ),
      Paint()
        ..color = const Color(0xFF7A4D35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(39, 21, 50, 40),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFDF9F0),
    );

    // Painting on the canvas.
    final paint = Paint();
    paint.color = const Color(0xFF6BC2DF);
    canvas.drawCircle(const Offset(50, 37), 9, paint);
    paint.color = const Color(0xFFF6C85A);
    canvas.drawCircle(const Offset(66, 31), 6, paint);
    paint.color = const Color(0xFFF07C67);
    canvas.drawPath(
      Path()
        ..moveTo(42, 62)
        ..quadraticBezierTo(58, 39, 77, 61)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFF69B585);
    canvas.drawCircle(const Offset(81, 45), 4, paint);

    // Paint palette.
    canvas.save();
    canvas.translate(91, 77);
    canvas.rotate(-0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, 0, 36, 21),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFFE9C9A4),
    );
    for (final spot in [
      (const Offset(-13, 6), const Color(0xFFF07C67)),
      (const Offset(-4, 3), const Color(0xFFF6C85A)),
      (const Offset(6, 6), const Color(0xFF6BC2DF)),
      (const Offset(-4, 13), const Color(0xFF69B585)),
    ]) {
      canvas.drawCircle(spot.$1, 3.2, Paint()..color = spot.$2);
    }
    canvas.restore();

    // Brush.
    canvas.save();
    canvas.translate(25, 71);
    canvas.rotate(0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 4, 28),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFB47C59),
    );
    canvas.drawCircle(
      const Offset(2, -2),
      4,
      Paint()..color = const Color(0xFFF07C67),
    );
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PuzzleArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 128, size.height / 104);
    canvas.save();
    canvas.translate((size.width - 128 * s) / 2, (size.height - 104 * s) / 2);
    canvas.scale(s);

    // Soft confetti.
    _star(canvas, const Offset(17, 28), 7, const Color(0xFFFFE08A));
    _star(canvas, const Offset(111, 80), 6, const Color(0xFFB7F0D4));
    canvas.drawCircle(
      const Offset(108, 19),
      5,
      Paint()..color = const Color(0xFFFFF3D2),
    );
    canvas.drawCircle(
      const Offset(22, 84),
      4,
      Paint()..color = const Color(0xFFD9F3FA),
    );

    _piece(
      canvas,
      center: const Offset(46, 38),
      angle: -0.16,
      color: const Color(0xFF64C4DF),
    );
    _piece(
      canvas,
      center: const Offset(84, 33),
      angle: 0.2,
      color: const Color(0xFFF4CC58),
    );
    _piece(
      canvas,
      center: const Offset(41, 70),
      angle: 0.12,
      color: const Color(0xFFF18A76),
    );
    _piece(
      canvas,
      center: const Offset(85, 69),
      angle: -0.12,
      color: const Color(0xFF7BC89D),
    );

    canvas.restore();
  }

  void _piece(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(-20, -18)
      ..lineTo(20, -18)
      ..quadraticBezierTo(20, -30, 29, -28)
      ..quadraticBezierTo(38, -25, 36, -16)
      ..quadraticBezierTo(36, -10, 26, -8)
      ..lineTo(20, -8)
      ..lineTo(20, 18)
      ..lineTo(-20, 18)
      ..lineTo(-20, 8)
      ..quadraticBezierTo(-32, 8, -33, 0)
      ..quadraticBezierTo(-32, -8, -20, -8)
      ..close();

    // Drop shadow.
    canvas.save();
    canvas.translate(1, 3);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.restore();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
