import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/provider_repository.dart';
import '../../auth/providers/auth_provider.dart';

class ProviderProfileState {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  ProviderProfileState({this.profile, this.isLoading = false, this.error});

  ProviderProfileState copyWith({
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProviderProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProviderProfileNotifier extends StateNotifier<ProviderProfileState> {
  final ProviderRepository _repository;
  final Ref _ref;

  ProviderProfileNotifier(this._repository, this._ref) : super(ProviderProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    if (token == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    // ✅ SAFETY NET: Prevents infinite loading if the repository crashes
    try {
      final result = await _repository.getProfile(token);
      
      if (result['success'] == true) {
        state = state.copyWith(profile: result['data'], isLoading: false);
      } else {
        state = state.copyWith(
          error: result['errorMessage'] ?? 'Unknown error', 
          isLoading: false
        );
      }
    } catch (e) {
      // If the repository throws an error, we catch it here and stop the loading spinner!
      state = state.copyWith(error: 'Failed to load profile: $e', isLoading: false);
    }
  }

  Future<bool> updateProfile(String bio, String serviceArea) async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    if (token == null) return false;

    try {
      final result = await _repository.updateProfile(token, bio, serviceArea);
      if (result['success'] == true) {
        state = state.copyWith(profile: result['data'], isLoading: false);
        return true;
      } else {
        state = state.copyWith(error: result['errorMessage'], isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update: $e', isLoading: false);
      return false;
    }
  }

  Future<bool> submitVerification() async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    if (token == null) return false;

    try {
      final result = await _repository.submitVerification(token);
      if (result['success'] == true) {
        state = state.copyWith(profile: result['data'], isLoading: false);
        return true;
      } else {
        state = state.copyWith(error: result['errorMessage'], isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to submit: $e', isLoading: false);
      return false;
    }
  }
}

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository();
});

final providerProfileProvider = StateNotifierProvider<ProviderProfileNotifier, ProviderProfileState>((ref) {
  return ProviderProfileNotifier(ref.read(providerRepositoryProvider), ref);
});