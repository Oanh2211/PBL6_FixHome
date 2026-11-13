import 'dart:io';

import 'package:fixhome/features/technician/home/register_profile/api/catalog_api.dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../api/media_upload_api.dart';
import '../api/technician_registration_api.dart';

import '../models/technician_profile_request.dart';
import '../models/technician_specialty_request.dart';

import 'technician_registration_state.dart';

class TechnicianRegistrationCubit extends Cubit<TechnicianRegistrationState> {
  final MediaUploadApi mediaApi;
  final TechnicianRegistrationApi registrationApi;
  final CatalogApi catalogApi;

  final ImagePicker _picker = ImagePicker();

  TechnicianRegistrationCubit({
    required this.mediaApi,
    required this.registrationApi,
    required this.catalogApi,
  }) : super(const TechnicianRegistrationState()) {
    loadCategories();
  }

  // =====================================================
  // 1. CHUYỂN BƯỚC
  // =====================================================

  void nextStep() {
    if (state.currentStep < 5) {
      emit(
        state.copyWith(currentStep: state.currentStep + 1, clearError: true),
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(
        state.copyWith(currentStep: state.currentStep - 1, clearError: true),
      );
    }
  }

  // =====================================================
  // 2. CHỌN ẢNH
  // =====================================================

  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      throw Exception('Không thể chọn ảnh: $e');
    }
  }

  // =====================================================
  // 3. UPLOAD FILE
  // =====================================================

  Future<String> _uploadFile(File file) async {
    final result = await mediaApi.uploadFile(file: file, mediaType: 'IMAGE');

    if (result.mediaUrl.isEmpty) {
      throw Exception('Không nhận được media_url');
    }

    return result.mediaUrl;
  }

  // Upload avatar
  Future<void> selectAvatar() async {
    try {
      final file = await pickImage();
      if (file == null) return;

      emit(state.copyWith(isLoading: true, clearError: true));

      final url = await _uploadFile(file);

      emit(state.copyWith(avatarFile: file, avatarUrl: url, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể upload ảnh đại diện: $e',
        ),
      );
    }
  }

  // Upload CCCD mặt trước
  Future<void> selectFrontCccd() async {
    try {
      final file = await pickImage();
      if (file == null) return;

      emit(state.copyWith(isLoading: true, clearError: true));

      final url = await _uploadFile(file);

      emit(
        state.copyWith(
          frontCccdFile: file,
          frontCccdUrl: url,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể upload CCCD mặt trước: $e',
        ),
      );
    }
  }

  // Upload CCCD mặt sau
  Future<void> selectBackCccd() async {
    try {
      final file = await pickImage();
      if (file == null) return;

      emit(state.copyWith(isLoading: true, clearError: true));

      final url = await _uploadFile(file);

      emit(
        state.copyWith(backCccdFile: file, backCccdUrl: url, isLoading: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể upload CCCD mặt sau: $e',
        ),
      );
    }
  }

  // Upload tài liệu minh chứng
  Future<void> selectEvidence() async {
    try {
      final file = await pickImage();
      if (file == null) return;

      emit(state.copyWith(isLoading: true, clearError: true));

      final url = await _uploadFile(file);

      emit(
        state.copyWith(
          evidenceUrls: [...state.evidenceUrls, url],
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể upload tài liệu: $e',
        ),
      );
    }
  }

  void removeEvidence(int index) {
    if (index < 0 || index >= state.evidenceUrls.length) return;

    final list = [...state.evidenceUrls];
    list.removeAt(index);

    emit(state.copyWith(evidenceUrls: list));
  }

  // =====================================================
  // 4. LẤY DANH SÁCH NGÀNH NGHỀ
  // =====================================================

  Future<void> loadCategories({String query = ''}) async {
    try {
      emit(state.copyWith(isLoadingCategories: true, clearCatalogError: true));

      final categories = query.trim().isEmpty
          ? await catalogApi.getAllCategory()
          : await catalogApi.getCategories(query: query.trim());

      if (isClosed) return;

      emit(
        state.copyWith(
          categories: categories,
          isLoadingCategories: false,
          deviceTypes: [],
          selectedDeviceIds: [],
          acceptAllDevices: false,
          clearCategoryId: true,
          clearCatalogError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoadingCategories: false, catalogError: e.toString()),
      );
    }
  }

  // =====================================================
  // 5. CHỌN NGÀNH NGHỀ
  // =====================================================

  Future<void> selectCategory(int id) async {
    // Nếu chọn lại đúng ngành nghề hiện tại thì không gọi lại API
    if (state.categoryId == id) return;

    emit(
      state.copyWith(
        categoryId: id,
        deviceTypes: [],
        selectedDeviceIds: [],
        acceptAllDevices: false,
        isLoadingDevices: true,
        clearCatalogError: true,
      ),
    );

    await loadDeviceTypes(id);
  }

  // =====================================================
  // 6. LẤY THIẾT BỊ THEO NGÀNH NGHỀ
  // =====================================================

  Future<void> loadDeviceTypes(int categoryId, {String query = ''}) async {
    try {
      emit(state.copyWith(isLoadingDevices: true, clearCatalogError: true));

      final devices = await catalogApi.getDeviceTypes(
        categoryId: categoryId,
        query: query,
      );

      // Tránh trường hợp người dùng đổi ngành nghề
      // trong lúc API cũ chưa trả kết quả.
      if (isClosed || state.categoryId != categoryId) return;

      emit(
        state.copyWith(
          deviceTypes: devices,
          isLoadingDevices: false,
          clearCatalogError: true,
        ),
      );
    } catch (e) {
      if (isClosed || state.categoryId != categoryId) return;

      emit(state.copyWith(isLoadingDevices: false, catalogError: e.toString()));
    }
  }

  // =====================================================
  // 7. CHỌN KINH NGHIỆM
  // =====================================================

  void selectExperience(String value) {
    emit(state.copyWith(experienceLevel: value));
  }

  // =====================================================
  // 8. CHỌN TẤT CẢ THIẾT BỊ
  // =====================================================

  void toggleAllDevices(bool value) {
    emit(
      state.copyWith(
        acceptAllDevices: value,
        selectedDeviceIds: value ? [] : state.selectedDeviceIds,
      ),
    );
  }

  // =====================================================
  // 9. CHỌN THIẾT BỊ RIÊNG LẺ
  // =====================================================

  void toggleDevice(int id) {
    final list = [...state.selectedDeviceIds];

    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }

    emit(state.copyWith(selectedDeviceIds: list, acceptAllDevices: false));
  }

  // =====================================================
  // 10. GỬI HỒ SƠ ĐĂNG KÝ
  // =====================================================

  Future<void> submitRegistration({
    required TechnicianProfileRequest profile,
    required TechnicianSpecialtyRequest specialty,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, isSuccess: false, clearError: true));

      // Kiểm tra ảnh
      if (state.avatarUrl.isEmpty) {
        throw Exception('Vui lòng tải ảnh đại diện');
      }

      if (state.frontCccdUrl.isEmpty || state.backCccdUrl.isEmpty) {
        throw Exception('Vui lòng tải đủ 2 mặt CCCD');
      }

      // Kiểm tra ngành nghề
      if (state.categoryId == null) {
        throw Exception('Vui lòng chọn ngành nghề');
      }

      // API 1: Cập nhật profile
      await registrationApi.updateProfile(profile);

      // API 2: Lưu chuyên môn
      await registrationApi.saveSpecialties(specialty);

      // API 3: Gửi hồ sơ xét duyệt
      await registrationApi.submitProfile();

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
