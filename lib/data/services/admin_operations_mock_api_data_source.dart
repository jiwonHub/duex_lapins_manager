import 'dart:convert';

import 'package:deux_lapins_manager/domain/models/admin_claim.dart';
import 'package:deux_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';

class AdminOperationsApiException implements Exception {
  const AdminOperationsApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// 관리자 앱의 단일 메모리 원본에 요청/응답(JSON)으로 접근한다.
/// 쇼핑몰 앱 메모리와는 공유되지 않는다.
class AdminOperationsMockApiDataSource {
  AdminOperationsMockApiDataSource(this._orders, this._claims, this._inquiries);

  final List<AdminOrder> _orders;
  final List<AdminClaim> _claims;
  final List<AdminInquiry> _inquiries;

  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final input = body == null
        ? null
        : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    try {
      final data = _dispatch(method.toUpperCase(), Uri.parse(path), input);
      return jsonDecode(jsonEncode({'success': true, 'data': data}))
      as Map<String, dynamic>;
    } on AdminOperationsApiException catch (error) {
      return {
        'success': false,
        'error': {'code': error.code, 'message': error.message},
      };
    }
  }

  Object _dispatch(String method, Uri uri, Map<String, dynamic>? body) {
    final parts = uri.pathSegments;
    if (parts.length < 2 || parts.first != 'admin') {
      throw const AdminOperationsApiException('NOT_FOUND', 'API 경로가 없습니다.');
    }
    if (parts[1] == 'orders') {
      if (method == 'GET' && parts.length == 2) {
        return _orders.map(AdminOperationsApiCodec.orderToJson).toList();
      }
      if (method == 'POST' && parts.length == 3 && parts[2] == 'bulk-shipping') {
        final ids = (body?['order_ids'] as List<dynamic>?)?.cast<String>();
        final carrier = (body?['carrier'] as String?)?.trim() ?? '';
        final numbers = body?['tracking_numbers'] as Map<String, dynamic>?;
        if (ids == null || ids.isEmpty || ids.toSet().length != ids.length ||
            carrier.isEmpty || numbers == null) {
          throw const AdminOperationsApiException('VALIDATION_ERROR', '주문과 택배사를 확인해주세요.');
        }
        // 전부 검증한 후에 수정한다. 부분 배송 처리 금지.
        final updates = <int, AdminOrder>{};
        for (final id in ids) {
          final index = _orders.indexWhere((order) => order.id == id);
          final tracking = (numbers[id] as String?)?.trim() ?? '';
          if (index == -1) {
            throw AdminOperationsApiException('NOT_FOUND', '존재하지 않는 주문: $id');
          }
          final original = _orders[index];
          final updated = original.copyWith(
            status: AdminOrderStatus.shipped,
            carrier: carrier,
            trackingNumber: tracking,
          );
          _validateOrder(original, updated);
          updates[index] = updated;
        }
        for (final entry in updates.entries) {
          _orders[entry.key] = entry.value;
        }
        return updates.values.map(AdminOperationsApiCodec.orderToJson).toList();
      }
      if (parts.length == 3) {
        final index = _orders.indexWhere((order) => order.id == parts[2]);
        if (index == -1) {
          throw const AdminOperationsApiException('NOT_FOUND', '주문을 찾을 수 없습니다.');
        }
        if (method == 'GET') return AdminOperationsApiCodec.orderToJson(_orders[index]);
        if (method == 'PATCH') {
          final old = _orders[index];
          final updated = old.copyWith(
            status: _parseStatus(body?['order_status'], AdminOrderStatus.values),
            carrier: body?['carrier'] as String? ?? old.carrier,
            trackingNumber: body?['tracking_number'] as String? ?? old.trackingNumber,
            adminMemo: body?['admin_memo'] as String? ?? old.adminMemo,
            items: body?['items'] == null
                ? old.items
                : old.items.map((item) {
              final updates = body!['items'] as List<dynamic>;
              final match = updates.where(
                    (row) =>
                (row as Map<String, dynamic>)['product_variant_id'] ==
                    (item.variantId.isEmpty
                        ? item.productId
                        : item.variantId),
              );

              if (match.isEmpty) return item;

              final data = match.first as Map<String, dynamic>;

              return item.copyWith(
                carrier: data['carrier'] as String?,
                trackingNumber: data['tracking_number'] as String?,
              );
            }).toList(growable: false),
          );
          _validateOrder(old, updated);
          _orders[index] = updated;
          return AdminOperationsApiCodec.orderToJson(updated);
        }
      }
    }
    if (parts[1] == 'claims') {
      if (method == 'GET' && parts.length == 2) {
        return _claims.map(AdminOperationsApiCodec.claimToJson).toList();
      }
      if (method == 'PATCH' && parts.length == 3) {
        final index = _claims.indexWhere((claim) => claim.id == parts[2]);
        if (index == -1) {
          throw const AdminOperationsApiException('NOT_FOUND', '클레임을 찾을 수 없습니다.');
        }
        final old = _claims[index];
        final updated = old.copyWith(
          pickupStatus: _parseStatus(body?['pickup_status'], AdminPickupStatus.values),
          processStatus: _parseStatus(body?['process_status'], AdminClaimProcessStatus.values),
          refundStatus: _parseStatus(body?['refund_status'], AdminRefundStatus.values),
          adminMemo: body?['admin_memo'] as String? ?? old.adminMemo,
        );
        if (!_orders.any((order) => order.id == updated.orderId)) {
          throw const AdminOperationsApiException('NOT_FOUND', '연결된 주문이 없습니다.');
        }
        if (updated.refundStatus == AdminRefundStatus.completed &&
            updated.processStatus != AdminClaimProcessStatus.approved &&
            updated.processStatus != AdminClaimProcessStatus.completed) {
          throw const AdminOperationsApiException(
              'INVALID_STATUS', '승인 또는 완료된 요청만 환불 완료로 처리할 수 있습니다.');
        }
        if (updated.processStatus == AdminClaimProcessStatus.rejected &&
            updated.refundStatus == AdminRefundStatus.completed) {
          throw const AdminOperationsApiException(
              'INVALID_STATUS', '거절된 요청을 환불 완료로 처리할 수 없습니다.');
        }
        _claims[index] = updated;
        return AdminOperationsApiCodec.claimToJson(updated);
      }
    }
    if (parts[1] == 'inquiries') {
      if (method == 'GET' && parts.length == 2) {
        return _inquiries.map(AdminOperationsApiCodec.inquiryToJson).toList();
      }
      if (method == 'PUT' && parts.length == 4 && parts[3] == 'answer') {
        final index = _inquiries.indexWhere((inquiry) => inquiry.id == parts[2]);
        if (index == -1) {
          throw const AdminOperationsApiException('NOT_FOUND', '문의를 찾을 수 없습니다.');
        }
        final answer = (body?['answer'] as String?)?.trim() ?? '';
        if (answer.isEmpty) {
          throw const AdminOperationsApiException('VALIDATION_ERROR', '답변을 입력해주세요.');
        }
        final current = _inquiries[index];
        if (current.answer == answer && current.status == AdminInquiryStatus.answered) {
          return AdminOperationsApiCodec.inquiryToJson(current);
        }
        final updated = current.copyWith(
          status: AdminInquiryStatus.answered,
          answer: answer,
          answeredAt: DateTime.now(),
        );
        _inquiries[index] = updated;
        return AdminOperationsApiCodec.inquiryToJson(updated);
      }
    }
    throw const AdminOperationsApiException('NOT_FOUND', '지원하지 않는 요청입니다.');
  }

