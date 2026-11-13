import 'package:fixhome/features/customer/home/main/api/service_category_api.dart';
import 'package:fixhome/features/customer/home/main/cubit/service_category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceCategoryCubit extends Cubit<ServiceCategoryState> {
  final ServiceCategoryApi _api;

  ServiceCategoryCubit(this._api) : super(const ServiceCategoryState());

  // Lấy danh sách danh mục
  Future<void> loadCategories() async {
    emit(
      state.copyWith(status: ServiceCategoryStatus.loading, clearError: true),
    );

    try {
      final categories = await _api.getCategories();

      emit(
        state.copyWith(
          status: ServiceCategoryStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceCategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Tìm kiếm danh mục và loại thiết bị
  Future<void> searchCategories(String query) async {
    if (query.trim().isEmpty) {
      await loadCategories();
      return;
    }

    emit(
      state.copyWith(
        status: ServiceCategoryStatus.loading,
        searchQuery: query,
        clearError: true,
      ),
    );

    try {
      final result = await _api.searchCatalog(query: query);

      final categories = result.categories
          .where((category) => category.isActive)
          .toList();
      final deviceTypes = result.deviceTypes
          .where((device) => device.isActive)
          .toList();

      emit(
        state.copyWith(
          status: ServiceCategoryStatus.success,
          categories: categories,
          deviceTypes: deviceTypes,
          searchQuery: query,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceCategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Tải lại danh sách
  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
