import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apps_chemviro/models/employee.dart';
import 'package:apps_chemviro/services/api_service.dart';
import '../routes/route.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = Get.find<ApiService>();
  Employee? _employeeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    try {
      // Ambil data karyawan berdasarkan token
      final employee = await _apiService.fetchEmployeeData();
      setState(() {
        _employeeData = employee;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
          onPressed: () {
            Get.offNamed(Routes.home);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employeeData == null
              ? const Center(child: Text("Data not available"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  const AssetImage('assets/images/avatar.png'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _employeeData?.userName ?? 'Unknown Name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _employeeData?.department ?? 'Unknown Department',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                              'SO',
                              _employeeData?.soCount.toString() ?? '0',
                              Routes.salesOrder),
                          _buildStatCard(
                              'PO',
                              _employeeData?.poCount.toString() ?? '0',
                              Routes.purchaseOrder),
                          _buildStatCard(
                              'CO',
                              _employeeData?.coCount.toString() ?? '0',
                              Routes.cancelOrder),
                          _buildStatCard(
                              'Client',
                              _employeeData?.clientCount.toString() ?? '0',
                              Routes.client),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailItem(Icons.phone, 'Nomor Telepon',
                          _employeeData?.phone ?? 'Unknown Phone'),
                      _buildDetailItem(Icons.email, 'Email',
                          _employeeData?.userEmail ?? 'Unknown Email'),
                      _buildDetailItem(Icons.business, 'Company',
                          _employeeData?.branchCompany ?? 'Unknown Company'),
                      _buildDetailItem(
                          Icons.location_city,
                          'Branch Company',
                          _employeeData?.branchCompanyAddress ??
                              'Unknown Address'),
                      _buildDetailItem(Icons.apartment, 'Department',
                          _employeeData?.department ?? 'Unknown Department'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, String route) {
    return GestureDetector(
      onTap: () {
        Get.offNamed(route);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
