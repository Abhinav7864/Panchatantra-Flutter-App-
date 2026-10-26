class VoiceProfile {
  final bool isEnrolled;
  final String parentName;
  final bool consentAccepted;
  final DateTime? consentTimestamp;
  final String voiceId;
  final String provider;
  final bool isAutoDeleteActive;
  final int autoDeleteDays;
  final bool isAIActive;
  final String encryptionStatus;
  final double sampleLengthSeconds;

  VoiceProfile({
    this.isEnrolled = true,
    this.parentName = 'Priya Sharma (Parent)',
    this.consentAccepted = true,
    DateTime? consentTimestamp,
    this.voiceId = 'VOICE_PAR_78912',
    this.provider = 'Private Sovereign Neural Voice',
    this.isAutoDeleteActive = true,
    this.autoDeleteDays = 30,
    this.isAIActive = true,
    this.encryptionStatus = 'AES-256 Bit Hardware Enclave',
    this.sampleLengthSeconds = 45.0,
  }) : consentTimestamp = consentTimestamp ?? DateTime.now();

  VoiceProfile copyWith({
    bool? isEnrolled,
    String? parentName,
    bool? consentAccepted,
    DateTime? consentTimestamp,
    String? voiceId,
    String? provider,
    bool? isAutoDeleteActive,
    int? autoDeleteDays,
    bool? isAIActive,
    String? encryptionStatus,
    double? sampleLengthSeconds,
  }) {
    return VoiceProfile(
      isEnrolled: isEnrolled ?? this.isEnrolled,
      parentName: parentName ?? this.parentName,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      voiceId: voiceId ?? this.voiceId,
      provider: provider ?? this.provider,
      isAutoDeleteActive: isAutoDeleteActive ?? this.isAutoDeleteActive,
      autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
      isAIActive: isAIActive ?? this.isAIActive,
      encryptionStatus: encryptionStatus ?? this.encryptionStatus,
      sampleLengthSeconds: sampleLengthSeconds ?? this.sampleLengthSeconds,
    );
  }
}
