import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../dashboard/controllers/location_service.dart';
import '../../../theme.dart';

class LiveUpdateScreen extends ConsumerStatefulWidget {
  const LiveUpdateScreen({super.key});

  @override
  ConsumerState<LiveUpdateScreen> createState() => _LiveUpdateScreenState();
}

class _LiveUpdateScreenState extends ConsumerState<LiveUpdateScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLatLng = const LatLng(13.0827, 80.2707); // Default Chennai
  String _crowdLevel = 'Low';
  final TextEditingController _noteController = TextEditingController();
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    // In a real application we would load the current vendor location from GPS or Firestore
    // Let's seed a realistic location close to T-Nagar Chennai or the default
    _selectedLatLng = const LatLng(13.0405, 80.2337);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _broadcastLocation() async {
    setState(() {
      _isBroadcasting = true;
    });

    try {
      // Update location via locationServiceProvider
      await ref.read(locationServiceProvider.notifier).updateManualLocation(
            _selectedLatLng.latitude,
            _selectedLatLng.longitude,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Broadcast Active! Location set to ${_selectedLatLng.latitude.toStringAsFixed(4)}, ${_selectedLatLng.longitude.toStringAsFixed(4)}. Crowd status: $_crowdLevel.',
            ),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to broadcast: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBroadcasting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(locationServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Broadcast'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map Instructions Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.primaryOrange.withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryOrange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap anywhere on the map to set your cart\'s live position.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Leaflet Map viewport
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLatLng = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.spotcart.spotcart',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLatLng,
                          width: 60.0,
                          height: 60.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse effect
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryOrange.withOpacity(0.3),
                                ),
                              ),
                              const Icon(
                                Icons.storefront,
                                size: 36.0,
                                color: AppTheme.primaryOrange,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Overlay coordinates pill
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black87 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'Lat: ${_selectedLatLng.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status & Custom notes footer
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Crowd Level Slider/Buttons
                  const Text(
                    'Crowd Level at Stall',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Low', 'Moderate', 'High', 'Crowded'].map((level) {
                      final isSelected = _crowdLevel == level;
                      Color btnColor = AppTheme.primaryOrange;
                      if (level == 'Low') btnColor = AppTheme.statusGreen;
                      if (level == 'Moderate') btnColor = AppTheme.ratingYellow;
                      if (level == 'High') btnColor = Colors.orange;
                      if (level == 'Crowded') btnColor = AppTheme.dangerRed;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _crowdLevel = level;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? btnColor : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? btnColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              level,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Custom Announcement Note
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Stall Announcement Note',
                      hintText: 'e.g. Opposite Metro station, serving hot tiffins now!',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Broadcast button
                  ElevatedButton(
                    onPressed: _isBroadcasting ? null : _broadcastLocation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isBroadcasting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isOnline ? Icons.sync : Icons.wifi_tethering),
                              const SizedBox(width: 8),
                              Text(isOnline ? 'Update Live Coordinates' : 'Start Live Broadcast'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
