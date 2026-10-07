import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple iOS material types matching Human Interface Guidelines (HIG).
enum IosGlassMaterial {
  /// Ultra-thin material for secondary controls and subtle overlays (sigma ~14).
  ultraThin(sigma: 14.0, darkAlpha: 0.22, lightAlpha: 0.30),

  /// Thin material for interactive buttons, nav pills, and toolbars (sigma ~20).
  thin(sigma: 20.0, darkAlpha: 0.32, lightAlpha: 0.48),

  /// Regular material for standard cards and major content pods (sigma ~28).
  regular(sigma: 28.0, darkAlpha: 0.45, lightAlpha: 0.68),

  /// Thick material for elevated modals, sheets, and dense backgrounds (sigma ~40).
  thick(sigma: 40.0, darkAlpha: 0.62, lightAlpha: 0.85);

  final double sigma;
  final double darkAlpha;
  final double lightAlpha;

  const IosGlassMaterial({
    required this.sigma,
    required this.darkAlpha,
    required this.lightAlpha,
  });
}

/// Pixel-accurate Apple iOS Glass Material (Frosted Glass).
///
/// Implements all 6 anatomy layers:
/// - Layer 1: Backdrop blur with TileMode.clamp
/// - Layer 2: 1.7× saturation boost ColorFilter matrix composed with blur
/// - Layer 3: Dynamic luminosity tint overlay (separate light/dark values)
/// - Layer 4: Specular hairline gradient border + soft glossy top rim
/// - Layer 5: Two-tier soft drop shadow outside the clip
/// - Layer 6: Native continuous corner shape (squircle via RoundedSuperellipseBorder)
class IosGlass extends StatefulWidget {
  final Widget child;
  final IosGlassMaterial material;
  final dynamic borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? accentGlow;
  final Color? customBottomReflection;
  final bool hasBlur;
  final bool enableInteractiveScale;
  final Brightness? brightness;

  const IosGlass({
    super.key,
    required this.child,
    this.material = IosGlassMaterial.regular,
    this.borderRadius = 16.0,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.width,
    this.height,
    this.accentGlow,
    this.customBottomReflection,
    this.hasBlur = true,
    this.enableInteractiveScale = true,
    this.brightness,
  });

  @override
  State<IosGlass> createState() => _IosGlassState();
}

class _IosGlassState extends State<IosGlass> {
  bool _isPressed = false;

  BorderRadius get _effectiveBorderRadius {
    final br = widget.borderRadius;
    if (br is BorderRadius) return br;
    if (br is num) return BorderRadius.circular(br.toDouble());
    return BorderRadius.circular(16.0);
  }

  /// Generates the standard Apple 1.7× color saturation matrix.
  static List<double> _saturationMatrix(double s) {
    final inv = 1.0 - s;
    final r = 0.2126 * inv;
    final g = 0.7152 * inv;
    final b = 0.0722 * inv;
    return <double>[
      r + s, g,     b,     0, 0,
      r,     g + s, b,     0, 0,
      r,     g,     b + s, 0, 0,
      0,     0,     0,     1, 0,
    ];
  }

  /// Composes backdrop blur with saturation boost filter.
  ImageFilter _buildBackdropFilter() {
    final blur = ImageFilter.blur(
      sigmaX: widget.material.sigma,
      sigmaY: widget.material.sigma,
      tileMode: TileMode.clamp,
    );
    // Compose with 1.7x saturation boost matrix
    return ImageFilter.compose(
      outer: ColorFilter.matrix(_saturationMatrix(1.7)),
      inner: blur,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = (widget.brightness ?? Theme.of(context).brightness) == Brightness.dark;
    final isReduceTransparency = MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;

    final effectiveRadius = _effectiveBorderRadius;
    // Squircle shape matching continuous iOS corner geometry
    final squircleShape = RoundedSuperellipseBorder(
      borderRadius: effectiveRadius,
    );
    final highlightHeight = (effectiveRadius.topLeft.x * 1.5).clamp(12.0, 48.0);

    // Tint colors derived from Apple HIG system materials
    final tintColor = isDark
        ? Color.fromRGBO(38, 38, 44, widget.material.darkAlpha)
        : Color.fromRGBO(255, 255, 255, widget.material.lightAlpha);

    // Layer 5 — Drop Shadow (Outside Clip)
    Widget glassContainer = Container(
      width: widget.width,
      height: widget.height,
      decoration: ShapeDecoration(
        shape: squircleShape,
        shadows: [
          if (widget.accentGlow != null)
            BoxShadow(
              color: widget.accentGlow!.withValues(alpha: 0.35),
              blurRadius: 20.0,
              spreadRadius: 0.5,
            ),
          // Soft ambient drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          // Directional contact shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipPath.shape(
        shape: squircleShape,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Layer 1 & 2 — Backdrop Blur + Saturation Matrix (if blur enabled & transparency not reduced)
            if (widget.hasBlur && !isReduceTransparency)
              Positioned.fill(
                child: BackdropFilter(
                  filter: _buildBackdropFilter(),
                  child: const SizedBox.shrink(),
                ),
              ),

            // Layer 3 — Tint & Luminosity Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isReduceTransparency
                      ? (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7))
                      : tintColor,
                ),
              ),
            ),

            // Layer 4 — Specular Top Rim Highlight (soft gloss gradient)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: highlightHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.10 : 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Optional subtle custom bottom reflection (e.g. accent / neon tint)
            if (widget.customBottomReflection != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: highlightHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        widget.customBottomReflection!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Layer 4 — Specular Hairline Border (0.5px gradient stroke)
            Positioned.fill(
              child: CustomPaint(
                painter: _IosHairlineBorderPainter(
                  shape: squircleShape,
                  isDark: isDark,
                ),
              ),
            ),

            // Press state flash / dimming feedback
            if (_isPressed)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.12),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ],
        ),
      ),
    );

    // Interactive scale motion response (iOS Spring curve)
    if (widget.onTap != null && widget.enableInteractiveScale) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: glassContainer,
        ),
      );
    } else if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: glassContainer,
      );
    }

    return glassContainer;
  }
}

/// Custom painter for true 0.5px hairline gradient edge matching iOS light falloff.
class _IosHairlineBorderPainter extends CustomPainter {
  final RoundedSuperellipseBorder shape;
  final bool isDark;

  const _IosHairlineBorderPainter({
    required this.shape,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.24 : 0.42),
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.16),
          Colors.white.withValues(alpha: isDark ? 0.03 : 0.06),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IosHairlineBorderPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.isDark != isDark;
  }
}
