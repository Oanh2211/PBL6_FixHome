import 'package:equatable/equatable.dart';
import 'package:fixhome/features/technician/home/main/model/me_model.dart';

import '../model/technician_profile_model.dart';

abstract class TechnicianProfileState extends Equatable {
  const TechnicianProfileState();

  @override
  List<Object?> get props => [];
}

class TechnicianProfileInitial extends TechnicianProfileState {}

class TechnicianProfileLoading extends TechnicianProfileState {}

class TechnicianProfileLoaded extends TechnicianProfileState {
  final TechnicianProfileModel profile;
  final MeModel me;

  const TechnicianProfileLoaded(this.profile, this.me);

  @override
  List<Object?> get props => [profile, me];
}

class TechnicianProfileError extends TechnicianProfileState {
  final String message;

  const TechnicianProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
