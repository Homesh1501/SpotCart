import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/location_service.dart';
import '../controllers/menu_controller.dart';
import 'menu_manager_screen.dart';

class VendorDashboard extends ConsumerWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isOnline = ref.watch(locationServiceProvider);
    final vendorId = authState.user?.id ?? '';
    final menuItemsAsync = ref.watch(vendorMenuItemsProvider(vendorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
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
            // Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: isOnline
                        ? [Colors.orange.shade800, Colors.orange.shade600]
                        : [Colors.brown.shade800, Colors.brown.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOnline ? 'ONLINE' : 'OFFLINE',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOnline
                                  ? 'Broadcasting location to customers'
                                  : 'Location streaming paused',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        // Online indicator pulse
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.greenAccent : Colors.grey.shade400,
                            boxShadow: isOnline
                                ? [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isOnline ? Colors.orange.shade900 : Colors.brown.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        ref.read(locationServiceProvider.notifier).toggleOnlineOffline();
                      },
                      child: Text(
                        isOnline ? 'Go Offline' : 'Go Online',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Menu CRUD Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Specials & Menu',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MenuManagerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Menu Items List Summary
            menuItemsAsync.when(
              data: (items) {
                final specials = items.where((element) => element.isTodaySpecial).toList();
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'No items in your menu yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "Manage" to list items for your customers to see.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MenuManagerScreen(),
                                ),
                              );
                            },
                            child: const Text('Manage Menu'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (specials.isNotEmpty) ...[
                      const _SectionHeader(title: 'TODAY\'S SPECIALS'),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: specials.length,
                        itemBuilder: (context, index) {
                          final item = specials[index];
                          return _MenuItemCard(item: item, isSpecial: true);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    const _SectionHeader(title: 'STANDARD MENU'),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.where((element) => !element.isTodaySpecial).length,
                      itemBuilder: (context, index) {
                        final standardItems = items.where((element) => !element.isTodaySpecial).toList();
                        final item = standardItems[index];
                        return _MenuItemCard(item: item, isSpecial: false);
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading menu: $err', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.brown.shade400,
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final dynamic item;
  final bool isSpecial;

  const _MenuItemCard({required this.item, required this.isSpecial});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.fastfood, color: Colors.orange.shade800),
                  ),
                )
              : Icon(Icons.fastfood, color: Colors.orange.shade800),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isSpecial ? Colors.orange.shade800 : Colors.brown.shade800,
              ),
            ),
            if (isSpecial) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SPECIAL',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
