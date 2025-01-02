import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../routes/route.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final ApiService _apiService = Get.find<ApiService>();
  bool _isLoading = false;

  List<Product> _products = [];
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _branchCompanies = [];
  List<Map<String, dynamic>> _discounts = [];
  String? _selectedStatus;
  int? _selectedClientId;
  int? _selectedBranchCompanyId;
  int? _selectedDiscountId;
  List<int> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final products = await _apiService.fetchProducts();
      final clients = await _apiService.fetchClients();
      final branchCompanies = await _apiService.fetchBranchCompanies();
      final discounts = await _apiService.fetchDiscounts();

      setState(() {
        _products = products;
        _clients = clients
            .map((client) => {'id': client['id'], 'name': client['name']})
            .toList();
        _branchCompanies = branchCompanies
            .map((branch) => {'id': branch['id'], 'name': branch['name']})
            .toList();
        _discounts = discounts
            .map((discount) => {'id': discount['id'], 'name': discount['name']})
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch dropdown data: $e")),
      );
    }
  }

  void _createOrder() async {
    if (_selectedStatus == null ||
        _selectedClientId == null ||
        _selectedBranchCompanyId == null ||
        _selectedDiscountId == null ||
        _selectedProducts.isEmpty) {
      _showSnackbar(
        title: "Error",
        message: "All required fields must be filled!",
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.createOrder(
        status: _selectedStatus!,
        employeeId: null,
        discountId: _selectedDiscountId!,
        clientId: _selectedClientId!,
        branchCompanyId: _selectedBranchCompanyId!,
        products: _selectedProducts,
      );

      if (response["message"] == "Successfully Create Order") {
        _showSnackbar(
          title: "Success",
          message: "Order created successfully!",
          isSuccess: true,
        );
        Get.offAllNamed(Routes.home);
      } else {
        _showSnackbar(
          title: "Error",
          message: response["message"] ?? "An error occurred.",
          isSuccess: false,
        );
      }
    } catch (e) {
      _showSnackbar(
        title: "Error",
        message: e.toString(),
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Widget buildDropdown<T>({
    required String label,
    required List<Map<String, dynamic>> items,
    required T? value,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item['id'] as T,
                child: Text(item['name']),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          "Create Order",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: [
                  {'id': 'Sales Order', 'name': 'Sales Order'},
                  {'id': 'Purchase Order', 'name': 'Purchase Order'},
                  {'id': 'Cancel Order', 'name': 'Cancel Order'},
                ]
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(item['name']!),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                decoration: const InputDecoration(
                  labelText: "Select Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildDropdown<int>(
                label: "Select Client",
                items: _clients,
                value: _selectedClientId,
                onChanged: (value) => setState(() => _selectedClientId = value),
              ),
              const SizedBox(height: 20),
              buildDropdown<int>(
                label: "Select Branch Company",
                items: _branchCompanies,
                value: _selectedBranchCompanyId,
                onChanged: (value) =>
                    setState(() => _selectedBranchCompanyId = value),
              ),
              const SizedBox(height: 20),
              buildDropdown<int>(
                label: "Select Discount",
                items: _discounts,
                value: _selectedDiscountId,
                onChanged: (value) =>
                    setState(() => _selectedDiscountId = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: null,
                items: _products
                    .map((product) => DropdownMenuItem<int>(
                          value: product.priceId,
                          child: Text(product.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null && !_selectedProducts.contains(value)) {
                    setState(() => _selectedProducts.add(value));
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Select Product",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              Wrap(
                children: _selectedProducts
                    .map((productId) => Chip(
                          label: Text(
                            _products
                                .firstWhere(
                                    (product) => product.priceId == productId)
                                .name,
                          ),
                          onDeleted: () => setState(
                              () => _selectedProducts.remove(productId)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CREATE ORDER",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
