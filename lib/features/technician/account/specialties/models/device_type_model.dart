class DeviceTypeModel {
  final int id;
  final int categoryId;
  final String code;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;

  DeviceTypeModel({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
  });

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) {
    return DeviceTypeModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? false,
    );
  }
}
