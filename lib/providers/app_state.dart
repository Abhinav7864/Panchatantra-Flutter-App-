import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_platform/audio_platform_helper.dart';
import '../models/learner_profile.dart';
import '../models/voice_profile.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import '../services/elo_engine.dart';

class AppState extends ChangeNotifier {
  LearnerProfile _profile = LearnerProfile.defaultChild();
  VoiceProfile _voiceProfile = VoiceProfile();
  late Story _activeStory;
  int _currentTabIndex = 0;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _audioProgress = 0.0;
  double _playbackSpeed = 1.0;
  bool _useParentVoice = true;
  Duration _audioDuration = const Duration(seconds: 5);

  // Search filter
  String _searchQuery = '';
  String _selectedCategory = 'All';

  AppState() {
    _activeStory = StoryService.allStories.first;
    _initAudio();
  }

  void _initAudio() {
    _audioPlayer.onPositionChanged.listen((pos) {
      if (_audioDuration.inMilliseconds > 0) {
        _audioProgress = (pos.inMilliseconds / _audioDuration.inMilliseconds).clamp(0.0, 1.0);
        notifyListeners();
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      _audioDuration = dur;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }
    });
  }

  // Getters
  LearnerProfile get profile => _profile;
  VoiceProfile get voiceProfile => _voiceProfile;
  Story get activeStory => _activeStory;
  int get currentTabIndex => _currentTabIndex;
  bool get isPlaying => _isPlaying;
  double get audioProgress => _audioProgress;
  double get playbackSpeed => _playbackSpeed;
  bool get useParentVoice => _useParentVoice && _voiceProfile.isEnrolled;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Story get recommendedStory => EloEngine.selectNextStory(_profile);

  // Tab Navigation
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Story Selection
  void setActiveStory(Story story) {
    _activeStory = story;
    _isPlaying = false;
    _audioProgress = 0.0;
    _audioPlayer.stop();
    notifyListeners();
  }

  // Audio Controls
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final source = await createPlatformAudioSource(
          path: 'assets/audio/cloned_sample.wav',
          assetFallback: 'audio/cloned_sample.wav',
        );
        if (source != null) {
          await _audioPlayer.play(source);
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
        }
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
      _isPlaying = !_isPlaying;
      notifyListeners();
    }
  }

  Future<void> setAudioProgress(double val) async {
    _audioProgress = val.clamp(0.0, 1.0);
    notifyListeners();
    if (_audioDuration.inMilliseconds > 0) {
      final targetMs = (val * _audioDuration.inMilliseconds).toInt();
      try {
        await _audioPlayer.seek(Duration(milliseconds: targetMs));
      } catch (_) {}
    }
  }

  Future<void> cyclePlaybackSpeed() async {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 1.25;
    } else if (_playbackSpeed == 1.25) {
      _playbackSpeed = 0.75;
    } else {
      _playbackSpeed = 1.0;
    }
    try {
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
    } catch (_) {}
    notifyListeners();
  }

  void toggleParentVoice() {
    _useParentVoice = !_useParentVoice;
    notifyListeners();
  }

  // Child Profile Updates
  void updateProfile({
    String? name,
    int? age,
    String? ageBand,
    double? cognitiveComplexity,
    double? emotionalResilience,
    double? culturalLiteracy,
    double? attentionSpan,
  }) {
    _profile = _profile.copyWith(
      childName: name,
      age: age,
      ageBand: ageBand,
      cognitiveComplexity: cognitiveComplexity,
      emotionalResilience: emotionalResilience,
      culturalLiteracy: culturalLiteracy,
      attentionSpan: attentionSpan,
    );
    notifyListeners();
  }

  // Parent Voice Lifecycle
  void enrollParentVoice({
    required String parentName,
    required double sampleDuration,
    String? voiceId,
    String? provider,
  }) {
    _voiceProfile = _voiceProfile.copyWith(
      isEnrolled: true,
      parentName: parentName,
      consentAccepted: true,
      consentTimestamp: DateTime.now(),
      sampleLengthSeconds: sampleDuration,
      isAIActive: true,
      voiceId: voiceId,
      provider: provider ?? 'Inworld AI Realtime Cloud Voice',
    );
    _useParentVoice = true;
    notifyListeners();
  }

  void revokeParentVoice() {
    _voiceProfile = _voiceProfile.copyWith(
      isEnrolled: false,
      consentAccepted: false,
      isAIActive: false,
    );
    _useParentVoice = false;
    _audioPlayer.stop();
    notifyListeners();
  }

  // Elo & Learning Loop
  void recordAnswer({required String skill, required bool isCorrect}) {
    final updatedElo = EloEngine.updateElo(
      currentRatings: _profile.eloRatings,
      skill: skill,
      isCorrect: isCorrect,
    );
    _profile = _profile.copyWith(eloRatings: updatedElo);
    notifyListeners();
  }

  void finishStory(String storyId) {
    final updatedCompleted = List<String>.from(_profile.completedStoryIds);
    if (!updatedCompleted.contains(storyId)) {
      updatedCompleted.add(storyId);
    }

    final updatedRecent = List<String>.from(_profile.recentStoryIds);
    updatedRecent.add(storyId);
    if (updatedRecent.length > 3) {
      updatedRecent.removeAt(0); // keep only last 3 for L_c novelty exclusion
    }

    _profile = _profile.copyWith(
      completedStoryIds: updatedCompleted,
      recentStoryIds: updatedRecent,
      starsCount: _profile.starsCount + 3,
      minutesReadToday: _profile.minutesReadToday + 8,
    );
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
