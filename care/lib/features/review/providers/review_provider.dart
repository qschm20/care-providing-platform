import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/review_repository.dart';
import '../models/review_model.dart'; // ✅ Added this import

class ReviewState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  ReviewState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ReviewState copyWith({bool? isSubmitting, String? errorMessage, bool? isSuccess}) {
    return ReviewState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository _repository;
  final Ref _ref;

  ReviewNotifier(this._repository, this._ref) : super(ReviewState());

  Future<bool> submitReview({
    required String careRequestId,
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);
    final token = _ref.read(authProvider).token;

    if (token == null) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Not authenticated');
      return false;
    }

    try {
      await _repository.submitReview(
        token: token,
        careRequestId: careRequestId,
        rating: rating,
        comment: comment,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final reviewNotifierProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier(ref.read(reviewRepositoryProvider), ref);
});

// ✅ NEW: Fetch reviews for a specific provider
final providerReviewsProvider = FutureProvider.family<ProviderReviewsModel, String>((ref, providerId) async {
  final token = ref.watch(authProvider).token;
  if (token == null) throw Exception('Not authenticated');
  
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getProviderReviews(token: token, providerId: providerId);
});