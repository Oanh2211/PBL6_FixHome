import 'package:equatable/equatable.dart';
import 'package:fixhome/features/technician/account/profile/model/technician_profile_model.dart';

abstract class TechnicianProfileState extends Equatable {
  const TechnicianProfileState();

  @override
  List<Object?> get props => [];
}

class TechnicianProfileInitial extends TechnicianProfileState {
  const TechnicianProfileInitial();
}

class TechnicianProfileLoading extends TechnicianProfileState {
  const TechnicianProfileLoading();
}

class TechnicianProfileLoaded extends TechnicianProfileState {
  final TechnicianProfileModel profile;

  const TechnicianProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TechnicianProfileUpdating extends TechnicianProfileState {
  final TechnicianProfileModel profile;

  const TechnicianProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TechnicianProfileUpdateSuccess extends TechnicianProfileState {
  final TechnicianProfileModel profile;

  const TechnicianProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TechnicianProfileError extends TechnicianProfileState {
  final String message;

  const TechnicianProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
