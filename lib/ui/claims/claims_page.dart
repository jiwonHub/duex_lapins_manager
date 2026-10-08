import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/utils/formatters.dart';
import 'package:duex_lapins_manager/core/widgets/admin_pagination.dart';
import 'package:duex_lapins_manager/core/widgets/page_heading.dart';
import 'package:duex_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:duex_lapins_manager/domain/models/admin_claim.dart';
import 'package:duex_lapins_manager/ui/claims/claims_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimsPage extends ConsumerWidget {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(claimsViewModelProvider);
    final vm = ref.read(claimsViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            eyebrow: '판매 관리 / 취소·교환·반품',
            title: '취소·교환·반품 관리',
            description: '취소·교환·반품 요청의 회수, 처리, 환불 상태를 관리합니다.',
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _filter('전체', state.type == null, () => vm.selectType(null)),
              ...AdminClaimType.values.map(
                (type) => _filter(
                  type.label,
                  state.type == type,
                  () => vm.selectType(type),
                ),
              ),
              const SizedBox(width: 14),
              _filter(
                '전체 상태',
                state.status == null,
                () => vm.selectStatus(null),
              ),
              ...AdminClaimProcessStatus.values.map(
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
                          dataRowMinHeight: 72,
                          dataRowMaxHeight: 72,
                          columns: const [
                            DataColumn(label: Text('구분')),
                            DataColumn(label: Text('주문번호')),
                            DataColumn(label: Text('구매자')),
                            DataColumn(label: Text('신청 사유')),
                            DataColumn(label: Text('신청일')),
                            DataColumn(label: Text('회수 상태')),
                            DataColumn(label: Text('처리 상태')),
                            DataColumn(label: Text('환불 상태')),
                            DataColumn(label: Text('관리')),
                          ],
                          rows: state.paged.map((claim) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  claimTypeBadge(claim.type),
                                ),
                                DataCell(Text(claim.orderId)),
                                DataCell(Text(claim.customerName)),
                                DataCell(
                                  SizedBox(
                                    width: 220,
                                    child: Text(
                                      claim.reason,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(formatDate(claim.requestedAt))),
                                DataCell(
                                  claimPickupStatusBadge(claim.pickupStatus),
                                ),
                                DataCell(
                                  claimProcessStatusBadge(claim.processStatus),
                                ),
                                DataCell(
                                  claimRefundStatusBadge(claim.refundStatus),
                                ),
                                DataCell(
                                  TextButton(
                                    onPressed: () => _edit(context, claim, vm),
                                    child: const Text('처리'),
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

  Widget _filter(String text, bool selected, VoidCallback onTap) {
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
          text,
          style: AdminTypography.label(
            fontSize: 9,
            color: selected ? AdminTheme.text : AdminTheme.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _edit(BuildContext context, AdminClaim claim, ClaimsViewModel vm) {
    var pickup = claim.pickupStatus;
    var process = claim.processStatus;
    var refund = claim.refundStatus;
    final memo = TextEditingController(text: claim.adminMemo);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('요청 처리', style: AdminTypography.serif(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text(
                    '${claim.orderId}  /  ${claim.type.label}  /  ${claim.customerName}',
                    style: AdminTypography.label(
                      fontSize: 9,
                      color: AdminTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(claim.reason),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<AdminPickupStatus>(
                    value: pickup,
                    decoration: const InputDecoration(labelText: '회수 여부'),
                    items: AdminPickupStatus.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => pickup = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AdminClaimProcessStatus>(
                    value: process,
                    decoration: const InputDecoration(labelText: '처리 상태'),
                    items: AdminClaimProcessStatus.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => process = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AdminRefundStatus>(
                    value: refund,
                    decoration: const InputDecoration(labelText: '환불 상태'),
                    items: AdminRefundStatus.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setModalState(() => refund = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: memo,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '관리자 메모'),
                  ),
                  const SizedBox(height: 22),
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
                          vm.updateClaim(
                            claim.copyWith(
                              pickupStatus: pickup,
                              processStatus: process,
                              refundStatus: refund,
                              adminMemo: memo.text.trim(),
                            ),
                          );
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
