import 'package:uuid/uuid.dart';

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String barangay;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;

  Address({
    String? id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.barangay,
    required this.city,
    required this.province,
    required this.postalCode,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String? ?? const Uuid().v4(),
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      barangay: json['barangay'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postalCode'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'barangay': barangay,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };

  String get fullAddress =>
      '$street, $barangay, $city, $province $postalCode';

  Address copyWith({
    String? fullName,
    String? phone,
    String? street,
    String? barangay,
    String? city,
    String? province,
    String? postalCode,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
