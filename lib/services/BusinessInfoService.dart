import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:invo/models/business_info.dart';
import 'package:mime/mime.dart';
import 'AuthService.dart';

// Custom exception for unauthorized access
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => message;
}

class BusinessInfoService {
  final String baseUrl = 'http://localhost:9090/api/business-info';

  // Get auth token from AuthService
  Future<String> _getAuthToken() async {
    final authService = AuthService();
    final token = await authService.getToken();
    
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('You must be logged in to perform this action. Please log in and try again.');
    }
    
    return token;
  }


  void _validateBusinessInfo(BusinessInfo businessInfo) {
    if (businessInfo.businessName.isEmpty) {
      throw Exception('Business name is required');
    }
    if (businessInfo.address.isEmpty) {
      throw Exception('Address is required');
    }
    if (businessInfo.phone.isEmpty) {
      throw Exception('Phone is required');
    }
    if (businessInfo.email.isEmpty || !businessInfo.email.contains('@')) {
      throw Exception('Valid email is required');
    }
    if (businessInfo.website.isEmpty) {
      throw Exception('Website is required');
    }
    if (businessInfo.createdBy.isEmpty) {
      throw Exception('Creator username is required');
    }
  }

  Future<BusinessInfo> createBusinessInfo(BusinessInfo businessInfo) async {
    _validateBusinessInfo(businessInfo);

    final token = await _getAuthToken();

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(businessInfo.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BusinessInfo.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception(
          'Failed to create business info: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Error creating business info: $e');
    }
  }

Future<BusinessInfo> getBusinessInfoByUser(String username) async {
  if (username.trim().isEmpty) {
    throw Exception('Username is required');
  }

  final token = await _getAuthToken();

  final uri = Uri.parse('$baseUrl/by-username/$username');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        final Map<String, dynamic> json = jsonDecode(response.body);
        return BusinessInfo.fromJson(json);

      case 401:
        throw Exception('Unauthorized. Please log in again.');

      case 404:
        throw Exception('No business info found for user: $username');

      default:
        throw Exception(
          'Failed to fetch business info (${response.statusCode}): ${response.body}',
        );
    }
  } on SocketException {
    throw Exception('No internet connection.');
  } on FormatException {
    throw Exception('Invalid response format.');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}


  Future<BusinessInfo> getBusinessInfo(String id) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BusinessInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to fetch business info: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Update existing business info
  Future<BusinessInfo> updateBusinessInfo(BusinessInfo businessInfo) async {
    if (businessInfo.id == null) {
      throw Exception('Cannot update business info without an ID');
    }

    final token = await _getAuthToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${businessInfo.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(businessInfo.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BusinessInfo.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Business info not found.');
      } else {
        throw Exception(
          'Failed to update business info: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error updating business info: $e');
    }
  }

  Future<BusinessInfo> uploadLogo(BusinessInfo businessInfo, List<int> fileBytes, String fileName) async {
    if (businessInfo.id == null) {
      throw Exception('Cannot upload logo for business info without an ID');
    }

    final token = await _getAuthToken();
    final mimeType = fileName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-logo/${businessInfo.id}'),
    );

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return BusinessInfo.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to upload logo: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading logo: $e');
    }
  }
}
