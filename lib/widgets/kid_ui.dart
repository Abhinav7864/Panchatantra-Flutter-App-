import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// A reusable violet page header with a soft curved base.
class KidPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double bottomPadding;

  const KidPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBackButton = false,
    this.onBack,
    this.bottomPadding = 26,
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
          left: 20,
          right: 20,
          bottom: bottomPadding,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -18,
              top: -34,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 58,
              bottom: -46,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBackButton) ...[
                  _SoftCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack ?? () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SoftCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

/// Rounded white icon container used across headers and cards.
class SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? background;
  final Color? color;
  final double size;
  final double iconSize;
  final bool badge;

  const SoftIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background,
    this.color,
    this.size = 44,
    this.iconSize = 22,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color ?? Colors.white, size: iconSize),
              if (badge)
                Positioned(
                  top: size * 0.25,
                  right: size * 0.25,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bold candy-colored CTA with a small depth shadow.
class PrimaryCta extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double height;
  final bool expand;

  const PrimaryCta({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.height = 56,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.cyanGradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: (gradient != null ? AppColors.accentCyan : backgroundColor ?? AppColors.accentCyan)
                .withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 9),
                  Icon(icon, color: Colors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A light surface card with the friendly large corner radius used throughout.
class KidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final double radius;
  final Border? border;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;

  const KidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = Colors.white,
    this.gradient,
    this.radius = 26,
    this.border,
    this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadow ??
            [
              BoxShadow(
                color: AppColors.headerDark.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// White rounded search field used in the purple hero header.
class HeroSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hint;

  const HeroSearchField({
    super.key,
    this.onChanged,
    this.hint = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C0D2A).withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.nunito(
          color: AppColors.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textDark,
            size: 23,
          ),
        ),
      ),
    );
  }
}

/// A slim progress track used for story and quiz progress.
class CandyProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color? background;
  final double height;

  const CandyProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.headerPrimary,
    this.background,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: background ?? AppColors.chipPurple,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Small pill used for story metadata.
class MetaPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;

  const MetaPill({
    super.key,
    required this.label,
    this.icon,
    this.foreground = AppColors.headerPrimary,
    this.background = AppColors.chipPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
