import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import 'liquid_glass.dart';

class BottomPillNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const BottomPillNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  Color _tabAccentColor(int index) {
    switch (index) {
      case 0:
        return Tok.neonAccent;
      case 1:
        return Tok.recoveryOptimal;
      case 2:
        return Tok.accentAmber;
      case 3:
        return Tok.accentBlue;
      default:
        return Tok.neonAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.only(
            bottom: Tok.space12,
            left: Tok.space20,
            right: Tok.space20,
          ),
          child: LiquidGlass(
            height: 62,
            borderRadius: BorderRadius.circular(36),
            padding: const EdgeInsets.symmetric(horizontal: Tok.space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.monitor_heart_outlined,
                  activeIcon: Icons.monitor_heart,
                  label: 'Pulse',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Recovery',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.bolt_outlined,
                  activeIcon: Icons.bolt,
                  label: 'Strain',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.bedtime_outlined,
                  activeIcon: Icons.bedtime,
                  label: 'Sleep',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final tabColor = _tabAccentColor(index);
    final color = isSelected ? tabColor : Tok.textTertiary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Tok.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: Tok.animFast,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: Tok.space2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.5,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Tok.space2),
              AnimatedContainer(
                duration: Tok.animFast,
                width: isSelected ? 4.0 : 0,
                height: isSelected ? 4.0 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tabColor,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: tabColor.withValues(alpha: 0.7),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              ),
              if (!isSelected) const SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
