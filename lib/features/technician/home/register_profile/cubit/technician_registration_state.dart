import 'dart:io';

import 'package:equatable/equatable.dart';
import '../models/catalog_model.dart';

class TechnicianRegistrationState extends Equatable {
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  // File đã chọn
  final File? avatarFile;
  final File? frontCccdFile;
  final File? backCccdFile;

  // URL sau khi upload
  final String avatarUrl;
  final String frontCccdUrl;
  final String backCccdUrl;
  final List<String> evidenceUrls;

  // Chuyên môn
  final int? categoryId;
  final String experienceLevel;
  final bool acceptAllDevices;
  final List<int> selectedDeviceIds;

  // Danh mục từ API
  final List<CatalogCategory> categories;
  final List<CatalogDeviceType> deviceTypes;

  // Loading catalog
  final bool isLoadingCategories;
  final bool isLoadingDevices;

  // Lỗi catalog
  final String? catalogError;

  const TechnicianRegistrationState({
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.avatarFile,
    this.frontCccdFile,
    this.backCccdFile,
    this.avatarUrl = '',
    this.frontCccdUrl = '',
    this.backCccdUrl = '',
    this.evidenceUrls = const [],
    this.categoryId,
    this.experienceLevel = '3-5',
    this.acceptAllDevices = false,
    this.selectedDeviceIds = const [],
    this.categories = const [],
    this.deviceTypes = const [],
    this.isLoadingCategories = false,
    this.isLoadingDevices = false,
    this.catalogError,
  });

  TechnicianRegistrationState copyWith({
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,

    File? avatarFile,
    File? frontCccdFile,
    File? backCccdFile,

    String? avatarUrl,
    String? frontCccdUrl,
    String? backCccdUrl,
    List<String>? evidenceUrls,

    int? categoryId,
    bool clearCategoryId = false,

    String? experienceLevel,
    bool? acceptAllDevices,
    List<int>? selectedDeviceIds,

    List<CatalogCategory>? categories,
    List<CatalogDeviceType>? deviceTypes,

    bool? isLoadingCategories,
    bool? isLoadingDevices,

    String? catalogError,
    bool clearCatalogError = false,
  }) {
    return TechnicianRegistrationState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,

      avatarFile: avatarFile ?? this.avatarFile,
      frontCccdFile: frontCccdFile ?? this.frontCccdFile,
      backCccdFile: backCccdFile ?? this.backCccdFile,

      avatarUrl: avatarUrl ?? this.avatarUrl,
      frontCccdUrl: frontCccdUrl ?? this.frontCccdUrl,
      backCccdUrl: backCccdUrl ?? this.backCccdUrl,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,

      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,

      experienceLevel: experienceLevel ?? this.experienceLevel,
      acceptAllDevices: acceptAllDevices ?? this.acceptAllDevices,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,

      categories: categories ?? this.categories,
      deviceTypes: deviceTypes ?? this.deviceTypes,

      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingDevices: isLoadingDevices ?? this.isLoadingDevices,

      catalogError: clearCatalogError
          ? null
          : catalogError ?? this.catalogError,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    errorMessage,
    isSuccess,
    avatarFile,
    frontCccdFile,
    backCccdFile,
    avatarUrl,
    frontCccdUrl,
    backCccdUrl,
    evidenceUrls,
    categoryId,
    experienceLevel,
    acceptAllDevices,
    selectedDeviceIds,
    categories,
    deviceTypes,
    isLoadingCategories,
    isLoadingDevices,
    catalogError,
  ];
}
