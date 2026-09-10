import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/provider_search_model.dart';

class ProviderSearchRepository {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<ProviderSearchModel>> searchProviders({
    required String token,
    String? category,
    String? serviceArea,
    String? search,
  }) async {
    // Build the URI with optional query parameters
    final uri = Uri.parse('$baseUrl/providers/search').replace(
      queryParameters: {
        if (category != null) 'category': category,
        if (serviceArea != null) 'service_area': serviceArea,
        if (search != null) 'search': search,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProviderSearchModel.fromJson(e)).toList();
    } else {
      // If the token is invalid or expired, the backend returns 401
      throw Exception('Failed to search providers: ${response.statusCode}');
    }
  }
}