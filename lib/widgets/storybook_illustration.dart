import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A soft illustrated sky used behind onboarding and splash content.
class SkyBackground extends StatelessWidget {
  final Widget child;
  final bool showSun;

  const SkyBackground({
    super.key,
    required this.child,
    this.showSun = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: CustomPaint(
        painter: _CloudPainter(showSun: showSun),
        child: child,
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final bool showSun;

  _CloudPainter({required this.showSun});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    if (showSun) {
      final sunPaint = Paint()..color = const Color(0xFFFFE9A8).withValues(alpha: 0.55);
      canvas.drawCircle(
        Offset(width * 0.84, height * 0.13),
        width * 0.16,
        sunPaint,
      );
    }

    _cloud(
      canvas,
      Offset(width * 0.06, height * 0.14),
      width * 0.25,
      0.92,
    );
    _cloud(
      canvas,
      Offset(width * 0.86, height * 0.24),
      width * 0.22,
      0.8,
    );
    _cloud(
      canvas,
      Offset(width * 0.18, height * 0.45),
      width * 0.16,
      0.65,
    );
    _cloud(
      canvas,
      Offset(width * 0.9, height * 0.52),
      width * 0.19,
      0.7,
    );
    _cloud(
      canvas,
      Offset(width * 0.02, height * 0.68),
      width * 0.2,
      0.6,
    );

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final dot in [
      Offset(width * 0.13, height * 0.31),
      Offset(width * 0.76, height * 0.08),
      Offset(width * 0.68, height * 0.41),
      Offset(width * 0.32, height * 0.58),
    ]) {
      canvas.drawCircle(dot, 3.5, dotPaint);
    }
  }

  void _cloud(Canvas canvas, Offset anchor, double radius, double opacity) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final base = Rect.fromCenter(
      center: Offset(anchor.dx + radius, anchor.dy + radius * 0.42),
      width: radius * 3.1,
      height: radius * 0.95,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, Radius.circular(radius * 0.5)),
      paint,
    );
    canvas.drawCircle(Offset(anchor.dx + radius * 0.75, anchor.dy), radius * 0.62, paint);
    canvas.drawCircle(Offset(anchor.dx + radius * 1.45, anchor.dy - radius * 0.2), radius * 0.8, paint);
    canvas.drawCircle(Offset(anchor.dx + radius * 2.15, anchor.dy + radius * 0.08), radius * 0.58, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The signature Panchatantra illustration: a happy reader, an open storybook,
/// alphabet bubbles and a soft rainbow of story blobs.
class StorybookIllustration extends StatelessWidget {
  final double size;
  final bool showBackdrop;

  const StorybookIllustration({
    super.key,
    this.size = 330,
    this.showBackdrop = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StorybookPainter(showBackdrop: showBackdrop),
      ),
    );
  }
}

class _StorybookPainter extends CustomPainter {
  final bool showBackdrop;

  _StorybookPainter({required this.showBackdrop});

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final scale = side / 360;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(scale);

    if (showBackdrop) {
      _paintBackdrop(canvas);
    }
    _paintBookShadow(canvas);
    _paintLegs(canvas);
    _paintBody(canvas);
    _paintArms(canvas);
    _paintHead(canvas);
    _paintBook(canvas);
    _paintBubbles(canvas);
    _paintConfetti(canvas);

    canvas.restore();
  }

  void _paintBackdrop(Canvas canvas) {
    canvas.drawCircle(
      const Offset(92, 210),
      90,
      Paint()..color = const Color(0xFFF7A38C),
    );
    canvas.drawCircle(
      const Offset(254, 154),
      62,
      Paint()..color = const Color(0xFFF6CF6E),
    );
    canvas.drawCircle(
      const Offset(196, 249),
      87,
      Paint()..color = const Color(0xFFA9D8C9),
    );
    canvas.drawCircle(
      const Offset(298, 263),
      46,
      Paint()..color = const Color(0xFFF5B8C8),
    );
    canvas.drawCircle(
      const Offset(64, 120),
      38,
      Paint()..color = const Color(0x66FFFFFF),
    );

    // Little grassy ground poking out below the book.
    final grassPaint = Paint()..color = const Color(0xFF7EBF8C);
    final grass = Path()
      ..moveTo(38, 309)
      ..quadraticBezierTo(104, 294, 172, 305)
      ..quadraticBezierTo(242, 316, 324, 300)
      ..lineTo(326, 340)
      ..lineTo(36, 340)
      ..close();
    canvas.drawPath(grass, grassPaint);

    final backGrass = Paint()..color = const Color(0xFF9ED2A8);
    final hill = Path()
      ..moveTo(18, 320)
      ..quadraticBezierTo(90, 304, 155, 317)
      ..lineTo(155, 340)
      ..lineTo(18, 340)
      ..close();
    canvas.drawPath(hill, backGrass);
  }

