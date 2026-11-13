class TechnicianSpecialtyModel {
  final int id;
  final int technicianId;
  final int categoryId;
  final String experienceLevel;
  final bool acceptAllDevices;
  final String status;
  final String? rejectionReason;
  final List<int> deviceTypeIds;
  final List<String> evidenceUrls;
  final DateTime? createdAt;
  final DateTime? reviewedAt;

  const TechnicianSpecialtyModel({
    required this.id,
    required this.technicianId,
    required this.categoryId,
    required this.experienceLevel,
    required this.acceptAllDevices,
    required this.status,
    this.rejectionReason,
    required this.deviceTypeIds,
    required this.evidenceUrls,
    this.createdAt,
    this.reviewedAt,
  });

  factory TechnicianSpecialtyModel.fromJson(Map<String, dynamic> json) {
    return TechnicianSpecialtyModel(
      id: json['id'] ?? 0,
      technicianId: json['technician_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      experienceLevel: json['experience_level'] ?? '',
      acceptAllDevices: json['accept_all_devices'] ?? false,
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      deviceTypeIds: (json['device_type_ids'] as List? ?? [])
          .map((e) => e as int)
          .toList(),
      evidenceUrls: (json['evidence_urls'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'])
          : null,
    );
  }
}

class CreateTechnicianSpecialtyRequest {
  final int categoryId;
  final String experienceLevel;
  final bool acceptAllDevices;
  final List<int> deviceTypeIds;
  final List<String> evidenceUrls;

  const CreateTechnicianSpecialtyRequest({
    required this.categoryId,
    required this.experienceLevel,
    required this.acceptAllDevices,
    required this.deviceTypeIds,
    required this.evidenceUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'experience_level': experienceLevel,
      'accept_all_devices': acceptAllDevices,
      'device_type_ids': deviceTypeIds,
      'evidence_urls': evidenceUrls,
    };
  }
}

/// Request cập nhật theo body PATCH trong Swagger.
/// category_id không được gửi vì Swagger không khai báo trường này.
class UpdateTechnicianSpecialtyRequest {
  final String experienceLevel;
  final bool acceptAllDevices;
  final List<int> deviceTypeIds;
  final List<String> evidenceUrls;

  const UpdateTechnicianSpecialtyRequest({
    required this.experienceLevel,
    required this.acceptAllDevices,
    required this.deviceTypeIds,
    required this.evidenceUrls,
  });

  Map<String, dynamic> toJson() => {
    'experience_level': experienceLevel,
    'accept_all_devices': acceptAllDevices,
    'device_type_ids': deviceTypeIds,
    'evidence_urls': evidenceUrls,
  };
}
