import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';

/// Activity categories for classifying workouts and athletic sessions.
enum ActivityCategory {
  all('All', Icons.grid_view_rounded, Color(0xFFFFFFFF)),
  cardio('Cardio', Icons.directions_run_rounded, Color(0xFFFF6B00)),
  strength('Strength', Icons.fitness_center_rounded, Color(0xFF8B5CF6)),
  hiit('HIIT', Icons.bolt_rounded, Color(0xFFFFB800)),
  recovery('Recovery', Icons.self_improvement_rounded, Color(0xFF00F090)),
  sports('Sports', Icons.sports_basketball_rounded, Color(0xFF00D2FF)),
  general('Other', Icons.sports_rounded, Color(0xFFAEAEB2));

  final String label;
  final IconData icon;
  final Color color;

  const ActivityCategory(this.label, this.icon, this.color);
}

/// Helper for categorizing and formatting activity names.
class ActivityCategoryHelper {
  static ActivityCategory resolve(String rawTitle) {
    final t = rawTitle.toLowerCase();
    if (t.contains('run') ||
        t.contains('jog') ||
        t.contains('walk') ||
        t.contains('cycl') ||
        t.contains('bik') ||
        t.contains('swim') ||
        t.contains('row') ||
        t.contains('elliptical') ||
        t.contains('hik') ||
        t.contains('cardio') ||
        t.contains('treadmill')) {
      return ActivityCategory.cardio;
    }
    if (t.contains('strength') ||
        t.contains('weight') ||
        t.contains('lift') ||
        t.contains('bodyweight') ||
        t.contains('calisthenic') ||
        t.contains('gym') ||
        t.contains('resistance') ||
        t.contains('bench') ||
        t.contains('squat')) {
      return ActivityCategory.strength;
    }
    if (t.contains('hiit') ||
        t.contains('interval') ||
        t.contains('circuit') ||
        t.contains('crossfit') ||
        t.contains('tabata') ||
        t.contains('aerobic') ||
        t.contains('bootcamp') ||
        t.contains('sprint')) {
      return ActivityCategory.hiit;
    }
    if (t.contains('yoga') ||
        t.contains('pilates') ||
        t.contains('stretch') ||
        t.contains('flex') ||
        t.contains('breath') ||
        t.contains('meditat') ||
        t.contains('cool_down') ||
        t.contains('warm_up') ||
        t.contains('mobility')) {
      return ActivityCategory.recovery;
    }
    if (t.contains('ball') ||
        t.contains('soccer') ||
        t.contains('tennis') ||
        t.contains('badminton') ||
        t.contains('box') ||
        t.contains('martial') ||
        t.contains('sport') ||
        t.contains('dance') ||
        t.contains('padel') ||
        t.contains('climb') ||
        t.contains('mma') ||
        t.contains('karate')) {
      return ActivityCategory.sports;
    }
    return ActivityCategory.general;
  }

  static String formatTitle(String rawTitle) {
    if (rawTitle.isEmpty) return 'Workout Session';
    final cleaned = rawTitle.replaceAll('_', ' ').toLowerCase();
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

/// Enhanced, liquid-glass Strain & Workout Activity Screen.
/// Provides 5-second instant comprehension, 7-day historical strain,
/// category filtering, and complete activity exploration.
class StrainScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;

  const StrainScreen({
    super.key,
    this.summary,
  });

  @override
  State<StrainScreen> createState() => _StrainScreenState();
}

class _StrainScreenState extends State<StrainScreen> {
  // 0 = Today, 1 = Past 7 Days
  int _timeHorizonIndex = 0;
  ActivityCategory _selectedCategory = ActivityCategory.all;
  int? _selectedChartDayIndex;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final hasStrain = summary?.dayStrain != null && summary!.dayStrain! > 0.0;
    final dayStrain = summary?.dayStrain ?? 0.0;
    final targetStrain = summary?.targetStrain ?? 14.0;
    final activeCalories = summary?.activeCalories?.toInt();
    final totalCalories = summary?.totalCalories?.toInt();
    final todaySteps = summary?.todaySteps;
    final workoutsToday = summary?.workouts ?? [];
    final workouts7d = summary?.workouts7d.isNotEmpty == true
        ? summary!.workouts7d
        : workoutsToday;

    // Active workouts list based on time horizon
    final currentWorkouts =
        _timeHorizonIndex == 0 ? workoutsToday : workouts7d;

