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
  });
}
