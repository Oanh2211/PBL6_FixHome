import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/device_type_api.dart';
import '../model/device_type_model.dart';
import 'device_type_state.dart';

class DeviceTypeCubit extends Cubit<DeviceTypeState> {
  final DeviceTypeApi api;

  DeviceTypeCubit(this.api) : super(const DeviceTypeState());

  int? _categoryId;

  void setCategory(int categoryId) {
    _categoryId = categoryId;
    loadDeviceTypes();
  }

  Future<void> loadDeviceTypes({String? query}) async {
    if (_categoryId == null) return;

    final search = query ?? state.searchQuery;

    emit(
      state.copyWith(
        status: DeviceTypeStatus.loading,
        searchQuery: search,
        clearError: true,
      ),
    );

    try {
      final devices = await api.getDeviceTypes(
        categoryId: _categoryId!,
        query: search,
      );

      emit(
        state.copyWith(
          status: DeviceTypeStatus.success,
          devices: devices,
          searchQuery: search,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceTypeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> searchDeviceTypes(String query) async {
    await loadDeviceTypes(query: query);
  }

  Future<void> refreshDeviceTypes() async {
    await loadDeviceTypes();
  }

  Future<void> clearSearch() async {
    await loadDeviceTypes(query: '');
  }

  // Dùng khi muốn lấy lại danh sách ban đầu.
  Future<void> resetSearch() async {
    await loadDeviceTypes(query: '');
  }
}
