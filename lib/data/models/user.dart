import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.customer,
    this.phone,
    this.avatar,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values[json['role'] as int? ?? 0],
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.index,
        'phone': phone,
        'avatar': avatar,
        'createdAt': createdAt.toIso8601String(),
      };

  User copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatar,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }

  static User create(String name, String email, UserRole role) {
    return User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      role: role,
    );
  }
}

enum UserRole { customer, admin }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
