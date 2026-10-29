import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../services/background_sync_service.dart';
import '../../services/home_widget_service.dart';
import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import 'liquid_glass.dart';

/// Helper to get the canonical color for a recovery score.
Color getRecoveryColor(double? score) {
  if (score == null) return Tok.textTertiary;
  if (score >= 67) return Tok.recoveryOptimal;
  if (score >= 34) return Tok.recoveryModerate;
  return Tok.recoverySuppressed;
}

/// Helper to get the recovery tier label.
String getRecoveryTierLabel(double? score) {
  if (score == null) return 'CALIBRATING';
  if (score >= 67) return 'OPTIMAL';
  if (score >= 34) return 'MODERATE';
  return 'SUPPRESSED';
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. RECOVERY 1x1 WIDGET (Liquid Glass with iPhone-style typography)
// ═══════════════════════════════════════════════════════════════════════════════

/// A 1x1 square widget dedicated to Athletic Recovery, featuring:
/// - Liquid Glass container with Apple HIG frosted glass & ambient glow.
/// - iPhone-inspired large tabular typography.
/// - Dynamic circular arc gauge colored by recovery tier (Optimal / Moderate / Suppressed).
/// - Baseline context comparison and interactive tap navigation.
class Recovery1x1Widget extends StatelessWidget {
  final double? recoveryScore;
  final double? baselineRecovery;
  final VoidCallback? onTap;

  const Recovery1x1Widget({
    super.key,
    this.recoveryScore,
    this.baselineRecovery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recoveryColor = getRecoveryColor(recoveryScore);
    final recoveryTier = getRecoveryTierLabel(recoveryScore);

    return AspectRatio(
      aspectRatio: 1.0,
      child: LiquidGlass(
        padding: const EdgeInsets.all(Tok.space12),
        borderRadius: BorderRadius.circular(22),
        material: IosGlassMaterial.thick,
        accentGlow: recoveryColor.withValues(alpha: 0.16),
        customBottomReflection: recoveryColor.withValues(alpha: 0.08),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Header: Icon + RECOVERY Label + Status Pill ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 13, color: recoveryColor),
                        const SizedBox(width: 3),
                        const Text(
                          'RECOVERY',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: Tok.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: recoveryColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: recoveryColor.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      recoveryTier,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: recoveryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Center: iPhone-Style Big Number with Mini Circular Arc ──
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: CustomPaint(
                      painter: _MiniRecoveryArcPainter(
                        score: recoveryScore ?? 0,
                        color: recoveryColor,
                        trackColor: Tok.glassFillElevated,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              recoveryScore != null
                                  ? '${recoveryScore!.round()}'
                                  : '--',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.2,
                                color: Tok.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            if (recoveryScore != null)
                              Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: recoveryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom: Baseline Comparison ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      baselineRecovery != null
                          ? 'Base ${baselineRecovery!.round()}%'
                          : 'Daily balance',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Tok.textSecondary,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 13,
                  color: Tok.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. VO₂ MAX & RESTING HR 1x1 WIDGET (Liquid Glass)
// ═══════════════════════════════════════════════════════════════════════════════

/// A 1x1 square widget displaying:
/// - Top: VO₂ Max (Cardio capacity in mL/kg/min).
/// - Frosted glass hairline divider.
/// - Bottom: Resting Heart Rate (bpm) with animated pulse & basal baseline delta.
class Vo2Rhr1x1Widget extends StatefulWidget {
  final double? vo2Max;
  final double? restingHr;
  final double? baselineRhr;
  final VoidCallback? onTap;
  final VoidCallback? onVo2Tap;

  const Vo2Rhr1x1Widget({
    super.key,
    this.vo2Max,
    this.restingHr,
    this.baselineRhr,
    this.onTap,
    this.onVo2Tap,
  });

  @override
  State<Vo2Rhr1x1Widget> createState() => _Vo2Rhr1x1WidgetState();
}

class _Vo2Rhr1x1WidgetState extends State<Vo2Rhr1x1Widget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartPulseController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _heartPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_heartPulseController);
  }

  @override
  void dispose() {
    _heartPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic RHR delta vs baseline
    String rhrDeltaText = 'Basal';
    Color rhrDeltaColor = Tok.textSecondary;
    if (widget.restingHr != null && widget.baselineRhr != null) {
      final diff = (widget.restingHr! - widget.baselineRhr!).round();
      if (diff < 0) {
        rhrDeltaText = '$diff bpm basal';
        rhrDeltaColor = Tok.recoveryOptimal;
      } else if (diff > 0) {
        rhrDeltaText = '+$diff bpm basal';
        rhrDeltaColor = Tok.recoverySuppressed;
      } else {
        rhrDeltaText = 'On baseline';
        rhrDeltaColor = Tok.textSecondary;
      }
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: LiquidGlass(
        padding: const EdgeInsets.all(Tok.space12),
        borderRadius: BorderRadius.circular(22),
        material: IosGlassMaterial.thick,
        accentGlow: Tok.accentBlue.withValues(alpha: 0.12),
        customBottomReflection: Tok.neonAccent.withValues(alpha: 0.06),
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP: VO₂ MAX ──
            InkWell(
              onTap: widget.onVo2Tap ?? widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.speed, size: 12, color: Tok.accentBlue),
                              SizedBox(width: 3),
                              Text(
                                'VO₂ MAX',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Tok.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Tok.accentBlue.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CARDIO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Tok.accentBlue,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          widget.vo2Max != null
                              ? widget.vo2Max!.toStringAsFixed(1)
                              : '--',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: Tok.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'mL/kg/min',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: Tok.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Frosted Glass Divider ──
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Tok.glassBorder.withValues(alpha: 0.05),
                    Tok.glassBorder.withValues(alpha: 0.35),
                    Tok.glassBorder.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),

            // ── BOTTOM: RESTING HR ──
            InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _heartScaleAnimation,
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 11,
                          color: Tok.recoverySuppressed,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'RESTING HR',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Tok.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              widget.restingHr != null
                                  ? '${widget.restingHr!.round()}'
                                  : '--',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: Tok.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'bpm',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Tok.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            rhrDeltaText,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: rhrDeltaColor,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. COMBINED RECOVERY & RHR WIDGET (Split 1x1 Side-by-Side Presentation)
// ═══════════════════════════════════════════════════════════════════════════════

/// A premium, glassmorphic telemetry widget rendering two split 1x1 widgets:
/// 1. [Recovery1x1Widget] (1x1 square for recovery with iPhone-like numbers).
/// 2. [Vo2Rhr1x1Widget] (1x1 square telling VO₂ Max on top and Resting HR in bottom).
///
/// Features:
/// - 30-minute automatic background & foreground refresh cycle with live countdown ticker.
/// - Synced with OS Home Screen Widgets via [HomeWidgetService].
/// - Interactive tap callbacks to navigate to Recovery calculation and RHR detail screens.
class RecoveryRhrWidget extends StatefulWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback? onRefresh;
  final VoidCallback? onRecoveryTap;
  final VoidCallback? onRhrTap;
  final VoidCallback? onVo2Tap;
  final bool autoRefreshEnabled;
  final Duration autoRefreshInterval;
  final EdgeInsetsGeometry margin;

  const RecoveryRhrWidget({
    super.key,
    this.summary,
    this.onRefresh,
    this.onRecoveryTap,
    this.onRhrTap,
    this.onVo2Tap,
    this.autoRefreshEnabled = true,
    this.autoRefreshInterval = const Duration(minutes: 30),
    this.margin = const EdgeInsets.symmetric(
      horizontal: Tok.space16,
      vertical: Tok.space8,
    ),
  });

  @override
  State<RecoveryRhrWidget> createState() => _RecoveryRhrWidgetState();
}

class _RecoveryRhrWidgetState extends State<RecoveryRhrWidget>
    with TickerProviderStateMixin {
  Timer? _autoRefreshTimer;
  Timer? _tickerTimer;
  DateTime _lastRefreshed = DateTime.now();
  bool _isRefreshing = false;

  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _lastRefreshed = widget.summary?.lastSyncedAt ?? DateTime.now();

    // Refresh spin animation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 30-minute auto-refresh timer
    if (widget.autoRefreshEnabled) {
      _startAutoRefreshTimer();
    }

    // Push initial summary data to HomeWidget
    if (widget.summary != null) {
      HomeWidgetService.updateFromSummary(widget.summary!);
    }
  }

  @override
  void didUpdateWidget(covariant RecoveryRhrWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary != oldWidget.summary && widget.summary != null) {
      _lastRefreshed = widget.summary?.lastSyncedAt ?? DateTime.now();
      HomeWidgetService.updateFromSummary(widget.summary!);
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tickerTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _tickerTimer?.cancel();

    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      _performAutoRefresh();
    });

    _tickerTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _performAutoRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _spinController.repeat();

    try {
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      } else {
        try {
          await context.read<HealthSyncCubit>().syncNow();
        } catch (_) {}
      }
      _lastRefreshed = DateTime.now();
    } catch (_) {
      // Handled silently
    } finally {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prefer explicitly passed summary, otherwise watch dashboard state
    DerivedMetricSummary? currentSummary = widget.summary;
    if (currentSummary == null) {
      try {
        final state = context.watch<DashboardCubit>().state;
        if (state is DashboardLoaded) {
          currentSummary = state.summary;
        }
      } catch (_) {}
    }

    final recoveryScore = currentSummary?.recoveryScore;
    final baselineRecovery = currentSummary?.baselineRecoveryScore;
    final restingHr = currentSummary?.restingHr;
    final baselineRhr = currentSummary?.baselineRestingHr;
    final vo2Max = currentSummary?.estimatedVo2Max ?? currentSummary?.estimatedVo2Max7d;

    // Calculate elapsed time in the 30-minute window
    final now = DateTime.now();
    final effectiveLastSync = currentSummary?.lastSyncedAt ?? _lastRefreshed;
    final elapsed = now.difference(effectiveLastSync);
    final totalWindowSec = widget.autoRefreshInterval.inSeconds;
    final elapsedSec = elapsed.inSeconds.clamp(0, totalWindowSec);
    final progressFraction = totalWindowSec > 0 ? (elapsedSec / totalWindowSec) : 1.0;

    final remainingMinutes = math.max(
      0,
      widget.autoRefreshInterval.inMinutes - elapsed.inMinutes,
    );

    return Padding(
      padding: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Header: Title, 30m Auto-Refresh Tag & Manual Refresh Button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isRefreshing ? Tok.accentBlue : Tok.neonAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRefreshing ? Tok.accentBlue : Tok.neonAccent)
                              .withValues(alpha: 0.7),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Tok.space8),
                  Text(
                    'AUTONOMIC TELEMETRY',
                    style: TokType.sectionLabel.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w700,
                      color: Tok.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Auto 30m pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tok.space8,
                      vertical: Tok.space4,
                    ),
                    decoration: BoxDecoration(
                      color: Tok.glassFillRecessed,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: Tok.glassBorder.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.autorenew_rounded,
                          size: 11,
                          color: Tok.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isRefreshing ? 'SYNCING...' : 'AUTO 30M',
                          style: TokType.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: _isRefreshing
                                ? Tok.accentBlue
                                : Tok.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Tok.space8),
                  // Interactive Refresh Icon Button
                  GestureDetector(
                    onTap: _isRefreshing ? null : _performAutoRefresh,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(Tok.space6),
                      decoration: BoxDecoration(
                        color: Tok.glassFillRecessed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Tok.glassBorder.withValues(alpha: 0.2),
                        ),
                      ),
                      child: RotationTransition(
                        turns: _spinController,
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 15,
                          color: _isRefreshing
                              ? Tok.neonAccent
                              : Tok.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),

          // ── Two 1x1 Split Widgets in a Row ──
          Row(
            children: [
              Expanded(
                child: Recovery1x1Widget(
                  recoveryScore: recoveryScore,
                  baselineRecovery: baselineRecovery,
                  onTap: widget.onRecoveryTap,
                ),
              ),
              const SizedBox(width: Tok.space12),
              Expanded(
                child: Vo2Rhr1x1Widget(
                  vo2Max: vo2Max,
                  restingHr: restingHr,
                  baselineRhr: baselineRhr,
                  onTap: widget.onRhrTap,
                  onVo2Tap: widget.onVo2Tap,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tok.space12),

          // ── Bottom Progress & 30-Minute Cycle Telemetry ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 2.5,
                  backgroundColor: Tok.glassFillElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isRefreshing
                        ? Tok.accentBlue
                        : Tok.neonAccent.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Synced ${formatRelativeSyncTime(effectiveLastSync)}',
                    style: TokType.caption.copyWith(
                      fontSize: 9.5,
                      color: Tok.textMuted,
                    ),
                  ),
                  Text(
                    _isRefreshing
                        ? 'Refreshing now...'
                        : 'Next auto-refresh in ${remainingMinutes}m',
                    style: TokType.caption.copyWith(
                      fontSize: 9.5,
                      color: Tok.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the mini circular recovery arc
class _MiniRecoveryArcPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color trackColor;

  _MiniRecoveryArcPainter({
    required this.score,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 5.0;
    final radius = (size.width - strokeWidth) / 2;

    // Background track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active arc
    final sweepAngle = (score.clamp(0.0, 100.0) / 100.0) * 2 * math.pi;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top 12 o'clock
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRecoveryArcPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
