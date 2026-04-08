import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum DashboardTab { kitchen, scan, recipes, planner, profile }

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.activeTab,
    this.showScanTab = false,
  });

  final DashboardTab activeTab;
  final bool showScanTab;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItemData>[
      const _NavItemData(
        icon: Icons.kitchen_rounded,
        label: 'Mutfak',
        tab: DashboardTab.kitchen,
      ),
      if (showScanTab)
        const _NavItemData(
          icon: Icons.camera_alt_rounded,
          label: 'Tara',
          tab: DashboardTab.scan,
        ),
      const _NavItemData(
        icon: Icons.restaurant_menu_rounded,
        label: 'Tarifler',
        tab: DashboardTab.recipes,
      ),
      const _NavItemData(
        icon: Icons.calendar_today_rounded,
        label: 'Planla',
        tab: DashboardTab.planner,
      ),
      const _NavItemData(
        icon: Icons.person_rounded,
        label: 'Profil',
        tab: DashboardTab.profile,
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            return _BottomNavItem(
              icon: item.icon,
              label: item.label,
              active: item.tab == activeTab,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.onPrimary : AppColors.primary,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: active ? AppColors.onPrimary : AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.tab,
  });

  final IconData icon;
  final String label;
  final DashboardTab tab;
}
