import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/provider_request_model.dart';

class ProviderRequestsRepository {
  final String baseUrl = ApiConfig.baseUrl;

  /// Fetch all matching pending requests for the authenticated provider
  Future<List<ProviderRequestModel>> getMatchingRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/provider/requests/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProviderRequestModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch provider requests: ${response.statusCode}');
    }
  }

  /// Accept a care request (first-accept-wins)
  Future<Map<String, dynamic>> acceptRequest({
    required String token,
    required String requestId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/provider/requests/$requestId/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 409) {
      throw Exception('Request already accepted by another provider');
    } else {
      throw Exception('Failed to accept request: ${response.statusCode}');
    }
  }

  /// Decline a care request
  Future<Map<String, dynamic>> declineRequest({
    required String token,
    required String requestId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/provider/requests/$requestId/decline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to decline request: ${response.statusCode}');
    }
  }
}