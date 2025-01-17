import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/route.dart';
import '../pages/detail_po_page.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> purchaseOrders = [];
  bool isLoading = true;
  double totalSalesIncome = 0.0;

  @override
  void initState() {
    super.initState();
    fetchPurchaseOrders();
  }

  Future<void> fetchPurchaseOrders() async {
    try {
      final response = await _apiService.fetchOrdersByStatus('Purchase Order');
      setState(() {
        purchaseOrders = response
            .where((order) => order['status'] == 'Purchase Order')
            .toList();
        totalSalesIncome = calculateTotalSalesIncome(purchaseOrders);
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

    for (var product in products) {
      final priceProduct = product['price_product'];
      final price = priceProduct != null
          ? double.tryParse(priceProduct['price'].toString()) ?? 0.0
          : 0.0;
      total += price;
    }

    total += (total * 11 / 100);

    return total;
  }

  double calculateTotalSalesIncome(List<Map<String, dynamic>> orders) {
    double salesIncome = 0.0;

    for (var order in orders) {
      final products = List<dynamic>.from(order['products']);
      final totalAmount = calculateTotalAmount(products);
      salesIncome += (totalAmount * 5 / 100);
    }

    return salesIncome;
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
            const Text('Purchase Order', style: TextStyle(color: Colors.green)),
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
          : purchaseOrders.isEmpty
              ? const Center(child: Text('No Purchase Orders Available'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: purchaseOrders.length,
                        itemBuilder: (context, index) {
                          final order = purchaseOrders[index];
                          final products =
                              List<dynamic>.from(order['products']);
                          final totalAmount = calculateTotalAmount(products);

                          return _buildOrderCard(
                            icon: Icons.water_drop,
                            title: order['status'],
                            orderNumber: order['order_number'],
                            client:
                                order['client']?['name'] ?? 'Unknown Client',
                            product: products.isNotEmpty
                                ? products.map((p) => p['name']).join(', ')
                                : 'No Products',
                            totalAmount:
                                'Rp. ${totalAmount.toStringAsFixed(2)}',
                            onPressed: () {
                              Get.to(
                                  () => PurchaseOrderDetailPage(order: order));
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total Sales Income: Rp. ${totalSalesIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.blue),
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
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Purchase Order'),
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
