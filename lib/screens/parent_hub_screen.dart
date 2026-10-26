import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import 'parent_voice_enroll_screen.dart';

class ParentHubScreen extends StatelessWidget {
  const ParentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final voice = appState.voiceProfile;

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
              title: 'Parent Hub',
              subtitle: 'Your voice, your rules, your child’s safety',
              trailing: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text('🛡️', style: TextStyle(fontSize: 21)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _VoiceStatusCard(appState: appState),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: voice.isEnrolled
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openEnrollment(context),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Re-calibrate'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: appState.toggleParentVoice,
                            icon: Icon(
                              appState.useParentVoice
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_rounded,
                              size: 18,
                            ),
                            label: Text(
                              appState.useParentVoice ? 'Pause voice' : 'Use voice',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appState.useParentVoice
                                  ? AppColors.accentCyan
                                  : AppColors.textLight,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : PrimaryCta(
                      label: 'Enroll my voice',
                      icon: Icons.mic_rounded,
                      onPressed: () => _openEnrollment(context),
                    ),
            ),
            if (voice.isEnrolled) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.chipRose,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Revoke & delete',
                            style: GoogleFonts.nunito(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Wipe your voice biometrics instantly. Narrations switch back to the studio storyteller.',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.textMedium,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showRevokeDialog(context, appState),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete my voice data'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(
                            color: AppColors.danger.withValues(alpha: 0.35),
                          ),
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Our privacy promises',
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SecurityFeature(
                    icon: Icons.lock_outline_rounded,
                    color: AppColors.headerPrimary,
                    background: AppColors.chipPurple,
                    title: 'Stays on this device',
                    desc:
                        'Story history and your child’s interactions never train external AI models.',
                  ),
                  _SecurityFeature(
                    icon: Icons.child_care_rounded,
                    color: AppColors.cardReading,
                    background: AppColors.chipRose,
                    title: 'Never clone a child’s voice',
                    desc:
                        'Voice synthesis politely refuses recordings from anyone under 18.',
                  ),
                  _SecurityFeature(
                    icon: Icons.verified_user_outlined,
                    color: AppColors.success,
                    background: AppColors.chipGreen,
                    title: 'Always say it’s AI',
                    desc:
                        'Every parent-voice story carries a clear AI narration label.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEnrollment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParentVoiceEnrollScreen()),
    );
  }

  static void _showRevokeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete your voice?',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This permanently removes your voice sample and encryption keys from this device.',
          style: GoogleFonts.nunito(
            fontSize: 13,
            height: 1.45,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.revokeParentVoice();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice profile deleted. Studio narrator is active.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VoiceStatusCard extends StatelessWidget {
  final AppState appState;

  const _VoiceStatusCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final voice = appState.voiceProfile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerPrimary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -26,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: voice.isEnrolled
                                ? AppColors.accentGreen
                                : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          voice.isEnrolled ? 'VOICE READY' : 'NOT ENROLLED',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                voice.isEnrolled ? voice.parentName : 'A storyteller in your voice',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                voice.isEnrolled
                    ? 'Consent recorded • voice stays on this device'
                    : 'Read one short passage and hear bedtime stories in your warm tone.',
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (voice.isEnrolled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeroStat(
                      icon: Icons.fingerprint_rounded,
                      label: 'Encrypted',
                    ),
                    const SizedBox(width: 10),
                    _HeroStat(
                      icon: Icons.timer_outlined,
                      label: '${voice.sampleLengthSeconds.toInt()}s sample',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentGold, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityFeature extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String desc;

  const _SecurityFeature({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.nunito(
                    fontSize: 10.5,
                    color: AppColors.textLight,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
