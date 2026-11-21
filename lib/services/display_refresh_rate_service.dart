import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

/// Service to automatically configure 120Hz/90Hz high refresh rate display modes
/// on devices supporting high-refresh displays (e.g. ProMotion, 120Hz Android).
class DisplayRefreshRateService {
  DisplayRefreshRateService._();

  static Future<void> enableHighRefreshRate() async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid) {
        // Fetch all display modes supported by the device screen
        final modes = await FlutterDisplayMode.supported;
        if (modes.isEmpty) return;

        // Find the mode with highest refresh rate (e.g. 120Hz or 90Hz)
        DisplayMode highestMode = modes.first;
        for (final mode in modes) {
          if (mode.refreshRate > highestMode.refreshRate) {
            highestMode = mode;
          }
        }

        // Set the active mode to highest refresh rate
        await FlutterDisplayMode.setPreferredMode(highestMode);
      }
    } catch (_) {
      // Gracefully fall back if device does not permit display mode switching
    }
  }
}
