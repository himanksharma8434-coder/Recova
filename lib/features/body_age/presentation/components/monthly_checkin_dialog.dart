import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/design_tokens.dart';
import '../cubits/body_age_checkin/body_age_checkin_cubit.dart';
import '../cubits/body_age_checkin/body_age_checkin_state.dart';
import 'body_fat_guide_sheet.dart';

/// Interactive dialog/sheet for the user's monthly body measurement check-in.
class MonthlyCheckinDialog extends StatefulWidget {
  final double? prefilledWeight;
  final double? prefilledBodyFat;
  final bool initialIsKg;

  const MonthlyCheckinDialog({
    super.key,
    this.prefilledWeight,
    this.prefilledBodyFat,
    this.initialIsKg = true,
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BodyAgeCheckinCubit>(),
        child: const MonthlyCheckinDialog(),
      ),
    );
  }

  @override
  State<MonthlyCheckinDialog> createState() => _MonthlyCheckinDialogState();
}

class _MonthlyCheckinDialogState extends State<MonthlyCheckinDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _bodyFatController;

  late bool _isKg;
  bool _skipBodyFat = false;
  String? _weightError;
  String? _bodyFatError;

  @override
  void initState() {
    super.initState();
    _isKg = widget.initialIsKg;

    final initialWeight = widget.prefilledWeight;
    _weightController = TextEditingController(
      text: initialWeight != null ? initialWeight.toStringAsFixed(1) : '',
    );

    final initialFat = widget.prefilledBodyFat;
    _bodyFatController = TextEditingController(
      text: initialFat != null ? initialFat.toStringAsFixed(1) : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _weightError = null;
      _bodyFatError = null;
    });

    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      setState(() => _weightError = 'Please enter your weight');
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null) {
      setState(() => _weightError = 'Enter a valid number');
      return;
    }

    // Weight range validation: 25-300 kg (or 55-660 lbs)
    final minWeight = _isKg ? 25.0 : 55.0;
    final maxWeight = _isKg ? 300.0 : 660.0;
    if (weight < minWeight || weight > maxWeight) {
      setState(() => _weightError =
          'Weight must be between ${minWeight.toInt()} and ${maxWeight.toInt()} ${_isKg ? 'kg' : 'lbs'}');
      return;
    }

    double? bodyFat;
    if (!_skipBodyFat && _bodyFatController.text.trim().isNotEmpty) {
      bodyFat = double.tryParse(_bodyFatController.text.trim());
      if (bodyFat == null || bodyFat < 3.0 || bodyFat > 60.0) {
        setState(() => _bodyFatError = 'Body fat must be between 3% and 60%');
        return;
      }
    }

    context.read<BodyAgeCheckinCubit>().saveCheckin(
          weightInput: weight,
          isKg: _isKg,
          bodyFatPct: _skipBodyFat ? null : bodyFat,
        );
  }

  void _toggleUnit(bool toKg) {
    if (_isKg == toKg) return;
    final currentWeight = double.tryParse(_weightController.text.trim());
    setState(() {
      _isKg = toKg;
      if (currentWeight != null) {
        final converted = toKg ? currentWeight * 0.45359237 : currentWeight / 0.45359237;
        _weightController.text = converted.toStringAsFixed(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BodyAgeCheckinCubit, BodyAgeCheckinState>(
      listener: (context, state) {
        if (state is BodyAgeCheckinDismissed) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isSuccess = state is BodyAgeCheckinSuccess;
        final isSaving = state is BodyAgeCheckinSaving;

        return Container(
          decoration: const BoxDecoration(
            color: Tok.canvasBase,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Tok.radiusLg)),
            border: Border(top: BorderSide(color: Tok.glassBorderBright)),
          ),
          padding: EdgeInsets.only(
            left: Tok.space20,
            right: Tok.space20,
            top: Tok.space16,
            bottom: MediaQuery.of(context).viewInsets.bottom + Tok.space24,
          ),
          child: SingleChildScrollView(
            child: isSuccess
                ? _buildSuccessView(context, state)
                : _buildFormView(context, isSaving),
          ),
        );
      },
    );
  }

  Widget _buildFormView(BuildContext context, bool isSaving) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Tok.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: Tok.space16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY CHECK-IN',
                  style: TokType.sectionLabel.copyWith(
                    color: Tok.neonAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your body measurements',
                  style: TokType.heading.copyWith(color: Tok.textPrimary),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Tok.textSecondary),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: Tok.space20),

        // ── Weight Field ──
        Text(
          'BODY WEIGHT',
          style: TokType.sectionLabel,
        ),
        const SizedBox(height: Tok.space8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: TokType.metricMedium.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  hintText: _isKg ? 'e.g. 74.5' : 'e.g. 164.2',
                  hintStyle: TokType.body.copyWith(color: Tok.textMuted),
                  errorText: _weightError,
                  filled: true,
                  fillColor: Tok.glassFillRecessed,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Tok.space16,
                    vertical: Tok.space14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    borderSide: const BorderSide(color: Tok.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    borderSide: const BorderSide(color: Tok.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Tok.radiusMd),
                    borderSide: const BorderSide(color: Tok.neonAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Tok.space12),

            // Unit toggle pills
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                border: Border.all(color: Tok.glassBorder),
              ),
              child: Row(
                children: [
                  _buildUnitTab(label: 'KG', isSelected: _isKg, onTap: () => _toggleUnit(true)),
                  _buildUnitTab(label: 'LBS', isSelected: !_isKg, onTap: () => _toggleUnit(false)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Tok.space20),

        // ── Body Fat Field ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BODY FAT % (OPTIONAL)',
              style: TokType.sectionLabel,
            ),
            InkWell(
              onTap: () => BodyFatGuideSheet.show(context),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, size: 14, color: Tok.neonAccent),
                  const SizedBox(width: 4),
                  Text(
                    'How to measure?',
                    style: TokType.caption.copyWith(color: Tok.neonAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Tok.space8),

        if (!_skipBodyFat)
          TextField(
            controller: _bodyFatController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: TokType.metricMedium.copyWith(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g. 16.5',
              suffixText: '%',
              suffixStyle: TokType.unit,
              hintStyle: TokType.body.copyWith(color: Tok.textMuted),
              errorText: _bodyFatError,
              filled: true,
              fillColor: Tok.glassFillRecessed,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Tok.space16,
                vertical: Tok.space14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                borderSide: const BorderSide(color: Tok.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                borderSide: const BorderSide(color: Tok.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                borderSide: const BorderSide(color: Tok.neonAccent),
              ),
            ),
          ),

        Row(
          children: [
            Checkbox(
              value: _skipBodyFat,
              activeColor: Tok.neonAccent,
              checkColor: Colors.black,
              onChanged: (val) {
                setState(() {
                  _skipBodyFat = val ?? false;
                  if (_skipBodyFat) _bodyFatError = null;
                });
              },
            ),
            Text(
              'Skip body fat (use BMI instead)',
              style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: Tok.space24),

        // ── Action Buttons ──
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isSaving ? null : _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Tok.neonAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    'SAVE & UPDATE BODY AGE',
                    style: TokType.cardTitle.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: Tok.space12),

        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.read<BodyAgeCheckinCubit>().snoozeCheckin(),
                child: Text(
                  'Remind me in 3 days',
                  style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => context.read<BodyAgeCheckinCubit>().skipThisMonth(),
                child: Text(
                  'Skip this month',
                  style: TokType.bodySmall.copyWith(color: Tok.textMuted),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, BodyAgeCheckinSuccess state) {
    final diff = state.deltaFromPrevious;
    final isImproved = diff < 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: Tok.space12),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Tok.neonAccentSurface,
            shape: BoxShape.circle,
            border: Border.all(color: Tok.neonAccentGlow),
          ),
          child: const Icon(Icons.check, color: Tok.neonAccent, size: 30),
        ),
        const SizedBox(height: Tok.space16),

        Text(
          'CHECK-IN COMPLETE',
          style: TokType.sectionLabel.copyWith(
            color: Tok.neonAccent,
          ),
        ),
        const SizedBox(height: Tok.space8),
        Text(
          'New Functional Body Age',
          style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
        ),
        const SizedBox(height: Tok.space4),
        Text(
          state.newBodyAge.toStringAsFixed(1),
          style: TokType.displayNumber.copyWith(
            color: Tok.textPrimary,
          ),
        ),
        const SizedBox(height: Tok.space8),

        if (state.previousBodyAge != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Tok.space12,
              vertical: Tok.space6,
            ),
            decoration: BoxDecoration(
              color: isImproved ? Colors.green.withValues(alpha: 0.15) : Tok.glassFillRecessed,
              borderRadius: BorderRadius.circular(Tok.radiusFull),
              border: Border.all(
                color: isImproved ? Colors.green : Tok.glassBorder,
              ),
            ),
            child: Text(
              isImproved
                  ? '▼ ${diff.abs().toStringAsFixed(1)} years younger than last check-in'
                  : '▲ ${diff.abs().toStringAsFixed(1)} years vs last check-in',
              style: TokType.caption.copyWith(
                color: isImproved ? Colors.greenAccent : Tok.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: Tok.space24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Tok.glassFillElevated,
              foregroundColor: Tok.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Tok.radiusMd),
                side: const BorderSide(color: Tok.glassBorder),
              ),
            ),
            child: const Text('DONE'),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Tok.space14, vertical: Tok.space10),
        decoration: BoxDecoration(
          color: isSelected ? Tok.glassFillElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(Tok.radiusMd - 2),
        ),
        child: Text(
          label,
          style: TokType.caption.copyWith(
            color: isSelected ? Tok.neonAccent : Tok.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
