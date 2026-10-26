import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'kid_ui.dart';

class GlossaryModal extends StatelessWidget {
  final String word;
  final String definition;

  const GlossaryModal({
    super.key,
    required this.word,
    required this.definition,
  });

  static void show(BuildContext context, String word, String definition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GlossaryModal(word: word, definition: definition),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.paddingOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.chipAmber,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text('💡', style: TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: GoogleFonts.baloo2(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'A golden word',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.chipPurple,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔊 Pronouncing “$word”'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.headerPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              definition,
              style: GoogleFonts.nunito(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryCta(
            label: 'Got it!',
            icon: Icons.check_rounded,
            height: 52,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
