import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/register_specialty_api.dart';
import '../models/device_type_model.dart';
import '../models/service_category_model.dart';
import 'technician_register_specialty_state.dart';

class TechnicianRegisterSpecialtyCubit
    extends Cubit<TechnicianRegisterSpecialtyState> {
  final TechnicianRegisterSpecialtyApi api;

  TechnicianRegisterSpecialtyCubit({required this.api})
    : super(const TechnicianRegisterSpecialtyState());

  // ==============================
  // LOAD CATEGORIES
  // ==============================

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final categories = await api.getCategories();

      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // ==============================
  // SEARCH CATALOG
  // ==============================

  Future<void> searchCatalog(String query) async {
    if (query.trim().isEmpty) {
      await loadCategories();
      return;
    }

    try {
      final result = await api.searchCatalog(query.trim());

      final categories = result['categories'] as List<ServiceCategoryModel>;

      final devices = result['device_types'] as List<DeviceTypeModel>;

      final updatedDevices = Map<int, List<DeviceTypeModel>>.from(
        state.devicesByCategory,
      );

      // Nhóm thiết bị tìm được theo category_id
      for (final device in devices) {
        final list = updatedDevices[device.categoryId] ?? [];

        if (!list.any((e) => e.id == device.id)) {
          updatedDevices[device.categoryId] = [...list, device];
        }
      }

      emit(
        state.copyWith(
          categories: categories,
          devicesByCategory: updatedDevices,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ==============================
  // LOAD DEVICE TYPES
  // ==============================

  Future<void> loadDeviceTypes(int categoryId) async {
    if (state.devicesByCategory.containsKey(categoryId)) {
      return;
    }

    final loading = Set<int>.from(state.loadingDeviceCategoryIds)
      ..add(categoryId);

    emit(state.copyWith(loadingDeviceCategoryIds: loading));

    try {
      final devices = await api.getDeviceTypes(categoryId: categoryId);

      final updated = Map<int, List<DeviceTypeModel>>.from(
        state.devicesByCategory,
      );

      updated[categoryId] = devices;

      emit(
        state.copyWith(
          devicesByCategory: updated,
          loadingDeviceCategoryIds: Set<int>.from(loading)..remove(categoryId),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingDeviceCategoryIds: Set<int>.from(loading)..remove(categoryId),
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==============================
  // EXPAND CATEGORY
  // ==============================

  Future<void> toggleExpandCategory(int categoryId) async {
    final expanded = Set<int>.from(state.expandedCategoryIds);

    if (expanded.contains(categoryId)) {
      expanded.remove(categoryId);
    } else {
      expanded.add(categoryId);

      await loadDeviceTypes(categoryId);
    }

    emit(state.copyWith(expandedCategoryIds: expanded));
  }

  // ==============================
  // SELECT CATEGORY
  // ==============================

  Future<void> toggleCategory(int categoryId) async {
    final selected = Set<int>.from(state.selectedCategoryIds);

    final selectedDevices = Map<int, Set<int>>.from(state.selectedDeviceIds);

    final acceptAll = Map<int, bool>.from(state.acceptAllDevices);

    if (selected.contains(categoryId)) {
      selected.remove(categoryId);
      selectedDevices.remove(categoryId);
      acceptAll.remove(categoryId);
    } else {
      selected.add(categoryId);

      await loadDeviceTypes(categoryId);
    }

    emit(
      state.copyWith(
        selectedCategoryIds: selected,
        selectedDeviceIds: selectedDevices,
        acceptAllDevices: acceptAll,
      ),
    );
  }

  // ==============================
  // SELECT ALL DEVICES
  // ==============================

  void toggleAcceptAllDevices(int categoryId, bool value) {
    final acceptAll = Map<int, bool>.from(state.acceptAllDevices);

    final selectedDevices = Map<int, Set<int>>.from(state.selectedDeviceIds);

    acceptAll[categoryId] = value;

    if (value) {
      selectedDevices[categoryId] = {};
    }

    emit(
      state.copyWith(
        acceptAllDevices: acceptAll,
        selectedDeviceIds: selectedDevices,
      ),
    );
  }

  // ==============================
  // SELECT DEVICE
  // ==============================

  void toggleDevice(int categoryId, int deviceId) {
    final selected = Map<int, Set<int>>.from(state.selectedDeviceIds);

    final devices = Set<int>.from(selected[categoryId] ?? {});

    if (devices.contains(deviceId)) {
      devices.remove(deviceId);
    } else {
      devices.add(deviceId);
    }

    selected[categoryId] = devices;

    final acceptAll = Map<int, bool>.from(state.acceptAllDevices);

    acceptAll[categoryId] = false;

    emit(
      state.copyWith(selectedDeviceIds: selected, acceptAllDevices: acceptAll),
    );
  }

  // ==============================
  // EXPERIENCE LEVEL
  // ==============================

  void setExperienceLevel(int categoryId, String experienceLevel) {
    final levels = Map<int, String>.from(state.experienceLevels);

    levels[categoryId] = experienceLevel;

    emit(state.copyWith(experienceLevels: levels));
  }

  // ==============================
  // UPLOAD EVIDENCE
  // ==============================

  Future<void> uploadEvidence({
    required int categoryId,
    required File file,
  }) async {
    final uploading = Set<int>.from(state.uploadingCategoryIds)
      ..add(categoryId);

    emit(state.copyWith(uploadingCategoryIds: uploading, clearError: true));

    try {
      // 1. Tạo upload intent
      final intent = await api.createUploadIntent();

      // 2. Upload trực tiếp lên Cloudinary
      final cloudinaryUrl = await api.uploadImageToCloudinary(
        file: file,
        intent: intent,
      );

      // 3. Xác nhận upload với backend
      final result = await api.completeUpload(
        uploadIntentId: intent.uploadIntentId,
      );

      // Ưu tiên URL do backend xác nhận trả về
      final finalUrl = result.fileUrl.isNotEmpty
          ? result.fileUrl
          : cloudinaryUrl;

      if (finalUrl.isEmpty) {
        throw Exception('Không lấy được URL chứng chỉ');
      }

      final evidence = Map<int, List<String>>.from(state.evidenceUrls);

      evidence[categoryId] = [...?evidence[categoryId], finalUrl];

      emit(
        state.copyWith(
          evidenceUrls: evidence,
          uploadingCategoryIds: Set<int>.from(uploading)..remove(categoryId),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploadingCategoryIds: Set<int>.from(uploading)..remove(categoryId),
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==============================
  // REMOVE EVIDENCE
  // ==============================

  void removeEvidence(int categoryId, String url) {
    final evidence = Map<int, List<String>>.from(state.evidenceUrls);

    evidence[categoryId] = [...?evidence[categoryId]]..remove(url);

    emit(state.copyWith(evidenceUrls: evidence));
  }

  // ==============================
  // VALIDATE STEP 1
  // ==============================

  bool validateStep1() {
    if (state.selectedCategoryIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'specialty.select_category_error'));
      return false;
    }

    for (final categoryId in state.selectedCategoryIds) {
      final acceptAll = state.acceptAllDevices[categoryId] ?? false;

      final selectedDevices = state.selectedDeviceIds[categoryId] ?? {};

      if (!acceptAll && selectedDevices.isEmpty) {
        emit(state.copyWith(errorMessage: 'specialty.select_device_error'));
        return false;
      }
    }

    emit(state.copyWith(currentStep: 1, clearError: true));

    return true;
  }

  // ==============================
  // BACK TO STEP 1
  // ==============================

  void backToStep1() {
    emit(state.copyWith(currentStep: 0, clearError: true));
  }

  // ==============================
  // SUBMIT SPECIALTIES
  // ==============================

  Future<bool> submitSpecialties() async {
    if (state.selectedCategoryIds.isEmpty) {
      return false;
    }

    for (final categoryId in state.selectedCategoryIds) {
      if (!(state.experienceLevels[categoryId] ?? '').isNotEmpty) {
        emit(state.copyWith(errorMessage: 'specialty.select_experience_error'));
        return false;
      }
    }

    if (state.uploadingCategoryIds.isNotEmpty) {
      emit(state.copyWith(errorMessage: 'specialty.uploading_error'));
      return false;
    }

    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );

    try {
      // Mỗi chuyên môn tương ứng một request POST
      for (final categoryId in state.selectedCategoryIds) {
        final acceptAll = state.acceptAllDevices[categoryId] ?? false;

        final deviceIds = (state.selectedDeviceIds[categoryId] ?? {}).toList();

        final experience = state.experienceLevels[categoryId]!;

        final evidence = state.evidenceUrls[categoryId] ?? [];

        await api.registerSpecialty(
          categoryId: categoryId,
          experienceLevel: experience,
          acceptAllDevices: acceptAll,
          deviceTypeIds: deviceIds,
          evidenceUrls: evidence,
        );
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'specialty.register_success',
        ),
      );

      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));

      return false;
    }
  }
}
