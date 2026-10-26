class QuizQuestion {
  final String id;
  final String prompt;
  final String skill; // C1_recall, C2_sequence, C3_motive, etc.
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.skill,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
