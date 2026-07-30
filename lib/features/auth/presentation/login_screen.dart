import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../data/auth_repository.dart';
import '../../../models/user_model.dart';
import '../../../theme.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialRole; // 'customer', 'vendor', 'admin'
  const LoginScreen({super.key, this.initialRole});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _adminPasscodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late String _selectedRole; // 'customer', 'vendor', 'admin'

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'customer';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _adminPasscodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == 'admin') {
        if (_adminPasscodeController.text.trim() == 'admin123' ||
            _adminPasscodeController.text.trim() == '9999900000' ||
            _adminPasscodeController.text.trim().isNotEmpty) {
          _performQuickDemoLogin('admin');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Admin Passcode')),
          );
        }
        return;
      }

      String rawPhone = _phoneController.text.trim().replaceAll(' ', '');
      String phone = rawPhone;
      if (!phone.startsWith('+')) {
        final offset = DateTime.now().timeZoneOffset.inMinutes;
        String countryCode = '+91'; // Default India (+91)
        if (offset != 330 && offset != 0) {
          countryCode = '+91';
        }
        
        if (phone.startsWith('0')) {
          phone = phone.substring(1);
        }
        phone = '$countryCode$phone';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📱 Sending 6-digit SMS OTP verification code to $phone...'),
          backgroundColor: AppTheme.primaryOrange,
          duration: const Duration(seconds: 4),
        ),
      );

      ref.read(authControllerProvider.notifier).sendOTP(phone);
    }
  }

  Future<void> _performQuickDemoLogin(String role) async {
    await ref.read(authControllerProvider.notifier).performDemoLogin(role);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen to codeSent state to navigate
    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.codeSent) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OtpScreen()),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authControllerProvider.notifier).resetError();
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          tooltip: 'Go Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ref.read(authControllerProvider.notifier).changeRole();
            }
          },
        ),
        title: Text(
          'Login',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon & Title
                  Icon(
                    Icons.storefront_outlined,
                    size: 70,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SpotCart',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-Time Street Food Tracking Platform',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  // Role Selector Segment Control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildRoleTab('customer', '🛒 Customer', Icons.person),
                        _buildRoleTab('vendor', '🚚 Vendor', Icons.storefront),
                        _buildRoleTab('admin', '🛡️ Admin', Icons.admin_panel_settings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Header depending on role
                  Text(
                    _getRoleTitle(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRoleSubtitle(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Input Fields
                  if (_selectedRole != 'admin') ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+91 99999 55555',
                        labelText: 'Mobile Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: _selectedRole == 'vendor'
                            ? AppTheme.statusGreen
                            : AppTheme.primaryOrange,
                      ),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Send OTP Verification',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _adminPasscodeController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter Admin Key (e.g. admin123)',
                        labelText: 'Admin Passcode',
                        prefixIcon: const Icon(Icons.key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter admin passcode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                      child: const Text(
                        'Access Admin Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('OR QUICK DEMO ACCESS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Demo Login Button for selected role
                  OutlinedButton.icon(
                    onPressed: () => _performQuickDemoLogin(_selectedRole),
                    icon: Icon(
                      _selectedRole == 'vendor'
                          ? Icons.storefront
                          : (_selectedRole == 'admin' ? Icons.security : Icons.person),
                    ),
                    label: Text(
                      'Instant Direct Login as ${_selectedRole.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: _selectedRole == 'vendor'
                            ? AppTheme.statusGreen
                            : (_selectedRole == 'admin' ? Colors.deepPurple : AppTheme.primaryOrange),
                        width: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).changeRole();
                    },
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to Prototype Hub / Role Switcher'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (role == 'vendor'
                    ? AppTheme.statusGreen
                    : (role == 'admin' ? Colors.deepPurple : AppTheme.primaryOrange))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleTitle() {
    switch (_selectedRole) {
      case 'vendor':
        return 'Food Vendor Portal Login';
      case 'admin':
        return 'Admin Command Center Access';
      default:
        return 'Customer Portal Login';
    }
  }

  String _getRoleSubtitle() {
    switch (_selectedRole) {
      case 'vendor':
        return 'Manage food stall status, update live location & edit daily menus.';
      case 'admin':
        return 'Platform oversight, vendor approvals & system analytics.';
      default:
        return 'Find live street food vendors, track carts & order delicious meals.';
    }
  }
}
