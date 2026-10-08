import 'package:duex_lapins_manager/app/app_routes.dart';
import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/utils/formatters.dart';
import 'package:duex_lapins_manager/core/widgets/admin_pagination.dart';
import 'package:duex_lapins_manager/core/widgets/page_heading.dart';
import 'package:duex_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:duex_lapins_manager/domain/models/admin_order.dart';
import 'package:duex_lapins_manager/ui/orders/orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersViewModelProvider);
    final vm = ref.read(ordersViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '판매 관리 / 주문',
            title: '주문 관리',
            description: '주문상태, 배송처리와 송장번호를 관리합니다.',
            trailing: state.selectedIds.isEmpty
                ? null
                : FilledButton.icon(
                    onPressed: () => _showBulkShipping(context, state, vm),
                    icon: const Icon(Icons.local_shipping_outlined, size: 15),
                    label: Text('${state.selectedIds.length}건 배송처리'),
                  ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  onChanged: vm.search,
                  decoration: const InputDecoration(
                    hintText: '주문번호 / 구매자 / 연락처 검색',
                    prefixIcon: Icon(Icons.search, size: 17),
                  ),
                ),
              ),
              _filter('전체', state.status == null, () => vm.selectStatus(null)),
              ...AdminOrderStatus.values.map(
                (status) => _filter(
                  status.label,
                  state.status == status,
                  () => vm.selectStatus(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AdminTheme.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: const WidgetStatePropertyAll(
                            AdminTheme.surface,
                          ),
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 64,
                          columns: [
                            DataColumn(
                              label: Checkbox(
                                value:
                                    state.paged.isNotEmpty &&
                                    state.paged.every(
                                      (order) =>
                                          state.selectedIds.contains(order.id),
                                    ),
                                onChanged: (value) =>
                                    vm.selectAllVisible(value ?? false),
                              ),
                            ),
                            const DataColumn(label: Text('주문번호')),
                            const DataColumn(label: Text('구매자')),
                            const DataColumn(label: Text('상품수')),
                            const DataColumn(label: Text('결제금액')),
                            const DataColumn(label: Text('결제상태')),
                            const DataColumn(label: Text('배송상태')),
                            const DataColumn(label: Text('주문일')),
                            const DataColumn(label: Text('관리')),
                          ],
                          rows: state.paged.map((order) {
                            return DataRow(
                              selected: state.selectedIds.contains(order.id),
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: state.selectedIds.contains(order.id),
                                    onChanged: (_) =>
                                        vm.toggleSelected(order.id),
                                  ),
                                ),
                                DataCell(Text(order.id)),
                                DataCell(Text(order.customerName)),
                                DataCell(Text('${order.itemCount}')),
                                DataCell(Text(formatWon(order.amount))),
                                DataCell(
                                  orderPaymentStatusBadge(order.paymentStatus),
                                ),
                                DataCell(
                                  orderStatusBadge(order.status),
                                ),
                                DataCell(Text(formatDate(order.orderedAt))),
                                DataCell(
                                  TextButton(
                                    onPressed: () => context.go(
                                      AdminRoutePath.orderDetail(order.id),
                                    ),
                                    child: const Text('상세'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                AdminPagination(
                  totalItems: state.totalItems,
                  currentPage: state.effectivePage,
                  pageSize: state.pageSize,
                  onPageChanged: vm.setPage,
                  onPageSizeChanged: vm.setPageSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AdminTheme.text : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: AdminTypography.label(
            fontSize: 9,
            color: selected ? AdminTheme.text : AdminTheme.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showBulkShipping(
    BuildContext context,
    OrdersState state,
    OrdersViewModel vm,
  ) {
    final carrier = TextEditingController(text: 'CJ대한통운');
    final controllers = <String, TextEditingController>{
      for (final id in state.selectedIds) id: TextEditingController(),
    };

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('일괄 배송 처리', style: AdminTypography.serif(fontSize: 34)),
                const SizedBox(height: 8),
                Text(
                  '선택 주문의 택배사와 송장번호를 등록합니다.',
                  style: AdminTypography.body(
                    fontSize: 11.5,
                    color: AdminTheme.muted,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: carrier,
                  decoration: const InputDecoration(labelText: '택배사'),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 330),
                  child: SingleChildScrollView(
                    child: Column(
                      children: controllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  entry.key,
                                  style: AdminTypography.label(fontSize: 9),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: entry.value,
                                  decoration: const InputDecoration(
                                    hintText: '송장번호',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        vm.bulkShip(carrier.text.trim(), {
                          for (final entry in controllers.entries)
                            entry.key: entry.value.text.trim(),
                        });
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('배송처리'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
