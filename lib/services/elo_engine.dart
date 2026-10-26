import 'dart:math' as math;
import '../models/learner_profile.dart';
import '../models/story_model.dart';
import 'story_service.dart';

class EloEngine {
  static const double kFactor = 32.0;
  static const double masteryTarget = 1200.0;

  /// Updates Elo rating for a specific skill when child answers an MCQ
  static Map<String, double> updateElo({
    required Map<String, double> currentRatings,
    required String skill,
    required bool isCorrect,
    double itemDifficulty = 1000.0,
  }) {
    final updated = Map<String, double>.from(currentRatings);
    final currentElo = updated[skill] ?? 1000.0;

    // Standard Elo formula: E = 1 / (1 + 10^((item - child) / 400))
    final double exponent = (itemDifficulty - currentElo) / 400.0;
    final double expected = 1.0 / (1.0 + math.pow(10.0, exponent));
    final double actual = isCorrect ? 1.0 : 0.0;

    final double newElo = currentElo + kFactor * (actual - expected);
    updated[skill] = newElo.clamp(600.0, 2000.0);
    return updated;
  }

  /// Selects the best next story maximizing weighted gap to mastery
  /// Implements Formula 1, 2, and 3 from Section 3.6 of the Project Report
  static Story selectNextStory(LearnerProfile profile) {
    final List<Story> available = StoryService.allStories;
    
    // Hard novelty exclusion: filter out last 3 stories served (Lc)
    List<Story> eligible = available
        .where((s) => !profile.recentStoryIds.contains(s.storyId))
        .toList();

    // Fallback if pool exhausted
    if (eligible.isEmpty) {
      eligible = available;
    }

    Story bestStory = eligible.first;
    double highestScore = -999999.0;

    for (final story in eligible) {
      double maxWeightedGap = 0.0;

      // Score: max_{s in S_j} (w_js * gap_{c,s})
      story.skillWeights.forEach((skill, weight) {
        final currentRating = profile.eloRatings[skill] ?? 1000.0;
        final gap = math.max(0.0, masteryTarget - currentRating);
        final weightedGap = weight * gap;
        if (weightedGap > maxWeightedGap) {
          maxWeightedGap = weightedGap;
        }
      });

      // Soft penalty for repeating theme
      double penalty = 0.0;
      if (profile.completedStoryIds.isNotEmpty) {
        final lastStory = StoryService.getStoryById(profile.completedStoryIds.last);
        final commonThemes = story.themes.where((t) => lastStory.themes.contains(t)).length;
        penalty = commonThemes * 8.0;
      }

      final score = maxWeightedGap - penalty;
      if (score > highestScore) {
        highestScore = score;
        bestStory = story;
      }
    }

    return bestStory;
  }
}
