import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:deux_lapins_manager/ui/products/products_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryRow {
  const InventoryRow({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.line,
    required this.color,
    required this.size,
    required this.quantity,
    required this.lowStockThreshold,
  });

  final String productId;
  final String productName;
  final String sku;
  final AdminProductLine line;
  final String color;
  final String size;
  final int quantity;
  final int lowStockThreshold;

  bool get isSoldOut => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
}

class InventoryState {
  const InventoryState({
    required this.products,
    this.query = '',
    this.onlyLowStock = false,
    this.page = 1,
    this.pageSize = 20,
    this.updating = false,
    this.errorMessage,
  });

  final List<AdminProduct> products;
  final String query;
  final bool onlyLowStock;
  final int page;
  final int pageSize;
  final bool updating;
  final String? errorMessage;

  List<InventoryRow> get rows {
    final normalized = query.trim().toLowerCase();
    final result = <InventoryRow>[];

    for (final product in products) {
      for (final item in product.inventory) {
        final row = InventoryRow(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          line: product.line,
          color: item.color,
          size: item.size,
          quantity: item.quantity,
          lowStockThreshold: item.lowStockThreshold,
        );
        final matchesQuery = normalized.isEmpty ||
            row.productName.toLowerCase().contains(normalized) ||
            row.sku.toLowerCase().contains(normalized) ||
            row.color.toLowerCase().contains(normalized) ||
            row.size.toLowerCase().contains(normalized);
        final matchesLowStock = !onlyLowStock || row.isLowStock;
        if (matchesQuery && matchesLowStock) result.add(row);
      }
    }
    return result;
  }

  int get soldOutOptionCount => rows.where((row) => row.isSoldOut).length;
  int get lowStockOptionCount => rows.where((row) => row.isLowStock).length;

  int get totalItems => rows.length;

  int get totalPages {
    if (totalItems == 0) return 1;
    return ((totalItems - 1) ~/ pageSize) + 1;
  }

  int get effectivePage {
    if (page < 1) return 1;
    if (page > totalPages) return totalPages;
    return page;
  }

  List<InventoryRow> get pagedRows {
    final items = rows;

    if (items.isEmpty) {
      return const [];
    }

    final start = (effectivePage - 1) * pageSize;
    final end = start + pageSize > items.length
        ? items.length
        : start + pageSize;

    return items.sublist(start, end);
  }

  InventoryState copyWith({
    List<AdminProduct>? products,
    String? query,
    bool? onlyLowStock,
    int? page,
    int? pageSize,
    bool? updating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryState(
      products: products ?? this.products,
      query: query ?? this.query,
      onlyLowStock: onlyLowStock ?? this.onlyLowStock,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      updating: updating ?? this.updating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final inventoryViewModelProvider =
    NotifierProvider<InventoryViewModel, InventoryState>(InventoryViewModel.new);

class InventoryViewModel extends Notifier<InventoryState> {
  @override
  InventoryState build() {
    return InventoryState(
      products: ref.read(adminRepositoryProvider).getProducts(),
    );
  }

  void search(String value) {
    state = state.copyWith(
      query: value,
      page: 1,
    );
  }

  void toggleLowStockOnly(bool value) {
    state = state.copyWith(
      onlyLowStock: value,
      page: 1,
    );
  }

  void setPage(int value) {
    if (value < 1 || value > state.totalPages) {
      return;
    }

    state = state.copyWith(
      page: value,
    );
  }

  void setPageSize(int value) {
    state = state.copyWith(
      pageSize: value,
      page: 1,
    );
  }

  void refresh() {
    state = state.copyWith(
      products: ref.read(adminRepositoryProvider).getProducts(),
    );
  }

  Future<void> updateQuantity(InventoryRow row, int quantity) async {
    if (state.updating) {
      throw StateError('재고 저장 요청이 진행 중입니다.');
    }

    if (quantity < 0) {
      throw ArgumentError.value(quantity, 'quantity');
    }

    state = state.copyWith(
      updating: true,
      clearError: true,
    );

    try {
      final repository = ref.read(adminRepositoryProvider);

      await repository.updateInventoryApi(
        productId: row.productId,
        color: row.color,
        size: row.size,
        quantity: quantity,
      );

      state = state.copyWith(
        products: repository.getProducts(),
        updating: false,
      );

      ref.invalidate(productsViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);
    } catch (error) {
      state = state.copyWith(
        updating: false,
        errorMessage: '$error',
      );
      rethrow;
    }
  }
}

