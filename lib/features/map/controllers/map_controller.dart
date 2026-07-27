import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../models/user_model.dart';

// Stream of online vendors
final liveVendorsProvider = StreamProvider<List<UserModel>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  
  if (isDemo) {
    final userPositionAsync = ref.watch(customerLocationProvider);
    final userPos = userPositionAsync.value;
    final lat = userPos?.latitude ?? 37.42796133580664;
    final lng = userPos?.longitude ?? -122.085749655962;

    AuthRepository.initializeMockVendors(lat, lng);

    Stream<List<UserModel>> getDemoVendors() async* {
      yield AuthRepository.getMockOnlineVendors();
      await for (final userMap in AuthRepository.mockUsersStream) {
        yield userMap.values.where((user) => user.role == 'vendor' && user.isOnline == true).toList();
      }
    }
    
    return getDemoVendors();
  }

  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'vendor')
      .where('isOnline', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList());
});

// Current Customer Location Provider
final customerLocationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    // Return dummy position on web/desktop if emulator has no GPS support
    return Position(
      longitude: -122.085749655962,
      latitude: 37.42796133580664,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
});
