import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/api_client.dart';

class ProviderRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // --- MOCK STATE FOR DEMO MODE ---
  static final Map<String, dynamic> _demoProfile = {
    'id': 'demo-profile-id',
    'user_id': 'demo-provider-id',
    'bio': 'Certified caregiver with 5+ years of experience in elderly and special needs care. Compassionate, reliable, and trained in first aid.',
    'service_area': 'Kathmandu, Lalitpur, Bhaktapur',
    'verification_status': 'approved',
    'verification_date': '2026-09-01T10:00:00Z',
    'created_at': '2026-08-01T10:00:00Z',
    'updated_at': '2026-09-01T10:00:00Z',
  };

  static final List<Map<String, dynamic>> _demoServices = [
    {
      'id': 'demo-service-1',
      'provider_id': 'demo-provider-id',
      'title': 'Comprehensive Senior Companion',
      'category': 'senior_care',
      'description': 'Providing compassionate overnight care, medication management, and mobility support for elderly patients.',
      'price': 350.00,
      'pricing_unit': 'hourly',
      'hours': 2.0,
      'skills': ['Nursing & Health Monitoring', 'Mobility Support', 'Cooking Meals', 'Doctor Visit Accompaniment'],
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-01T10:00:00Z',
    },
    {
      'id': 'demo-service-2',
      'provider_id': 'demo-provider-id',
      'title': 'Professional Pet Sitting & Walking',
      'category': 'pet_care',
      'description': 'Reliable and loving care for your furry friends while you are away. Includes feeding, walking, and updates.',
      'price': 200.00,
      'pricing_unit': 'per_session',
      'hours': 1.0,
      'skills': ['Dog Walking', 'Pet Feeding', 'Basic Training'],
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-01T10:00:00Z',
    }
  ];
  // --------------------------------

  // --- PROFILE METHODS ---

  Future<Map<String, dynamic>> getProfile(String token) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'data': Map.from(_demoProfile)};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, String bio, String serviceArea) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 500));
      _demoProfile['bio'] = bio;
      _demoProfile['service_area'] = serviceArea;
      _demoProfile['updated_at'] = DateTime.now().toIso8601String();
      return {'success': true, 'data': Map.from(_demoProfile)};
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/provider/profile/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'bio': bio, 'service_area': serviceArea}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitVerification(String token) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 500));
      _demoProfile['verification_status'] = 'pending';
      _demoProfile['verification_date'] = null;
      _demoProfile['updated_at'] = DateTime.now().toIso8601String();
      return {'success': true, 'data': Map.from(_demoProfile)};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/provider/profile/submit-verification'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  // --- SERVICES METHODS ---

  Future<Map<String, dynamic>> getServices(String token) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'data': List.from(_demoServices)};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/services/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createService(String token, Map<String, dynamic> serviceData) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 800));
      final newService = {
        ...serviceData,
        'id': 'demo-service-${DateTime.now().millisecondsSinceEpoch}',
        'provider_id': 'demo-provider-id',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      _demoServices.add(newService);
      return {'success': true, 'data': newService};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/provider/services/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(serviceData),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateService(String token, String serviceId, Map<String, dynamic> serviceData) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 800));
      final index = _demoServices.indexWhere((s) => s['id'] == serviceId);
      if (index != -1) {
        _demoServices[index] = {
          ..._demoServices[index],
          ...serviceData,
          'updated_at': DateTime.now().toIso8601String(),
        };
        return {'success': true, 'data': _demoServices[index]};
      }
      return {'success': false, 'errorMessage': 'Service not found'};
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/provider/services/$serviceId'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(serviceData),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteService(String token, String serviceId) async {
    if (token == 'DEMO_TOKEN') {
      await Future.delayed(const Duration(milliseconds: 500));
      _demoServices.removeWhere((s) => s['id'] == serviceId);
      return {'success': true, 'data': null};
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/provider/services/$serviceId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204) {
        return {'success': true, 'data': null};
      } else {
        return {
          'success': false,
          'errorMessage': jsonDecode(response.body)['detail'] ?? 'Failed to delete service',
        };
      }
    } catch (e) {
      return {'success': false, 'errorMessage': 'Network error: $e'};
    }
  }

  // --- HELPER ---

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
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