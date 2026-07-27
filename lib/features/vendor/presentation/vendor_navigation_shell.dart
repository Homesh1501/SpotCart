import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/presentation/vendor_dashboard.dart';
import '../../dashboard/presentation/menu_manager_screen.dart';
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
      const VendorProfileScreen(), // Tab 4: Profile Settings
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

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stall Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            ref.read(authControllerProvider.notifier).changeRole();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stall Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                      child: const Icon(Icons.storefront, size: 48, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user?.name ?? 'My Tamil Nadu Street Stall',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.statusGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'VERIFIED VENDOR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.statusGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          authState.user?.phoneNumber ?? '+91 99999 11111',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Settings Section
            Text(
              'Stall Specifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_road),
                    title: const Text('Operating License'),
                    subtitle: const Text('FSSAI Reg: 23321008000142'),
                    trailing: const Icon(Icons.verified, color: Colors.blue),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Primary Food Type'),
                    trailing: const Text('Tiffin / Fast Food', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Standard Operating Hours'),
                    trailing: const Text('5:00 PM - 11:30 PM', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Settings options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme Settings'),
                    subtitle: Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: const Text('Vendor Helpdesk'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
