import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/technician_profile_api.dart';
import 'technician_profile_state.dart';

class TechnicianProfileCubit extends Cubit<TechnicianProfileState> {
  final TechnicianProfileApi api;

  TechnicianProfileCubit({required this.api})
    : super(TechnicianProfileInitial());

  Future<void> getProfile() async {
    emit(TechnicianProfileLoading());

    try {
      print('========== GET TECHNICIAN PROFILE ==========');

      final profile = await api.getTechnicianProfile();

      print('PROFILE SUCCESS');
      print('Gender: ${profile.gender}');
      print('Avatar: ${profile.avatarUrl}');

      print('========== GET ME ==========');

      final me = await api.getMe();

      print('ME SUCCESS');
      print('Full name: ${me.fullName}');
      print('Role: ${me.role}');

      emit(TechnicianProfileLoaded(profile, me));
    } catch (e, stackTrace) {
      print('========== PROFILE ERROR ==========');
      print(e);
      print(stackTrace);

      emit(
        TechnicianProfileError(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  // Cập nhật trạng thái nhận việc trên UI
  void toggleAvailability(bool value) {
    if (state is! TechnicianProfileLoaded) return;

    final currentState = state as TechnicianProfileLoaded;

    final updatedProfile = currentState.profile.copyWith(isAvailable: value);

    emit(TechnicianProfileLoaded(updatedProfile, currentState.me));
  }

  Future<void> refresh() async {
    await getProfile();
  }
}
