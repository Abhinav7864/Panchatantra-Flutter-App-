import 'quiz_model.dart';

class StoryScene {
  final int sceneNumber;
  final String illustrationTheme;
  final String narrationSnippet;

  const StoryScene({
    required this.sceneNumber,
    required this.illustrationTheme,
    required this.narrationSnippet,
  });
}

class Story {
  final String storyId;
  final String title;
  final String tantraBook;
  final String ageBand; // '4-9' or '9+'
  final int readingMinutes;
  final int cognitiveLevel; // 1 to 5
  final String summary;
  final String adaptedText;
  final String originalSourceCitation;
  final String moral;
  final String iksConcept; // e.g. "Dharma (Righteous Duty)"
  final String iksExplanation;
  final List<String> characters;
  final List<String> themes;
  final Map<String, String> glossary; // word -> definition
  final List<QuizQuestion> questions;
  final String discussionPrompt; // open moral reflection
  final Map<String, double> skillWeights; // w_js centrality weights for Elo selector
  final String coverEmoji;

  const Story({
    required this.storyId,
    required this.title,
    required this.tantraBook,
    required this.ageBand,
    required this.readingMinutes,
    required this.cognitiveLevel,
    required this.summary,
    required this.adaptedText,
    required this.originalSourceCitation,
    required this.moral,
    required this.iksConcept,
    required this.iksExplanation,
    required this.characters,
    required this.themes,
    required this.glossary,
    required this.questions,
    required this.discussionPrompt,
    required this.skillWeights,
    this.coverEmoji = '🦁',
  });
}
