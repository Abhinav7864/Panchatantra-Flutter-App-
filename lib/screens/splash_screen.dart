import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/kid_ui.dart';
import '../widgets/storybook_illustration.dart';
import 'onboarding_flow_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SkyBackground(
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final illustrationSize = (constraints.maxWidth * 0.86).clamp(270.0, 370.0);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                        _buildBrandPill(),
                        const SizedBox(height: 14),
                        const Spacer(),
                        Text(
                          'Learning with',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMedium.withValues(alpha: 0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Panchatantra',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.baloo2(
                            fontSize: 50,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            'Little fables. Big hearts. Brave minds.',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.headerPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        StorybookIllustration(size: illustrationSize),
                        const Spacer(),
                        PrimaryCta(
                          label: 'Start our story',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnboardingFlowScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainNavigationScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Explore as a guest',
                            style: GoogleFonts.nunito(
                              color: AppColors.headerPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          'Made for curious kids · Ages 4–10',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPill() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              'Panchatantra Kids',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.headerPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
