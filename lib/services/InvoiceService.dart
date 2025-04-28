import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invo/models/invoice_model.dart';
import 'package:invo/services/AuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceService {
  static const String baseUrl = "http://localhost:9090/api/invoices";

  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      // Get token from shared preferences directly since that's where login saves it
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get username from token for createdBy field
      final authService = AuthService();
      final username = await authService.getUsernameFromToken(token);
      
      if (username == null || username.isEmpty) {
        throw Exception('Could not get username from token');
      }
      
      print('Setting createdBy fields...');
      print('Username from token: $username');
      
      // Create a separate client object first
      Map<String, dynamic>? clientData;
      if (invoice.client != null) {
        clientData = {
          ...invoice.client!.toJson(),
          'createdBy': username,  // Explicitly set createdBy for client
        };
        print('Client data prepared: $clientData');
      }

      // Create the request body
      final Map<String, dynamic> requestBody = {
        ...invoice.toJson(),
        'createdBy': username,  // Set for invoice
        if (clientData != null) 'client': clientData,  // Use our prepared client data
      };
      
      print('Full request body being sent: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Ensure client data has createdBy
        if (responseData['client'] != null) {
          // If server didn't set createdBy, set it here
          if (responseData['client']['createdBy'] == null) {
            responseData['client']['createdBy'] = username;
          }
        }
        
        print("Final response data with client: ${jsonEncode(responseData)}");
        return Invoice.fromJson(responseData);
      } else {
        throw Exception(
          "Failed to create Invoice: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error creating invoice: $e");
    }
  }


 Future<Map<String, dynamic>> getAll({int page = 0, int size = 10}) async {
  final Uri url = Uri.parse('$baseUrl?page=$page&size=$size');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    List<Invoice> invoices = (data['content'] as List)
        .map((invoiceJson) => Invoice.fromJson(invoiceJson))
        .toList();

    return {
      'invoices': invoices,
      'totalPages': data['totalPages'],
      'currentPage': data['number'],
    };
  } else {
    throw Exception('Failed to load invoices');
  }
}


  Future<Invoice> getInvoiceById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Invoice not found");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // POST: Create a new product

  // PUT: Update product
  Future<Invoice> updateProduct(Invoice invoice) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${invoice.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(invoice.toJson()),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update product");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // DELETE: Delete product
  Future<void> deleteInvoice(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 204) {
        return; // Successfully deleted
      } else {
        throw Exception("Failed to delete Invoice");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getPaidInvoices({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'asc',
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/paid?page=$page&size=$size&sortBy=$sortBy&direction=$direction',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      List<Invoice> invoices = (data['content'] as List)
          .map((invoiceJson) => Invoice.fromJson(invoiceJson))
          .toList();

      return {
        'invoices': invoices,
        'totalPages': data['totalPages'],
        'currentPage': data['number'],
      };
    } else {
      throw Exception('Failed to load paid invoices');
    }
  }

    Future<Map<String, dynamic>> getUnpaidInvoices({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'asc',
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/unpaid?page=$page&size=$size&sortBy=$sortBy&direction=$direction',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      List<Invoice> invoices = (data['content'] as List)
          .map((invoiceJson) => Invoice.fromJson(invoiceJson))
          .toList();

      return {
        'invoices': invoices,
        'totalPages': data['totalPages'],
        'currentPage': data['number'],
      };
    } else {
      throw Exception('Failed to load unpaid invoices: ${response.statusCode} - ${response.body}');
    }
  }

    Future<Map<String, dynamic>> getOverDueInvoices({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'asc',
  }) async {
    final Uri url = Uri.parse(
      '$baseUrl/overdue?page=$page&size=$size&sortBy=$sortBy&direction=$direction',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      List<Invoice> invoices = (data['content'] as List)
          .map((invoiceJson) => Invoice.fromJson(invoiceJson))
          .toList();

      return {
        'invoices': invoices,
        'totalPages': data['totalPages'],
        'currentPage': data['number'],
      };
    } else {
      throw Exception('Failed to load overdue invoices: ${response.statusCode} - ${response.body}');
    }
  }


Future<Map<String, dynamic>> searchInvoices(String invoiceNumber) async {
  try {
    final uri = Uri.parse(
      '$baseUrl/search?invoiceNumber=$invoiceNumber&page=0&size=10',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Invoices: ${data['content']}');
      return {
        'invoices': data['content'],
        'totalPages': data['totalPages'],
        'currentPage': data['number'],
      };
    } else {
      throw Exception('Failed to search invoices');
    }
  } catch (e) {
    throw Exception('Exception during invoice search: $e');
  }
}


}
