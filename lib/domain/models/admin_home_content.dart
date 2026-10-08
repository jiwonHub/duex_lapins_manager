enum AdminContentPublishStatus {
  draft,
  published,
}

extension AdminContentPublishStatusLabel on AdminContentPublishStatus {
  String get label => switch (this) {
        AdminContentPublishStatus.draft => '임시저장',
        AdminContentPublishStatus.published => '게시',
      };
}

class AdminHeroContent {
  const AdminHeroContent({
    required this.mainText,
    required this.subText,
    required this.buttonText,
    required this.buttonRoute,
    required this.visible,
    required this.order,
    this.mediaName = '',
    this.mediaBase64,
    this.isVideo = false,
  });

  final String mainText;
  final String subText;
  final String buttonText;
  final String buttonRoute;
  final bool visible;
  final int order;
  final String mediaName;
  final String? mediaBase64;
  final bool isVideo;

  AdminHeroContent copyWith({
    String? mainText,
    String? subText,
    String? buttonText,
    String? buttonRoute,
    bool? visible,
    int? order,
    String? mediaName,
    String? mediaBase64,
    bool? isVideo,
  }) {
    return AdminHeroContent(
      mainText: mainText ?? this.mainText,
      subText: subText ?? this.subText,
      buttonText: buttonText ?? this.buttonText,
      buttonRoute: buttonRoute ?? this.buttonRoute,
      visible: visible ?? this.visible,
      order: order ?? this.order,
      mediaName: mediaName ?? this.mediaName,
      mediaBase64: mediaBase64 ?? this.mediaBase64,
      isVideo: isVideo ?? this.isVideo,
    );
  }
}

class AdminHomeContent {
  const AdminHomeContent({
    required this.hero,
    required this.classicVisible,
    required this.workVisible,
    required this.classicImageBase64,
    required this.workImageBase64,
    required this.newArrivalProductIds,
    required this.publishStatus,
    required this.updatedAt,
  });

  final AdminHeroContent hero;
  final bool classicVisible;
  final bool workVisible;
  final String? classicImageBase64;
  final String? workImageBase64;
  final List<String> newArrivalProductIds;
  final AdminContentPublishStatus publishStatus;
  final DateTime updatedAt;

  AdminHomeContent copyWith({
    AdminHeroContent? hero,
    bool? classicVisible,
    bool? workVisible,
    String? classicImageBase64,
    String? workImageBase64,
    List<String>? newArrivalProductIds,
    AdminContentPublishStatus? publishStatus,
    DateTime? updatedAt,
  }) {
    return AdminHomeContent(
      hero: hero ?? this.hero,
      classicVisible: classicVisible ?? this.classicVisible,
      workVisible: workVisible ?? this.workVisible,
      classicImageBase64: classicImageBase64 ?? this.classicImageBase64,
      workImageBase64: workImageBase64 ?? this.workImageBase64,
      newArrivalProductIds:
          newArrivalProductIds ?? this.newArrivalProductIds,
      publishStatus: publishStatus ?? this.publishStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
