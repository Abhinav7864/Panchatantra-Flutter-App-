import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'audio_platform/audio_platform_helper.dart';

export 'package:record/record.dart' show InputDevice;

class RecordedAudio {
  final String path;
  final Uint8List? bytes;
  final Duration duration;
  final double peakAmplitude;
  final bool isSilent;
  final String? inputDeviceName;

  const RecordedAudio({
    required this.path,
    this.bytes,
    this.duration = Duration.zero,
    this.peakAmplitude = 0.0,
    this.isSilent = false,
    this.inputDeviceName,
  });

  bool get hasValidAudio => bytes != null && bytes!.length > 500 && !isSilent;
}

class AudioRecorderHelper {
  final AudioRecorder _recorder = AudioRecorder();
  String _currentRecordPath = '';
  InputDevice? _activeDevice;

  InputDevice? get activeDevice => _activeDevice;

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

  /// Lists available audio input devices (e.g. MacBook Air Microphone, Headset, etc.)
  Future<List<InputDevice>> listInputDevices() async {
    try {
      final devices = await _recorder.listInputDevices();
      debugPrint('🎙️ Available audio input devices: ${devices.map((d) => "${d.label} (${d.id})").toList()}');
      return devices;
    } catch (e) {
      debugPrint('listInputDevices error: $e');
      return [];
    }
  }

  /// Automatically discovers and prioritizes the laptop's built-in microphone
  /// to avoid macOS erroneously selecting a floating/muted 3.5mm headphone jack.
  Future<InputDevice?> getDefaultPreferredInputDevice() async {
    try {
      final devices = await listInputDevices();
      if (devices.isEmpty) return null;

      // 1. Prioritize built-in laptop microphone array
      for (final dev in devices) {
        final label = dev.label.toLowerCase();
        final id = dev.id.toLowerCase();
        if (label.contains('macbook') ||
            label.contains('built-in') ||
            label.contains('builtin') ||
            label.contains('internal') ||
            id.contains('builtinmicrophone')) {
          debugPrint('🎯 Auto-selected built-in microphone: ${dev.label} (${dev.id})');
          return dev;
        }
      }

      // 2. Fall back to first available device
      return devices.first;
    } catch (e) {
      debugPrint('getDefaultPreferredInputDevice error: $e');
      return null;
    }
  }

  /// Starts recording 16kHz mono WAV audio using the preferred microphone
  Future<void> startRecording({String? path, InputDevice? device}) async {
    // Auto-select laptop microphone if none explicitly provided
    InputDevice? targetDevice = device;
    targetDevice ??= await getDefaultPreferredInputDevice();
    _activeDevice = targetDevice;

    final effectivePath = (path != null && path.isNotEmpty)
        ? path
        : getPlatformRecordingPath();

    _currentRecordPath = effectivePath;

    final config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
      device: targetDevice,
    );

    try {
      await _recorder.start(config, path: effectivePath);
      debugPrint('🎙️ AudioRecorder started recording to: "$effectivePath" using [${targetDevice?.label ?? "default"}]');
    } catch (e) {
      debugPrint('❌ AudioRecorder start error: $e');
      rethrow;
    }
  }

  /// Stops recording, analyzes waveform amplitude, boosts volume, and returns RecordedAudio
  Future<RecordedAudio?> stopRecording({Duration duration = Duration.zero}) async {
    try {
      final returnedPath = await _recorder.stop();
      final effectivePath = (returnedPath != null && returnedPath.isNotEmpty)
          ? returnedPath
          : _currentRecordPath;

      debugPrint('🛑 AudioRecorder stopped. Final path: "$effectivePath"');

      // Read audio bytes and normalize quiet speech in place
      final bytes = await readPlatformAudioBytes(effectivePath, normalize: true);

      double peak = 0.0;
      bool isSilent = false;

      if (bytes != null && bytes.isNotEmpty) {
        final analysis = analyzeAndNormalizeWav(bytes);
        peak = analysis.peakAmplitude;
        isSilent = analysis.isSilent;
        debugPrint('📊 Audio analysis: peak=${(peak * 100).toStringAsFixed(1)}%, silent=$isSilent, length=${bytes.length} bytes');
      } else {
        isSilent = true;
        debugPrint('⚠️ No audio bytes retrieved from "$effectivePath"');
      }

      return RecordedAudio(
        path: effectivePath,
        bytes: bytes,
        duration: duration,
        peakAmplitude: peak,
        isSilent: isSilent,
        inputDeviceName: _activeDevice?.label,
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
