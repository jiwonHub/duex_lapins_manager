import 'dart:convert';

import 'package:deux_lapins_manager/domain/models/admin_home_content.dart';
import 'package:deux_lapins_manager/domain/models/admin_journal.dart';
import 'package:deux_lapins_manager/domain/models/admin_product.dart';
import 'package:deux_lapins_manager/domain/models/admin_store_settings.dart';

class AdminEditorialApiException implements Exception {
  const AdminEditorialApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AdminEditorialMockApiDataSource {
  AdminEditorialMockApiDataSource({
    required AdminHomeContent Function() getHome,
    required void Function(AdminHomeContent) setHome,
    required List<AdminJournal> journals,
    required AdminStoreSettings Function() getSettings,
    required void Function(AdminStoreSettings) setSettings,
    required List<AdminProduct> Function() getProducts,
  })  : _getHome = getHome,
        _setHome = setHome,
        _journals = journals,
        _getSettings = getSettings,
        _setSettings = setSettings,
        _getProducts = getProducts;

  final AdminHomeContent Function() _getHome;
  final void Function(AdminHomeContent) _setHome;
  final List<AdminJournal> _journals;
  final AdminStoreSettings Function() _getSettings;
  final void Function(AdminStoreSettings) _setSettings;
  final List<AdminProduct> Function() _getProducts;

  Future<Map<String, dynamic>> request(
      String method,
      String path, [
        Map<String, dynamic>? body,
      ]) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 80),
    );

    final input = body == null
        ? null
        : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;

    try {
      final data = _dispatch(
        method.toUpperCase(),
        Uri.parse(path),
        input,
      );

      return jsonDecode(
        jsonEncode({
          'success': true,
          'data': data,
        }),
      ) as Map<String, dynamic>;
    } on AdminEditorialApiException catch (error) {
      return {
        'success': false,
        'error': {
          'code': error.code,
          'message': error.message,
        },
      };
    } on FormatException catch (error) {
      return {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': error.message,
        },
      };
    }
  }

  Object? _dispatch(
      String method,
      Uri uri,
      Map<String, dynamic>? body,
      ) {
    final parts = uri.pathSegments;

    if (uri.path == '/admin/home-content') {
      if (method == 'GET') {
        return AdminEditorialCodec.homeToJson(_getHome());
      }

      if (method == 'PUT') {
        final home = AdminEditorialCodec.homeFromJson(
          _requiredBody(body),
        );

        if (home.hero.order < 0 ||
            (home.publishStatus ==
                AdminContentPublishStatus.published &&
                home.hero.visible &&
                home.hero.mainText.trim().isEmpty)) {
          throw const AdminEditorialApiException(
            'VALIDATION_ERROR',
            '메인 문구 또는 노출 순서를 확인해주세요.',
          );
        }

        _validateProducts(home.newArrivalProductIds);

        _setHome(
          home.copyWith(updatedAt: DateTime.now()),
        );

        return AdminEditorialCodec.homeToJson(_getHome());
      }
    }

    if (uri.path == '/admin/journals') {
      if (method == 'GET') {
        return _journals
            .map(AdminEditorialCodec.journalToJson)
            .toList();
      }

      if (method == 'POST') {
        final journal = AdminEditorialCodec.journalFromJson(
          _requiredBody(body),
        );

        _validateJournal(journal);

        if (_journals.any((item) => item.id == journal.id)) {
          throw const AdminEditorialApiException(
            'CONFLICT',
            '이미 존재하는 저널 ID입니다.',
          );
        }

        _journals.insert(0, journal);

        return AdminEditorialCodec.journalToJson(journal);
      }
    }

    if (parts.length == 3 &&
        parts[0] == 'admin' &&
        parts[1] == 'journals') {
      final index = _journals.indexWhere(
            (item) => item.id == parts[2],
      );

      if (index < 0) {
        throw const AdminEditorialApiException(
          'NOT_FOUND',
          '저널을 찾을 수 없습니다.',
        );
      }

      if (method == 'GET') {
        return AdminEditorialCodec.journalToJson(
          _journals[index],
        );
      }

      if (method == 'PUT') {
        final journal = AdminEditorialCodec.journalFromJson(
          _requiredBody(body),
        );

        if (journal.id != parts[2]) {
          throw const AdminEditorialApiException(
            'VALIDATION_ERROR',
            '저널 ID가 일치하지 않습니다.',
          );
        }

        _validateJournal(journal);

        final old = _journals[index];

        final updated = old.copyWith(
          title: journal.title,
          category: journal.category,
          body: journal.body,
          relatedProductIds: journal.relatedProductIds,
          publishAt: journal.publishAt,
          publishStatus: journal.publishStatus,
          coverImageBase64: journal.coverImageBase64,
          additionalImageBase64: journal.additionalImageBase64,
        );

        _journals[index] = updated;

        return AdminEditorialCodec.journalToJson(updated);
      }
    }

    if (uri.path == '/admin/store-settings') {
      if (method == 'GET') {
        return AdminEditorialCodec.settingsToJson(
          _getSettings(),
        );
      }

      if (method == 'PUT') {
        final settings = AdminEditorialCodec.settingsFromJson(
          _requiredBody(body),
        );

        if (settings.shippingFee < 0 ||
            settings.freeShippingThreshold < 0 ||
            settings.carrier.trim().isEmpty ||
            settings.originAddress.trim().isEmpty ||
            settings.returnAddress.trim().isEmpty ||
            settings.csPhone.trim().isEmpty ||
            !RegExp(
              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
            ).hasMatch(settings.csEmail)) {
          throw const AdminEditorialApiException(
            'VALIDATION_ERROR',
            '배송비·택배사·주소·고객센터 정보를 확인해주세요.',
          );
        }

        _setSettings(settings);

        return AdminEditorialCodec.settingsToJson(
          _getSettings(),
        );
      }
    }

    // 관리자 데이터와 공개 데이터를 구분한다.
    // 별도 실행되는 쇼핑몰 앱과 메모리가 자동 공유되지는 않는다.

    if (method == 'GET' &&
        uri.path == '/public/home-content') {
      final home = _getHome();

      if (home.publishStatus !=
          AdminContentPublishStatus.published) {
        return null;
      }

      final publishedIds = _getProducts()
          .where(
            (p) =>
        p.publishStatus == AdminPublishStatus.published &&
            p.status != AdminProductStatus.hidden,
      )
          .map((p) => p.id)
          .toSet();

      final json = AdminEditorialCodec.homeToJson(home);

      json['new_arrival_product_ids'] = home.newArrivalProductIds
          .where(publishedIds.contains)
          .toList();

      return json;
    }

    if (method == 'GET' &&
        uri.path == '/public/journals') {
      final now = DateTime.now();

      final publishedIds = _getProducts()
          .where(
            (p) =>
        p.publishStatus == AdminPublishStatus.published &&
            p.status != AdminProductStatus.hidden,
      )
          .map((p) => p.id)
          .toSet();

      return _journals
          .where(
            (journal) =>
        journal.publishStatus ==
            AdminContentPublishStatus.published &&
            !journal.publishAt.isAfter(now),
      )
          .map((journal) {
        final row = AdminEditorialCodec.journalToJson(journal);

        row['related_product_ids'] = journal.relatedProductIds
            .where(publishedIds.contains)
            .toList();

        return row;
      }).toList();
    }

    throw const AdminEditorialApiException(
      'NOT_FOUND',
      '지원하지 않는 API 요청입니다.',
    );
  }

  Map<String, dynamic> _requiredBody(
      Map<String, dynamic>? body,
      ) {
    if (body == null) {
      throw const AdminEditorialApiException(
        'VALIDATION_ERROR',
        '요청 데이터가 없습니다.',
      );
    }

    return body;
  }

  void _validateProducts(List<String> ids) {
    if (ids.length != ids.toSet().length) {
      throw const AdminEditorialApiException(
        'VALIDATION_ERROR',
        '관련 상품이 중복되었습니다.',
      );
    }

    final existingIds = _getProducts()
        .map((p) => p.id)
        .toSet();

    if (ids.any((id) => !existingIds.contains(id))) {
      throw const AdminEditorialApiException(
        'NOT_FOUND',
        '존재하지 않는 관련 상품이 있습니다.',
      );
    }
  }

  void _validateJournal(AdminJournal journal) {
    if (journal.id.trim().isEmpty ||
        journal.title.trim().isEmpty ||
        journal.body.trim().isEmpty ||
        journal.title.length > 255 ||
        !const ['JOURNAL', 'PEOPLE'].contains(journal.category)) {
      throw const AdminEditorialApiException(
        'VALIDATION_ERROR',
        '저널 제목·본문·분류를 확인해주세요.',
      );
    }

    _validateProducts(journal.relatedProductIds);
  }
}

