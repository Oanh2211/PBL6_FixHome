import 'package:equatable/equatable.dart';
import 'package:fixhome/features/technician/account/main/model/technician_account_model.dart';

abstract class TechnicianAccountState extends Equatable {
  const TechnicianAccountState();

  @override
  List<Object?> get props => [];
}

class TechnicianAccountInitial extends TechnicianAccountState {
  const TechnicianAccountInitial();
}

class TechnicianAccountLoading extends TechnicianAccountState {
  const TechnicianAccountLoading();
}

class TechnicianAccountLoaded extends TechnicianAccountState {
  final TechnicianAccountModel account;

  const TechnicianAccountLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

class TechnicianAccountError extends TechnicianAccountState {
  final String message;

  const TechnicianAccountError(this.message);

  @override
  List<Object?> get props => [message];
}

// LOGOUT SUCCESS
class TechnicianAccountLogoutSuccess extends TechnicianAccountState {
  const TechnicianAccountLogoutSuccess();
}
