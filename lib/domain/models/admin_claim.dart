enum AdminClaimType {
  cancel,
  exchange,
  returnItem,
}

extension AdminClaimTypeLabel on AdminClaimType {
  String get label => switch (this) {
        AdminClaimType.cancel => '취소',
        AdminClaimType.exchange => '교환',
        AdminClaimType.returnItem => '반품',
      };
}

enum AdminPickupStatus {
  notRequired,
  waiting,
  requested,
  collected,
}

extension AdminPickupStatusLabel on AdminPickupStatus {
  String get label => switch (this) {
        AdminPickupStatus.notRequired => '회수 없음',
        AdminPickupStatus.waiting => '회수 대기',
        AdminPickupStatus.requested => '회수 접수',
        AdminPickupStatus.collected => '회수 완료',
      };
}

enum AdminClaimProcessStatus {
  requested,
  processing,
  approved,
  rejected,
  completed,
}

extension AdminClaimProcessStatusLabel on AdminClaimProcessStatus {
  String get label => switch (this) {
        AdminClaimProcessStatus.requested => '신청',
        AdminClaimProcessStatus.processing => '처리중',
        AdminClaimProcessStatus.approved => '승인',
        AdminClaimProcessStatus.rejected => '거절',
        AdminClaimProcessStatus.completed => '완료',
      };
}

enum AdminRefundStatus {
  none,
  waiting,
  completed,
}

extension AdminRefundStatusLabel on AdminRefundStatus {
  String get label => switch (this) {
        AdminRefundStatus.none => '환불 없음',
        AdminRefundStatus.waiting => '환불 대기',
        AdminRefundStatus.completed => '환불 완료',
      };
}

class AdminClaim {
  const AdminClaim({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.type,
    required this.reason,
    required this.requestedAt,
    required this.pickupStatus,
    required this.processStatus,
    required this.refundStatus,
    this.adminMemo = '',
  });

  final String id;
  final String orderId;
  final String customerName;
  final AdminClaimType type;
  final String reason;
  final DateTime requestedAt;
  final AdminPickupStatus pickupStatus;
  final AdminClaimProcessStatus processStatus;
  final AdminRefundStatus refundStatus;
  final String adminMemo;

  AdminClaim copyWith({
    AdminPickupStatus? pickupStatus,
    AdminClaimProcessStatus? processStatus,
    AdminRefundStatus? refundStatus,
    String? adminMemo,
  }) {
    return AdminClaim(
      id: id,
      orderId: orderId,
      customerName: customerName,
      type: type,
      reason: reason,
      requestedAt: requestedAt,
      pickupStatus: pickupStatus ?? this.pickupStatus,
      processStatus: processStatus ?? this.processStatus,
      refundStatus: refundStatus ?? this.refundStatus,
      adminMemo: adminMemo ?? this.adminMemo,
    );
  }
}
