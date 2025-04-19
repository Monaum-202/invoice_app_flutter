import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final _storage = const FlutterSecureStorage();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Key used for storing the JWT token
  static const String tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
    // Also save to SharedPreferences as a backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> getToken() async {
    // First try to get from secure storage
    String? token = await _storage.read(key: tokenKey);
    
    if (token == null || token.isEmpty) {
      // If not found in secure storage, try SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(tokenKey);
      
      // If found in SharedPreferences, save it to secure storage for next time
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: tokenKey, value: token);
      }
    }
    
    return token;
  }

  Future<String?> getUsername() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      // JWT token consists of three parts: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);

      // The username is typically stored in 'sub' or 'username' claim
      return data['sub'] ?? data['username'];
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    // Clear from both secure storage and SharedPreferences
    await _storage.delete(key: tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}
