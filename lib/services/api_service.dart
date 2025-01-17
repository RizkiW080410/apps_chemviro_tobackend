import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apps_chemviro/models/product.dart';
import 'package:apps_chemviro/models/employee.dart';

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
      print(jsonResponse); // Debugging: Periksa struktur data API di konsol
      final data =
          jsonResponse['data']['data']; // Sesuaikan dengan struktur data Anda
      if (data is List) {
        return List<Map<String, dynamic>>.from(data.map((client) {
          return {
            'id': client['id'],
            'name': client['name'],
            'email': client['email'], // Pastikan key sesuai dengan API
            'address': client['address'],
            'phone': client['phone'],
          };
        }));
      } else {
        throw Exception("Invalid format for clients data.");
      }
    } else {
      throw Exception("Failed to load clients: ${response.body}");
    }
  }

  // create client
  Future<void> createClient({
    required String name,
    required String email,
    required String address,
    required String phone,
    required int? branchCompanyId,
  }) async {
    final url = Uri.parse("$baseUrl/clients");
    final headers = _getHeaders();

    final body = json.encode({
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'branch_company_id': branchCompanyId,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to create client: ${response.body}");
    }
  }

  // Fetch list of branch companies
  Future<List<Map<String, dynamic>>> fetchBranchCompanies() async {
    final url = Uri.parse("$baseUrl/branch_companys");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data']['data']; // Ambil dari data['data']
      if (data is List) {
        return List<Map<String, dynamic>>.from(data.map((branch) {
          return {'id': branch['id'], 'name': branch['name']};
        }));
      } else {
        throw Exception("Invalid format for branch companies data.");
      }
    } else {
      throw Exception("Failed to load branch companies: ${response.body}");
    }
  }

  // Tambahkan di dalam ApiService
  Future<List<Map<String, dynamic>>> fetchDiscounts() async {
    final url = Uri.parse(
        "$baseUrl/discounts"); // Ganti "discounts" dengan endpoint API Anda
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null &&
          jsonResponse['data']['data'] != null) {
        return List<Map<String, dynamic>>.from(
          jsonResponse['data']['data'].map((discount) {
            if (discount.containsKey('id') && discount.containsKey('name')) {
              return {
                'id': discount['id'],
                'name':
                    discount['name'], // Pastikan field ini sesuai dengan API
              };
            } else {
              throw Exception("Invalid discount data format.");
            }
          }),
        );
      } else {
        throw Exception("Invalid format for discounts response.");
      }
    } else {
      throw Exception("Failed to load discounts: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final url = Uri.parse("$baseUrl/user");
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch user data: ${response.body}");
    }
  }

  Future<Employee> fetchEmployeeData() async {
    // Endpoint untuk mendapatkan data karyawan
    final url = Uri.parse('$baseUrl/employees/details');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null) {
        return Employee.fromJson(jsonResponse['data']);
      } else {
        throw Exception("Employee data not found.");
      }
    } else {
      throw Exception(
          "Failed to fetch employee data: ${response.body}"); // Debugging error jika API gagal
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

  Future<List<Map<String, dynamic>>> fetchOrdersByStatus(String status) async {
    final url = Uri.parse("$baseUrl/orders?status=$status");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']['data']);
    } else {
      throw Exception("Failed to load orders: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async {
    final url = Uri.parse("$baseUrl/orders/$orderId");
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print("Branch Company Data: ${data['branch_company']}"); // Debugging
      if (data['branch_company'] == null) {
        throw Exception("Branch Company data is missing from API response.");
      }
      return data;
    } else {
      throw Exception("Failed to fetch order details: ${response.body}");
    }
  }

  // Update order
  Future<void> updateOrder({
    required int orderId,
    required String status,
    int? employeeId,
    int? discountId,
    int? clientId,
    int? branchCompanyId,
    List<int>? products,
  }) async {
    final url = Uri.parse("$baseUrl/orders/$orderId");
    final headers = _getHeaders();

    final body = json.encode({
      'status': status,
      if (employeeId != null) 'employee_id': employeeId,
      if (discountId != null) 'discount_id': discountId,
      if (clientId != null) 'client_id': clientId,
      if (branchCompanyId != null) 'branch_company_id': branchCompanyId,
      if (products != null) 'products': products,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception("Failed to update order: ${response.body}");
    }
  }
}
