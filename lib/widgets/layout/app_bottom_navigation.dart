import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

class AppNavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavDestination> destinations;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        border: Border(
          top: BorderSide(color: colors.outline),
        ),
      ),
      child: Row(
        children: List.generate(destinations.length, (index) {
          final destination = destinations[index];
          final selected = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? destination.activeIcon : destination.icon,
                    color: selected ? colors.textOnSurface : colors.mutedText,
                    size: 20,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? colors.textOnSurface : colors.mutedText,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}