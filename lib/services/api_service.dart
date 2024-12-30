import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apps_chemviro/models/product.dart';

class ApiService {
  static const String baseUrl = "http://localhost/api";
  String? _authToken; // Token autentikasi

  // Simpan token setelah login
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Helper function to set headers with Authorization
  Map<String, String> _getHeaders() {
    if (_authToken == null) {
      throw Exception("Authentication token is not set.");
    }

    return {
      'Authorization': 'Bearer $_authToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // Login method
  Future<String> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        setAuthToken(data['token']); // Simpan token
        return data['token'];
      } else {
        throw Exception("Token not found in response.");
      }
    } else if (response.statusCode == 403) {
      throw Exception("You are not authorized to login.");
    } else if (response.statusCode == 401) {
      throw Exception("Incorrect email or password.");
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  // Fetch list of products
  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse("$baseUrl/products");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> productsData = jsonResponse['data']['data'];
      if (productsData is List) {
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Invalid format for products data.");
      }
    } else {
      throw Exception("Failed to load products: ${response.body}");
    }
  }

  // Fetch list of clients
  Future<List<Map<String, dynamic>>> fetchClients() async {
    final url = Uri.parse("$baseUrl/clients");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null &&
          jsonResponse['data']['data'] != null) {
        return List<Map<String, dynamic>>.from(
            jsonResponse['data']['data'].map((client) {
          if (client.containsKey('id') && client.containsKey('name')) {
            return {
              'id': client['id'],
              'name': client['name'],
            };
          } else {
            throw Exception("Invalid client data format.");
          }
        }));
      } else {
        throw Exception("Invalid format for clients response.");
      }
    } else {
      throw Exception("Failed to load clients: ${response.body}");
    }
  }

  // Fetch list of branch companies
  Future<List<Map<String, dynamic>>> fetchBranchCompanies() async {
    final url = Uri.parse("$baseUrl/branch_companys");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data =
          jsonResponse['data']['data']; // Ambil data dari `data['data']`
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Invalid format for branch companies data.");
      }
    } else {
      throw Exception("Failed to load branch companies: ${response.body}");
    }
  }

  // Create an order
  Future<Map<String, dynamic>> createOrder({
    required String status,
    required int? employeeId,
    required int? discountId,
    required int? clientId,
    required int? branchCompanyId,
    required List<int> products,
  }) async {
    final url = Uri.parse("$baseUrl/orders");
    final headers = _getHeaders();

    final body = json.encode({
      'status': status,
      'employee_id': employeeId,
      'discount_id': discountId,
      'client_id': clientId,
      'branch_company_id': branchCompanyId,
      'products': products,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to create order: ${response.body}");
    }
  }
}
