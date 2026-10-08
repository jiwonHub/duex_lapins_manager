enum AdminOrderStatus {
  newOrder,
  paid,
  preparing,
  shipped,
  delivered,
  cancelled,
  exchangeReturn,
}

extension AdminOrderStatusLabel on AdminOrderStatus {
  String get label => switch (this) {
        AdminOrderStatus.newOrder => '신규주문',
        AdminOrderStatus.paid => '결제완료',
        AdminOrderStatus.preparing => '상품준비중',
        AdminOrderStatus.shipped => '배송중',
        AdminOrderStatus.delivered => '배송완료',
        AdminOrderStatus.cancelled => '취소',
        AdminOrderStatus.exchangeReturn => '교환/반품',
      };
}

enum AdminPaymentStatus {
  pending,
  paid,
  refunded,
  partialRefunded,
}

extension AdminPaymentStatusLabel on AdminPaymentStatus {
  String get label => switch (this) {
        AdminPaymentStatus.pending => '결제대기',
        AdminPaymentStatus.paid => '결제완료',
        AdminPaymentStatus.refunded => '환불완료',
        AdminPaymentStatus.partialRefunded => '부분환불',
      };
}

class AdminOrderItem {
  const AdminOrderItem({
    required this.productId,
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final String color;
  final String size;
  final int quantity;
  final int unitPrice;

  int get amount => unitPrice * quantity;
}

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.shippingFee,
    required this.paymentStatus,
    required this.status,
    required this.orderedAt,
    this.carrier = '',
    this.trackingNumber = '',
    this.adminMemo = '',
  });

  final String id;
  final String customerId;
  final String customerName;
  final String phone;
  final String address;
  final List<AdminOrderItem> items;
  final int shippingFee;
  final AdminPaymentStatus paymentStatus;
  final AdminOrderStatus status;
  final DateTime orderedAt;
  final String carrier;
  final String trackingNumber;
  final String adminMemo;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
  int get productAmount =>
      items.fold<int>(0, (sum, item) => sum + item.amount);
  int get amount => productAmount + shippingFee;

  AdminOrder copyWith({
    AdminPaymentStatus? paymentStatus,
    AdminOrderStatus? status,
    String? carrier,
    String? trackingNumber,
    String? adminMemo,
  }) {
    return AdminOrder(
      id: id,
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      address: address,
      items: items,
      shippingFee: shippingFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      orderedAt: orderedAt,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      adminMemo: adminMemo ?? this.adminMemo,
    );
  }
}
