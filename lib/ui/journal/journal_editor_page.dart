import 'dart:convert';
import 'dart:typed_data';

import 'package:duex_lapins_manager/app/app_routes.dart';
import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';
import 'package:duex_lapins_manager/domain/models/admin_journal.dart';
import 'package:duex_lapins_manager/ui/journal/journal_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JournalEditorPage extends ConsumerStatefulWidget {
  const JournalEditorPage({super.key, this.journalId});

  final String? journalId;
  bool get editing => journalId != null;

  @override
  ConsumerState<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends ConsumerState<JournalEditorPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _createdDate = TextEditingController();
  final _publishDate = TextEditingController();
  String _category = 'JOURNAL';
  Uint8List? _cover;
  final List<Uint8List> _additional = [];
  final Set<String> _relatedProductIds = {};
  AdminJournal? _editing;

  @override
  void initState() {
    super.initState();
    if (widget.editing) {
      final journal = ref.read(journalViewModelProvider.notifier).getById(widget.journalId!);
      if (journal != null) {
        _editing = journal;
        _title.text = journal.title;
        _body.text = journal.body;
        _category = journal.category;
        _createdDate.text = _formatInputDate(journal.createdAt);
        _publishDate.text = _formatInputDate(journal.publishAt);
        _relatedProductIds.addAll(journal.relatedProductIds);
        try {
          if (journal.coverImageBase64?.isNotEmpty == true) {
            _cover = base64Decode(journal.coverImageBase64!);
          }
          for (final encoded in journal.additionalImageBase64) {
            _additional.add(base64Decode(encoded));
          }
        } catch (_) {}
      }
    } else {
      _createdDate.text = _formatInputDate(DateTime.now());
      _publishDate.text = _formatInputDate(DateTime.now());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _createdDate.dispose();
    _publishDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalViewModelProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '콘텐츠 관리 / 콘텐츠 작성',
                      style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.editing ? '저널 수정' : '새 저널 작성',
                      style: AdminTypography.serif(fontSize: 48),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => context.go(AdminRoutePath.journal),
                child: const Text('목록으로'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final form = Column(
                children: [
                  _section(
                    '01.',
                    '콘텐츠 정보',
                    Column(
                      children: [
                        TextField(
                          controller: _title,
                          decoration: const InputDecoration(labelText: '제목'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(labelText: '카테고리'),
                          items: const [
                            DropdownMenuItem(value: 'JOURNAL', child: Text('저널')),
                            DropdownMenuItem(value: 'PEOPLE', child: Text('피플')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _category = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _body,
                          minLines: 12,
                          maxLines: 24,
                          decoration: const InputDecoration(labelText: '본문'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _createdDate,
                                decoration: const InputDecoration(
                                  labelText: '작성일',
                                  hintText: '2026-10-08',
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: TextField(
                                controller: _publishDate,
                                decoration: const InputDecoration(
                                  labelText: '공개일',
                                  hintText: '2026-10-08',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    '02.',
                    '이미지',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _pickCover,
                          child: AspectRatio(
                            aspectRatio: 1.7,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AdminTheme.soft,
                                border: Border.all(color: AdminTheme.line),
                              ),
                              child: _cover == null
                                  ? const Center(child: Text('대표 이미지 선택'))
                                  : Image.memory(_cover!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _pickAdditional,
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 15),
                          label: const Text('추가 이미지'),
                        ),
                        if (_additional.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_additional.length, (index) {
                              return SizedBox(
                                width: 100,
                                height: 120,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(_additional[index], fit: BoxFit.cover),
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: IconButton.filled(
                                        onPressed: () => setState(() => _additional.removeAt(index)),
                                        icon: const Icon(Icons.close, size: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    '03.',
                    '관련 상품',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.products.map((product) {
                        final selected = _relatedProductIds.contains(product.id);
                        return FilterChip(
                          label: Text(product.name),
                          selected: selected,
                          showCheckmark: false,
                          shape: const RoundedRectangleBorder(),
                          side: const BorderSide(color: AdminTheme.line),
                          selectedColor: AdminTheme.soft,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _relatedProductIds.add(product.id);
                              } else {
                                _relatedProductIds.remove(product.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );

              final actions = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminTheme.surface,
                  border: Border.all(color: AdminTheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: () => _save(AdminContentPublishStatus.published),
                      child: const Text('게시'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _preview,
                      child: const Text('미리보기'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _save(AdminContentPublishStatus.draft),
                      child: const Text('임시저장'),
                    ),
                  ],
                ),
              );

              if (!wide) {
                return Column(children: [form, const SizedBox(height: 16), actions]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: form),
                  const SizedBox(width: 20),
                  SizedBox(width: 300, child: actions),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _section(String index, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted)),
          const SizedBox(height: 6),
          Text(title, style: AdminTypography.serif(fontSize: 30)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Future<Uint8List?> _readImage(PlatformFile file) async {
    final length = file.lengthSync() ?? await file.length();
    if (length == null || length > 10 * 1024 * 1024) return null;
    try {
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickCover() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await _readImage(file);
    if (bytes != null && mounted) setState(() => _cover = bytes);
  }

  Future<void> _pickAdditional() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final selected = <Uint8List>[];
    for (final file in files.take(8 - _additional.length)) {
      final bytes = await _readImage(file);
      if (bytes != null) selected.add(bytes);
    }
    if (mounted) setState(() => _additional.addAll(selected));
  }

  DateTime _parseDate(TextEditingController controller) {
    final parts = controller.text.trim().split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) return DateTime(y, m, d);
    }
    return DateTime.now();
  }

  String _formatInputDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  void _save(AdminContentPublishStatus status) {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 본문을 입력해주세요.')),
      );
      return;
    }
    final now = DateTime.now();
    final journal = AdminJournal(
      id: _editing?.id ?? 'J${now.microsecondsSinceEpoch}',
      title: _title.text.trim(),
      category: _category,
      body: _body.text.trim(),
      relatedProductIds: _relatedProductIds.toList(),
      createdAt: _parseDate(_createdDate),
      publishAt: _parseDate(_publishDate),
      publishStatus: status,
      coverImageBase64: _cover == null ? null : base64Encode(_cover!),
      additionalImageBase64: _additional.map(base64Encode).toList(),
    );
    ref.read(journalViewModelProvider.notifier).save(journal);
    context.go(AdminRoutePath.journal);
  }

  void _preview() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_category, style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted)),
                const SizedBox(height: 8),
                Text(
                  _title.text.isEmpty ? '저널 제목' : _title.text,
                  style: AdminTypography.serif(fontSize: 48, height: 0.95),
                ),
                const SizedBox(height: 22),
                if (_cover != null) ...[
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: Image.memory(_cover!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 26),
                ],
                Text(
                  _body.text,
                  style: AdminTypography.body(fontSize: 13, height: 1.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
