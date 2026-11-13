class TechnicianProfileModel {
  final int id;
  final int accountId;

  final String? avatarUrl;
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? citizenId;

  final String? currentAddress;
  final String? currentWardCode;

  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;

  final String? verificationStatus;
  final String? verificationRejectionReason;

  final bool isAvailable;
  final String? verifiedAt;

  final List<IdentityMediaModel> identityMedia;

  const TechnicianProfileModel({
    required this.id,
    required this.accountId,
    this.avatarUrl,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.citizenId,
    this.currentAddress,
    this.currentWardCode,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.verificationStatus,
    this.verificationRejectionReason,
    this.isAvailable = false,
    this.verifiedAt,
    this.identityMedia = const [],
  });

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileModel(
      id: json['id'] ?? 0,
      accountId: json['account_id'] ?? 0,

      avatarUrl: json['avatar_url'],
      fullName: json['full_name'] ?? json['account']?['full_name'],

      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      citizenId: json['citizen_id'],

      currentAddress: json['current_address'],
      currentWardCode: json['current_ward_code'],

      emergencyContactName: json['emergency_contact_name'],

      emergencyContactRelationship: json['emergency_contact_relationship'],

      emergencyContactPhone: json['emergency_contact_phone'],

      verificationStatus: json['verification_status'],

      verificationRejectionReason: json['verification_rejection_reason'],

      isAvailable: json['is_available'] ?? false,
      verifiedAt: json['verified_at'],

      identityMedia:
          (json['identity_media'] as List<dynamic>?)
              ?.map(
                (e) => IdentityMediaModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // Kiểm tra hồ sơ đã hoàn thiện chưa
  bool get isProfileCompleted {
    return gender != null && gender!.trim().isNotEmpty;
  }

  TechnicianProfileModel copyWith({bool? isAvailable}) {
    return TechnicianProfileModel(
      id: id,
      accountId: accountId,
      avatarUrl: avatarUrl,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      citizenId: citizenId,
      currentAddress: currentAddress,
      currentWardCode: currentWardCode,
      emergencyContactName: emergencyContactName,
      emergencyContactRelationship: emergencyContactRelationship,
      emergencyContactPhone: emergencyContactPhone,
      verificationStatus: verificationStatus,
      verificationRejectionReason: verificationRejectionReason,
      isAvailable: isAvailable ?? this.isAvailable,
      verifiedAt: verifiedAt,
      identityMedia: identityMedia,
    );
  }
}

class IdentityMediaModel {
  final int id;
  final String? mediaUrl;
  final String? mediaType;

  const IdentityMediaModel({required this.id, this.mediaUrl, this.mediaType});

  factory IdentityMediaModel.fromJson(Map<String, dynamic> json) {
    return IdentityMediaModel(
      id: json['id'] ?? 0,
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
    );
  }
}
