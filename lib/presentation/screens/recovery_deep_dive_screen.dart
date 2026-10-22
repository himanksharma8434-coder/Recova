import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/daily_metric_point.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../domain/services/vo2_max_estimator.dart';


/// Time-period options for VO2 Max trend charting and averaging.
enum Vo2Period {
  sevenDays('7D', 7),
  thirtyDays('30D', 30),
  allTime('ALL', 0);

  final String label;
  final int days;
  const Vo2Period(this.label, this.days);
}

/// Body Data Screen displaying Cardiovascular Capacity (VO₂ Max)
/// with 7D/30D/ALL trends and Uth–Sørensen calculations.
class BodyDataScreen extends StatefulWidget {
  final DerivedMetricSummary? summary;

  const BodyDataScreen({
    super.key,
    required this.summary,
  });

  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

/// Backwards compatibility typedef for existing screen references and tests
typedef RecoveryDeepDiveScreen = BodyDataScreen;

class _MetricDataCache {
  final List<DailyMetricPoint> points;
  final double? avg;
  final double? latest;
  final double? minVal;
  final double? maxVal;
  final double? hrMax;
  final double? hrRest;
  final double? bestVo2Max;
  final Vo2MaxResult? latestVo2MaxResult;

  const _MetricDataCache({
    required this.points,
    this.avg,
    this.latest,
    this.minVal,
    this.maxVal,
    this.hrMax,
    this.hrRest,
    this.bestVo2Max,
    this.latestVo2MaxResult,
  });
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  Vo2Period _selectedPeriod = Vo2Period.sevenDays;

  final Map<String, _MetricDataCache> _cache = {};
  String get _cacheKey => 'vo2Max_${_selectedPeriod.name}';

  List<DailyMetricPoint> _points = [];
  double? _average;
  double? _latest;

  // Calculation components for VO2 formula display
  static const double defaultMaxHeartRate = 190.0;
  double _calcHrMax = defaultMaxHeartRate;
  double _calcHrRest = 60.0;
  double? _min;
  double? _max;
  bool _loading = false;

  Vo2MaxResult? _latestVo2MaxResult;



  @override
  void initState() {
    super.initState();
    _loadMetricData();
  }

  @override
  void didUpdateWidget(BodyDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary?.estimatedVo2Max != widget.summary?.estimatedVo2Max ||
        oldWidget.summary?.restingHr != widget.summary?.restingHr) {
      _cache.clear();
      _loadMetricData();
    }
  }

  /// Resolves max heart rate: takes 190 by default if there is no data more than 190 bpm.
  static double _resolveMaxHr(double? recordedMax) {
    if (recordedMax != null && recordedMax > defaultMaxHeartRate) {
      return recordedMax;
    }
    return defaultMaxHeartRate;
  }



