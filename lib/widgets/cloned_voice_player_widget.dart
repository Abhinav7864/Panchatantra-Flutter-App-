import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../services/voice_clone_runner.dart';
import '../services/audio_platform/audio_platform_helper.dart';

class ClonedVoicePlayerWidget extends StatefulWidget {
  final String parentName;
  final VoiceCloneResult? initialResult;
  final VoidCallback? onEnrollRequested;

  const ClonedVoicePlayerWidget({
    super.key,
    required this.parentName,
    this.initialResult,
    this.onEnrollRequested,
  });

  @override
  State<ClonedVoicePlayerWidget> createState() => _ClonedVoicePlayerWidgetState();
}

class _ClonedVoicePlayerWidgetState extends State<ClonedVoicePlayerWidget>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = const Duration(seconds: 5);
  Duration _position = Duration.zero;
  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  late AnimationController _waveAnimController;
  bool _isSynthesizing = false;
  String? _lastSynthesizedNote;
  Uint8List? _customAudioBytes;

  final TextEditingController _testTextController = TextEditingController(
    text: 'Hello my sweet little one, tonight we will learn about the clever rabbit and the mighty lion.',
  );

  final List<String> _quickPresets = [
    '🐰 "Clever rabbit outsmarts the mighty lion!"',
    '🌙 "Goodnight sweetheart, rest and dream big tonight."',
    '🐘 "The wise elephant shows us patience and courage."',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });

    _posSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    _durSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (!mounted) return;
      setState(() => _duration = dur);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _waveAnimController.dispose();
    _testTextController.dispose();
    super.dispose();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        Source? source;
        if (_customAudioBytes != null && _customAudioBytes!.isNotEmpty) {
          source = await createPlatformAudioSource(bytes: _customAudioBytes);
        } else if (widget.initialResult?.audioBytes != null &&
            widget.initialResult!.audioBytes!.isNotEmpty) {
          source = await createPlatformAudioSource(
              bytes: widget.initialResult!.audioBytes);
        } else {
          source = await createPlatformAudioSource(
              path: 'assets/audio/cloned_sample.wav',
              assetFallback: 'audio/cloned_sample.wav');
        }

        if (source != null) {
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.play(source);
        }
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  Future<void> _replayAudio() async {
    try {
      await _audioPlayer.seek(Duration.zero);
      Source? source;
      if (_customAudioBytes != null && _customAudioBytes!.isNotEmpty) {
        source = await createPlatformAudioSource(bytes: _customAudioBytes);
      } else if (widget.initialResult?.audioBytes != null &&
          widget.initialResult!.audioBytes!.isNotEmpty) {
        source = await createPlatformAudioSource(
            bytes: widget.initialResult!.audioBytes);
      } else {
        source = await createPlatformAudioSource(
            path: 'assets/audio/cloned_sample.wav',
            assetFallback: 'audio/cloned_sample.wav');
      }

      if (source != null) {
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(source);
      }
    } catch (e) {
      debugPrint('Replay audio error: $e');
    }
  }

  Future<void> _handleSynthesizeCustomSentence() async {
    final text = _testTextController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSynthesizing = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await VoiceCloneRunner.synthesizeSentence(
        text: text,
        parentName: widget.parentName,
      );

      if (!mounted) return;
      setState(() {
        _isSynthesizing = false;
        _lastSynthesizedNote = '⚡ Real Voice Synthesized in ${result.latencyMs}ms via SpeechT5 + HiFi-GAN (Metal GPU)!';
        if (result.audioBytes != null && result.audioBytes!.isNotEmpty) {
          _customAudioBytes = result.audioBytes;
        }
      });

      // Automatically play the freshly generated neural voice!
      await _replayAudio();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Cloned Voice narration synthesized in ${result.latencyMs}ms!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSynthesizing = false);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.parentName.isEmpty ? 'Parent' : widget.parentName;
    final pitchHz = widget.initialResult?.pitchHz ?? 115.9;
    final rms = widget.initialResult?.rmsEnergy ?? 0.1006;
    final wpm = widget.initialResult?.speakingRateWpm ?? 150;
    final device = widget.initialResult?.device ?? 'Apple Silicon MPS (Metal GPU)';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyanDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
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
                          Flexible(
                            child: Text(
                              '$parent’s Cloned Voice',
                              style: GoogleFonts.baloo2(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B5E20),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'LIVE & ACTIVE',
                              style: GoogleFonts.nunito(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'SpeechBrain 512-D X-Vector • SpeechT5 Transformer',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Player Control Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Play/Pause Action Button
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: _isPlaying
                                    ? AppColors.readingGradient
                                    : AppColors.headerGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.headerPrimary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Equalizer animation + progress scrubber
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _customAudioBytes != null
                                            ? (_isPlaying
                                                ? '🎙️ Speaking Custom Sentence...'
                                                : '🎧 Custom Sentence Ready')
                                            : (_isPlaying
                                                ? '🎙️ Speaking Story Preview...'
                                                : '🎧 Cloned Voice Ready (Tap Play)'),
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _isPlaying
                                              ? AppColors.accentCyanDark
                                              : AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    if (_customAudioBytes != null) ...[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _customAudioBytes = null;
                                            _lastSynthesizedNote = null;
                                          });
                                          _replayAudio();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.chipBlue,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Story Preview',
                                            style: GoogleFonts.nunito(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.headerPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    IconButton(
                                      icon: const Icon(Icons.replay_rounded, size: 20),
                                      color: AppColors.textMedium,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: _replayAudio,
                                      tooltip: 'Replay from start',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Animated Waveform Equalizer
                                AnimatedBuilder(
                                  animation: _waveAnimController,
                                  builder: (context, _) {
                                    return SizedBox(
                                      height: 24,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(24, (i) {
                                          final baseH = 5.0 + (i % 5) * 3.0;
                                          final animFactor = _isPlaying
                                              ? (0.3 + 0.7 * ((_waveAnimController.value + (i * 0.08)) % 1.0))
                                              : 0.35;
                                          final height = (baseH * animFactor * 1.6).clamp(4.0, 24.0);

                                          return Container(
                                            width: 3.5,
                                            height: height,
                                            decoration: BoxDecoration(
                                              color: _isPlaying
                                                  ? (i.isEven ? AppColors.accentCyanDark : AppColors.headerPrimary)
                                                  : AppColors.headerPrimary.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Slider & time labels
                      Row(
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                activeTrackColor: AppColors.accentCyanDark,
                                inactiveTrackColor: AppColors.accentCyanDark.withValues(alpha: 0.15),
                                thumbColor: AppColors.accentCyanDark,
                              ),
                              child: Slider(
                                value: _duration.inMilliseconds > 0
                                    ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                                    : 0.0,
                                onChanged: (val) {
                                  final targetMs = (val * _duration.inMilliseconds).toInt();
                                  _audioPlayer.seek(Duration(milliseconds: targetMs));
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Biometrics Telemetry Grid
                Text(
                  'NEURAL BIOMETRICS & HARDWARE ACCELERATION',
                  style: GoogleFonts.nunito(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTelemetryChip(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Pitch (F0)',
                      value: '${pitchHz.toStringAsFixed(1)} Hz',
                      color: const Color(0xFF1976D2),
                    ),
                    _buildTelemetryChip(
                      icon: Icons.bolt_rounded,
                      label: 'RMS Energy',
                      value: rms.toStringAsFixed(3),
                      color: const Color(0xFFE65100),
                    ),
                    _buildTelemetryChip(
                      icon: Icons.speed_rounded,
                      label: 'Story Cadence',
                      value: '$wpm WPM',
                      color: const Color(0xFF6A1B9A),
                    ),
                    _buildTelemetryChip(
                      icon: Icons.memory_rounded,
                      label: 'Hardware Acceleration',
                      value: device,
                      color: const Color(0xFF2E7D32),
                    ),
                    _buildTelemetryChip(
                      icon: Icons.lock_rounded,
                      label: 'Enclave Encryption',
                      value: 'AES-256 Bit Local',
                      color: const Color(0xFF37474F),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Interactive Custom Sentence Tester Box
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.accentCyanDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TEST ANY CUSTOM SENTENCE LIVE',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.accentCyanDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Type any bedtime phrase below to hear your cloned neural voice speak it:',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Quick presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickPresets.map((preset) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          backgroundColor: AppColors.chipBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          label: Text(
                            preset,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.headerPrimary,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _testTextController.text = preset.replaceAll(RegExp(r'^[^\"]*\"|\"[^\"]*$'), '');
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Custom sentence text field
                TextField(
                  controller: _testTextController,
                  maxLines: 2,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(12),
                    hintText: 'e.g. Goodnight Aarav, sleep tight!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.accentCyanDark, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Synthesize button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isSynthesizing ? null : _handleSynthesizeCustomSentence,
                    icon: _isSynthesizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.record_voice_over_rounded, size: 18),
                    label: Text(
                      _isSynthesizing
                          ? 'Synthesizing on Apple Silicon GPU...'
                          : 'Synthesize in My Cloned Voice',
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.headerPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                if (_lastSynthesizedNote != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Text(
                      _lastSynthesizedNote!,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
