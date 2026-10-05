import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'liquid_glass.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// GLASS CARD — Reusable Glassmorphic Surface Widget
// Apple Liquid Glass inspired: translucent fill, backdrop blur, specular edge
// highlight, faint outer glow. Single implementation used across all screens.
// ═══════════════════════════════════════════════════════════════════════════════

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentGlow;         // Optional neon glow for focal cards
  final bool elevated;             // Use elevated glass fill
  final VoidCallback? onTap;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Tok.space16),
    this.borderRadius = Tok.radiusMd,
    this.accentGlow,
    this.elevated = false,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(borderRadius),
      padding: padding,
      width: width,
      onTap: onTap,
      accentGlow: accentGlow,
      enableInteractiveScale: onTap != null,
      child: child,
    );
  }
}

/// Lighter-weight glass card for items inside lists or secondary surfaces.
class GlassCardLight extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCardLight({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Tok.space12),
    this.borderRadius = Tok.radiusSm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(borderRadius),
      padding: padding,
      onTap: onTap,
      enableInteractiveScale: onTap != null,
      child: child,
    );
  }
}

/// Glass Pill — for status badges, tags, and filter chips.
/// Powered by the strict Liquid Glassmorphism Standard:
/// - Base: rgba(255, 255, 255, 0.08)
/// - Blur: 16px, saturation: 180%
/// - Elevation shadow: 0 4px 24px rgba(0, 0, 0, 0.15)
/// - Dual Insets: top white highlight + bottom neon-pink liquid reflection
/// - Outer border: 1px solid rgba(255, 255, 255, 0.25)
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const GlassPill({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: padding,
      hasBlur: false,
      customBottomReflection: accentColor?.withValues(alpha: 0.15),
      child: child,
    );
  }
}
