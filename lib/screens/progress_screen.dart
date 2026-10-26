import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import '../widgets/radar_chart.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 105,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KidPageHeader(
              title: 'My Progress',
              subtitle: 'Every story grows a brand-new skill',
              trailing: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text('🌱', style: TextStyle(fontSize: 21)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '${profile.minutesReadToday}',
                      label: 'minutes',
                      emoji: '⏰',
                      background: const Color(0xFFFFE4DB),
                      foreground: AppColors.cardReading,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      value: '${profile.completedStoryIds.length}',
                      label: 'stories',
                      emoji: '📚',
                      background: const Color(0xFFFFF0CF),
                      foreground: const Color(0xFFBD8931),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      value: '${profile.starsCount}',
                      label: 'stars',
                      emoji: '⭐',
                      background: const Color(0xFFE8F5ED),
                      foreground: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: KidCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your skill garden',
                                style: GoogleFonts.baloo2(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Six little skills growing together',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'GROWING',
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    EloRadarChart(
                      eloRatings: profile.eloRatings,
                      size: 245,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 17)),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Next up: stories with strong Niti and character-motive twists will grow your brightest areas.',
                              style: GoogleFonts.nunito(
                                fontSize: 10.5,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'The five Tantras',
                    style: GoogleFonts.baloo2(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _TantraTile(
                    title: 'The Loss of Friends',
                    subtitle: 'Mitra-bheda',
                    progress: 0.65,
                    color: AppColors.cardReading,
                    emoji: '🦁',
                  ),
                  _TantraTile(
                    title: 'Winning of Friends',
                    subtitle: 'Mitra-prapti',
                    progress: 0.40,
                    color: AppColors.cardNumbers,
                    emoji: '🐒',
                  ),
                  _TantraTile(
                    title: 'Crows and Owls',
                    subtitle: 'Kakolukiyam',
                    progress: 0.20,
                    color: AppColors.cardDrawing,
                    emoji: '🦉',
                  ),
                  _TantraTile(
                    title: 'Loss of Gains',
                    subtitle: 'Labdhapranasam',
                    progress: 0.80,
                    color: AppColors.cardPuzzles,
                    emoji: '🐊',
                  ),
                  _TantraTile(
                    title: 'Ill-Considered Action',
                    subtitle: 'Apariksitakaraka',
                    progress: 0.35,
                    color: AppColors.headerPrimary,
                    emoji: '🐺',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final Color background;
  final Color foreground;

  const _StatTile({
    required this.value,
    required this.label,
    required this.emoji,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerDark.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: 25,
              height: 1,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TantraTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final String emoji;

  const _TantraTile({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 7),
                CandyProgressBar(
                  value: progress,
                  color: color,
                  background: color.withValues(alpha: 0.10),
                  height: 7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
