import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'voice_clone_runner.dart';

class InworldVoice {
  final String voiceId;
  final String displayName;
  final String status;
  final String provider;

  InworldVoice({
    required this.voiceId,
    required this.displayName,
    this.status = 'READY',
    this.provider = 'INWORLD_CLONE',
  });

  factory InworldVoice.fromJson(Map<String, dynamic> json) {
    return InworldVoice(
      voiceId: json['voiceId'] ?? json['id'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? 'Cloned Voice',
      status: json['status'] ?? 'READY',
      provider: json['provider'] ?? 'INWORLD_CLONE',
    );
  }
}

class CloudVoiceConfig {
  final String provider; // 'inworld' or 'elevenlabs'
  final String apiKey;
  final String voiceId;
  final String voiceDisplayName;
  final bool isEnabled;

  const CloudVoiceConfig({
    this.provider = 'inworld',
    this.apiKey = '',
    this.voiceId = '',
    this.voiceDisplayName = '',
    this.isEnabled = false,
  });

  bool get isValid => apiKey.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'apiKey': apiKey.trim(),
        'voiceId': voiceId.trim(),
        'voiceDisplayName': voiceDisplayName.trim(),
        'isEnabled': isEnabled,
      };

  factory CloudVoiceConfig.fromJson(Map<String, dynamic> json) {
    return CloudVoiceConfig(
      provider: json['provider'] ?? 'inworld',
      apiKey: json['apiKey'] ?? '',
      voiceId: json['voiceId'] ?? '',
      voiceDisplayName: json['voiceDisplayName'] ?? '',
      isEnabled: json['isEnabled'] ?? (json['apiKey'] != null && (json['apiKey'] as String).isNotEmpty),
    );
  }
}

class CloudVoiceService {
  static const String defaultMasterApiKey = 'U2Q5ZWFoYzlHSHlRN3phdV9rNzJPa2E0U05UTmhLZEI6cEhyWXFrV2tqRThqS2xKZTV4WTVDMA==';
  static const String _configFile = 'voice_profiles/cloud_api_config.json';
  static CloudVoiceConfig? _cachedConfig;

  /// Loads stored configuration from disk
  static Future<CloudVoiceConfig> loadConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    try {
      final file = File(_configFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        final cfg = CloudVoiceConfig.fromJson(json);
        _cachedConfig = cfg.apiKey.isNotEmpty
            ? cfg
            : CloudVoiceConfig(
                provider: 'inworld',
                apiKey: defaultMasterApiKey,
                voiceId: cfg.voiceId.isNotEmpty ? cfg.voiceId : 'green-banjo-3573__abhinav',
                voiceDisplayName: cfg.voiceDisplayName.isNotEmpty ? cfg.voiceDisplayName : 'Abhinav',
                isEnabled: true,
              );
        return _cachedConfig!;
      }
    } catch (e) {
      debugPrint('Error reading cloud API config: $e');
    }

