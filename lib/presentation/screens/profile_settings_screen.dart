import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../services/user_profile_service.dart';
import '../components/ambient_glow_backdrop.dart';
import '../components/glass_card.dart';
import '../components/liquid_glass.dart';

/// Screen allowing the user to configure their baseline biometrics
/// (body weight, height, age, and gender) for body age and recovery.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfileService.getProfile();
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
        _selectedGender = profile.gender ?? 'male';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double? get _parsedHeight => double.tryParse(_heightController.text.trim());
  double? get _parsedWeight => double.tryParse(_weightController.text.trim());
  int? get _parsedAge => int.tryParse(_ageController.text.trim());

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

    final profile = UserProfile(
      age: age,
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
    );

    await UserProfileService.saveProfile(profile);
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
                      color: Tok.textTertiary,
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
                        color: Tok.textMuted,
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
                    style: TokType.bodySmall.copyWith(color: Tok.textMuted),
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
                                  color: Tok.textMuted,
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
                                  color: Tok.textMuted,
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
                                        .copyWith(color: Tok.textMuted)),
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
                                        .copyWith(color: Tok.textMuted)),
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
                color: isSelected ? Tok.textPrimary : Tok.textMuted,
              ),
              const SizedBox(width: Tok.space8),
              Text(
                label,
                style: TokType.caption.copyWith(
                  color: isSelected ? Tok.textPrimary : Tok.textMuted,
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
}
