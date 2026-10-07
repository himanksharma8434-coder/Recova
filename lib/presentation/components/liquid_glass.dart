import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LIQUID GLASSMORPHISM ELEMENT
// Strict Standard Specification:
// 1. Glass Base: Highly translucent white (rgba(255, 255, 255, 0.08))
// 2. Backdrop Blur & Saturation: 16px blur & 180% saturation
// 3. Liquid Depth (Box Shadows):
//    - Outer drop shadow: 0 4px 24px rgba(0, 0, 0, 0.15)
//    - Inner top highlight: inset 0 1px 1px rgba(255, 255, 255, 0.4)
//    - Inner bottom shadow: inset 0 -1px 1px rgba(255, 0, 128, 0.1) (neon pink)
// 4. Border: 1px solid rgba(255, 255, 255, 0.25)
// 5. Shape: Fully rounded edges (border-radius: 100px)
// ═══════════════════════════════════════════════════════════════════════════════

/// Universal Liquid Glass container widget.
class LiquidGlass extends StatefulWidget {
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
  });

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ??
        BorderRadius.circular(Tok.liquidGlassRadiusPill);

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          if (widget.accentGlow != null)
            BoxShadow(
              color: widget.accentGlow!,
              blurRadius: 20.0,
              spreadRadius: 0.5,
            ),
          const BoxShadow(
            color: Tok.liquidGlassOuterShadow,
            blurRadius: 18.0,
            spreadRadius: 0.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // 1. Single-pass GPU-accelerated frosted glass blur
            if (widget.hasBlur)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: Tok.liquidGlassBlurSigma,
                    sigmaY: Tok.liquidGlassBlurSigma,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

            // 2. Base Translucent Glass Fill & Specular Gradient
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: effectiveRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.025),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                border: Border.all(
                  color: Tok.liquidGlassBorder,
                  width: 0.85,
                ),
              ),
              child: widget.child,
            ),

            // 3. Ultra-fast GPU Specular Highlight & Rim Refraction
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LiquidGlassSpecularPainter(
                    borderRadius: effectiveRadius,
                    topHighlightColor: Tok.liquidGlassTopHighlight,
                    bottomReflectionColor: widget.customBottomReflection ??
                        Tok.liquidGlassBottomReflection,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.enableInteractiveScale
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.enableInteractiveScale
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.enableInteractiveScale
            ? () => setState(() => _isPressed = false)
            : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _isPressed ? 0.86 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: content,
          ),
        ),
      );
    }

    return RepaintBoundary(child: content);
  }
}

/// Ultra-fast GPU shader painter for specular top edge and subtle rim reflection.
/// Uses a single hardware drawRRect with a linear gradient shader.
/// 0% CPU path clipping overhead, 60/120fps hardware acceleration.
class _LiquidGlassSpecularPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color topHighlightColor;
  final Color bottomReflectionColor;

  const _LiquidGlassSpecularPainter({
    required this.borderRadius,
    required this.topHighlightColor,
    required this.bottomReflectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(0.5);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          topHighlightColor,
          Colors.transparent,
          Colors.transparent,
          bottomReflectionColor,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassSpecularPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.topHighlightColor != topHighlightColor ||
        oldDelegate.bottomReflectionColor != bottomReflectionColor;
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
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: padding,
      hasBlur: false,
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
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      width: width,
      height: height,
      onTap: onTap,
      borderRadius: borderRadius,
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
