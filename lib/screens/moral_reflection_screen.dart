import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import 'celebration_screen.dart';

class MoralReflectionScreen extends StatefulWidget {
  final int score;
  final int total;

  const MoralReflectionScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  State<MoralReflectionScreen> createState() => _MoralReflectionScreenState();
}

class _MoralReflectionScreenState extends State<MoralReflectionScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  bool _isVoiceRecording = false;

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final story = appState.activeStory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KidPageHeader(
              title: 'Moral Reflection',
              subtitle: story.title,
              showBackButton: true,
              trailing: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text('💭', style: TextStyle(fontSize: 21)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE4F4EC), Color(0xFFD4EEE0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🌿', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INDIAN WISDOM',
                                style: GoogleFonts.nunito(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFF3E7A58),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                story.iksConcept,
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF245C3D),
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'What do you think?',
                    style: GoogleFonts.baloo2(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'There is no wrong answer here. Just your own kind heart.',
                    style: GoogleFonts.nunito(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.headerDark.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“',
                          style: GoogleFonts.baloo2(
                            fontSize: 46,
                            height: 0.6,
                            color: AppColors.accentCoral.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          story.discussionPrompt,
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.chipBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.family_restroom_rounded,
                          color: AppColors.accentCyanDark,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Your thoughts stay in your private family journal. AI never judges a child’s morality.',
                            style: GoogleFonts.nunito(
                              fontSize: 9.5,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF25738B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Your reflection',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _thoughtController,
                    maxLines: 4,
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'I think the rabbit did what was right because...',
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _isVoiceRecording = !_isVoiceRecording);
                      if (_isVoiceRecording) {
                        _thoughtController.text =
                            'I think calm thinking and a brave heart helped the rabbit protect everyone.';
                      }
                    },
                    icon: Icon(
                      _isVoiceRecording
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      size: 18,
                      color: _isVoiceRecording
                          ? AppColors.danger
                          : AppColors.headerPrimary,
                    ),
                    label: Text(
                      _isVoiceRecording
                          ? 'Listening...'
                          : 'Speak your answer',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isVoiceRecording
                          ? AppColors.danger
                          : AppColors.headerPrimary,
                      side: BorderSide(
                        color: (_isVoiceRecording
                                ? AppColors.danger
                                : AppColors.headerPrimary)
                            .withValues(alpha: 0.25),
                      ),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                  const SizedBox(height: 25),
                  PrimaryCta(
                    label: 'Finish the story',
                    icon: Icons.emoji_events_rounded,
                    onPressed: () {
                      appState.finishStory(story.storyId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CelebrationScreen(
                            score: widget.score,
                            total: widget.total,
                            story: story,
                          ),
                        ),
                      );
                    },
                    gradient: AppColors.cyanGradient,
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
