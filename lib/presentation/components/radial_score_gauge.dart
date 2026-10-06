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
            // Static background glass disc
            Container(
              width: widget.size * 0.72,
              height: widget.size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Tok.canvasDeep,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            // Bioluminescent pulsing glow (isolated in RepaintBoundary)
            if (widget.score != null)
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) {
                    return Container(
                      width: widget.size * 0.72,
                      height: widget.size * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tier.color.withValues(
                              alpha: 0.20 * _pulseAnimation.value,
                            ),
                            blurRadius: 28,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
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

                // Status Pill
                LiquidGlass(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tok.space12,
                    vertical: Tok.space4,
                  ),
                  hasBlur: false,
                  customBottomReflection: tier.color.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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

    // 1. Subtle glass-like background track
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // 2. Active score progress
    if (score > 0) {
      final sweepAngle = (score / 100).clamp(0.0, 1.0) * 2 * pi;
      final arcRect = Rect.fromCircle(center: center, radius: radius - 6);

      // Neon glow arc (drawn underneath)
      final glowArcPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawArc(
        arcRect,
        -pi / 2,
        sweepAngle,
        false,
        glowArcPaint,
      );

      // Main vibrant arc
      final innerArcPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        arcRect,
        -pi / 2,
        sweepAngle,
        false,
        innerArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.accentColor != accentColor;
  }
}
