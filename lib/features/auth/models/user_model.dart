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
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      role: json['role'] as String?,
      tripsCount: (json['tripsCount'] as num?)?.toInt() ?? 0,
      deliveriesCount: (json['deliveriesCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
