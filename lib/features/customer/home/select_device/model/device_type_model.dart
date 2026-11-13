class DeviceTypeModel {
  final int id;
  final int categoryId;
  final String code;
  final String name;
  final bool isActive;
  final String? iconUrl;

  const DeviceTypeModel({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.isActive,
    this.iconUrl,
  });

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) {
    return DeviceTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] == true,
      iconUrl: json['icon_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'code': code,
      'name': name,
      'is_active': isActive,
      'icon_url': iconUrl,
    };
  }
}
