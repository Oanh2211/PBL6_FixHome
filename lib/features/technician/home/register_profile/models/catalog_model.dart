class CatalogCategory {
  final int id;
  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final bool isActive;

  const CatalogCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.isActive,
  });

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class CatalogDeviceType {
  final int id;
  final int categoryId;
  final String code;
  final String name;
  final bool isActive;

  const CatalogDeviceType({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory CatalogDeviceType.fromJson(Map<String, dynamic> json) {
    return CatalogDeviceType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
