import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PurchaseOrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const PurchaseOrderDetailPage({Key? key, required this.order})
      : super(key: key);

  double calculateSubtotal(List<dynamic> products) {
    double subtotal = 0.0;
    for (var product in products) {
      final priceProduct = product['price_product'];
      final price = priceProduct != null
          ? double.tryParse(priceProduct['price'].toString()) ?? 0.0
          : 0.0;
      subtotal += price;
    }
    return subtotal;
  }

  double calculateTax(double subtotal) {
    return subtotal * 0.11; // Pajak 11%
  }

  double calculateTotalAmount(double subtotal, double tax) {
    return subtotal + tax;
  }

  @override
  Widget build(BuildContext context) {
    final branchCompany = order['branch_company']; // Ambil data branch_company
    final products = List<dynamic>.from(order['products'] ?? []);
    final subtotal = calculateSubtotal(products);
    final tax = calculateTax(subtotal);
    final totalAmount = calculateTotalAmount(subtotal, tax);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Purchase Order',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with branch company data
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo_login.png', // Path ke logo
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PT. Chemviro Buana Indonesia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        branchCompany?['name'] ?? 'Unknown Branch',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Order Number', order['order_number']),
            _buildDetailRow('Client', order['client']?['name']),
            _buildDetailRow('Address', order['client']?['address']),
            _buildDetailRow('Email', order['client']?['email']),
            _buildDetailRow('Phone', order['client']?['phone']),
            _buildDetailRow('Status', order['status']),
            const SizedBox(height: 16),
            Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...products.map((product) => _buildProductRow(
                  product['name'] ?? 'Unknown',
                  'Rp. ${double.tryParse(product['price_product']?['price']?.toString() ?? '0')?.toStringAsFixed(2)}',
                  product['category'] ?? 'Unknown Category',
                )),
            const Divider(),
            _buildDetailRow('Subtotal', 'Rp. ${subtotal.toStringAsFixed(2)}'),
            _buildDetailRow('Tax Rate', '11%'),
            _buildDetailRow('Total Tax', 'Rp. ${tax.toStringAsFixed(2)}'),
            _buildDetailRow(
                'Total Amount', 'Rp. ${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => generatePdf(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Download PDF',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Text(value ?? '-', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, String amount, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 14)),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Category: $category',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final products = List<dynamic>.from(order['products'] ?? []);
    final subtotal = calculateSubtotal(products);
    final tax = calculateTax(subtotal);
    final totalAmount = calculateTotalAmount(subtotal, tax);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Purchase Order',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Order Number: ${order['order_number'] ?? '-'}'),
              pw.Text(
                  'Branch Company: ${order['branch_company']?['name'] ?? 'Unknown'}'),
              pw.Text('Client: ${order['client']?['name'] ?? '-'}'),
              pw.Text('Address: ${order['client']?['address'] ?? '-'}'),
              pw.Text('Email: ${order['client']?['email'] ?? '-'}'),
              pw.Text('Phone: ${order['client']?['phone'] ?? '-'}'),
              pw.Text('Status: ${order['status'] ?? '-'}'),
              pw.SizedBox(height: 16),
              pw.Text('Items:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Text('Name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Category',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...products.map(
                    (product) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(product['name'] ?? 'Unknown'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Rp. ${double.tryParse(product['price_product']?['price']?.toString() ?? '0')?.toStringAsFixed(2)}',
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(product['category'] ?? 'Unknown'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Text('Subtotal: Rp. ${subtotal.toStringAsFixed(2)}'),
              pw.Text('Tax (11%): Rp. ${tax.toStringAsFixed(2)}'),
              pw.Text('Total: Rp. ${totalAmount.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/purchase_order_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      Get.snackbar('Success', 'PDF berhasil disimpan di ${file.path}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan PDF: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
