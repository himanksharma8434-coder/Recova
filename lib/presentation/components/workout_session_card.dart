import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/workout_engine.dart';
import '../../domain/body_engine/load_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import 'liquid_glass.dart';

/// Card component displaying a workout session with strain, recovery cost,
/// and Karvonen zone distribution bar.
class WorkoutSessionCard extends StatelessWidget {
  final WorkoutSessionSummary workout;
  final VoidCallback? onTap;

  const WorkoutSessionCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = SportCategory.fromKey(workout.sport);
    final strain = workout.estimatedStrain;
    final recoveryCost = workout.effectiveRecoveryCost;

    final Color strainColor;
    if (strain >= 14.0) {
      strainColor = const Color(0xFFFF6B00);
    } else if (strain >= 9.0) {
      strainColor = Tok.accentAmber;
    } else {
      strainColor = Tok.neonAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(Tok.radiusMd),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Sport Icon, Title & Strain Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: strainColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: strainColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          _getSportIcon(cat),
                          size: 16,
                          color: strainColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: RecovaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${workout.formattedDuration} • ${_formatTime(workout.startTime)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: RecovaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Strain Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: strainColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: strainColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'STRAIN ${strain.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: strainColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Middle Row: Calories, Avg HR, Recovery Cost
              Row(
                children: [
                  if (workout.calories != null && workout.calories! > 0) ...[
                    _buildMetaPill(
                      icon: Icons.local_fire_department_rounded,
                      text: '${workout.calories!.round()} kcal',
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (workout.avgHeartRate != null && workout.avgHeartRate! > 0) ...[
                    _buildMetaPill(
                      icon: Icons.favorite_rounded,
                      text: '${workout.avgHeartRate!.round()} bpm avg',
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildMetaPill(
                    icon: Icons.timelapse_rounded,
                    text: '~${recoveryCost.round()}h recovery',
                  ),
                ],
              ),

              // Zone Distribution Bar if present
              if (workout.zones != null && workout.zones!.totalActiveMinutes > 0) ...[
                const SizedBox(height: 10),
                _buildMiniZoneBar(workout.zones!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RecovaColors.borderSubtle, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: RecovaColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: RecovaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniZoneBar(HeartRateZoneBreakdown zones) {
    final z1 = zones.zone1Minutes;
    final z2 = zones.zone2Minutes;
    final z3 = zones.zone3Minutes;
    final z4 = zones.zone4Minutes;
    final z5 = zones.zone5Minutes;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 4,
        child: Row(
          children: [
            if (z1 > 0)
              Expanded(
                flex: z1,
                child: Container(color: Tok.neonAccent.withValues(alpha: 0.6)),
              ),
            if (z2 > 0)
              Expanded(
                flex: z2,
                child: Container(color: Tok.accentBlue),
              ),
            if (z3 > 0)
              Expanded(
                flex: z3,
                child: Container(color: Tok.accentAmber),
              ),
            if (z4 > 0)
              Expanded(
                flex: z4,
                child: Container(color: const Color(0xFFFF6B00)),
              ),
            if (z5 > 0)
              Expanded(
                flex: z5,
                child: Container(color: Tok.recoverySuppressed),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _getSportIcon(SportCategory cat) {
    switch (cat) {
      case SportCategory.running:
        return Icons.directions_run_rounded;
      case SportCategory.cycling:
        return Icons.directions_bike_rounded;
      case SportCategory.swimming:
        return Icons.pool_rounded;
      case SportCategory.strength:
        return Icons.fitness_center_rounded;
      case SportCategory.hiit:
        return Icons.bolt_rounded;
      case SportCategory.walking:
        return Icons.directions_walk_rounded;
      case SportCategory.recovery:
        return Icons.self_improvement_rounded;
      default:
        return Icons.sports_rounded;
    }
  }
}
