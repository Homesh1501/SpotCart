import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/location_service.dart';
import '../../../theme.dart';

class SharedProfileScreen extends ConsumerWidget {
  final String role; // 'customer', 'vendor', 'admin'
  const SharedProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final isVendorOnline = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getRoleBadgeText(role)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Hub / Switch Role',
          onPressed: () {
            ref.read(authControllerProvider.notifier).changeRole();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
                      child: Icon(
                        _getRoleIcon(role),
                        size: 48,
                        color: _getRoleColor(role),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? _getDefaultName(role),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? '+91 99999 55555',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getRoleColor(role)),
                      ),
                      child: Text(
                        _getRoleBadgeText(role).toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(role),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Vendor Specific Status Card
            if (role == 'vendor') ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Stall Active Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          isVendorOnline ? 'ONLINE — Broadcasting live location' : 'OFFLINE — Cart closed',
                        ),
                        secondary: Icon(
                          Icons.storefront,
                          color: isVendorOnline ? AppTheme.statusGreen : Colors.grey,
                        ),
                        value: isVendorOnline,
                        onChanged: (val) {
                          ref.read(locationServiceProvider.notifier).toggleOnlineOffline();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Quick Links
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz, color: Colors.indigo),
                    title: const Text('Switch Account Role'),
                    subtitle: const Text('Return to Role Selection & Prototype Hub'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).changeRole();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.brightness_6, color: Colors.orange),
                    title: const Text('Appearance'),
                    subtitle: Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.teal),
                    title: const Text('Default City / Region'),
                    subtitle: const Text('Chennai, Tamil Nadu'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.redAccent),
                    title: const Text('Logout Session'),
                    subtitle: const Text('Sign out of active device'),
                    trailing: const Icon(Icons.logout, color: Colors.redAccent),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'vendor':
        return AppTheme.statusGreen;
      case 'admin':
        return Colors.deepPurple;
      default:
        return AppTheme.primaryOrange;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'vendor':
        return Icons.storefront;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getRoleBadgeText(String role) {
    switch (role) {
      case 'vendor':
        return 'Food Vendor Profile';
      case 'admin':
        return 'Admin Command Center';
      default:
        return 'Customer Profile';
    }
  }

  String _getDefaultName(String role) {
    switch (role) {
      case 'vendor':
        return 'Spicy Fish Tacos Cart';
      case 'admin':
        return 'Platform Administrator';
      default:
        return 'Rahul Kumar';
    }
  }
}
