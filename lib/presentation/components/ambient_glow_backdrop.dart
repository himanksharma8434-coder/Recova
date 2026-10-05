import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

/// Atmospheric Bioluminescent Ambient Backdrop.
/// Renders calibrated organic glow orbs across deep pitch OLED background.
/// Serves as the optical refraction source for all [LiquidGlass] and [GlassCard]
/// surfaces, making frosted glassmorphic blur and saturation genuinely come alive.
class AmbientGlowBackdrop extends StatelessWidget {
  final Color? primaryGlow;
  final Color? secondaryGlow;
  final Widget? child;

  const AmbientGlowBackdrop({
    super.key,
    this.primaryGlow,
    this.secondaryGlow,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrimary = primaryGlow ?? Tok.neonAccent;
    final effectiveSecondary = secondaryGlow ?? Tok.accentBlue;

    return Stack(
      children: [
        // 1. Deep OLED canvas base
        Positioned.fill(
          child: Container(
            color: const Color(0xFF08090C),
          ),
        ),

        // 2. High-performance atmospheric glow orbs
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _AmbientGlowPainter(
                  topColor: effectivePrimary,
                  midColor: effectiveSecondary,
                  bottomColor: Tok.accentAmber,
                ),
              ),
            ),
          ),
        ),

        // 3. Child content (e.g. scrollable screens)
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _AmbientGlowPainter extends CustomPainter {
  final Color topColor;
  final Color midColor;
  final Color bottomColor;

  const _AmbientGlowPainter({
    required this.topColor,
    required this.midColor,
    required this.bottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Orb 1: Upper central / top-left glow (Recovery / Pulse halo)
    final topCenter = Offset(size.width * 0.45, size.height * 0.16);
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          topColor.withValues(alpha: 0.14),
          topColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: topCenter, radius: size.width * 0.75));
    canvas.drawCircle(topCenter, size.width * 0.75, topPaint);

    // Orb 2: Mid-right restorative glow (Sleep Azure)
    final midCenter = Offset(size.width * 0.88, size.height * 0.48);
    final midPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          midColor.withValues(alpha: 0.12),
          midColor.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: midCenter, radius: size.width * 0.65));
    canvas.drawCircle(midCenter, size.width * 0.65, midPaint);

    // Orb 3: Lower-left kinetic glow (Strain / Activity Amber)
    final bottomCenter = Offset(size.width * 0.12, size.height * 0.78);
    final bottomPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          bottomColor.withValues(alpha: 0.10),
          bottomColor.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: bottomCenter, radius: size.width * 0.6));
    canvas.drawCircle(bottomCenter, size.width * 0.6, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.midColor != midColor ||
        oldDelegate.bottomColor != bottomColor;
  }
}
