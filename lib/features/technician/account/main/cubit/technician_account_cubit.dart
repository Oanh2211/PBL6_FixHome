import 'package:fixhome/core/storage/storage.dart';
import 'package:fixhome/features/technician/account/main/api/technician_account_api.dart';
import 'package:fixhome/features/technician/account/main/cubit/technician_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianAccountCubit extends Cubit<TechnicianAccountState> {
  final TechnicianAccountApi _api;

  TechnicianAccountCubit(this._api) : super(const TechnicianAccountInitial());

  Future<void> loadAccount() async {
    if (isClosed) return;
    emit(const TechnicianAccountLoading());

    try {
      final account = await _api.getAccount();
      emit(TechnicianAccountLoaded(account));
    } catch (e) {
      emit(TechnicianAccountError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadAccount();
  }

  Future<void> logout() async {
    emit(const TechnicianAccountLoading());

    try {
      final refreshToken = await Storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        emit(const TechnicianAccountError('Không tìm thấy refresh token.'));
        return;
      }

      await _api.logout(refreshToken: refreshToken);

      await Storage.removeTokens();

      // Báo hiệu đăng xuất thành công để UI điều hướng.
      emit(const TechnicianAccountLogoutSuccess());
    } catch (e) {
      emit(TechnicianAccountError(e.toString()));
    }
  }
}
