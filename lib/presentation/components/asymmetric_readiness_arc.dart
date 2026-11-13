import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/body_engine.dart';
import 'liquid_glass.dart';

bool get _isInTest =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Distinctive, non-circular Asymmetric Biometric Readiness Arc.
///
/// Replaces competitor circular dials with an original architectural visor arc,
/// bold percentage typography, semantic neon glow, confidence pill badges,
/// and live explainable driver chips.
class AsymmetricReadinessArc extends StatefulWidget {
  final double? score;
  final ReadinessConfidence confidence;
  final ReadinessTier tier;
  final int daysOfData;
  final String headline;
  final List<ReadinessDriver> topDrivers;
  final bool isHrvEstimated;
  final VoidCallback? onTap;

  const AsymmetricReadinessArc({
    super.key,
    required this.score,
    this.confidence = ReadinessConfidence.high,
    this.tier = ReadinessTier.optimal,
    this.daysOfData = 14,
    required this.headline,
    this.topDrivers = const [],
    this.isHrvEstimated = false,
    this.onTap,
  });

  @override
  State<AsymmetricReadinessArc> createState() => _AsymmetricReadinessArcState();
}

class _AsymmetricReadinessArcState extends State<AsymmetricReadinessArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (!_isInTest) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getTierColor() {
    if (widget.score == null) return Tok.accentAmber;
    if (widget.score! >= 67.0) return Tok.recoveryOptimal;
    if (widget.score! >= 34.0) return Tok.accentAmber;
    return Tok.recoverySuppressed;
  }

  String _getConfidenceLabel() {
    if (widget.daysOfData < 4) {
      return 'CALIBRATING • DAY ${widget.daysOfData}/3';
    }
    if (widget.daysOfData < 14) {
      return 'PROVISIONAL • DAY ${widget.daysOfData}/14';
    }
    if (widget.isHrvEstimated) {
      return 'ESTIMATED (NOCTURNAL PPG)';
    }
    return 'HIGH CONFIDENCE';
  }

  Color _getConfidenceColor() {
    if (widget.daysOfData < 4) return Tok.accentAmber;
    if (widget.daysOfData < 14) return Tok.accentBlue;
    if (widget.isHrvEstimated) return Tok.accentViolet;
    return Tok.recoveryOptimal;
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor();
    final confidenceColor = _getConfidenceColor();
    final confidenceLabel = _getConfidenceLabel();
    final isCalibrating = widget.daysOfData < 4 || widget.score == null;

    final effectiveScore = widget.score ?? 0.0;
    final animDuration =
        _isInTest ? Duration.zero : const Duration(milliseconds: 900);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(Tok.radiusLg),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Top Row: Section Tag & Confidence Badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: tierColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tierColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'READINESS',
                      style: TokType.sectionLabel.copyWith(
                        letterSpacing: 1.5,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: confidenceColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    confidenceLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Center Asymmetric Arc & Score Display ──
            SizedBox(
              height: 170,
              width: double.infinity,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: effectiveScore),
                duration: animDuration,
                curve: Curves.easeOutCubic,
                builder: (context, animatedScore, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Custom Asymmetric Arc Painter
                      CustomPaint(
                        size: const Size(double.infinity, 170),
                        painter: _AsymmetricArcPainter(
                          score: animatedScore,
                          tierColor: tierColor,
                          isCalibrating: isCalibrating,
                          calibrationProgress:
                              (widget.daysOfData / 3.0).clamp(0.0, 1.0),
                        ),
                      ),

                      // Central Readout
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCalibrating) ...[
                            const Icon(
                              Icons.hourglass_top_rounded,
                              size: 28,
                              color: Tok.accentAmber,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'CALIBRATING',
                              style: TokType.metricLarge.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Tok.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Night ${widget.daysOfData} of 3 collected',
                              style: TokType.caption.copyWith(
                                color: Tok.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ] else ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${animatedScore.round()}',
                                  style: TokType.metricLarge.copyWith(
                                    fontSize: 56,
                                    height: 1.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: Tok.textPrimary,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 2),
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: tierColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.headline.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: tierColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // ── Explainable Driver Chips (Top 2-3 biometric drivers) ──
            if (widget.topDrivers.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: widget.topDrivers.take(3).map((driver) {
                  final isPositive = driver.direction == 'positive';
                  final chipColor = isPositive ? Tok.recoveryOptimal : Tok.accentAmber;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: chipColor.withValues(alpha: 0.25),
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 11,
                          color: chipColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          driver.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Tok.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // ── Bottom Link: "Why this score?" Deep Dive Pill ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 13,
                  color: Tok.neonAccent.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Why this score? Tap for science breakdown',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Tok.neonAccent.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 9,
                  color: Tok.neonAccent.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering a sweeping architectural asymmetric status arc.
class _AsymmetricArcPainter extends CustomPainter {
  final double score;
  final Color tierColor;
  final bool isCalibrating;
  final double calibrationProgress;

  _AsymmetricArcPainter({
    required this.score,
    required this.tierColor,
    required this.isCalibrating,
    required this.calibrationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final radius = math.min(size.width * 0.42, 78.0);

    // Track arc: sweeping from 140 degrees to 40 degrees (260 degree arc)
    const startAngle = 140.0 * (math.pi / 180.0);
    const sweepTotal = 260.0 * (math.pi / 180.0);

    // 1. Background Track
    final trackPaint = Paint()
      ..color = RecovaColors.monochromeWhite.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // 2. Active Progress Arc
    final progressFraction = isCalibrating
        ? calibrationProgress
        : (score / 100.0).clamp(0.0, 1.0);
    final activeSweep = sweepTotal * progressFraction;

    if (activeSweep > 0.01) {
      // Glow shadow
      final glowPaint = Paint()
        ..color = tierColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        glowPaint,
      );

      // Core crisp gradient arc
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepTotal,
        colors: [
          tierColor.withValues(alpha: 0.6),
          tierColor,
        ],
      );

      final activePaint = Paint()
        ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );

      // Endpoint indicator pip
      final endAngle = startAngle + activeSweep;
      final pipCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final pipGlow = Paint()
        ..color = tierColor.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pipCenter, 6.0, pipGlow);

      final pipCore = Paint()..color = RecovaColors.monochromeWhite;
      canvas.drawCircle(pipCenter, 3.5, pipCore);
    }
  }

  @override
  bool shouldRepaint(covariant _AsymmetricArcPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.tierColor != tierColor ||
        oldDelegate.isCalibrating != isCalibrating ||
        oldDelegate.calibrationProgress != calibrationProgress;
  }
}
