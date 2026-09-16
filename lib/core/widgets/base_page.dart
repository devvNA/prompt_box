import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/notification/screens/notification_page.dart';
import '../../features/profile/screens/profile_page.dart';
import '../theme/app_colors.dart';

/// Data class representing a tab item in BasePage
class BaseTabItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget page;

  const BaseTabItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.page,
  });
}

/// HomePage wrapper embedding DashboardScreen without redundant bottom nav
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(showBottomNav: false);
  }
}

/// ExplorePage wrapper embedding ExploreScreen without redundant bottom nav
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return const ExploreScreen(showBottomNav: false);
  }
}

/// BasePage acts as the primary parent scaffold holding the bottom navigation
/// and switching screens via [IndexedStack] to preserve each tab's state.
class BasePage extends ConsumerStatefulWidget {
  final int initialIndex;
  final List<BaseTabItem>? customTabs;

  const BasePage({super.key, this.initialIndex = 0, this.customTabs});

  /// Allows descendant widgets to change tabs programmatically
  static BasePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<BasePageState>();
  }

  @override
  ConsumerState<BasePage> createState() => BasePageState();
}

class BasePageState extends ConsumerState<BasePage> {
  late int _currentIndex;
  late final List<BaseTabItem> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabs = widget.customTabs ?? _defaultTabs();
  }

  /// Change active tab index
  void setTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Default application tabs
  List<BaseTabItem> _defaultTabs() {
    return const [
      BaseTabItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_filled,
        page: HomePage(),
      ),
      BaseTabItem(
        label: 'Explore',
        icon: Icons.search,
        activeIcon: Icons.search,
        page: ExplorePage(),
      ),
      BaseTabItem(
        label: 'Notifications',
        icon: Icons.notifications_none_outlined,
        activeIcon: Icons.notifications,
        page: NotificationPage(),
      ),
      BaseTabItem(
        label: 'Profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        page: ProfilePage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.ink,
          unselectedItemColor: AppColors.muted,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(tab.icon, size: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(tab.activeIcon ?? tab.icon, size: 24),
              ),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
