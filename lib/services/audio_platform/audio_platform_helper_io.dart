import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

String getPlatformRecordingPath() {
  final tempDir = Directory.systemTemp;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${tempDir.path}/user_voice_recording_$timestamp.wav';
}

Future<Uint8List?> readPlatformAudioBytes(String path) async {
  try {
    if (path.isEmpty) return null;
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      if (bytes.length > 100) {
        return bytes;
      }
    }
  } catch (e) {
    debugPrint('readPlatformAudioBytes error: $e');
  }
  return null;
}

Future<Source?> createPlatformAudioSource({
  Uint8List? bytes,
  String? path,
  String? assetFallback,
}) async {
  try {
    // 1. If we have raw bytes, write to a temp file and play via DeviceFileSource
    // to bypass DarwinAudioError (setSourceBytes is not implemented on iOS / macOS).
    if (bytes != null && bytes.isNotEmpty) {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/play_cache_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(bytes, flush: true);
      return DeviceFileSource(tempFile.path);
    }

    // 2. If a local file path exists, use DeviceFileSource
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return UrlSource(path);
      }
      final file = File(path);
      if (await file.exists()) {
        return DeviceFileSource(path);
      }
    }

    // 3. Asset fallback
    if (assetFallback != null && assetFallback.isNotEmpty) {
      return AssetSource(assetFallback);
    }
  } catch (e) {
    debugPrint('createPlatformAudioSource error: $e');
  }
  return null;
}