  T _parseStatus<T extends Enum>(Object? value, List<T> values) {
    for (final status in values) {
      if (status.name == value) return status;
    }
    throw const AdminOperationsApiException('VALIDATION_ERROR', '상태 코드가 올바르지 않습니다.');
  }

  void _validateOrder(AdminOrder old, AdminOrder updated) {
    if (old.paymentStatus != AdminPaymentStatus.paid &&
        (updated.status == AdminOrderStatus.shipped ||
            updated.status == AdminOrderStatus.delivered)) {
      throw const AdminOperationsApiException('INVALID_STATUS', '결제 완료 주문만 배송할 수 있습니다.');
    }
    if ((old.status == AdminOrderStatus.cancelled ||
        old.status == AdminOrderStatus.exchangeReturn) &&
        old.status != updated.status) {
      throw const AdminOperationsApiException('INVALID_STATUS', '취소·교환/반품 주문 상태는 직접 변경할 수 없습니다.');
    }
    if (updated.status == AdminOrderStatus.shipped ||
        updated.status == AdminOrderStatus.delivered) {
      if (!updated.items.every(
            (item) =>
        (item.carrier.trim().isNotEmpty &&
            item.trackingNumber.trim().isNotEmpty) ||
            (updated.carrier.trim().isNotEmpty &&
                updated.trackingNumber.trim().isNotEmpty),
      )) {
        throw const AdminOperationsApiException(
          'VALIDATION_ERROR',
          '상품별 택배사와 송장번호를 입력해주세요.',
        );
      }
    }
  }
}

