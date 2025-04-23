// lib/services/Client_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:invo/services/AuthService.dart';
import 'package:invo/services/BusinessInfoService.dart';
import '../models/client_model.dart';

class ClientService {
  static const String baseUrl = "http://localhost:9090/api/clients"; 

  Future<String> _getAuthToken() async {
    final authService = AuthService();
    final token = await authService.getToken();
    
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('You must be logged in to perform this action. Please log in and try again.');
    }
    
    return token;
  }



Future<Map<String, dynamic>> getClientsByUser(String username, int page, int size) async {
  final token = await _getAuthToken();
  final uri = Uri.parse('$baseUrl/by-username/$username?page=$page&size=$size');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // This should be a paginated Map with "content", "totalPages", etc.
    } else {
      throw Exception('Failed to fetch clients: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}



  // GET: Fetch all clients
  // Future<List<Client>> getAllClients() async {
  //   try {
  //     final response = await http.get(Uri.parse(baseUrl));

  //     if (response.statusCode == 200) {
  //       final dynamic data = jsonDecode(response.body);
        
  //       // If the response is a Map with a data field containing the array
  //       if (data is Map) {
  //         if (data.containsKey('data') && data['data'] is List) {
  //           return (data['data'] as List)
  //               .map((json) => Client.fromJson(json as Map<String, dynamic>))
  //               .toList();
  //         }
  //         // If we get a single client, wrap it in a list
  //         return [Client.fromJson(Map<String, dynamic>.from(data))];
  //       }
        
  //       // If the response is directly an array
  //       if (data is List) {
  //         return data
  //             .map((json) => Client.fromJson(json as Map<String, dynamic>))
  //             .toList();
  //       }
        
  //       throw Exception("Invalid response format");
  //     } else {
  //       throw Exception("Failed to load clients: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Error: $e");
  //   }
  // }



// Future<Map<String, dynamic>> getAll({int page = 0, int size = 10}) async {
//   final Uri url = Uri.parse('$baseUrl?page=$page&size=$size');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);

//     List<Client> clients = (data['content'] as List)
//         .map((clientJson) => Client.fromJson(clientJson))
//         .toList();

//     return {
//       'clients': clients,
//       'totalPages': data['totalPages'],
//       'currentPage': data['number'],
//     };
//   } else {
//     throw Exception('Failed to load clients');
//   }
// }



 Future<Client> getClientById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Client not found");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // POST: Create a new client
  Future<Client> createClient(Client client) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 201) {
        return Client.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create client");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // PUT: Update client
  Future<Client> updateClient(Client client) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${client.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update client");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // DELETE: Delete client
  Future<void> deleteClient(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 204) {
        return;  // Successfully deleted
      } else {
        throw Exception("Failed to delete Client");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }






  Future<double> getTotalAmount(int clientId) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/total-amount/$clientId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        throw Exception('Failed to load total amount: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch total amount: $e');
    }
  }

  Future<double> getTotalPaidAmount(int clientId) async {
  final token = await _getAuthToken();
  final url = Uri.parse('$baseUrl/total-paid/$clientId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to load total paid: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch total paid: $e');
  }
}


Future<double> getTotalDueAmount(int clientId) async {
  final token = await _getAuthToken();
  final url = Uri.parse('$baseUrl/total-due/$clientId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to load total due: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch total due: $e');
  }
}

}

