import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import 'celebration_screen.dart';

class VideoQuestion {
  final int id;
  final double pauseTimestampSeconds;
  final double rewindTimestampSeconds;
  final String sentenceSnippet;
  final String category; // 'Video Recall' or 'Child Development'
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String iksNote;

  const VideoQuestion({
    required this.id,
    required this.pauseTimestampSeconds,
    required this.rewindTimestampSeconds,
    required this.sentenceSnippet,
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.iksNote,
  });
}

class VideoStoryScreen extends StatefulWidget {
  const VideoStoryScreen({super.key});

  // 5 Questions: First 2 Video Recall, Last 3 Child Development
  static const List<VideoQuestion> videoQuestions = [
    VideoQuestion(
      id: 1,
      pauseTimestampSeconds: 42.0,
      rewindTimestampSeconds: 12.0,
      sentenceSnippet: 'In a dense savanna forest ruled a ferocious king lion, hunting fearlessly every day...',
      category: 'Question 1 of 5 • Video Recall',
      prompt: 'Who is the fierce antagonist terrorizing all the woodland animals in the video?',
      options: [
        'The fierce King Lion',
        'A greedy hunter from the village',
        'A wild pack of hyenas',
      ],
      correctIndex: 0,
      explanation: 'The fierce King Lion hunted ruthlessly across the savanna, causing all the animals to live in fear.',
      iksNote: 'Panchatantra uses animal rulers to teach the consequences of unchecked arrogance in leadership.',
    ),
    VideoQuestion(
      id: 2,
      pauseTimestampSeconds: 92.0,
      rewindTimestampSeconds: 50.0,
      sentenceSnippet: "When it was the little rabbit's turn, he stood tall with a calm mind and clever plan...",
      category: 'Question 2 of 5 • Video Protagonist',
      prompt: 'Which clever protagonist bravely stepped forward with a calm, smart plan to save the jungle?',
      options: [
        'The swift spotted deer',
        'The clever little rabbit',
        'The striped zebra',
      ],
      correctIndex: 1,
      explanation: 'The clever little rabbit stepped forward, proving that quick intelligence (Buddhi) can outsmart raw physical strength.',
      iksNote: 'In Indian Knowledge Systems, the rabbit symbolizes Buddhi (discerning intellect) overcoming brute force.',
    ),
    VideoQuestion(
      id: 3,
      pauseTimestampSeconds: 142.0,
      rewindTimestampSeconds: 98.0,
      sentenceSnippet: 'The little rabbit took deep breaths, remaining calm and respectful even as the lion roared with rage...',
      category: 'Question 3 of 5 • Child Development & Empathy',
      prompt: 'If you were the little rabbit standing before the roaring, angry lion, how would you stay calm and brave?',
      options: [
        'Take slow deep breaths and focus on my clever plan',
        'Cry, scream, and run away as fast as possible',
        'Give up and blame the other animals',
      ],
      correctIndex: 0,
      explanation: 'Staying calm and focused during fear is called Dhairya (emotional courage) in ancient Indian wisdom.',
      iksNote: 'Emotional regulation allows children to make wise decisions even under pressure.',
    ),
    VideoQuestion(
      id: 4,
      pauseTimestampSeconds: 192.0,
      rewindTimestampSeconds: 150.0,
      sentenceSnippet: 'The clever rabbit led the lion to the deep stone well to see his imaginary rival...',
      category: 'Question 4 of 5 • Moral Reasoning Dilemma',
      prompt: 'The rabbit used the lion’s own reflection to trick him into jumping. In Panchatantra Niti, is outsmarting someone justified to protect innocent lives?',
      options: [
        'Yes, protecting the innocent community from harm is the highest duty (Dharma)',
        'No, tricking someone is always bad no matter who is in danger',
        'Only if the lion asked nicely first',
      ],
      correctIndex: 0,
      explanation: 'Panchatantra teaches situational ethics: defense of the weak against a violent tyrant is an act of righteousness.',
      iksNote: 'Dharma upholds the preservation of life and peace over rigid rules.',
    ),
    VideoQuestion(
      id: 5,
      pauseTimestampSeconds: 230.0,
      rewindTimestampSeconds: 198.0,
      sentenceSnippet: 'The entire jungle lived in peace, learning that wisdom and intellect always overcome brute anger...',
      category: 'Question 5 of 5 • Developmental Life Application',
      prompt: 'When you face a difficult challenge in real life (like a tough school lesson or a big fear), what is the best approach?',
      options: [
        'Use calm thinking, ask for advice, and find a smart strategy like the rabbit',
        'Get angry, yell, and try to force things through',
        'Give up immediately and pretend the problem doesn’t exist',
      ],
      correctIndex: 0,
      explanation: 'Wisdom, patience, and strategy (Niti) always produce better results than anger or frustration.',
      iksNote: 'This completes your 5-question comprehension and moral reasoning milestone!',
    ),
  ];

  @override
  State<VideoStoryScreen> createState() => _VideoStoryScreenState();
}

