enum UserRole { customer, staff, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final double balance;
  final int points;
  final int? coupons;
  final String? lastFillDate;
  final double? lastFillVolume;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.balance = 0.0,
    this.points = 0,
    this.coupons,
    this.lastFillDate,
    this.lastFillVolume,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'balance': balance,
      'points': points,
      if (coupons != null) 'coupons': coupons,
      if (lastFillDate != null) 'lastFillDate': lastFillDate,
      if (lastFillVolume != null) 'lastFillVolume': lastFillVolume,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.customer,
      ),
      balance: (map['balance'] ?? 0.0).toDouble(),
      points: map['points'] ?? 0,
      coupons: map['coupons'] as int?,
      lastFillDate: map['lastFillDate'] as String?,
      lastFillVolume: (map['lastFillVolume'] as num?)?.toDouble(),
    );
  }
}
