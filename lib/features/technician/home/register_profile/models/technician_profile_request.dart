class IdentityMediaRequest {
  final String mediaUrl;
  final String mediaType;

  IdentityMediaRequest({required this.mediaUrl, required this.mediaType});

  Map<String, dynamic> toJson() {
    return {'media_url': mediaUrl, 'media_type': mediaType};
  }
}

class TechnicianProfileRequest {
  final String gender;
  final String avatarUrl;
  final String dateOfBirth;
  final String citizenId;
  final String currentAddress;
  final String currentWardCode;

  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;

  final List<IdentityMediaRequest> identityMediaUrls;

  TechnicianProfileRequest({
    required this.gender,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.citizenId,
    required this.currentAddress,
    required this.currentWardCode,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    required this.identityMediaUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth,
      'citizen_id': citizenId,
      'current_address': currentAddress,
      'current_ward_code': currentWardCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_relationship': emergencyContactRelationship,
      'emergency_contact_phone': emergencyContactPhone,
      'identity_media_urls': identityMediaUrls.map((e) => e.toJson()).toList(),
    };
  }
}
