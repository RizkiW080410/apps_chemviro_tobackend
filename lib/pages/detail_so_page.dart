import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesOrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const SalesOrderDetailPage({Key? key, required this.order}) : super(key: key);

  double calculateTotalAmount(List<dynamic> products) {
    double total = 0;

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

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final products = List<dynamic>.from(order['products'] ?? []);
    final totalAmount = calculateTotalAmount(products);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'PT. Chemviro Buana Indonesia',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF4CAF50),
                  ),
                ),
                pw.Text(
                  'Head Office',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            // Order details
            pw.Text(
              'Order Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                _buildRow('Order Number', order['order_number']),
                _buildRow('Client', order['client']?['name']),
                _buildRow('Address', order['client']?['address']),
                _buildRow('Email', order['client']?['email']),
                _buildRow('Phone', order['client']?['phone']),
                _buildRow('Status', order['status']),
              ],
            ),
            pw.SizedBox(height: 20),
            // Product details
            pw.Text(
              'Products',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 10),
            ...products.map((product) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(product['name'] ?? 'Unknown Product'),
                    pw.Text(
                      'Rp. ${product['price_product'] != null ? double.tryParse(product['price_product']['price'].toString())?.toStringAsFixed(2) ?? "0.00" : "0.00"}',
                    ),
                  ],
                )),
            pw.SizedBox(height: 20),
            // Total amount
            pw.Text(
              'Total Amount: Rp. ${totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${outputDir.path}/sales_order_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      Get.snackbar(
        'Success',
        'PDF downloaded to ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final products = List<dynamic>.from(order['products'] ?? []);
    final totalAmount = calculateTotalAmount(products);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Sales Order Details',
          style: TextStyle(
            color: Colors.green,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: screenWidth * 0.05,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                      'Order Number', order['order_number'] ?? '', screenWidth),
                  _buildDetailRow(
                      'Client', order['client']?['name'] ?? '', screenWidth),
                  _buildDetailRow('Address', order['client']?['address'] ?? '',
                      screenWidth),
                  _buildDetailRow(
                      'Email', order['client']?['email'] ?? '', screenWidth),
                  _buildDetailRow(
                      'Phone', order['client']?['phone'] ?? '', screenWidth),
                  _buildDetailRow('Status', order['status'] ?? '', screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'Products',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            ...products.map((product) {
              return _buildProductRow(
                product['name'] ?? 'Unknown Product',
                product['price_product'] != null
                    ? 'Rp. ${double.tryParse(product['price_product']['price'].toString())?.toStringAsFixed(2) ?? "0.00"}'
                    : 'Rp. 0.00',
                screenWidth,
              );
            }).toList(),
            Divider(),
            _buildSummaryRow('Total Amount',
                'Rp. ${totalAmount.toStringAsFixed(2)}', screenWidth),
            SizedBox(height: screenWidth * 0.04),
            ElevatedButton(
              onPressed: () => generatePdf(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                minimumSize: Size(double.infinity, screenWidth * 0.12),
              ),
              child: Text(
                'Download PDF',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, String price, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildRow(String label, String? value) {
    return pw.TableRow(
      children: [
        pw.Text(
          '$label:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value ?? '',
          style: pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
