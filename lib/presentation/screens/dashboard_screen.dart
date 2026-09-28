import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import '../cubits/health_sync/health_sync_state.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../../core/theme/design_tokens.dart';
import '../components/liquid_glass.dart';

/// Main recovery dashboard screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery'),
        centerTitle: true,
        actions: [
          BlocBuilder<HealthSyncCubit, HealthSyncState>(
            builder: (context, state) {
              return IconButton(
                icon: state is HealthSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                onPressed: state is HealthSyncing
                    ? null
                    : () async {
                        await context.read<HealthSyncCubit>().syncNow();
                        if (context.mounted) {
                          context.read<DashboardCubit>().refresh();
                        }
                      },
                tooltip: 'Sync',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<HealthSyncCubit, HealthSyncState>(
        listener: (context, syncState) {
          if (syncState is HealthSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Synced ${syncState.recordCount} records'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (syncState is HealthSyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync failed: ${syncState.message}'),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, syncState) {
          return BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DashboardError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is DashboardEmpty) {
                return _buildEmptyState(context);
              }
              if (state is DashboardLoaded) {
                return _buildDashboard(context, state.summary);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No health data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the sync button to pull data from Health Connect',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          LiquidGlassButton(
            onTap: () async {
              await context.read<HealthSyncCubit>().syncNow();
              if (context.mounted) {
                context.read<DashboardCubit>().refresh();
              }
            },
            icon: const Icon(Icons.sync, color: Tok.neonAccent, size: 20),
            label: 'Sync Wearable Biometrics',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DerivedMetricSummary summary) {
    final score = summary.recoveryScore ?? 50;
    final isOptimal = score >= 67;
    final isModerate = score >= 34 && score < 67;
    final statusColor = isOptimal
        ? Tok.recoveryOptimal
        : isModerate
            ? Tok.recoveryModerate
            : Tok.recoverySuppressed;
    final statusLabel = isOptimal
        ? 'OPTIMAL RECOVERY'
        : isModerate
            ? 'MODERATE RECOVERY'
            : 'SUPPRESSED RECOVERY';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Liquid Glass Status Pill ──
          Center(
            child: LiquidGlassPill(
              label: statusLabel,
              indicatorColor: statusColor,
              trailing: Text(
                '${score.toInt()}%',
                style: TokType.badge.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recovery Score Card
          _RecoveryScoreCard(summary: summary),
          const SizedBox(height: 16),

          // Component Breakdown
          _ComponentBreakdownCard(summary: summary),
          const SizedBox(height: 16),

          // VO2max Card
          if (summary.estimatedVo2Max != null)
            _Vo2MaxCard(vo2max: summary.estimatedVo2Max!),
          if (summary.estimatedVo2Max != null) const SizedBox(height: 16),

          // Vital Stats Row
          _VitalStatsRow(summary: summary),
          const SizedBox(height: 16),

          // Sync info
          if (summary.lastSyncedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${summary.totalRecords} records synced · Last sync: ${_formatTime(summary.lastSyncedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Recovery Score Card ──

class _RecoveryScoreCard extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _RecoveryScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final score = summary.recoveryScore ?? 50;
    final color = _scoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'RECOVERY SCORE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 16),

            // Radial gauge using PieChart
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 65,
                      sections: [
                        PieChartSectionData(
                          value: score,
                          color: color,
                          radius: 18,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 100 - score,
                          color: color.withValues(alpha: 0.15),
                          radius: 18,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.toInt()}',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        _scoreLabel(score),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Primary factor
            if (summary.primaryFactor != null) ...[
              const SizedBox(height: 14),
              LiquidGlassPill(
                label: summary.primaryFactor!.toUpperCase(),
                indicatorColor: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.amber;
    return Colors.redAccent;
  }

  String _scoreLabel(double score) {
    if (score >= 80) return 'Optimal';
    if (score >= 60) return 'Moderate';
    if (score >= 40) return 'Fair';
    return 'Low';
  }
}

// ── Component Breakdown Card ──

class _ComponentBreakdownCard extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _ComponentBreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _ComponentBar(
              label: 'Resting HR',
              value: summary.recoveryComponentRhr ?? 50,
              icon: Icons.favorite,
              weight: '50%',
            ),
            const SizedBox(height: 12),
            _ComponentBar(
              label: 'Sleep',
              value: summary.recoveryComponentSleep ?? 50,
              icon: Icons.bedtime,
              weight: '35%',
            ),
            const SizedBox(height: 12),
            _ComponentBar(
              label: 'Blood Oxygen',
              value: summary.recoveryComponentSpo2 ?? 50,
              icon: Icons.air,
              weight: '15%',
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentBar extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final String weight;
  const _ComponentBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 80
        ? Colors.green
        : value >= 50
            ? Colors.amber
            : Colors.redAccent;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text('${value.toInt()}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(weight,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    )),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withValues(alpha: 0.15),
          color: color,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

// ── VO2max Card ──

class _Vo2MaxCard extends StatelessWidget {
  final double vo2max;
  const _Vo2MaxCard({required this.vo2max});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.speed,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Est. VO₂ Max',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message:
                            'Estimated from resting and max heart rate.\nNot a clinical measurement.',
                        child: Icon(Icons.info_outline,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                  Text(
                    '${vo2max.toStringAsFixed(1)} mL/kg/min',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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

// ── Vital Stats Row ──

class _VitalStatsRow extends StatelessWidget {
  final DerivedMetricSummary summary;
  const _VitalStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.favorite,
            label: 'Resting HR',
            value: summary.restingHr != null
                ? '${summary.restingHr!.toInt()} bpm'
                : '—',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.bedtime,
            label: 'Avg Sleep',
            value: summary.sleepHours != null
                ? '${summary.sleepHours!.toStringAsFixed(1)} hrs'
                : '—',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.air,
            label: 'SpO₂',
            value: summary.spo2 != null
                ? '${summary.spo2!.toStringAsFixed(0)}%'
                : '—',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon,
                size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    )),
          ],
        ),
      ),
    );
  }
}
