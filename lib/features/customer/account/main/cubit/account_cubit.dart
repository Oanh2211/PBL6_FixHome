import 'package:fixhome/core/storage/storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/account_api.dart';

enum AccountStatus { initial, loggingOut, logoutSuccess, logoutFailure }

class AccountState {
  final AccountStatus status;
  final String? errorMessage;

  const AccountState({this.status = AccountStatus.initial, this.errorMessage});

  AccountState copyWith({AccountStatus? status, String? errorMessage}) {
    return AccountState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class AccountCubit extends Cubit<AccountState> {
  final AccountApi accountApi;

  AccountCubit(this.accountApi) : super(const AccountState());

  Future<void> logout() async {
    if (state.status == AccountStatus.loggingOut) return;

    emit(state.copyWith(status: AccountStatus.loggingOut, errorMessage: null));

    try {
      final refreshToken = await Storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        emit(
          const AccountState(
            status: AccountStatus.logoutFailure,
            errorMessage: 'Không tìm thấy refresh token.',
          ),
        );
        return;
      }

      await accountApi.logout(refreshToken: refreshToken);

      await Storage.removeTokens();

      emit(const AccountState(status: AccountStatus.logoutSuccess));
    } catch (e) {
      emit(
        AccountState(
          status: AccountStatus.logoutFailure,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') || message.contains('connection')) {
      return 'Không thể kết nối máy chủ. Vui lòng thử lại.';
    }

    return 'Đăng xuất thất bại. Vui lòng thử lại.';
  }
}
