import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/workout_engine.dart';
import '../../domain/body_engine/load_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import 'liquid_glass.dart';

/// Modal bottom sheet for logging workouts with live Karvonen 5-zone preview,
/// TRIMP cardiovascular strain, and recovery cost estimation.
class WorkoutLoggingModal extends StatefulWidget {
  final VoidCallback? onWorkoutLogged;

  const WorkoutLoggingModal({super.key, this.onWorkoutLogged});

  static Future<void> show(BuildContext context, {VoidCallback? onWorkoutLogged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkoutLoggingModal(onWorkoutLogged: onWorkoutLogged),
    );
  }

  @override
  State<WorkoutLoggingModal> createState() => _WorkoutLoggingModalState();
}

class _WorkoutLoggingModalState extends State<WorkoutLoggingModal> {
  SportCategory _selectedSport = SportCategory.running;
  final TextEditingController _titleController =
      TextEditingController(text: 'Morning Run');
  int _durationMinutes = 45;
  double _avgHeartRate = 145.0;
  double _maxHeartRate = 172.0;
  bool _isSaving = false;

  final WorkoutEngine _engine = const WorkoutEngine();

  WorkoutAnalysisResult _computePreview() {
    return _engine.analyze(
      WorkoutInput(
        sport: _selectedSport.key,
        title: _titleController.text.trim().isEmpty
            ? _selectedSport.displayName
            : _titleController.text.trim(),
        startTime: DateTime.now().subtract(Duration(minutes: _durationMinutes)),
        durationMinutes: _durationMinutes,
        avgHeartRate: _avgHeartRate,
        maxHeartRate: _maxHeartRate,
        restingHr: 58.0,
        maxHr: 190.0,
      ),
    );
  }

  Future<void> _saveWorkout() async {
    setState(() => _isSaving = true);
    try {
      final repo = sl<HealthSourceRepository>();
      final input = WorkoutInput(
        sport: _selectedSport.key,
        title: _titleController.text.trim().isEmpty
            ? _selectedSport.displayName
            : _titleController.text.trim(),
        startTime: DateTime.now().subtract(Duration(minutes: _durationMinutes)),
        durationMinutes: _durationMinutes,
        avgHeartRate: _avgHeartRate,
        maxHeartRate: _maxHeartRate,
        restingHr: 58.0,
        maxHr: 190.0,
      );

      await repo.logWorkout(input);
      widget.onWorkoutLogged?.call();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: RecovaColors.surfaceElevation3,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Tok.neonAccent),
            ),
            content: Text(
              '${_selectedSport.displayName} logged successfully',
              style: const TextStyle(color: RecovaColors.textPrimary),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _computePreview();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: RecovaColors.canvasBase,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: 24,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RecovaColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Header Title ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOG WORKOUT SESSION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: RecovaColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: RecovaColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Sport Category Selector Horizontal Scroll ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    SportCategory.running,
                    SportCategory.cycling,
                    SportCategory.strength,
                    SportCategory.hiit,
                    SportCategory.walking,
                    SportCategory.swimming,
                    SportCategory.recovery,
                  ].map((sport) {
                    final isSelected = _selectedSport == sport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSport = sport;
                            _titleController.text = sport.displayName;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Tok.neonAccent.withValues(alpha: 0.2)
                                : RecovaColors.surfaceElevation2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Tok.neonAccent
                                  : RecovaColors.borderSubtle,
                              width: isSelected ? 1.2 : 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSportIcon(sport),
                                size: 13,
                                color: isSelected
                                    ? Tok.neonAccent
                                    : RecovaColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                sport.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? RecovaColors.textPrimary
                                      : RecovaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // ── Title Input ──
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  color: RecovaColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  labelText: 'Session Title',
                  labelStyle: const TextStyle(
                      color: RecovaColors.textTertiary, fontSize: 11),
                  filled: true,
                  fillColor: RecovaColors.surfaceElevation2,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: RecovaColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: RecovaColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Tok.neonAccent),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Duration Slider (Minutes) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$_durationMinutes mins',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Tok.neonAccent,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _durationMinutes.toDouble(),
                min: 10,
                max: 180,
                divisions: 34,
                activeColor: Tok.neonAccent,
                inactiveColor: RecovaColors.surfaceElevation3,
                onChanged: (val) =>
                    setState(() => _durationMinutes = val.round()),
              ),

