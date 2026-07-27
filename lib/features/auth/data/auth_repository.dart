import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';

class AuthResult {
  final String uid;
  final String phoneNumber;
  AuthResult({required this.uid, required this.phoneNumber});
}

class MockUser {
  final String uid;
  final String? phoneNumber;
  MockUser({required this.uid, this.phoneNumber});
}

class AuthRepository {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final bool isDemo;

  // In-memory mock database for Demo Mode
  static final Map<String, UserModel> _mockUsers = {};
  static MockUser? _mockCurrentUser;
  static final StreamController<MockUser?> _mockAuthStreamController = StreamController<MockUser?>.broadcast();
  static final StreamController<Map<String, UserModel>> _mockUsersStreamController = 
      StreamController<Map<String, UserModel>>.broadcast();

  static Stream<Map<String, UserModel>> get mockUsersStream => _mockUsersStreamController.stream;

  static List<UserModel> getMockOnlineVendors() {
    return _mockUsers.values.where((user) => user.role == 'vendor' && user.isOnline == true).toList();
  }

  static void initializeMockVendors(double customerLat, double customerLng) {
    if (!_mockUsers.containsKey('mock_vendor_2')) {
      _mockUsers['mock_vendor_2'] = UserModel(
        id: 'mock_vendor_2',
        phoneNumber: '+91 99999 88888',
        role: 'vendor',
        name: 'Spicy Fish Tacos Truck',
        isOnline: true,
        location: GeoPoint(customerLat + 0.0015, customerLng + 0.0015),
        lastUpdated: DateTime.now(),
      );
    }
    if (!_mockUsers.containsKey('mock_vendor_3')) {
      _mockUsers['mock_vendor_3'] = UserModel(
        id: 'mock_vendor_3',
        phoneNumber: '+91 88888 77777',
        role: 'vendor',
        name: 'Earthy Green Fruit Stand',
        isOnline: true,
        location: GeoPoint(customerLat - 0.0015, customerLng - 0.0015),
        lastUpdated: DateTime.now(),
      );
    }
    _mockUsersStreamController.add(Map.from(_mockUsers));
  }

  static void updateMockVendorLocation(String uid, double lat, double lng, bool isOnline) {
    final existing = _mockUsers[uid];
    if (existing != null) {
      _mockUsers[uid] = existing.copyWith(
        location: isOnline ? GeoPoint(lat, lng) : null,
        isOnline: isOnline,
        lastUpdated: DateTime.now(),
      );
    } else {
      _mockUsers[uid] = UserModel(
        id: uid,
        phoneNumber: '',
        role: 'vendor',
        isOnline: isOnline,
        location: isOnline ? GeoPoint(lat, lng) : null,
        lastUpdated: DateTime.now(),
      );
    }
    _mockUsersStreamController.add(Map.from(_mockUsers));
  }

  ConfirmationResult? _webConfirmationResult;

  void setMockCurrentUser(MockUser? user) {
    _mockCurrentUser = user;
    _mockAuthStreamController.add(user);
  }

  void setMockUserData(String uid, UserModel user) {
    _mockUsers[uid] = user;
    _mockUsersStreamController.add(Map.from(_mockUsers));
  }

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.isDemo = false,
  })  : _auth = isDemo ? null : (auth ?? FirebaseAuth.instance),
        _firestore = isDemo ? null : (firestore ?? FirebaseFirestore.instance);

  Stream<dynamic> get authStateChanges {
    if (isDemo) {
      return _mockAuthStreamController.stream;
    }
    return _auth!.authStateChanges();
  }

  dynamic get currentUser {
    if (isDemo) {
      return _mockCurrentUser;
    }
    return _auth!.currentUser;
  }

  Future<void> sendSMSCode({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onFailed,
  }) async {
    if (isDemo) {
      // Instantly trigger code sent
      await Future.delayed(const Duration(milliseconds: 500));
      onCodeSent("mock_verification_id", null);
      return;
    }
    if (kIsWeb) {
      try {
        final result = await _auth!.signInWithPhoneNumber(phoneNumber);
        _webConfirmationResult = result;
        onCodeSent("web_verification_id", null);
      } on FirebaseAuthException catch (e) {
        onFailed(e);
      } catch (e) {
        onFailed(FirebaseAuthException(
          code: 'web-sign-in-failed',
          message: e.toString(),
        ));
      }
      return;
    }
    await _auth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth!.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<AuthResult> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    if (isDemo) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockUid = "mock_user_id";
      final mockPhone = smsCode.isNotEmpty ? "+11234567890" : "+11234567890";
      
      // Update mock current user
      _mockCurrentUser = MockUser(uid: mockUid, phoneNumber: mockPhone);
      _mockAuthStreamController.add(_mockCurrentUser);
      
      // Save session in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_demo_mode', true);
      await prefs.setString('demo_user_id', mockUid);
      await prefs.setString('demo_user_phone', mockPhone);
      
      return AuthResult(uid: mockUid, phoneNumber: mockPhone);
    }

    if (kIsWeb) {
      if (_webConfirmationResult == null) {
        throw FirebaseAuthException(
          code: 'missing-confirmation-result',
          message: 'No active confirmation flow. Please send the SMS code again.',
        );
      }
      final userCred = await _webConfirmationResult!.confirm(smsCode);
      return AuthResult(
        uid: userCred.user!.uid,
        phoneNumber: userCred.user!.phoneNumber ?? '',
      );
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCred = await _auth!.signInWithCredential(credential);
    return AuthResult(
      uid: userCred.user!.uid,
      phoneNumber: userCred.user!.phoneNumber ?? '',
    );
  }

  Future<UserModel?> getUserData(String uid) async {
    if (isDemo) {
      return _mockUsers[uid];
    }
    final doc = await _firestore!.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> saveUserData(UserModel user) async {
    if (isDemo) {
      _mockUsers[user.id] = user;
      _mockCurrentUser = MockUser(uid: user.id, phoneNumber: user.phoneNumber);
      _mockAuthStreamController.add(_mockCurrentUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_demo_mode', true);
      await prefs.setString('demo_user_id', user.id);
      await prefs.setString('demo_user_phone', user.phoneNumber);
      if (user.role != null) {
        await prefs.setString('demo_user_role', user.role!);
      }
      if (user.name != null) {
        await prefs.setString('demo_user_name', user.name!);
      }
      _mockUsersStreamController.add(Map.from(_mockUsers));
      return;
    }
    await _firestore!.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> signOut() async {
    if (isDemo) {
      _mockCurrentUser = null;
      _mockAuthStreamController.add(null);
      
      // Clear persistence keys
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_demo_mode');
      await prefs.remove('demo_user_id');
      await prefs.remove('demo_user_phone');
      await prefs.remove('demo_user_role');
      await prefs.remove('demo_user_name');
      return;
    }
    await _auth!.signOut();
  }
}
