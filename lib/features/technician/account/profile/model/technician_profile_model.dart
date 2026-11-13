class TechnicianProfileModel {
  final int? id;
  final int? accountId;

  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? citizenId;

  final String? currentAddress;
  final String? currentWardCode;
  final String? currentProvinceCode;

  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;

  final String? verificationStatus;
  final String? verificationRejectionReason;
  final bool isAvailable;
  final String? verifiedAt;

  final List<IdentityMediaModel> identityMedia;

  const TechnicianProfileModel({
    this.id,
    this.accountId,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.citizenId,
    this.currentAddress,
    this.currentWardCode,
    this.currentProvinceCode,
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
      id: json['id'],
      accountId: json['account_id'],
      avatarUrl: json['avatar_url'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      citizenId: json['citizen_id'],
      currentAddress: json['current_address'],
      currentWardCode: json['current_ward_code'],
      currentProvinceCode: json['current_province_code'],
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
  TechnicianProfileModel copyWith({
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? citizenId,
    String? currentAddress,
    String? currentWardCode,
    String? currentProvinceCode,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
    List<IdentityMediaModel>? identityMedia,
  }) {
    return TechnicianProfileModel(
      id: id,
      accountId: accountId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      citizenId: citizenId ?? this.citizenId,
      currentAddress: currentAddress ?? this.currentAddress,
      currentWardCode: currentWardCode ?? this.currentWardCode,
      currentProvinceCode: currentProvinceCode ?? this.currentProvinceCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelationship:
          emergencyContactRelationship ?? this.emergencyContactRelationship,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      verificationStatus: verificationStatus,
      verificationRejectionReason: verificationRejectionReason,
      isAvailable: isAvailable,
      verifiedAt: verifiedAt,
      identityMedia: identityMedia ?? this.identityMedia,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'citizen_id': citizenId,
      'current_address': currentAddress,
      'current_ward_code': currentWardCode,
      'current_province_code': currentProvinceCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_relationship': emergencyContactRelationship,
      'emergency_contact_phone': emergencyContactPhone,
      'identity_media': identityMedia.map((e) => e.toUpdateJson()).toList(),
    };
  }
}

class IdentityMediaModel {
  final int? id;
  final int? mediaId;
  final String? mediaUrl;
  final String? mediaType;

  const IdentityMediaModel({
    this.id,
    this.mediaId,
    this.mediaUrl,
    this.mediaType,
  });

  factory IdentityMediaModel.fromJson(Map<String, dynamic> json) {
    return IdentityMediaModel(
      id: json['id'],
      mediaId: json['media_id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {'media_id': mediaId, 'media_type': mediaType};
  }
}
