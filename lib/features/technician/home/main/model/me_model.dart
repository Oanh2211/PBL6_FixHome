class MeModel {
  final int id;
  final String role;
  final String status;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? phoneVerifiedAt;
  final String? createdAt;

  const MeModel({
    required this.id,
    required this.role,
    required this.status,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.phoneVerifiedAt,
    this.createdAt,
  });

  factory MeModel.fromJson(Map<String, dynamic> json) {
    return MeModel(
      id: json['id'] ?? 0,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      phoneVerifiedAt: json['phone_verified_at'],
      createdAt: json['created_at'],
    );
  }
}
