import 'package:deux_lapins_manager/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins_manager/data/services/admin_product_mock_api_data_source.dart';
import 'package:deux_lapins_manager/data/services/admin_editorial_mock_api_data_source.dart';
import 'package:deux_lapins_manager/data/services/admin_operations_mock_api_data_source.dart';
import 'package:deux_lapins_manager/domain/models/admin_claim.dart';
import 'package:deux_lapins_manager/domain/models/admin_customer.dart';
import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:deux_lapins_manager/domain/models/admin_journal.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/domain/models/admin_store_settings.dart';
import 'package:deux_lapins_manager/domain/repositories/admin_repository.dart';

class AdminMockRepository implements AdminRepository {
  final List<AdminProduct> _products = [
    AdminProduct(
      id: 'P001',
      name: 'Heritage Wool Blouson',
      sku: 'DL-AW26-001',
      line: AdminProductLine.classic,
      season: 'AW26',
      price: 489000,
      description: '절제된 볼륨과 부드러운 구조가 특징인 울 블루종입니다.',
      material: 'Wool 90%, Nylon 10%',
      colors: const ['BLACK', 'CHARCOAL'],
      sizes: const ['M', 'L'],
      fit: 'RELAXED FIT',
      detail: 'Two-way zipper / Hidden pocket / Cupra lining',
      care: 'Dry clean only',
      status: AdminProductStatus.selling,
      publishStatus: AdminPublishStatus.published,
      updatedAt: DateTime(2026, 10, 8, 8, 10),
      inventory: const [
        AdminInventoryItem(color: 'BLACK', size: 'M', quantity: 6),
        AdminInventoryItem(color: 'BLACK', size: 'L', quantity: 4),
        AdminInventoryItem(color: 'CHARCOAL', size: 'M', quantity: 2),
        AdminInventoryItem(color: 'CHARCOAL', size: 'L', quantity: 1),
      ],
    ),
    AdminProduct(
      id: 'P002',
      name: 'Utility Cotton Shirt',
      sku: 'DL-AW26-002',
      line: AdminProductLine.work,
      season: 'AW26',
      price: 159000,
      description: '워크 셔츠 구조를 정돈된 비율로 재해석한 코튼 셔츠입니다.',
      material: 'Cotton 100%',
      colors: const ['IVORY', 'NAVY'],
      sizes: const ['M', 'L', 'XL'],
      fit: 'REGULAR FIT',
      detail: 'Chest pocket / Garment washed',
      care: 'Cold wash separately',
      status: AdminProductStatus.selling,
      publishStatus: AdminPublishStatus.published,
      updatedAt: DateTime(2026, 10, 8, 8, 0),
      inventory: const [
        AdminInventoryItem(color: 'IVORY', size: 'M', quantity: 5),
        AdminInventoryItem(color: 'IVORY', size: 'L', quantity: 2),
        AdminInventoryItem(color: 'IVORY', size: 'XL', quantity: 0),
        AdminInventoryItem(color: 'NAVY', size: 'M', quantity: 4),
        AdminInventoryItem(color: 'NAVY', size: 'L', quantity: 3),
        AdminInventoryItem(color: 'NAVY', size: 'XL', quantity: 1),
      ],
    ),
    AdminProduct(
      id: 'P003',
      name: 'Classic Pleated Trousers',
      sku: 'DL-AW26-003',
      line: AdminProductLine.classic,
      season: 'AW26',
      price: 219000,
      description: '깊은 원턱과 길게 떨어지는 실루엣의 트라우저입니다.',
      material: 'Wool 52%, Polyester 48%',
      colors: const ['BLACK'],
      sizes: const ['S', 'M', 'L'],
      fit: 'WIDE FIT',
      detail: 'Single pleat / Half lining',
      care: 'Dry clean only',
      status: AdminProductStatus.selling,
      publishStatus: AdminPublishStatus.published,
      updatedAt: DateTime(2026, 10, 7, 16, 30),
      inventory: const [
        AdminInventoryItem(color: 'BLACK', size: 'S', quantity: 1),
        AdminInventoryItem(color: 'BLACK', size: 'M', quantity: 2),
        AdminInventoryItem(color: 'BLACK', size: 'L', quantity: 0),
      ],
    ),
    AdminProduct(
      id: 'P004',
      name: 'Work Leather Bag',
      sku: 'DL-AW26-004',
      line: AdminProductLine.work,
      season: 'ESSENTIAL',
      price: 379000,
      description: '도구 가방의 실용적인 구조를 미니멀하게 정돈한 레더 백입니다.',
      material: 'Cow Leather 100%',
      colors: const ['BLACK'],
      sizes: const ['FREE'],
      fit: 'ONE SIZE',
      detail: 'Adjustable strap / Inner pocket',
      care: 'Professional leather clean',
      status: AdminProductStatus.hidden,
      publishStatus: AdminPublishStatus.draft,
      updatedAt: DateTime(2026, 10, 6, 11, 20),
      inventory: const [
        AdminInventoryItem(color: 'BLACK', size: 'FREE', quantity: 8),
      ],
    ),
  ];

