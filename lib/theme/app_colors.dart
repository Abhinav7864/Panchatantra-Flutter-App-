import 'package:flutter/material.dart';

/// Panchatantra Kids design tokens.
///
/// The palette is built around the illustrated storybook direction:
/// a violet hero header, a deep plum play area, warm candy-colored learning
/// cards, and a soft sky-blue world for onboarding.
class AppColors {
  AppColors._();

  // Hero header
  static const Color headerDark = Color(0xFF4A256A);
  static const Color headerPrimary = Color(0xFF77409F);
  static const Color headerLight = Color(0xFF9F65C6);
  static const Color headerGlow = Color(0xFFC69AE4);

  // Canvas
  static const Color background = Color(0xFFF7F9FE);
  static const Color cardSurface = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F7FC);
  static const Color cream = Color(0xFFFFFCF7);

  // Sky / illustration
  static const Color sky = Color(0xFFCDEAF9);
  static const Color skyDeep = Color(0xFFB3DDF3);
  static const Color skyLight = Color(0xFFEAF7FE);
  static const Color cloud = Color(0xFFFFFFFF);

  // Night play area
  static const Color night = Color(0xFF171522);
  static const Color nightSurface = Color(0xFF211D30);
  static const Color nightSoft = Color(0xFF2B263D);

  // Learning worlds
  static const Color cardReading = Color(0xFFF37358);
  static const Color cardReadingLight = Color(0xFFFF9A7E);
  static const Color cardNumbers = Color(0xFFE9B44C);
  static const Color cardNumbersLight = Color(0xFFFFCE72);
  static const Color cardDrawing = Color(0xFF4C8F80);
  static const Color cardDrawingLight = Color(0xFF6BB0A0);
  static const Color cardPuzzles = Color(0xFFC37D90);
  static const Color cardPuzzlesLight = Color(0xFFDD9EAE);

  // Soft chips
  static const Color chipPurple = Color(0xFFF0E8FA);
  static const Color chipBlue = Color(0xFFE4F5FD);
  static const Color chipRose = Color(0xFFFFECEF);
  static const Color chipAmber = Color(0xFFFFF4DA);
  static const Color chipGreen = Color(0xFFE9F6EF);

  // Accents
  static const Color accentCyan = Color(0xFF4FC4E8);
  static const Color accentCyanDark = Color(0xFF229BC2);
  static const Color accentCyanLight = Color(0xFFA7E5F7);
  static const Color accentGold = Color(0xFFFFC542);
  static const Color accentCoral = Color(0xFFF37358);
  static const Color accentGreen = Color(0xFF53B788);
  static const Color success = Color(0xFF4FA96B);
  static const Color warning = Color(0xFFF2A33C);
  static const Color danger = Color(0xFFE76464);
  static const Color aiBadgeGreen = Color(0xFF53B788);
  static const Color aiBadgeGreenBg = Color(0xFFE8F6EE);

  // Text
  static const Color textDark = Color(0xFF211F2D);
  static const Color textMedium = Color(0xFF5B5A6C);
  static const Color textLight = Color(0xFF9694A6);
  static const Color textWhite = Colors.white;

  // Bottom navigation
  static const Color bottomBarDark = Color(0xFF171522);
  static const Color bottomBarActive = Color(0xFF7E4AA6);
  static const Color bottomBarGlow = Color(0xFFA778C9);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF5A2D7C), Color(0xFF8B52B5)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient headerGradientSoft = LinearGradient(
    colors: [Color(0xFF7D46A6), Color(0xFFB37AD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyLight, sky],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF201C2E), night],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient readingGradient = LinearGradient(
    colors: [Color(0xFFF37358), Color(0xFFF88B66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient numbersGradient = LinearGradient(
    colors: [Color(0xFFE9B44C), Color(0xFFF4C45F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient drawingGradient = LinearGradient(
    colors: [Color(0xFF4C8F80), Color(0xFF64AB9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient puzzlesGradient = LinearGradient(
    colors: [Color(0xFFC37D90), Color(0xFFD992A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF58C9EB), Color(0xFF29A8D0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFFC65C), Color(0xFFF58A58)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
