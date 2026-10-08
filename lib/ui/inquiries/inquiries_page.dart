import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/utils/formatters.dart';
import 'package:duex_lapins_manager/core/widgets/page_heading.dart';
import 'package:duex_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:duex_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:duex_lapins_manager/ui/inquiries/inquiries_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiriesPage extends ConsumerWidget {
  const InquiriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inquiriesViewModelProvider);
    final vm = ref.read(inquiriesViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            eyebrow: '고객 관리 / 문의',
            title: '문의 관리',
            description: '상품 문의와 1:1 문의를 확인하고 관리자에서 바로 답변합니다.',
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  onChanged: vm.search,
                  decoration: const InputDecoration(
                    hintText: '제목 / 고객 / 문의내용 검색',
                    prefixIcon: Icon(Icons.search, size: 17),
                  ),
                ),
              ),
              _filter('전체', state.type == null, () => vm.selectType(null)),
              ...AdminInquiryType.values.map(
                (type) => _filter(
                  type.label,
                  state.type == type,
                  () => vm.selectType(type),
                ),
              ),
              _filter('전체 상태', state.status == null, () => vm.selectStatus(null)),
              ...AdminInquiryStatus.values.map(
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
            decoration: BoxDecoration(border: Border.all(color: AdminTheme.line)),
            child: Column(
              children: state.visible.map((inquiry) {
                return InkWell(
                  onTap: () => _open(context, inquiry, vm),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AdminTheme.line)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            inquiry.type.label,
                            style: AdminTypography.label(
                              fontSize: 9,
                              color: AdminTheme.muted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inquiry.title,
                                style: AdminTypography.serif(fontSize: 21),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${inquiry.customerName}  /  ${formatDate(inquiry.createdAt)}',
                                style: AdminTypography.label(
                                  fontSize: 9,
                                  color: AdminTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        inquiryStatusBadge(inquiry.status),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
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

  void _open(
    BuildContext context,
    AdminInquiry inquiry,
    InquiriesViewModel vm,
  ) {
    final answer = TextEditingController(text: inquiry.answer);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inquiry.title, style: AdminTypography.serif(fontSize: 34)),
                const SizedBox(height: 8),
                Text(
                  '${inquiry.type.label}  /  ${inquiry.customerName}',
                  style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
                ),
                if (inquiry.productName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    inquiry.productName!,
                    style: AdminTypography.label(fontSize: 9),
                  ),
                ],
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: AdminTheme.surface,
                  child: Text(inquiry.question, style: AdminTypography.body(fontSize: 12)),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: answer,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(hintText: '답변을 입력하세요.'),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('닫기'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (answer.text.trim().isEmpty) return;
                        vm.answer(inquiry.id, answer.text.trim());
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('답변 등록'),
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
