import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../dashboard/controllers/menu_controller.dart';
import '../../../models/user_model.dart';
import '../../../models/menu_item_model.dart';

class VendorBottomSheet extends ConsumerWidget {
  final UserModel vendor;
  final Position? customerPosition;

  const VendorBottomSheet({
    super.key,
    required this.vendor,
    this.customerPosition,
  });

  String _calculateDistance() {
    if (customerPosition == null || vendor.location == null) {
      return 'Distance unknown';
    }

    final double distanceInMeters = Geolocator.distanceBetween(
      customerPosition!.latitude,
      customerPosition!.longitude,
      vendor.location!.latitude,
      vendor.location!.longitude,
    );

    if (distanceInMeters >= 1000) {
      final double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km away';
    } else {
      return '${distanceInMeters.round()} m away';
    }
  }

  Future<void> _launchDirections() async {
    if (vendor.location == null) return;
    
    final lat = vendor.location!.latitude;
    final lng = vendor.location!.longitude;
    
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final appleMapsUrl = 'maps://?q=$lat,$lng';

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final appleUri = Uri.parse(appleMapsUrl);
        if (await canLaunchUrl(appleUri)) {
          await launchUrl(appleUri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      
      final googleUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps URL';
      }
    } catch (e) {
      debugPrint('Error launching map directions: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(vendorMenuItemsProvider(vendor.id));
    final distanceText = _calculateDistance();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Vendor Details Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name ?? 'Street Food Vendor',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          distanceText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text(
                          'Open: 11AM - 7PM',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _launchDirections,
                icon: const Icon(Icons.navigation, size: 18),
                label: const Text('Go', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          // Menu list
          Expanded(
            child: menuItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No items listed in the menu.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final specials = items.where((element) => element.isTodaySpecial).toList();
                final standard = items.where((element) => !element.isTodaySpecial).toList();

                return ListView(
                  children: [
                    if (specials.isNotEmpty) ...[
                      const _SectionTitle(title: 'TODAY\'S SPECIALS'),
                      const SizedBox(height: 8),
                      ...specials.map((item) => _MenuListItem(item: item, isSpecial: true)),
                      const SizedBox(height: 16),
                    ],
                    if (standard.isNotEmpty) ...[
                      const _SectionTitle(title: 'STANDARD MENU'),
                      const SizedBox(height: 8),
                      ...standard.map((item) => _MenuListItem(item: item, isSpecial: false)),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading menu: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.brown.shade400,
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final MenuItemModel item;
  final bool isSpecial;

  const _MenuListItem({required this.item, required this.isSpecial});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSpecial ? 2 : 0.5,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                fontSize: 15,
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
            ],
          ],
        ),
      ),
    );
  }
}
