import 'dart:convert';
import 'dart:typed_data';

import 'package:deux_lapins_manager/app/app_routes.dart';
import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/utils/formatters.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/ui/dashboard/dashboard_view_model.dart';
import 'package:deux_lapins_manager/ui/inventory/inventory_view_model.dart';
import 'package:deux_lapins_manager/ui/products/products_view_model.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductCreatePage extends ConsumerStatefulWidget {
  const ProductCreatePage({
    super.key,
    this.productId,
  });

  final String? productId;

  bool get editing => productId != null;

  @override
  ConsumerState<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends ConsumerState<ProductCreatePage> {
  static const _sizeOptions = ['XS', 'S', 'M', 'L', 'XL', 'FREE'];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _season = TextEditingController(text: 'AW26');
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _material = TextEditingController();
  final _colors = TextEditingController();
  final _fit = TextEditingController();
  final _detail = TextEditingController();
  final _care = TextEditingController();

  final Set<String> _sizes = {'M'};
  final Map<String, int> _optionStock = {};

  Uint8List? _mainImageBytes;
  final List<Uint8List> _detailImages = [];

  AdminProductLine _line = AdminProductLine.classic;
  AdminProductStatus _status = AdminProductStatus.selling;
  bool _isBest = false;
  bool _isPremium = false;
  AdminProduct? _editingProduct;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    for (final controller in [
      _name,
      _season,
      _price,
      _description,
      _material,
      _colors,
      _fit,
      _detail,
      _care,
    ]) {
      controller.addListener(_refresh);
    }

    if (widget.editing) {
      final product = ref
          .read(productsViewModelProvider.notifier)
          .getById(widget.productId!);
      if (product != null) {
        _editingProduct = product;
        _name.text = product.name;
        _sku.text = product.sku;
        _season.text = product.season;
        _price.text = product.price.toString();
        _description.text = product.description;
        _material.text = product.material;
        _colors.text = product.colors.join(', ');
        _fit.text = product.fit;
        _detail.text = product.detail;
        _care.text = product.care;
        _line = product.line;
        _status = product.status;
        _isBest = product.isBest;
        _isPremium = product.isPremium;
        _sizes
          ..clear()
          ..addAll(product.sizes);

        for (final item in product.inventory) {
          _optionStock[
          _stockKey(
            item.color,
            item.size,
          )
          ] = item.quantity;
        }

        if (product.mainImageBase64?.isNotEmpty == true) {
          try {
            _mainImageBytes = base64Decode(product.mainImageBase64!);
          } catch (_) {}
        }
        for (final encoded in product.detailImageBase64) {
          try {
            _detailImages.add(base64Decode(encoded));
          } catch (_) {}
        }
      }
    } else {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      _sku.text = 'DL-${now.substring(now.length - 7)}';
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _season,
      _price,
      _description,
      _material,
      _colors,
      _fit,
      _detail,
      _care,
    ]) {
      controller.removeListener(_refresh);
    }
    _name.dispose();
    _sku.dispose();
    _season.dispose();
    _price.dispose();
    _description.dispose();
    _material.dispose();
    _colors.dispose();
    _fit.dispose();
    _detail.dispose();
    _care.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 1120;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            twoColumn ? 32 : 22,
            32,
            twoColumn ? 32 : 22,
            72,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pageHeader(context),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: twoColumn
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _basicSection(),
                                  const SizedBox(height: 20),
                                  _mediaSection(),
                                  const SizedBox(height: 20),
                                  _detailSection(),
                                  const SizedBox(height: 20),
                                  _optionSection(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 360,
                              child: Column(
                                children: [
                                  _publishSection(),
                                  const SizedBox(height: 20),
                                  _previewSection(),
                                  const SizedBox(height: 20),
                                  _actionSection(context),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _basicSection(),
                            const SizedBox(height: 18),
                            _mediaSection(),
                            const SizedBox(height: 18),
                            _detailSection(),
                            const SizedBox(height: 18),
                            _optionSection(),
                            const SizedBox(height: 18),
                            _publishSection(),
                            const SizedBox(height: 18),
                            _previewSection(),
                            const SizedBox(height: 18),
                            _actionSection(context),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pageHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '판매 관리 / 상품 등록',
                style: AdminTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.7,
                  color: AdminTheme.muted,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.editing ? '상품 수정' : '새 상품 등록',
                style: AdminTypography.serif(fontSize: 48, height: 0.95),
              ),
              const SizedBox(height: 9),
              Text(
                '상품 정보, 옵션, 이미지와 게시상태를 한 화면에서 관리합니다.',
                style: AdminTypography.body(
                  fontSize: 11.5,
                  color: AdminTheme.muted,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go(AdminRoutePath.products),
          icon: const Icon(Icons.arrow_back, size: 14),
          label: const Text('목록으로'),
        ),
      ],
    );
  }

  Widget _basicSection() {
    return _Section(
      index: '01',
      title: '기본 정보',
      description: '스토어에 노출될 상품의 기본 정보를 입력합니다.',
      child: Column(
        children: [
          _responsivePair(
            _field(
              label: '상품명',
              required: true,
              child: TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  hintText: '예: 헤리티지 울 블루종',
                ),
                validator: _requiredValidator,
              ),
            ),
            _field(
              label: '상품코드',
              required: true,
              child: TextFormField(
                controller: _sku,
                decoration: const InputDecoration(hintText: 'DL-AW26-001'),
                validator: _requiredValidator,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _responsivePair(
            _field(
              label: '라인',
              required: true,
              child: Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: '클래식',
                      selected: _line == AdminProductLine.classic,
                      onTap: () =>
                          setState(() => _line = AdminProductLine.classic),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ChoiceButton(
                      label: '워크',
                      selected: _line == AdminProductLine.work,
                      onTap: () => setState(() => _line = AdminProductLine.work),
                    ),
                  ),
                ],
              ),
            ),
            _field(
              label: '시즌',
              required: true,
              child: TextFormField(
                controller: _season,
                decoration: const InputDecoration(hintText: 'AW26'),
                validator: _requiredValidator,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '가격',
            required: true,
            suffix: '원',
            child: TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: '0'),
              validator: _positiveNumberValidator,
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '상품 설명',
            required: true,
            child: TextFormField(
              controller: _description,
              maxLines: 5,
              maxLength: 800,
              decoration: const InputDecoration(
                hintText: '상품의 핵심 실루엣과 특징을 입력해주세요.',
              ),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '소재',
            required: true,
            child: TextFormField(
              controller: _material,
              decoration: const InputDecoration(
                hintText: '예: 울 90%, 나일론 10%',
              ),
              validator: _requiredValidator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaSection() {
    return _Section(
      index: '02',
      title: '상품 이미지',
      description: '대표 이미지 1장과 상세 이미지를 등록합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            label: '대표 이미지',
            required: true,
            child: InkWell(
              onTap: _pickMainImage,
              child: Container(
                width: double.infinity,
                height: 250,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AdminTheme.surface,
                  border: Border.all(color: AdminTheme.line),
                ),
                child: _mainImageBytes == null
                    ? _uploadPlaceholder('대표 이미지 선택')
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_mainImageBytes!, fit: BoxFit.cover),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: _blackLabel('대표'),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton.filled(
                              onPressed: () =>
                                  setState(() => _mainImageBytes = null),
                              icon: const Icon(Icons.close, size: 15),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _field(
            label: '상세 이미지',
            description: '상세 이미지는 최대 8장까지 등록할 수 있습니다.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDetailImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                  label: const Text('상세 이미지 추가'),
                ),
                if (_detailImages.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_detailImages.length, (index) {
                      return SizedBox(
                        width: 120,
                        child: AspectRatio(
                          aspectRatio: 0.78,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AdminTheme.line),
                                ),
                                child: Image.memory(
                                  _detailImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: IconButton.filled(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => setState(
                                    () => _detailImages.removeAt(index),
                                  ),
                                  icon: const Icon(Icons.close, size: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection() {
    return _Section(
      index: '03',
      title: '상품 상세',
      description: '상품 상세 페이지에서 사용할 핏, 디테일, 관리 방법을 입력합니다.',
      child: Column(
        children: [
          _field(
            label: '핏',
            required: true,
            child: TextFormField(
              controller: _fit,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '예: 여유 있는 핏 / 드롭 숄더',
              ),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '디테일',
            required: true,
            child: TextFormField(
              controller: _detail,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '봉제, 여밈, 포켓 등 주요 디테일',
              ),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '관리 방법',
            required: true,
            child: TextFormField(
              controller: _care,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '세탁 및 관리 방법',
              ),
              validator: _requiredValidator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionSection() {
    return _Section(
      index: '04',
      title: '옵션 및 재고',
      description: '컬러와 사이즈를 설정하고 옵션별 초기 재고를 입력합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            label: '컬러',
            required: true,
            description: '여러 컬러는 쉼표(,)로 구분합니다.',
            child: TextFormField(
              controller: _colors,
              decoration: const InputDecoration(
                hintText: '블랙, 차콜, 아이보리',
              ),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(height: 24),
          _field(
            label: '사이즈',
            required: true,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sizeOptions.map((size) {
                final selected = _sizes.contains(size);

                return _ChoiceButton(
                  label: size,
                  selected: selected,
                  compact: true,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _sizes.remove(size);
                      } else {
                        _sizes.add(size);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          _field(
            label: '초기 재고',
            required: true,
            description: '컬러 / 사이즈별 초기 재고를 입력합니다. 등록 후 재고 관리에서도 수정할 수 있습니다.',
            child: _stockMatrix(),
          ),
        ],
      ),
    );
  }

  Widget _stockMatrix() {
    final colors = _parsedColors();
    final sizes = _sizes.toList();

    if (colors.isEmpty || sizes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          border: Border.all(
            color: AdminTheme.line,
          ),
        ),
        child: Text(
          '컬러와 사이즈를 먼저 설정하면 재고 입력란이 생성됩니다.',
          style: AdminTypography.body(
            fontSize: 11.5,
            color: AdminTheme.muted,
          ),
        ),
      );
    }

    final totalStock = colors.fold<int>(
      0,
          (total, color) {
        return total +
            sizes.fold<int>(
              0,
                  (sum, size) {
                return sum + _stockValue(color, size);
              },
            );
      },
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AdminTheme.line,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: AdminTheme.surface,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '컬러',
                    style: AdminTypography.label(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: AdminTheme.muted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '사이즈',
                    style: AdminTypography.label(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: AdminTheme.muted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    '재고',
                    textAlign: TextAlign.right,
                    style: AdminTypography.label(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: AdminTheme.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...colors.expand(
                (color) => sizes.map(
                  (size) => _stockRow(
                color: color,
                size: size,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AdminTheme.line,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '총 재고',
                  style: AdminTypography.label(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalStock개',
                  style: AdminTypography.label(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockRow({
    required String color,
    required String size,
  }) {
    final key = _stockKey(
      color,
      size,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AdminTheme.line,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ProductColorBadge(colorName: color),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              size,
              style: AdminTypography.body(
                fontSize: 11,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: TextFormField(
              key: ValueKey(
                'stock-$key',
              ),
              initialValue: '${_stockValue(color, size)}',
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: '개',
              ),
              onChanged: (value) {
                _optionStock[key] =
                    int.tryParse(value) ?? 0;

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  String _stockKey(
      String color,
      String size,
      ) {
    return '$color::$size';
  }

  int _stockValue(
      String color,
      String size,
      ) {
    final key = _stockKey(
      color,
      size,
    );

    final current =
    _optionStock[key];

    if (current != null) {
      return current;
    }

    for (final item
    in _editingProduct?.inventory ??
        const <AdminInventoryItem>[]) {
      if (item.color == color &&
          item.size == size) {
        return item.quantity;
      }
    }

    return 0;
  }

  Widget _publishSection() {
    return _Section(
      index: '05',
      title: '게시 설정',
      description: '상품의 판매 상태와 스토어 노출 구분을 설정합니다.',
      dense: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final status in AdminProductStatus.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ChoiceButton(
                label: status.label,
                selected: _status == status,
                onTap: () => setState(() => _status = status),
              ),
            ),
          const Divider(height: 28),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('BEST 상품'),
            subtitle: const Text('BEST 목록과 홈페이지 베스트셀러에 노출'),
            value: _isBest,
            onChanged: (value) {
              setState(() => _isBest = value ?? false);
            },
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('PREMIUM 상품'),
            subtitle: const Text('PREMIUM 상품 목록에 노출'),
            value: _isPremium,
            onChanged: (value) {
              setState(() => _isPremium = value ?? false);
            },
          ),
        ],
      ),
    );
  }

  Widget _previewSection() {
    final price = int.tryParse(_price.text) ?? 0;
    final name = _name.text.trim().isEmpty ? '상품명' : _name.text.trim();

    return _Section(
      index: '06',
      title: '미리보기',
      description: '실제 스토어 카드 기준 미리보기입니다.',
      dense: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.78,
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AdminTheme.soft,
                border: Border.all(color: AdminTheme.line),
              ),
              child: _mainImageBytes == null
                  ? Center(
                      child: Text(
                        'DUEX LAPINS',
                        style: AdminTypography.serif(
                          fontSize: 26,
                          color: AdminTheme.muted,
                        ),
                      ),
                    )
                  : Image.memory(_mainImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'DUEX LAPINS  /  ${_line.label}',
            style: AdminTypography.label(
              fontSize: 9,
              letterSpacing: 1.2,
              color: AdminTheme.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AdminTypography.serif(fontSize: 25, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            price == 0 ? '₩0' : formatWon(price),
            style: AdminTypography.body(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: _saving
                ? null
                : () => _submit(context, AdminPublishStatus.published),
            child: _saving
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  )
                : Text(widget.editing ? '수정사항 게시' : '상품 게시'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _saving ? null : _showFullPreview,
            child: const Text('미리보기'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _saving
                ? null
                : () => _submit(context, AdminPublishStatus.draft),
            child: const Text('임시저장'),
          ),
          const SizedBox(height: 10),
          Text(
            '게시 상태의 상품은 홈페이지 연동 시 스토어에 바로 반영됩니다.',
            textAlign: TextAlign.center,
            style: AdminTypography.body(fontSize: 10.5, color: AdminTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _responsivePair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              first,
              const SizedBox(height: 24),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 24),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _field({
    required String label,
    required Widget child,
    bool required = false,
    String? suffix,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: AdminTypography.label(fontSize: 9, letterSpacing: 1.35),
            ),
            if (required) ...[
              const SizedBox(width: 5),
              Text(
                '*',
                style: AdminTypography.label(
                  fontSize: 9,
                  color: AdminTheme.danger,
                ),
              ),
            ],
            if (suffix != null) ...[
              const Spacer(),
              Text(
                suffix,
                style: AdminTypography.label(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  color: AdminTheme.muted,
                ),
              ),
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: AdminTypography.body(fontSize: 10.5, color: AdminTheme.muted),
          ),
        ],
        const SizedBox(height: 7),
        child,
      ],
    );
  }

  Widget _uploadPlaceholder(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined, size: 25),
        const SizedBox(height: 12),
        Text(
          text,
          style: AdminTypography.label(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '이미지 파일 / 10MB 이하',
          style: AdminTypography.label(
            fontSize: 9,
            color: AdminTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _blackLabel(String text) {
    return Container(
      color: AdminTheme.text,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        text,
        style: AdminTypography.label(
          fontSize: 9,
          color: AdminTheme.background,
        ),
      ),
    );
  }

  Future<Uint8List?> _readImage(PlatformFile file) async {
    final length = file.lengthSync() ?? await file.length();
    if (length == null || length > 10 * 1024 * 1024) return null;
    try {
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickMainImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await _readImage(file);
    if (!mounted) return;
    if (bytes == null) {
      _message('10MB 이하의 이미지 파일을 선택해주세요.');
      return;
    }
    setState(() => _mainImageBytes = bytes);
  }

  Future<void> _pickDetailImages() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty || !mounted) return;
    final available = 8 - _detailImages.length;
    if (available <= 0) {
      _message('상세 이미지는 최대 8장까지 등록할 수 있습니다.');
      return;
    }
    final selected = <Uint8List>[];
    for (final file in files.take(available)) {
      final bytes = await _readImage(file);
      if (bytes != null) selected.add(bytes);
    }
    if (!mounted) return;
    if (selected.isEmpty) {
      _message('10MB 이하의 이미지 파일을 선택해주세요.');
      return;
    }
    setState(() => _detailImages.addAll(selected));
  }

  List<String> _parsedColors() {
    return _colors.text
        .split(',')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  List<AdminInventoryItem> _buildInventory(
      List<String> colors,
      ) {
    final inventory = <AdminInventoryItem>[];

    for (final color in colors) {
      for (final size in _sizes) {
        AdminInventoryItem? existing;

        for (final item
        in _editingProduct?.inventory ??
            const <AdminInventoryItem>[]) {
          if (item.color == color &&
              item.size == size) {
            existing = item;
            break;
          }
        }

        inventory.add(
          AdminInventoryItem(
            color: color,
            size: size,
            quantity: _stockValue(
              color,
              size,
            ),
            lowStockThreshold:
            existing?.lowStockThreshold ?? 3,
          ),
        );
      }
    }

    return inventory;
  }

  Future<void> _submit(
    BuildContext context,
    AdminPublishStatus publishStatus,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_mainImageBytes == null &&
        (!widget.editing || _editingProduct?.mainImageBase64?.isNotEmpty == true)) {
      _message('대표 이미지를 등록해주세요.');
      return;
    }
    if (_sizes.isEmpty) {
      _message('사이즈를 1개 이상 선택해주세요.');
      return;
    }
    final colors = _parsedColors();
    if (colors.isEmpty) {
      _message('컬러를 1개 이상 입력해주세요.');
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final inventory = _buildInventory(colors);
    final totalStock = inventory.fold<int>(0, (sum, item) => sum + item.quantity);
    var status = _status;
    if (status == AdminProductStatus.selling && totalStock == 0) {
      status = AdminProductStatus.soldOut;
    }

    final product = AdminProduct(
      id: _editingProduct?.id ?? 'P${now.microsecondsSinceEpoch}',
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      line: _line,
      season: _season.text.trim().toUpperCase(),
      price: int.parse(_price.text),
      description: _description.text.trim(),
      material: _material.text.trim(),
      colors: colors,
      sizes: _sizes.toList(),
      fit: _fit.text.trim(),
      detail: _detail.text.trim(),
      care: _care.text.trim(),
      status: status,
      publishStatus: publishStatus,
      updatedAt: now,
      inventory: inventory,
      isBest: _isBest,
      isPremium: _isPremium,
      mainImageBase64: _mainImageBytes == null
          ? _editingProduct?.mainImageBase64
          : base64Encode(_mainImageBytes!),
      detailImageBase64: _detailImages.map(base64Encode).toList(),
    );

    try {
      await ref.read(productsViewModelProvider.notifier).saveProduct(product);

      ref.invalidate(inventoryViewModelProvider);
      ref.invalidate(dashboardViewModelProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publishStatus == AdminPublishStatus.draft
                ? '상품을 임시저장했습니다.'
                : widget.editing
                ? '상품 수정사항을 게시했습니다.'
                : '새 상품을 게시했습니다.',
          ),
        ),
      );

      context.go(AdminRoutePath.products);
    } catch (error) {
      if (!mounted) return;
      _message('상품 저장 실패: $error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showFullPreview() {
    final colors = _parsedColors();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('실제 화면 미리보기', style: AdminTypography.serif(fontSize: 38)),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 680;
                    final image = AspectRatio(
                      aspectRatio: 0.78,
                      child: Container(
                        color: AdminTheme.soft,
                        child: _mainImageBytes == null
                            ? const SizedBox.shrink()
                            : Image.memory(_mainImageBytes!, fit: BoxFit.cover),
                      ),
                    );
                    final copy = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_line.label}  /  ${_season.text.toUpperCase()}',
                          style: AdminTypography.label(
                            fontSize: 9,
                            color: AdminTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _name.text.isEmpty ? '상품명' : _name.text,
                          style: AdminTypography.serif(fontSize: 38),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatWon(int.tryParse(_price.text) ?? 0),
                          style: AdminTypography.body(fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _description.text,
                          style: AdminTypography.body(fontSize: 12),
                        ),
                        const SizedBox(height: 18),
                        Text('컬러  ${colors.join(' / ')}'),
                        const SizedBox(height: 8),
                        Text('사이즈  ${_sizes.join(' / ')}'),
                        const SizedBox(height: 22),
                        Text('핏', style: AdminTypography.label(fontSize: 9)),
                        const SizedBox(height: 6),
                        Text(_fit.text),
                        const SizedBox(height: 18),
                        Text('디테일', style: AdminTypography.label(fontSize: 9)),
                        const SizedBox(height: 6),
                        Text(_detail.text),
                        const SizedBox(height: 18),
                        Text('관리 방법', style: AdminTypography.label(fontSize: 9)),
                        const SizedBox(height: 6),
                        Text(_care.text),
                      ],
                    );
                    if (!wide) {
                      return Column(
                        children: [
                          image,
                          const SizedBox(height: 24),
                          copy,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: image),
                        const SizedBox(width: 30),
                        Expanded(child: copy),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return '필수 입력 항목입니다.';
    return null;
  }

  String? _positiveNumberValidator(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) return '0보다 큰 값을 입력해주세요.';
    return null;
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.index,
    required this.title,
    required this.description,
    required this.child,
    this.dense = false,
  });

  final String index;
  final String title;
  final String description;
  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 20 : 24),
      decoration: BoxDecoration(
        color: AdminTheme.background,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  '$index.',
                  style: AdminTypography.label(
                    fontSize: 9,
                    letterSpacing: 1.25,
                    color: AdminTheme.muted,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AdminTypography.serif(
                        fontSize: dense ? 27 : 31,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: AdminTypography.body(
                        fontSize: 11,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: dense ? 20 : 28),
          const Divider(height: 1),
          SizedBox(height: dense ? 20 : 28),
          child,
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 13 : 16,
          vertical: compact ? 10 : 13,
        ),
        decoration: BoxDecoration(
          color: selected ? AdminTheme.text : Colors.transparent,
          border: Border.all(
            color: selected ? AdminTheme.text : AdminTheme.line,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AdminTypography.label(
            fontSize: compact ? 8 : 8.5,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
            color: selected ? AdminTheme.background : AdminTheme.text,
          ),
        ),
      ),
    );
  }
}
