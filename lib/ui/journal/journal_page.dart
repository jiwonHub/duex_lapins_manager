import 'package:deux_lapins_manager/app/app_routes.dart';
import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/utils/formatters.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/ui/journal/journal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalViewModelProvider);
    final vm = ref.read(journalViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '콘텐츠 관리 / 저널',
            title: '저널 관리',
            description: '저널과 피플 콘텐츠를 작성하고 게시합니다.',
            trailing: FilledButton.icon(
              onPressed: () => context.go(AdminRoutePath.journalCreate),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('새 콘텐츠 작성'),
            ),
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
                    hintText: '제목 / 본문 검색',
                    prefixIcon: Icon(Icons.search, size: 17),
                  ),
                ),
              ),
              _filter('전체', state.category == 'ALL', () => vm.selectCategory('ALL')),
              _filter('저널', state.category == 'JOURNAL', () => vm.selectCategory('JOURNAL')),
              _filter('피플', state.category == 'PEOPLE', () => vm.selectCategory('PEOPLE')),
              _filter('전체 게시상태', state.publish == 'ALL', () => vm.selectPublish('ALL')),
              _filter('임시저장', state.publish == '임시저장', () => vm.selectPublish('임시저장')),
              _filter('게시', state.publish == '게시', () => vm.selectPublish('게시')),
            ],
          ),
          const SizedBox(height: 20),
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          if (!state.loading && state.errorMessage == null && state.visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('조건에 맞는 저널이 없습니다.'),
            ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AdminTheme.line)),
            child: Column(
              children: state.visible.map((journal) {
                return InkWell(
                  onTap: () => context.go(AdminRoutePath.journalEdit(journal.id)),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AdminTheme.line)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            journal.category == 'PEOPLE' ? '피플' : '저널',
                            style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(journal.title, style: AdminTypography.serif(fontSize: 23)),
                              const SizedBox(height: 4),
                              Text(
                                '작성 ${formatDate(journal.createdAt)}  /  공개 ${formatDate(journal.publishAt)}',
                                style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
                              ),
                            ],
                          ),
                        ),
                        contentPublishStatusBadge(journal.publishStatus),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, size: 15),
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
}
