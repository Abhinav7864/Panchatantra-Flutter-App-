import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/glossary_modal.dart';
import '../widgets/kid_ui.dart';
import 'quiz_screen.dart';

class StoryReaderScreen extends StatelessWidget {
  const StoryReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final story = appState.activeStory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          KidPageHeader(
            title: story.title,
            subtitle: '${story.tantraBook.split(':').first.trim()} • ${story.readingMinutes} min read',
            showBackButton: true,
            trailing: SoftIconButton(
              icon: Icons.ios_share_rounded,
              size: 44,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story link copied!')),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StoryHero(story: story),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_edu_rounded,
                          color: AppColors.headerPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            story.originalSourceCitation,
                            style: GoogleFonts.nunito(
                              fontSize: 9.5,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'The story',
                        style: GoogleFonts.baloo2(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipAmber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'READ ALOUD',
                          style: GoogleFonts.nunito(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: const Color(0xFFB37A12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tap the golden words to discover what they mean.',
                    style: GoogleFonts.nunito(
                      fontSize: 10.5,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  KidCard(
                    padding: const EdgeInsets.all(19),
                    child: _buildInteractiveStoryText(
                      context,
                      story.adaptedText,
                      story.glossary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildIksCard(story),
                  const SizedBox(height: 20),
                  PrimaryCta(
                    label: 'Take the story quiz',
                    icon: Icons.psychology_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    },
                    gradient: AppColors.readingGradient,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AudioPlayerBar(
        isPlaying: appState.isPlaying,
        progress: appState.audioProgress,
        speed: appState.playbackSpeed,
        isParentVoice: appState.useParentVoice,
        isParentVoiceEnrolled: appState.voiceProfile.isEnrolled,
        onPlayPause: () => appState.togglePlayPause(),
        onSeek: (val) => appState.setAudioProgress(val),
        onSpeedCycle: () => appState.cyclePlaybackSpeed(),
        onToggleVoice: () => appState.toggleParentVoice(),
      ),
    );
  }

  Widget _buildIksCard(dynamic story) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.chipGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardDrawing.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Text('🌿', style: TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  story.iksConcept,
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245C3D),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            story.iksExplanation,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF326B4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStoryText(
    BuildContext context,
    String text,
    Map<String, String> glossary,
  ) {
    final paragraphs = text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final words = paragraph.split(' ');
        final spans = <InlineSpan>[];

        for (var i = 0; i < words.length; i++) {
          final word = words[i];
          final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
          String? definition;
          for (final key in glossary.keys) {
            if (key.toLowerCase() == cleanWord.toLowerCase()) {
              definition = glossary[key];
              break;
            }
          }

          if (definition != null) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () => GlossaryModal.show(context, cleanWord, definition!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipAmber,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB37A12),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: '$word ',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: RichText(text: TextSpan(children: spans)),
        );
      }).toList(),
    );
  }
}

class _StoryHero extends StatelessWidget {
  final dynamic story;

  const _StoryHero({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 174,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE5D6), Color(0xFFDDEBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -30,
            top: -38,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -56,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 17,
            top: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'BAND ${story.ageBand}',
                style: GoogleFonts.nunito(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.headerPrimary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 17,
            right: 120,
            top: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.characters.join(' • '),
                  style: GoogleFonts.nunito(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                Text(
                  story.moral,
                  style: GoogleFonts.baloo2(
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            right: 18,
            bottom: 12,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(story.coverEmoji, style: const TextStyle(fontSize: 49)),
            ),
          ),
          Positioned(
            right: 104,
            top: 22,
            child: _LetterBubble(
              letter: 'A',
              color: AppColors.cardDrawing,
              size: 28,
            ),
          ),
          Positioned(
            right: 30,
            top: 14,
            child: _LetterBubble(
              letter: 'B',
              color: AppColors.cardNumbers,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterBubble extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _LetterBubble({
    required this.letter,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
