import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/recova_colors.dart';
import '../../domain/body_engine/journal_engine.dart';
import '../../domain/repositories/health_source_repository.dart';
import '../screens/journal_impact_screen.dart';
import 'liquid_glass.dart';

/// Quick-tap behavioral journal pod for logging lifestyle habits and viewing 30-day impact.
class JournalQuickTapPod extends StatefulWidget {
  final DerivedMetricSummary? summary;
  final VoidCallback? onTagToggled;

  const JournalQuickTapPod({
    super.key,
    required this.summary,
    this.onTagToggled,
  });

  @override
  State<JournalQuickTapPod> createState() => _JournalQuickTapPodState();
}

class _JournalQuickTapPodState extends State<JournalQuickTapPod> {
  late Set<String> _activeTags;

  @override
  void initState() {
    super.initState();
    _activeTags = (widget.summary?.todayLoggedTags ?? []).toSet();
  }

  @override
  void didUpdateWidget(covariant JournalQuickTapPod oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary?.todayLoggedTags != oldWidget.summary?.todayLoggedTags) {
      _activeTags = (widget.summary?.todayLoggedTags ?? []).toSet();
    }
  }

  Future<void> _toggleTag(String tagKey) async {
    final repo = sl<HealthSourceRepository>();
    final isNowActive = !_activeTags.contains(tagKey);

    setState(() {
      if (isNowActive) {
        _activeTags.add(tagKey);
      } else {
        _activeTags.remove(tagKey);
      }
    });

    await repo.toggleJournalTag(tagKey);
    widget.onTagToggled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tags = BehaviorTagDefinition.defaults;
    final loggedCount = _activeTags.length;

    return LiquidGlass(
      borderRadius: BorderRadius.circular(Tok.radiusMd),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row ──
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 15,
                    color: Tok.neonAccent,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'DAILY BEHAVIORS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: RecovaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (loggedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Tok.neonAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$loggedCount LOGGED',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Tok.neonAccent,
                    ),
                  ),
                ),
              // View Impact Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JournalImpactScreen(summary: widget.summary),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: RecovaColors.surfaceElevation3,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: RecovaColors.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'HABIT IMPACT',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Tok.neonAccent,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 11,
                        color: Tok.neonAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Quick-Tap Tag Pills Horizontal Scroll ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: tags.map((def) {
                final isSelected = _activeTags.contains(def.key);
                final isNegative = def.category == 'recovery_suppressor';
                final activeBorderColor = isNegative
                    ? Tok.recoverySuppressed
                    : Tok.neonAccent;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _toggleTag(def.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeBorderColor.withValues(alpha: 0.18)
                              : RecovaColors.surfaceElevation2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? activeBorderColor.withValues(alpha: 0.8)
                                : RecovaColors.borderSubtle,
                            width: isSelected ? 1.2 : 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconData(def.iconName),
                              size: 13,
                              color: isSelected
                                  ? activeBorderColor
                                  : RecovaColors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              def.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? RecovaColors.textPrimary
                                    : RecovaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'wine_bar':
        return Icons.wine_bar_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'coronavirus':
        return Icons.sick_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'hot_tub':
        return Icons.hot_tub_rounded;
      case 'air':
        return Icons.air_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }
}
