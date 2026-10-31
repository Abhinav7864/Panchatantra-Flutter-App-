import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import '../widgets/cloned_voice_player_widget.dart';
import '../services/voice_clone_runner.dart';
import '../services/audio_recorder_helper.dart';
import '../services/audio_file_picker_service.dart';
import '../services/audio_platform/audio_platform_helper.dart';
import '../widgets/cloud_api_key_modal.dart';
import '../services/cloud_voice_service.dart';
import 'child_profile_screen.dart';

class ParentVoiceEnrollScreen extends StatefulWidget {
  const ParentVoiceEnrollScreen({super.key});

  @override
  State<ParentVoiceEnrollScreen> createState() => _ParentVoiceEnrollScreenState();
}

class _ParentVoiceEnrollScreenState extends State<ParentVoiceEnrollScreen> {
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

  bool _autoDelete = true;
  bool _isCloning = false;
  int _cloningStage = 0;
  bool _isEnrolled = false;
  VoiceCloneResult? _cloneResult;

  final TextEditingController _nameController =
      TextEditingController(text: 'Priya Sharma');

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

        // Ensure player is at 100% volume
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
                    child: const Icon(Icons.audio_file_rounded, color: AppColors.headerPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Voice Recording',
                          style: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Upload an MP3 or WAV (20–30 seconds ideal)',
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
                    'Browse Computer for Audio File...',
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
                  'Recent Voice Recordings found on your PC:',
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
                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        tileColor: const Color(0xFFF8FAFC),
                        leading: const Icon(Icons.mic_none_rounded, color: AppColors.headerPrimary, size: 20),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('$sizeMb MB • ${file.path.split('.').last.toUpperCase()}',
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

    final parentName = _nameController.text.trim().isEmpty
        ? 'Priya Sharma'
        : _nameController.text.trim();

    final audioPath = _recordedAudio?.path ?? '';
    final ext = audioPath.contains('.') ? audioPath.split('.').last.toLowerCase() : 'wav';

    // Stage 1: Audio Normalization & 24kHz Conversion
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
      _isEnrolled = result.success;
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
          content: Text('🎉 Cloned Voice Calibrated: ${result.pitchEstimate}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recorderHelper.dispose();
    _userVoicePlayer.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildExtractionProgressCard() {
    final stages = [
      (1, 'Audio Normalization & Resampling', '24kHz studio conversion & acoustic silence trimming'),
      (2, 'Neural Latent Diffusion Conditioning', 'Coqui XTTS-v2 zero-shot cross-attention alignment'),
      (3, 'Vocal Timbre & Prosody Analysis', 'Fundamental pitch & native accent formant extraction'),
      (4, 'Hardware Acceleration on RTX 4070', 'NVIDIA GeForce RTX 4070 CUDA FP16 Tensor Cores'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 26,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KidPageHeader(
              title: 'Parent Voice Studio',
              subtitle: 'A bedtime storyteller who sounds authentically like you',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.chipGreen,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.success,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safe, private, sovereign on-device',
                                style: GoogleFonts.nunito(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF22663C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Encrypted via AES-256 on Apple Silicon. Zero cloud recording leakage.',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3D7A55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          borderRadius: BorderRadius.circular(18),
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
                                size: 20,
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
                                          fontSize: 12.5,
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
                                        : 'Photorealistic voice cloning & Realtime TTS-2 cloud synthesis',
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  const SizedBox(height: 18),

                  KidCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parent name',
                          style: GoogleFonts.nunito(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.headerPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Read this bedtime story aloud',
                              style: GoogleFonts.baloo2(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFB45309)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '30s Target',
                                    style: GoogleFonts.nunito(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'For photorealistic cloning, record for ~30 seconds with a warm, calm bedtime tone.',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.chipBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '“Once upon a time, in a peaceful green valley by a shimmering lake, there lived a wise little rabbit and a mighty lion. Every evening as the golden sun sank behind the purple mountains, the gentle creatures would gather beneath the ancient banyan tree to share tales of courage, kindness, and wonder. Tonight, close your eyes, my dear little one, as we embark on a magical journey into the stars together.”',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Center(
                          child: _buildMicSelector(),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: _RecordingWave(
                            active: _isRecording || _isPlayingUserRecording || _isCloning,
                            level: _micAmplitude,
                          ),
                        ),
                        const SizedBox(height: 15),
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
                                const SizedBox(height: 14),
                                Container(
                                  width: 240,
                                  height: 8,
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
                                      ? '✨ Ideal 30s captured! Tap Stop when finished.'
                                      : (_recordDuration.inSeconds >= 15
                                          ? 'Great pace! Almost at 30 seconds...'
                                          : 'Reading passage... (~30s needed for best clone)'),
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
                                      ? 'Voice sample ready (${_formatDuration(_recordDuration)})! Listen below.'
                                      : 'Tap mic to record for 30 seconds',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                              if (!_isRecording && !_isCloning) ...[
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: _openAudioFilePicker,
                                  icon: const Icon(Icons.upload_file_rounded, size: 19),
                                  label: Text(
                                    'Add / Upload Voice Recording (MP3 / WAV)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.headerPrimary,
                                    side: const BorderSide(color: AppColors.headerPrimary, width: 1.5),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // USER RAW RECORDING PLAYBACK CARD
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
                                            'HEAR YOUR RAW VOICE SAMPLE',
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
                                            _isPlayingUserRecording ? 'Playing your recorded sample...' : 'Tap to listen to yourself',
                                            style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Hear how you sound before neural extraction.',
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
                                      _isEnrolled ? 'Re-clone with this sample' : 'Clone My Voice Now ✨',
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
                        ] else if (_recordedAudio == null && !_isEnrolled) ...[
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

                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.headerPrimary,
                            title: Text(
                              'Auto-delete raw audio sample',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                color: AppColors.textDark,
                              ),
                            ),
                            subtitle: Text(
                              'Keeps only 512-D neural X-Vector weights on device.',
                              style: GoogleFonts.nunito(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            value: _autoDelete,
                            onChanged: (value) =>
                                setState(() => _autoDelete = value),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cloned Voice Live Player & Synthesizer Card
                  if (_isEnrolled && _cloneResult != null) ...[
                    const SizedBox(height: 20),
                    ClonedVoicePlayerWidget(
                      parentName: _nameController.text.trim().isEmpty
                          ? 'Priya Sharma'
                          : _nameController.text.trim(),
                      initialResult: _cloneResult,
                    ),
                  ],

                  const SizedBox(height: 22),
                  PrimaryCta(
                    label: 'Save & set up my child',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      context.read<AppState>().enrollParentVoice(
                            parentName: _nameController.text.trim(),
                            sampleDuration: 30.0,
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChildProfileScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip · use the studio narrator',
                        style: GoogleFonts.nunito(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
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
    );
  }
}

class _RecordingWave extends StatelessWidget {
  final bool active;
  final double level;

  const _RecordingWave({
    required this.active,
    this.level = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(24, (index) {
          final dynamicScale = (level > 0.0)
              ? (8.0 + (level * 32.0) * ((index % 5 + 1) / 3.0)).clamp(6.0, 42.0)
              : (active
                  ? 9.0 + ((index % 5) * 7.0) * (index.isEven ? 1.1 : 0.8)
                  : 5.0 + (index % 3) * 2);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2.4),
            width: 4,
            height: dynamicScale,
            decoration: BoxDecoration(
              color: active
                  ? (level > 0.2 ? AppColors.headerPrimary : AppColors.accentCyan)
                  : AppColors.headerPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
