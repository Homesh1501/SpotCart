import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String phone = _phoneController.text.trim();
      if (!phone.startsWith('+')) {
        final offset = DateTime.now().timeZoneOffset.inMinutes;
        String countryCode = '+1'; // Default
        if (offset == 330) {
          countryCode = '+91'; // India
        }
        
        // Remove leading 0 if user entered it
        if (phone.startsWith('0')) {
          phone = phone.substring(1);
        }
        phone = '$countryCode$phone';
      }
      ref.read(authControllerProvider.notifier).sendOTP(phone);
    }
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

    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      appBar: isDemo
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  ref.read(isDemoModeProvider.notifier).state = false;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_demo_mode', false);
                },
              ),
            )
          : null,
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
                  const SizedBox(height: 40),
                  // Logo/Icon
                  Icon(
                    Icons.storefront_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SpotCart',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Real-time street food finder',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Enter Phone Number',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+1 123 456 7890',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading ? null : _submit,
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send Verification Code'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We will send a 6-digit verification code to this phone number.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () async {
                      ref.read(isDemoModeProvider.notifier).state = true;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_demo_mode', true);
                    },
                    child: Text(
                      'Bypass with Demo Mode',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