  final List<AdminOrder> _orders = [
    AdminOrder(
      id: 'DL261008-0017',
      customerId: 'M001',
      customerName: '김민준',
      phone: '010-1234-5678',
      address: '서울특별시 성동구 성수이로 00, 101호',
      items: const [
        AdminOrderItem(
          productId: 'P001',
          productName: 'Heritage Wool Blouson',
          color: 'BLACK',
          size: 'M',
          quantity: 1,
          unitPrice: 489000,
        ),
        AdminOrderItem(
          productId: 'P003',
          productName: 'Classic Pleated Trousers',
          color: 'BLACK',
          size: 'M',
          quantity: 1,
          unitPrice: 219000,
        ),
      ],
      shippingFee: 0,
      paymentStatus: AdminPaymentStatus.paid,
      status: AdminOrderStatus.preparing,
      orderedAt: DateTime(2026, 10, 8, 9, 12),
      adminMemo: '오후 출고 요청',
    ),
    AdminOrder(
      id: 'DL261008-0016',
      customerId: 'M002',
      customerName: '박서준',
      phone: '010-2345-6789',
      address: '경기도 성남시 분당구 판교로 00',
      items: const [
        AdminOrderItem(
          productId: 'P002',
          productName: 'Utility Cotton Shirt',
          color: 'NAVY',
          size: 'L',
          quantity: 1,
          unitPrice: 159000,
        ),
      ],
      shippingFee: 3000,
      paymentStatus: AdminPaymentStatus.paid,
      status: AdminOrderStatus.delivered,
      orderedAt: DateTime(2026, 10, 8, 8, 44),
    ),
    AdminOrder(
      id: 'DL261007-0015',
      customerId: 'M003',
      customerName: '이도윤',
      phone: '010-3456-7890',
      address: '서울특별시 마포구 연남로 00',
      items: const [
        AdminOrderItem(
          productId: 'P001',
          productName: 'Heritage Wool Blouson',
          color: 'CHARCOAL',
          size: 'L',
          quantity: 1,
          unitPrice: 489000,
        ),
      ],
      shippingFee: 0,
      paymentStatus: AdminPaymentStatus.paid,
      status: AdminOrderStatus.shipped,
      orderedAt: DateTime(2026, 10, 7, 17, 30),
      carrier: 'CJ대한통운',
      trackingNumber: '123456789012',
    ),
    AdminOrder(
      id: 'DL261007-0014',
      customerId: 'M004',
      customerName: '최현우',
      phone: '010-4567-8901',
      address: '서울특별시 용산구 한남대로 00',
      items: const [
        AdminOrderItem(
          productId: 'P003',
          productName: 'Classic Pleated Trousers',
          color: 'BLACK',
          size: 'L',
          quantity: 1,
          unitPrice: 219000,
        ),
      ],
      shippingFee: 3000,
      paymentStatus: AdminPaymentStatus.refunded,
      status: AdminOrderStatus.exchangeReturn,
      orderedAt: DateTime(2026, 10, 7, 14, 12),
    ),
  ];

