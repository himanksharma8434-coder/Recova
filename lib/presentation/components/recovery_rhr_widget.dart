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

/// A premium, glassmorphic widget that displays live Athletic Recovery and
/// Resting Heart Rate (RHR) telemetry, automatically refreshed every 30 minutes.
///
/// Features:
/// - Real-time Recovery score with dynamic color-coded circular arc gauge and status tier.
/// - Resting Heart Rate (bpm) with animated cardiac pulse and basal baseline delta.
/// - 30-minute automatic background & foreground refresh cycle with live countdown ticker.
/// - Synced with the OS Home Screen Widget via [HomeWidgetService].
/// - Interactive tap callbacks to navigate to Recovery calculation and RHR detail screens.
class RecoveryRhrWidget extends StatefulWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback? onRefresh;
  final VoidCallback? onRecoveryTap;
  final VoidCallback? onRhrTap;
  final bool autoRefreshEnabled;
  final Duration autoRefreshInterval;
  final EdgeInsetsGeometry margin;

  const RecoveryRhrWidget({
    super.key,
    this.summary,
    this.onRefresh,
    this.onRecoveryTap,
    this.onRhrTap,
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

  late AnimationController _heartPulseController;
  late Animation<double> _heartScaleAnimation;

  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _lastRefreshed = widget.summary?.lastSyncedAt ?? DateTime.now();

    // Subtle rhythmic heartbeat animation for resting heart rate
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

    // Refresh spin animation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 30-minute auto-refresh timer
    if (widget.autoRefreshEnabled) {
      _startAutoRefreshTimer();
    }

    // 30-second live ticker to update relative timestamp & progress
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      _performAutoRefresh();
    });
  }

  @override
  void didUpdateWidget(covariant RecoveryRhrWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary?.lastSyncedAt != null &&
        widget.summary!.lastSyncedAt != oldWidget.summary?.lastSyncedAt) {
      _lastRefreshed = widget.summary!.lastSyncedAt!;
    }
    if (widget.autoRefreshEnabled != oldWidget.autoRefreshEnabled ||
        widget.autoRefreshInterval != oldWidget.autoRefreshInterval) {
      if (widget.autoRefreshEnabled) {
        _startAutoRefreshTimer();
      } else {
        _autoRefreshTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tickerTimer?.cancel();
    _heartPulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  /// Triggers an immediate 30-minute sync refresh
  Future<void> _performAutoRefresh() async {
    if (_isRefreshing || !mounted) return;

    setState(() {
      _isRefreshing = true;
    });
    _spinController.repeat();

    try {
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      } else {
        // Trigger health sync cubit if present
        try {
          await context.read<HealthSyncCubit>().syncNow();
        } catch (_) {}

        if (!mounted) return;

        // Refresh dashboard cubit if present
        try {
          await context.read<DashboardCubit>().refresh();
        } catch (_) {}
      }

      // Update native OS home widget with latest available metrics
      final currentSummary = _resolveSummary();
      if (currentSummary != null) {
        await HomeWidgetService.updateFromSummary(currentSummary);
      }
    } catch (_) {
      // Gracefully handle transient refresh errors
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _lastRefreshed = DateTime.now();
        });
        _spinController.stop();
        _spinController.reset();
      }
    }
  }

  DerivedMetricSummary? _resolveSummary() {
    if (widget.summary != null) return widget.summary;
    try {
      final dashState = context.read<DashboardCubit>().state;
      if (dashState is DashboardLoaded) {
        return dashState.summary;
      }
    } catch (_) {}
    return null;
  }

  Color _getRecoveryColor(double? score) {
    if (score == null) return Tok.recoveryCalibrating;
    if (score >= 67) return Tok.recoveryOptimal;
    if (score >= 34) return Tok.recoveryModerate;
    return Tok.recoverySuppressed;
  }

  String _getRecoveryTierLabel(double? score) {
    if (score == null) return 'CALIBRATING';
    if (score >= 67) return 'OPTIMAL';
    if (score >= 34) return 'MODERATE';
    return 'SUPPRESSED';
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
    final recoveryColor = _getRecoveryColor(recoveryScore);
    final recoveryTier = _getRecoveryTierLabel(recoveryScore);

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

    // Dynamic RHR delta vs baseline
    String rhrDeltaText = 'Basal';
    Color rhrDeltaColor = Tok.textSecondary;
    if (restingHr != null && baselineRhr != null) {
      final diff = (restingHr - baselineRhr).round();
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

    return Padding(
      padding: widget.margin,
      child: LiquidGlass(
        padding: const EdgeInsets.all(Tok.space16),
        borderRadius: BorderRadius.circular(22),
        material: IosGlassMaterial.thick,
        accentGlow: recoveryColor.withValues(alpha: 0.12),
        customBottomReflection: recoveryColor.withValues(alpha: 0.08),
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
                            _isRefreshing
                                ? 'SYNCING...'
                                : 'AUTO 30M',
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
            const SizedBox(height: Tok.space14),

            // ── Core Metrics Section: Dual Pods (Recovery | Resting Heart Rate) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Recovery Pod (Left) ──
                Expanded(
                  child: InkWell(
                    onTap: widget.onRecoveryTap,
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Tok.space6,
                        vertical: Tok.space4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 13,
                                color: recoveryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'RECOVERY',
                                style: TokType.sectionLabel.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 1.1,
                                  color: Tok.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Tok.space8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Radial Mini Gauge
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: CustomPaint(
                                  painter: _MiniRecoveryArcPainter(
                                    score: recoveryScore ?? 0,
                                    color: recoveryColor,
                                    trackColor: Tok.glassFillElevated,
                                  ),
                                  child: Center(
                                    child: Text(
                                      recoveryScore != null
                                          ? '${recoveryScore.round()}'
                                          : '--',
                                      style: TokType.heading.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: recoveryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Tok.space10),
                              // Score Details & Tier Badge
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: recoveryColor.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: recoveryColor.withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        recoveryTier,
                                        style: TokType.caption.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: recoveryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      baselineRecovery != null
                                          ? 'Base ${baselineRecovery.round()}%'
                                          : 'Daily balance',
                                      style: TokType.caption.copyWith(
                                        fontSize: 9.5,
                                        color: Tok.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Vertical Glass Divider ──
                Container(
                  width: 1,
                  height: 58,
                  margin: const EdgeInsets.symmetric(horizontal: Tok.space8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Tok.glassBorder.withValues(alpha: 0.05),
                        Tok.glassBorder.withValues(alpha: 0.4),
                        Tok.glassBorder.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),

                // ── Resting Heart Rate Pod (Right) ──
                Expanded(
                  child: InkWell(
                    onTap: widget.onRhrTap,
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Tok.space6,
                        vertical: Tok.space4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ScaleTransition(
                                scale: _heartScaleAnimation,
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  size: 13,
                                  color: Tok.recoverySuppressed,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'RESTING HR',
                                style: TokType.sectionLabel.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 1.1,
                                  color: Tok.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Tok.space8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                restingHr != null
                                    ? '${restingHr.round()}'
                                    : '--',
                                style: TokType.heading.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Tok.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'bpm',
                                style: TokType.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Tok.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: rhrDeltaColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rhrDeltaText,
                                  style: TokType.caption.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: rhrDeltaColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tok.space12),

            // ── Bottom Progress & 30-Minute Cycle Telemetry ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thin progress track showing 30m window elapsed
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
    final strokeWidth = 4.0;
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
