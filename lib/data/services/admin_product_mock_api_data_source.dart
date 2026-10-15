import 'dart:convert';

import 'package:deux_lapins_manager/domain/models/admin_product.dart';

class AdminProductApiException implements Exception {
  const AdminProductApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class _NotFoundException implements Exception {
  const _NotFoundException(this.message);

  final String message;
}

abstract interface class AdminProductApiDataSource {
  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]);
}

class AdminProductMockApiDataSource
    implements AdminProductApiDataSource {
  AdminProductMockApiDataSource(this._products);

  final List<AdminProduct> _products;
  final Set<String> _deletedIds = <String>{};

  bool isDeleted(String productId) =>
      _deletedIds.contains(productId);

  @override
  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 80),
    );

    final payload = body == null
        ? null
        : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;

    try {
      final data = _dispatch(
        method.toUpperCase(),
        path,
        payload,
      );

      return jsonDecode(
        jsonEncode({
          'success': true,
          'data': data,
        }),
      ) as Map<String, dynamic>;
    } on FormatException catch (error) {
      return _failure(
        'VALIDATION_ERROR',
        error.message,
      );
    } on _NotFoundException catch (error) {
      return _failure(
        'NOT_FOUND',
        error.message,
      );
    } on StateError catch (error) {
      return _failure(
        'CONFLICT',
        error.message.toString(),
      );
    }
  }

  Map<String, dynamic> _failure(
      String code,
      String message,
      ) {
    return {
      'success': false,
      'error': {
        'code': code,
        'message': message,
      },
    };
  }

  Object? _dispatch(
      String method,
      String path,
      Map<String, dynamic>? body,
      ) {
    if (method == 'GET' && path == '/products') {
      return _products
          .where((product) => !isDeleted(product.id))
          .map(AdminProductApiCodec.toJson)
          .toList();
    }

    final segments = Uri.parse(path).pathSegments;

    if (segments.isEmpty || segments.first != 'products') {
      throw const FormatException(
        '지원하지 않는 상품 API 경로입니다.',
      );
    }

    if (method == 'POST' && segments.length == 1) {
      if (body == null) {
        throw const FormatException(
          '상품 데이터가 없습니다.',
        );
      }

      final product = AdminProductApiCodec.fromJson(body);

      _validateProduct(product);

      if (_products.any(
            (entry) => entry.id == product.id,
      )) {
        throw StateError('이미 존재하는 상품 ID입니다.');
      }

      _products.insert(
        0,
        product.copyWith(updatedAt: DateTime.now()),
      );

      return AdminProductApiCodec.toJson(_products.first);
    }

    if (segments.length < 2) {
      throw const FormatException(
        '상품 ID가 필요합니다.',
      );
    }

    final productId = segments[1];

    final index = _products.indexWhere(
          (entry) =>
      entry.id == productId && !isDeleted(entry.id),
    );

    if (index == -1) {
      throw _NotFoundException(
        '상품을 찾을 수 없습니다: $productId',
      );
    }

    if (method == 'GET' && segments.length == 2) {
      return AdminProductApiCodec.toJson(
        _products[index],
      );
    }

    if (method == 'PUT' && segments.length == 2) {
      if (body == null) {
        throw const FormatException(
          '수정 데이터가 없습니다.',
        );
      }

      final product = AdminProductApiCodec.fromJson(body);

      if (product.id != productId) {
        throw const FormatException(
          '상품 ID가 일치하지 않습니다.',
        );
      }

      _validateProduct(
        product,
        excludeId: productId,
      );

      _products[index] = product.copyWith(
        updatedAt: DateTime.now(),
      );

      return AdminProductApiCodec.toJson(
        _products[index],
      );
    }

    if (method == 'PATCH' &&
        segments.length == 3 &&
        segments[2] == 'inventory') {
      final color =
      (body?['color'] as String?)?.trim().toUpperCase();

      final size =
      (body?['size'] as String?)?.trim().toUpperCase();

      final quantity = body?['quantity'];

      if (color == null ||
          color.isEmpty ||
          size == null ||
          size.isEmpty ||
          quantity is! int ||
          quantity < 0) {
        throw const FormatException(
          '옵션과 0 이상의 재고 수량을 확인해주세요.',
        );
      }

      final product = _products[index];

      if (!product.inventory.any(
            (item) =>
        item.color.trim().toUpperCase() == color &&
            item.size.trim().toUpperCase() == size,
      )) {
        throw const _NotFoundException(
          '존재하지 않는 색상·사이즈 옵션입니다.',
        );
      }

      _products[index] = product.copyWith(
        inventory: product.inventory.map((item) {
          if (item.color.trim().toUpperCase() == color &&
              item.size.trim().toUpperCase() == size) {
            return item.copyWith(quantity: quantity);
          }

          return item;
        }).toList(),
        updatedAt: DateTime.now(),
      );

      return AdminProductApiCodec.toJson(
        _products[index],
      );
    }

    if (method == 'DELETE' && segments.length == 2) {
      _deletedIds.add(productId);

      return {
        'id': productId,
        'deleted': true,
      };
    }

    throw const FormatException(
      '지원하지 않는 상품 API 요청입니다.',
    );
  }

  void _validateProduct(
      AdminProduct product, {
        String? excludeId,
      }) {
    if (product.id.trim().isEmpty ||
        product.name.trim().isEmpty ||
        product.sku.trim().isEmpty ||
        product.price < 0) {
      throw const FormatException(
        '상품명·상품코드·가격을 확인해주세요.',
      );
    }

    if (_products.any(
          (entry) =>
      !isDeleted(entry.id) &&
          entry.id != excludeId &&
          entry.sku.trim().toUpperCase() ==
              product.sku.trim().toUpperCase(),
    )) {
      throw StateError('이미 등록된 상품코드입니다.');
    }

    if (product.colors.isEmpty ||
        product.sizes.isEmpty ||
        product.inventory.isEmpty) {
      throw const FormatException(
        '색상·사이즈·재고 옵션을 등록해주세요.',
      );
    }

    final seen = <String>{};

    for (final item in product.inventory) {
      final color = item.color.trim().toUpperCase();
      final size = item.size.trim().toUpperCase();

      if (item.quantity < 0 ||
          item.lowStockThreshold < 0 ||
          color.isEmpty ||
          size.isEmpty ||
          !seen.add('$color|$size')) {
        throw const FormatException(
          '옵션 중복 또는 재고 수량을 확인해주세요.',
        );
      }

      if (!product.colors.any(
            (c) => c.trim().toUpperCase() == color,
      ) ||
          !product.sizes.any(
                (s) => s.trim().toUpperCase() == size,
          )) {
        throw const FormatException(
          '상품에 등록되지 않은 색상·사이즈 옵션이 있습니다.',
        );
      }
    }
  }
}

