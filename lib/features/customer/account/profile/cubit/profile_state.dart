import 'package:fixhome/features/customer/account/profile/model/profile_response_model.dart';

class ProfileState {
  final ProfileResponseModel? profile;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    ProfileResponseModel? profile,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
