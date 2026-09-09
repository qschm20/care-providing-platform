import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/auth_result.dart';

class AuthRepository {

  //demoo
  static const String demoEmail = 'customer@care.app';
  static const String demoPassword = 'demo1234';

  static const String providerDemoEmail = 'provider@care.app';
  static const String providerDemoPassword = 'demo1234';

  static const String demoToken = 'DEMO_TOKEN';

//real
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );
      if (response.statusCode == 201) {
        return login(email: email, password: password);
      } else {
        final body = jsonDecode(response.body);
        return AuthResult.failure(body['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.failure('Could not reach server. Check your connection.');
    }
  }
//demo
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email == demoEmail && password == demoPassword) {
      return AuthResult.success(
        token: demoToken,
        user: {'name': 'Demo User', 'email': demoEmail, 'role': 'customer'},
      );
    }

    if (email == providerDemoEmail && password == providerDemoPassword) {
      return AuthResult.success(
        token: demoToken, // Reuses the existing DEMO_TOKEN pattern
        user: {'name': 'Demo Provider', 'email': providerDemoEmail, 'role': 'provider'},
      );
    }
//real backend
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return AuthResult.success(token: body['access_token'], user: body['user']);
      } else {
        final body = jsonDecode(response.body);
        return AuthResult.failure(body['detail'] ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.failure('Could not reach server. Check your connection.');
    }
  }
}