class AdminProductApiCodec {
  static Map<String, dynamic> toJson(
      AdminProduct product,
      ) =>
      {
        'id': product.id,
        'product_code': product.sku,
        'name': product.name,
        'line': product.line.name,
        'season': product.season,
        'price': product.price,
        'description': product.description,
        'material': product.material,
        'colors': product.colors,
        'sizes': product.sizes,
        'fit': product.fit,
        'detail': product.detail,
        'care': product.care,
        'is_best': product.isBest,
        'is_premium': product.isPremium,
        'sale_status': switch (product.status) {
          AdminProductStatus.selling => 'selling',
          AdminProductStatus.soldOut => 'sold_out',
          AdminProductStatus.hidden => 'hidden',
        },
        'publish_status': product.publishStatus.name,
        'updated_at':
        product.updatedAt.toUtc().toIso8601String(),
        'main_image_base64': product.mainImageBase64,
        'detail_image_base64': product.detailImageBase64,
        'variants': product.inventory.map((item) {
          return {
            'id':
            '${product.id}:${item.color.trim().toUpperCase()}:${item.size.trim().toUpperCase()}',
            'product_id': product.id,
            'color_name': item.color,
            'size_name': item.size,
            'stock_quantity': item.quantity,
            'low_stock_threshold': item.lowStockThreshold,
            'is_active': true,
          };
        }).toList(),
      };

  static AdminProduct fromJson(
      Map<String, dynamic> json,
      ) {
    final variants =
    (json['variants'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return AdminProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['product_code'] as String,
      line: AdminProductLine.values.byName(
        json['line'] as String,
      ),
      season: json['season'] as String,
      price: json['price'] as int,
      description: json['description'] as String,
      material: json['material'] as String,
      colors: (json['colors'] as List<dynamic>).cast<String>(),
      sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      fit: json['fit'] as String,
      detail: json['detail'] as String,
      care: json['care'] as String,
      isBest: json['is_best'] == true,
      isPremium: json['is_premium'] == true,
      status: switch (json['sale_status']) {
        'selling' => AdminProductStatus.selling,
        'sold_out' => AdminProductStatus.soldOut,
        'hidden' => AdminProductStatus.hidden,
        _ => throw const FormatException(
          '판매 상태 코드가 올바르지 않습니다.',
        ),
      },
      publishStatus: AdminPublishStatus.values.byName(
        json['publish_status'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String,
      ),
      inventory: variants.map((row) {
        return AdminInventoryItem(
          color: row['color_name'] as String,
          size: row['size_name'] as String,
          quantity: row['stock_quantity'] as int,
          lowStockThreshold:
          row['low_stock_threshold'] as int,
        );
      }).toList(),
      mainImageBase64: json['main_image_base64'] as String?,
      detailImageBase64:
      (json['detail_image_base64'] as List<dynamic>)
          .cast<String>(),
    );
  }
}