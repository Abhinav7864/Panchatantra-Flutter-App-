import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/custom_header.dart';
import '../widgets/category_chip.dart';
import '../widgets/story_card.dart';
import '../widgets/learning_art.dart';
import 'story_reader_screen.dart';
import 'quiz_screen.dart';
import 'child_profile_screen.dart';
import 'parent_voice_enroll_screen.dart';
import 'video_story_screen.dart';
import 'moral_reflection_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile;
    final recommended = appState.recommendedStory;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(
              childName: profile.childName,
              progressSubtitle: '${profile.starsCount} stars • ${profile.minutesReadToday} min today',
              onSearchChanged: (query) => appState.setSearchQuery(query),
              onAvatarTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildProfileScreen()),
                );
              },
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentVoiceEnrollScreen()),
                );
              },
              footer: CategoryChipRow(
                selectedLabel: appState.selectedCategory,
                onSelected: (category) => _onCategoryTap(context, appState, category),
              ),
            ),

            // Dark play area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's learn & play",
                          style: GoogleFonts.baloo2(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pick a colourful world to explore',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.48),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '3 day streak',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FeatureGridCard(
                          title: 'Reading',
                          subtitle: 'Fables that spark ideas',
                          world: LearningWorld.reading,
                          gradient: AppColors.readingGradient,
                          onTap: () {
                            appState.setActiveStory(appState.activeStory);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StoryReaderScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FeatureGridCard(
                          title: 'Numbers',
                          subtitle: 'Count, sort & solve',
                          world: LearningWorld.numbers,
                          gradient: AppColors.numbersGradient,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QuizScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FeatureGridCard(
                          title: 'Drawing',
                          subtitle: 'Colours, art & nature',
                          world: LearningWorld.drawing,
                          gradient: AppColors.drawingGradient,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎨 Drawing studio is coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FeatureGridCard(
                          title: 'Puzzles',
                          subtitle: 'Moral puzzles & recall',
                          world: LearningWorld.puzzles,
                          gradient: AppColors.puzzlesGradient,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QuizScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'A story for you',
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'AI PICK',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PersonalizedHeroCard(
              title: recommended.title,
              bookName: recommended.tantraBook,
              minutes: recommended.readingMinutes,
              level: recommended.cognitiveLevel,
              moral: recommended.moral,
              emoji: recommended.coverEmoji,
              isParentVoiceActive: appState.useParentVoice,
              onWatchVideo: () {
                appState.setActiveStory(recommended);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoStoryScreen()),
                );
              },
              onRead: () {
                appState.setActiveStory(recommended);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoryReaderScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, AppState appState, String category) {
    appState.setSelectedCategory(category);

    switch (category) {
      case 'Books':
        appState.setTabIndex(1);
        break;
      case 'Games':
        appState.setActiveStory(appState.activeStory);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoStoryScreen()),
        );
        break;
      case 'Quiz':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );
        break;
      case 'Writing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MoralReflectionScreen(score: 0, total: 0),
          ),
        );
        break;
      case 'Lessons':
        appState.setTabIndex(2);
        break;
    }
  }
}
