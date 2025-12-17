class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? distributorId;
  final String? wilaya;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.distributorId,
    this.wilaya,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      distributorId: json['distributor_id'],
      wilaya: json['wilaya'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'distributor_id': distributorId,
      'wilaya': wilaya,
    };
  }

  bool get isDistributor => role == 'distributor';
  bool get isAdmin => role == 'admin' || role == 'super_admin';
}