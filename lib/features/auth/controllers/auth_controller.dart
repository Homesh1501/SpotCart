import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import '../../../models/user_model.dart';

enum AuthStatus {
  unauthenticated,
  checkingSession,
  loading,
  codeSent,
  authenticated,
  onboardingRequired,
  error
}

class AuthControllerState {
  final AuthStatus status;
  final UserModel? user;
  final String? verificationId;
  final String? errorMessage;

  AuthControllerState({
    required this.status,
    this.user,
    this.verificationId,
    this.errorMessage,
  });

  AuthControllerState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? verificationId,
    String? errorMessage,
  }) {
    return AuthControllerState(
      status: status ?? this.status,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final isDemoModeProvider = StateProvider<bool>((ref) => false);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return AuthRepository(isDemo: isDemo);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository, ref);
});

// A provider that streams the current FirebaseAuth user state changes
final authStateChangesProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthController extends StateNotifier<AuthControllerState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController(this._repository, this._ref)
      : super(AuthControllerState(status: AuthStatus.unauthenticated)) {
    _init();
  }

  void _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final wasDemo = prefs.getBool('is_demo_mode') ?? false;

    if (wasDemo) {
      _ref.read(isDemoModeProvider.notifier).state = true;
      final mockUid = prefs.getString('demo_user_id');
      final mockPhone = prefs.getString('demo_user_phone');
      final mockRole = prefs.getString('demo_user_role');
      final mockName = prefs.getString('demo_user_name');

      if (mockUid != null && mockPhone != null) {
        final mockUser = MockUser(uid: mockUid, phoneNumber: mockPhone);
        _repository.setMockCurrentUser(mockUser);

        final userModel = UserModel(
          id: mockUid,
          phoneNumber: mockPhone,
          role: mockRole,
          name: mockName,
        );
        _repository.setMockUserData(mockUid, userModel);

        await checkUserProfile(mockUid, mockPhone, isStartup: true);
        return;
      }
    }

    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      checkUserProfile(currentUser.uid, currentUser.phoneNumber ?? '', isStartup: true);
    }
  }

  Future<void> checkUserProfile(String uid, String phoneNumber, {bool isStartup = false, String defaultRole = 'customer'}) async {
    state = state.copyWith(status: isStartup ? AuthStatus.checkingSession : AuthStatus.loading);
    try {
      final userModel = await _repository.getUserData(uid);
      if (!mounted) return;
      if (userModel == null) {
        final newUser = UserModel(
          id: uid,
          phoneNumber: phoneNumber,
          role: defaultRole,
          name: 'SpotCart User',
        );
        await _repository.saveUserData(newUser);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: newUser,
        );
      } else if (userModel.role == null) {
        final updatedUser = userModel.copyWith(role: defaultRole);
        await _repository.saveUserData(updatedUser);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
        );
      } else {
        state = state.copyWith(status: AuthStatus.authenticated, user: userModel);
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback user session on error
      final fallbackUser = UserModel(
        id: uid,
        phoneNumber: phoneNumber,
        role: defaultRole,
        name: 'SpotCart User',
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: fallbackUser,
      );
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.sendSMSCode(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
          );
        },
        onFailed: (e) {
          if (!mounted) return;
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Phone verification failed: [${e.code}] ${e.message ?? e.toString()}',
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error sending SMS code: $e',
      );
    }
  }

  Future<void> verifyOTP(String smsCode) async {
    final verificationId = state.verificationId ?? 'fallback_verification_id';


    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repository.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (!mounted) return;
      await checkUserProfile(
        result.uid,
        result.phoneNumber,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid OTP code: $e',
      );
    }
  }

  Future<void> selectRole(String role) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No active user found to select a role.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      UserModel updatedUser = user.copyWith(
        role: role,
        isOnline: role == 'vendor' ? false : null,
      );
      await _repository.saveUserData(updatedUser);
      if (!mounted) return;
      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to save role selection: $e',
      );
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String phoneNumber,
    String? email,
    String? password,
    String? city,
  }) async {
    final user = state.user ?? UserModel(id: 'user_${DateTime.now().millisecondsSinceEpoch}', phoneNumber: phoneNumber);
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final updatedUser = user.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        city: city,
      );
      await _repository.saveUserData(updatedUser);
      if (!mounted) return;
      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update user profile: $e',
      );
    }
  }

  void changeRole() {
    state = state.copyWith(status: AuthStatus.onboardingRequired);
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.signOut();
      if (!mounted) return;
      state = AuthControllerState(status: AuthStatus.unauthenticated);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to log out: $e',
      );
    }
  }

  Future<void> performDemoLogin(String role) async {
    state = state.copyWith(status: AuthStatus.loading);
    _ref.read(isDemoModeProvider.notifier).state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', true);

    UserModel user;
    if (role == 'vendor') {
      user = UserModel(
        id: 'vendor_001',
        phoneNumber: '+91 99999 55555',
        role: 'vendor',
        name: 'Ramu\'s Evening Bajji Stall',
        isOnline: true,
        city: 'Chennai',
      );
    } else if (role == 'admin') {
      user = UserModel(
        id: 'admin_001',
        phoneNumber: '+91 99999 00000',
        role: 'admin',
        name: 'SpotCart Admin Command Center',
        isOnline: null,
      );
    } else {
      user = UserModel(
        id: 'customer_001',
        phoneNumber: '+91 98401 22334',
        role: 'customer',
        name: 'Priya Sundaram (Customer)',
        isOnline: null,
        city: 'Chennai',
      );
    }

    _repository.setMockCurrentUser(MockUser(uid: user.id, phoneNumber: user.phoneNumber));
    _repository.setMockUserData(user.id, user);

    await prefs.setString('demo_user_id', user.id);
    await prefs.setString('demo_user_phone', user.phoneNumber);
    await prefs.setString('demo_user_role', user.role!);
    await prefs.setString('demo_user_name', user.name!);

    state = AuthControllerState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  void resetError() {
    state = state.copyWith(
      status: state.status == AuthStatus.error ? AuthStatus.unauthenticated : state.status,
      errorMessage: null,
    );
  }
}
