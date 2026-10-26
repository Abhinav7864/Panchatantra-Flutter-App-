import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/kid_ui.dart';
import '../widgets/radar_chart.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  late TextEditingController _nameController;
  int _age = 7;
  double _cognitiveComplexity = 2.8;
  double _emotionalResilience = 3.0;
  double _culturalLiteracy = 3.2;
  double _attentionSpan = 2.5;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    _nameController = TextEditingController(text: profile.childName);
    _age = profile.age;
    _cognitiveComplexity = profile.cognitiveComplexity;
    _emotionalResilience = profile.emotionalResilience;
    _culturalLiteracy = profile.culturalLiteracy;
    _attentionSpan = profile.attentionSpan;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 105,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KidPageHeader(
              title: canPop ? 'Child Profile' : 'My Profile',
              subtitle: 'Shape every fable around your learner',
              showBackButton: canPop,
              trailing: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text('🌟', style: TextStyle(fontSize: 21)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _ProfileHero(
                name: _nameController.text.isEmpty ? 'Your learner' : _nameController.text,
                age: _age,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: KidCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Child’s name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Eity or Aarav',
                        prefixIcon: Icon(
                          Icons.face_rounded,
                          color: AppColors.headerPrimary,
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    Row(
                      children: [
                        const _FieldLabel('Age'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_age years • ${_age <= 9 ? 'Band 4–9' : 'Band 9+'}',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentCyanDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _age.toDouble(),
                      min: 4,
                      max: 15,
                      divisions: 11,
                      label: '$_age',
                      onChanged: (value) => setState(() => _age = value.round()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: KidCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story tuning',
                      style: GoogleFonts.baloo2(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nudge the dials and stories reshape themselves.',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Tuner(
                      title: 'Vocabulary depth',
                      emoji: '💬',
                      value: _cognitiveComplexity,
                      left: 'Simple',
                      right: 'Rich',
                      color: AppColors.cardReading,
                      onChanged: (v) => setState(() => _cognitiveComplexity = v),
                    ),
                    _Tuner(
                      title: 'Emotional strength',
                      emoji: '💛',
                      value: _emotionalResilience,
                      left: 'Gentle',
                      right: 'Bold',
                      color: AppColors.cardNumbers,
                      onChanged: (v) => setState(() => _emotionalResilience = v),
                    ),
                    _Tuner(
                      title: 'Indian wisdom (IKS)',
                      emoji: '🌿',
                      value: _culturalLiteracy,
                      left: 'Light',
                      right: 'Deep',
                      color: AppColors.cardDrawing,
                      onChanged: (v) => setState(() => _culturalLiteracy = v),
                    ),
                    _Tuner(
                      title: 'Story length',
                      emoji: '⏳',
                      value: _attentionSpan,
                      left: 'Short',
                      right: 'Long',
                      color: AppColors.cardPuzzles,
                      onChanged: (v) => setState(() => _attentionSpan = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: KidCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      'Skill preview',
                      style: GoogleFonts.baloo2(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Where stories will meet your child',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EloRadarChart(
                      eloRatings: appState.profile.eloRatings,
                      size: 230,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryCta(
                label: 'Save & start exploring',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _save(context, appState, canPop),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context, AppState appState, bool canPop) {
    final band = _age <= 9 ? '4-9' : '9+';
    appState.updateProfile(
      name: _nameController.text.trim().isEmpty
          ? 'Eity'
          : _nameController.text.trim(),
      age: _age,
      ageBand: band,
      cognitiveComplexity: _cognitiveComplexity,
      emotionalResilience: _emotionalResilience,
      culturalLiteracy: _culturalLiteracy,
      attentionSpan: _attentionSpan,
    );

    if (canPop) {
      Navigator.pop(context);
    } else {
      appState.setTabIndex(0);
    }
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final int age;

  const _ProfileHero({required this.name, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7DA), Color(0xFFFFD2C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text('👧🏽', style: TextStyle(fontSize: 33)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.baloo2(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Age $age • Curious explorer',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🌱', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

class _Tuner extends StatelessWidget {
  final String title;
  final String emoji;
  final double value;
  final String left;
  final String right;
  final Color color;
  final ValueChanged<double> onChanged;

  const _Tuner({
    required this.title,
    required this.emoji,
    required this.value,
    required this.left,
    required this.right,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.12),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 8,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left,
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                right,
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
    );
  }
}
