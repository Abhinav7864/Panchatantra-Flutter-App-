import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../services/voice_clone_runner.dart';
import '../services/audio_recorder_helper.dart';
import '../services/audio_file_picker_service.dart';
import '../services/audio_platform/audio_platform_helper.dart';
import '../widgets/kid_ui.dart';
import '../widgets/storybook_illustration.dart';
import '../widgets/cloned_voice_player_widget.dart';
import '../widgets/cloud_api_key_modal.dart';
import '../services/cloud_voice_service.dart';
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
  Timer? _amplitudeTimer;
  double _micAmplitude = 0.0;
  RecordedAudio? _recordedAudio;
  bool _isPlayingUserRecording = false;

  List<InputDevice> _availableDevices = [];
  InputDevice? _selectedDevice;

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
    _loadInputDevices();
    _userVoicePlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingUserRecording = (state == PlayerState.playing);
        });
      }
    });
  }

  Future<void> _loadInputDevices() async {
    final devices = await _recorderHelper.listInputDevices();
    final preferred = await _recorderHelper.getDefaultPreferredInputDevice();
    if (mounted) {
      setState(() {
        _availableDevices = devices;
        _selectedDevice = preferred ?? (devices.isNotEmpty ? devices.first : null);
      });
    }
  }

  Widget _buildMicSelector() {
    if (_availableDevices.isEmpty && _selectedDevice == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyanDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_rounded, size: 17, color: AppColors.headerPrimary),
          const SizedBox(width: 7),
          Text(
            'Microphone:',
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(width: 6),
          if (_availableDevices.length <= 1)
            Text(
              _selectedDevice?.label ?? 'MacBook Air Microphone',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton<InputDevice>(
                value: _selectedDevice,
                isDense: true,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20, color: AppColors.headerPrimary),
                items: _availableDevices.map((dev) {
                  final isBuiltIn = dev.label.toLowerCase().contains('macbook') ||
                      dev.label.toLowerCase().contains('built-in') ||
                      dev.label.toLowerCase().contains('builtin');
                  return DropdownMenuItem<InputDevice>(
                    value: dev,
                    child: Text(
                      isBuiltIn ? '${dev.label} (Recommended)' : dev.label,
                    ),
                  );
                }).toList(),
                onChanged: (newDev) {
                  if (newDev != null) {
                    setState(() => _selectedDevice = newDev);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _amplitudeTimer?.cancel();
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
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.mic_off_rounded, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Text('Microphone Access Needed', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                ],
              ),
              content: Text(
                'Panchatantra needs permission to use your MacBook microphone to capture your storytelling voice.\n\nPlease enable Microphone in:\nSystem Settings > Privacy & Security > Microphone.',
                style: GoogleFonts.nunito(fontSize: 13, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      await _userVoicePlayer.stop();
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
        _micAmplitude = 0.05;
        _recordedAudio = null;
      });

      await _recorderHelper.startRecording(device: _selectedDevice);

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _recordDuration = Duration(seconds: t.tick);
        });
      });

      _amplitudeTimer?.cancel();
      _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
        if (!mounted || !_isRecording) return;
        try {
          final amp = await _recorderHelper.getAmplitude();
          final normalized = ((amp.current + 55.0) / 55.0).clamp(0.08, 1.0);
          setState(() {
            _micAmplitude = normalized;
          });
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Start recording error: $e');
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Could not start recording: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    _amplitudeTimer?.cancel();
    if (!_isRecording) return;

    try {
      final result = await _recorderHelper.stopRecording(duration: _recordDuration);

      if (!mounted) return;
      final hasAudio = result != null && result.hasValidAudio;

      setState(() {
        _isRecording = false;
        _micAmplitude = 0.0;
        _recordedAudio = result;
      });

      if (hasAudio) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎙️ Voice recorded (${_formatDuration(_recordDuration)}, peak: ${(result.peakAmplitude * 100).toInt()}%) via ${_selectedDevice?.label ?? "Microphone"}! Tap Play to listen.'),
            backgroundColor: AppColors.headerPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result != null && result.isSilent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Near-zero sound picked up by "${result.inputDeviceName ?? "Microphone"}". If earphones are plugged in, switch microphone above to "MacBook Air Microphone" and speak clearly.'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Microphone captured no audio bytes. Ensure your MacBook mic is enabled in System Settings > Privacy.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Stop recording error: $e');
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _micAmplitude = 0.0;
      });
    }
  }

  Future<void> _togglePlayUserRecording() async {
    if (_recordedAudio == null) return;
    try {
      if (_isPlayingUserRecording) {
        await _userVoicePlayer.pause();
      } else {
        if (!_recordedAudio!.hasValidAudio && _recordedAudio!.path.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ No valid audio recorded. Tap the mic to record your voice first!'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Ensure playback volume is 100%
        await _userVoicePlayer.setVolume(1.0);

        final source = await createPlatformAudioSource(
          bytes: _recordedAudio!.bytes,
          path: _recordedAudio!.path,
        );

        if (source != null) {
          await _userVoicePlayer.play(source);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Unable to open recorded audio for playback.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Play user recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Playback error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _openAudioFilePicker() async {
    await _userVoicePlayer.stop();

    // Look for recent recordings in Downloads / Temp
    final recentFiles = await AudioFilePickerService.getRecentAudioRecordings();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(22, 20, 22, MediaQuery.of(ctx).viewInsets.bottom + 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.chipBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.video_collection_rounded, color: AppColors.headerPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Voice or Video Recording',
                          style: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Upload an MP3, WAV, or MP4/MOV video (20–30s ideal)',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final pickedPath = await AudioFilePickerService.pickAudioFile();
                    if (pickedPath != null && mounted) {
                      await _loadSelectedAudio(pickedPath);
                    }
                  },
                  icon: const Icon(Icons.folder_open_rounded, size: 20),
                  label: Text(
                    'Browse Computer for Audio/Video File...',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.headerPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              if (recentFiles.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Recent Voice & Video Recordings found on your PC:',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: recentFiles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final file = recentFiles[i];
                      final name = file.uri.pathSegments.last;
                      final sizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
                      final ext = file.path.split('.').last.toUpperCase();
                      final isVideo = ['MP4', 'MOV', 'MKV', 'WEBM'].contains(ext);
                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        tileColor: const Color(0xFFF8FAFC),
                        leading: Icon(
                          isVideo ? Icons.videocam_rounded : Icons.mic_none_rounded,
                          color: AppColors.headerPrimary,
                          size: 20,
                        ),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('$sizeMb MB • $ext',
                            style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textLight)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.headerPrimary),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _loadSelectedAudio(file.path);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadSelectedAudio(String filePath) async {
    final loaded = await AudioFilePickerService.loadAudioFile(filePath);
    if (!mounted || loaded == null) return;

    setState(() {
      _recordedAudio = loaded;
      _recordDuration = loaded.duration;
      _isRecording = false;
      _micAmplitude = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎙️ Loaded "${loaded.inputDeviceName ?? "Voice Sample"}" (${_formatDuration(loaded.duration)})! Tap Play to listen.'),
        backgroundColor: AppColors.headerPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _executeVoiceCloning() async {
    setState(() {
      _isCloning = true;
      _cloningStage = 1;
    });

    final parentName = _parentNameController.text.trim().isEmpty
        ? 'Priya Sharma'
        : _parentNameController.text.trim();

    final audioPath = _recordedAudio?.path ?? '';
    final ext = audioPath.contains('.') ? audioPath.split('.').last.toLowerCase() : 'wav';

    // Stage 1: Audio normalization & 24kHz Conversion
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _cloningStage = 2);

    // Stage 2: Coqui XTTS-v2 Latent Diffusion Conditioning
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _cloningStage = 3);

    // Stage 3 & 4: Neural extraction & CUDA acceleration
    final result = await VoiceCloneRunner.runVoiceCloning(
      parentName: parentName,
      audioBytes: _recordedAudio?.bytes,
      audioSamplePath: _recordedAudio?.path,
      fileExt: ext,
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
            voiceId: result.voiceId,
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
              const SizedBox(height: 14),
              FutureBuilder<CloudVoiceConfig>(
                future: CloudVoiceService.loadConfig(),
                builder: (context, snapshot) {
                  final config = snapshot.data;
                  final isConnected = config != null && config.isValid && config.isEnabled;
                  final voiceLabel = config?.voiceDisplayName.isNotEmpty == true
                      ? config!.voiceDisplayName
                      : (config?.voiceId.isNotEmpty == true ? config!.voiceId : 'Not connected');

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isConnected
                            ? const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)]
                            : const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isConnected ? AppColors.success : const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isConnected ? Icons.verified_rounded : Icons.cloud_sync_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isConnected ? 'Inworld AI Cloud Mode Active' : 'Use Inworld AI API',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isConnected ? const Color(0xFF14532D) : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isConnected ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isConnected ? 'CONNECTED' : 'API KEY',
                                      style: GoogleFonts.nunito(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                isConnected
                                    ? 'Using: $voiceLabel (Realtime TTS-2)'
                                    : 'Photorealistic voice cloning & Realtime TTS-2 cloud engine',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isConnected ? const Color(0xFF166534) : const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            CloudApiKeyModal.show(context, onConfigSaved: () {
                              setState(() {});
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: isConnected ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 1,
                          ),
                          child: Text(
                            isConnected ? 'Change Key' : 'Enter API Key',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
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
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFB45309)),
                              const SizedBox(width: 4),
                              Text(
                                '30s Target',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '“Once upon a time, in a peaceful green valley by a shimmering lake, there lived a wise little rabbit and a mighty lion. Every evening as the golden sun sank behind the purple mountains, the gentle creatures would gather beneath the ancient banyan tree to share tales of courage, kindness, and wonder. Tonight, close your eyes, my dear little one, as we embark on a magical journey into the stars together.”',
                      style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: _buildMicSelector(),
              ),
              const SizedBox(height: 14),
              Center(
                child: _Waveform(
                  active: _isRecording || _isPlayingUserRecording || _isCloning,
                  success: _voiceClonedSuccessfully,
                  level: _micAmplitude,
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
                    if (_isRecording) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: 230,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_recordDuration.inSeconds / 30.0).clamp(0.0, 1.0),
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              _recordDuration.inSeconds >= 30
                                  ? AppColors.success
                                  : (_recordDuration.inSeconds >= 15
                                      ? AppColors.headerPrimary
                                      : const Color(0xFFF59E0B)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDuration(_recordDuration)} / 00:30 (${((_recordDuration.inSeconds / 30.0) * 100).toInt().clamp(0, 100)}%)',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _recordDuration.inSeconds >= 30
                              ? AppColors.success
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _recordDuration.inSeconds >= 30
                            ? '✨ 30s captured! Tap Stop when done.'
                            : 'Aim for ~30s for the most accurate clone',
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _recordDuration.inSeconds >= 30
                              ? AppColors.success
                              : AppColors.textMedium,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        _recordedAudio != null
                            ? 'Sample recorded (${_formatDuration(_recordDuration)})! Listen below.'
                            : 'Tap mic to record your voice',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                    if (!_isRecording && !_isCloning) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OR',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openAudioFilePicker,
                          icon: const Icon(Icons.video_collection_rounded, size: 19),
                          label: Text(
                            'Add / Upload Voice & Video Recording',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.headerPrimary,
                            side: const BorderSide(color: AppColors.headerPrimary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Upload an MP3, WAV audio or MP4, MOV video recording (20–30s ideal)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.volume_up_rounded, size: 13, color: AppColors.textMedium),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Playing at 100% volume. (Note: Audio routes through headphones if connected)',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_recordedAudio != null && _recordedAudio!.isSilent) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '⚠️ Near-zero sound was captured! If headphones/earphones are plugged into your Mac, please select "MacBook Air Microphone" above and record again.',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
      (1, 'Audio Normalization & 24kHz Conversion', 'High-res audio normalization & noise floor cleaning'),
      (2, 'Neural Latent Conditioning', 'Coqui XTTS-v2 24kHz latent speaker feature projection'),
      (3, 'Multi-Scale Speaker Conditioning', 'Multi-head cross-attention acoustic timbre mapping'),
      (4, 'CUDA Latent Diffusion Engine', 'NVIDIA RTX 4070 GPU ready for real-time storytelling'),
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
  final double level;

  const _Waveform({
    required this.active,
    required this.success,
    this.level = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(24, (index) {
          final dynamicHeight = (level > 0.0)
              ? (8.0 + (level * 32.0) * ((index % 5 + 1) / 3.0)).clamp(6.0, 42.0)
              : (active
                  ? 9.0 + ((index % 6) * 5.5) * (index.isEven ? 1.15 : 0.78)
                  : 5.0 + (index % 3) * 2);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2.4),
            width: 4,
            height: dynamicHeight,
            decoration: BoxDecoration(
              color: success
                  ? AppColors.success
                  : (active
                      ? (level > 0.2 ? AppColors.headerPrimary : AppColors.accentCyan)
                      : AppColors.headerPrimary.withValues(alpha: 0.16)),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