class _VideoStoryScreenState extends State<VideoStoryScreen> {
  static const List<VideoQuestion> videoQuestions = VideoStoryScreen.videoQuestions;

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  VideoQuestion? _activeQuestion;
  int? _selectedOption;
  bool _questionAnswered = false;
  final Set<int> _completedQuestionIds = {};
  VideoQuestion? _rewindingQuestion;
  bool _isSeekingToRewind = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/lion_and_clever_rabbit.mp4',
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.addListener(_videoListener);
      }).catchError((error) {
        debugPrint("Video init note: $error");
        setState(() {
          _isInitialized = true; // allow fallback UI
        });
      });
  }

  void _videoListener() {
    if (_isSeekingToRewind) return;

    if (!_controller.value.isPlaying && _controller.value.position >= _controller.value.duration) {
      // Check if last question needs triggering
      if (!_completedQuestionIds.contains(5) && _activeQuestion == null) {
        _triggerQuestion(videoQuestions.last);
      }
      return;
    }

    final currentPos = _controller.value.position.inMilliseconds / 1000.0;

    // If currently rewinding to re-watch a clue, wait until we reach the checkpoint again
    if (_rewindingQuestion != null) {
      if (currentPos < _rewindingQuestion!.pauseTimestampSeconds - 0.5) {
        return;
      }
    }

    for (final q in videoQuestions) {
      if (!_completedQuestionIds.contains(q.id) &&
          currentPos >= q.pauseTimestampSeconds &&
          _activeQuestion == null) {
        _triggerQuestion(q);
        break;
      }
    }
  }

  void _triggerQuestion(VideoQuestion q) {
    _controller.pause();
    setState(() {
      _activeQuestion = q;
      _rewindingQuestion = null;
      _selectedOption = null;
      _questionAnswered = false;
    });
  }

  Future<void> _rewindToSentence(VideoQuestion q) async {
    setState(() {
      _isSeekingToRewind = true;
      _rewindingQuestion = q;
      _activeQuestion = null;
      _selectedOption = null;
      _questionAnswered = false;
    });

    await _controller.pause();
    await _controller.seekTo(
      Duration(milliseconds: (q.rewindTimestampSeconds * 1000).toInt()),
    );
    if (mounted) {
      setState(() {
        _isSeekingToRewind = false;
      });
      await _controller.play();
    }
  }

  void _resumeVideo() {
    if (_activeQuestion != null) {
      _completedQuestionIds.add(_activeQuestion!.id);
    }

    final allDone = _completedQuestionIds.length >= videoQuestions.length;

    setState(() {
      _activeQuestion = null;
      _rewindingQuestion = null;
      _selectedOption = null;
      _questionAnswered = false;
    });

    if (allDone) {
      final appState = context.read<AppState>();
      appState.finishStory(appState.activeStory.storyId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CelebrationScreen(
            score: 5,
            total: 5,
            story: appState.activeStory,
          ),
        ),
      );
    } else {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: AppBar(
        backgroundColor: AppColors.night,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Animated Story Time',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.headerPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${_completedQuestionIds.length}/5',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.night,
                    AppColors.headerDark.withValues(alpha: 0.55),
                    AppColors.night,
                  ],
                ),
              ),
            ),
          ),

          // Video Player Core
          Center(
            child: _isInitialized && _controller.value.isInitialized
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.headerPrimary.withValues(alpha: 0.32),
                                blurRadius: 36,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'WATCH & WONDER',
                        style: GoogleFonts.nunito(
                          color: AppColors.accentCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          appState.activeStory.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.baloo2(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Watch the fable, then answer each little checkpoint to keep going.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.56),
                            fontSize: 11.5,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.accentCyan),
                      SizedBox(height: 14),
                      Text(
                        'Loading Animated Panchatantra Video...',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
          ),

          // In-Video Checkpoint Timeline Tracker (At Top)
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  const Text('Video Checkpoints:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(videoQuestions.length, (index) {
                        final q = videoQuestions[index];
                        final isCompleted = _completedQuestionIds.contains(q.id);
                        final isCurrent = _activeQuestion?.id == q.id;

                        Color color = Colors.grey.shade600;
                        if (isCompleted) color = const Color(0xFF4CAF50);
                        if (isCurrent) color = AppColors.accentCyan;

                        return Tooltip(
                          message: q.category,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: isCurrent ? 2 : 1),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rewind Scene Clue Banner when re-watching after an incorrect answer
          if (_rewindingQuestion != null && _activeQuestion == null)
            Positioned(
              top: 58,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A1647), Color(0xFF162544)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.replay_rounded,
                        color: AppColors.accentCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'RE-WATCHING SCENE CLUE',
                                style: GoogleFonts.nunito(
                                  color: AppColors.accentCyan,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text('🎧', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Listen closely to catch the answer!',
                            style: GoogleFonts.baloo2(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final q = _rewindingQuestion!;
                        _controller.seekTo(
                          Duration(
                            milliseconds:
                                (q.pauseTimestampSeconds * 1000).toInt(),
                          ),
                        );
                        _triggerQuestion(q);
                      },
                      child: Text(
                        'Ready! ❯',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Play / Pause Overlay Control if no question is active
          if (_activeQuestion == null && _isInitialized)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.accentCyan,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Skip to next question button for quick preview
                    IconButton(
                      tooltip: 'Next Question Checkpoint',
                      icon: const Icon(Icons.fast_forward_rounded, color: Colors.white70, size: 22),
                      onPressed: () {
                        final nextUnanswered = videoQuestions.firstWhere(
                          (q) => !_completedQuestionIds.contains(q.id),
                          orElse: () => videoQuestions.last,
                        );
                        _controller.seekTo(Duration(milliseconds: (nextUnanswered.pauseTimestampSeconds * 1000).toInt()));
                        _triggerQuestion(nextUnanswered);
                      },
                    ),
                  ],
                ),
              ),
            ),

          // In-Video Interactive Question Modal Overlay
          if (_activeQuestion != null)
            _buildInVideoQuestionOverlay(_activeQuestion!, appState),
        ],
      ),
    );
  }

  Widget _buildInVideoQuestionOverlay(VideoQuestion q, AppState appState) {
    return Container(
      color: Colors.black.withValues(alpha: 0.76),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.headerPrimary.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: q.id <= 2
                              ? AppColors.chipBlue
                              : AppColors.chipPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              q.id <= 2 ? 'STORY RECALL' : 'MORAL THINKING',
                              style: GoogleFonts.nunito(
                                fontSize: 8.5,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w900,
                                color: q.id <= 2
                                    ? AppColors.accentCyanDark
                                    : AppColors.headerPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipAmber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pause_rounded,
                              size: 12,
                              color: Color(0xFFB37A12),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'PAUSED',
                              style: GoogleFonts.nunito(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: const Color(0xFFB37A12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    q.prompt,
                    style: GoogleFonts.baloo2(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (idx) {
                    final isSelected = _selectedOption == idx;
                    final isCorrect = idx == q.correctIndex;
                    final answeredCorrectly = _selectedOption == q.correctIndex;

                    Color background = AppColors.background;
                    Color border = Colors.transparent;
                    Color textColor = AppColors.textDark;
                    Color badgeColor = Colors.white;
                    Color badgeText = AppColors.headerPrimary;

                    if (_questionAnswered) {
                      if (answeredCorrectly && isCorrect) {
                        background = AppColors.chipGreen;
                        border = AppColors.success.withValues(alpha: 0.35);
                        textColor = const Color(0xFF22663C);
                        badgeColor = AppColors.success;
                        badgeText = Colors.white;
                      } else if (isSelected && !isCorrect) {
                        background = AppColors.chipRose;
                        border = AppColors.danger.withValues(alpha: 0.3);
                        textColor = const Color(0xFFA13E3E);
                        badgeColor = AppColors.danger;
                        badgeText = Colors.white;
                      }
                    } else if (isSelected) {
                      background = AppColors.chipPurple;
                      border = AppColors.headerPrimary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: GestureDetector(
                        onTap: _questionAnswered
                            ? null
                            : () {
                                setState(() {
                                  _selectedOption = idx;
                                  _questionAnswered = true;
                                });
                                appState.recordAnswer(
                                  skill: q.id <= 2
                                      ? 'C1_recall'
                                      : 'M2_moral_dilemma',
                                  isCorrect: isCorrect,
                                );
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(color: border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 31,
                                height: 31,
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + idx),
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: badgeText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.options[idx],
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    height: 1.35,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_questionAnswered && answeredCorrectly && isCorrect)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              if (_questionAnswered && isSelected && !isCorrect)
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_questionAnswered) ...[
                    const SizedBox(height: 5),
                    if (_selectedOption == q.correctIndex) ...[
                      // Correct answer feedback
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.chipGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '💡 ${q.explanation}\n🌿 ${q.iksNote}',
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            color: const Color(0xFF245C3D),
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryCta(
                        label: _completedQuestionIds.length >= 4
                            ? 'Finish & see my rewards'
                            : 'Keep watching',
                        icon: Icons.play_arrow_rounded,
                        height: 50,
                        onPressed: _resumeVideo,
                      ),
                    ] else ...[
                      // Incorrect answer: Pedagogical encouragement & Rewind CTA
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.replay_rounded,
                                    color: AppColors.danger,
                                    size: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Not quite! Let's re-watch 🎬",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFA13E3E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Don't worry! Let's start the video again from this scene so you can hear the story clue and try again.",
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: const Color(0xFF7A3333),
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF3C7C7),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🗣️', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      'Story Sentence: "${q.sentenceSnippet}"',
                                      style: GoogleFonts.nunito(
                                        fontSize: 10.5,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF4A2B2B),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryCta(
                        label: 'Re-watch from this sentence ↺',
                        icon: Icons.replay_rounded,
                        height: 50,
                        onPressed: () => _rewindToSentence(q),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedOption = null;
                              _questionAnswered = false;
                            });
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 15,
                            color: AppColors.headerPrimary,
                          ),
                          label: Text(
                            'Try another answer now',
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.headerPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
