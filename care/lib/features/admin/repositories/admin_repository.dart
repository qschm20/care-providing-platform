import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart'; // Adjust if your ApiConfig is elsewhere

class AdminRepository {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> getProviders({String? status, required String token}) async {
    final uri = Uri.parse('$baseUrl/admin/providers${status != null ? '?status=$status' : ''}');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load providers: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> approveProvider(String providerId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/providers/$providerId/approve'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to approve');
  }

  Future<Map<String, dynamic>> rejectProvider(String providerId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/providers/$providerId/reject'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to reject');
  }
}