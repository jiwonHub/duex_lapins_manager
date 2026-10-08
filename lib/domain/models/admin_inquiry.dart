enum AdminInquiryType {
  product,
  oneToOne,
}

extension AdminInquiryTypeLabel on AdminInquiryType {
  String get label => switch (this) {
        AdminInquiryType.product => '상품 문의',
        AdminInquiryType.oneToOne => '1:1 문의',
      };
}

enum AdminInquiryStatus {
  unanswered,
  answered,
}

extension AdminInquiryStatusLabel on AdminInquiryStatus {
  String get label => switch (this) {
        AdminInquiryStatus.unanswered => '미답변',
        AdminInquiryStatus.answered => '답변완료',
      };
}

class AdminInquiry {
  const AdminInquiry({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.title,
    required this.question,
    required this.status,
    required this.createdAt,
    this.productId,
    this.productName,
    this.answer = '',
    this.answeredAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final AdminInquiryType type;
  final String title;
  final String question;
  final AdminInquiryStatus status;
  final DateTime createdAt;
  final String? productId;
  final String? productName;
  final String answer;
  final DateTime? answeredAt;

  AdminInquiry copyWith({
    AdminInquiryStatus? status,
    String? answer,
    DateTime? answeredAt,
  }) {
    return AdminInquiry(
      id: id,
      customerId: customerId,
      customerName: customerName,
      type: type,
      title: title,
      question: question,
      status: status ?? this.status,
      createdAt: createdAt,
      productId: productId,
      productName: productName,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
