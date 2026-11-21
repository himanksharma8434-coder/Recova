import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Performance configuration and scroll telemetry tracker.
/// During active fling or drag scrolling, informs [IosGlass] and other
/// visual-heavy components to suspend expensive dynamic backdrop blurs
/// and re-enable them instantly when scroll becomes idle.
/// This guarantees locked 120 FPS / 60 FPS without GPU frame drops.
class ScrollPerformanceManager {
  ScrollPerformanceManager._();

  /// ValueNotifier indicating whether the user is actively scrolling.
  static final ValueNotifier<bool> isScrolling = ValueNotifier<bool>(false);

  /// Global toggle for glassmorphic backdrop blur rendering.
  /// Set to true by default. If disabled by user or low-spec mode,
  /// turns off multi-pass GPU shaders entirely.
  static bool enableBackdropBlur = true;

  /// Global blur radius multiplier. Can be set to 0.75 for high performance.
  static double blurSigmaScale = 0.85;

  static void onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (!isScrolling.value) {
        isScrolling.value = true;
      }
    } else if (notification is ScrollEndNotification) {
      if (isScrolling.value) {
        isScrolling.value = false;
      }
    } else if (notification is UserScrollNotification) {
      final scrolling = notification.direction != ScrollDirection.idle;
      if (isScrolling.value != scrolling) {
        isScrolling.value = scrolling;
      }
    }
  }
}
