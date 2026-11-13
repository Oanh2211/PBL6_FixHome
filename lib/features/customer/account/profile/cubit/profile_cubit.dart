import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/profile_api.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileApi profileApi;

  ProfileCubit(this.profileApi) : super(const ProfileState());

  // Lấy thông tin cá nhân
  Future<void> getProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true, isSuccess: false));

    try {
      final profile = await profileApi.getProfile();

      emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _getErrorMessage(e)));
    }
  }

  // Cập nhật họ tên
  Future<bool> updateProfile({required String fullName}) async {
    if (fullName.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'profile_name_required',
          clearError: false,
        ),
      );
      return false;
    }

    emit(state.copyWith(isUpdating: true, isSuccess: false, clearError: true));

    try {
      final updatedProfile = await profileApi.updateProfile(
        fullName: fullName.trim(),
      );

      emit(
        state.copyWith(
          profile: updatedProfile,
          isUpdating: false,
          isSuccess: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          isSuccess: false,
          errorMessage: _getErrorMessage(e),
        ),
      );

      return false;
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'profile_error';
    }

    return 'profile_error';
  }
}
