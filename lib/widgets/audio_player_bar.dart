import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AudioPlayerBar extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final double speed;
  final bool isParentVoice;
  final bool isParentVoiceEnrolled;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onSpeedCycle;
  final VoidCallback onToggleVoice;

  const AudioPlayerBar({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.speed,
    required this.isParentVoice,
    required this.isParentVoiceEnrolled,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSpeedCycle,
    required this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerDark.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 10,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: isParentVoiceEnrolled ? onToggleVoice : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isParentVoice
                        ? AppColors.chipPurple
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isParentVoice
                            ? Icons.record_voice_over_rounded
                            : Icons.spatial_audio_rounded,
                        size: 14,
                        color: isParentVoice
                            ? AppColors.headerPrimary
                            : AppColors.textMedium,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isParentVoice ? "Parent's voice" : 'Studio narrator',
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isParentVoice
                              ? AppColors.headerPrimary
                              : AppColors.textMedium,
                        ),
                      ),
                      if (isParentVoiceEnrolled) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.sync_alt_rounded,
                          size: 12,
                          color: AppColors.headerPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.aiBadgeGreenBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.success,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'AI NARRATION',
                      style: GoogleFonts.nunito(
                        fontSize: 7.5,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDuration(progress * 480),
                style: GoogleFonts.nunito(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: AppColors.headerPrimary,
                    inactiveTrackColor: AppColors.chipPurple,
                    thumbColor: AppColors.headerPrimary,
                  ),
                  child: Slider(value: progress, onChanged: onSeek),
                ),
              ),
              Text(
                '08:00',
                style: GoogleFonts.nunito(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onSpeedCycle,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '${speed}x',
                  style: GoogleFonts.nunito(
                    color: AppColors.headerPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        onSeek((progress - 0.05).clamp(0.0, 1.0)),
                    icon: const Icon(
                      Icons.replay_10_rounded,
                      color: AppColors.textMedium,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onPlayPause,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.headerGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.headerPrimary.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    onPressed: () =>
                        onSeek((progress + 0.05).clamp(0.0, 1.0)),
                    icon: const Icon(
                      Icons.forward_10_rounded,
                      color: AppColors.textMedium,
                      size: 26,
                    ),
                  ),
                ],
              ),
              Icon(
                isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                color: AppColors.headerPrimary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(double totalSeconds) {
    final seconds = totalSeconds.round();
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}