  final List<AdminCustomer> _customers = [
    AdminCustomer(
      id: 'M001',
      name: '김민준',
      email: 'minjun@example.com',
      phone: '010-1234-5678',
      address: '서울특별시 성동구 성수이로 00',
      orderCount: 8,
      totalSpent: 3184000,
      joinedAt: DateTime(2026, 8, 12),
    ),
    AdminCustomer(
      id: 'M002',
      name: '박서준',
      email: 'seojun@example.com',
      phone: '010-2345-6789',
      address: '경기도 성남시 분당구 판교로 00',
      orderCount: 5,
      totalSpent: 1872000,
      joinedAt: DateTime(2026, 8, 24),
    ),
    AdminCustomer(
      id: 'M003',
      name: '이도윤',
      email: 'doyoon@example.com',
      phone: '010-3456-7890',
      address: '서울특별시 마포구 연남로 00',
      orderCount: 11,
      totalSpent: 4421000,
      joinedAt: DateTime(2026, 7, 3),
    ),
    AdminCustomer(
      id: 'M004',
      name: '최현우',
      email: 'hyunwoo@example.com',
      phone: '010-4567-8901',
      address: '서울특별시 용산구 한남대로 00',
      orderCount: 3,
      totalSpent: 917000,
      joinedAt: DateTime(2026, 9, 7),
    ),
  ];

  final List<AdminInquiry> _inquiries = [
    AdminInquiry(
      id: 'Q001',
      customerId: 'M001',
      customerName: '김민준',
      type: AdminInquiryType.product,
      title: '블루종 사이즈 문의',
      question: '평소 100 사이즈를 입는데 M과 L 중 어떤 사이즈가 좋을까요?',
      status: AdminInquiryStatus.unanswered,
      createdAt: DateTime(2026, 10, 8, 9, 30),
      productId: 'P001',
      productName: 'Heritage Wool Blouson',
    ),
    AdminInquiry(
      id: 'Q002',
      customerId: 'M002',
      customerName: '박서준',
      type: AdminInquiryType.oneToOne,
      title: '배송지 변경 문의',
      question: '아직 배송 전인데 배송지를 변경할 수 있을까요?',
      status: AdminInquiryStatus.unanswered,
      createdAt: DateTime(2026, 10, 8, 8, 55),
    ),
    AdminInquiry(
      id: 'Q003',
      customerId: 'M003',
      customerName: '이도윤',
      type: AdminInquiryType.product,
      title: '세탁 방법 문의',
      question: '드라이클리닝만 가능한 제품인가요?',
      status: AdminInquiryStatus.answered,
      createdAt: DateTime(2026, 10, 7, 15, 20),
      productId: 'P003',
      productName: 'Classic Pleated Trousers',
      answer: '제품의 형태 보존을 위해 드라이클리닝을 권장드립니다.',
      answeredAt: DateTime(2026, 10, 7, 16, 5),
    ),
  ];

  final List<AdminClaim> _claims = [
    AdminClaim(
      id: 'C001',
      orderId: 'DL261007-0014',
      customerName: '최현우',
      type: AdminClaimType.returnItem,
      reason: '사이즈가 예상보다 큽니다.',
      requestedAt: DateTime(2026, 10, 8, 8, 20),
      pickupStatus: AdminPickupStatus.requested,
      processStatus: AdminClaimProcessStatus.processing,
      refundStatus: AdminRefundStatus.waiting,
    ),
    AdminClaim(
      id: 'C002',
      orderId: 'DL261007-0015',
      customerName: '이도윤',
      type: AdminClaimType.exchange,
      reason: '컬러 교환 요청',
      requestedAt: DateTime(2026, 10, 8, 7, 40),
      pickupStatus: AdminPickupStatus.waiting,
      processStatus: AdminClaimProcessStatus.requested,
      refundStatus: AdminRefundStatus.none,
    ),
  ];

