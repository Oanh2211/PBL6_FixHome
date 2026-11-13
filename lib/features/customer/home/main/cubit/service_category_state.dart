import 'package:fixhome/features/customer/home/main/model/catalog_search_model.dart';
import 'package:fixhome/features/customer/home/main/model/service_category_model.dart';

enum ServiceCategoryStatus { initial, loading, success, failure }

class ServiceCategoryState {
  final ServiceCategoryStatus status;
  final List<ServiceCategoryModel> categories;
  final List<DeviceTypeModel> deviceTypes;
  final String? errorMessage;
  final String searchQuery;

  const ServiceCategoryState({
    this.status = ServiceCategoryStatus.initial,
    this.categories = const [],
    this.deviceTypes = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  ServiceCategoryState copyWith({
    ServiceCategoryStatus? status,
    List<ServiceCategoryModel>? categories,
    List<DeviceTypeModel>? deviceTypes,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return ServiceCategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      deviceTypes: deviceTypes ?? this.deviceTypes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
