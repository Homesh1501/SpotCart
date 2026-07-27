import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authControllerProvider.notifier).resetError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            ref.read(authControllerProvider.notifier).logout();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Welcome to SpotCart!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please select your role to continue. You can register as a transient food vendor or a hungry customer.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Column(
                  children: [
                    // Customer Card
                    Expanded(
                      child: _RoleCard(
                        title: 'I am a Customer',
                        description: 'Find transient street food vendors in real-time near you, explore daily specials, and get directions.',
                        icon: Icons.fastfood_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        isLoading: authState.status == AuthStatus.loading,
                        onTap: () {
                          ref.read(authControllerProvider.notifier).selectRole('customer');
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Vendor Card
                    Expanded(
                      child: _RoleCard(
                        title: 'I am a Food Vendor',
                        description: 'Broadcast your live location when active, update your menu items, highlight daily specials, and connect with customers.',
                        icon: Icons.storefront_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        isLoading: authState.status == AuthStatus.loading,
                        onTap: () {
                          ref.read(authControllerProvider.notifier).selectRole('vendor');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (authState.status == AuthStatus.loading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