  AdminHomeContent _homeContent = AdminHomeContent(
    hero: const AdminHeroContent(
      mainText: 'A Quiet Form\nFor What Moves\nYou Forward.',
      subText: 'AUTUMN / WINTER 2026 · MODERN HERITAGE',
      buttonText: '컬렉션 보기',
      buttonRoute: '/new',
      visible: true,
      order: 1,
    ),
    classicVisible: true,
    workVisible: true,
    classicImageBase64: null,
    workImageBase64: null,
    newArrivalProductIds: const ['P001', 'P002', 'P003'],
    publishStatus: AdminContentPublishStatus.published,
    updatedAt: DateTime(2026, 10, 8, 8),
  );

  final List<AdminJournal> _journals = [
    AdminJournal(
      id: 'J001',
      title: 'A Quiet Heritage',
      category: 'JOURNAL',
      body: '전통적인 남성복의 구조를 오늘의 균형으로 다시 바라봅니다.',
      relatedProductIds: const ['P001', 'P003'],
      createdAt: DateTime(2026, 10, 1),
      publishAt: DateTime(2026, 10, 2),
      publishStatus: AdminContentPublishStatus.published,
    ),
    AdminJournal(
      id: 'J002',
      title: 'People / Studio Visit',
      category: 'PEOPLE',
      body: 'DUEX LAPINS가 만난 사람과 공간에 대한 기록입니다.',
      relatedProductIds: const ['P002'],
      createdAt: DateTime(2026, 10, 6),
      publishAt: DateTime(2026, 10, 12),
      publishStatus: AdminContentPublishStatus.draft,
    ),
  ];

  AdminStoreSettings _settings = const AdminStoreSettings(
    shippingFee: 3000,
    freeShippingThreshold: 100000,
    carrier: 'CJ대한통운',
    originAddress: '서울특별시 성동구 성수이로 00 DUEX LAPINS',
    returnAddress: '서울특별시 성동구 성수이로 00 DUEX LAPINS 반품센터',
    csPhone: '02-0000-0000',
    csEmail: 'cs@duexlapins.com',
    csHours: 'MON-FRI 10:00-17:00 / LUNCH 12:00-13:00',
    defaultGuide: '배송 및 교환/반품 관련 안내는 상품 상세와 고객센터에서 확인할 수 있습니다.',
  );

  late final AdminProductApiDataSource _productApi =
  AdminProductMockApiDataSource(_products);

  AdminProductMockApiDataSource get _mockProductApi =>
      _productApi as AdminProductMockApiDataSource;

