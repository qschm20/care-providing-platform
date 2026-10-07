import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository());

class AdminState {
  final List<dynamic> providers;
  final bool isLoading;
  final String? error;
  final bool isActionLoading;

  AdminState({this.providers = const [], this.isLoading = false, this.error, this.isActionLoading = false});

  AdminState copyWith({List<dynamic>? providers, bool? isLoading, String? error, bool? isActionLoading}) {
    return AdminState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminNotifier(this._repository, this._ref) : super(AdminState());

  Future<void> fetchProviders({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    if (token == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }
    try {
      final data = await _repository.getProviders(status: status, token: token);
      state = state.copyWith(providers: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> approveProvider(String providerId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    try {
      await _repository.approveProvider(providerId, token!);
      await fetchProviders(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }

  Future<void> rejectProvider(String providerId) async {
    state = state.copyWith(isActionLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    try {
      await _repository.rejectProvider(providerId, token!);
      await fetchProviders(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString(), isActionLoading: false);
    }
  }
}

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminRepositoryProvider), ref);
});