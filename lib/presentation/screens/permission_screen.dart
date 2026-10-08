import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/design_tokens.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/motion.dart';
import '../cubits/health_permission/health_permission_cubit.dart';
import '../cubits/health_permission/health_permission_state.dart';
import 'main_shell_screen.dart';

/// Glassmorphic Permission onboarding screen.
/// Explains why health data is needed and requests authorization.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check in case permissions were already granted
    context.read<HealthPermissionCubit>().checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HealthPermissionCubit>().checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthPermissionCubit, HealthPermissionState>(
      listener: (context, state) {
        if (state is HealthPermissionGranted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Tok.canvasBase,
        body: AmbientGlowBackdrop(
          primaryGlow: Tok.neonAccent,
          secondaryGlow: Tok.accentBlue,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(
                horizontal: Tok.space32,
                vertical: Tok.space24,
              ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Icon with Recova logo & neon accent
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Tok.neonAccent.withValues(alpha: 0.25),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Tok.neonAccent.withValues(alpha: 0.12),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/recova_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Tok.glassFill,
                          border: Border.all(color: Tok.glassBorderBright, width: 0.5),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          size: 48,
                          color: Tok.neonAccent,
                        ),
                      ),
                    ),
                  ),
                ).animateHero(),
                const SizedBox(height: Tok.space32),

                // Title
                Text(
                  'CONNECT WEARABLE TELEMETRY',
                  style: TokType.heading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animateFadeIn(index: 1),
                const SizedBox(height: Tok.space12),

                // Rationale
                Text(
                  'Recova reads heart rate, sleep architecture, SpO2, and workouts from your wearable via Health Connect.\n\n'
                  'All telemetry is computed locally on-device. Zero cloud transmission.',
                  style: TokType.body.copyWith(fontSize: 12.5),
                  textAlign: TextAlign.center,
                ).animateFadeIn(index: 2),
                const SizedBox(height: Tok.space32),

                // Data types
                _DataTypeChip(
                  icon: Icons.favorite_outline,
                  label: 'Heart Rate & Resting HR',
                  accentColor: Tok.neonAccent,
                ).animateIn(index: 0),
                const SizedBox(height: Tok.space8),
                _DataTypeChip(
                  icon: Icons.bedtime_outlined,
                  label: 'Sleep Stages & Architecture',
                  accentColor: Tok.accentBlue,
                ).animateIn(index: 1),
                const SizedBox(height: Tok.space8),
                _DataTypeChip(
                  icon: Icons.air,
                  label: 'Blood Oxygen Saturation (SpO2)',
                  accentColor: Tok.recoveryModerate,
                ).animateIn(index: 2),
                const SizedBox(height: Tok.space8),
                _DataTypeChip(
                  icon: Icons.directions_run,
                  label: 'Workouts, Steps & Active Energy',
                  accentColor: Tok.neonAccent,
                ).animateIn(index: 3),
                const SizedBox(height: Tok.space8),
                _DataTypeChip(
                  icon: Icons.thermostat_outlined,
                  label: 'Respiration, Vitals & Temperature',
                  accentColor: Tok.textSecondary,
                ).animateIn(index: 4),
                const SizedBox(height: Tok.space32),

                // Primary Connect button — neon accent CTA
                BlocBuilder<HealthPermissionCubit, HealthPermissionState>(
                  builder: (context, state) {
                    final isLoading = state is HealthPermissionRequesting;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<HealthPermissionCubit>()
                                .requestPermissions(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Tok.neonAccent,
                          foregroundColor: Tok.canvasBase,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Tok.radiusXl),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Tok.canvasBase,
                                ),
                              )
                            : Text(
                                'GRANT HEALTH CONNECT ACCESS',
                                style: TokType.badge.copyWith(
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  color: Tok.canvasBase,
                                ),
                              ),
                      ),
                    );
                  },
                ).animateIn(index: 5),
                const SizedBox(height: Tok.space12),

                // Secondary
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const MainShellScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Tok.textSecondary,
                    ),
                    child: Text(
                      'I\'VE ALREADY GRANTED ACCESS • PROCEED',
                      style: TokType.caption.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Denied message
                BlocBuilder<HealthPermissionCubit, HealthPermissionState>(
                  builder: (context, state) {
                    if (state is HealthPermissionDenied) {
                      return Padding(
                        padding: const EdgeInsets.only(top: Tok.space8),
                        child: Text(
                          state.message,
                          style: TokType.bodySmall.copyWith(
                            color: Tok.recoveryModerate,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _DataTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _DataTypeChip({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hasBlur: false,
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space16,
        vertical: Tok.space12,
      ),
      borderRadius: Tok.radiusSm,
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: Tok.space12),
          Expanded(
            child: Text(
              label,
              style: TokType.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Tok.textPrimary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