  Future<dynamic> _productRequest(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    final response = SharedMockApiClient.enabled
        ? await SharedMockApiClient.instance.request(method, path, body)
        : await _productApi.request(method, path, body);

    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;

      throw AdminProductApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '상품 요청에 실패했습니다.',
      );
    }

    return response['data'];
  }

  @override
  Future<List<AdminProduct>> fetchProductsApi() async {
    final data =
    await _productRequest('GET', '/products') as List<dynamic>;

    final products = data.map((row) {
      return AdminProductApiCodec.fromJson(
        row as Map<String, dynamic>,
      );
    }).toList(growable: false);

    if (SharedMockApiClient.enabled) {
      _products
        ..clear()
        ..addAll(products);
    }

    return products;
  }

  @override
  Future<AdminProduct?> fetchProductApi(String productId) async {
    try {
      final data = await _productRequest(
        'GET',
        '/products/${Uri.encodeComponent(productId)}',
      );

      return AdminProductApiCodec.fromJson(
        data as Map<String, dynamic>,
      );
    } on AdminProductApiException catch (error) {
      if (error.code == 'NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<AdminProduct> saveProductApi(AdminProduct product) async {
    final isNew = getProduct(product.id) == null;

    final data = await _productRequest(
      isNew ? 'POST' : 'PUT',
      isNew
          ? '/products'
          : '/products/${Uri.encodeComponent(product.id)}',
      AdminProductApiCodec.toJson(product),
    );

    final saved = AdminProductApiCodec.fromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      _products.removeWhere((item) => item.id == saved.id);
      _products.insert(0, saved);
    }

    return saved;
  }

  @override
  Future<AdminProduct> updateInventoryApi({
    required String productId,
    required String color,
    required String size,
    required int quantity,
  }) async {
    final data = await _productRequest(
      'PATCH',
      '/products/${Uri.encodeComponent(productId)}/inventory',
      {
        'color': color,
        'size': size,
        'quantity': quantity,
      },
    );

    final updated = AdminProductApiCodec.fromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      final index = _products.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        _products[index] = updated;
      }
    }

    return updated;
  }

  @override
  Future<void> deleteProductApi(String productId) async {
    await _productRequest(
      'DELETE',
      '/products/${Uri.encodeComponent(productId)}',
    );

    if (SharedMockApiClient.enabled) {
      _products.removeWhere((item) => item.id == productId);
    }
  }

  @override
  List<AdminProduct> getProducts() => List.unmodifiable(
    _products.where(
          (product) => !_mockProductApi.isDeleted(product.id),
    ),
  );

  @override
  AdminProduct? getProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId &&
          !_mockProductApi.isDeleted(productId)) {
        return product;
      }
    }
    return null;
  }

  @override
  void addProduct(AdminProduct product) {
    _products.insert(0, product);
  }

  @override
  void updateProduct(AdminProduct product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index >= 0) _products[index] = product;
  }

  @override
  void updateInventory({
    required String productId,
    required String color,
    required String size,
    required int quantity,
  }) {
    final index = _products.indexWhere((item) => item.id == productId);
    if (index < 0) return;

    final product = _products[index];
    final inventory = product.inventory.map((item) {
      if (item.color == color && item.size == size) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    final total = inventory.fold<int>(0, (sum, item) => sum + item.quantity);
    var status = product.status;
    if (status != AdminProductStatus.hidden) {
      status = total <= 0
          ? AdminProductStatus.soldOut
          : AdminProductStatus.selling;
    }

    _products[index] = product.copyWith(
      inventory: inventory,
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  late final AdminOperationsMockApiDataSource _operationsApi =
  AdminOperationsMockApiDataSource(_orders, _claims, _inquiries);

  Future<dynamic> _operationsRequest(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    final response = SharedMockApiClient.enabled
        ? await SharedMockApiClient.instance.request(method, path, body)
        : await _operationsApi.request(method, path, body);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw AdminOperationsApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '운영 API 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<List<AdminOrder>> fetchOrdersApi() async {
    final data = await _operationsRequest('GET', '/admin/orders') as List<dynamic>;
    final orders = data.map((row) => AdminOperationsApiCodec.orderFromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);

    if (SharedMockApiClient.enabled) {
      _orders
        ..clear()
        ..addAll(orders);
    }

    return orders;
  }

  @override
  Future<AdminOrder?> fetchOrderApi(String orderId) async {
    try {
      final data = await _operationsRequest(
        'GET', '/admin/orders/${Uri.encodeComponent(orderId)}',
      );
      return AdminOperationsApiCodec.orderFromJson(data as Map<String, dynamic>);
    } on AdminOperationsApiException catch (error) {
      if (error.code == 'NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<AdminOrder> saveOrderApi(AdminOrder order) async {
    final data = await _operationsRequest(
      'PATCH', '/admin/orders/${Uri.encodeComponent(order.id)}',
      {
        'order_status': order.status.name,
        'carrier': order.carrier,
        'tracking_number': order.trackingNumber,
        'items': order.items.map((item) => {
          'product_variant_id':
          item.variantId.isEmpty ? item.productId : item.variantId,
          'carrier': item.carrier.trim().isEmpty ? null : item.carrier.trim(),
          'tracking_number': item.trackingNumber.trim().isEmpty
              ? null : item.trackingNumber.trim(),
        }).toList(),
        'admin_memo': order.adminMemo,
      },
    );
    return AdminOperationsApiCodec.orderFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> bulkShipOrdersApi({
    required List<String> orderIds,
    required String carrier,
    required Map<String, String> trackingNumbers,
  }) async {
    await _operationsRequest('POST', '/admin/orders/bulk-shipping', {
      'order_ids': orderIds,
      'carrier': carrier,
      'tracking_numbers': trackingNumbers,
    });
  }

  @override
  Future<List<AdminClaim>> fetchClaimsApi() async {
    final data = await _operationsRequest('GET', '/admin/claims') as List<dynamic>;
    final claims = data.map((row) => AdminOperationsApiCodec.claimFromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);

    if (SharedMockApiClient.enabled) {
      _claims
        ..clear()
        ..addAll(claims);
    }

    return claims;
  }

  @override
  Future<AdminClaim> saveClaimApi(AdminClaim claim) async {
    final data = await _operationsRequest(
      'PATCH', '/admin/claims/${Uri.encodeComponent(claim.id)}',
      {
        'pickup_status': claim.pickupStatus.name,
        'process_status': claim.processStatus.name,
        'refund_status': claim.refundStatus.name,
        'admin_memo': claim.adminMemo,
      },
    );
    return AdminOperationsApiCodec.claimFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<AdminInquiry>> fetchInquiriesApi() async {
    final data = await _operationsRequest('GET', '/admin/inquiries') as List<dynamic>;
    final inquiries = data.map((row) => AdminOperationsApiCodec.inquiryFromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);

    if (SharedMockApiClient.enabled) {
      _inquiries
        ..clear()
        ..addAll(inquiries);
    }

    return inquiries;
  }

  @override
  Future<AdminInquiry> answerInquiryApi(String inquiryId, String answer) async {
    final data = await _operationsRequest(
      'PUT', '/admin/inquiries/${Uri.encodeComponent(inquiryId)}/answer',
      {'answer': answer},
    );
    return AdminOperationsApiCodec.inquiryFromJson(data as Map<String, dynamic>);
  }

  @override
  List<AdminOrder> getOrders() => List.unmodifiable(_orders);

  @override
  AdminOrder? getOrder(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  void addOrder(AdminOrder order) {
    _orders.insert(0, order);
    _deductInventory(order);
  }

  void _deductInventory(AdminOrder order) {
    for (final orderItem in order.items) {
      final product = getProduct(orderItem.productId);
      if (product == null) continue;
      for (final inventory in product.inventory) {
        if (inventory.color == orderItem.color &&
            inventory.size == orderItem.size) {
          updateInventory(
            productId: product.id,
            color: inventory.color,
            size: inventory.size,
            quantity: (inventory.quantity - orderItem.quantity).clamp(0, 999999).toInt(),
          );
        }
      }
    }
  }

  @override
  void updateOrder(AdminOrder order) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index >= 0) _orders[index] = order;
  }

  @override
  void updateOrderStatus(String orderId, AdminOrderStatus status) {
    final order = getOrder(orderId);
    if (order != null) updateOrder(order.copyWith(status: status));
  }

  @override
  void bulkShipOrders({
    required List<String> orderIds,
    required String carrier,
    required Map<String, String> trackingNumbers,
  }) {
    for (final id in orderIds) {
      final order = getOrder(id);
      if (order == null) continue;
      updateOrder(
        order.copyWith(
          status: AdminOrderStatus.shipped,
          carrier: carrier,
          trackingNumber: trackingNumbers[id] ?? order.trackingNumber,
        ),
      );
    }
  }

  @override
  List<AdminClaim> getClaims() => List.unmodifiable(_claims);

  @override
  void updateClaim(AdminClaim claim) {
    final index = _claims.indexWhere((item) => item.id == claim.id);
    if (index >= 0) _claims[index] = claim;
  }

  @override
  List<AdminCustomer> getCustomers() => List.unmodifiable(_customers);

  @override
  AdminCustomer? getCustomer(String customerId) {
    for (final customer in _customers) {
      if (customer.id == customerId) return customer;
    }
    return null;
  }

  @override
  List<AdminOrder> getOrdersForCustomer(String customerId) {
    return _orders.where((order) => order.customerId == customerId).toList();
  }

  @override
  List<AdminInquiry> getInquiries() => List.unmodifiable(_inquiries);

  @override
  void answerInquiry(String inquiryId, String answer) {
    final index = _inquiries.indexWhere((item) => item.id == inquiryId);
    if (index < 0) return;
    _inquiries[index] = _inquiries[index].copyWith(
      status: AdminInquiryStatus.answered,
      answer: answer,
      answeredAt: DateTime.now(),
    );
  }

  late final AdminEditorialMockApiDataSource _editorialApi =
  AdminEditorialMockApiDataSource(
    getHome: () => _homeContent,
    setHome: (value) => _homeContent = value,
    journals: _journals,
    getSettings: () => _settings,
    setSettings: (value) => _settings = value,
    getProducts: getProducts,
  );

  Future<dynamic> _editorialRequest(String method, String path,
      [Map<String, dynamic>? body]) async {
    final response = SharedMockApiClient.enabled
        ? await SharedMockApiClient.instance.request(method, path, body)
        : await _editorialApi.request(method, path, body);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      throw AdminEditorialApiException(
        error?['code']?.toString() ?? 'UNKNOWN',
        error?['message']?.toString() ?? '콘텐츠 요청에 실패했습니다.',
      );
    }
    return response['data'];
  }

  @override
  Future<AdminHomeContent> fetchHomeContentApi() async {
    final data = await _editorialRequest('GET', '/admin/home-content');
    final content = AdminEditorialCodec.homeFromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      _homeContent = content;
    }

    return content;
  }

  @override
  Future<AdminHomeContent> saveHomeContentApi(AdminHomeContent content) async {
    final data = await _editorialRequest(
      'PUT',
      '/admin/home-content',
      AdminEditorialCodec.homeToJson(content),
    );
    final saved = AdminEditorialCodec.homeFromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      _homeContent = saved;
    }

    return saved;
  }

  @override
  Future<List<AdminJournal>> fetchJournalsApi() async {
    final rows = await _editorialRequest('GET', '/admin/journals') as List<dynamic>;
    final journals = rows.map((row) => AdminEditorialCodec.journalFromJson(
      row as Map<String, dynamic>,
    )).toList(growable: false);

    if (SharedMockApiClient.enabled) {
      _journals
        ..clear()
        ..addAll(journals);
    }

    return journals;
  }

  @override
  Future<AdminJournal?> fetchJournalApi(String journalId) async {
    try {
      final data = await _editorialRequest(
          'GET', '/admin/journals/${Uri.encodeComponent(journalId)}');
      return AdminEditorialCodec.journalFromJson(data as Map<String, dynamic>);
    } on AdminEditorialApiException catch (error) {
      if (error.code == 'NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<AdminJournal> saveJournalApi(AdminJournal journal) async {
    final isNew = getJournal(journal.id) == null;
    final data = await _editorialRequest(
      isNew ? 'POST' : 'PUT',
      isNew ? '/admin/journals' : '/admin/journals/${Uri.encodeComponent(journal.id)}',
      AdminEditorialCodec.journalToJson(journal),
    );
    return AdminEditorialCodec.journalFromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AdminStoreSettings> fetchSettingsApi() async {
    final data = await _editorialRequest('GET', '/admin/store-settings');
    final settings = AdminEditorialCodec.settingsFromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      _settings = settings;
    }

    return settings;
  }

  @override
  Future<AdminStoreSettings> saveSettingsApi(AdminStoreSettings settings) async {
    final data = await _editorialRequest(
      'PUT',
      '/admin/store-settings',
      AdminEditorialCodec.settingsToJson(settings),
    );
    final saved = AdminEditorialCodec.settingsFromJson(
      data as Map<String, dynamic>,
    );

    if (SharedMockApiClient.enabled) {
      _settings = saved;
    }

    return saved;
  }

  @override
  AdminHomeContent getHomeContent() => _homeContent;

  @override
  void saveHomeContent(AdminHomeContent content) {
    _homeContent = content;
  }

  @override
  List<AdminJournal> getJournals() => List.unmodifiable(_journals);

  @override
  AdminJournal? getJournal(String journalId) {
    for (final journal in _journals) {
      if (journal.id == journalId) return journal;
    }
    return null;
  }

  @override
  void saveJournal(AdminJournal journal) {
    final index = _journals.indexWhere((item) => item.id == journal.id);
    if (index >= 0) {
      _journals[index] = journal;
    } else {
      _journals.insert(0, journal);
    }
  }

  @override
  AdminStoreSettings getSettings() => _settings;

  @override
  void saveSettings(AdminStoreSettings settings) {
    _settings = settings;
  }
}
