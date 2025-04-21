import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static const String baseUrl = 'http://localhost:9090/api/auth';

  Future<String?> getUsernameFromToken(String token) async {
    try {
      print('Decoding token: $token');
      
      // Split the token into parts
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid token format - wrong number of parts');
        return null;
      }

      // Decode the payload (second part)
      String normalizedPayload = base64Url.normalize(parts[1]);
      print('Normalized payload: $normalizedPayload');
      
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadStr = utf8.decode(payloadBytes);
      print('Decoded payload string: $payloadStr');
      
      final payloadMap = json.decode(payloadStr);
      print('Decoded payload map: $payloadMap');

      // Try different common JWT claim names for username
      final username = payloadMap['sub'] ?? 
                      payloadMap['username'] ?? 
                      payloadMap['email'] ?? 
                      payloadMap['preferred_username'];
                      
      print('Extracted username from token: $username');
      return username?.toString();
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

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
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    
    if (username != null && username.isNotEmpty) {
      return username;
    }
    
    // Fallback to token if username is not found
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

      final tokenUsername = data['sub'] ?? data['username'];
      if (tokenUsername != null) {
        // Save username for future use
        await prefs.setString('username', tokenUsername);
      }
      return tokenUsername;
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



  // Future<bool> login(String username, String password) async {
  //   final uri = Uri.parse('$baseUrl/signin');

  //   final response = await http.post(
  //     uri,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'username': username, 'password': password}),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final token = data['token'];
  //     if (token != null) {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('auth_token', token);
  //       await prefs.setString('username', data['users']['userName']);
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    List<String> roles = const ['admin'],
  }) async {
    final uri = Uri.parse('$baseUrl/signup');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'userFirstName': firstName,
        'userLastName': lastName,
        'role': roles,
      }),
    );

    return response.statusCode == 200;
  }

  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/signout');
    await http.post(uri);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }



  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

