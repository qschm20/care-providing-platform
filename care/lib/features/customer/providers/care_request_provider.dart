import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/care_request_model.dart';
import '../repositories/care_request_repository.dart';

enum SubmissionStatus { idle, loading, success, error }

class CareRequestState {
  final SubmissionStatus status;
  final String? errorMessage;

  const CareRequestState({
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });
}

class CareRequestNotifier extends StateNotifier<CareRequestState> {
  final CareRequestRepository _repository;

  CareRequestNotifier(this._repository) : super(const CareRequestState());

  Future<bool> submitRequest(CareRequestModel request, String token) async {
    if (state.status == SubmissionStatus.loading) {
      return false; // block duplicate submissions
    }

    state = const CareRequestState(status: SubmissionStatus.loading);

    final result = await _repository.createRequest(request, token);

    if (result.success) {
      state = const CareRequestState(status: SubmissionStatus.success);
      return true;
    } else {
      state = CareRequestState(
        status: SubmissionStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  void reset() {
    state = const CareRequestState();
  }
}

final careRequestRepositoryProvider = Provider<CareRequestRepository>((ref) {
  return CareRequestRepository();
});

final careRequestNotifierProvider =
    StateNotifierProvider<CareRequestNotifier, CareRequestState>((ref) {
  final repository = ref.watch(careRequestRepositoryProvider);
  return CareRequestNotifier(repository);
});