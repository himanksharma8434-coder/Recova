import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'glass_card.dart';

class EcgWaveformCard extends StatelessWidget {
  final double? restingHr;
  final double? respirationRate;

  const EcgWaveformCard({
    super.key,
    this.restingHr,
    this.respirationRate,
  });

  @override
  Widget build(BuildContext context) {
    final hasHr = restingHr != null && restingHr! > 0;
    final hrText = hasHr ? '${restingHr!.toInt()}' : '--';

    final hasRpm = respirationRate != null && respirationRate! > 0;
    final rpmText = hasRpm ? respirationRate!.toStringAsFixed(1) : '--';

    return GlassCard(
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BIOMETRIC TELEMETRY',
                style: TokType.caption.copyWith(letterSpacing: 1.2),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasHr ? Tok.neonAccent : Tok.textSecondary,
                      boxShadow: hasHr
                          ? [
                              BoxShadow(
                                color: Tok.neonAccent.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    hasHr ? 'HEALTH CONNECT LIVE' : 'SENSOR STANDBY',
                    style: TokType.caption.copyWith(
                      color: Tok.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),

          // Vascular HR with Waveform
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Tok.glassFillRecessed,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: hasHr
                            ? Tok.glassBorderBright
                            : Tok.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(Icons.favorite_outline,
                        size: 15,
                        color: hasHr ? Tok.neonAccent : Tok.textSecondary),
                  ),
                  const SizedBox(width: Tok.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(hrText,
                              style: TokType.metricMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: Tok.space4),
                          Text('BPM', style: TokType.unit.copyWith(fontSize: 9)),
                        ],
                      ),
                      Text(
                        hasHr ? 'RESTING VASCULAR' : 'NO PULSE LOGGED',
                        style: TokType.caption.copyWith(
                          fontSize: 8,
                          color: Tok.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // ECG Sparkline
              SizedBox(
                width: 110,
                height: 28,
                child: CustomPaint(
                  painter: _EcgSparklinePainter(active: hasHr),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),
          Divider(height: 1, color: Tok.glassBorder),
          const SizedBox(height: Tok.space12),

          // Respiration Cycle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Tok.glassFillRecessed,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: Tok.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(Icons.air,
                        size: 15,
                        color: hasRpm ? Tok.accentBlue : Tok.textSecondary),
                  ),
                  const SizedBox(width: Tok.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(rpmText,
                              style: TokType.metricMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: Tok.space4),
                          Text('RPM', style: TokType.unit.copyWith(fontSize: 9)),
                        ],
                      ),
                      Text(
                        hasRpm ? 'RESPIRATION CYCLE' : 'NO RESPIRATION LOGGED',
                        style: TokType.caption.copyWith(
                          fontSize: 8,
                          color: Tok.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GlassPill(
                accentColor: hasRpm ? Tok.accentBlue : null,
                child: Text(
                  hasRpm ? 'IN RANGE' : 'AWAITING SYNC',
                  style: TokType.badge.copyWith(
                    color: hasRpm ? Tok.textPrimary : Tok.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EcgSparklinePainter extends CustomPainter {
  final bool active;

  _EcgSparklinePainter({this.active = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active
          ? Tok.neonAccent
          : Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;

    if (!active) {
      path.moveTo(0, midY);
      path.lineTo(size.width, midY);
      canvas.drawPath(path, paint);
      return;
    }

    path.moveTo(0, midY);
    path.lineTo(size.width * 0.25, midY);
    path.lineTo(size.width * 0.32, midY - 3);
    path.lineTo(size.width * 0.38, midY);
    path.lineTo(size.width * 0.45, midY + 2);
    path.lineTo(size.width * 0.52, 2);
    path.lineTo(size.width * 0.58, size.height - 2);
    path.lineTo(size.width * 0.65, midY);
    path.lineTo(size.width * 0.75, midY - 4);
    path.lineTo(size.width * 0.82, midY);
    path.lineTo(size.width, midY);

    canvas.drawPath(path, paint);

    // Glow effect for the ECG line when active
    final glowPaint = Paint()
      ..color = Tok.neonAccent.withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgSparklinePainter oldDelegate) =>
      oldDelegate.active != active;
}
