class LearnerProfile {
  final String childName;
  final int age;
  final String ageBand; // '4-9' or '9+'
  final String avatar;
  final double cognitiveComplexity; // 1 to 5
  final double emotionalResilience;
  final double culturalLiteracy;
  final double attentionSpan;
  final Map<String, double> eloRatings; // C1, C2, C3, M1, M2, M3
  final List<String> completedStoryIds;
  final List<String> recentStoryIds; // for novelty exclusion L_c
  final int starsCount;
  final int minutesReadToday;

  LearnerProfile({
    required this.childName,
    required this.age,
    required this.ageBand,
    this.avatar = 'cub',
    this.cognitiveComplexity = 3.0,
    this.emotionalResilience = 3.0,
    this.culturalLiteracy = 3.0,
    this.attentionSpan = 3.0,
    required this.eloRatings,
    this.completedStoryIds = const [],
    this.recentStoryIds = const [],
    this.starsCount = 24,
    this.minutesReadToday = 18,
  });

  // Initial default profile for a typical 7-year-old child (Eity)
  factory LearnerProfile.defaultChild() {
    return LearnerProfile(
      childName: 'Eity',
      age: 7,
      ageBand: '4-9',
      avatar: 'cub',
      cognitiveComplexity: 2.8,
      emotionalResilience: 3.2,
      culturalLiteracy: 3.0,
      attentionSpan: 2.5,
      eloRatings: {
        'C1_recall': 1050.0,
        'C2_sequence': 1020.0,
        'C3_motive': 1080.0,
        'M1_perspective': 1040.0,
        'M2_moral_dilemma': 1010.0,
        'M3_niti_strategy': 1070.0,
      },
      completedStoryIds: ['PT005'],
      recentStoryIds: ['PT005'],
      starsCount: 36,
      minutesReadToday: 22,
    );
  }

  LearnerProfile copyWith({
    String? childName,
    int? age,
    String? ageBand,
    String? avatar,
    double? cognitiveComplexity,
    double? emotionalResilience,
    double? culturalLiteracy,
    double? attentionSpan,
    Map<String, double>? eloRatings,
    List<String>? completedStoryIds,
    List<String>? recentStoryIds,
    int? starsCount,
    int? minutesReadToday,
  }) {
    return LearnerProfile(
      childName: childName ?? this.childName,
      age: age ?? this.age,
      ageBand: ageBand ?? this.ageBand,
      avatar: avatar ?? this.avatar,
      cognitiveComplexity: cognitiveComplexity ?? this.cognitiveComplexity,
      emotionalResilience: emotionalResilience ?? this.emotionalResilience,
      culturalLiteracy: culturalLiteracy ?? this.culturalLiteracy,
      attentionSpan: attentionSpan ?? this.attentionSpan,
      eloRatings: eloRatings ?? Map.from(this.eloRatings),
      completedStoryIds: completedStoryIds ?? List.from(this.completedStoryIds),
      recentStoryIds: recentStoryIds ?? List.from(this.recentStoryIds),
      starsCount: starsCount ?? this.starsCount,
      minutesReadToday: minutesReadToday ?? this.minutesReadToday,
    );
  }
}
