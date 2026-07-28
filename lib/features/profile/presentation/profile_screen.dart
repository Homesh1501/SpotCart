import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/location_service.dart';
import '../../../theme.dart';

class SharedProfileScreen extends ConsumerStatefulWidget {
  final String role; // 'customer', 'vendor', 'admin'
  const SharedProfileScreen({super.key, required this.role});

  @override
  ConsumerState<SharedProfileScreen> createState() => _SharedProfileScreenState();
}

class _SharedProfileScreenState extends ConsumerState<SharedProfileScreen> {
  bool _showPassword = false;

  void _openEditProfileSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(authControllerProvider).user;

    final nameController = TextEditingController(text: user?.name ?? 'Homesh User');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '+91 99999 55555');
    final emailController = TextEditingController(text: user?.email ?? 'homesh@example.com');
    final passwordController = TextEditingController(text: user?.password ?? 'pass1234');
    final cityController = TextEditingController(text: user?.city ?? 'Chennai, Tamil Nadu');

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edit & Update Profile',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name / Stall Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter name' : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone Field
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                  ),
                  const SizedBox(height: 14),

                  // User ID / Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'User ID / Email Address',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Account Password / Secret PIN',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // City Field
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'City / Region',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ref.read(authControllerProvider.notifier).updateUserProfile(
                              name: nameController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              city: cityController.text.trim(),
                            );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Profile updated successfully!'),
                            backgroundColor: AppTheme.statusGreen,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save & Update Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final isVendorOnline = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getRoleBadgeText(widget.role)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: _getRoleColor(widget.role).withValues(alpha: 0.2),
                      child: Icon(
                        _getRoleIcon(widget.role),
                        size: 48,
                        color: _getRoleColor(widget.role),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? _getDefaultName(widget.role),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? '+91 99999 55555',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRoleColor(widget.role).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getRoleColor(widget.role)),
                      ),
                      child: Text(
                        _getRoleBadgeText(widget.role).toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(widget.role),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Credentials Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ACCOUNT CREDENTIALS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openEditProfileSheet(context, ref),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.person, color: AppTheme.primaryOrange),
                      title: const Text('Name / Stall Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        user?.name ?? 'Homesh User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.phone, color: AppTheme.statusGreen),
                      title: const Text('Verified Phone Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        user?.phoneNumber ?? '+91 99999 55555',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.badge, color: Colors.indigo),
                      title: const Text('User ID / Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        user?.email ?? 'homesh1501@gmail.com',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.lock, color: Colors.deepPurple),
                      title: const Text('Account Password / PIN', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        _showPassword ? (user?.password ?? 'pass1234') : '••••••••',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      trailing: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_city, color: Colors.teal),
                      title: const Text('Registered City', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        user?.city ?? 'Chennai, Tamil Nadu',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vendor Specific Status Card
            if (widget.role == 'vendor') ...[
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
              const SizedBox(height: 16),
            ],

            // Action Quick Links
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_note, color: AppTheme.primaryOrange),
                    title: const Text('Edit Account Information'),
                    subtitle: const Text('Update Name, Phone, User ID & Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openEditProfileSheet(context, ref),
                  ),
                  const Divider(height: 1),
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
                    title: const Text('Appearance Theme'),
                    subtitle: Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                    },
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
        return 'Homesh User';
    }
  }
}
