import 'dart:convert';

import 'package:deux_lapins_manager/app/app_routes.dart';
import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/utils/formatters.dart';
import 'package:deux_lapins_manager/core/widgets/admin_pagination.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/ui/inventory/inventory_view_model.dart';
import 'package:deux_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:deux_lapins_manager/ui/products/products_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  Future<void> _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      AdminProduct product,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('「${product.name}」 상품을 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(productsViewModelProvider.notifier)
          .deleteProduct(product.id);

      ref.invalidate(inventoryViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품을 삭제했습니다.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 삭제 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsViewModelProvider);
    final vm = ref.read(productsViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '판매 관리 / 상품',
            title: '상품 관리',
            description: '상품 등록·수정, 판매상태와 게시상태를 관리합니다.',
            trailing: FilledButton.icon(
              onPressed: () => context.go(AdminRoutePath.productCreate),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('새 상품 등록'),
            ),
          ),
          const SizedBox(height: 30),
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
                    hintText: '상품명 / 상품코드 / 시즌 검색',
                    prefixIcon: Icon(Icons.search, size: 17),
                  ),
                ),
              ),
              _FilterGroup(
                values: const ['전체', '클래식', '워크'],
                selected: state.line,
                onTap: vm.selectLine,
              ),
              _FilterGroup(
                values: const ['전체', '판매중', '품절', '비공개'],
                selected: state.status,
                onTap: vm.selectStatus,
              ),
              _FilterGroup(
                values: const ['전체', '임시저장', '게시'],
                selected: state.publish,
                onTap: vm.selectPublish,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
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
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('상품')),
                  DataColumn(label: Text('구분')),
                  DataColumn(label: Text('시즌')),
                  DataColumn(label: Text('가격')),
                  DataColumn(label: Text('재고')),
                  DataColumn(label: Text('판매상태')),
                  DataColumn(label: Text('게시상태')),
                  DataColumn(label: Text('수정일')),
                  DataColumn(label: Text('관리')),
                ],
                rows: state.paged.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 285,
                          child: Row(
                            children: [
                              _ProductThumbnail(product: product),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AdminTypography.serif(fontSize: 19),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      product.sku,
                                      style: AdminTypography.label(
                                        fontSize: 9,
                                        color: AdminTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(product.line.label)),
                      DataCell(Text(product.season)),
                      DataCell(Text(formatWon(product.price))),
                      DataCell(
                        stockQuantityBadge(
                          quantity: product.stock,
                          isLowStock: product.lowStockOptionCount > 0,
                        ),
                      ),
                      DataCell(
                        productSaleStatusBadge(product.status),
                      ),
                      DataCell(
                        productPublishStatusBadge(product.publishStatus),
                      ),
                      DataCell(Text(formatDate(product.updatedAt))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: state.saving
                                  ? null
                                  : () => context.go(
                                AdminRoutePath.productEdit(product.id),
                              ),
                              child: const Text('수정'),
                            ),
                            TextButton(
                              onPressed: state.saving
                                  ? null
                                  : () => _confirmDelete(context, ref, product),
                              child: const Text('삭제'),
                            ),
                          ],
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

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.values,
    required this.selected,
    required this.onTap,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AdminTheme.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((value) {
          final active = value == selected;
          return InkWell(
            onTap: () => onTap(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: active ? AdminTheme.text : Colors.transparent,
              child: Text(
                value,
                style: AdminTypography.label(
                  fontSize: 9,
                  letterSpacing: 0.9,
                  color: active ? AdminTheme.background : AdminTheme.muted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});

  final AdminProduct product;

  @override
  Widget build(BuildContext context) {
    Widget child = Center(
      child: Text(
        'DL',
        style: AdminTypography.serif(fontSize: 16, color: AdminTheme.muted),
      ),
    );

    if (product.mainImageBase64?.isNotEmpty == true) {
      try {
        child = Image.memory(
          base64Decode(product.mainImageBase64!),
          fit: BoxFit.cover,
          width: 44,
          height: 54,
          gaplessPlayback: true,
        );
      } catch (_) {}
    }

    return Container(
      width: 44,
      height: 54,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AdminTheme.soft,
        border: Border.all(color: AdminTheme.line),
      ),
      child: child,
    );
  }
}
