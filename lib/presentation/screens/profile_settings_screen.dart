import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../features/body_age/data/repositories/body_measurement_repository_impl.dart';
import '../../features/body_age/presentation/components/body_fat_guide_sheet.dart';
import '../../features/body_age/presentation/cubits/body_age_checkin/body_age_checkin_cubit.dart';
import '../../services/user_profile_service.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';

/// Screen allowing the user to configure their baseline biometrics
/// (body weight, height, age, body fat %, and gender) for body age and recovery.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  String? _selectedGender;
  bool _monthlyReminderEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfileService.getProfile();
    final prefs = await SharedPreferences.getInstance();
    final reminderOn = prefs.getBool(BodyAgeCheckinCubit.keyMonthlyReminderEnabled) ?? true;
    double? bodyFat = profile.bodyFatPct;

    if (bodyFat == null) {
      final latest = await BodyMeasurementRepositoryImpl().getLatestMeasurement();
      bodyFat = latest?.bodyFatPct;
    }

    if (mounted) {
      setState(() {
        if (profile.age != null) {
          _ageController.text = profile.age.toString();
        }
        if (profile.weightKg != null) {
          _weightController.text = profile.weightKg!.toStringAsFixed(1);
        }
        if (profile.heightCm != null) {
          _heightController.text = profile.heightCm!.toStringAsFixed(1);
        }
        if (bodyFat != null) {
          _bodyFatController.text = bodyFat.toStringAsFixed(1);
        }
        _selectedGender = profile.gender ?? 'male';
        _monthlyReminderEnabled = reminderOn;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  double? get _parsedHeight => double.tryParse(_heightController.text.trim());
  double? get _parsedWeight => double.tryParse(_weightController.text.trim());
  int? get _parsedAge => int.tryParse(_ageController.text.trim());
  double? get _parsedBodyFat => double.tryParse(_bodyFatController.text.trim());

  double? get _liveBmi {
    final h = _parsedHeight;
    final w = _parsedWeight;
    if (h != null && w != null && h > 0) {
      final hm = h / 100.0;
      return w / (hm * hm);
    }
    return null;
  }

  double? get _liveBmr {
    final h = _parsedHeight;
    final w = _parsedWeight;
    final age = _parsedAge;
    if (h != null && w != null && age != null && h > 0 && w > 0 && age > 0) {
      if (_selectedGender == 'female') {
        return 10 * w + 6.25 * h - 5 * age - 161;
      } else {
        return 10 * w + 6.25 * h - 5 * age + 5;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final age = _parsedAge;
    if (age == null || age < 18 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid adult age (18–120)'),
          backgroundColor: Tok.recoverySuppressed,
        ),
      );
      return;
    }

    final height = _parsedHeight;
    final weight = _parsedWeight;
    final bodyFat = _parsedBodyFat;

    if (bodyFat != null && (bodyFat < 3.0 || bodyFat > 60.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Body fat percentage must be between 3.0% and 60.0%'),
          backgroundColor: Tok.recoverySuppressed,
        ),
      );
      return;
    }

    final profile = UserProfile(
      age: age,
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
      bodyFatPct: bodyFat,
    );

    await UserProfileService.saveProfile(profile);

    // Save to Drift DB BodyMeasurements so it updates history and body age tracking
    final effectiveWeight = weight ?? (await UserProfileService.getProfile()).weightKg;
    if (effectiveWeight != null && effectiveWeight > 0) {
      await BodyMeasurementRepositoryImpl().saveMeasurement(
        weightKg: effectiveWeight,
        bodyFatPct: bodyFat,
        source: 'manual',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(BodyAgeCheckinCubit.keyMonthlyReminderEnabled, _monthlyReminderEnabled);
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: RecovaColors.canvasBase,
        body: Center(
          child: CircularProgressIndicator(color: Tok.textPrimary),
        ),
      );
    }

    final bmi = _liveBmi;
    final bmr = _liveBmr;

    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PROFILE & SETTINGS',
          style: TokType.sectionLabel.copyWith(
            fontSize: 12,
            letterSpacing: 2.0,
            color: Tok.textSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: AmbientGlowBackdrop(
        primaryGlow: Tok.accentBlue,
        secondaryGlow: Tok.accentAmber,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: Tok.space20,
            vertical: Tok.space12,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 18, color: Tok.textSecondary),
                      const SizedBox(width: Tok.space8),
                      Text(
                        'BASELINE DEMOGRAPHICS',
                        style: TokType.sectionLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: Tok.space8),
                  Text(
                    'Your age, gender, height, and body weight are stored once on your device. '
                    'They are used continuously to compare your wearable biometrics against population norms for Body Age and Recovery.',
                    style: TokType.bodySmall.copyWith(
                      color: Tok.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Age & Gender Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHRONOLOGICAL AGE', style: TokType.sectionLabel),
                  const SizedBox(height: Tok.space12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: TokType.metricMedium.copyWith(fontSize: 22),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '25',
                      hintStyle: TokType.metricMedium.copyWith(
                        fontSize: 22,
                        color: Tok.textSecondary,
                      ),
                      suffixText: 'years old',
                      suffixStyle: TokType.unit,
                      filled: true,
                      fillColor: Tok.glassFillRecessed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide:
                            BorderSide(color: Tok.glassBorder, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide:
                            BorderSide(color: Tok.glassBorder, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Tok.radiusSm),
                        borderSide: BorderSide(
                            color: Tok.glassBorderBright, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Tok.space16,
                        vertical: Tok.space12,
                      ),
                    ),
                  ),
                  const SizedBox(height: Tok.space20),

                  Text('BIOLOGICAL SEX', style: TokType.sectionLabel),
                  const SizedBox(height: Tok.space4),
                  Text(
                    'Used for demographic physiological norm comparison',
                    style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
                  ),
                  const SizedBox(height: Tok.space12),
                  Row(
                    children: [
                      _buildGenderOption('male', 'Male', Icons.male),
                      const SizedBox(width: Tok.space12),
                      _buildGenderOption('female', 'Female', Icons.female),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Height & Weight Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BODY MEASUREMENTS', style: TokType.sectionLabel),
                  const SizedBox(height: Tok.space16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BODY WEIGHT', style: TokType.caption),
                            const SizedBox(height: Tok.space8),
                            TextField(
                              controller: _weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style:
                                  TokType.metricMedium.copyWith(fontSize: 18),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '70.0',
                                hintStyle: TokType.metricMedium.copyWith(
                                  fontSize: 18,
                                  color: Tok.textSecondary,
                                ),
                                suffixText: 'kg',
                                suffixStyle: TokType.unit,
                                filled: true,
                                fillColor: Tok.glassFillRecessed,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorderBright, width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Tok.space12,
                                  vertical: Tok.space8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Tok.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HEIGHT', style: TokType.caption),
                            const SizedBox(height: Tok.space8),
                            TextField(
                              controller: _heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style:
                                  TokType.metricMedium.copyWith(fontSize: 18),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '175.0',
                                hintStyle: TokType.metricMedium.copyWith(
                                  fontSize: 18,
                                  color: Tok.textSecondary,
                                ),
                                suffixText: 'cm',
                                suffixStyle: TokType.unit,
                                filled: true,
                                fillColor: Tok.glassFillRecessed,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorderBright, width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Tok.space12,
                                  vertical: Tok.space8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Body Fat Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BODY COMPOSITION', style: TokType.sectionLabel),
                      GestureDetector(
                        onTap: () => BodyFatGuideSheet.show(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: Tok.neonAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'MEASURE GUIDE',
                              style: TokType.caption.copyWith(
                                color: Tok.neonAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tok.space16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BODY FAT PERCENTAGE', style: TokType.caption),
                            const SizedBox(height: Tok.space8),
                            TextField(
                              controller: _bodyFatController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style:
                                  TokType.metricMedium.copyWith(fontSize: 18),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '18.0',
                                hintStyle: TokType.metricMedium.copyWith(
                                  fontSize: 18,
                                  color: Tok.textSecondary,
                                ),
                                suffixText: '%',
                                suffixStyle: TokType.unit,
                                filled: true,
                                fillColor: Tok.glassFillRecessed,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorder, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(Tok.radiusSm),
                                  borderSide: BorderSide(
                                      color: Tok.glassBorderBright, width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Tok.space12,
                                  vertical: Tok.space8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Tok.space16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CATEGORY', style: TokType.caption),
                          const SizedBox(height: Tok.space8),
                          _buildBodyFatCategoryBadge(_parsedBodyFat, _selectedGender),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Tok.space12),
                  Text(
                    'Body fat % provides direct insight into lean mass vs adipose tissue, heavily refining body age precision.',
                    style: TokType.bodySmall.copyWith(
                      color: Tok.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Live Calculated Biomarkers
            if (bmi != null || bmr != null) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DERIVED ESTIMATES', style: TokType.sectionLabel),
                    const SizedBox(height: Tok.space12),
                    Row(
                      children: [
                        if (bmi != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BODY MASS INDEX',
                                    style: TokType.caption
                                        .copyWith(color: Tok.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  bmi.toStringAsFixed(1),
                                  style: TokType.metricMedium
                                      .copyWith(fontSize: 18),
                                ),
                                Text(
                                  bmi < 18.5
                                      ? 'Underweight'
                                      : bmi < 25.0
                                          ? 'Normal weight'
                                          : bmi < 30.0
                                              ? 'Overweight'
                                              : 'High BMI',
                                  style: TokType.caption
                                      .copyWith(color: Tok.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        if (bmr != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ESTIMATED BMR',
                                    style: TokType.caption
                                        .copyWith(color: Tok.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '${bmr.toStringAsFixed(0)} kcal',
                                  style: TokType.metricMedium
                                      .copyWith(fontSize: 18),
                                ),
                                Text(
                                  'Basal metabolic rate',
                                  style: TokType.caption
                                      .copyWith(color: Tok.textSecondary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tok.space20),
            ],

            // Monthly Check-In Reminder Toggle
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MONTHLY BODY CHECK-IN', style: TokType.sectionLabel),
                        const SizedBox(height: Tok.space4),
                        Text(
                          'Prompt once a month to log body weight & body fat % for body age estimation.',
                          style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _monthlyReminderEnabled,
                    activeThumbColor: Tok.neonAccent,
                    onChanged: (val) => setState(() => _monthlyReminderEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space20),

            // Save Button
            LiquidGlassButton(
              label: 'SAVE PROFILE',
              height: 52,
              width: double.infinity,
              accentColor: Tok.recoveryOptimal,
              onTap: _save,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: Tok.animFast,
          padding: const EdgeInsets.symmetric(
            vertical: Tok.space12,
            horizontal: Tok.space12,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? Tok.glassFillElevated : Tok.glassFillRecessed,
            borderRadius: BorderRadius.circular(Tok.radiusSm),
            border: Border.all(
              color: isSelected ? Tok.glassBorderBright : Tok.glassBorder,
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Tok.textPrimary : Tok.textSecondary,
              ),
              const SizedBox(width: Tok.space8),
              Text(
                label,
                style: TokType.caption.copyWith(
                  color: isSelected ? Tok.textPrimary : Tok.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyFatCategoryBadge(double? fat, String? gender) {
    if (fat == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Tok.space12,
          vertical: Tok.space8,
        ),
        decoration: BoxDecoration(
          color: Tok.glassFillRecessed,
          borderRadius: BorderRadius.circular(Tok.radiusSm),
          border: Border.all(color: Tok.glassBorder, width: 0.5),
        ),
        child: Text(
          'OPTIONAL',
          style: TokType.caption.copyWith(
            color: Tok.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final isFemale = gender == 'female';
    final athleticMax = isFemale ? 20.0 : 13.0;
    final fitnessMax = isFemale ? 24.0 : 17.0;
    final averageMax = isFemale ? 31.0 : 24.0;

    String label;
    Color color;
    if (fat <= athleticMax) {
      label = 'ATHLETIC';
      color = Tok.neonAccent;
    } else if (fat <= fitnessMax) {
      label = 'FITNESS';
      color = Colors.greenAccent;
    } else if (fat <= averageMax) {
      label = 'AVERAGE';
      color = Colors.amberAccent;
    } else {
      label = 'MODERATE';
      color = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Tok.space12,
        vertical: Tok.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Tok.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 0.5),
      ),
      child: Text(
        label,
        style: TokType.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
