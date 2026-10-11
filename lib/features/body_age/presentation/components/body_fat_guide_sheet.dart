import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../presentation/components/glass_card.dart';

/// Modal bottom sheet providing educational guidance on how to measure body fat %.
class BodyFatGuideSheet extends StatelessWidget {
  const BodyFatGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const BodyFatGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
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

          Text(
            'HOW TO MEASURE BODY FAT %',
            style: TokType.sectionLabel.copyWith(
              color: Tok.neonAccent,
            ),
          ),
          const SizedBox(height: Tok.space8),
          Text(
            'Ways to check your body composition at home or in a clinic:',
            style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
          ),
          const SizedBox(height: Tok.space16),

          _buildMethodCard(
            title: '1. Smart Bathroom Scale (BIA)',
            description:
                'Scales with bioelectrical impedance sensors estimate fat % using safe micro-currents. Weigh yourself first thing in the morning.',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: Tok.space12),

          _buildMethodCard(
            title: '2. Skinfold Calipers',
            description:
                'Inexpensive manual calipers measure skinfold pinch thickness at standard sites (chest, abdominal, thigh) using Jackson-Pollock formulas.',
            icon: Icons.straighten_outlined,
          ),
          const SizedBox(height: Tok.space12),

          _buildMethodCard(
            title: '3. DEXA Scan / Clinic Test',
            description:
                'Dual-energy X-ray absorptiometry or Bod Pod is the gold standard clinical measurement often available at gyms or health centers.',
            icon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: Tok.space16),

          GlassCard(
            padding: const EdgeInsets.all(Tok.space12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Tok.textSecondary, size: 20),
                const SizedBox(width: Tok.space12),
                Expanded(
                  child: Text(
                    'Optional: You can skip body fat anytime. The engine will safely use your BMI instead.',
                    style: TokType.caption.copyWith(color: Tok.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tok.space20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Tok.glassFillElevated,
                foregroundColor: Tok.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: Tok.space14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Tok.radiusMd),
                  side: const BorderSide(color: Tok.glassBorder),
                ),
              ),
              child: const Text('GOT IT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(Tok.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Tok.space8),
            decoration: BoxDecoration(
              color: Tok.glassFillRecessed,
              borderRadius: BorderRadius.circular(Tok.radiusSm),
            ),
            child: Icon(icon, color: Tok.textPrimary, size: 20),
          ),
          const SizedBox(width: Tok.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TokType.cardTitle.copyWith(
                    color: Tok.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TokType.bodySmall.copyWith(color: Tok.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
