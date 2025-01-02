import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/route.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key});

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> salesOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalesOrders();
  }

  Future<void> fetchSalesOrders() async {
    try {
      final response = await _apiService.fetchOrdersByStatus('Sales Order');
      setState(() {
        salesOrders = response
            .where((order) => order['status'] == 'Sales Order')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  double calculateTotalAmount(
      List<Map<String, dynamic>> products, double? discountPercent) {
    double total = 0;

    // Kalkulasi total harga produk
    for (var product in products) {
      total += product['price'] ?? 0.0;
    }

    // Terapkan diskon jika ada
    if (discountPercent != null && discountPercent > 0) {
      total -= (total * discountPercent / 100);
    }

    // Tambahkan pajak 11%
    total += (total * 11 / 100);

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed(Routes.profile);
          },
        ),
        title: const Text('Sales Order', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : salesOrders.isEmpty
              ? const Center(child: Text('No Sales Orders Available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: salesOrders.length,
                  itemBuilder: (context, index) {
                    final order = salesOrders[index];
                    final products =
                        List<Map<String, dynamic>>.from(order['products']);
                    final totalAmount = calculateTotalAmount(
                      products,
                      order['discount']?['percent']?.toDouble(),
                    );

                    return _buildOrderCard(
                      icon: Icons.air,
                      title: order['status'],
                      orderNumber: order['order_number'],
                      client: order['client']['name'] ?? 'Unknown Client',
                      product: products.isNotEmpty
                          ? products.map((p) => p['category']).join(', ')
                          : 'No Products',
                      totalAmount: 'Rp. ${totalAmount.toStringAsFixed(2)}',
                    );
                  },
                ),
    );
  }

  Widget _buildOrderCard({
    required IconData icon,
    required String title,
    required String orderNumber,
    required String client,
    required String product,
    required String totalAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Order Number: $orderNumber"),
                Text("Client: $client"),
                Text("Product: $product"),
                Text("Total Amount: $totalAmount"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle Sales Order button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sales Order'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black54),
            onPressed: () {
              Get.toNamed(Routes.detailSalesOrder);
            },
          ),
        ],
      ),
    );
  }
}
