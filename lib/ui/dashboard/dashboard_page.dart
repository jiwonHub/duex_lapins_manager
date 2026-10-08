import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/utils/formatters.dart';
import 'package:duex_lapins_manager/core/widgets/metric_card.dart';
import 'package:duex_lapins_manager/core/widgets/page_heading.dart';
import 'package:duex_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:duex_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:duex_lapins_manager/domain/models/admin_order.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:duex_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeading(
                eyebrow: '운영 현황',
                title: '대시보드',
                description: '오늘의 주문, 매출, 배송, 문의와 재고 현황을 한눈에 확인합니다.',
                compact: true,
              ),
              const SizedBox(height: 16),
              _metricGrid(state, constraints.maxWidth),
              const SizedBox(height: 16),
              _overviewPanels(state, constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _metricGrid(DashboardState state, double width) {
    final count = width >= 980
        ? 3
        : width >= 620
            ? 2
            : 1;

    return GridView.count(
      crossAxisCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      mainAxisExtent: 108,
      children: [
        MetricCard(
          index: '01.',
          label: '오늘 주문',
          value: '${state.todayOrderCount}',
          caption: '오늘 접수된 주문',
          compact: true,
        ),
        MetricCard(
          index: '02.',
          label: '오늘 매출',
          value: formatWon(state.todaySales),
          caption: '취소 주문 제외',
          compact: true,
        ),
        MetricCard(
          index: '03.',
          label: '배송 준비중',
          value: '${state.preparingCount}',
          caption: '상품 준비 단계',
          compact: true,
        ),
        MetricCard(
          index: '04.',
          label: '교환·반품',
          value: '${state.claimRequestCount}',
          caption: '처리 대기 요청',
          compact: true,
        ),
        MetricCard(
          index: '05.',
          label: '미답변 문의',
          value: '${state.unansweredInquiryCount}',
          caption: '답변이 필요한 문의',
          compact: true,
        ),
        MetricCard(
          index: '06.',
          label: '재고 부족',
          value: '${state.lowStockProductCount}',
          caption: '확인이 필요한 상품',
          compact: true,
        ),
      ],
    );
  }

  Widget _overviewPanels(DashboardState state, double width) {
    const panelHeight = 330.0;
    const gap = 14.0;

    if (width >= 1020) {
      return SizedBox(
        height: panelHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _panel(
                title: '최근 주문',
                subtitle: '최근 접수된 주문',
                child: _compactOrders(state.recentOrders),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: _panel(
                title: '최근 문의',
                subtitle: '답변이 필요한 문의',
                child: _compactInquiries(state.recentInquiries),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: _panel(
                title: '재고 부족',
                subtitle: '확인이 필요한 상품',
                child: _compactStock(state.lowStockProducts),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: panelHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 340,
              child: _panel(
                title: '최근 주문',
                subtitle: '최근 접수된 주문',
                child: _compactOrders(state.recentOrders),
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: 340,
              child: _panel(
                title: '최근 문의',
                subtitle: '답변이 필요한 문의',
                child: _compactInquiries(state.recentInquiries),
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: 340,
              child: _panel(
                title: '재고 부족',
                subtitle: '확인이 필요한 상품',
                child: _compactStock(state.lowStockProducts),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AdminTypography.body(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.body(
                      fontSize: 10.5,
                      height: 1.2,
                      color: AdminTheme.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _compactOrders(List<AdminOrder> orders) {
    if (orders.isEmpty) {
      return _empty('최근 주문이 없습니다.');
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = orders[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 11.5,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.customerName} · ${formatWon(order.amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 10,
                        height: 1.2,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              orderStatusBadge(order.status),
            ],
          ),
        );
      },
    );
  }

  Widget _compactInquiries(List<AdminInquiry> inquiries) {
    if (inquiries.isEmpty) {
      return _empty('최근 문의가 없습니다.');
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: inquiries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 11.5,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${inquiry.type.label} · ${inquiry.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 10,
                        height: 1.2,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              inquiryStatusBadge(inquiry.status),
            ],
          ),
        );
      },
    );
  }

  Widget _compactStock(List<AdminProduct> products) {
    if (products.isEmpty) {
      return _empty('재고 부족 상품이 없습니다.');
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = products[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 11.5,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.sku} · ${product.line.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body(
                        fontSize: 10,
                        height: 1.2,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              stockQuantityBadge(
                quantity: product.stock,
                isLowStock: product.lowStockOptionCount > 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Text(
        text,
        style: AdminTypography.body(
          fontSize: 11,
          color: AdminTheme.muted,
        ),
      ),
    );
  }
}