  void _paintBookShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(180, 329), width: 220, height: 25),
      Paint()..color = Colors.black.withValues(alpha: 0.10),
    );
  }

  void _paintLegs(Canvas canvas) {
    final pants = Paint()..color = const Color(0xFFF0B84B);
    final skin = Paint()..color = const Color(0xFFF2BA8E);
    final shoe = Paint()..color = const Color(0xFFE45D5D);

    canvas.save();
    canvas.translate(145, 256);
    canvas.rotate(-0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, 0, 34, 34),
        const Radius.circular(14),
      ),
      pants,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, 27, 20, 27),
        const Radius.circular(9),
      ),
      skin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-19, 46, 34, 18),
        const Radius.circular(9),
      ),
      shoe,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(215, 256);
    canvas.rotate(0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-19, 0, 34, 34),
        const Radius.circular(14),
      ),
      pants,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 27, 20, 27),
        const Radius.circular(9),
      ),
      skin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, 46, 34, 18),
        const Radius.circular(9),
      ),
      shoe,
    );
    canvas.restore();
  }

  void _paintBody(Canvas canvas) {
    final shirt = Paint()..color = const Color(0xFF4BA9D6);
    final shirtDark = Paint()..color = const Color(0xFF3797C4);

    final body = Path()
      ..moveTo(153, 171)
      ..quadraticBezierTo(180, 160, 207, 171)
      ..lineTo(225, 235)
      ..quadraticBezierTo(225, 255, 203, 259)
      ..lineTo(157, 259)
      ..quadraticBezierTo(135, 255, 135, 235)
      ..close();
    canvas.drawPath(body, shirt);

    // Collar
    final collar = Path()
      ..moveTo(168, 167)
      ..quadraticBezierTo(180, 185, 192, 167)
      ..lineTo(188, 191)
      ..quadraticBezierTo(180, 198, 172, 191)
      ..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xFFF4C84F));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(158, 244, 44, 15),
        const Radius.circular(7),
      ),
      shirtDark,
    );
  }

  void _paintArms(Canvas canvas) {
    final skin = Paint()
      ..color = const Color(0xFFF2BA8E)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(148, 195), const Offset(112, 236), skin);
    canvas.drawLine(const Offset(212, 195), const Offset(251, 232), skin);

    final sleeve = Paint()
      ..color = const Color(0xFF4BA9D6)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(153, 184), const Offset(143, 200), sleeve);
    canvas.drawLine(const Offset(207, 184), const Offset(217, 199), sleeve);

    final handPaint = Paint()..color = const Color(0xFFF2BA8E);
    canvas.drawCircle(const Offset(109, 239), 10, handPaint);
    canvas.drawCircle(const Offset(253, 235), 10, handPaint);
  }

  void _paintHead(Canvas canvas) {
    final hair = Paint()..color = const Color(0xFF5E3B2E);
    final hairLight = Paint()..color = const Color(0xFF754B39);
    final skin = Paint()..color = const Color(0xFFF5C29A);
    final blush = Paint()..color = const Color(0xFFFFA7A0).withValues(alpha: 0.8);

    // Back hair
    canvas.drawCircle(const Offset(181, 120), 50, hair);

    // Buns
    canvas.drawCircle(const Offset(138, 76), 19, hair);
    canvas.drawCircle(const Offset(226, 76), 19, hair);
    canvas.drawCircle(const Offset(138, 76), 12, hairLight);
    canvas.drawCircle(const Offset(226, 76), 12, hairLight);

    // Hair tie bows
    _drawBow(canvas, const Offset(130, 96), 0.85);
    _drawBow(canvas, const Offset(235, 96), -0.85);

    // Ears
    canvas.drawCircle(const Offset(138, 132), 8, skin);
    canvas.drawCircle(const Offset(224, 132), 8, skin);

    // Face
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(181, 129), width: 80, height: 88),
      skin,
    );

    // Fringe
    final fringe = Path()
      ..moveTo(139, 105)
      ..quadraticBezierTo(151, 74, 181, 77)
      ..quadraticBezierTo(212, 78, 224, 107)
      ..quadraticBezierTo(210, 94, 196, 96)
      ..quadraticBezierTo(185, 108, 172, 95)
      ..quadraticBezierTo(154, 109, 139, 105)
      ..close();
    canvas.drawPath(fringe, hair);

    // Blush
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(156, 148), width: 17, height: 10),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(207, 148), width: 17, height: 10),
      blush,
    );

    // Glasses
    final glasses = Paint()
      ..color = const Color(0xFF7A4B34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawCircle(const Offset(165, 128), 13, glasses);
    canvas.drawCircle(const Offset(198, 128), 13, glasses);
    canvas.drawLine(const Offset(178, 127), const Offset(185, 127), glasses);

    // Eyes
    final eye = Paint()..color = const Color(0xFF33251F);
    canvas.drawCircle(const Offset(165, 129), 3.5, eye);
    canvas.drawCircle(const Offset(198, 129), 3.5, eye);
    canvas.drawCircle(
      const Offset(166.5, 127.5),
      1.2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(199.5, 127.5),
      1.2,
      Paint()..color = Colors.white,
    );

    // Smile
    final smile = Paint()
      ..color = const Color(0xFF7A3A36)
      ..style = PaintingStyle.fill;
    final mouth = Path()
      ..moveTo(171, 147)
      ..quadraticBezierTo(182, 160, 194, 146)
      ..quadraticBezierTo(183, 153, 171, 147)
      ..close();
    canvas.drawPath(mouth, smile);
  }

  void _drawBow(Canvas canvas, Offset center, double tilt) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    final bowPaint = Paint()..color = const Color(0xFFE95E67);
    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(-17, -8)
      ..quadraticBezierTo(-22, 0, -17, 8)
      ..close();
    final right = Path()
      ..moveTo(0, 0)
      ..lineTo(17, -8)
      ..quadraticBezierTo(22, 0, 17, 8)
      ..close();
    canvas.drawPath(left, bowPaint);
    canvas.drawPath(right, bowPaint);
    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFFC94754));
    canvas.restore();
  }

  void _paintBook(Canvas canvas) {
    final cover = Paint()..color = const Color(0xFFC9557E);
    final coverDark = Paint()..color = const Color(0xFFAE446C);
    final page = Paint()..color = const Color(0xFFFFF8E7);
    final pageLine = Paint()
      ..color = const Color(0xFFE7D5BC)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Cover
    final coverPath = Path()
      ..moveTo(49, 278)
      ..quadraticBezierTo(117, 252, 178, 277)
      ..quadraticBezierTo(243, 251, 311, 278)
      ..lineTo(311, 330)
      ..quadraticBezierTo(245, 307, 180, 331)
      ..quadraticBezierTo(114, 307, 49, 330)
      ..close();
    canvas.drawPath(coverPath, cover);

    // Spine
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(173, 276, 14, 52),
        const Radius.circular(6),
      ),
      coverDark,
    );

    // Pages
    final leftPage = Path()
      ..moveTo(58, 276)
      ..quadraticBezierTo(116, 256, 176, 281)
      ..lineTo(176, 322)
      ..quadraticBezierTo(118, 299, 58, 320)
      ..close();
    final rightPage = Path()
      ..moveTo(184, 281)
      ..quadraticBezierTo(244, 256, 302, 276)
      ..lineTo(302, 320)
      ..quadraticBezierTo(243, 300, 184, 322)
      ..close();
    canvas.drawPath(leftPage, page);
    canvas.drawPath(rightPage, page);

    for (var i = 0; i < 4; i++) {
      final y = 291.0 + i * 7;
      canvas.drawLine(Offset(82, y + 6), Offset(156, y - 1), pageLine);
      canvas.drawLine(Offset(205, y - 1), Offset(279, y + 6), pageLine);
    }

    // Page bottom highlights
    canvas.drawLine(
      const Offset(62, 316),
      const Offset(154, 304),
      Paint()
        ..color = const Color(0xFFFFFDF6)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(207, 304),
      const Offset(298, 316),
      Paint()
        ..color = const Color(0xFFFFFDF6)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintBubbles(Canvas canvas) {
    _drawLetterBubble(canvas, const Offset(65, 166), 24, 'A', const Color(0xFF6BBE73));
    _drawLetterBubble(canvas, const Offset(302, 110), 21, 'B', const Color(0xFF8A6BC9));
    _drawLetterBubble(canvas, const Offset(300, 190), 18, 'C', const Color(0xFFF0A64D));

    // A small book bubble at the top right.
    final bubble = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(const Offset(286, 56), 23, bubble);
    final bookPaint = Paint()..color = const Color(0xFFF37358);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(275, 47, 22, 17),
        const Radius.circular(4),
      ),
      bookPaint,
    );
    canvas.drawLine(
      const Offset(286, 48),
      const Offset(286, 63),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  void _drawLetterBubble(
    Canvas canvas,
    Offset center,
    double radius,
    String letter,
    Color color,
  ) {
    canvas.drawCircle(
      center,
      radius + 3,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(center, radius, Paint()..color = color);

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1.15,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
        ),
      ),
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintConfetti(Canvas canvas) {
    final starPaint = Paint()..color = const Color(0xFFE95E67);
    _drawStar(canvas, const Offset(326, 155), 11, starPaint);
    _drawStar(
      canvas,
      const Offset(44, 251),
      8,
      Paint()..color = const Color(0xFFF5C24B),
    );
    _drawStar(
      canvas,
      const Offset(240, 47),
      7,
      Paint()..color = const Color(0xFF6BBE73),
    );

    final dot = Paint()..color = const Color(0xFF8A6BC9);
    canvas.drawCircle(const Offset(44, 208), 5, dot);
    canvas.drawCircle(
      const Offset(314, 243),
      6,
      Paint()..color = const Color(0xFF4BA9D6),
    );
    canvas.drawCircle(
      const Offset(100, 61),
      4,
      Paint()..color = const Color(0xFFF0A64D),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StorybookPainter oldDelegate) {
    return oldDelegate.showBackdrop != showBackdrop;
  }
}
