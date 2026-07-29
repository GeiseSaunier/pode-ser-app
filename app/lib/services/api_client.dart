import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Aponta pro mesmo backend Express + Prisma + Postgres do projeto web.
/// Troque para o host de produção antes de publicar nas lojas.
const String kApiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:3333', // 10.0.2.2 = localhost do host, visto de dentro do emulador Android
);

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'pode_ser_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> setToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$kApiBaseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    late http.Response response;
    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      default:
        response = await http.get(uri, headers: headers);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message = 'Erro ${response.statusCode}';
    try {
      final decoded = jsonDecode(response.body);
      message = decoded['error'] ?? message;
    } catch (_) {}
    throw ApiException(message);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required List<String> oferece,
    required List<String> quer,
  }) async {
    final data = await _request('/auth/register',
        method: 'POST', body: {'name': name, 'email': email, 'password': password, 'oferece': oferece, 'quer': quer});
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _request('/auth/login', method: 'POST', body: {'email': email, 'password': password});
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> me() async {
    final data = await _request('/users/me');
    return data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> searchSkills({String? q, String? mode}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (mode != null) params['mode'] = mode;
    final query = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    final data = await _request('/skills$query');
    return data as List<dynamic>;
  }

  static Future<List<dynamic>> myTransactions() async {
    final data = await _request('/transactions');
    return data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> proposeTransaction(String skillId) async {
    final data = await _request('/transactions', method: 'POST', body: {'skillId': skillId});
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> confirmTransaction(String id) async {
    final data = await _request('/transactions/$id/confirm', method: 'POST');
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> openDispute({
    required String transactionId,
    required String reason,
    required String description,
  }) async {
    final data = await _request('/disputes',
        method: 'POST', body: {'transactionId': transactionId, 'reason': reason, 'description': description});
    return data as Map<String, dynamic>;
  }
}
