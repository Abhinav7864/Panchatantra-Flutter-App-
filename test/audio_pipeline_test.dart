import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:panchatantra_app/services/audio_recorder_helper.dart';
import 'package:panchatantra_app/services/audio_platform/audio_platform_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Platform & Recorder Pipeline Tests', () {
    test('getPlatformRecordingPath returns valid .wav path', () {
      final path = getPlatformRecordingPath();
      expect(path.isNotEmpty, isTrue);
      expect(path.endsWith('.wav'), isTrue);
    });

    test('RecordedAudio hasValidAudio checks byte thresholds', () {
      const emptyRecording = RecordedAudio(path: '', bytes: null);
      expect(emptyRecording.hasValidAudio, isFalse);

      final tinyRecording = RecordedAudio(
        path: '/tmp/test.wav',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(tinyRecording.hasValidAudio, isFalse);

      final realRecording = RecordedAudio(
        path: '/tmp/test.wav',
        bytes: Uint8List(1024),
      );
      expect(realRecording.hasValidAudio, isTrue);
    });

    test('createPlatformAudioSource safely wraps bytes into DeviceFileSource on native', () async {
      final sampleBytes = Uint8List.fromList(List.generate(200, (i) => i % 256));
      final source = await createPlatformAudioSource(bytes: sampleBytes);

      expect(source, isNotNull);
      expect(source, isA<DeviceFileSource>());
      final fileSource = source as DeviceFileSource;
      expect(fileSource.path.endsWith('.wav'), isTrue);
      expect(File(fileSource.path).existsSync(), isTrue);

      // Clean up
      try {
        File(fileSource.path).deleteSync();
      } catch (_) {}
    });

    test('readPlatformAudioBytes reads written audio bytes', () async {
      final tempFile = File('${Directory.systemTemp.path}/test_read_${DateTime.now().millisecondsSinceEpoch}.wav');
      final dummyBytes = Uint8List.fromList(List.generate(600, (i) => (i * 3) % 256));
      await tempFile.writeAsBytes(dummyBytes);

      final readBytes = await readPlatformAudioBytes(tempFile.path);
      expect(readBytes, isNotNull);
      expect(readBytes!.length, equals(600));

      tempFile.deleteSync();
    });

    test('analyzeAndNormalizeWav identifies silent audio and boosts soft speech', () {
      // Build a minimal RIFF WAV with silence (PCM int16 zeros)
      final wavData = Uint8List(44 + 2000);
      final bd = ByteData.view(wavData.buffer);
      // 'RIFF'
      wavData.setRange(0, 4, [0x52, 0x49, 0x46, 0x46]);
      bd.setUint32(4, 2036, Endian.little);
      // 'WAVE'
      wavData.setRange(8, 12, [0x57, 0x41, 0x56, 0x45]);
      // 'fmt '
      wavData.setRange(12, 16, [0x66, 0x6D, 0x74, 0x20]);
      bd.setUint32(16, 16, Endian.little);
      bd.setUint16(20, 1, Endian.little); // PCM
      bd.setUint16(22, 1, Endian.little); // mono
      bd.setUint32(24, 16000, Endian.little);
      bd.setUint32(28, 32000, Endian.little);
      bd.setUint16(32, 2, Endian.little);
      bd.setUint16(34, 16, Endian.little);
      // 'data'
      wavData.setRange(36, 40, [0x64, 0x61, 0x74, 0x61]);
      bd.setUint32(40, 2000, Endian.little);

      // 1. Pure silence
      final silentResult = analyzeAndNormalizeWav(wavData);
      expect(silentResult.isSilent, isTrue);
      expect(silentResult.peakAmplitude, equals(0.0));

      // 2. Soft speech (max amplitude ~0.15 = 4915)
      for (int i = 0; i < 1000; i++) {
        bd.setInt16(44 + i * 2, (i % 2 == 0 ? 4915 : -4915), Endian.little);
      }
      final softResult = analyzeAndNormalizeWav(wavData);
      expect(softResult.isSilent, isFalse);
      expect(softResult.peakAmplitude, closeTo(0.88, 0.01));
    });
  });
}
