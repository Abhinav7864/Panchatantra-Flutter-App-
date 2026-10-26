import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'kid_ui.dart';

class CustomHeader extends StatelessWidget {
  final String childName;
  final String progressSubtitle;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final Widget? footer;

  const CustomHeader({
    super.key,
    required this.childName,
    this.progressSubtitle = 'Progress • Level 3',
    this.onSearchChanged,
    this.onNotificationTap,
    this.onAvatarTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 12,
          bottom: 24,
          left: 20,
          right: 20,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft atmosphere dots.
            Positioned(
              right: -42,
              top: -36,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: 120,
              bottom: -56,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('👧🏽', style: TextStyle(fontSize: 29)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $childName',
                            style: GoogleFonts.baloo2(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  progressSubtitle,
                                  style: GoogleFonts.nunito(
                                    color: Colors.white.withValues(alpha: 0.76),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SoftIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotificationTap,
                      size: 46,
                      badge: true,
                      background: Colors.white.withValues(alpha: 0.16),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                HeroSearchField(
                  onChanged: onSearchChanged,
                  hint: 'Search stories, morals, animals...',
                ),
                if (footer != null) ...[
                  const SizedBox(height: 20),
                  footer!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
