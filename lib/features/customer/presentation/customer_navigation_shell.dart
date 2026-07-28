import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../theme.dart';

// Import customer screens
import 'customer_home_screen.dart';
import '../presentation/favorites_screen.dart';
import '../presentation/notifications_screen.dart';
import '../../map/presentation/customer_map_screen.dart';

class CustomerNavigationShell extends ConsumerStatefulWidget {
  const CustomerNavigationShell({super.key});

  @override
  ConsumerState<CustomerNavigationShell> createState() => _CustomerNavigationShellState();
}

class _CustomerNavigationShellState extends ConsumerState<CustomerNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CustomerHomeScreen(onMapToggle: () {
        setState(() {
          _currentIndex = 2; // Index of Map Tab
        });
      }),
      const FavoritesScreen(),
      const CustomerMapScreen(),
      const NotificationsScreen(),
      const SharedProfileScreen(role: 'customer'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
