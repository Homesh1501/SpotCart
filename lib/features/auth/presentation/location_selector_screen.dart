import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import '../../../theme.dart';

class LocationSelectorScreen extends ConsumerWidget {
  const LocationSelectorScreen({super.key});

  final List<String> _cities = const ['Chennai', 'Coimbatore', 'Madurai', 'Trichy'];

  void _proceedToLogin(BuildContext context, String locationName) {
    // Navigate to Login screen to log in or select guest/bypass
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location set to: $locationName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppTheme.lightTextDark),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Map Icon Container
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Where are you hungry?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.lightTextDark,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'SpotCart uses your location to discover active roadside pushcarts, tea stalls, and moving food trucks in real-time near you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
              ),
              const SizedBox(height: 36),
              // GPS Button
              ElevatedButton.icon(
                onPressed: () => _proceedToLogin(context, 'Current GPS Coordinates'),
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Enable Location (GPS)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              // Manual Selection divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR CHOOSE MANUALLY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              // Cities Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _proceedToLogin(context, city),
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.lightTextDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
