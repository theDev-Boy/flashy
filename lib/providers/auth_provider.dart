import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AuthState clearError() {
    return copyWith(error: null);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final authService = ref.watch(authServiceProvider);
    authService.authStateChanges.listen((user) {
      state = state.copyWith(user: user);
    });
    return const AuthState();
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign-in failed. Please try again.',
      );
    }
  }

  Future<bool> silentSignIn() async {
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.silentSignIn();
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AuthState();
  }

  Future<void> switchAccount() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    await signIn();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
