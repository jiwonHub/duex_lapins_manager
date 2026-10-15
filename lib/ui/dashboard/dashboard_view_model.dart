import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_claim.dart';
import 'package:deux_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
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

    bool isToday(DateTime value) {
      final local = value.toLocal();
      return local.year == now.year && local.month == now.month && local.day == now.day;
    }

    final todayOrders = orders.where((order) => isToday(order.orderedAt)).toList();
    // 실제 정산액이 아닌 Mock 주문의 결제완료 총액. 부분환불은 금액 정보가 없어 제외.
    final todaySales = todayOrders
        .where((order) => order.paymentStatus == AdminPaymentStatus.paid &&
        order.status != AdminOrderStatus.cancelled)
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
          .where((claim) => claim.type != AdminClaimType.cancel &&
          claim.processStatus != AdminClaimProcessStatus.completed &&
          claim.processStatus != AdminClaimProcessStatus.rejected)
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
