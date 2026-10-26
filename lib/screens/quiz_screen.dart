import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import 'moral_reflection_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final story = appState.activeStory;
    final questions = story.questions;

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: PrimaryCta(
            label: 'No questions here yet',
            onPressed: () => Navigator.pop(context),
            expand: false,
          ),
        ),
      );
    }

    final question = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          KidPageHeader(
            title: 'Story Quiz',
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
              child: Text(
                '${_currentIndex + 1}/${questions.length}',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Question ${_currentIndex + 1}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headerPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).toInt()}% complete',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  CandyProgressBar(
                    value: progress,
                    color: AppColors.headerPrimary,
                    height: 8,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE7DA), Color(0xFFFFD8C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _skillLabel(question.skill),
                                style: GoogleFonts.nunito(
                                  fontSize: 8.5,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.cardReading,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text('🧠', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Text(
                          question.prompt,
                          style: GoogleFonts.baloo2(
                            fontSize: 21,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: question.options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildOption(
                          appState: appState,
                          question: question,
                          index: index,
                        );
                      },
                    ),
                  ),
                  if (_answered) ...[
                    _buildExplanation(question.explanation),
                    const SizedBox(height: 12),
                  ],
                  if (_answered)
                    PrimaryCta(
                      label: _currentIndex + 1 < questions.length
                          ? 'Next question'
                          : 'Moral reflection',
                      icon: _currentIndex + 1 < questions.length
                          ? Icons.arrow_forward_rounded
                          : Icons.favorite_rounded,
                      height: 54,
                      gradient: AppColors.headerGradientSoft,
                      onPressed: () {
                        if (_currentIndex + 1 < questions.length) {
                          setState(() {
                            _currentIndex++;
                            _selectedOption = null;
                            _answered = false;
                          });
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MoralReflectionScreen(
                                score: _correctCount,
                                total: questions.length,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required AppState appState,
    required dynamic question,
    required int index,
  }) {
    final selected = _selectedOption == index;
    final correct = index == question.correctIndex;

    Color background = Colors.white;
    Color border = Colors.transparent;
    Color textColor = AppColors.textDark;
    Color badgeColor = AppColors.background;
    Color badgeText = AppColors.headerPrimary;

    if (_answered) {
      if (correct) {
        background = AppColors.chipGreen;
        border = AppColors.success.withValues(alpha: 0.35);
        textColor = const Color(0xFF22663C);
        badgeColor = AppColors.success;
        badgeText = Colors.white;
      } else if (selected) {
        background = AppColors.chipRose;
        border = AppColors.danger.withValues(alpha: 0.30);
        textColor = const Color(0xFFA13E3E);
        badgeColor = AppColors.danger;
        badgeText = Colors.white;
      }
    } else if (selected) {
      background = AppColors.chipPurple;
      border = AppColors.headerPrimary.withValues(alpha: 0.35);
    }

    return GestureDetector(
      onTap: _answered
          ? null
          : () {
              setState(() {
                _selectedOption = index;
                _answered = true;
                final isCorrect = index == question.correctIndex;
                if (isCorrect) _correctCount++;
                appState.recordAnswer(
                  skill: question.skill,
                  isCorrect: isCorrect,
                );
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.5),
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                String.fromCharCode(65 + index),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: badgeText,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.options[index],
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            if (_answered && correct)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            if (_answered && selected && !correct)
              const Icon(
                Icons.cancel_rounded,
                color: AppColors.danger,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.chipAmber,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF765311),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _skillLabel(String skill) {
    const labels = {
      'C1_recall': 'STORY RECALL',
      'C2_sequence': 'STORY ORDER',
      'C3_motive': 'CHARACTER MOTIVE',
      'M1_perspective': 'EMPATHY',
      'M2_moral_dilemma': 'MORAL REASONING',
      'M3_niti_strategy': 'STRATEGY • NITI',
    };
    return labels[skill] ?? skill.replaceAll('_', ' ').toUpperCase();
  }
}
