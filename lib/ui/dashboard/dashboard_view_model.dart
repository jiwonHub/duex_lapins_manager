import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_claim.dart';
import 'package:duex_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:duex_lapins_manager/domain/models/admin_order.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  const DashboardState({
    required this.todayOrderCount,
    required this.todaySales,
    required this.preparingCount,
    required this.claimRequestCount,
    required this.unansweredInquiryCount,
    required this.lowStockProductCount,
    required this.recentOrders,
    required this.recentInquiries,
    required this.lowStockProducts,
  });

  final int todayOrderCount;
  final int todaySales;
  final int preparingCount;
  final int claimRequestCount;
  final int unansweredInquiryCount;
  final int lowStockProductCount;
  final List<AdminOrder> recentOrders;
  final List<AdminInquiry> recentInquiries;
  final List<AdminProduct> lowStockProducts;
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(DashboardViewModel.new);

class DashboardViewModel extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    final repository = ref.read(adminRepositoryProvider);
    final orders = repository.getOrders();
    final products = repository.getProducts();
    final inquiries = repository.getInquiries();
    final claims = repository.getClaims();
    final now = DateTime.now();

    bool isToday(DateTime value) =>
        value.year == now.year && value.month == now.month && value.day == now.day;

    final todayOrders = orders.where((order) => isToday(order.orderedAt)).toList();
    final todaySales = todayOrders
        .where((order) => order.status != AdminOrderStatus.cancelled)
        .fold<int>(0, (sum, order) => sum + order.amount);
    final lowStock = products
        .where((product) => product.inventory.any((item) => item.isLowStock))
        .toList();

    return DashboardState(
      todayOrderCount: todayOrders.length,
      todaySales: todaySales,
      preparingCount: orders
          .where((order) => order.status == AdminOrderStatus.preparing)
          .length,
      claimRequestCount: claims
          .where((claim) => claim.processStatus != AdminClaimProcessStatus.completed)
          .length,
      unansweredInquiryCount: inquiries
          .where((inquiry) => inquiry.status == AdminInquiryStatus.unanswered)
          .length,
      lowStockProductCount: lowStock.length,
      recentOrders: orders.take(5).toList(),
      recentInquiries: inquiries.take(5).toList(),
      lowStockProducts: lowStock.take(5).toList(),
    );
  }
}
