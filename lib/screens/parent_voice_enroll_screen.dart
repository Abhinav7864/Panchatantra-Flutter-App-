import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import 'child_profile_screen.dart';

class ParentVoiceEnrollScreen extends StatefulWidget {
  const ParentVoiceEnrollScreen({super.key});

  @override
  State<ParentVoiceEnrollScreen> createState() => _ParentVoiceEnrollScreenState();
}

class _ParentVoiceEnrollScreenState extends State<ParentVoiceEnrollScreen> {
  bool _isRecording = false;
  double _recordProgress = 0.0;
  Timer? _timer;
  bool _autoDelete = true;
  final TextEditingController _nameController =
      TextEditingController(text: 'Priya Sharma');

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordProgress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _recordProgress += 0.02;
        if (_recordProgress >= 1.0) {
          _recordProgress = 1.0;
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KidPageHeader(
              title: 'Parent Voice',
              subtitle: 'A bedtime storyteller who sounds like you',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.chipGreen,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.success,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safe, private, yours',
                                style: GoogleFonts.nunito(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF22663C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Encrypted on this device. Never used to clone a child’s voice.',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3D7A55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  KidCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your name',
                          style: GoogleFonts.nunito(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.headerPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Read this little passage',
                          style: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Read it naturally, like you are tucking someone in.',
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.chipBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '“Once upon a time, in a lush green forest by a shimmering lake, lived a wise old elephant who knew all the secrets of the woods. Come close, my dear, and listen to what the animals taught us today...”',
                            style: GoogleFonts.nunito(
                              fontSize: 13.5,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: _RecordingWave(active: _isRecording),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: GestureDetector(
                            onTapDown: (_) => _startRecording(),
                            onTapUp: (_) => _stopRecording(),
                            onTapCancel: _stopRecording,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: _recordProgress,
                                    strokeWidth: 4,
                                    backgroundColor: AppColors.chipPurple,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.accentCyan,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    gradient: _isRecording
                                        ? AppColors.readingGradient
                                        : AppColors.headerGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.headerPrimary
                                            .withValues(alpha: 0.28),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRecording
                                        ? Icons.mic_rounded
                                        : Icons.mic_none_rounded,
                                    color: Colors.white,
                                    size: 31,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _isRecording
                                ? 'Listening... ${(_recordProgress * 100).toInt()}%'
                                : (_recordProgress > 0
                                    ? 'Sample captured!'
                                    : 'Press and hold to record'),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _isRecording
                                  ? AppColors.cardReading
                                  : AppColors.textMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.headerPrimary,
                            title: Text(
                              'Auto-delete my sample',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                color: AppColors.textDark,
                              ),
                            ),
                            subtitle: Text(
                              'Keeps only the acoustic weights on this device.',
                              style: GoogleFonts.nunito(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            value: _autoDelete,
                            onChanged: (value) =>
                                setState(() => _autoDelete = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryCta(
                    label: 'Save & set up my child',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      context.read<AppState>().enrollParentVoice(
                            parentName: _nameController.text.trim(),
                            sampleDuration: 30.0,
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChildProfileScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip · use the studio narrator',
                        style: GoogleFonts.nunito(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingWave extends StatelessWidget {
  final bool active;

  const _RecordingWave({required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(24, (index) {
          final height = active
              ? 9.0 + ((index % 5) * 7.0) * (index.isEven ? 1.1 : 0.8)
              : 5.0 + (index % 3) * 2;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2.4),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accentCyan
                  : AppColors.headerPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
