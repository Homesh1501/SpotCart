import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/data/auth_repository.dart';

final locationServiceProvider = StateNotifierProvider<LocationService, bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id;
  final isDemo = ref.watch(isDemoModeProvider);
  return LocationService(userId, isDemo: isDemo);
});

class LocationService extends StateNotifier<bool> {
  final String? _userId;
  final bool isDemo;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastUploadedPosition;
  DateTime? _lastUploadedTime;
  
  LocationService(this._userId, {this.isDemo = false}) : super(false) {
    _initOnlineStatus();
  }

  late final FirebaseFirestore? _firestore = isDemo ? null : FirebaseFirestore.instance;

  Future<void> _initOnlineStatus() async {
    if (_userId == null) return;
    if (isDemo) {
      state = false;
      return;
    }
    try {
      final doc = await _firestore!.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final isOnline = doc.data()?['isOnline'] as bool? ?? false;
        state = isOnline;
        if (isOnline) {
          _startLocationStream();
        }
      }
    } catch (e) {
      debugPrint('Error initializing online status: $e');
    }
  }

  Future<void> toggleOnlineOffline() async {
    if (_userId == null) return;

    if (state) {
      // Go Offline
      await _stopLocationStream();
      if (isDemo) {
        AuthRepository.updateMockVendorLocation(_userId!, 0, 0, false);
        state = false;
        return;
      }
      try {
        await _firestore!.collection('users').doc(_userId).update({
          'isOnline': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        state = false;
      } catch (e) {
        debugPrint('Failed to set offline in database: $e');
      }
    } else {
      // Go Online
      // First check permissions
      bool hasPermission = await _handlePermission();
      if (!hasPermission && !isDemo) {
        return;
      }

      state = true;
      try {
        Position currentPosition;
        if (isDemo) {
          currentPosition = Position(
            latitude: 37.42796133580664,
            longitude: -122.085749655962,
            timestamp: DateTime.now(),
            accuracy: 5.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        } else {
          currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }
        
        await _updateLocationInDatabase(currentPosition);
        _startLocationStream();
      } catch (e) {
        debugPrint('Failed to set online in database: $e');
        state = false;
      }
    }
  }

  Future<bool> _handlePermission() async {
    if (isDemo) return true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void _startLocationStream() {
    _positionStreamSubscription?.cancel();

    if (isDemo) {
      // Fake location stream updates every 15 seconds for testing on web/localhost
      _positionStreamSubscription = Stream.periodic(
        const Duration(seconds: 15),
        (count) => Position(
          latitude: 37.42796133580664 + (count * 0.0001), // Move slightly
          longitude: -122.085749655962 + (count * 0.0001),
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      ).listen((Position position) {
        _onLocationChanged(position);
      });
      return;
    }

    late final LocationSettings locationSettings;
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 15),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "SpotCart is broadcasting your active food cart coordinates.",
          notificationTitle: "SpotCart Vendor Online",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _onLocationChanged(position);
    }, onError: (error) {
      debugPrint('Location stream error: $error');
    });
  }

  Future<void> _stopLocationStream() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _lastUploadedPosition = null;
    _lastUploadedTime = null;
  }

  void _onLocationChanged(Position position) {
    if (_lastUploadedPosition == null || _lastUploadedTime == null) {
      _updateLocationInDatabase(position);
      return;
    }

    final durationDiff = DateTime.now().difference(_lastUploadedTime!);
    final bool timeThresholdMet = durationDiff.inMinutes >= 2;

    final double distanceDiff = Geolocator.distanceBetween(
      _lastUploadedPosition!.latitude,
      _lastUploadedPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    final bool distanceThresholdMet = distanceDiff >= 10.0;

    if (timeThresholdMet || distanceThresholdMet) {
      _updateLocationInDatabase(position);
    }
  }

  Future<void> _updateLocationInDatabase(Position position) async {
    _lastUploadedPosition = position;
    _lastUploadedTime = DateTime.now();
    
    if (isDemo) {
      AuthRepository.updateMockVendorLocation(
        _userId ?? 'mock_user_id',
        position.latitude,
        position.longitude,
        true,
      );
      debugPrint('[Demo Mode] Vendor location updated: ${position.latitude}, ${position.longitude}');
      return;
    }
    
    if (_userId == null) return;
    try {
      await _firestore!.collection('users').doc(_userId).update({
        'isOnline': true,
        'location': GeoPoint(position.latitude, position.longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint('Location updated in Firestore: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Failed to update location: $e');
    }
  }

  Future<void> updateManualLocation(double lat, double lng) async {
    final position = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
    state = true; // Ensure online status
    await _updateLocationInDatabase(position);
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