    // Filtered by selected category
    final filteredWorkouts = _selectedCategory == ActivityCategory.all
        ? currentWorkouts
        : currentWorkouts
            .where((w) =>
                ActivityCategoryHelper.resolve(w.title) == _selectedCategory)
            .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(
        left: Tok.space16,
        right: Tok.space16,
        top: Tok.space8,
        bottom: 96,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STRAIN & WORKOUTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: RecovaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Autonomic Exertion & Physical Load',
                    style: TextStyle(
                      fontSize: 10,
                      color: RecovaColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              // Dynamic Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: RecovaColors.surfaceElevation3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasStrain
                        ? _getStrainStatusColor(dayStrain).withValues(alpha: 0.4)
                        : RecovaColors.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasStrain
                            ? _getStrainStatusColor(dayStrain)
                            : RecovaColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasStrain
                          ? _getStrainStatusLabel(dayStrain)
                          : 'STANDBY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: hasStrain
                            ? RecovaColors.textPrimary
                            : RecovaColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Time Horizon Switcher: [ TODAY ] | [ PAST 7 DAYS ] ──
          _buildTimeHorizonSelector(),
          const SizedBox(height: 14),

          // ── Hero Exertion Card ──
          if (_timeHorizonIndex == 0)
            _buildTodayHeroCard(
              hasStrain: hasStrain,
              dayStrain: dayStrain,
              targetStrain: targetStrain,
            )
          else
            _build7DayHeroCard(
              summary: summary,
              workouts7d: workouts7d,
            ),
          const SizedBox(height: 14),

          // ── 3 Quick Telemetry Pods (Real Data from Health Connect) ──
          _buildTelemetryPods(
            activeCalories: activeCalories,
            totalCalories: totalCalories,
            todaySteps: todaySteps,
            currentWorkouts: currentWorkouts,
          ),
          const SizedBox(height: 16),

          // ── Activity Section Header & See All Button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _timeHorizonIndex == 0
                        ? 'TODAY\'S ACTIVITIES'
                        : '7-DAY ACTIVITIES',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: RecovaColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: RecovaColors.surfaceElevation3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: RecovaColors.borderSubtle),
                    ),
                    child: Text(
                      '${currentWorkouts.length} TOTAL',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: currentWorkouts.isNotEmpty
                            ? Tok.neonAccent
                            : RecovaColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              // Option to see all activities
              GestureDetector(
                onTap: () => _showAllActivitiesModal(
                  context,
                  allWorkouts: workouts7d.isNotEmpty ? workouts7d : workoutsToday,
                ),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: const [
                    Text(
                      'ALL ACTIVITIES',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Tok.neonAccent,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9,
                      color: Tok.neonAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Activity Categories Filter Chips ──
          _buildCategoryFilterRow(currentWorkouts),
          const SizedBox(height: 10),

          // ── Category Aggregate Summary Bar ──
          if (filteredWorkouts.isNotEmpty)
            _buildCategorySummaryBar(filteredWorkouts),
          const SizedBox(height: 10),

          // ── Workout List or Empty State ──
          if (filteredWorkouts.isEmpty)
            _buildEmptyWorkoutsCard(
              hasActivityData: (todaySteps != null && todaySteps > 0) ||
                  (activeCalories != null && activeCalories > 0),
              activeCalories: activeCalories,
              todaySteps: todaySteps,
            )
          else
            ...filteredWorkouts.map((w) => _buildWorkoutCard(w)),
        ],
      ),
    );
  }

