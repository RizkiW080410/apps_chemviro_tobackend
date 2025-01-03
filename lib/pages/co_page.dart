import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/route.dart';
import '../pages/detail_co_pages.dart';

class CancelOrderPage extends StatefulWidget {
  const CancelOrderPage({super.key});

  @override
  State<CancelOrderPage> createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> cancelOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCancelOrders();
  }

  Future<void> fetchCancelOrders() async {
    try {
      final response = await _apiService.fetchOrdersByStatus('Cancel Order');
      setState(() {
        // Filter hanya order dengan status 'Cancel Order'
        cancelOrders = response
            .where((order) => order['status'] == 'Cancel Order')
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

  double calculateTotalAmount(List<dynamic> products) {
    double total = 0;

    // Kalkulasi total harga produk
    for (var product in products) {
      final priceProduct = product['price_product'];
      final price = priceProduct != null
          ? double.tryParse(priceProduct['price'].toString()) ?? 0.0
          : 0.0;
      total += price;
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
        title:
            const Text('Cancel Order', style: TextStyle(color: Colors.green)),
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
          : cancelOrders.isEmpty
              ? const Center(child: Text('No Cancel Orders Available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: cancelOrders.length,
                  itemBuilder: (context, index) {
                    final order = cancelOrders[index];
                    final products = List<dynamic>.from(order['products']);
                    final totalAmount = calculateTotalAmount(products);

                    return _buildOrderCard(
                      icon: Icons.cancel,
                      title: order['status'],
                      orderNumber: order['order_number'],
                      client: order['client']?['name'] ?? 'Unknown Client',
                      product: products.isNotEmpty
                          ? products.map((p) => p['name']).join(', ')
                          : 'No Products',
                      totalAmount: 'Rp. ${totalAmount.toStringAsFixed(2)}',
                      onPressed: () {
                        // Navigasi ke halaman detail dengan data order
                        Get.to(() => CancelOrderDetailPage(order: order));
                      },
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
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.red),
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
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black54),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
