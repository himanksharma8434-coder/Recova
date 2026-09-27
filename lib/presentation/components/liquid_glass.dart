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
  final bool enableInteractiveScale;

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
    this.enableInteractiveScale = true,
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
        // Elevation drop shadow: 0 4px 24px rgba(0, 0, 0, 0.15)
        boxShadow: const [
          BoxShadow(
            color: Tok.liquidGlassOuterShadow,
            blurRadius: 24.0,
            spreadRadius: 0.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // 1. Backdrop Blur (16px)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: Tok.liquidGlassBlurSigma,
                  sigmaY: Tok.liquidGlassBlurSigma,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            // 2. Base Fill & Delicate Border:
            // Background: rgba(255, 255, 255, 0.08)
            // Border: 1px solid rgba(255, 255, 255, 0.25)
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Tok.liquidGlassFill,
                borderRadius: effectiveRadius,
                border: Border.all(
                  color: Tok.liquidGlassBorder,
                  width: 1.0,
                ),
              ),
              child: widget.child,
            ),

            // 3. Liquid Depth Inset Highlights:
            // - Crisp inner top highlight: inset 0 1px 1px rgba(255, 255, 255, 0.4)
            // - Subtle neon pink inner bottom shadow: inset 0 -1px 1px rgba(255, 0, 128, 0.1)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LiquidGlassInnerShadowPainter(
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
          duration: Tok.animFast,
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Painter that renders the dual inset shadows:
/// - Top specular edge: inset 0 1px 1px rgba(255, 255, 255, 0.4)
/// - Bottom liquid refraction: inset 0 -1px 1px rgba(255, 0, 128, 0.1)
class _LiquidGlassInnerShadowPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color topHighlightColor;
  final Color bottomReflectionColor;

  const _LiquidGlassInnerShadowPainter({
    required this.borderRadius,
    required this.topHighlightColor,
    required this.bottomReflectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final Rect rect = Offset.zero & size;
    final RRect rrect = borderRadius.toRRect(rect);

    // Confine all inner shadows strictly to the container bounds
    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Crisp inner top highlight (inset 0 1px 1px rgba(255, 255, 255, 0.4))
    _drawInsetShadow(
      canvas: canvas,
      rrect: rrect,
      color: topHighlightColor,
      offset: const Offset(0, 1),
      blurRadius: 1.0,
    );

    // 2. Subtle neon pink inner bottom reflection (inset 0 -1px 1px rgba(255, 0, 128, 0.1))
    _drawInsetShadow(
      canvas: canvas,
      rrect: rrect,
      color: bottomReflectionColor,
      offset: const Offset(0, -1),
      blurRadius: 1.0,
    );

    canvas.restore();
  }

  void _drawInsetShadow({
    required Canvas canvas,
    required RRect rrect,
    required Color color,
    required Offset offset,
    required double blurRadius,
  }) {
    if (color.a == 0) return;

    final Paint paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    // Create an expanded outer path that encloses the inner hole
    final Rect outerBounds = rrect.outerRect.inflate(12.0 + blurRadius);
    final Path outerPath = Path()..addRect(outerBounds);
    final Path innerPath = Path()..addRRect(rrect);
    final Path invertedShadowHole = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(invertedShadowHole, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassInnerShadowPainter oldDelegate) {
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

  const LiquidGlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      onTap: onTap,
      customBottomReflection: accentColor?.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space24,
        vertical: Tok.space16,
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
            style: TokType.cardTitle.copyWith(
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
