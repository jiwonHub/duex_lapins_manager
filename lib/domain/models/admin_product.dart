enum AdminProductLine {
  classic,
  work,
}

extension AdminProductLineLabel on AdminProductLine {
  String get label => switch (this) {
        AdminProductLine.classic => '클래식',
        AdminProductLine.work => '워크',
      };
}

enum AdminProductStatus {
  selling,
  soldOut,
  hidden,
}

extension AdminProductStatusLabel on AdminProductStatus {
  String get label => switch (this) {
        AdminProductStatus.selling => '판매중',
        AdminProductStatus.soldOut => '품절',
        AdminProductStatus.hidden => '비공개',
      };
}

enum AdminPublishStatus {
  draft,
  published,
}

extension AdminPublishStatusLabel on AdminPublishStatus {
  String get label => switch (this) {
        AdminPublishStatus.draft => '임시저장',
        AdminPublishStatus.published => '게시',
      };
}

class AdminInventoryItem {
  const AdminInventoryItem({
    required this.color,
    required this.size,
    required this.quantity,
    this.lowStockThreshold = 3,
  });

  final String color;
  final String size;
  final int quantity;
  final int lowStockThreshold;

  bool get isSoldOut => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;

  AdminInventoryItem copyWith({
    String? color,
    String? size,
    int? quantity,
    int? lowStockThreshold,
  }) {
    return AdminInventoryItem(
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}

class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.line,
    required this.season,
    required this.price,
    required this.description,
    required this.material,
    required this.colors,
    required this.sizes,
    required this.fit,
    required this.detail,
    required this.care,
    required this.status,
    required this.publishStatus,
    required this.updatedAt,
    required this.inventory,
    this.isBest = false,
    this.isPremium = false,
    this.mainImageBase64,
    this.detailImageBase64 = const [],
  });

  final String id;
  final String name;
  final String sku;
  final AdminProductLine line;
  final String season;
  final int price;
  final String description;
  final String material;
  final List<String> colors;
  final List<String> sizes;
  final String fit;
  final String detail;
  final String care;
  final AdminProductStatus status;
  final AdminPublishStatus publishStatus;
  final DateTime updatedAt;
  final List<AdminInventoryItem> inventory;
  final bool isBest;
  final bool isPremium;
  final String? mainImageBase64;
  final List<String> detailImageBase64;

  int get stock => inventory.fold<int>(0, (sum, item) => sum + item.quantity);

  int get lowStockOptionCount =>
      inventory.where((item) => item.isLowStock).length;

  bool get isVisible =>
      status != AdminProductStatus.hidden &&
      publishStatus == AdminPublishStatus.published;

  AdminProduct copyWith({
    String? id,
    String? name,
    String? sku,
    AdminProductLine? line,
    String? season,
    int? price,
    String? description,
    String? material,
    List<String>? colors,
    List<String>? sizes,
    String? fit,
    String? detail,
    String? care,
    AdminProductStatus? status,
    AdminPublishStatus? publishStatus,
    DateTime? updatedAt,
    List<AdminInventoryItem>? inventory,
    bool? isBest,
    bool? isPremium,
    String? mainImageBase64,
    List<String>? detailImageBase64,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      line: line ?? this.line,
      season: season ?? this.season,
      price: price ?? this.price,
      description: description ?? this.description,
      material: material ?? this.material,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      fit: fit ?? this.fit,
      detail: detail ?? this.detail,
      care: care ?? this.care,
      status: status ?? this.status,
      publishStatus: publishStatus ?? this.publishStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      inventory: inventory ?? this.inventory,
      isBest: isBest ?? this.isBest,
      isPremium: isPremium ?? this.isPremium,
      mainImageBase64: mainImageBase64 ?? this.mainImageBase64,
      detailImageBase64: detailImageBase64 ?? this.detailImageBase64,
    );
  }
}