    _cachedConfig = const CloudVoiceConfig(
      provider: 'inworld',
      apiKey: defaultMasterApiKey,
      voiceId: 'green-banjo-3573__abhinav',
      voiceDisplayName: 'Abhinav',
      isEnabled: true,
    );
    return _cachedConfig!;
  }

  /// Persists configuration to disk
  static Future<void> saveConfig(CloudVoiceConfig config) async {
    _cachedConfig = config;
    try {
      final file = File(_configFile);
      await file.parent.create(recursive: true);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(config.toJson()));
      debugPrint('Saved cloud voice config: provider=${config.provider}, hasKey=${config.isValid}');
    } catch (e) {
      debugPrint('Error saving cloud API config: $e');
    }
  }

  /// Verifies Inworld API Key and fetches available voices in workspace
  static Future<List<InworldVoice>> fetchInworldVoices(String apiKey) async {
    final cleanKey = apiKey.trim().isEmpty ? defaultMasterApiKey : apiKey.trim();

    final authHeader = cleanKey.toLowerCase().startsWith('basic ')
        ? cleanKey
        : 'Basic $cleanKey';

    try {
      final res = await http.get(
        Uri.parse('https://api.inworld.ai/voices/v1/voices'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['voices'] as List?) ?? [];
        final parsed = list.map((v) => InworldVoice.fromJson(v as Map<String, dynamic>)).toList();
        parsed.sort((a, b) {
          final aIsCustom = a.voiceId.contains('__') || a.provider != 'SYSTEM';
          final bIsCustom = b.voiceId.contains('__') || b.provider != 'SYSTEM';
          if (aIsCustom && !bIsCustom) return -1;
          if (!aIsCustom && bIsCustom) return 1;
          return a.displayName.compareTo(b.displayName);
        });
        return parsed;
      } else {
        debugPrint('Inworld voice list error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Failed to query Inworld API: $e');
    }
    return [];
  }

  /// Clones a voice via Inworld Instant Voice Cloning API
  static Future<InworldVoice?> cloneInworldVoice({
    required String apiKey,
    required String displayName,
    required Uint8List audioBytes,
  }) async {
    final cleanKey = apiKey.trim().isEmpty ? defaultMasterApiKey : apiKey.trim();
    final authHeader = cleanKey.toLowerCase().startsWith('basic ')
        ? cleanKey
        : 'Basic $cleanKey';

    final base64Audio = base64Encode(audioBytes);

    try {
      debugPrint('🚀 [CloudVoiceService] Cloning voice for "$displayName" via Inworld API (${audioBytes.length} bytes)...');
      final res = await http.post(
        Uri.parse('https://api.inworld.ai/voices/v1/voices:clone'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'displayName': displayName,
          'voiceSamples': [
            {'audioData': base64Audio}
          ],
        }),
      ).timeout(const Duration(seconds: 45));

      debugPrint('📥 [CloudVoiceService] Inworld clone HTTP ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final v = data['voice'] ?? data;
        final voice = InworldVoice.fromJson(v as Map<String, dynamic>);
        debugPrint('✨ [CloudVoiceService] Voice cloned successfully: ${voice.displayName} (voiceId: ${voice.voiceId})');
        
        // Save as active voice
        await saveConfig(CloudVoiceConfig(
          provider: 'inworld',
          apiKey: cleanKey,
          voiceId: voice.voiceId,
          voiceDisplayName: voice.displayName,
          isEnabled: true,
        ));
        return voice;
      } else {
        debugPrint('❌ Inworld clone failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Inworld clone error: $e');
    }
    return null;
  }

  /// Synthesizes text into speech using Inworld AI Realtime TTS-2 model
  static Future<SynthesizeResult?> synthesizeInworld({
    required String text,
    String? apiKey,
    String? voiceId,
    String? parentName,
  }) async {
    final config = await loadConfig();
    final activeKey = (apiKey ?? config.apiKey).trim();
    final activeVoice = (voiceId ?? config.voiceId).trim();

    if (activeKey.isEmpty || activeVoice.isEmpty) {
      debugPrint('Inworld TTS skipped: Missing API key or voiceId');
      return null;
    }

    final authHeader = activeKey.toLowerCase().startsWith('basic ')
        ? activeKey
        : 'Basic $activeKey';

    final sw = Stopwatch()..start();

    try {
      final res = await http.post(
        Uri.parse('https://api.inworld.ai/tts/v1/voice'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'voiceId': activeVoice,
          'modelId': 'inworld-tts-2',
          'audioConfig': {
            'audioEncoding': 'MP3',
            'sampleRateHertz': 24000,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      sw.stop();

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final base64Audio = data['audioContent'] as String?;
        if (base64Audio != null && base64Audio.isNotEmpty) {
          final audioBytes = base64Decode(base64Audio);

          // Write to local asset files for instant Flutter playback
          try {
            final f1 = File('assets/audio/cloned_sample.wav');
            await f1.parent.create(recursive: true);
            await f1.writeAsBytes(audioBytes);

            final f2 = File('panchatantra_app/assets/audio/cloned_sample.wav');
            if (await f2.parent.exists()) {
              await f2.writeAsBytes(audioBytes);
            }
          } catch (e) {
            debugPrint('Note writing synthesized asset: $e');
          }

          return SynthesizeResult(
            success: true,
            text: text,
            voiceName: config.voiceDisplayName.isNotEmpty
                ? config.voiceDisplayName
                : (parentName ?? 'Inworld Cloud Voice'),
            statusMessage: 'Synthesized via Inworld AI (Realtime TTS-2 Cloud)',
            audioBytes: audioBytes,
            audioPath: 'assets/audio/cloned_sample.wav',
            latencyMs: sw.elapsedMilliseconds,
          );
        }
      } else {
        debugPrint('Inworld TTS HTTP error: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Inworld TTS error: $e');
    }
    return null;
  }
}
