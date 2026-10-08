import 'dart:convert';
import 'dart:typed_data';

import 'package:duex_lapins_manager/core/theme/admin_theme.dart';
import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/widgets/page_heading.dart';
import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';
import 'package:duex_lapins_manager/ui/content/home_content_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentPage extends ConsumerStatefulWidget {
  const ContentPage({super.key});

  @override
  ConsumerState<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends ConsumerState<ContentPage> {
  final _mainText = TextEditingController();
  final _subText = TextEditingController();
  final _buttonText = TextEditingController();
  final _buttonRoute = TextEditingController();
  final _order = TextEditingController();

  bool _loaded = false;
  bool _heroVisible = true;
  bool _classicVisible = true;
  bool _workVisible = true;
  Uint8List? _heroMedia;
  String _heroMediaName = '';
  bool _heroIsVideo = false;
  Uint8List? _classicImage;
  Uint8List? _workImage;
  final Set<String> _newArrivalIds = {};

  @override
  void dispose() {
    _mainText.dispose();
    _subText.dispose();
    _buttonText.dispose();
    _buttonRoute.dispose();
    _order.dispose();
    super.dispose();
  }

  void _load(AdminHomeContent content) {
    if (_loaded) return;
    _loaded = true;
    _mainText.text = content.hero.mainText;
    _subText.text = content.hero.subText;
    _buttonText.text = content.hero.buttonText;
    _buttonRoute.text = content.hero.buttonRoute;
    _order.text = '${content.hero.order}';
    _heroVisible = content.hero.visible;
    _classicVisible = content.classicVisible;
    _workVisible = content.workVisible;
    _heroMediaName = content.hero.mediaName;
    _heroIsVideo = content.hero.isVideo;
    _newArrivalIds.addAll(content.newArrivalProductIds);
    try {
      if (content.hero.mediaBase64?.isNotEmpty == true) {
        _heroMedia = base64Decode(content.hero.mediaBase64!);
      }
      if (content.classicImageBase64?.isNotEmpty == true) {
        _classicImage = base64Decode(content.classicImageBase64!);
      }
      if (content.workImageBase64?.isNotEmpty == true) {
        _workImage = base64Decode(content.workImageBase64!);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeContentViewModelProvider);
    _load(state.content);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '콘텐츠 관리 / 홈페이지',
            title: '홈페이지 관리',
            description: '메인 배너, 클래식·워크 이미지와 신규 상품 노출 영역을 관리합니다.',
            trailing: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _preview,
                  child: const Text('미리보기'),
                ),
                OutlinedButton(
                  onPressed: () => _save(AdminContentPublishStatus.draft),
                  child: const Text('임시저장'),
                ),
                FilledButton(
                  onPressed: () => _save(AdminContentPublishStatus.published),
                  child: const Text('게시'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _section(
            '01.',
            '메인 배너',
            '메인 첫 화면의 이미지/영상과 문구를 관리합니다.',
            Column(
              children: [
                InkWell(
                  onTap: _pickHeroMedia,
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AdminTheme.soft,
                      border: Border.all(color: AdminTheme.line),
                    ),
                    child: _heroMedia == null
                        ? _mediaPlaceholder('메인 이미지 또는 영상 선택')
                        : _heroIsVideo
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.movie_outlined, size: 34),
                                    const SizedBox(height: 10),
                                    Text(_heroMediaName),
                                  ],
                                ),
                              )
                            : Image.memory(_heroMedia!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                _two(
                  TextField(
                    controller: _mainText,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: '메인 문구'),
                  ),
                  TextField(
                    controller: _subText,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: '서브 문구'),
                  ),
                ),
                const SizedBox(height: 18),
                _two(
                  TextField(
                    controller: _buttonText,
                    decoration: const InputDecoration(labelText: '버튼 문구'),
                  ),
                  TextField(
                    controller: _buttonRoute,
                    decoration: const InputDecoration(labelText: '버튼 연결 페이지'),
                  ),
                ),
                const SizedBox(height: 18),
                _two(
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _heroVisible,
                    title: const Text('메인 배너 노출'),
                    onChanged: (value) => setState(() => _heroVisible = value),
                  ),
                  TextField(
                    controller: _order,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '노출 순서'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            '02.',
            '클래식 / 워크',
            '각 라인의 메인 이미지와 노출 여부를 관리합니다.',
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final classic = _lineMediaCard(
                  '클래식',
                  _classicImage,
                  _classicVisible,
                  _pickClassicImage,
                  (value) => setState(() => _classicVisible = value),
                );
                final work = _lineMediaCard(
                  '워크',
                  _workImage,
                  _workVisible,
                  _pickWorkImage,
                  (value) => setState(() => _workVisible = value),
                );
                if (!wide) {
                  return Column(children: [classic, const SizedBox(height: 16), work]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: classic),
                    const SizedBox(width: 18),
                    Expanded(child: work),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _section(
            '03.',
            '신규 상품',
            '메인 신규 상품 영역에 노출할 상품을 직접 선택합니다.',
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: state.products.map((product) {
                final selected = _newArrivalIds.contains(product.id);
                return FilterChip(
                  label: Text('${product.name} / ${product.sku}'),
                  selected: selected,
                  showCheckmark: false,
                  shape: const RoundedRectangleBorder(),
                  side: const BorderSide(color: AdminTheme.line),
                  selectedColor: AdminTheme.soft,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _newArrivalIds.add(product.id);
                      } else {
                        _newArrivalIds.remove(product.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String index, String title, String caption, Widget child) {
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
          Text(title, style: AdminTypography.serif(fontSize: 31)),
          const SizedBox(height: 5),
          Text(
            caption,
            style: AdminTypography.body(fontSize: 11.5, color: AdminTheme.muted),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _two(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(children: [a, const SizedBox(height: 16), b]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 20),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  Widget _lineMediaCard(
    String label,
    Uint8List? bytes,
    bool visible,
    VoidCallback onPick,
    ValueChanged<bool> onVisible,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminTypography.label(fontSize: 10)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AdminTheme.soft,
                border: Border.all(color: AdminTheme.line),
              ),
              child: bytes == null
                  ? _mediaPlaceholder('$label 이미지 선택')
                  : Image.memory(bytes, fit: BoxFit.cover),
            ),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: visible,
          title: Text('$label 노출'),
          onChanged: onVisible,
        ),
      ],
    );
  }

  Widget _mediaPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined, size: 28),
        const SizedBox(height: 10),
        Text(label, style: AdminTypography.label(fontSize: 9.5)),
      ],
    );
  }

  Future<Uint8List?> _readFile(PlatformFile file, {int maxMb = 20}) async {
    final length = file.lengthSync() ?? await file.length();
    if (length == null || length > maxMb * 1024 * 1024) return null;
    try {
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickHeroMedia() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', 'webm'],
    );
    if (file == null) return;
    final bytes = await _readFile(file, maxMb: 30);
    if (bytes == null || !mounted) return;
    final lower = file.name.toLowerCase();
    setState(() {
      _heroMedia = bytes;
      _heroMediaName = file.name;
      _heroIsVideo = lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.webm');
    });
  }

  Future<void> _pickClassicImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await _readFile(file);
    if (bytes != null && mounted) setState(() => _classicImage = bytes);
  }

  Future<void> _pickWorkImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await _readFile(file);
    if (bytes != null && mounted) setState(() => _workImage = bytes);
  }

  AdminHomeContent _build(AdminContentPublishStatus status) {
    return AdminHomeContent(
      hero: AdminHeroContent(
        mainText: _mainText.text.trim(),
        subText: _subText.text.trim(),
        buttonText: _buttonText.text.trim(),
        buttonRoute: _buttonRoute.text.trim(),
        visible: _heroVisible,
        order: int.tryParse(_order.text) ?? 1,
        mediaName: _heroMediaName,
        mediaBase64: _heroMedia == null ? null : base64Encode(_heroMedia!),
        isVideo: _heroIsVideo,
      ),
      classicVisible: _classicVisible,
      workVisible: _workVisible,
      classicImageBase64:
          _classicImage == null ? null : base64Encode(_classicImage!),
      workImageBase64: _workImage == null ? null : base64Encode(_workImage!),
      newArrivalProductIds: _newArrivalIds.toList(),
      publishStatus: status,
      updatedAt: DateTime.now(),
    );
  }

  void _save(AdminContentPublishStatus status) {
    ref.read(homeContentViewModelProvider.notifier).save(_build(status));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == AdminContentPublishStatus.draft
              ? '홈페이지 콘텐츠를 임시저장했습니다.'
              : '홈페이지 콘텐츠를 게시했습니다.',
        ),
      ),
    );
  }

  void _preview() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 8,
                  child: Container(
                    color: AdminTheme.darkBrown,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_heroMedia != null && !_heroIsVideo)
                          Image.memory(_heroMedia!, fit: BoxFit.cover),
                        Container(color: Colors.black.withValues(alpha: 0.24)),
                        Padding(
                          padding: const EdgeInsets.all(42),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _subText.text,
                                style: AdminTypography.label(
                                  fontSize: 9,
                                  color: AdminTheme.background,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _mainText.text,
                                style: AdminTypography.serif(
                                  fontSize: 48,
                                  height: 0.92,
                                  color: AdminTheme.background,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _buttonText.text,
                                style: AdminTypography.label(
                                  fontSize: 10,
                                  color: AdminTheme.background,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Text(
                    '신규 상품  /  ${_newArrivalIds.length}개 노출',
                    style: AdminTypography.label(fontSize: 10),
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
