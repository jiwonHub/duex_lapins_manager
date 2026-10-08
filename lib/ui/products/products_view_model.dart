import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsState {
  const ProductsState({
    required this.all,
    this.query = '',
    this.line = '전체',
    this.status = '전체',
    this.publish = '전체',
    this.page = 1,
    this.pageSize = 20,
  });

  final List<AdminProduct> all;
  final String query;
  final String line;
  final String status;
  final String publish;
  final int page;
  final int pageSize;

  List<AdminProduct> get visible {
    final normalized = query.trim().toLowerCase();
    return all.where((product) {
      final matchesQuery = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.sku.toLowerCase().contains(normalized) ||
          product.season.toLowerCase().contains(normalized);
      final matchesLine = line == '전체' || product.line.label == line;
      final matchesStatus = status == '전체' || product.status.label == status;
      final matchesPublish =
          publish == '전체' || product.publishStatus.label == publish;
      return matchesQuery && matchesLine && matchesStatus && matchesPublish;
    }).toList();
  }

  int get totalItems => visible.length;

  int get totalPages {
    if (totalItems == 0) return 1;
    return ((totalItems - 1) ~/ pageSize) + 1;
  }

  int get effectivePage {
    if (page < 1) return 1;
    if (page > totalPages) return totalPages;
    return page;
  }

  List<AdminProduct> get paged {
    final items = visible;

    if (items.isEmpty) {
      return const [];
    }

    final start = (effectivePage - 1) * pageSize;
    final end = start + pageSize > items.length
        ? items.length
        : start + pageSize;

    return items.sublist(start, end);
  }

  ProductsState copyWith({
    List<AdminProduct>? all,
    String? query,
    String? line,
    String? status,
    String? publish,
    int? page,
    int? pageSize,
  }) {
    return ProductsState(
      all: all ?? this.all,
      query: query ?? this.query,
      line: line ?? this.line,
      status: status ?? this.status,
      publish: publish ?? this.publish,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

final productsViewModelProvider =
    NotifierProvider<ProductsViewModel, ProductsState>(ProductsViewModel.new);

class ProductsViewModel extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    return ProductsState(all: ref.read(adminRepositoryProvider).getProducts());
  }

  void search(String value) {
    state = state.copyWith(
      query: value,
      page: 1,
    );
  }

  void selectLine(String value) {
    state = state.copyWith(
      line: value,
      page: 1,
    );
  }

  void selectStatus(String value) {
    state = state.copyWith(
      status: value,
      page: 1,
    );
  }

  void selectPublish(String value) {
    state = state.copyWith(
      publish: value,
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

  AdminProduct? getById(String productId) {
    return ref.read(adminRepositoryProvider).getProduct(productId);
  }

  void refresh() {
    state = state.copyWith(all: ref.read(adminRepositoryProvider).getProducts());
  }

  void saveProduct(AdminProduct product) {
    final repository = ref.read(adminRepositoryProvider);
    if (repository.getProduct(product.id) == null) {
      repository.addProduct(product);
    } else {
      repository.updateProduct(product);
    }
    state = state.copyWith(all: repository.getProducts());
  }
}