class AdminEditorialCodec {
  static Map<String, dynamic> homeToJson(
      AdminHomeContent home,
      ) =>
      {
        'hero': {
          'main_text': home.hero.mainText,
          'sub_text': home.hero.subText,
          'button_text': home.hero.buttonText,
          'button_route': home.hero.buttonRoute,
          'is_visible': home.hero.visible,
          'sort_order': home.hero.order,
          'media_name': home.hero.mediaName,
          'media_base64': home.hero.mediaBase64,
          'is_video': home.hero.isVideo,
        },
        'classic_visible': home.classicVisible,
        'work_visible': home.workVisible,
        'classic_image_base64': home.classicImageBase64,
        'work_image_base64': home.workImageBase64,
        'new_arrival_product_ids': home.newArrivalProductIds,
        'publish_status': home.publishStatus.name,
        'updated_at': home.updatedAt.toIso8601String(),
      };

  static AdminHomeContent homeFromJson(
      Map<String, dynamic> row,
      ) {
    final hero = Map<String, dynamic>.from(
      row['hero'] as Map,
    );

    return AdminHomeContent(
      hero: AdminHeroContent(
        mainText: hero['main_text'] as String,
        subText: hero['sub_text'] as String,
        buttonText: hero['button_text'] as String,
        buttonRoute: hero['button_route'] as String,
        visible: hero['is_visible'] as bool,
        order: hero['sort_order'] as int,
        mediaName: hero['media_name'] as String? ?? '',
        mediaBase64: hero['media_base64'] as String?,
        isVideo: hero['is_video'] as bool? ?? false,
      ),
      classicVisible: row['classic_visible'] as bool,
      workVisible: row['work_visible'] as bool,
      classicImageBase64:
      row['classic_image_base64'] as String?,
      workImageBase64:
      row['work_image_base64'] as String?,
      newArrivalProductIds:
      (row['new_arrival_product_ids'] as List).cast<String>(),
      publishStatus: AdminContentPublishStatus.values.byName(
        row['publish_status'] as String,
      ),
      updatedAt: DateTime.parse(
        row['updated_at'] as String,
      ),
    );
  }

