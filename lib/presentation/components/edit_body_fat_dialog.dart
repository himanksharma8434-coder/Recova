import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../features/body_age/data/repositories/body_measurement_repository_impl.dart';
import '../../features/body_age/presentation/components/body_fat_guide_sheet.dart';
import '../../services/user_profile_service.dart';
import 'glass_card.dart';
import 'liquid_glass.dart';

/// Modal bottom sheet allowing the user to manually edit and log their body fat percentage.
/// Synchronizes across both [UserProfileService] (baseline profile) and
/// [BodyMeasurementRepository] (historical measurements for body age calculations).
class EditBodyFatDialog extends StatefulWidget {
  final double? initialBodyFat;
  final String? gender;
  final VoidCallback? onSaved;

  const EditBodyFatDialog({
    super.key,
    this.initialBodyFat,
    this.gender,
    this.onSaved,
  });

  /// Shows the dialog as a modal bottom sheet and returns the newly saved body fat percentage (or null if cleared).
  static Future<double?> show(
    BuildContext context, {
    double? initialBodyFat,
    String? gender,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditBodyFatDialog(
        initialBodyFat: initialBodyFat,
        gender: gender,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditBodyFatDialog> createState() => _EditBodyFatDialogState();
}

class _EditBodyFatDialogState extends State<EditBodyFatDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;
  String? _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _gender = widget.gender;
    final initial = widget.initialBodyFat;
    _controller = TextEditingController(
      text: initial != null ? initial.toStringAsFixed(1) : '',
    );
    _controller.addListener(_onTextChanged);

    if (_gender == null) {
      _loadGender();
    }
  }

  Future<void> _loadGender() async {
    final profile = await UserProfileService.getProfile();
    if (mounted) {
      setState(() {
        _gender = profile.gender ?? 'male';
      });
    }
  }

  void _onTextChanged() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  double? get _parsedValue {
    final text = _controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _step(double delta) {
    HapticFeedback.selectionClick();
    final current = _parsedValue ?? 18.0;
    final updated = (current + delta).clamp(3.0, 60.0);
    _controller.text = updated.toStringAsFixed(1);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _setPreset(double val) {
    HapticFeedback.selectionClick();
    _controller.text = val.toStringAsFixed(1);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  /// Calculates clinical classification based on sex.
  _BodyFatClassification _classify(double? fat) {
    if (fat == null) {
      return const _BodyFatClassification(
        label: 'UNSPECIFIED',
        color: Tok.textSecondary,
        description: 'Enter your body fat percentage to calculate category',
      );
    }

    final isFemale = _gender == 'female';
    final athleticMax = isFemale ? 20.0 : 13.0;
    final fitnessMax = isFemale ? 24.0 : 17.0;
    final averageMax = isFemale ? 31.0 : 24.0;
    final overfatMax = isFemale ? 38.0 : 30.0;

    if (fat < (isFemale ? 10.0 : 5.0)) {
      return const _BodyFatClassification(
        label: 'ESSENTIAL',
        color: Colors.cyanAccent,
        description: 'Essential body fat required for physiological health',
      );
    } else if (fat <= athleticMax) {
      return const _BodyFatClassification(
        label: 'ATHLETIC',
        color: Tok.neonAccent,
        description: 'Elite athletic conditioning and low adiposity',
      );
    } else if (fat <= fitnessMax) {
      return const _BodyFatClassification(
        label: 'FITNESS',
        color: Colors.greenAccent,
        description: 'Fit, lean physique supporting longevity and recovery',
      );
    } else if (fat <= averageMax) {
      return const _BodyFatClassification(
        label: 'AVERAGE',
        color: Colors.amberAccent,
        description: 'Typical population baseline range',
      );
    } else if (fat <= overfatMax) {
      return const _BodyFatClassification(
        label: 'MODERATE',
        color: Colors.orangeAccent,
        description: 'Slightly elevated body fat percentage',
      );
    } else {
      return const _BodyFatClassification(
        label: 'ELEVATED',
        color: Tok.recoverySuppressed,
        description: 'High body fat percentage; training & nutrition will optimize',
      );
    }
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      // Clear body fat
      await _clear();
      return;
    }

    final val = double.tryParse(text);
    if (val == null || val < 3.0 || val > 60.0) {
      setState(() {
        _errorMessage = 'Body fat must be between 3.0% and 60.0%';
      });
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final roundedVal = double.parse(val.toStringAsFixed(1));

      // 1. Update UserProfile (baseline)
      final profile = await UserProfileService.getProfile();
      final updatedProfile = profile.copyWith(bodyFatPct: roundedVal);
      await UserProfileService.saveProfile(updatedProfile);

      // 2. Insert into BodyMeasurements table (Drift DB)
      final weightKg = profile.weightKg ?? 70.0;
      await BodyMeasurementRepositoryImpl().saveMeasurement(
        weightKg: weightKg,
        bodyFatPct: roundedVal,
        source: 'manual',
      );

      HapticFeedback.lightImpact();

      widget.onSaved?.call();

      if (mounted) {
        Navigator.of(context).pop(roundedVal);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save: $e';
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _clear() async {
    setState(() => _isSaving = true);

    try {
      final profile = await UserProfileService.getProfile();
      // Remove bodyFatPct from profile
      final updatedProfile = UserProfile(
        age: profile.age,
        gender: profile.gender,
        heightCm: profile.heightCm,
        weightKg: profile.weightKg,
        waistCircumferenceCm: profile.waistCircumferenceCm,
        hipCircumferenceCm: profile.hipCircumferenceCm,
        smokingStatus: profile.smokingStatus,
        stressLevel: profile.stressLevel,
        bodyFatPct: null,
      );
      await UserProfileService.saveProfile(updatedProfile);

      HapticFeedback.lightImpact();

      widget.onSaved?.call();

      if (mounted) {
        Navigator.of(context).pop(null);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to clear: $e';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsedValue;
    final classification = _classify(parsed);

    return Container(
      decoration: const BoxDecoration(
        color: RecovaColors.canvasBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
        border: Border(
          top: BorderSide(color: Tok.glassBorderBright, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: Tok.space20,
        right: Tok.space20,
        top: Tok.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + Tok.space24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Tok.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Header Row with Guide Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EDIT BODY FAT',
                      style: TokType.sectionLabel.copyWith(
                        color: Tok.neonAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manual percentage entry',
                      style: TokType.caption.copyWith(color: Tok.textSecondary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => BodyFatGuideSheet.show(context),
                  child: LiquidGlass(
                    hasBlur: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tok.space10,
                      vertical: Tok.space6,
                    ),
                    borderRadius: BorderRadius.circular(Tok.radiusSm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: Tok.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GUIDE',
                          style: TokType.caption.copyWith(
                            color: Tok.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tok.space20),

            // Value Input Card
            GlassCard(
              padding: const EdgeInsets.all(Tok.space16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Minus 0.5% Stepper Button
                      IconButton(
                        onPressed: () => _step(-0.5),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        iconSize: 32,
                        color: Tok.textSecondary,
                        tooltip: 'Decrease 0.5%',
                      ),
                      const SizedBox(width: Tok.space8),

                      // Numerical Text Field
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TokType.displayNumber.copyWith(
                            fontSize: 36,
                            letterSpacing: -1.0,
                          ),
                          decoration: InputDecoration(
                            hintText: '18.0',
                            hintStyle: TokType.displayNumber.copyWith(
                              fontSize: 36,
                              color: Tok.textMuted,
                            ),
                            suffixText: '%',
                            suffixStyle: TokType.unit.copyWith(
                              fontSize: 18,
                              color: Tok.neonAccent,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: Tok.space8),

                      // Plus 0.5% Stepper Button
                      IconButton(
                        onPressed: () => _step(0.5),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        iconSize: 32,
                        color: Tok.textSecondary,
                        tooltip: 'Increase 0.5%',
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: Tok.space8),
                    Text(
                      _errorMessage!,
                      style: TokType.caption.copyWith(
                        color: Tok.recoverySuppressed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: Tok.space12),

                  // Quick preset pills
                  Wrap(
                    spacing: Tok.space6,
                    runSpacing: Tok.space6,
                    alignment: WrapAlignment.center,
                    children: [10.0, 14.0, 18.0, 22.0, 26.0].map((preset) {
                      final isSelected =
                          parsed != null && (parsed - preset).abs() < 0.1;
                      return GestureDetector(
                        onTap: () => _setPreset(preset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Tok.space10,
                            vertical: Tok.space4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Tok.neonAccent.withValues(alpha: 0.18)
                                : Tok.glassFillRecessed,
                            borderRadius: BorderRadius.circular(Tok.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? Tok.neonAccent
                                  : Tok.glassBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '${preset.toStringAsFixed(0)}%',
                            style: TokType.caption.copyWith(
                              color: isSelected
                                  ? Tok.neonAccent
                                  : Tok.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space16),

            // Live Category Badge
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Tok.space16,
                vertical: Tok.space12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tok.space10,
                      vertical: Tok.space4,
                    ),
                    decoration: BoxDecoration(
                      color: classification.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: classification.color.withValues(alpha: 0.8),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      classification.label,
                      style: TokType.caption.copyWith(
                        color: classification.color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: Tok.space12),
                  Expanded(
                    child: Text(
                      classification.description,
                      style: TokType.bodySmall.copyWith(
                        color: Tok.textSecondary,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tok.space20),

            // Action Buttons (Clear & Save)
            Row(
              children: [
                if (widget.initialBodyFat != null || parsed != null) ...[
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _isSaving ? null : _clear,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Tok.glassFillRecessed,
                          borderRadius: BorderRadius.circular(Tok.radiusSm),
                          border: Border.all(color: Tok.glassBorder, width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            'CLEAR',
                            style: TokType.caption.copyWith(
                              color: Tok.textSecondary,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Tok.space12),
                ],
                Expanded(
                  flex: 5,
                  child: LiquidGlassButton(
                    label: _isSaving ? 'SAVING...' : 'SAVE BODY FAT',
                    height: 48,
                    accentColor: Tok.recoveryOptimal,
                    onTap: _isSaving ? () {} : _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyFatClassification {
  final String label;
  final Color color;
  final String description;

  const _BodyFatClassification({
    required this.label,
    required this.color,
    required this.description,
  });
}
