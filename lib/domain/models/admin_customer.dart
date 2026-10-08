class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.orderCount,
    required this.totalSpent,
    required this.joinedAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int orderCount;
  final int totalSpent;
  final DateTime joinedAt;
}
