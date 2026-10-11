import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../services/user_profile_service.dart';
import '../../../domain/repositories/body_age_repository.dart';
import '../../../domain/repositories/body_measurement_repository.dart';
import 'body_age_checkin_state.dart';

/// Cubit managing the 30-day periodic body measurement check-in prompt.
class BodyAgeCheckinCubit extends Cubit<BodyAgeCheckinState> {
  final BodyMeasurementRepository measurementRepo;
  final BodyAgeRepository bodyAgeRepo;

  static const String keyMonthlyReminderEnabled = 'body_checkin_reminder_enabled';
  static const String keyLastPromptDate = 'body_checkin_last_prompt_date';
  static const String keySnoozeUntil = 'body_checkin_snooze_until';
  static const String keyWeightUnitKg = 'body_checkin_unit_is_kg';
  static const String keyFirstOpenDate = 'app_first_open_timestamp';

  BodyAgeCheckinCubit({
    required this.measurementRepo,
    required this.bodyAgeRepo,
  }) : super(const BodyAgeCheckinInitial());

  /// Checks if the user is eligible for a monthly check-in prompt.
  /// Evaluates on app open / resume; never blocks startup.
  Future<void> evaluateEligibility({bool isWorkoutActive = false}) async {
    if (isWorkoutActive) return;

    final prefs = await SharedPreferences.getInstance();

    // 1. Check if reminders are enabled in settings (defaults to true)
    final remindersEnabled = prefs.getBool(keyMonthlyReminderEnabled) ?? true;
    if (!remindersEnabled) return;

    final now = DateTime.now();

    // 2. Check snooze state
    final snoozeMs = prefs.getInt(keySnoozeUntil);
    if (snoozeMs != null) {
      final snoozeUntil = DateTime.fromMillisecondsSinceEpoch(snoozeMs);
      if (now.isBefore(snoozeUntil)) return;
    }

    // 3. Show at most once per calendar day
    final lastPromptMs = prefs.getInt(keyLastPromptDate);
    if (lastPromptMs != null) {
      final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      if (lastPrompt.year == now.year &&
          lastPrompt.month == now.month &&
          lastPrompt.day == now.day) {
        return;
      }
    }

    // 4. Onboarding grace period: do not prompt on very first launch (wait >= 3 days)
    int? firstOpenMs = prefs.getInt(keyFirstOpenDate);
    if (firstOpenMs == null) {
      firstOpenMs = now.millisecondsSinceEpoch;
      await prefs.setInt(keyFirstOpenDate, firstOpenMs);
      return;
    } else {
      final firstOpen = DateTime.fromMillisecondsSinceEpoch(firstOpenMs);
      if (now.difference(firstOpen).inDays < 3) {
        final hasAny = await measurementRepo.getLatestMeasurement();
        if (hasAny == null) return;
      }
    }

    // 5. Check if 30 days have elapsed since last measurement
    final shouldPrompt =
        await measurementRepo.hasElapsedDaysSinceLastMeasurement(30);
    if (!shouldPrompt) return;

    // Record prompt time for today
    await prefs.setInt(keyLastPromptDate, now.millisecondsSinceEpoch);

    final lastEntry = await measurementRepo.getLatestMeasurement();
    final isKg = prefs.getBool(keyWeightUnitKg) ?? true;

    double? prefillWeight;
    if (lastEntry != null) {
      prefillWeight = isKg
          ? lastEntry.weightKg
          : lastEntry.weightKg / 0.45359237;
    }

    emit(BodyAgeCheckinPrompt(
      lastMeasurement: lastEntry,
      isKgUnit: isKg,
      prefilledWeight: prefillWeight,
      prefilledBodyFat: lastEntry?.bodyFatPct,
    ));
  }

  /// Sets the unit preference (kg vs lbs) and updates display prefill.
  Future<void> toggleUnit(bool isKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyWeightUnitKg, isKg);

    final currentState = state;
    if (currentState is BodyAgeCheckinPrompt) {
      double? convertedWeight;
      if (currentState.lastMeasurement != null) {
        final kg = currentState.lastMeasurement!.weightKg;
        convertedWeight = isKg ? kg : kg / 0.45359237;
      }

      emit(BodyAgeCheckinPrompt(
        lastMeasurement: currentState.lastMeasurement,
        isKgUnit: isKg,
        prefilledWeight: convertedWeight,
        prefilledBodyFat: currentState.prefilledBodyFat,
      ));
    }
  }

  /// Save measurement, update profile, and calculate new body age.
  Future<void> saveCheckin({
    required double weightInput,
    required bool isKg,
    double? bodyFatPct,
  }) async {
    emit(const BodyAgeCheckinSaving());

    final double weightKg = isKg ? weightInput : weightInput * 0.45359237;

    // Get previous snapshot for comparative diff
    final previousSnapshot = await bodyAgeRepo.getLatestSnapshot();
    final double? previousAge = previousSnapshot?.bodyAge;

    // Persist measurement locally in Drift
    await measurementRepo.saveMeasurement(
      weightKg: double.parse(weightKg.toStringAsFixed(1)),
      bodyFatPct: bodyFatPct != null
          ? double.parse(bodyFatPct.toStringAsFixed(1))
          : null,
    );

    // Sync weight with UserProfile
    final profile = await UserProfileService.getProfile();
    await UserProfileService.saveProfile(profile.copyWith(
      weightKg: double.parse(weightKg.toStringAsFixed(1)),
    ));

    // Clear snooze
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keySnoozeUntil);

    // Recalculate Body Age
    final newResult = await bodyAgeRepo.calculateCurrentBodyAge();

    if (newResult != null) {
      final double delta = previousAge != null
          ? double.parse((newResult.bodyAge - previousAge).toStringAsFixed(1))
          : 0.0;

      emit(BodyAgeCheckinSuccess(
        result: newResult,
        previousBodyAge: previousAge,
        newBodyAge: newResult.bodyAge,
        deltaFromPrevious: delta,
      ));
    } else {
      emit(const BodyAgeCheckinDismissed('saved'));
    }
  }

  /// Snooze check-in reminder for 3 days.
  Future<void> snoozeCheckin() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeDate = DateTime.now().add(const Duration(days: 3));
    await prefs.setInt(keySnoozeUntil, snoozeDate.millisecondsSinceEpoch);
    emit(const BodyAgeCheckinDismissed('snoozed'));
  }

  /// Skip check-in for this month (30 days).
  Future<void> skipThisMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeDate = DateTime.now().add(const Duration(days: 30));
    await prefs.setInt(keySnoozeUntil, snoozeDate.millisecondsSinceEpoch);
    emit(const BodyAgeCheckinDismissed('skipped'));
  }
}