  Future<void> _loadMetricData() async {
    final cacheKey = _cacheKey;
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      setState(() {
        _points = cached.points;
        _average = cached.avg;
        _latest = cached.latest;
        _min = cached.minVal;
        _max = cached.maxVal;
        _calcHrMax = _resolveMaxHr(cached.hrMax);
        _calcHrRest = cached.hrRest ??
            widget.summary?.baselineRestingHr ??
            widget.summary?.restingHr ??
            60.0;
        _latestVo2MaxResult = cached.latestVo2MaxResult;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final db = AppDatabase.instance;
      final days = _selectedPeriod.days > 0 ? _selectedPeriod.days : null;

      final points = await db.derivedMetricDao.getDailyVo2MaxHistory(days);

      double? avg;
      double? latest;
      double? minVal;
      double? maxVal;

      if (points.isNotEmpty) {
        final sum = points.fold<double>(0.0, (s, p) => s + p.value);
        avg = sum / points.length;
        latest = points.last.value;
        minVal = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
        maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
      } else {
        latest = widget.summary?.estimatedVo2Max;
        avg = latest;
      }

      // Live formula components for VO2 max
      double? hrMax;
      double? hrRest;
      double? bestVo2Max;
      Vo2MaxResult? latestVo2MaxResult;

      if (mounted) {
        try {
          latestVo2MaxResult = await context
              .read<HealthSourceRepository>()
              .getLatestVo2MaxResult();
        } catch (_) {}
      }
      final now = DateTime.now();
      final periodDays = _selectedPeriod.days > 0 ? _selectedPeriod.days : null;

      // ── HRmax: 1 highest HR from whole week (or period), default 190 bpm ──
      hrMax = await db.healthRecordDao.getHighestMaxHr(days: periodDays);
      if (hrMax == null && _selectedPeriod != Vo2Period.allTime) {
        hrMax = await db.healthRecordDao.getHighestMaxHr(days: 7);
      }
      hrMax ??= await db.healthRecordDao.getMaxExerciseHr(
        start: DateTime(2000),
        end: now,
      );

      // Default to 190.0 if not > 190 bpm
      hrMax = _resolveMaxHr(hrMax);

      // ── HRrest: 7-day average RHR ──
      final todayStart = DateTime(now.year, now.month, now.day);
      final baseline = await db.baselineDao.getBaseline(todayStart);

      hrRest = baseline?.restingHrBaseline7d ??
          widget.summary?.baselineRestingHr ??
          widget.summary?.restingHr ??
          60.0;

      // Best-case VO2 Max
      final bestPeriodDays = periodDays ?? 7;
      final bestRhr = await db.healthRecordDao.getBestRestingHr(bestPeriodDays) ?? hrRest;
      var bestMaxHr = await db.healthRecordDao.getBestMaxHr(bestPeriodDays) ?? hrMax;
      bestMaxHr = _resolveMaxHr(bestMaxHr);

      if (bestRhr > 0 && bestMaxHr > bestRhr) {
        final raw = 15.3 * (bestMaxHr / bestRhr);
        if (raw >= 15.0 && raw <= 85.0) {
          bestVo2Max = raw;
        }
      }

      _cache[cacheKey] = _MetricDataCache(
        points: points,
        avg: avg,
        latest: latest,
        minVal: minVal,
        maxVal: maxVal,
        hrMax: hrMax,
        hrRest: hrRest,
        bestVo2Max: bestVo2Max,
        latestVo2MaxResult: latestVo2MaxResult,
      );

      if (mounted) {
        setState(() {
          _points = points;
          _average = avg;
          _latest = latest;
          _min = minVal;
          _max = maxVal;
          _calcHrMax = hrMax ?? defaultMaxHeartRate;
          _calcHrRest = hrRest ?? 60.0;
          _latestVo2MaxResult = latestVo2MaxResult;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onPeriodChanged(Vo2Period period) {
    setState(() => _selectedPeriod = period);
    _loadMetricData();
  }

  void _showVo2Explainer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _Vo2ExplainerSheet(vo2Result: _latestVo2MaxResult),
    );
  }





  String _vo2Tier(double? vo2) {
    if (vo2 == null) return 'FAIR';
    if (vo2 >= 50) return 'SUPERIOR';
    if (vo2 >= 42) return 'EXCELLENT';
    if (vo2 >= 35) return 'GOOD';
    return 'FAIR';
  }

  String _formatDateLabel(DateTime date, bool isLast) {
    if (isLast) return 'Today';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }


  @override
  Widget build(BuildContext context) {
    // Current displayed headline VO2 Max value
    // Matches the calculation breakdown card exactly: 15.3 × (HRmax / HRrest)
    final computedVo2 = _calcHrRest > 0
        ? (15.3 * (_calcHrMax / _calcHrRest)).clamp(15.0, 85.0)
        : null;

    double? headlineValue = computedVo2 ??
        widget.summary?.estimatedVo2Max7d ??
        widget.summary?.estimatedVo2Max ??
        _average ??
        _latest;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BODY DATA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: RecovaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CARDIOVASCULAR CAPACITY (VO₂ MAX)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: RecovaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showVo2Explainer,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RecovaColors.surfaceElevation2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RecovaColors.borderSubtle),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Tok.neonAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),



          // ── VO2 MAX SECTION ──
          _buildVo2MaxSection(headlineValue),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VO2 MAX CARD & TREND
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildVo2MaxSection(double? headlineValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.speed, size: 14, color: Tok.neonAccent),
                SizedBox(width: 6),
                Text(
                  'VO₂ MAX (CARDIO CAPACITY)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Tok.textPrimary,
                  ),
                ),
              ],
            ),
            // Period Selector Pills (7D / 30D / ALL)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: Vo2Period.values.map((p) {
                final isSelected = p == _selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => _onPeriodChanged(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Tok.neonAccentSurface
                            : RecovaColors.surfaceElevation2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Tok.neonAccentGlow
                              : RecovaColors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isSelected
                              ? Tok.neonAccent
                              : RecovaColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main VO2 Max Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecovaColors.surfaceElevation1,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RecovaColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline Value + Fitness Tier
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: headlineValue != null
                                ? headlineValue.toStringAsFixed(1)
                                : '--',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.0,
                              color: RecovaColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text: ' mL/kg/min',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: RecovaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (headlineValue != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Tok.neonAccentSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Tok.neonAccentGlow),
                      ),
                      child: Text(
                        _vo2Tier(headlineValue),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Tok.neonAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              Text(
                _selectedPeriod == Vo2Period.allTime
                    ? 'All-time cardiovascular telemetry (${_points.length} entries)'
                    : '${_selectedPeriod.label} rolling trend (${_points.length} daily entries)',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: RecovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Trend Chart
              _buildChart(),
              const SizedBox(height: 16),

              // Uth–Sørensen Calculation Breakdown
              _buildCalculationCard(),
              const SizedBox(height: 16),

              // Stats Strip
              _buildStatsStrip(),
            ],
          ),
        ),
      ],
    );
  }

  /// Interactive LineChart for VO2 Max
  Widget _buildChart() {
    if (_points.isEmpty) {
      return Container(
        height: 130,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.show_chart, size: 26, color: RecovaColors.textSecondary),
            SizedBox(height: 6),
            Text(
              'No VO₂ Max entries recorded for this window.\nWear your tracker and log workouts to build your trend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: RecovaColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final spots = _points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final values = _points.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final diff = maxVal - minVal;
    final pad = diff == 0 ? 5.0 : (diff * 0.15).clamp(2.0, 20.0);
    final minY = (minVal - pad).floorToDouble().clamp(0.0, 300.0);
    final maxY = (maxVal + pad).ceilToDouble();
    final minX = 0.0;
    final maxX = spots.length > 1 ? (spots.length - 1).toDouble() : 1.0;

    final yInterval = ((maxY - minY) / 3).clamp(1.0, 50.0);

    return SizedBox(
      height: 145,
      child: RepaintBoundary(
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.05),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: yInterval,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: RecovaColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= _points.length) {
                      return const SizedBox.shrink();
                    }
                    final total = _points.length;
                    bool showLabel = false;
                    if (total <= 7) {
                      showLabel = index == 0 ||
                          index == total ~/ 2 ||
                          index == total - 1;
                    } else {
                      final step = (total / 3).floor();
                      showLabel = index == 0 ||
                          index == step ||
                          index == step * 2 ||
                          index == total - 1;
                    }
                    if (!showLabel) return const SizedBox.shrink();
                    final isLast = index == total - 1;
                    final label = _formatDateLabel(_points[index].date, isLast);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: RecovaColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => RecovaColors.surfaceElevation3,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.spotIndex;
                    final date = (idx >= 0 && idx < _points.length)
                        ? _points[idx].date
                        : DateTime.now();
                    final dateStr =
                        _formatDateLabel(date, idx == _points.length - 1);
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} mL/kg/min\n',
                      const TextStyle(
                        color: Tok.neonAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      children: [
                        TextSpan(
                          text: dateStr,
                          style: const TextStyle(
                            color: RecovaColors.textTertiary,
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: spots.length > 2,
                curveSmoothness: 0.28,
                color: Tok.neonAccent,
                barWidth: 2.2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final isLatest = index == barData.spots.length - 1;
                    return FlDotCirclePainter(
                      radius: isLatest ? 3.5 : 1.8,
                      color: isLatest
                          ? Tok.neonAccent
                          : RecovaColors.monochromeSilver,
                      strokeColor: Colors.white,
                      strokeWidth: isLatest ? 1.5 : 0,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Tok.neonAccent.withValues(alpha: 0.18),
                      Tok.neonAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculation Breakdown Card for VO2 Max
  Widget _buildCalculationCard() {
    final hrMaxSubtitle = _calcHrMax > defaultMaxHeartRate
        ? 'Recorded Peak'
        : 'Default (≤190 bpm)';
    final hrRestSubtitle = _selectedPeriod == Vo2Period.allTime
        ? 'All-Time Avg RHR'
        : (_selectedPeriod == Vo2Period.thirtyDays
            ? '30D Avg RHR'
            : '7D Avg RHR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RecovaColors.recoveryEmerald.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.functions,
                      size: 14, color: RecovaColors.recoveryEmerald),
                  SizedBox(width: 5),
                  Text(
                    'CALCULATION BREAKDOWN',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: RecovaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: RecovaColors.recoveryEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: RecovaColors.recoveryEmerald.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'UTH\u2013S\u00d8RENSEN',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: RecovaColors.recoveryEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Calculates VO₂ max from the ratio of your maximum heart rate (default 190 bpm) to your resting heart rate.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: RecovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Formula box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RecovaColors.surfaceElevation3,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RecovaColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VO₂max = 15.3 × (HRmax / HRrest)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RecovaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '15.3 × (${_calcHrMax.toStringAsFixed(0)} / ${_calcHrRest.toStringAsFixed(1)}) = ${(15.3 * (_calcHrMax / _calcHrRest)).toStringAsFixed(1)} mL/kg/min',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: RecovaColors.monochromeWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Variables chips
          Row(
            children: [
              _calcChip('HRmax', '${_calcHrMax.toStringAsFixed(0)} bpm', hrMaxSubtitle),
              const SizedBox(width: 6),
              _calcChip('HRrest', '${_calcHrRest.toStringAsFixed(1)} bpm', hrRestSubtitle),
              const SizedBox(width: 6),
              _calcChip('Ratio', (_calcHrMax / _calcHrRest).toStringAsFixed(2), 'Max/Rest Dynamic'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcChip(String title, String val, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: RecovaColors.surfaceElevation3,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: RecovaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RecovaColors.monochromeWhite,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                color: RecovaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3-column summary statistics footer strip for VO2 Max
  Widget _buildStatsStrip() {
    final col1Val = _latest != null ? _latest!.toStringAsFixed(1) : '--';
    final col2Val = _average != null ? _average!.toStringAsFixed(1) : '--';
    final col3Val = _vo2Tier(_latest ?? _average);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RecovaColors.surfaceElevation2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('LATEST', col1Val),
          Container(width: 1, height: 24, color: RecovaColors.borderSubtle),
          _statItem('PERIOD AVG', col2Val),
          Container(width: 1, height: 24, color: RecovaColors.borderSubtle),
          _statItem('FITNESS TIER', col3Val),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: RecovaColors.textTertiary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: RecovaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Vo2ExplainerSheet extends StatelessWidget {
  final Vo2MaxResult? vo2Result;
  const _Vo2ExplainerSheet({this.vo2Result});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Tok.glassFillDark,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
            border: Border.all(color: Tok.glassBorder, width: 1.0),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Tok.glassBorderBright,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Icon(Icons.science_outlined,
                        size: 18, color: Tok.recoveryOptimal),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'HOW VO₂ MAX & BODY AGE ARE CALCULATED',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Tok.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Powered by the Uth-Sørensen Baseline Equation & Multi-Factor Fitness Age Modeling',
                  style: TextStyle(
                    fontSize: 11,
                    color: Tok.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _explainerRow(
                  icon: Icons.speed,
                  title: 'Uth–Sørensen Ratio',
                  description:
                      'VO₂max = 15.0 × (HRmax / HRrest). Maximum heart rate defaults to 190 bpm unless higher peaks (>190 bpm) are detected.',
                ),
                const SizedBox(height: 12),
                _explainerRow(
                  icon: Icons.accessibility_new_rounded,
                  title: 'Biological Body Age',
                  description:
                      'Compares your cardiovascular capacity (VO2 Max), autonomic resting heart rate, and body composition against population percentiles.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Tok.glassFillRecessed,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Tok.glassBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline,
                          size: 14, color: Tok.textTertiary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estimates are derived from your wearable biometric telemetry and configured profile. They are not clinical diagnostic tests.',
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.45,
                            color: Tok.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _explainerRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Tok.glassFillElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Tok.glassBorder),
          ),
          child: Icon(icon, size: 14, color: Tok.textPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Tok.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.4,
                  color: Tok.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
