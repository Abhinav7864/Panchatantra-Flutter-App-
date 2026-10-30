import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'audio_platform/audio_platform_helper.dart';

class RecordedAudio {
  final String path;
  final Uint8List? bytes;
  final Duration duration;

  const RecordedAudio({
    required this.path,
    this.bytes,
    this.duration = Duration.zero,
  });

  bool get hasValidAudio => bytes != null && bytes!.length > 500;
}

class AudioRecorderHelper {
  final AudioRecorder _recorder = AudioRecorder();
  String _currentRecordPath = '';

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('hasPermission error: $e');
      return false;
    }
  }

  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (_) {
      return false;
    }
  }

  Future<Amplitude> getAmplitude() async {
    try {
      return await _recorder.getAmplitude();
    } catch (_) {
      return Amplitude(current: -160.0, max: -160.0);
    }
  }

  /// Starts recording 16kHz mono WAV audio to platform-appropriate destination
  Future<void> startRecording({String? path}) async {
    final effectivePath = (path != null && path.isNotEmpty)
        ? path
        : getPlatformRecordingPath();

    _currentRecordPath = effectivePath;

    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );

    try {
      await _recorder.start(config, path: effectivePath);
      debugPrint('🎙️ AudioRecorder started recording to: "$effectivePath"');
    } catch (e) {
      debugPrint('❌ AudioRecorder start error: $e');
      rethrow;
    }
  }

  /// Stops recording, retrieves audio bytes across platforms, and returns RecordedAudio
  Future<RecordedAudio?> stopRecording({Duration duration = Duration.zero}) async {
    try {
      final returnedPath = await _recorder.stop();
      final effectivePath = (returnedPath != null && returnedPath.isNotEmpty)
          ? returnedPath
          : _currentRecordPath;

      debugPrint('🛑 AudioRecorder stopped. Final path: "$effectivePath"');

      // Read audio bytes across native file system and browser Blob APIs
      final bytes = await readPlatformAudioBytes(effectivePath);

      if (bytes != null) {
        debugPrint('✅ Audio bytes captured successfully: ${bytes.length} bytes');
      } else {
        debugPrint('⚠️ No audio bytes retrieved from "$effectivePath"');
      }

      return RecordedAudio(
        path: effectivePath,
        bytes: bytes,
        duration: duration,
      );
    } catch (e) {
      debugPrint('❌ Stop recording error: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {}
  }
}
