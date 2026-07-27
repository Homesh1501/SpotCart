import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../theme.dart';

// Import customer screens
import 'customer_home_screen.dart';
import '../presentation/favorites_screen.dart'; // We will use Favorites as Explore/Leaderboard
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
      const FavoritesScreen(), // Explore tab showing leaderboards, rewards, badges
      const CustomerMapScreen(), // Live Leaflet Map
      const NotificationsScreen(), // Alerts
      const CustomerProfileScreen(), // Profile
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

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
            // User Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                      child: const Icon(Icons.person, size: 36, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.name ?? 'SpotCart Customer',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.user?.phoneNumber ?? '+91 99999 11111',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Favorite cuisine list
            Text(
              'My Food Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildPreferenceChip('Dosa'),
                _buildPreferenceChip('Parotta'),
                _buildPreferenceChip('Biryani'),
                _buildPreferenceChip('Filter Coffee'),
                _buildPreferenceChip('Kothu Parotta'),
              ],
            ),
            const SizedBox(height: 32),
            
            // Settings options
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
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Language'),
                    trailing: const Text('Tamil / English', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
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

  Widget _buildPreferenceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
