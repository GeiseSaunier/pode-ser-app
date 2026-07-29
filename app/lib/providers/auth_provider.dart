import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  AuthStatus _status = AuthStatus.loading;

  AppUser? get user => _user;
  AuthStatus get status => _status;

  AuthProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await refreshUser();
  }

  Future<void> refreshUser() async {
    try {
      final data = await ApiClient.me();
      _user = AppUser.fromJson(data);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await ApiClient.clearToken();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await ApiClient.login(email, password);
    await ApiClient.setToken(result['token']);
    await refreshUser();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required List<String> oferece,
    required List<String> quer,
  }) async {
    final result = await ApiClient.register(
      name: name,
      email: email,
      password: password,
      oferece: oferece,
      quer: quer,
    );
    await ApiClient.setToken(result['token']);
    await refreshUser();
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
