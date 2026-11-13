import 'package:fixhome/features/technician/account/profile/api/technician_profile_api.dart';
import 'package:fixhome/features/technician/account/profile/cubit/technician_profile_state.dart';
import 'package:fixhome/features/technician/account/profile/model/technician_profile_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianProfileCubit extends Cubit<TechnicianProfileState> {
  final TechnicianProfileApi _api;

  TechnicianProfileCubit(this._api) : super(const TechnicianProfileInitial());

  Future<void> loadProfile() async {
    emit(const TechnicianProfileLoading());

    try {
      final profile = await _api.getProfile();

      emit(TechnicianProfileLoaded(profile));
    } catch (e) {
      emit(TechnicianProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(TechnicianProfileModel profile) async {
    emit(TechnicianProfileUpdating(profile));

    try {
      final updatedProfile = await _api.updateProfile(profile);

      emit(TechnicianProfileUpdateSuccess(updatedProfile));
    } catch (e) {
      emit(TechnicianProfileError(e.toString()));
    }
  }
}
