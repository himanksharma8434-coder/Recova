import 'dart:ui';
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
    final effectiveRadius = BorderRadius.circular(borderRadius);
    final fillColor = elevated ? Tok.glassFillElevated : Tok.glassFill;

    Widget card = Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          if (accentGlow != null)
            BoxShadow(
              color: accentGlow!,
              blurRadius: 24,
              spreadRadius: 1,
            ),
          // iOS dynamic drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // 1. True iPhone Backdrop Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: elevated ? Tok.glassBlurSigma : Tok.glassBlurSigmaLight,
                  sigmaY: elevated ? Tok.glassBlurSigma : Tok.glassBlurSigmaLight,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            // 2. Liquid Glass Fill & Specular Gradient Sheen
            Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: effectiveRadius,
                color: fillColor,
                border: Border.all(
                  color: elevated ? Tok.glassBorderBright : Tok.glassBorder,
                  width: 0.75,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: elevated ? 0.15 : 0.09),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.005),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                  stops: const [0.0, 0.35, 0.75, 1.0],
                ),
              ),
              child: child,
            ),

            // 3. Top Specular Rim Reflection (iPhone optical edge)
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              height: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

/// Lighter-weight glass card (less blur, less overhead) for items inside lists
/// or for secondary surfaces that don't need the full glass treatment.
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
    final effectiveRadius = BorderRadius.circular(borderRadius);

    Widget card = ClipRRect(
      borderRadius: effectiveRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: Tok.glassBlurSigmaLight,
                sigmaY: Tok.glassBlurSigmaLight,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              color: Tok.glassFillRecessed,
              border: Border.all(
                color: Tok.glassBorder.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
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
      customBottomReflection: accentColor?.withValues(alpha: 0.15),
      child: child,
    );
  }
}
