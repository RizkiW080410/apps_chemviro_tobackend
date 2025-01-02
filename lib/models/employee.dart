class Employee {
  final String? userName;
  final String? userEmail;
  final String? phone;
  final String? department;
  final String? branchCompany;
  final String? branchCompanyAddress;
  final int? soCount;
  final int? poCount;
  final int? coCount;
  final int? clientCount;

  Employee({
    this.userName,
    this.userEmail,
    this.phone,
    this.department,
    this.branchCompany,
    this.branchCompanyAddress,
    this.soCount,
    this.poCount,
    this.coCount,
    this.clientCount,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? orders = json['orders'] as List<dynamic>?;
    return Employee(
      userName: json['user']?['name'] as String?,
      userEmail: json['user']?['email'] as String?,
      phone: json['phone'] as String?,
      department: json['department']?['name'] as String?,
      branchCompany: json['branch_company']?['name'] as String?,
      branchCompanyAddress: json['branch_company']?['address'] as String?,
      soCount:
          orders?.where((order) => order['status'] == 'Sales Order').length ??
              0,
      poCount: orders
              ?.where((order) => order['status'] == 'Purchase Order')
              .length ??
          0,
      coCount:
          orders?.where((order) => order['status'] == 'Cancel Order').length ??
              0,
      clientCount: (json['client'] as List<dynamic>?)?.length ?? 0,
    );
  }
}
