import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invo/services/AuthService.dart';

class DashboardService {
  static const String baseUrl = "http://localhost:9090/api";

  Future<String> _getAuthToken() async {
    final authService = AuthService();
    final token = await authService.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception('You must be logged in to perform this action. Please log in and try again.');
    }
    
    return token;
  }

  Future<List<double>> getTotalAmountsByUser(String userName) async {
    final token = await _getAuthToken();

    try {
      print('Fetching dashboard data for user: $userName');
      
      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/invoices/totals-by-user/$userName'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse('$baseUrl/invoices/totals-due-by-user/$userName'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse('$baseUrl/invoices/totals-paid-by-user/$userName'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ]);
      
      print('Response status codes: ${responses.map((r) => r.statusCode).toList()}');
      print('Response bodies: ${responses.map((r) => r.body).toList()}');

      if (responses.every((response) => response.statusCode == 200)) {
        final totalAmount = _parseAmount(responses[0].body);
        final totalDue = _parseAmount(responses[1].body);
        final totalPaid = _parseAmount(responses[2].body);
        
        print('Parsed amounts: total=$totalAmount, due=$totalDue, paid=$totalPaid');
        return [totalAmount, totalDue, totalPaid];
      } else {
        final statusCodes = responses.map((r) => r.statusCode).join(', ');
        throw Exception('Failed to load dashboard data. Status codes: $statusCodes');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  double _parseAmount(String body) {
    try {
      if (body.isEmpty) return 0.0;
      
      // Parse JSON
      final data = jsonDecode(body);
      
      // Handle array response
      if (data is List && data.isNotEmpty) {
        final firstItem = data[0];
        if (firstItem is num) return firstItem.toDouble();
        if (firstItem is String) return double.parse(firstItem);
      }
      
      // Handle direct number
      if (data is num) return data.toDouble();
      if (data is String) return double.parse(data);
      
      return 0.0;
    } catch (e) {
      print('Error parsing amount: $e for body: $body');
      return 0.0;
    }
  }
}
    