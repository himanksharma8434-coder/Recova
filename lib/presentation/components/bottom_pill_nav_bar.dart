import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/design_tokens.dart';

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
          child: _LiquidGlassPremium(
            child: Padding(
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
        ), // Close _LiquidGlassPremium
        ), // Close Container
      ), // Close Center
    ); // Close SafeArea
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final tabColor = _tabAccentColor(index);
    final color = isSelected ? tabColor : Tok.textSecondary;

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

class _LiquidGlassPremium extends StatelessWidget {
  final Widget child;
  const _LiquidGlassPremium({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: const ColorFilter.matrix(<double>[
              0.2126 + 0.7874 * 1.8, 0.7152 - 0.7152 * 1.8, 0.0722 - 0.0722 * 1.8, 0, 0,
              0.2126 - 0.2126 * 1.8, 0.7152 + 0.2848 * 1.8, 0.0722 - 0.0722 * 1.8, 0, 0,
              0.2126 - 0.2126 * 1.8, 0.7152 - 0.7152 * 1.8, 0.0722 + 0.9278 * 1.8, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            inner: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base color & Border
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.25),
                    width: 1,
                  ),
                ),
              ),
              // Inner top highlight
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(255, 255, 255, 0.4),
                        Color.fromRGBO(255, 255, 255, 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Inner bottom pink reflection
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromRGBO(255, 0, 128, 0.1),
                        Color.fromRGBO(255, 0, 128, 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              child,
            ],
          ),
        ),
      ),
    );
  }
}

