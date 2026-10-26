import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../models/story_model.dart';
import '../widgets/kid_ui.dart';
import 'story_reader_screen.dart';

class CelebrationScreen extends StatelessWidget {
  final int score;
  final int total;
  final Story story;

  const CelebrationScreen({
    super.key,
    required this.score,
    required this.total,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final nextStory = appState.recommendedStory;

    return Scaffold(
      backgroundColor: AppColors.skyLight,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF8EC), Color(0xFFE6F4FC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _ConfettiPainter())),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Story complete',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              Navigator.popUntil(context, (route) => route.isFirst),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _TrophyBadge(score: score, total: total),
                  const SizedBox(height: 16),
                  Text(
                    'You did it!',
                    style: GoogleFonts.baloo2(
                      fontSize: 36,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'You finished “${story.title}”',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RewardBadge(
                        emoji: '⭐',
                        label: '+3 stars',
                        background: AppColors.chipAmber,
                        foreground: const Color(0xFFB37A12),
                      ),
                      const SizedBox(width: 8),
                      _RewardBadge(
                        emoji: '📈',
                        label: '+22 Elo',
                        background: AppColors.chipPurple,
                        foreground: AppColors.headerPrimary,
                      ),
                      const SizedBox(width: 8),
                      _RewardBadge(
                        emoji: '📚',
                        label: '1 fable',
                        background: AppColors.chipRose,
                        foreground: AppColors.cardReading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  KidCard(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Skills that grew',
                              style: GoogleFonts.baloo2(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.chipPurple,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ELO ENGINE',
                                style: GoogleFonts.nunito(
                                  fontSize: 7.5,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.headerPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _EloRow(
                          label: 'Strategic thinking',
                          delta: '+24',
                          color: AppColors.cardNumbers,
                        ),
                        _EloRow(
                          label: 'Character motive',
                          delta: '+18',
                          color: AppColors.cardDrawing,
                        ),
                        _EloRow(
                          label: 'Story recall',
                          delta: '+14',
                          color: AppColors.cardReading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.headerPrimary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            nextStory.coverEmoji,
                            style: const TextStyle(fontSize: 29),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEXT FOR YOU',
                                style: GoogleFonts.nunito(
                                  fontSize: 8,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextStory.title,
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Picked to grow your next skill',
                                style: GoogleFonts.nunito(
                                  fontSize: 9.5,
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryCta(
                    label: 'Read the next story',
                    icon: Icons.auto_stories_rounded,
                    onPressed: () {
                      appState.setActiveStory(nextStory);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoryReaderScreen(),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(
                      'Back to my dashboard',
                      style: GoogleFonts.nunito(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  final int score;
  final int total;

  const _TrophyBadge({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.33),
                  AppColors.accentGold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.30),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 52)),
          ),
          Positioned(
            bottom: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.headerPrimary,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$score / $total correct',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 4,
            top: 25,
            child: Text('✨', style: TextStyle(fontSize: 23)),
          ),
          const Positioned(
            right: 1,
            bottom: 35,
            child: Text('⭐', style: TextStyle(fontSize: 19)),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color background;
  final Color foreground;

  const _RewardBadge({
    required this.emoji,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EloRow extends StatelessWidget {
  final String label;
  final String delta;
  final Color color;

  const _EloRow({
    required this.label,
    required this.delta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.chipGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$delta Elo',
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.cardReading,
      AppColors.cardNumbers,
      AppColors.cardDrawing,
      AppColors.cardPuzzles,
      AppColors.headerPrimary,
      AppColors.accentCyan,
    ];

    final random = math.Random(7);
    for (var i = 0; i < 34; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final color = colors[i % colors.length].withValues(alpha: 0.22);
      final paint = Paint()..color = color;
      if (i % 3 == 0) {
        final radius = 2.5 + random.nextDouble() * 3.5;
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else if (i % 3 == 1) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(random.nextDouble() * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 7 + random.nextDouble() * 5,
              height: 3 + random.nextDouble() * 2,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), 1.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
