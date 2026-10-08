class AdminStoreSettings {
  const AdminStoreSettings({
    required this.shippingFee,
    required this.freeShippingThreshold,
    required this.carrier,
    required this.originAddress,
    required this.returnAddress,
    required this.csPhone,
    required this.csEmail,
    required this.csHours,
    required this.defaultGuide,
  });

  final int shippingFee;
  final int freeShippingThreshold;
  final String carrier;
  final String originAddress;
  final String returnAddress;
  final String csPhone;
  final String csEmail;
  final String csHours;
  final String defaultGuide;

  AdminStoreSettings copyWith({
    int? shippingFee,
    int? freeShippingThreshold,
    String? carrier,
    String? originAddress,
    String? returnAddress,
    String? csPhone,
    String? csEmail,
    String? csHours,
    String? defaultGuide,
  }) {
    return AdminStoreSettings(
      shippingFee: shippingFee ?? this.shippingFee,
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      carrier: carrier ?? this.carrier,
      originAddress: originAddress ?? this.originAddress,
      returnAddress: returnAddress ?? this.returnAddress,
      csPhone: csPhone ?? this.csPhone,
      csEmail: csEmail ?? this.csEmail,
      csHours: csHours ?? this.csHours,
      defaultGuide: defaultGuide ?? this.defaultGuide,
    );
  }
}
