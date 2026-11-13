class ServiceCategoryModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;

  const ServiceCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
    };
  }
}
