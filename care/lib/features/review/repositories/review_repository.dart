import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart'; // Adjust path if your ApiConfig is elsewhere
import '../models/review_model.dart';

class ReviewRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // 1. Submit a new review
  Future<Map<String, dynamic>> submitReview({
    required String token,
    required String careRequestId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'care_request_id': careRequestId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Failed to submit review');
    }
  }

  // 2. Get all reviews for a specific provider
  Future<ProviderReviewsModel> getProviderReviews({
    required String token,
    required String providerId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/provider/$providerId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ProviderReviewsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load provider reviews');
    }
  }

  // 3. Check if a specific request has already been reviewed
  Future<bool> hasReview({
    required String token,
    required String careRequestId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/care-request/$careRequestId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['has_review'] == true;
    }
    return false;
  }
}