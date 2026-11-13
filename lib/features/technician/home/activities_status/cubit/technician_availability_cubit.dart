import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../api/technician_availability_api.dart';
import '../model/technician_location_model.dart';
import '../model/technician_availability_model.dart';
import 'technician_availability_state.dart';

class TechnicianAvailabilityCubit extends Cubit<TechnicianAvailabilityState> {
  final TechnicianAvailabilityApi api;

  TechnicianAvailabilityCubit({required this.api})
    : super(const TechnicianAvailabilityState());

  // Đồng bộ trạng thái ban đầu từ profile API
  void initializeAvailability(bool value) {
    if (state.isAvailable == null) {
      emit(state.copyWith(isAvailable: value));
    }
  }

  // BẬT NHẬN VIỆC
  Future<void> enableAvailability({
    required TechnicianLocationModel location,
  }) async {
    emit(
      state.copyWith(
        status: TechnicianAvailabilityStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      // API 1: Cập nhật vị trí
      print('========== MATCHING LOCATION ==========');
      print('Latitude: ${location.latitude}');
      print('Longitude: ${location.longitude}');
      print('Source: ${location.locationSource}');

      await api.updateMatchingLocation(location);

      print('MATCHING LOCATION SUCCESS');

      // API 2: Bật nhận việc
      print('========== UPDATE AVAILABILITY ==========');

      await api.updateAvailability(
        const TechnicianAvailabilityModel(isAvailable: true),
      );

      print('UPDATE AVAILABILITY SUCCESS');

      emit(
        state.copyWith(
          status: TechnicianAvailabilityStatus.success,
          isAvailable: true,
          successMessage: 'technician.availability.enable_success'.tr(),
        ),
      );
    } catch (e, stackTrace) {
      print('========== AVAILABILITY ERROR ==========');
      print('ERROR: $e');
      print('STACKTRACE: $stackTrace');

      if (e is DioException) {
        print('STATUS CODE: ${e.response?.statusCode}');
        print('RESPONSE DATA: ${e.response?.data}');
        print('REQUEST URL: ${e.requestOptions.uri}');
        print('REQUEST BODY: ${e.requestOptions.data}');
      }

      emit(
        state.copyWith(
          status: TechnicianAvailabilityStatus.failure,
          isAvailable: false,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  // TẮT NHẬN VIỆC
  Future<void> disableAvailability() async {
    emit(
      state.copyWith(
        status: TechnicianAvailabilityStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await api.updateAvailability(
        const TechnicianAvailabilityModel(isAvailable: false),
      );

      emit(
        state.copyWith(
          status: TechnicianAvailabilityStatus.success,
          isAvailable: false,
          successMessage: 'technician.availability.disable_success'.tr(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechnicianAvailabilityStatus.failure,
          isAvailable: true,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        return data['message']?.toString() ??
            data['detail']?.toString() ??
            'technician.availability.error'.tr();
      }

      return error.message ?? 'technician.availability.error'.tr();
    }

    return 'technician.availability.error'.tr();
  }

  void clearFeedback() {
    emit(
      state.copyWith(
        status: TechnicianAvailabilityStatus.initial,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}
