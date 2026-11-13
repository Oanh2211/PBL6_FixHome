import '../models/service_category_model.dart';
import '../models/device_type_model.dart';

class TechnicianRegisterSpecialtyState {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  final List<ServiceCategoryModel> categories;

  // Danh sách thiết bị theo từng chuyên môn
  final Map<int, List<DeviceTypeModel>> devicesByCategory;

  // Các chuyên môn đã chọn
  final Set<int> selectedCategoryIds;

  // Thiết bị đã chọn theo chuyên môn
  final Map<int, Set<int>> selectedDeviceIds;

  // Chọn tất cả thiết bị
  final Map<int, bool> acceptAllDevices;

  // Kinh nghiệm theo chuyên môn
  final Map<int, String> experienceLevels;

  // Danh sách URL chứng chỉ theo chuyên môn
  final Map<int, List<String>> evidenceUrls;

  // Danh sách chuyên môn đang mở rộng
  final Set<int> expandedCategoryIds;

  // Chuyên môn đang tải thiết bị
  final Set<int> loadingDeviceCategoryIds;

  // Chuyên môn đang upload chứng chỉ
  final Set<int> uploadingCategoryIds;

  final int currentStep;

  const TechnicianRegisterSpecialtyState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.categories = const [],
    this.devicesByCategory = const {},
    this.selectedCategoryIds = const {},
    this.selectedDeviceIds = const {},
    this.acceptAllDevices = const {},
    this.experienceLevels = const {},
    this.evidenceUrls = const {},
    this.expandedCategoryIds = const {},
    this.loadingDeviceCategoryIds = const {},
    this.uploadingCategoryIds = const {},
    this.currentStep = 0,
  });

  TechnicianRegisterSpecialtyState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<ServiceCategoryModel>? categories,
    Map<int, List<DeviceTypeModel>>? devicesByCategory,
    Set<int>? selectedCategoryIds,
    Map<int, Set<int>>? selectedDeviceIds,
    Map<int, bool>? acceptAllDevices,
    Map<int, String>? experienceLevels,
    Map<int, List<String>>? evidenceUrls,
    Set<int>? expandedCategoryIds,
    Set<int>? loadingDeviceCategoryIds,
    Set<int>? uploadingCategoryIds,
    int? currentStep,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TechnicianRegisterSpecialtyState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      categories: categories ?? this.categories,
      devicesByCategory: devicesByCategory ?? this.devicesByCategory,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      acceptAllDevices: acceptAllDevices ?? this.acceptAllDevices,
      experienceLevels: experienceLevels ?? this.experienceLevels,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      expandedCategoryIds: expandedCategoryIds ?? this.expandedCategoryIds,
      loadingDeviceCategoryIds:
          loadingDeviceCategoryIds ?? this.loadingDeviceCategoryIds,
      uploadingCategoryIds: uploadingCategoryIds ?? this.uploadingCategoryIds,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
