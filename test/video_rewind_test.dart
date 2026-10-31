import 'package:flutter_test/flutter_test.dart';
import 'package:panchatantra_app/screens/video_story_screen.dart';

void main() {
  group('Video Story Smart Rewind Verification Tests', () {
    test('All 5 video questions have valid rewind timestamps and sentence snippets', () {
      expect(VideoStoryScreen.videoQuestions.length, 5);

      for (final q in VideoStoryScreen.videoQuestions) {
        expect(q.rewindTimestampSeconds, isNotNull);
        expect(q.rewindTimestampSeconds, greaterThanOrEqualTo(0.0));
        expect(q.rewindTimestampSeconds, lessThan(q.pauseTimestampSeconds),
            reason: 'Rewind timestamp must precede pause timestamp for question ${q.id}');
        expect(q.sentenceSnippet.trim().isNotEmpty, isTrue,
            reason: 'Question ${q.id} must have a non-empty sentence snippet clue');
        expect(q.options.isNotEmpty, isTrue);
        expect(q.correctIndex, greaterThanOrEqualTo(0));
        expect(q.correctIndex, lessThan(q.options.length));
      }
    });

    test('Rewind timestamps map correctly to the animated narrative arc', () {
      final questions = VideoStoryScreen.videoQuestions;

      // Question 1: Lion terrorizing savanna woodland
      expect(questions[0].id, 1);
      expect(questions[0].rewindTimestampSeconds, 12.0);
      expect(questions[0].pauseTimestampSeconds, 42.0);
      expect(questions[0].sentenceSnippet, contains('ferocious king lion'));

      // Question 2: Clever rabbit stepping forward
      expect(questions[1].id, 2);
      expect(questions[1].rewindTimestampSeconds, 50.0);
      expect(questions[1].pauseTimestampSeconds, 92.0);
      expect(questions[1].sentenceSnippet, contains('clever plan'));

      // Question 3: Dhairya & staying calm
      expect(questions[2].id, 3);
      expect(questions[2].rewindTimestampSeconds, 98.0);
      expect(questions[2].pauseTimestampSeconds, 142.0);
      expect(questions[2].sentenceSnippet, contains('deep breaths'));

      // Question 4: Reflection in well
      expect(questions[3].id, 4);
      expect(questions[3].rewindTimestampSeconds, 150.0);
      expect(questions[3].pauseTimestampSeconds, 192.0);
      expect(questions[3].sentenceSnippet, contains('deep stone well'));

      // Question 5: Moral and wisdom application
      expect(questions[4].id, 5);
      expect(questions[4].rewindTimestampSeconds, 198.0);
      expect(questions[4].pauseTimestampSeconds, 230.0);
      expect(questions[4].sentenceSnippet, contains('wisdom and intellect'));
    });
  });
}
