import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import 'home_dashboard_screen.dart';
import 'library_screen.dart';
import 'progress_screen.dart';
import 'parent_hub_screen.dart';
import 'child_profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    HomeDashboardScreen(),
    LibraryScreen(),
    ProgressScreen(),
    ParentHubScreen(),
    ChildProfileScreen(),
  ];

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.auto_stories_rounded, label: 'Stories'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItem(icon: Icons.workspace_premium_rounded, label: 'Parent'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentIndex = appState.currentTabIndex;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.night,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _KidBottomBar(
        currentIndex: currentIndex,
        items: _items,
        onTap: appState.setTabIndex,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _KidBottomBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _KidBottomBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomBarDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 9, bottom: bottomInset > 0 ? bottomInset - 2 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: Semantics(
              label: item.label,
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 44 : 38,
                        height: isSelected ? 44 : 38,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF9A63C4), Color(0xFF6F3C97)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.bottomBarGlow.withValues(alpha: 0.36),
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.46),
                          size: isSelected ? 23 : 22,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.headerGlow,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