              // ── Average Heart Rate Slider ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Average Heart Rate',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_avgHeartRate.round()} bpm',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Tok.accentAmber,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _avgHeartRate,
                min: 90,
                max: 190,
                divisions: 20,
                activeColor: Tok.accentAmber,
                inactiveColor: RecovaColors.surfaceElevation3,
                onChanged: (val) {
                  setState(() {
                    _avgHeartRate = val;
                    if (_maxHeartRate < _avgHeartRate) {
                      _maxHeartRate = _avgHeartRate + 15;
                    }
                  });
                },
              ),

              // ── Live Scientific Engine Preview Card ──
              LiquidGlass(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                accentGlow: Tok.accentAmber,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ENGINE PHYSIOLOGY PREVIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Tok.accentAmber,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Tok.accentAmber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'STRAIN ${preview.strainScore.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Tok.accentAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Metrics row: Calories, TRIMP, Recovery Cost
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricChip(
                          label: 'EST. CALORIES',
                          value: '${preview.calories.round()} kcal',
                          icon: Icons.local_fire_department_rounded,
                          color: Tok.accentAmber,
                        ),
                        _buildMetricChip(
                          label: 'TRIMP LOAD',
                          value: preview.trimp.toStringAsFixed(1),
                          icon: Icons.bolt_rounded,
                          color: Tok.neonAccent,
                        ),
                        _buildMetricChip(
                          label: 'RECOVERY COST',
                          value: preview.recoveryCostLabel,
                          icon: Icons.timelapse_rounded,
                          color: Tok.accentBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5-Zone Distribution Bar
                    const Text(
                      'ESTIMATED KARVONEN HEART RATE ZONES',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildZoneDistributionBar(preview.zones, preview.durationMinutes),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Tok.neonAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveWorkout,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'SAVE WORKOUT TO LOCAL DB',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RecovaColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: RecovaColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneDistributionBar(HeartRateZoneBreakdown zones, int totalMins) {
    if (totalMins <= 0) return const SizedBox.shrink();

    final z1Flex = zones.zone1Minutes;
    final z2Flex = zones.zone2Minutes;
    final z3Flex = zones.zone3Minutes;
    final z4Flex = zones.zone4Minutes;
    final z5Flex = zones.zone5Minutes;
    final total = z1Flex + z2Flex + z3Flex + z4Flex + z5Flex;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (z1Flex > 0)
                  Expanded(
                    flex: z1Flex,
                    child: Container(color: Tok.neonAccent.withValues(alpha: 0.6)),
                  ),
                if (z2Flex > 0)
                  Expanded(
                    flex: z2Flex,
                    child: Container(color: Tok.accentBlue),
                  ),
                if (z3Flex > 0)
                  Expanded(
                    flex: z3Flex,
                    child: Container(color: Tok.accentAmber),
                  ),
                if (z4Flex > 0)
                  Expanded(
                    flex: z4Flex,
                    child: Container(color: const Color(0xFFFF6B00)),
                  ),
                if (z5Flex > 0)
                  Expanded(
                    flex: z5Flex,
                    child: Container(color: Tok.recoverySuppressed),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Z1: ${z1Flex}m', style: const TextStyle(fontSize: 8, color: RecovaColors.textTertiary)),
            Text('Z2: ${z2Flex}m', style: const TextStyle(fontSize: 8, color: RecovaColors.textTertiary)),
            Text('Z3: ${z3Flex}m', style: const TextStyle(fontSize: 8, color: RecovaColors.textTertiary)),
            Text('Z4: ${z4Flex}m', style: const TextStyle(fontSize: 8, color: RecovaColors.textTertiary)),
            Text('Z5: ${z5Flex}m', style: const TextStyle(fontSize: 8, color: RecovaColors.textTertiary)),
          ],
        ),
      ],
    );
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
