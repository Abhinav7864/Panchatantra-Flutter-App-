import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  StreamSubscription<Uint8List>? _streamSub;
  final List<int> _pcmBuffer = [];

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

  /// Starts recording with dual capture: standard file/blob + in-memory PCM stream
  Future<void> startRecording({String? path}) async {
    _pcmBuffer.clear();
    await _streamSub?.cancel();

    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );

    try {
      // Start streaming PCM chunks directly into Dart memory (works seamlessly on Web and Native)
      final stream = await _recorder.startStream(config);
      _streamSub = stream.listen((chunk) {
        _pcmBuffer.addAll(chunk);
      }, onError: (e) {
        debugPrint('Record stream chunk error: $e');
      });
    } catch (e) {
      debugPrint('Start stream fallback to file: $e');
      // If streaming not supported on specific platform, fallback to file path
      await _recorder.start(config, path: path ?? '');
    }
  }

  Future<RecordedAudio?> stopRecording({Duration duration = Duration.zero}) async {
    try {
      await _streamSub?.cancel();
      final path = await _recorder.stop() ?? '';

      Uint8List? finalWavBytes;

      // 1. If in-memory stream buffer has data, package with standard WAV header
      if (_pcmBuffer.isNotEmpty) {
        final rawPcm = Uint8List.fromList(_pcmBuffer);
        finalWavBytes = _createWavContainer(rawPcm, 16000, 1);
      }

      // 2. If native file exists (Desktop / Mobile), read file directly
      if ((finalWavBytes == null || finalWavBytes.isEmpty) && !kIsWeb && path.isNotEmpty) {
        try {
          final file = File(path);
          if (await file.exists()) {
            finalWavBytes = await file.readAsBytes();
          }
        } catch (_) {}
      }

      return RecordedAudio(
        path: path,
        bytes: finalWavBytes,
        duration: duration,
      );
    } catch (e) {
      debugPrint('Stop recording error: $e');
      return null;
    }
  }

  /// Wraps raw 16-bit mono PCM into a standard 44-byte WAV audio container
  static Uint8List _createWavContainer(Uint8List pcmData, int sampleRate, int numChannels) {
    // If data already has RIFF/WAV header, return directly
    if (pcmData.length >= 12 &&
        pcmData[0] == 0x52 && pcmData[1] == 0x49 && pcmData[2] == 0x46 && pcmData[3] == 0x46) {
      return pcmData;
    }

    final byteRate = sampleRate * numChannels * 2;
    final blockAlign = numChannels * 2;
    final totalDataLen = pcmData.length;
    final totalAudioLen = totalDataLen + 36;

    final header = Uint8List(44);
    final b = ByteData.view(header.buffer);

    // RIFF chunk
    header[0] = 0x52; // 'R'
    header[1] = 0x49; // 'I'
    header[2] = 0x46; // 'F'
    header[3] = 0x46; // 'F'
    b.setUint32(4, totalAudioLen, Endian.little);
    header[8] = 0x57;  // 'W'
    header[9] = 0x41;  // 'A'
    header[10] = 0x56; // 'V'
    header[11] = 0x45; // 'E'

    // fmt subchunk
    header[12] = 0x66; // 'f'
    header[13] = 0x6D; // 'm'
    header[14] = 0x74; // 't'
    header[15] = 0x20; // ' '
    b.setUint32(16, 16, Endian.little); // Subchunk1Size
    b.setUint16(20, 1, Endian.little);  // PCM format
    b.setUint16(22, numChannels, Endian.little);
    b.setUint32(24, sampleRate, Endian.little);
    b.setUint32(28, byteRate, Endian.little);
    b.setUint16(32, blockAlign, Endian.little);
    b.setUint16(34, 16, Endian.little); // 16-bit

    // data subchunk
    header[36] = 0x64; // 'd'
    header[37] = 0x61; // 'a'
    header[38] = 0x74; // 't'
    header[39] = 0x61; // 'a'
    b.setUint32(40, totalDataLen, Endian.little);

    final out = Uint8List(44 + totalDataLen);
    out.setRange(0, 44, header);
    out.setRange(44, 44 + totalDataLen, pcmData);
    return out;
  }

  Future<void> dispose() async {
    try {
      await _streamSub?.cancel();
      await _recorder.dispose();
    } catch (_) {}
  }
}
