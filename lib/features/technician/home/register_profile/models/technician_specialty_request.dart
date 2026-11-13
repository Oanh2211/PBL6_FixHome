class TechnicianSpecialtyRequest {
  final int categoryId;
  final String experienceLevel;
  final bool acceptAllDevices;
  final List<int> deviceTypeIds;
  final List<String> evidenceUrls;

  TechnicianSpecialtyRequest({
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
