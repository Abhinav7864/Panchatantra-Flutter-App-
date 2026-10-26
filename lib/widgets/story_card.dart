import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'kid_ui.dart';
import 'learning_art.dart';

class FeatureGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final LearningWorld world;
  final Gradient gradient;
  final VoidCallback onTap;

  const FeatureGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.world,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            height: 190,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -30,
                  top: -34,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -22,
                  bottom: -44,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 15, 15, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.baloo2(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                            child: const Icon(
                              Icons.north_east_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Expanded(
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(3, 4),
                            child: LearningWorldArt(
                              world: world,
                              width: 131,
                              height: 105,
                            ),
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
      ),
    );
  }
}

class PersonalizedHeroCard extends StatelessWidget {
  final String title;
  final String bookName;
  final int minutes;
  final int level;
  final String moral;
  final String emoji;
  final bool isParentVoiceActive;
  final VoidCallback onRead;
  final VoidCallback? onWatchVideo;

  const PersonalizedHeroCard({
    super.key,
    required this.title,
    required this.bookName,
    required this.minutes,
    required this.level,
    required this.moral,
    required this.emoji,
    this.isParentVoiceActive = true,
    required this.onRead,
    this.onWatchVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.chipRose,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      "TODAY'S PICK",
                      style: GoogleFonts.nunito(
                        color: AppColors.cardReading,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isParentVoiceActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.aiBadgeGreenBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.graphic_eq_rounded, size: 12, color: AppColors.aiBadgeGreen),
                      const SizedBox(width: 3),
                      Text(
                        'Parent voice',
                        style: GoogleFonts.nunito(
                          color: AppColors.aiBadgeGreen,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.baloo2(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookName,
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          '$minutes min',
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accentGold),
                        Text(
                          'Level $level',
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEFD9), Color(0xFFFFD9C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.headerPrimary.withValues(alpha: 0.06)),
            ),
            child: Text(
              '“$moral”',
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              if (onWatchVideo != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWatchVideo,
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                    label: const Text('Watch'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.headerPrimary,
                      side: BorderSide(
                        color: AppColors.headerPrimary.withValues(alpha: 0.24),
                      ),
                      backgroundColor: AppColors.chipPurple.withValues(alpha: 0.45),
                      minimumSize: const Size(0, 47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: PrimaryCta(
                  label: 'Read story',
                  icon: Icons.auto_stories_rounded,
                  height: 47,
                  onPressed: onRead,
                  gradient: AppColors.cyanGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
