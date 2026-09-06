import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/api_client.dart';

class ProviderRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // --- PROFILE METHODS ---

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/provider/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(
      String token, String bio, String serviceArea) async {
    final response = await http.put(
      Uri.parse('$baseUrl/provider/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'bio': bio, 'service_area': serviceArea}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> submitVerification(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/provider/profile/submit-verification'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // --- SERVICES METHODS ---

  Future<Map<String, dynamic>> getServices(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/provider/services/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createService(
      String token, Map<String, dynamic> serviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/provider/services/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(serviceData),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateService(
      String token, String serviceId, Map<String, dynamic> serviceData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/provider/services/$serviceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(serviceData),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteService(String token, String serviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/provider/services/$serviceId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    // 204 No Content is the standard success response for DELETE
    if (response.statusCode == 204) {
      return {'success': true, 'data': null};
    } else {
      return {
        'success': false,
        'errorMessage': jsonDecode(response.body)['detail'] ?? 'Failed to delete service',
      };
    }
  }

  // --- HELPER ---

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle cases where the response body might be empty (like 204 No Content)
      if (response.body.isEmpty) {
        return {'success': true, 'data': null};
      }
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      try {
        return {
          'success': false,
          'errorMessage': jsonDecode(response.body)['detail'] ?? 'An error occurred',
        };
      } catch (e) {
        return {
          'success': false,
          'errorMessage': 'An unexpected error occurred',
        };
      }
    }
  }
}