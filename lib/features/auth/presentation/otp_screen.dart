import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String code = _otpController.text.trim();
      ref.read(authControllerProvider.notifier).verifyOTP(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen to errors
    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authControllerProvider.notifier).resetError();
      } else if (next.status == AuthStatus.authenticated || next.status == AuthStatus.onboardingRequired) {
        // Pop back to root when signed in successfully (root selector handles next page)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Number'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Enter Verification Code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit verification code to your phone number.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      letterSpacing: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Please enter the 6-digit code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
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
                      : const Text('Verify & Continue'),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () {
                            // Go back to login to re-send code
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      'Didn\'t receive code? Edit phone number',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
