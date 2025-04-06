// lib/services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invo/models/invoice_model.dart';

class InvoiceService {
  static const String baseUrl = "http://localhost:9090/api/invoices"; 

  // GET: Fetch all products
  Future<List<Invoice>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // If the response is a Map with a data field containing the array
        if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            return (data['data'] as List)
                .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          // If we get a single product, wrap it in a list
          return [Invoice.fromJson(Map<String, dynamic>.from(data))];
        }
        
        // If the response is directly an array
        if (data is List) {
          return data
              .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception("Invalid response format");
      } else {
        throw Exception("Failed to load Invoices: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }



Future<List<Invoice>> getAll() async {
    final Uri url = Uri.parse(baseUrl);  // Adjust the endpoint if needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if 'content' is available in the response, then map it to a list of Product objects.
      List<Invoice> invoice = (data['content'] as List)
          .map((productJson) => Invoice.fromJson(productJson))
          .toList();

      return invoice;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load Invoices');
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
  Future<Invoice> createProduct(Invoice invoice) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(invoice.toJson()),
      );

      if (response.statusCode == 201) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create Invoice");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

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
        return;  // Successfully deleted
      } else {
        throw Exception("Failed to delete Invoice");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}