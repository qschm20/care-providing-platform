import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/provider_requests_repository.dart';
import '../models/provider_request_model.dart';

// 1. The State Class
class ProviderRequestsState {
  final List<ProviderRequestModel> requests;
  final bool isLoading;
  final String? error;
  final bool isActionLoading;

  ProviderRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
    this.isActionLoading = false,
  });

  ProviderRequestsState copyWith({
    List<ProviderRequestModel>? requests,
    bool? isLoading,
    String? error,
    bool? isActionLoading,
  }) {
    return ProviderRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}

// 2. The Notifier Class
class ProviderRequestsNotifier extends StateNotifier<ProviderRequestsState> {
  final ProviderRequestsRepository _repository;
  final Ref _ref;

  ProviderRequestsNotifier(this._repository, this._ref) : super(ProviderRequestsState());

  Future<void> fetchRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      final results = await _repository.getMatchingRequests(token: token);
      state = state.copyWith(requests: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isActionLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      await _repository.acceptRequest(token: token, requestId: requestId);
      await fetchRequests(); 
      state = state.copyWith(isActionLoading: false); // ✅ FIX: Reset loading state
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }

  Future<void> declineRequest(String requestId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isActionLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      await _repository.declineRequest(token: token, requestId: requestId);
      await fetchRequests();
      state = state.copyWith(isActionLoading: false); // ✅ FIX: Reset loading state
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }

  Future<void> startRequest(String requestId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isActionLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      await _repository.startRequest(token: token, requestId: requestId);
      await fetchRequests();
      state = state.copyWith(isActionLoading: false); // ✅ FIX: Reset loading state
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }

  Future<void> completeRequest(String requestId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isActionLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      await _repository.completeRequest(token: token, requestId: requestId);
      await fetchRequests();
      state = state.copyWith(isActionLoading: false); // ✅ FIX: Reset loading state
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }
}

// 3. The Providers
final providerRequestsRepositoryProvider = Provider<ProviderRequestsRepository>((ref) {
  return ProviderRequestsRepository();
});

final providerRequestsProvider = StateNotifierProvider<ProviderRequestsNotifier, ProviderRequestsState>((ref) {
  return ProviderRequestsNotifier(ref.read(providerRequestsRepositoryProvider), ref);
});