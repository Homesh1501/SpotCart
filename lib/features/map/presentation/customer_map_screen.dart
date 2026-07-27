import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/map_controller.dart';
import 'vendor_bottom_sheet.dart';
import '../../../models/user_model.dart';

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final position = await ref.read(customerLocationProvider.future);
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      if (position != null) {
        // Center map on user location safely after build frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
            } catch (e) {
              debugPrint('MapController.move error: $e');
            }
          }
        });
      }
    }
  }

  void _reCenter() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
            } catch (e) {
              debugPrint('MapController.move error: $e');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch location: $e')),
        );
      }
    }
  }

  void _showVendorDetails(UserModel vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VendorBottomSheet(
        vendor: vendor,
        customerPosition: _currentPosition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorsStream = ref.watch(liveVendorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotCart Map'),
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
      body: _isLoadingLocation && _currentPosition == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching GPS Coordinates...'),
                ],
              ),
            )
          : Stack(
              children: [
                vendorsStream.when(
                  data: (vendors) {
                    final List<Marker> markers = vendors
                        .where((vendor) => vendor.location != null)
                        .map((vendor) {
                      return Marker(
                        point: LatLng(
                          vendor.location!.latitude,
                          vendor.location!.longitude,
                        ),
                        width: 50.0,
                        height: 50.0,
                        child: GestureDetector(
                          onTap: () {
                            _showVendorDetails(vendor);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.5,
                              ),
                            ),
                            child: Icon(
                              Icons.storefront,
                              size: 28.0,
                              color: Theme.of(context).colorScheme.primary, // Appetite Orange
                            ),
                          ),
                        ),
                      );
                    }).toList();

                    // Add user location marker
                    if (_currentPosition != null) {
                      markers.add(
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 44.0,
                          height: 44.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_pin_circle,
                                size: 28.0,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    LatLng initialTarget = _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(37.42796133580664, -122.085749655962); // Default fallback Google HQ

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialTarget,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.spotcart.spotcart',
                        ),
                        MarkerLayer(
                          markers: markers,
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error loading vendor locations: $err'),
                  ),
                ),
                // Re-center FAB floating over the map
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton(
                    onPressed: _reCenter,
                    tooltip: 'Recenter location',
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}
