import 'package:fixhome/features/technician/account/specialties/models/technician_specialty_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/technician_specialty_api.dart';
import 'technician_specialty_state.dart';

class TechnicianSpecialtyCubit extends Cubit<TechnicianSpecialtyState> {
  final TechnicianSpecialtyApi _api;

  TechnicianSpecialtyCubit(this._api) : super(const TechnicianSpecialtyState());

  // Lấy danh sách nghiệp vụ
  Future<void> loadSpecialties() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _api.getSpecialties();

      emit(state.copyWith(isLoading: false, specialties: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Lấy chi tiết nghiệp vụ
  Future<void> loadDetail(int id) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _api.getSpecialtyDetail(id);

      emit(state.copyWith(isLoading: false, selectedSpecialty: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Đăng ký nghiệp vụ mới
  Future<bool> createSpecialty(CreateTechnicianSpecialtyRequest request) async {
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );

    try {
      await _api.createSpecialty(request);

      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'specialty.register_success',
        ),
      );

      await loadSpecialties();

      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));

      return false;
    }
  }

  Future<bool> updateSpecialty(
    int id,
    UpdateTechnicianSpecialtyRequest request,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _api.updateSpecialty(id, request);
      emit(state.copyWith(isSubmitting: false));
      await loadDetail(id);
      await loadSpecialties();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> deleteSpecialty(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _api.deleteSpecialty(id);
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSelectedSpecialty: true,
          successMessage: 'specialty.delete_success',
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      return false;
    }
  }
}
