import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Lỗi từ phía Server / API trả về (4xx, 5xx, backend validation, v.v.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Đã có lỗi xảy ra từ máy chủ'])
    : super(message);
}

// Lỗi kết nối mạng (mất Internet, timeout kết nối)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối Internet'])
    : super(message);
}

// Lỗi đọc/ghi bộ nhớ cục bộ (SharedPreferences, SecureStorage, Cache)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi truy xuất bộ nhớ tạm'])
    : super(message);
}

// Lỗi xác thực hoặc hết hạn phiên đăng nhập
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Phiên đăng nhập đã hết hạn'])
    : super(message);
}
