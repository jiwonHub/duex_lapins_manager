import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/widgets/admin_pagination.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/ui/inventory/inventory_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryViewModelProvider);
    final vm = ref.read(inventoryViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            eyebrow: '판매 관리 / 재고',
            title: '재고 관리',
            description: '상품 / 컬러 / 사이즈 단위로 재고를 관리합니다.',
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 340,
                child: TextField(
                  onChanged: vm.search,
                  decoration: const InputDecoration(
                    hintText: '상품명 / 상품코드 / 컬러 / 사이즈 검색',
                    prefixIcon: Icon(Icons.search, size: 17),
                  ),
                ),
              ),
              FilterChip(
                label: Text(
                  '재고 부족만 보기',
                  style: AdminTypography.label(fontSize: 9.5),
                ),
                selected: state.onlyLowStock,
                onSelected: vm.toggleLowStockOnly,
                shape: const RoundedRectangleBorder(),
                side: const BorderSide(color: AdminTheme.line),
                selectedColor: AdminTheme.soft,
                showCheckmark: false,
              ),
              _Summary(label: '재고 부족', value: state.lowStockOptionCount),
              _Summary(label: '품절', value: state.soldOutOptionCount),
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
                headingRowColor:
                    const WidgetStatePropertyAll(AdminTheme.surface),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('상품')),
                  DataColumn(label: Text('구분')),
                  DataColumn(label: Text('컬러')),
                  DataColumn(label: Text('사이즈')),
                  DataColumn(label: Text('재고')),
                  DataColumn(label: Text('상태')),
                ],
                rows: state.pagedRows.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.productName,
                                style: AdminTypography.serif(fontSize: 18),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                row.sku,
                                style: AdminTypography.label(
                                  fontSize: 9,
                                  color: AdminTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(row.line.label)),
                      DataCell(ProductColorBadge(colorName: row.color)),
                      DataCell(Text(row.size)),
                      DataCell(
                        SizedBox(
                          width: 82,
                          child: TextFormField(
                            key: ValueKey(
                              '${row.productId}-${row.color}-${row.size}-${row.quantity}',
                            ),
                            initialValue: '${row.quantity}',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: !state.updating,
                            onFieldSubmitted: (value) async {
                              final quantity = int.tryParse(value);

                              if (quantity == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('올바른 재고 수량을 입력해주세요.'),
                                  ),
                                );
                                return;
                              }

                              try {
                                await vm.updateQuantity(row, quantity);
                              } catch (error) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('재고 저장 실패: $error'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        stockStatusBadge(
                          isSoldOut: row.isSoldOut,
                          isLowStock: row.isLowStock,
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
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: AdminTheme.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
          ),
          const SizedBox(width: 10),
          Text(
            '$value',
            style: AdminTypography.label(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
