class AuthResult {
  final bool success;
  final String? token;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  AuthResult.success({required this.token, required this.user})
      : success = true,
        errorMessage = null;

  AuthResult.failure(this.errorMessage)
      : success = false,
        token = null,
        user = null;
}