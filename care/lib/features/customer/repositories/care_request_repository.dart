import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/care_request_model.dart';
import '../../auth/repositories/auth_repository.dart';

class CareRequestResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  CareRequestResult.success(this.data)
      : success = true,
        errorMessage = null;

  CareRequestResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class CareRequestRepository {
  // In-memory storage for demo mode only — resets when app restarts
  static final List<Map<String, dynamic>> _demoRequests = [];

  Future<CareRequestResult> createRequest(
    CareRequestModel request,
    String token,
  ) async {
    if (token == AuthRepository.demoToken) {
      final fakeRequest = {
        'id': 'demo-${_demoRequests.length + 1}',
        'category': request.category,
        'requirements': request.requirements,
        'service_date': request.toJson()['service_date'],
        'start_time': request.startTime,
        'end_time': request.endTime,
        'status': 'pending',
      };
      _demoRequests.insert(0, fakeRequest);
      return CareRequestResult.success(fakeRequest);
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/care-requests/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return CareRequestResult.success(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        return CareRequestResult.failure(body['detail'] ?? 'Failed to create request');
      }
    } catch (e) {
      return CareRequestResult.failure('Could not reach server. Check your connection.');
    }
  }

  Future<CareRequestResult> getMyRequests(String token) async {
    if (token == AuthRepository.demoToken) {
      return CareRequestResult.success({'requests': _demoRequests});
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/care-requests/my');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return CareRequestResult.success({'requests': jsonDecode(response.body)});
      } else {
        return CareRequestResult.failure('Failed to load requests');
      }
    } catch (e) {
      return CareRequestResult.failure('Could not reach server. Check your connection.');
    }
  }
}