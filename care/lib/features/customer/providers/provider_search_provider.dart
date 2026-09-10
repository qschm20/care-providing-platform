import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/provider_search_repository.dart';
import '../models/provider_search_model.dart';

// 1. The State Class
class ProviderSearchState {
  final List<ProviderSearchModel> providers;
  final bool isLoading;
  final String? error;

  ProviderSearchState({
    this.providers = const [],
    this.isLoading = false,
    this.error,
  });

  ProviderSearchState copyWith({
    List<ProviderSearchModel>? providers,
    bool? isLoading,
    String? error,
  }) {
    return ProviderSearchState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 2. The Notifier Class
class ProviderSearchNotifier extends StateNotifier<ProviderSearchState> {
  final ProviderSearchRepository _repository;
  final Ref _ref;

  ProviderSearchNotifier(this._repository, this._ref) : super(ProviderSearchState());

  Future<void> search({
    String? category,
    String? serviceArea,
    String? search,
  }) async {
    // Set loading to true and clear previous errors
    state = state.copyWith(isLoading: true, error: null);
    
    // Get the current auth token
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    try {
      // Call the repository
      final results = await _repository.searchProviders(
        token: token,
        category: category,
        serviceArea: serviceArea,
        search: search,
      );
      
      // Update state with results
      state = state.copyWith(providers: results, isLoading: false);
    } catch (e) {
      // Catch and store any network or parsing errors
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// 3. The Providers
final providerSearchRepositoryProvider = Provider<ProviderSearchRepository>((ref) {
  return ProviderSearchRepository();
});

final providerSearchProvider = StateNotifierProvider<ProviderSearchNotifier, ProviderSearchState>((ref) {
  return ProviderSearchNotifier(ref.read(providerSearchRepositoryProvider), ref);
});