import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoggedIn = false,
    this.token,
    this.user,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setAuth({required String token, required Map<String, dynamic> user}) {
    state = AuthState(
      isLoggedIn: true,
      token: token,
      user: user,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);