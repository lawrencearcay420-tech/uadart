class Promo {
  final String code;
  final String description;
  final double discountPercent;
  final double? minOrder;
  final DateTime? expiresAt;
  final int? usageLimit;
  final int usageCount;

  Promo({
    required this.code,
    required this.description,
    required this.discountPercent,
    this.minOrder,
    this.expiresAt,
    this.usageLimit,
    this.usageCount = 0,
  });

  bool get isValid {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    if (usageLimit != null && usageCount >= usageLimit!) {
      return false;
    }
    return true;
  }

  bool isValidFor(double subtotal) {
    if (!isValid) return false;
    if (minOrder != null && subtotal < minOrder!) return false;
    return true;
  }

  double calculateDiscount(double subtotal) {
    if (!isValidFor(subtotal)) return 0;
    return subtotal * (discountPercent / 100);
  }

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      code: json['code'] as String,
      description: json['description'] as String,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      minOrder: json['minOrder'] != null
          ? (json['minOrder'] as num).toDouble()
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'discountPercent': discountPercent,
        'minOrder': minOrder,
        'expiresAt': expiresAt?.toIso8601String(),
        'usageLimit': usageLimit,
        'usageCount': usageCount,
      };

  static Promo welcome10() {
    return Promo(
      code: 'WELCOME10',
      description: '10% off for new customers',
      discountPercent: 10,
      minOrder: 500,
    );
  }

  static Promo ua20() {
    return Promo(
      code: 'UA20',
      description: '20% off on orders above ₱2,000',
      discountPercent: 20,
      minOrder: 2000,
    );
  }

  static final List<Promo> defaults = [
    Promo.welcome10(),
    Promo.ua20(),
  ];
}
