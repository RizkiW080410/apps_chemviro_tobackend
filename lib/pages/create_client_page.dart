import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late final ApiService _apiService;
  bool _isLoading = false;
  bool _isBranchLoading = true;

  int? _selectedBranchCompanyId;
  List<Map<String, dynamic>> _branchCompanies = [];

  @override
  void initState() {
    super.initState();
    _apiService = Get.find<ApiService>();
    _fetchBranchCompanies();
  }

  Future<void> _fetchBranchCompanies() async {
    try {
      final branchCompanies = await _apiService.fetchBranchCompanies();
      setState(() {
        _branchCompanies = branchCompanies;
        _isBranchLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBranchLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load branch companies: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createClient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchCompanyId == null) {
      Get.snackbar(
        'Error',
        'Please select a branch company',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.createClient(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        branchCompanyId: _selectedBranchCompanyId,
      );
      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        'Success',
        'Client created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Client', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isBranchLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      decoration:
                          const InputDecoration(labelText: 'Branch Company'),
                      value: _selectedBranchCompanyId,
                      items: _branchCompanies
                          .map(
                            (branch) => DropdownMenuItem<int>(
                              value: branch['id'],
                              child: Text(branch['name'] ?? 'Unknown'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranchCompanyId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a branch company';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createClient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create Client',
                          style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
