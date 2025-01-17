import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../routes/route.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const EditOrderPage({super.key, required this.order});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
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
    _initializeOrderData();
    _fetchDropdownData();
  }

  void _initializeOrderData() {
    setState(() {
      _selectedStatus = widget.order['status'];
      _selectedClientId = widget.order['client']?['id'];
      _selectedBranchCompanyId = widget.order['branch_company']?['id'];
      _selectedDiscountId = widget.order['discount']?['id'];
      _selectedProducts = List<int>.from(
        widget.order['products']?.map((p) => p['id']) ?? [],
      );
    });
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

  void _updateOrder() async {
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
      await _apiService.updateOrder(
        orderId: widget.order['id'],
        status: _selectedStatus!,
        clientId: _selectedClientId!,
        branchCompanyId: _selectedBranchCompanyId!,
        discountId: _selectedDiscountId!,
        products: _selectedProducts,
      );

      _showSnackbar(
        title: "Success",
        message: "Order updated successfully!",
        isSuccess: true,
      );
      Get.offAllNamed(Routes.salesOrder);
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
          "Edit Order",
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
                children: _selectedProducts.map((productId) {
                  final product = _products.firstWhere(
                    (product) => product.priceId == productId,
                    orElse: () => Product(
                      name: 'Unknown',
                      categoryProduct: '',
                      category: '',
                      price: '', // Berikan default kosong untuk String nullable
                      priceId: productId,
                    ),
                  );
                  return Chip(
                    label: Text(product.name),
                    onDeleted: () => setState(() {
                      _selectedProducts.remove(productId);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateOrder,
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
                        "UPDATE ORDER",
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
