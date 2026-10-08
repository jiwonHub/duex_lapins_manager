import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';

class AdminJournal {
  const AdminJournal({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.relatedProductIds,
    required this.createdAt,
    required this.publishAt,
    required this.publishStatus,
    this.coverImageBase64,
    this.additionalImageBase64 = const [],
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final List<String> relatedProductIds;
  final DateTime createdAt;
  final DateTime publishAt;
  final AdminContentPublishStatus publishStatus;
  final String? coverImageBase64;
  final List<String> additionalImageBase64;

  AdminJournal copyWith({
    String? title,
    String? category,
    String? body,
    List<String>? relatedProductIds,
    DateTime? publishAt,
    AdminContentPublishStatus? publishStatus,
    String? coverImageBase64,
    List<String>? additionalImageBase64,
  }) {
    return AdminJournal(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      body: body ?? this.body,
      relatedProductIds: relatedProductIds ?? this.relatedProductIds,
      createdAt: createdAt,
      publishAt: publishAt ?? this.publishAt,
      publishStatus: publishStatus ?? this.publishStatus,
      coverImageBase64: coverImageBase64 ?? this.coverImageBase64,
      additionalImageBase64:
          additionalImageBase64 ?? this.additionalImageBase64,
    );
  }
}
