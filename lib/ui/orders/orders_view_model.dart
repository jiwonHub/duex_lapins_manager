import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersState {
  const OrdersState({
    required this.all,
    this.query = '',
    this.status,
    this.selectedIds = const {},
    this.page = 1,
    this.pageSize = 20,
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final bool loading;
  final bool saving;
  final String? errorMessage;
  final List<AdminOrder> all;
  final String query;
  final AdminOrderStatus? status;
  final Set<String> selectedIds;
  final int page;
  final int pageSize;

  List<AdminOrder> get visible {
    final normalized = query.trim().toLowerCase();

    return all.where((order) {
      final matchesStatus = status == null || order.status == status;

      final matchesQuery = normalized.isEmpty ||
          order.id.toLowerCase().contains(normalized) ||
          order.customerName.toLowerCase().contains(normalized) ||
          order.phone.toLowerCase().contains(normalized);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int get totalItems => visible.length;

  int get totalPages {
    if (totalItems == 0) {
      return 1;
    }

    return ((totalItems - 1) ~/ pageSize) + 1;
  }

  int get effectivePage {
    if (page < 1) {
      return 1;
    }

    if (page > totalPages) {
      return totalPages;
    }

    return page;
  }

  List<AdminOrder> get paged {
    final items = visible;

    if (items.isEmpty) {
      return const [];
    }

    final start = (effectivePage - 1) * pageSize;

    final end = start + pageSize > items.length
        ? items.length
        : start + pageSize;

    return items.sublist(
      start,
      end,
    );
  }

  OrdersState copyWith({
    List<AdminOrder>? all,
    String? query,
    AdminOrderStatus? status,
    bool clearStatus = false,
    Set<String>? selectedIds,
    int? page,
    int? pageSize,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      all: all ?? this.all,
      query: query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
      selectedIds: selectedIds ?? this.selectedIds,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final ordersViewModelProvider =
    NotifierProvider<OrdersViewModel, OrdersState>(OrdersViewModel.new);

class OrdersViewModel extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    Future<void>.microtask(refresh);
    return OrdersState(all: ref.read(adminRepositoryProvider).getOrders());
  }

  void search(String value) {
    state = state.copyWith(
      query: value,
      page: 1,
      selectedIds: <String>{},
    );
  }

  void selectStatus(AdminOrderStatus? status) {
    state = status == null
        ? state.copyWith(
      clearStatus: true,
      page: 1,
      selectedIds: <String>{},
    )
        : state.copyWith(
      status: status,
      page: 1,
      selectedIds: <String>{},
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
  void toggleSelected(String orderId) {
    final selected = {...state.selectedIds};
    if (!selected.add(orderId)) selected.remove(orderId);
    state = state.copyWith(selectedIds: selected);
  }

  void selectAllVisible(bool selected) {
    final ids = {
      ...state.selectedIds,
    };

    final pageIds = state.paged
        .map(
          (order) => order.id,
    )
        .toSet();

    if (selected) {
      ids.addAll(pageIds);
    } else {
      ids.removeAll(pageIds);
    }

    state = state.copyWith(
      selectedIds: ids,
    );
  }

  AdminOrder? getById(String orderId) {
    return ref.read(adminRepositoryProvider).getOrder(orderId);
  }

  Future<void> _save(Future<void> Function() request, {bool clearSelection = false}) async {
    if (state.saving || state.loading) {
      throw StateError('다른 주문 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      await request();
      final orders = await ref.read(adminRepositoryProvider).fetchOrdersApi();
      state = state.copyWith(
        all: orders,
        saving: false,
        selectedIds: clearSelection ? <String>{} : null,
      );
      ref.invalidate(dashboardViewModelProvider);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }

  Future<void> updateOrder(AdminOrder order) =>
      _save(() async { await ref.read(adminRepositoryProvider).saveOrderApi(order); });

  Future<void> updateStatus(AdminOrder order, AdminOrderStatus status) =>
      updateOrder(order.copyWith(status: status));

  Future<void> bulkShip(String carrier, Map<String, String> trackingNumbers) {
    final ids = state.selectedIds.toList(growable: false);
    return _save(() => ref.read(adminRepositoryProvider).bulkShipOrdersApi(
      orderIds: ids,
      carrier: carrier,
      trackingNumbers: trackingNumbers,
    ), clearSelection: true);
  }

  Future<void> refresh() async {
    if (state.saving || state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final orders = await ref.read(adminRepositoryProvider).fetchOrdersApi();
      state = state.copyWith(all: orders, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }
}
