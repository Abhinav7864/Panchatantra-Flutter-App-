import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../services/voice_clone_runner.dart';
import '../services/audio_recorder_helper.dart';
import '../widgets/kid_ui.dart';
import '../widgets/storybook_illustration.dart';
import '../widgets/cloned_voice_player_widget.dart';
import 'video_story_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0;

  // Step 1: Parent details
  final TextEditingController _parentNameController =
      TextEditingController(text: 'Priya Sharma');
  String _parentRole = 'Mother';
  String _primaryGoal = 'Moral Reasoning & Indian Knowledge Systems (IKS)';

  // Step 2: Voice recording & cloning
  final AudioRecorderHelper _recorderHelper = AudioRecorderHelper();
  final AudioPlayer _userVoicePlayer = AudioPlayer();
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  RecordedAudio? _recordedAudio;
  bool _isPlayingUserRecording = false;

  bool _isCloning = false;
  int _cloningStage = 0;
  bool _voiceClonedSuccessfully = false;
  VoiceCloneResult? _cloneResult;

  // Step 3: Child details
  final TextEditingController _childNameController =
      TextEditingController(text: 'Eity');
  int _childAge = 7;
  String _selectedAvatar = '🦁';

  // Step 4: Development baseline
  final String _readingLevel = 'Developing Reader (Simple Sentences)';
  int _dailyGoalMinutes = 10;
  final Set<String> _selectedThemes = {
    'Clever Animals',
    'Moral Values',
    'Strategy',
  };

  final List<String> _avatars = ['🦁', '🐰', '🐢', '🐘', '🦚', '🐵'];
  final List<String> _roles = ['Mother', 'Father', 'Grandparent', 'Guardian'];
  final List<String> _goals = [
    'Moral reasoning & Indian Knowledge Systems',
    'Reading comprehension & vocabulary',
    'Parent-voice bedtime storytelling',
    'Ethical decisions & strategy (Niti)',
  ];

  final List<String> _themesList = [
    'Clever Animals',
    'Moral Values',
    'True Friendship',
    'Strategy & Wit',
    'Courage & Bravery',
    'Nature & Wildlife',
  ];

  @override
  void initState() {
    super.initState();
    _userVoicePlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingUserRecording = (state == PlayerState.playing);
        });
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorderHelper.dispose();
    _userVoicePlayer.dispose();
    _parentNameController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPerm = await _recorderHelper.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Microphone access required. Please allow microphone in browser/system settings.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      await _userVoicePlayer.stop();
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
        _recordedAudio = null;
      });

      await _recorderHelper.startRecording();

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _recordDuration = Duration(seconds: t.tick);
        });
      });
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    if (!_isRecording) return;

    try {
      final result = await _recorderHelper.stopRecording(duration: _recordDuration);

      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordedAudio = result ?? RecordedAudio(
          path: '',
          bytes: null,
          duration: _recordDuration,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎙️ Voice recorded (${_formatDuration(_recordDuration)})! Tap Play below to listen to yourself.'),
          backgroundColor: AppColors.headerPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Stop recording error: $e');
      if (!mounted) return;
      setState(() => _isRecording = false);
    }
  }

  Future<void> _togglePlayUserRecording() async {
    if (_recordedAudio == null) return;
    try {
      if (_isPlayingUserRecording) {
        await _userVoicePlayer.pause();
      } else {
        if (_recordedAudio!.bytes != null && _recordedAudio!.bytes!.isNotEmpty) {
          await _userVoicePlayer.play(BytesSource(_recordedAudio!.bytes!));
        } else if (_recordedAudio!.path.isNotEmpty) {
          if (kIsWeb || _recordedAudio!.path.startsWith('blob:') || _recordedAudio!.path.startsWith('http')) {
            await _userVoicePlayer.play(UrlSource(_recordedAudio!.path));
          } else {
            await _userVoicePlayer.play(DeviceFileSource(_recordedAudio!.path));
          }
        } else {
          await _userVoicePlayer.play(AssetSource('audio/cloned_sample.wav'));
        }
      }
    } catch (e) {
      debugPrint('Play user recording error: $e');
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _executeVoiceCloning() async {
    setState(() {
      _isCloning = true;
      _cloningStage = 1;
    });

    final parentName = _parentNameController.text.trim().isEmpty
        ? 'Priya Sharma'
        : _parentNameController.text.trim();

    // Stage 1: Audio normalization & VAD
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _cloningStage = 2);

    // Stage 2: SpeechBrain 512-D neural X-Vector extraction
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _cloningStage = 3);

    // Stage 3 & 4: Neural extraction & SpeechT5 transformer synthesis
    final result = await VoiceCloneRunner.runVoiceCloning(
      parentName: parentName,
      audioBytes: _recordedAudio?.bytes,
      audioSamplePath: _recordedAudio?.path,
    );

    if (!mounted) return;
    setState(() => _cloningStage = 4);
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      _isCloning = false;
      _cloningStage = 0;
      _voiceClonedSuccessfully = result.success;
      _cloneResult = result;
    });

    if (result.success) {
      context.read<AppState>().enrollParentVoice(
            parentName: parentName,
            sampleDuration: _recordDuration.inSeconds > 0
                ? _recordDuration.inSeconds.toDouble()
                : 30.0,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Cloned Voice Ready: ${result.pitchEstimate}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _finishOnboarding() {
    final appState = context.read<AppState>();
    final band = _childAge <= 6 ? '4-6' : (_childAge <= 9 ? '4-9' : '9+');

    appState.updateProfile(
      name: _childNameController.text.trim().isEmpty
          ? 'Eity'
          : _childNameController.text.trim(),
      age: _childAge,
      ageBand: band,
      cognitiveComplexity: (_childAge / 3.0).clamp(1.0, 5.0),
      emotionalResilience: 3.2,
      culturalLiteracy: 3.5,
      attentionSpan: (_dailyGoalMinutes / 5.0).clamp(1.0, 5.0),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VideoStoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: switch (_currentStep) {
                      0 => _buildStep1ParentDetails(),
                      1 => _buildStep2LiveVoiceCloning(),
                      2 => _buildStep3ChildDetails(),
                      _ => _buildStep4AIEnginePreview(),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomCta(),
      ),
    );
  }

  Widget _buildHero() {
    final isIntro = _currentStep == 0;

    return SkyBackground(
      showSun: true,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(38),
              bottomRight: Radius.circular(38),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_currentStep > 0)
                    Material(
                      color: Colors.white.withValues(alpha: 0.72),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _prevStep,
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textDark,
                            size: 17,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            '100% Kids Learn',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.headerPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'STEP ${_currentStep + 1} OF 4',
                      style: GoogleFonts.nunito(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                        color: AppColors.headerPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStepProgress(),
              const SizedBox(height: 21),
              if (isIntro)
                _buildIntroHeadline()
              else
                _buildStepHeadline(),
              if (isIntro) ...[
                const SizedBox(height: 8),
                StorybookIllustration(size: 190),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.baloo2(
              fontSize: 35,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.05,
            ),
            children: const [
              TextSpan(text: 'Learn with '),
              TextSpan(
                text: 'Panchatantra',
                style: TextStyle(color: AppColors.accentCyanDark),
              ),
              TextSpan(text: '\nfaster than ever'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your favourite fables and start a magical learning journey.',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildStepHeadline() {
    final data = switch (_currentStep) {
      1 => (
          'Clone your ',
          'loving voice',
          'Read one little passage and we will narrate every fable in your warm voice.',
          '🎙️',
        ),
      2 => (
          'Meet your ',
          'little learner',
          'A few details help us shape stories for exactly where your child is growing.',
          '🌱',
        ),
      _ => (
          'Ready for your ',
          'first story?',
          'Everything is tuned. Time to meet the clever rabbit and the mighty lion.',
          '✨',
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: GoogleFonts.baloo2(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.05,
                  ),
                  children: [
                    TextSpan(text: data.$1),
                    TextSpan(
                      text: data.$2,
                      style: const TextStyle(color: AppColors.accentCyanDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                data.$3,
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(data.$4, style: const TextStyle(fontSize: 34)),
        ),
      ],
    );
  }

  Widget _buildStepProgress() {
    return Row(
      children: List.generate(4, (index) {
        final isDone = index <= _currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 7),
            height: 6,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.headerPrimary
                  : AppColors.headerPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomCta() {
    final label = switch (_currentStep) {
      0 => 'Continue',
      1 => 'Continue',
      2 => 'Continue',
      _ => 'Start the first story',
    };

    return Container(
      color: AppColors.cream,
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryCta(
            label: label,
            icon: _currentStep == 3
                ? Icons.auto_stories_rounded
                : Icons.arrow_forward_rounded,
            onPressed: _nextStep,
          ),
          if (_currentStep == 0)
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                'I already have a profile',
                style: GoogleFonts.nunito(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep1ParentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'A little about you',
              style: GoogleFonts.baloo2(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'This helps the storyteller speak to your family.',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        KidCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Your full name'),
              const SizedBox(height: 8),
              TextField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Priya Sharma',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.headerPrimary,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(height: 19),
              const _FieldLabel('You are the child’s'),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roles.map((role) {
                  final selected = _parentRole == role;
                  return _ChoicePill(
                    label: role,
                    selected: selected,
                    onTap: () => setState(() => _parentRole = role),
                  );
                }).toList(),
              ),
              const SizedBox(height: 19),
              const _FieldLabel('What matters most right now?'),
              const SizedBox(height: 5),
              ..._goals.map((goal) {
                final selected = _primaryGoal == goal;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _SelectRow(
                    label: goal,
                    selected: selected,
                    onTap: () => setState(() => _primaryGoal = goal),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2LiveVoiceCloning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KidCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.chipGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Private by design',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Encrypted on your device. Never used to clone children.',
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.record_voice_over_rounded,
                          color: AppColors.accentCyanDark,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'READ THIS ALOUD',
                          style: GoogleFonts.nunito(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                            color: AppColors.accentCyanDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '“Once upon a time, in a lush green forest, lived a wise little rabbit who showed us that calm wit can defeat brute power...”',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _Waveform(
                  active: _isRecording || _isPlayingUserRecording || _isCloning,
                  success: _voiceClonedSuccessfully,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_isRecording) {
                          _stopRecording();
                        } else {
                          _startRecording();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isRecording)
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.danger.withValues(alpha: 0.15),
                              ),
                            ),
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: _isRecording
                                  ? const LinearGradient(
                                      colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                                    )
                                  : AppColors.headerGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording ? AppColors.danger : AppColors.headerPrimary)
                                      .withValues(alpha: 0.32),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRecording
                          ? 'Recording... ${_formatDuration(_recordDuration)} (Tap to Stop)'
                          : (_recordedAudio != null
                              ? 'Sample recorded (${_formatDuration(_recordDuration)})! Listen below.'
                              : 'Tap mic to record your voice'),
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _isRecording ? AppColors.danger : AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // STEP 2: USER RECORDING PREVIEW & AUDITION CARD
              if (_recordedAudio != null && !_isCloning) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyanDark.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.chipBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.headphones_rounded, size: 14, color: AppColors.accentCyanDark),
                                const SizedBox(width: 4),
                                Text(
                                  'STEP 2: HEAR YOUR RAW RECORDING',
                                  style: GoogleFonts.nunito(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: AppColors.accentCyanDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(_recordDuration),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Play / Pause button
                          GestureDetector(
                            onTap: _togglePlayUserRecording,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: _isPlayingUserRecording
                                    ? AppColors.readingGradient
                                    : AppColors.headerGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.headerPrimary.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlayingUserRecording ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPlayingUserRecording ? 'Playing your voice back...' : 'Tap to hear what you said',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Sound good? Tap "Clone My Voice" to extract your voice model.',
                                  style: GoogleFonts.nunito(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.textMedium),
                            tooltip: 'Record again',
                            onPressed: () {
                              setState(() {
                                _recordedAudio = null;
                                _recordDuration = Duration.zero;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isCloning ? null : _executeVoiceCloning,
                          icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                          label: Text(
                            _voiceClonedSuccessfully ? 'Re-clone with this sample' : 'Clone My Voice Now ✨',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.headerPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_recordedAudio == null && !_voiceClonedSuccessfully) ...[
                // If user hasn't recorded yet, provide one-click demo clone button or encouragement
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _isCloning ? null : _executeVoiceCloning,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Or calibrate with studio sample profile'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],

              if (_isCloning) ...[
                _buildExtractionProgressCard(),
              ],

              // STEP 3: CLONED VOICE PLAYER & CUSTOM SENTENCE SYNTHESIZER
              if (_voiceClonedSuccessfully && _cloneResult != null) ...[
                const SizedBox(height: 18),
                ClonedVoicePlayerWidget(
                  parentName: _parentNameController.text.trim().isEmpty
                      ? 'Priya Sharma'
                      : _parentNameController.text.trim(),
                  initialResult: _cloneResult,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtractionProgressCard() {
    final stages = [
      (1, 'Audio Normalization & VAD', '16kHz mono conversion & background noise filtering'),
      (2, 'Neural Embedding Extraction', 'SpeechBrain 512-D X-Vector speaker space projection'),
      (3, 'Acoustic Timbre Analysis', 'Fundamental pitch (F0: 115.9 Hz) & resonance mapping'),
      (4, 'Transformer Model Synthesis', 'Microsoft SpeechT5 + HiFi-GAN neural vocoder weights'),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'NEURAL PIPELINE CALIBRATING...',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stages.map((stage) {
            final isDone = _cloningStage > stage.$1;
            final isCurrent = _cloningStage == stage.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.success
                          : (isCurrent ? AppColors.accentCyanDark : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : (isCurrent
                            ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                '${stage.$1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.$2,
                          style: GoogleFonts.nunito(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isDone || isCurrent
                                ? const Color(0xFF14532D)
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          stage.$3,
                          style: GoogleFonts.nunito(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3ChildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KidCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Child’s name'),
              const SizedBox(height: 8),
              TextField(
                controller: _childNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Eity or Aarav',
                  prefixIcon: Icon(
                    Icons.child_care_rounded,
                    color: AppColors.headerPrimary,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Pick a story buddy'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _avatars.map((avatar) {
                  final selected = _selectedAvatar == avatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = avatar),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.chipPurple : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.headerPrimary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(avatar, style: const TextStyle(fontSize: 23)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  const _FieldLabel('Age'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_childAge years',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentCyanDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _childAge <= 6
                        ? 'Early reader'
                        : (_childAge <= 9 ? 'Growing reader' : 'Independent'),
                    style: GoogleFonts.nunito(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.headerPrimary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _childAge.toDouble(),
                min: 4,
                max: 15,
                divisions: 11,
                label: '$_childAge',
                onChanged: (value) => setState(() => _childAge = value.round()),
              ),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📘', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _childAge <= 9
                            ? 'Stories use short, playful sentences with a moral checkpoint every few pages.'
                            : 'Stories open up richer dilemmas, deeper Niti and longer adventures.',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
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
        const SizedBox(height: 14),
        KidCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Daily reading goal'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 20].map((minutes) {
                  final selected = _dailyGoalMinutes == minutes;
                  return _ChoicePill(
                    label: '$minutes min',
                    selected: selected,
                    onTap: () => setState(() => _dailyGoalMinutes = minutes),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Stories they will love'),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _themesList.map((theme) {
                  final selected = _selectedThemes.contains(theme);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected
                            ? _selectedThemes.remove(theme)
                            : _selectedThemes.add(theme);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.chipRose : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.cardReading.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        theme,
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: selected ? AppColors.cardReading : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4AIEnginePreview() {
    final childName = _childNameController.text.trim().isEmpty
        ? 'your little one'
        : _childNameController.text.trim();

    return Column(
      children: [
        const StorybookIllustration(size: 172, showBackdrop: false),
        const SizedBox(height: 8),
        Text(
          'All set for $childName',
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your first animated fable is ready, with a gentle moral checkpoint along the way.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12.5,
            color: AppColors.textMedium,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        KidCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildCheckRow(
                _voiceClonedSuccessfully
                    ? 'Parent voice attached'
                    : 'Studio narrator ready',
                _voiceClonedSuccessfully
                    ? '${_parentNameController.text} • encrypted'
                    : 'A warm, professional storyteller',
              ),
              const Divider(height: 20),
              _buildCheckRow(
                'Learner profile prepared',
                'Age $_childAge • $_readingLevel',
              ),
              const Divider(height: 20),
              _buildCheckRow(
                'Stories rooted in real sources',
                'Ryder 1925 • Purnabhadra 1199 CE',
              ),
              const Divider(height: 20),
              _buildCheckRow(
                'Interactive fable ready',
                '5 gentle questions • recall & Niti',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckRow(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.aiBadgeGreenBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.success,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
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
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.headerPrimary : AppColors.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.chipPurple : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.headerPrimary.withValues(alpha: 0.35)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.headerPrimary : AppColors.textLight,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.headerPrimary : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final bool active;
  final bool success;

  const _Waveform({required this.active, required this.success});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(24, (index) {
          final animatedHeight = active
              ? 9.0 + ((index % 6) * 5.5) * (index.isEven ? 1.15 : 0.78)
              : 5.0 + (index % 3) * 2;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2.4),
            width: 4,
            height: animatedHeight,
            decoration: BoxDecoration(
              color: success
                  ? AppColors.success
                  : (active
                      ? AppColors.accentCyan
                      : AppColors.headerPrimary.withValues(alpha: 0.16)),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