  static Map<String, dynamic> journalToJson(
      AdminJournal journal,
      ) =>
      {
        'id': journal.id,
        'title': journal.title,
        'category': journal.category,
        'body': journal.body,
        'related_product_ids': journal.relatedProductIds,
        'created_at': journal.createdAt.toIso8601String(),
        'publish_at': journal.publishAt.toIso8601String(),
        'publish_status': journal.publishStatus.name,
        'cover_image_base64': journal.coverImageBase64,
        'additional_image_base64': journal.additionalImageBase64,
      };

  static AdminJournal journalFromJson(
      Map<String, dynamic> row,
      ) =>
      AdminJournal(
        id: row['id'] as String,
        title: row['title'] as String,
        category: row['category'] as String,
        body: row['body'] as String,
        relatedProductIds:
        (row['related_product_ids'] as List).cast<String>(),
        createdAt: DateTime.parse(
          row['created_at'] as String,
        ),
        publishAt: DateTime.parse(
          row['publish_at'] as String,
        ),
        publishStatus: AdminContentPublishStatus.values.byName(
          row['publish_status'] as String,
        ),
        coverImageBase64: row['cover_image_base64'] as String?,
        additionalImageBase64:
        (row['additional_image_base64'] as List).cast<String>(),
      );

  static Map<String, dynamic> settingsToJson(
      AdminStoreSettings settings,
      ) =>
      {
        'shipping_fee': settings.shippingFee,
        'free_shipping_threshold': settings.freeShippingThreshold,
        'carrier': settings.carrier,
        'origin_address': settings.originAddress,
        'return_address': settings.returnAddress,
        'cs_phone': settings.csPhone,
        'cs_email': settings.csEmail,
        'cs_hours': settings.csHours,
        'default_guide': settings.defaultGuide,
      };

  static AdminStoreSettings settingsFromJson(
      Map<String, dynamic> row,
      ) =>
      AdminStoreSettings(
        shippingFee: row['shipping_fee'] as int,
        freeShippingThreshold: row['free_shipping_threshold'] as int,
        carrier: row['carrier'] as String,
        originAddress: row['origin_address'] as String,
        returnAddress: row['return_address'] as String,
        csPhone: row['cs_phone'] as String,
        csEmail: row['cs_email'] as String,
        csHours: row['cs_hours'] as String,
        defaultGuide: row['default_guide'] as String,
      );
}