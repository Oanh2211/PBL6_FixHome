import 'package:fixhome/features/customer/home/main/model/service_category_model.dart';

class CatalogSearchModel {
  final List<ServiceCategoryModel> categories;
  final List<DeviceTypeModel> deviceTypes;

  CatalogSearchModel({required this.categories, required this.deviceTypes});

  factory CatalogSearchModel.fromJson(Map<String, dynamic> json) {
    return CatalogSearchModel(
      categories: (json['categories'] as List? ?? [])
          .map((e) => ServiceCategoryModel.fromJson(e))
          .toList(),

      deviceTypes: (json['device_types'] as List? ?? [])
          .map((e) => DeviceTypeModel.fromJson(e))
          .toList(),
    );
  }
}

class DeviceTypeModel {
  final int id;
  final int categoryId;
  final String code;
  final String name;
  final bool isActive;
  final String? iconUrl;

  DeviceTypeModel({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.isActive,
    this.iconUrl,
  });

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) {
    return DeviceTypeModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      iconUrl: json['icon_url'] ?? '',
    );
  }
}
