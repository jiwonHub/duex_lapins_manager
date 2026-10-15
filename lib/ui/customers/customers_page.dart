import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/utils/formatters.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:deux_lapins_manager/domain/models/admin_customer.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/ui/customers/customers_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customersViewModelProvider);
    final vm = ref.read(customersViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            eyebrow: '고객 관리 / 회원',
            title: '회원 관리',
            description: '회원 정보와 각 회원의 주문내역을 확인합니다.',
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 340,
            child: TextField(
              onChanged: vm.search,
              decoration: const InputDecoration(
                hintText: '이름 / 이메일 / 연락처 검색',
                prefixIcon: Icon(Icons.search, size: 17),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AdminTheme.line)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    const WidgetStatePropertyAll(AdminTheme.surface),
                dataRowMinHeight: 62,
                dataRowMaxHeight: 62,
                columns: const [
                  DataColumn(label: Text('회원')),
                  DataColumn(label: Text('이메일')),
                  DataColumn(label: Text('연락처')),
                  DataColumn(label: Text('주문수')),
                  DataColumn(label: Text('누적 구매금액')),
                  DataColumn(label: Text('가입일')),
                  DataColumn(label: Text('관리')),
                ],
                rows: state.visible.map((customer) {
                  return DataRow(
                    cells: [
                      DataCell(Text(customer.name, style: AdminTypography.serif(fontSize: 20))),
                      DataCell(Text(customer.email)),
                      DataCell(Text(customer.phone)),
                      DataCell(Text('${customer.orderCount}')),
                      DataCell(Text(formatWon(customer.totalSpent))),
                      DataCell(Text(formatDate(customer.joinedAt))),
                      DataCell(
                        TextButton(
                          onPressed: () => _detail(context, customer, vm),
                          child: const Text('상세'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _detail(
    BuildContext context,
    AdminCustomer customer,
    CustomersViewModel vm,
  ) {
    final orders = vm.ordersFor(customer.id);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AdminTypography.serif(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  '${customer.email}  /  ${customer.phone}',
                  style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
                ),
                const SizedBox(height: 8),
                Text(customer.address, style: AdminTypography.body(fontSize: 11)),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 18),
                Text('주문 내역', style: AdminTypography.serif(fontSize: 28)),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  const Text('주문내역이 없습니다.')
                else
                  ...orders.map(
                    (order) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AdminTheme.line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(order.id)),
                          Text(formatWon(order.amount)),
                          const SizedBox(width: 18),
                          orderStatusBadge(order.status),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
