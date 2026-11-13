class ProfileResponseModel {
  final int id;
  final String role;
  final String status;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? phoneVerifiedAt;
  final String? createdAt;

  const ProfileResponseModel({
    required this.id,
    required this.role,
    required this.status,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.phoneVerifiedAt,
    this.createdAt,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      id: json['id'] ?? 0,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      phoneVerifiedAt: json['phone_verified_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'status': status,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'phone_verified_at': phoneVerifiedAt,
      'created_at': createdAt,
    };
  }

  ProfileResponseModel copyWith({String? fullName}) {
    return ProfileResponseModel(
      id: id,
      role: role,
      status: status,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber,
      phoneVerifiedAt: phoneVerifiedAt,
      createdAt: createdAt,
    );
  }
}