  // ── Time Horizon Pill Switcher ──────────────────────────────────────────
  Widget _buildTimeHorizonSelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Tok.glassFillRecessed,
        borderRadius: BorderRadius.circular(Tok.radiusFull),
        border: Border.all(color: Tok.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _timeHorizonIndex = 0;
                _selectedCategory = ActivityCategory.all;
              }),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Tok.animFast,
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _timeHorizonIndex == 0
                      ? Tok.glassFillElevated
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Tok.radiusFull),
                  border: Border.all(
                    color: _timeHorizonIndex == 0
                        ? Tok.glassBorderBright
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 13,
                      color: _timeHorizonIndex == 0
                          ? Tok.neonAccent
                          : Tok.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: _timeHorizonIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.8,
                        color: _timeHorizonIndex == 0
                            ? Tok.textPrimary
                            : Tok.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _timeHorizonIndex = 1;
                _selectedCategory = ActivityCategory.all;
              }),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Tok.animFast,
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _timeHorizonIndex == 1
                      ? Tok.glassFillElevated
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Tok.radiusFull),
                  border: Border.all(
                    color: _timeHorizonIndex == 1
                        ? Tok.glassBorderBright
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_view_week_rounded,
                      size: 13,
                      color: _timeHorizonIndex == 1
                          ? Tok.recoveryModerate
                          : Tok.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PAST 7 DAYS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: _timeHorizonIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.8,
                        color: _timeHorizonIndex == 1
                            ? Tok.textPrimary
                            : Tok.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's Hero Exertion Card ──────────────────────────────────────────
  Widget _buildTodayHeroCard({
    required bool hasStrain,
    required double dayStrain,
    required double targetStrain,
  }) {
    final progressRatio =
        targetStrain > 0 ? (dayStrain / targetStrain).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progressRatio * 100).round();
    final advice = _getTargetAdvice(dayStrain, targetStrain);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(Tok.radiusLg),
        border: Border.all(color: RecovaColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'DAY STRAIN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: RecovaColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Tok.glassFillRecessed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '0.0 - 21.0 BORG',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: Tok.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        hasStrain ? dayStrain.toStringAsFixed(1) : '--',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0,
                          color: RecovaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '/ 21.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: RecovaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Glowing Kinetic Exertion Indicator Circle
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RecovaColors.surfaceElevation3,
                  border: Border.all(
                    color: hasStrain
                        ? _getStrainStatusColor(dayStrain)
                            .withValues(alpha: 0.5)
                        : RecovaColors.borderSubtle,
                    width: 1.2,
                  ),
                  boxShadow: hasStrain
                      ? [
                          BoxShadow(
                            color: _getStrainStatusColor(dayStrain)
                                .withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 30,
                    color: hasStrain
                        ? _getStrainStatusColor(dayStrain)
                        : RecovaColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Target Strain & Exertion Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'TARGET: ${targetStrain.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: RecovaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(FROM RECOVERY)',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    hasStrain ? '$progressPercent% ACCUMULATED' : 'READY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: hasStrain
                          ? _getStrainStatusColor(dayStrain)
                          : RecovaColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrainStatusColor(dayStrain),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Dynamic 5-Second Comprehension Advice Pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Tok.glassFillRecessed,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Tok.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      advice.icon,
                      size: 13,
                      color: advice.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advice.message,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Tok.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 7-Day Hero Card & Strain Bar Distribution ───────────────────────────
  Widget _build7DayHeroCard({
    required DerivedMetricSummary? summary,
    required List<WorkoutSessionSummary> workouts7d,
  }) {
    final history = summary?.strainHistory7d ?? [];
    double avgStrain = 0.0;
    if (history.isNotEmpty) {
      final total = history.fold<double>(0.0, (s, p) => s + p.score);
      avgStrain = total / history.length;
    }

    final total7dMinutes = workouts7d.fold<int>(
      0,
      (sum, w) => sum + w.durationMinutes,
    );
    final total7dCalories = workouts7d.fold<double>(
      0.0,
      (sum, w) => sum + (w.calories ?? 0.0),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(Tok.radiusLg),
        border: Border.all(color: RecovaColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '7-DAY AVERAGE STRAIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: RecovaColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        avgStrain > 0 ? avgStrain.toStringAsFixed(1) : '--',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0,
                          color: RecovaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ 21.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: RecovaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 7D Stat Overview
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${workouts7d.length} SESSIONS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Tok.neonAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${total7dMinutes ~/ 60}h ${total7dMinutes % 60}m Total',
                    style: const TextStyle(
                      fontSize: 10,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                  if (total7dCalories > 0)
                    Text(
                      '${total7dCalories.toInt()} kcal Burned',
                      style: const TextStyle(
                        fontSize: 9,
                        color: RecovaColors.kineticAmberGold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Interactive Daily Strain Bars
          if (history.isNotEmpty) ...[
            const Text(
              'DAILY EXERTION DISTRIBUTION',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: RecovaColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            _build7DayStrainBars(history),
          ],
        ],
      ),
    );
  }

  // ── 7-Day Strain Bar Chart ──────────────────────────────────────────────
  Widget _build7DayStrainBars(List<HistoricalScorePoint> history) {
    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(history.length, (index) {
          final point = history[index];
          final isToday = index == history.length - 1;
          final isSelected = _selectedChartDayIndex == index;
          final strain = point.score;
          final barRatio = (strain / 21.0).clamp(0.06, 1.0);
          final barColor = isToday
              ? Tok.recoveryModerate
              : (strain >= 14
                  ? Tok.recoverySuppressed
                  : (strain >= 8 ? Tok.neonAccent : Tok.textSecondary));

          const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final dayLabel = isToday ? 'TODAY' : dayNames[point.date.weekday - 1];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedChartDayIndex = isSelected ? null : index;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Score on top of bar
                  Text(
                    strain > 0 ? strain.toStringAsFixed(1) : '-',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday
                          ? Tok.recoveryModerate
                          : (isSelected ? Tok.textPrimary : Tok.textMuted),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bar
                  Container(
                    height: 65 * barRatio,
                    width: 18,
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: isToday ? 0.85 : (isSelected ? 0.6 : 0.25)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? RecovaColors.monochromeWhite
                            : (isToday
                                ? Tok.recoveryModerate
                                : barColor.withValues(alpha: 0.5)),
                        width: isSelected || isToday ? 1.2 : 0.8,
                      ),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: Tok.recoveryModerate.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Day Label
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: isToday ? 7.5 : 8.5,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday
                          ? Tok.recoveryModerate
                          : (isSelected ? Tok.textPrimary : Tok.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 3 Key Telemetry Bento Pods ──────────────────────────────────────────
  Widget _buildTelemetryPods({
    required int? activeCalories,
    required int? totalCalories,
    required int? todaySteps,
    required List<WorkoutSessionSummary> currentWorkouts,
  }) {
    final totalWorkoutMins = currentWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.durationMinutes,
    );

    return Row(
      children: [
        // Active Energy Pod
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecovaColors.surfaceElevation1,
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              border: Border.all(color: RecovaColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ACTIVE ENERGY',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: RecovaColors.kineticAmberGold,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  activeCalories != null
                      ? '$activeCalories'
                      : (totalCalories != null ? '$totalCalories' : '--'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RecovaColors.kineticAmberGold,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'kcal burned',
                  style: TextStyle(
                    fontSize: 8,
                    color: RecovaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Steps Pod (preserves exact test strings)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecovaColors.surfaceElevation1,
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              border: Border.all(color: RecovaColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'TODAY\'S STEPS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 13,
                      color: Tok.neonAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  todaySteps != null ? _formatNumber(todaySteps) : '--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RecovaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'DAY TOTAL (00:00 - NOW)',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: RecovaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Active Time Pod
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RecovaColors.surfaceElevation1,
              borderRadius: BorderRadius.circular(Tok.radiusMd),
              border: Border.all(color: RecovaColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ACTIVE TIME',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: Tok.accentBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  totalWorkoutMins > 0 ? '$totalWorkoutMins' : '0',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Tok.accentBlue,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'minutes active',
                  style: TextStyle(
                    fontSize: 8,
                    color: RecovaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Category Filter Row ─────────────────────────────────────────────────
  Widget _buildCategoryFilterRow(List<WorkoutSessionSummary> workouts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ActivityCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          final count = cat == ActivityCategory.all
              ? workouts.length
              : workouts
                  .where((w) =>
                      ActivityCategoryHelper.resolve(w.title) == cat)
                  .length;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              key: ValueKey('filter_chip_${cat.name}'),
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Tok.animFast,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.15)
                      : RecovaColors.surfaceElevation2,
                  borderRadius: BorderRadius.circular(Tok.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? cat.color
                        : RecovaColors.borderSubtle,
                    width: isSelected ? 1.0 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 11,
                      color: isSelected ? cat.color : RecovaColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? RecovaColors.textPrimary
                            : RecovaColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.3)
                              : Tok.glassFillRecessed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cat.color : Tok.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Category Aggregate Summary Bar ──────────────────────────────────────
  Widget _buildCategorySummaryBar(List<WorkoutSessionSummary> workouts) {
    final totalMins = workouts.fold<int>(0, (s, w) => s + w.durationMinutes);
    final totalCals = workouts.fold<double>(0.0, (s, w) => s + (w.calories ?? 0.0));
    final avgStrain = workouts.fold<double>(0.0, (s, w) => s + w.estimatedStrain) /
        workouts.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Tok.glassFillRecessed,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Tok.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _selectedCategory.icon,
                size: 12,
                color: _selectedCategory.color,
              ),
              const SizedBox(width: 6),
              Text(
                '${workouts.length} ${_selectedCategory.label} Sessions',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: RecovaColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${totalMins ~/ 60 > 0 ? '${totalMins ~/ 60}h ' : ''}${totalMins % 60}m',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: RecovaColors.textSecondary,
                ),
              ),
              const Text(' • ', style: TextStyle(color: Tok.textMuted, fontSize: 10)),
              Text(
                '${totalCals.toInt()} kcal',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: RecovaColors.kineticAmberGold,
                ),
              ),
              const Text(' • ', style: TextStyle(color: Tok.textMuted, fontSize: 10)),
              Text(
                '⚡ ${avgStrain.toStringAsFixed(1)} avg',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Tok.neonAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Workout Item Card ───────────────────────────────────────────────────
  Widget _buildWorkoutCard(WorkoutSessionSummary workout) {
    final cat = ActivityCategoryHelper.resolve(workout.title);
    final title = ActivityCategoryHelper.formatTitle(workout.title);
    final timeStr = _formatTime(workout.startTime);
    final dateStr = _timeHorizonIndex == 1
        ? '${_formatDateShort(workout.startTime)} • '
        : '';
    final strainStr = workout.estimatedStrain.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        border: Border.all(color: RecovaColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Category Colored Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cat.color.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Icon(cat.icon, size: 18, color: cat.color),
          ),
          const SizedBox(width: 12),

          // Workout Title & Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: RecovaColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cat.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: cat.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '$dateStr$timeStr • ${workout.formattedDuration}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                    if (workout.calories != null && workout.calories! > 0) ...[
                      const Text(' • ',
                          style:
                              TextStyle(color: Tok.textMuted, fontSize: 9)),
                      Text(
                        '${workout.calories!.toInt()} kcal',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: RecovaColors.kineticAmberGold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Session Strain Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Tok.glassFillRecessed,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Tok.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    size: 12, color: Tok.recoveryModerate),
                const SizedBox(width: 2),
                Text(
                  strainStr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: RecovaColors.monochromeWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State Card ────────────────────────────────────────────────────
  Widget _buildEmptyWorkoutsCard({
    required bool hasActivityData,
    required int? activeCalories,
    required int? todaySteps,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation1,
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        border: Border.all(color: RecovaColors.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Tok.glassFillRecessed,
              border: Border.all(color: Tok.glassBorder),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              size: 22,
              color: Tok.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _timeHorizonIndex == 0
                ? 'No structured workouts recorded today'
                : 'No workouts in selected category',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: RecovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasActivityData
                ? 'Daily movement accumulated ${_formatNumber(todaySteps ?? 0)} steps and ${activeCalories ?? 0} active kcal. Start a workout session on your CMF Watch, Nothing X, Strava, or wearable to record structured cardio or weights.'
                : 'Workouts logged on your wearable or fitness tracker (running, strength, HIIT, cycling) will automatically sync here via Health Connect.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: RecovaColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── All Activities Modal Bottom Sheet ───────────────────────────────────
  void _showAllActivitiesModal(
    BuildContext context, {
    required List<WorkoutSessionSummary> allWorkouts,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _AllActivitiesSheet(allWorkouts: allWorkouts);
      },
    );
  }

  // ── Helper Formatting & Logic ───────────────────────────────────────────
  String _formatNumber(int number) {
    if (number >= 1000) {
      final str = number.toString();
      return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return number.toString();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute $period';
  }

  String _formatDateShort(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _getStrainStatusLabel(double strain) {
    if (strain >= 18.0) return 'ALL-OUT PEAK';
    if (strain >= 14.0) return 'HIGH EXERTION';
    if (strain >= 8.0) return 'MODERATE LOAD';
    return 'LIGHT LOAD';
  }

  Color _getStrainStatusColor(double strain) {
    if (strain >= 18.0) return Tok.recoverySuppressed;
    if (strain >= 14.0) return Tok.recoveryModerate;
    if (strain >= 8.0) return Tok.neonAccent;
    return Tok.textSecondary;
  }

  ({String message, IconData icon, Color color}) _getTargetAdvice(
    double strain,
    double target,
  ) {
    final diff = strain - target;
    if (diff.abs() <= 1.5) {
      return (
        message: 'Optimal Strain Match • Load perfectly aligns with recovery.',
        icon: Icons.check_circle_rounded,
        color: Tok.neonAccent,
      );
    } else if (diff < -1.5) {
      final remain = (target - strain).toStringAsFixed(1);
      return (
        message: 'Room for Exertion • $remain strain remaining for optimal recovery balance.',
        icon: Icons.flag_rounded,
        color: Tok.recoveryModerate,
      );
    } else {
      final over = (strain - target).toStringAsFixed(1);
      return (
        message: 'Overreaching Load • +$over beyond recommended target.',
        icon: Icons.warning_amber_rounded,
        color: Tok.recoverySuppressed,
      );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ALL ACTIVITIES MODAL BOTTOM SHEET
// ═════════════════════════════════════════════════════════════════════════════

class _AllActivitiesSheet extends StatefulWidget {
  final List<WorkoutSessionSummary> allWorkouts;

  const _AllActivitiesSheet({required this.allWorkouts});

  @override
  State<_AllActivitiesSheet> createState() => _AllActivitiesSheetState();
}

class _AllActivitiesSheetState extends State<_AllActivitiesSheet> {
  ActivityCategory _selectedCategory = ActivityCategory.all;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final workouts = widget.allWorkouts.where((w) {
      final matchesCategory = _selectedCategory == ActivityCategory.all ||
          ActivityCategoryHelper.resolve(w.title) == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          w.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final totalMinutes =
        workouts.fold<int>(0, (sum, w) => sum + w.durationMinutes);
    final totalCalories = workouts.fold<double>(
      0.0,
      (sum, w) => sum + (w.calories ?? 0.0),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: Tok.glassFillDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
            border: Border.all(color: Tok.glassBorder, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Tok.glassBorderBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALL RECORDED ACTIVITIES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: RecovaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.allWorkouts.length} total sessions tracked across all categories',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: RecovaColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tok.glassFillRecessed,
                      border: Border.all(color: Tok.glassBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Tok.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary Stats Pill Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Tok.glassBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('SESSIONS', '${workouts.length}'),
                  Container(width: 1, height: 20, color: Tok.glassBorder),
                  _buildStatItem(
                      'TOTAL TIME', '${totalMinutes ~/ 60}h ${totalMinutes % 60}m'),
                  Container(width: 1, height: 20, color: Tok.glassBorder),
                  _buildStatItem('ACTIVE BURN', '${totalCalories.toInt()} kcal'),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(Tok.radiusFull),
                border: Border.all(color: Tok.glassBorder),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12, color: Tok.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search workouts (running, cycling, weights)...',
                  hintStyle: TextStyle(fontSize: 11, color: Tok.textMuted),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 16, color: Tok.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),

          // Categories Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ActivityCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final count = cat == ActivityCategory.all
                      ? widget.allWorkouts.length
                      : widget.allWorkouts
                          .where((w) =>
                              ActivityCategoryHelper.resolve(w.title) == cat)
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.2)
                              : Tok.glassFillRecessed,
                          borderRadius: BorderRadius.circular(Tok.radiusFull),
                          border: Border.all(
                            color: isSelected ? cat.color : Tok.glassBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(cat.icon,
                                size: 11,
                                color: isSelected ? cat.color : Tok.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              cat.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Tok.textPrimary
                                    : Tok.textSecondary,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($count)',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isSelected ? cat.color : Tok.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Workouts List
          Expanded(
            child: workouts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.fitness_center_rounded,
                            size: 32, color: Tok.textMuted),
                        SizedBox(height: 8),
                        Text(
                          'No workouts found matching filters',
                          style: TextStyle(fontSize: 11, color: Tok.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final cat = ActivityCategoryHelper.resolve(workout.title);
                      final title =
                          ActivityCategoryHelper.formatTitle(workout.title);
                      final strainStr =
                          workout.estimatedStrain.toStringAsFixed(1);
                      final timeStr =
                          '${workout.startTime.hour.toString().padLeft(2, '0')}:${workout.startTime.minute.toString().padLeft(2, '0')}';
                      final dateStr =
                          '${workout.startTime.day}/${workout.startTime.month}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Tok.glassFill,
                          borderRadius: BorderRadius.circular(Tok.radiusMd),
                          border: Border.all(color: Tok.glassBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(cat.icon, size: 18, color: cat.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Tok.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$dateStr • $timeStr • ${workout.formattedDuration}',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      color: Tok.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bolt_rounded,
                                        size: 12, color: Tok.recoveryModerate),
                                    Text(
                                      strainStr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Tok.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (workout.calories != null &&
                                    workout.calories! > 0)
                                  Text(
                                    '${workout.calories!.toInt()} kcal',
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      color: RecovaColors.kineticAmberGold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Tok.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Tok.textPrimary,
          ),
        ),
      ],
    );
  }
}
