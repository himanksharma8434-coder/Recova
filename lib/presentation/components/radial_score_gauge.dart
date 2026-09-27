import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import 'liquid_glass.dart';

/// Signature Biometric Recovery Gauge
/// Glassmorphic concentric rings with neon accent glow,
/// bold % readout, vital pulsing indicator, and semantic status badge.
class RadialScoreGauge extends StatefulWidget {
  final double? score;
  final double size;
  final VoidCallback? onTap;

  const RadialScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.onTap,
  });

  @override
  State<RadialScoreGauge> createState() => _RadialScoreGaugeState();
}

class _RadialScoreGaugeState extends State<RadialScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveScore = widget.score ?? 0;
    final tier = RecoveryTier.fromScore(widget.score);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glass disc with neon glow
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * 0.72,
                  height: widget.size * 0.72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Tok.canvasDeep,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                      // Neon accent glow that pulses
                      if (widget.score != null)
                        BoxShadow(
                          color: tier.color.withValues(
                            alpha: 0.1 * _pulseAnimation.value,
                          ),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                );
              },
            ),

            // Custom Painter for gauge arcs
            RepaintBoundary(
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GlassGaugePainter(
                  score: effectiveScore,
                  accentColor: tier.color,
                ),
              ),
            ),

            // Inner Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RECOVERY',
                  style: TokType.sectionLabel.copyWith(
                    letterSpacing: 2.4,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: Tok.space2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.score != null ? '${effectiveScore.toInt()}' : '--',
                      style: TokType.displayNumber.copyWith(
                        fontSize: widget.size * 0.25,
                        color: tier == RecoveryTier.calibrating
                            ? Tok.textTertiary
                            : Tok.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '%',
                      style: TokType.unit.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Tok.space8),

                // Status Pill with pulsing dot
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return LiquidGlass(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Tok.space12,
                        vertical: Tok.space4,
                      ),
                      customBottomReflection: tier.color.withValues(alpha: 0.2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tier.color.withValues(
                                alpha: _pulseAnimation.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tier.color.withValues(
                                    alpha: _pulseAnimation.value * 0.5,
                                  ),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Tok.space6),
                          Flexible(
                            child: Text(
                              tier.statusSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TokType.caption.copyWith(
                                color: Tok.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (widget.onTap != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: Tok.space2,
                    ),
                    decoration: BoxDecoration(
                      color: Tok.glassFillRecessed,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: Tok.glassBorder.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HOW IT\'S CALCULATED',
                          style: TokType.caption.copyWith(
                            fontSize: 7,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          size: 9,
                          color: Tok.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassGaugePainter extends CustomPainter {
  final double score;
  final Color accentColor;

  _GlassGaugePainter({required this.score, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // 1. Subtle glass-like background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Dot matrix ring (60 dots)
    const totalDots = 60;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      final angle = (i * 2 * pi) / totalDots - (pi / 2);
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), 1.2, dotPaint);
    }

    // 3. Active score progress
    if (score > 0) {
      final activeDotsCount = ((score / 100) * totalDots).round();

      final activeDotPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < activeDotsCount; i++) {
        final angle = (i * 2 * pi) / totalDots - (pi / 2);
        final dotX = center.dx + radius * cos(angle);
        final dotY = center.dy + radius * sin(angle);
        canvas.drawCircle(Offset(dotX, dotY), 2.2, activeDotPaint);
      }

      // Inner continuous arc
      final sweepAngle = (score / 100) * 2 * pi;
      final innerArcPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -pi / 2,
        sweepAngle,
        false,
        innerArcPaint,
      );

      // Neon glow arc (drawn underneath)
      final glowArcPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -pi / 2,
        sweepAngle,
        false,
        glowArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.accentColor != accentColor;
  }
}
