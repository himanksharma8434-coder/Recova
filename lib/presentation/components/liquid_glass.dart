import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'ios_glass.dart';

export 'ios_glass.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LIQUID GLASSMORPHISM ELEMENT (Apple iOS Material Frosted Glass)
// Backed canonically by IosGlass:
// 1. Single-pass TileMode.clamp Backdrop Blur
// 2. 1.7× Saturation boost ColorFilter matrix
// 3. Apple HIG Dark/Light luminosity tint overlay
// 4. 0.5px specular hairline border gradient + glossy rim
// 5. Ambient & contact drop shadows outside clip
// 6. Native squircle continuous curvature (RoundedSuperellipseBorder)
// ═══════════════════════════════════════════════════════════════════════════════

/// Universal Liquid Glass container widget.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? customBottomReflection;
  final Color? accentGlow;
  final bool enableInteractiveScale;
  final bool hasBlur;
  final IosGlassMaterial material;

  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Tok.space20,
      vertical: Tok.space12,
    ),
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.customBottomReflection,
    this.accentGlow,
    this.enableInteractiveScale = true,
    this.hasBlur = true,
    this.material = IosGlassMaterial.regular,
  });

  @override
  Widget build(BuildContext context) {
    return IosGlass(
      material: material,
      borderRadius: borderRadius ?? BorderRadius.circular(Tok.liquidGlassRadiusPill),
      padding: padding,
      width: width,
      height: height,
      onTap: onTap,
      accentGlow: accentGlow,
      customBottomReflection: customBottomReflection,
      hasBlur: hasBlur,
      enableInteractiveScale: enableInteractiveScale,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPECIALIZED LIQUID GLASS PILL COMPONENT
// Ready-to-use capsule for status badges, metric indicators, and action pills.
// ═══════════════════════════════════════════════════════════════════════════════

class LiquidGlassPill extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Widget? trailing;
  final Color? indicatorColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final IosGlassMaterial material;

  const LiquidGlassPill({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.indicatorColor,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Tok.space16,
      vertical: Tok.space8,
    ),
    this.material = IosGlassMaterial.ultraThin,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: padding,
      hasBlur: false,
      material: material,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (indicatorColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: indicatorColor!.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Tok.space8),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: Tok.space8),
          ],
          Text(
            label,
            style: TokType.badge.copyWith(
              color: Tok.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Tok.space8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPECIALIZED LIQUID GLASS BUTTON
// Tactile, pressable CTA pill with liquid glass styling and subtle glow.
// ═══════════════════════════════════════════════════════════════════════════════

class LiquidGlassButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onTap;
  final Color? accentColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final bool hasBlur;
  final IosGlassMaterial material;

  const LiquidGlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.hasBlur = true,
    this.material = IosGlassMaterial.thin,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      width: width,
      height: height,
      onTap: onTap,
      material: material,
      borderRadius: borderRadius ?? BorderRadius.circular(Tok.radiusFull),
      hasBlur: hasBlur,
      accentGlow: accentColor?.withValues(alpha: 0.25),
      customBottomReflection: accentColor?.withValues(alpha: 0.25),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Tok.space24,
            vertical: Tok.space14,
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: Tok.space8),
          ],
          Text(
            label,
            style: textStyle ??
                TokType.cardTitle.copyWith(
                  color: Tok.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