class AdminOperationsApiCodec {
  static Map<String, dynamic> orderToJson(AdminOrder order) => {
    'id': order.id,
    'customer_id': order.customerId,
    'customer_name': order.customerName,
    'phone': order.phone,
    'address': order.address,
    'shipping_fee': order.shippingFee,
    'payment_status': order.paymentStatus.name,
    'order_status': order.status.name,
    'ordered_at': order.orderedAt.toIso8601String(),
    'carrier': order.carrier,
    'tracking_number': order.trackingNumber,
    'admin_memo': order.adminMemo,
    'items': order.items.map((item) => {
      'product_id': item.productId,
      'product_name': item.productName,
      'product_variant_id':
      item.variantId.isEmpty ? item.productId : item.variantId,
      'carrier': item.carrier,
      'tracking_number': item.trackingNumber,
      'delivery_status': item.deliveryStatus,
      'color_name': item.color,
      'size_name': item.size,
      'quantity': item.quantity,
      'unit_price': item.unitPrice,
    }).toList(),
  };

  static AdminOrder orderFromJson(Map<String, dynamic> json) => AdminOrder(
    id: json['id'] as String,
    customerId: json['customer_id'] as String,
    customerName: json['customer_name'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    items: (json['items'] as List<dynamic>).map((raw) {
      final item = raw as Map<String, dynamic>;
      return AdminOrderItem(
        productId: item['product_id'] as String,
        productName: item['product_name'] as String,
        variantId: item['product_variant_id'] as String? ?? '',
        carrier: item['carrier'] as String? ?? '',
        trackingNumber: item['tracking_number'] as String? ?? '',
        deliveryStatus:
        item['delivery_status'] as String? ?? 'preparing',
        color: item['color_name'] as String,
        size: item['size_name'] as String,
        quantity: item['quantity'] as int,
        unitPrice: item['unit_price'] as int,
      );
    }).toList(growable: false),
    shippingFee: json['shipping_fee'] as int,
    paymentStatus: AdminPaymentStatus.values.byName(json['payment_status'] as String),
    status: AdminOrderStatus.values.byName(json['order_status'] as String),
    orderedAt: DateTime.parse(json['ordered_at'] as String),
    carrier: json['carrier'] as String,
    trackingNumber: json['tracking_number'] as String,
    adminMemo: json['admin_memo'] as String,
  );

  static Map<String, dynamic> claimToJson(AdminClaim claim) => {
    'id': claim.id,
    'order_id': claim.orderId,
    'customer_name': claim.customerName,
    'claim_type': claim.type.name,
    'reason': claim.reason,
    'requested_at': claim.requestedAt.toIso8601String(),
    'pickup_status': claim.pickupStatus.name,
    'process_status': claim.processStatus.name,
    'refund_status': claim.refundStatus.name,
    'admin_memo': claim.adminMemo,
  };

  static AdminClaim claimFromJson(Map<String, dynamic> json) => AdminClaim(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    customerName: json['customer_name'] as String,
    type: AdminClaimType.values.byName(json['claim_type'] as String),
    reason: json['reason'] as String,
    requestedAt: DateTime.parse(json['requested_at'] as String),
    pickupStatus: AdminPickupStatus.values.byName(json['pickup_status'] as String),
    processStatus: AdminClaimProcessStatus.values.byName(json['process_status'] as String),
    refundStatus: AdminRefundStatus.values.byName(json['refund_status'] as String),
    adminMemo: json['admin_memo'] as String,
  );

  static Map<String, dynamic> inquiryToJson(AdminInquiry inquiry) => {
    'id': inquiry.id,
    'customer_id': inquiry.customerId,
    'customer_name': inquiry.customerName,
    'inquiry_type': inquiry.type.name,
    'title': inquiry.title,
    'question': inquiry.question,
    'status': inquiry.status.name,
    'created_at': inquiry.createdAt.toIso8601String(),
    'product_id': inquiry.productId,
    'product_name': inquiry.productName,
    'answer': inquiry.answer,
    'answered_at': inquiry.answeredAt?.toIso8601String(),
  };

  static AdminInquiry inquiryFromJson(Map<String, dynamic> json) => AdminInquiry(
    id: json['id'] as String,
    customerId: json['customer_id'] as String,
    customerName: json['customer_name'] as String,
    type: AdminInquiryType.values.byName(json['inquiry_type'] as String),
    title: json['title'] as String,
    question: json['question'] as String,
    status: AdminInquiryStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    productId: json['product_id'] as String?,
    productName: json['product_name'] as String?,
    answer: json['answer'] as String,
    answeredAt: json['answered_at'] == null
        ? null : DateTime.parse(json['answered_at'] as String),
  );
}