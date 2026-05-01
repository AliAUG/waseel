/// Logged-in user - data depends on sign-up/login
class UserModel {
  const UserModel({
    required this.name,
    required this.phone,
    this.email,
    this.profileImagePath,
    this.role,
    this.tripsCount = 0,
    this.deliveriesCount = 0,
    this.rating = 0,
  });

  final String name;
  final String phone;
  final String? email;
  /// Backend: `Passenger` | `Driver`
  final String? role;
  final String? profileImagePath;
  final int tripsCount;
  final int deliveriesCount;
  final double rating;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (profileImagePath != null) 'profileImagePath': profileImagePath,
        if (role != null) 'role': role,
        'tripsCount': tripsCount,
        'deliveriesCount': deliveriesCount,
        'rating': rating,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: _stringFromJson(json['name']),
      phone: _stringFromJson(json['phone']),
      email: json['email']?.toString(),
      profileImagePath: json['profileImagePath']?.toString(),
      role: json['role']?.toString(),
      tripsCount: _intFromJson(json['tripsCount']),
      deliveriesCount: _intFromJson(json['deliveriesCount']),
      rating: _doubleFromJson(json['rating']),
    );
  }

  static String _stringFromJson(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static int _intFromJson(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _doubleFromJson(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
