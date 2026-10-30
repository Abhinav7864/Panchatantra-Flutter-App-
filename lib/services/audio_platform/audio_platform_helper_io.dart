import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

String getPlatformRecordingPath() {
  final tempDir = Directory.systemTemp;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${tempDir.path}/user_voice_recording_$timestamp.wav';
}

class WavAnalysisResult {
  final double peakAmplitude;
  final bool isSilent;
  final Uint8List bytes;

  const WavAnalysisResult({
    required this.peakAmplitude,
    required this.isSilent,
    required this.bytes,
  });
}

/// Analyzes 16-bit linear PCM audio in WAV container, checks for dead silence,
/// and normalizes comfortable speech to ~0.88 peak (-1.1 dBFS).
WavAnalysisResult analyzeAndNormalizeWav(Uint8List bytes) {
  if (bytes.length < 44) {
    return WavAnalysisResult(peakAmplitude: 0.0, isSilent: true, bytes: bytes);
  }

  // Locate the 'data' chunk inside the WAV container
  int dataIndex = -1;
  for (int i = 0; i < bytes.length - 8; i++) {
    if (bytes[i] == 0x64 &&
        bytes[i + 1] == 0x61 &&
        bytes[i + 2] == 0x74 &&
        bytes[i + 3] == 0x61) {
      dataIndex = i;
      break;
    }
  }

  if (dataIndex == -1 || dataIndex + 8 >= bytes.length) {
    return WavAnalysisResult(peakAmplitude: 1.0, isSilent: false, bytes: bytes);
  }

  final dataByteLength =
      ByteData.sublistView(bytes, dataIndex + 4, dataIndex + 8)
          .getUint32(0, Endian.little);
  final startOffset = dataIndex + 8;
  final endOffset =
      (startOffset + dataByteLength).clamp(startOffset, bytes.length);

  final sampleCount = (endOffset - startOffset) ~/ 2;
  if (sampleCount == 0) {
    return WavAnalysisResult(peakAmplitude: 0.0, isSilent: true, bytes: bytes);
  }

  final bd = ByteData.sublistView(bytes, startOffset, endOffset);
  int maxSample = 0;
  for (int i = 0; i < sampleCount; i++) {
    final s = bd.getInt16(i * 2, Endian.little).abs();
    if (s > maxSample) maxSample = s;
  }

  final peak = maxSample / 32768.0;
  // Threshold: less than 1.2% maximum signal is considered ambient background/electrical silence
  final isSilent = peak < 0.012;

  if (isSilent || peak >= 0.85 || peak <= 0.0) {
    return WavAnalysisResult(
      peakAmplitude: peak,
      isSilent: isSilent,
      bytes: bytes,
    );
  }

  // Boost soft/moderate speech to 0.88 peak
  final gain = 0.88 / peak;
  final outputBytes = Uint8List.fromList(bytes);
  final outBd = ByteData.sublistView(outputBytes, startOffset, endOffset);
  for (int i = 0; i < sampleCount; i++) {
    final original = bd.getInt16(i * 2, Endian.little);
    final scaled = (original * gain).round().clamp(-32768, 32767);
    outBd.setInt16(i * 2, scaled, Endian.little);
  }

  return WavAnalysisResult(
    peakAmplitude: 0.88,
    isSilent: false,
    bytes: outputBytes,
  );
}

Future<Uint8List?> readPlatformAudioBytes(String path, {bool normalize = true}) async {
  try {
    if (path.isEmpty) return null;
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      if (bytes.length > 100) {
        if (normalize) {
          final analyzed = analyzeAndNormalizeWav(bytes);
          if (!analyzed.isSilent && analyzed.peakAmplitude > 0) {
            // Write normalized bytes back so player and server consume loud, clean audio
            await file.writeAsBytes(analyzed.bytes, flush: true);
          }
          return analyzed.bytes;
        }
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
      final tempFile = File(
          '${tempDir.path}/play_cache_${DateTime.now().millisecondsSinceEpoch}.wav');
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
