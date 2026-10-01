import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../components/bottom_pill_nav_bar.dart';
import '../components/liquid_glass.dart';
import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import '../cubits/health_sync/health_sync_cubit.dart';
import '../cubits/health_sync/health_sync_state.dart';
import 'pulse_screen.dart';
import 'recovery_deep_dive_screen.dart';
import 'strain_screen.dart';
import 'sleep_screen.dart';
import '../../services/background_sync_service.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentTab = 0;
  Timer? _bannerTimer;
  bool _showBanner = false;
  String _bannerMessage = '';
  IconData _bannerIcon = Icons.check_circle_rounded;
  Color _bannerAccentColor = Tok.neonAccent;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
    // Guarantee background periodic sync is registered with the OS
    registerPeriodicSync();
    // Auto-sync on startup: pull latest wearable data immediately
    _autoSync();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _autoSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<HealthSyncCubit>().syncNow();
      if (mounted) {
        context.read<DashboardCubit>().refresh();
      }
    });
  }

  void _onSyncTap() async {
    await context.read<HealthSyncCubit>().syncNow();
    if (mounted) {
      context.read<DashboardCubit>().refresh();
    }
  }

  void _triggerTopNotification({
    required String message,
    required IconData icon,
    required Color accentColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _bannerIcon = icon;
      _bannerAccentColor = accentColor;
      _showBanner = true;
    });
    _bannerTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  void _dismissBanner() {
    _bannerTimer?.cancel();
    if (_showBanner && mounted) {
      setState(() {
        _showBanner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      body: BlocListener<HealthSyncCubit, HealthSyncState>(
        listener: (context, syncState) {
          if (syncState is HealthSyncSuccess) {
            final count = syncState.recordCount;
            final message = count > 0
                ? 'Synced $count health records from wearable'
                : 'Wearable in sync • 0 new records';
            _triggerTopNotification(
              message: message,
              icon: Icons.check_circle_rounded,
              accentColor: Tok.neonAccent,
            );
          } else if (syncState is HealthSyncFailure) {
            _triggerTopNotification(
              message: 'Sync failed: ${syncState.message}',
              icon: Icons.error_outline_rounded,
              accentColor: Tok.recoverySuppressed,
              duration: const Duration(seconds: 4),
            );
          }
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (prev, current) {
            if (prev is DashboardLoaded && current is DashboardLoaded) {
              return prev.summary != current.summary;
            }
            return prev != current;
          },
          builder: (context, state) {
            DerivedMetricSummary? summary;
            if (state is DashboardLoaded) {
              summary = state.summary;
            }

            final topPadding = MediaQuery.of(context).padding.top;

            return Stack(
              children: [
                // Safe Area wrapped IndexedStack
                SafeArea(
                  bottom: false,
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      PulseScreen(
                        summary: summary,
                        onSyncTap: _onSyncTap,
                      ),
                      RecoveryDeepDiveScreen(
                        summary: summary,
                      ),
                      StrainScreen(
                        summary: summary,
                      ),
                      SleepScreen(
                        summary: summary,
                      ),
                    ],
                  ),
                ),

                // Floating Pill Bottom Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomPillNavBar(
                    selectedIndex: _currentTab,
                    onTabSelected: (index) {
                      setState(() {
                        _currentTab = index;
                      });
                    },
                  ),
                ),

                // Non-intrusive Top Floating Status Pill (placed at the top to avoid bottom collision)
                Positioned(
                  top: topPadding + 8,
                  left: 20,
                  right: 20,
                  child: IgnorePointer(
                    ignoring: !_showBanner,
                    child: AnimatedSlide(
                      offset: _showBanner ? Offset.zero : const Offset(0, -1.3),
                      duration: Tok.animNormal,
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _showBanner ? 1.0 : 0.0,
                        duration: Tok.animNormal,
                        curve: Curves.easeOut,
                        child: Center(
                          child: GestureDetector(
                            onTap: _dismissBanner,
                            child: LiquidGlass(
                              borderRadius: BorderRadius.circular(Tok.radiusFull),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Tok.space16,
                                vertical: Tok.space8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _bannerAccentColor.withValues(alpha: 0.15),
                                    ),
                                    child: Icon(
                                      _bannerIcon,
                                      size: 14,
                                      color: _bannerAccentColor,
                                    ),
                                  ),
                                  const SizedBox(width: Tok.space8),
                                  Flexible(
                                    child: Text(
                                      _bannerMessage,
                                      style: TokType.caption.copyWith(
                                        color: Tok.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: Tok.space8),
                                  const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Tok.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
