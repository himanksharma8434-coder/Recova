import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'glass_card.dart';

class VitalMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String deltaText;
  final Color? deltaColor;
  final IconData? icon;
  final Color? iconColor;
  final Color? accentGlow;
  final VoidCallback? onTap;

  const VitalMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.deltaText,
    this.deltaColor,
    this.icon,
    this.iconColor,
    this.accentGlow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDeltaColor = deltaColor ?? Tok.textSecondary;

    return GlassCard(
      onTap: onTap,
      accentGlow: accentGlow,
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space10,
        vertical: Tok.space14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: iconColor ?? Tok.neonAccent),
                const SizedBox(width: Tok.space4),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TokType.caption.copyWith(
                    fontSize: 8.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: Tok.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TokType.metricMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: Tok.space2),
                Text(
                  unit,
                  style: TokType.unit.copyWith(
                    color: Tok.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Tok.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (effectiveDeltaColor == Tok.recoverySuppressed ||
                  effectiveDeltaColor == Tok.recoveryOptimal) ...[
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(right: Tok.space4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveDeltaColor,
                    boxShadow: [
                      BoxShadow(
                        color: effectiveDeltaColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
              Flexible(
                child: Text(
                  deltaText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TokType.caption.copyWith(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w500,
                    color: effectiveDeltaColor,
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
