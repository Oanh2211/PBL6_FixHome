import 'package:fixhome/features/technician/account/specialties/models/technician_specialty_model.dart';

class TechnicianSpecialtyState {
  final bool isLoading;
  final bool isSubmitting;
  final List<TechnicianSpecialtyModel> specialties;
  final TechnicianSpecialtyModel? selectedSpecialty;
  final String? errorMessage;
  final String? successMessage;

  const TechnicianSpecialtyState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.specialties = const [],
    this.selectedSpecialty,
    this.errorMessage,
    this.successMessage,
  });

  TechnicianSpecialtyState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<TechnicianSpecialtyModel>? specialties,
    TechnicianSpecialtyModel? selectedSpecialty,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedSpecialty = false,
  }) {
    return TechnicianSpecialtyState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      specialties: specialties ?? this.specialties,
      selectedSpecialty: clearSelectedSpecialty
          ? null
          : selectedSpecialty ?? this.selectedSpecialty,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
