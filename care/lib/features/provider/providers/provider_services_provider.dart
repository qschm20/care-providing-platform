import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/provider_repository.dart';
import '../../auth/providers/auth_provider.dart';
import 'provider_profile_provider.dart';

class ProviderServicesState {
  final List<dynamic> services;
  final bool isLoading;
  final String? error;

  ProviderServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
  });

  ProviderServicesState copyWith({
    List<dynamic>? services,
    bool? isLoading,
    String? error,
  }) {
    return ProviderServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProviderServicesNotifier extends StateNotifier<ProviderServicesState> {
  final ProviderRepository _repository;
  final Ref _ref;

  ProviderServicesNotifier(this._repository, this._ref) : super(ProviderServicesState());

  Future<void> fetchServices() async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    if (token == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    final result = await _repository.getServices(token);
    if (result['success']) {
      state = state.copyWith(services: result['data'] ?? [], isLoading: false);
    } else {
      state = state.copyWith(error: result['errorMessage'], isLoading: false);
    }
  }

  Future<bool> addService(Map<String, dynamic> serviceData) async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    final result = await _repository.createService(token!, serviceData);
    if (result['success']) {
      await fetchServices();
      return true;
    } else {
      state = state.copyWith(error: result['errorMessage'], isLoading: false);
      return false;
    }
  }

  Future<bool> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    final result = await _repository.updateService(token!, serviceId, serviceData);
    if (result['success']) {
      await fetchServices();
      return true;
    } else {
      state = state.copyWith(error: result['errorMessage'], isLoading: false);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    state = state.copyWith(isLoading: true, error: null);
    final token = _ref.read(authProvider).token;
    
    final result = await _repository.deleteService(token!, serviceId);
    if (result['success']) {
      await fetchServices();
      return true;
    } else {
      state = state.copyWith(error: result['errorMessage'], isLoading: false);
      return false;
    }
  }
}

final providerServicesProvider = StateNotifierProvider<ProviderServicesNotifier, ProviderServicesState>((ref) {
  return ProviderServicesNotifier(ref.read(providerRepositoryProvider), ref);
});