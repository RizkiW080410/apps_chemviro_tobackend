import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';
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
            .map((discount) => {
                  'id': discount['id'],
                  'name': discount['name'],
                  'percentage': discount['percentage'] ?? 0
                })
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch dropdown data: $e")),
      );
    }
  }

  double _calculateSubtotal() {
    final selectedProducts = _products
        .where((product) => _selectedProducts.contains(product.priceId))
        .toList();

    return selectedProducts.fold<double>(
      0.0,
      (sum, product) {
        final price = double.tryParse(product.price) ?? 0.0;
        return sum + price;
      },
    );
  }

  double _calculateTotalPrice() {
    final subtotal = _calculateSubtotal();

    // Get the discount percentage
    final discount = _discounts.firstWhere(
      (d) => d['id'] == _selectedDiscountId,
      orElse: () => {'percentage': 0},
    );
    final discountPercentage = (discount['percentage'] as num).toDouble() / 100;

    // Calculate tax
    final tax = subtotal * 0.11;

    // Apply discount and add tax to subtotal
    return (subtotal * (1 - discountPercentage)) + tax;
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
        _showOrderSummary();
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

  void _showOrderSummary() {
    final subtotal = _calculateSubtotal();
    final tax = subtotal * 0.11;
    final totalPrice = _calculateTotalPrice();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Summary",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Status:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        )),
                    Text(_selectedStatus ?? "Unknown",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Client:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      _clients.firstWhere(
                          (c) => c['id'] == _selectedClientId)['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Branch:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      _branchCompanies.firstWhere(
                          (b) => b['id'] == _selectedBranchCompanyId)['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Discount:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      _discounts.firstWhere(
                          (d) => d['id'] == _selectedDiscountId)['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  "Products:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ..._selectedProducts.map((id) {
                  final product = _products.firstWhere((p) => p.priceId == id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                )),
                            Text("Rp${product.price}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                )),
                          ],
                        ),
                        Text(
                          "Category: ${product.category}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 20, thickness: 1.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal:",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Rp${subtotal.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tax (11%):",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Rp${tax.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Price:",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp${totalPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(Routes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "BACK TO HOME",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              Text(
                "Select Products",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Wrap(
                children: _products
                    .map(
                      (product) => ChoiceChip(
                        label: Text(product.name),
                        selected:
                            _selectedProducts.contains(product.priceId ?? -1),
                        onSelected: (selected) {
                          setState(() {
                            if (selected && product.priceId != null) {
                              _selectedProducts.add(product.priceId!);
                            } else {
                              _selectedProducts.remove(product.priceId);
                            }
                          });
                        },
                      ),
                    )
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
