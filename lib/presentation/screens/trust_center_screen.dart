import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/engine_config.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/services/data_management_service.dart';
import '../components/liquid_glass.dart';
import 'methodology_sheet.dart';
import 'wearable_signal_comparator_screen.dart';

/// Screen providing complete transparency into the app's offline architecture,
/// FDA 2026 wellness compliance, sensor limitations, and user data rights (Export & Erase).
class TrustCenterScreen extends StatefulWidget {
  const TrustCenterScreen({super.key});

  @override
  State<TrustCenterScreen> createState() => _TrustCenterScreenState();
}

class _TrustCenterScreenState extends State<TrustCenterScreen> {
  final _dataService = DataManagementService();
  bool _isExporting = false;
  bool _isWiping = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final result = await _dataService.saveExportsToLocalFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Tok.glassFillElevated,
          content: Text(
            'Health data exported to:\n${result.jsonPath}',
            style: const TextStyle(fontSize: 12, color: RecovaColors.monochromeWhite),
          ),
          action: SnackBarAction(
            label: 'COPY JSON',
            textColor: Tok.neonAccent,
            onPressed: () async {
              final jsonStr = await _dataService.exportToJsonString();
              await Clipboard.setData(ClipboardData(text: jsonStr));
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Tok.recoverySuppressed,
          content: Text('Export failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _confirmWipeData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RecovaColors.canvasBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tok.radiusMd),
          side: const BorderSide(color: Tok.recoverySuppressed, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Tok.recoverySuppressed,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'PERMANENT DATA WIPE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: RecovaColors.monochromeWhite,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently and irreversibly purge all 14 SQLite database tables, '
          'including historical biometrics, sleep sessions, workouts, and personal baselines.\n\n'
          'Because Recova is 100% offline, this data cannot be recovered.',
          style: TextStyle(fontSize: 12.5, color: Tok.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: Tok.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Tok.recoverySuppressed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DELETE ALL DATA'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isWiping = true);
      try {
        final tableCount = await _dataService.wipeAllLocalData();
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Tok.recoverySuppressed,
            content: Text(
              'Successfully erased $tableCount database tables and user preferences.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erase failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _isWiping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecovaColors.canvasBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Tok.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRUST & DATA PRIVACY',
              style: TokType.sectionLabel.copyWith(
                letterSpacing: 1.3,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Tok.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '100% Offline-First • Zero Cloud Telemetry',
              style: TokType.caption.copyWith(fontSize: 10, color: Tok.textSecondary),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── 1. Offline Sovereignty ──
          _buildCard(
            title: '1. Local Offline Sovereignty',
            badge: 'NO CLOUD SELLING',
            badgeColor: Tok.recoveryOptimal,
            content:
                '• All biometric records are written exclusively to local SQLite on this device.\n'
                '• Zero telemetry trackers, advertising pixels, or third-party cloud analytics.\n'
                '• Your physiological data belongs 100% to you and never leaves your phone without explicit export.',
          ),
          const SizedBox(height: 14),

          // ── 2. FDA Jan 2026 Wellness Compliance ──
          _buildCard(
            title: '2. FDA 2026 General Wellness Compliance',
            badge: 'JAN 2026 FINAL GUIDANCE',
            badgeColor: Tok.neonAccent,
            content:
                '• Recova is intended solely for general wellness and athletic conditioning.\n'
                '• It does not make claims of clinical equivalence, clinical accuracy, or medical diagnosis.\n'
                '• Out-of-range vitals reflect physiological trends and deviations from personal baselines, never clinical diseases (e.g. sleep apnea, hypertension, or arrhythmia).\n'
                '• When out-of-range readings persist, athletes are advised to consult a qualified physician.',
          ),
          const SizedBox(height: 14),

          // ── 3. Sensor Physics & Limitations ──
          _buildCard(
            title: '3. Sensor Physics & Limitations',
            badge: 'TRANSPARENT SCIENCE',
            badgeColor: Tok.accentBlue,
            content:
                '• Optical PPG sensors detect pulsatile blood flow via light absorption in wrist arterioles.\n'
                '• Wrist optical readings are sensitive to motion artifacts, skin temperature, peripheral vasoconstriction, and strap tension.\n'
                '• Gold-standard ECG chest straps (e.g., Polar H10) sample electrical cardiac depolarization directly (QRS peak) and provide higher millisecond precision during exercise.\n'
                '• Skin temperature measures relative cutaneous deviation, not internal core temperature.',
          ),
          const SizedBox(height: 14),

          // ── 4. Provenance & No Fabricated Data ──
          _buildCard(
            title: '4. Honest Data Provenance',
            badge: 'ZERO FAKE DATA',
            badgeColor: Tok.accentViolet,
            content:
                '• When wearable hardware omits raw beat-to-beat variability, Recova uses transparent nocturnal PPG interval derivation and explicitly tags the output as ESTIMATED.\n'
                '• If sleep stage telemetry is missing, we report total sleep duration honestly rather than synthesizing synthetic deep/REM fractions.\n'
                '• Initial days of use display explicit CALIBRATING badges while your 60-day baseline forms.',
          ),
          const SizedBox(height: 18),

          // ── 5. User Data Rights (Export & Erase) ──
          LiquidGlass(
            borderRadius: BorderRadius.circular(Tok.radiusMd),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '5. User Data Sovereignty Controls',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: RecovaColors.monochromeWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Tok.neonAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Tok.neonAccent.withValues(alpha: 0.35), width: 0.8),
                      ),
                      child: const Text(
                        'EXPORT & ERASE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Tok.neonAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Export your full biometric history to structured JSON / CSV, or permanently erase all local records with zero cloud residue.',
                  style: TextStyle(fontSize: 11.5, color: Tok.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 16),

                // Export Button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isExporting ? null : _handleExport,
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Tok.glassFillElevated,
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(color: Tok.glassBorderBright, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Tok.neonAccent),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.download_rounded, color: Tok.neonAccent, size: 16),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'EXPORT ALL DATA (JSON & CSV)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Tok.neonAccent,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),

                // Erase Button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isWiping ? null : _confirmWipeData,
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Tok.recoverySuppressed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Tok.radiusSm),
                      border: Border.all(
                        color: Tok.recoverySuppressed.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _isWiping
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Tok.recoverySuppressed),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.delete_forever_rounded, color: Tok.recoverySuppressed, size: 16),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'PERMANENTLY ERASE ALL LOCAL DATA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Tok.recoverySuppressed,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Sensor Accuracy & BLE Comparator Link ──
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WearableSignalComparatorScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(Tok.radiusSm),
                border: Border.all(color: Tok.glassBorder, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'SENSOR ACCURACY & BLE COMPARATOR',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Tok.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Empirical test: Wrist Optical PPG vs Chest-Strap ECG',
                          style: TextStyle(fontSize: 10, color: Tok.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Tok.textSecondary, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 6. Algorithm Methodology Link ──
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => MethodologySheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Tok.glassFillRecessed,
                borderRadius: BorderRadius.circular(Tok.radiusSm),
                border: Border.all(color: Tok.glassBorder, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALGORITHM VERSION ${EngineConfig.algorithmVersion}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Tok.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'View formulas, physiological weights & peer-reviewed citations',
                          style: TextStyle(fontSize: 10, color: Tok.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Tok.textSecondary, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tok.glassFill,
        borderRadius: BorderRadius.circular(Tok.radiusMd),
        border: Border.all(color: Tok.glassBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: RecovaColors.monochromeWhite,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 0.8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11.5,
              color: Tok.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
