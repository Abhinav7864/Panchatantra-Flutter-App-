import 'dart:js_interop';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

String getPlatformRecordingPath() {
  // Web does not use file system paths for recording
  return '';
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

WavAnalysisResult analyzeAndNormalizeWav(Uint8List bytes) {
  if (bytes.length < 44) {
    return WavAnalysisResult(peakAmplitude: 0.0, isSilent: true, bytes: bytes);
  }

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
  final isSilent = peak < 0.012;

  if (isSilent || peak >= 0.85 || peak <= 0.0) {
    return WavAnalysisResult(
      peakAmplitude: peak,
      isSilent: isSilent,
      bytes: bytes,
    );
  }

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
    final response = await web.window.fetch(path.toJS).toDart;
    final arrayBuffer = await response.arrayBuffer().toDart;
    final rawBytes = arrayBuffer.toDart.asUint8List();
    if (rawBytes.length > 100) {
      if (normalize) {
        final analyzed = analyzeAndNormalizeWav(rawBytes);
        return analyzed.bytes;
      }
      return rawBytes;
    }
  } catch (e) {
    debugPrint('readPlatformAudioBytes (web) error: $e');
  }
  return null;
}

Future<Source?> createPlatformAudioSource({
  Uint8List? bytes,
  String? path,
  String? assetFallback,
}) async {
  try {
    // 1. In browser, BytesSource works natively by creating blob URLs
    if (bytes != null && bytes.isNotEmpty) {
      return BytesSource(bytes);
    }

    // 2. If blob or http URL
    if (path != null && path.isNotEmpty) {
      return UrlSource(path);
    }

    // 3. Asset fallback
    if (assetFallback != null && assetFallback.isNotEmpty) {
      return AssetSource(assetFallback);
    }
  } catch (e) {
    debugPrint('createPlatformAudioSource (web) error: $e');
  }
  return null;
}
