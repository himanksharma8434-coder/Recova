import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MOTION UTILITIES — GSAP-Quality Feel, Flutter-Native Implementation
// Smooth easing, staggered reveals, spring-like responsiveness.
// ═══════════════════════════════════════════════════════════════════════════════

bool get _isInTest =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Standard entrance animation for cards: fade + slide up with hardware-accelerated compositing.
extension StaggeredEntrance on Widget {
  /// Applies a fluid, hardware-composited card entrance animation.
  /// [index] controls stagger delay, [fromOffset] is the initial Y offset.
  Widget animateIn({
    int index = 0,
    double fromOffset = 18.0,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (_isInTest) return this;
    final staggerDelay = delay ??
        Duration(milliseconds: index * Tok.staggerDelay.inMilliseconds);

    return RepaintBoundary(
      child: animate()
          .fadeIn(
            duration: duration ?? Tok.animEntrance,
            delay: staggerDelay,
            curve: curve,
          )
          .slideY(
            begin: fromOffset / 100,
            end: 0,
            duration: duration ?? Tok.animEntrance,
            delay: staggerDelay,
            curve: curve,
          ),
    );
  }

  /// Hero number reveal — bigger scale + slower.
  Widget animateHero({
    Duration? delay,
  }) {
    if (_isInTest) return this;
    return animate()
        .fadeIn(
          duration: Tok.animSlow,
          delay: delay ?? const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
        )
        .scaleXY(
          begin: 0.8,
          end: 1.0,
          duration: Tok.animSlow,
          delay: delay ?? const Duration(milliseconds: 100),
          curve: Curves.easeOutBack,
        );
  }

  /// Subtle fade-in without movement — for labels, captions, secondary content.
  Widget animateFadeIn({
    int index = 0,
    Duration? duration,
    Duration? delay,
  }) {
    if (_isInTest) return this;
    final staggerDelay = delay ??
        Duration(milliseconds: index * Tok.staggerDelay.inMilliseconds);
    return animate().fadeIn(
      duration: duration ?? Tok.animNormal,
      delay: staggerDelay,
      curve: Curves.easeOut,
    );
  }
}

/// Shimmer loading placeholder that matches glass card look.
class GlassShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GlassShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = Tok.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Tok.glassFillRecessed,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white.withValues(alpha: 0.04),
        );
  }
}

/// Themed loading spinner that matches the glass aesthetic.
class GlassLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const GlassLoadingSpinner({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Tok.neonAccent.withValues(alpha: 0.7),
        backgroundColor: Tok.glassFillRecessed,
      ),
    );
  }
}

/// Themed empty state that matches glass aesthetic.
class GlassEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Tok.space32,
          vertical: Tok.space48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Tok.glassFill,
                border: Border.all(
                  color: Tok.glassBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Tok.textTertiary,
              ),
            ),
            const SizedBox(height: Tok.space16),
            Text(
              title,
              style: TokType.cardTitle.copyWith(color: Tok.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Tok.space8),
              Text(
                subtitle!,
                style: TokType.bodySmall.copyWith(color: Tok.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Tok.space24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
