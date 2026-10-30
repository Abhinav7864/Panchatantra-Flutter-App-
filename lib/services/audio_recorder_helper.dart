import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

class RecordedAudio {
  final String path;
  final Uint8List? bytes;
  final Duration duration;

  const RecordedAudio({
    required this.path,
    this.bytes,
    this.duration = Duration.zero,
  });
}

class AudioRecorderHelper {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
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

  Future<void> startRecording({String? path}) async {
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );
    await _recorder.start(config, path: path ?? '');
  }

  Future<RecordedAudio?> stopRecording({Duration duration = Duration.zero}) async {
    try {
      final path = await _recorder.stop();
      if (path == null) return null;

      Uint8List? bytes;
      try {
        if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
          final res = await http.get(Uri.parse(path));
          bytes = res.bodyBytes;
        } else {
          final file = File(path);
          if (await file.exists()) {
            bytes = await file.readAsBytes();
          }
        }
      } catch (e) {
        debugPrint('Error reading recorded audio bytes: $e');
      }

      return RecordedAudio(
        path: path,
        bytes: bytes,
        duration: duration,
      );
    } catch (e) {
      debugPrint('Stop recording error: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {}
  }
}
