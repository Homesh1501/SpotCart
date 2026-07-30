import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/vendor_dashboard.dart';
import '../../dashboard/presentation/menu_manager_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'live_update_screen.dart';
import 'vendor_analytics_screen.dart';
import '../../../theme.dart';

class VendorNavigationShell extends ConsumerStatefulWidget {
  const VendorNavigationShell({super.key});

  @override
  ConsumerState<VendorNavigationShell> createState() => _VendorNavigationShellState();
}

class _VendorNavigationShellState extends ConsumerState<VendorNavigationShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const VendorDashboard(), // Tab 0: Dashboard
      const MenuManagerScreen(), // Tab 1: Menu Manager
      const LiveUpdateScreen(), // Tab 2: Live Location Update
      const VendorAnalyticsScreen(), // Tab 3: Analytics
      const SharedProfileScreen(role: 'vendor'), // Tab 4: Profile Settings
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Live Broadcast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Stall Profile',
          ),
        ],
      ),
    );
  }
}
