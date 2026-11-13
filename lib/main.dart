import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/app.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/auth/login/api/login_api.dart';
import 'package:flutter/material.dart';
import 'package:fixhome/features/auth/register/api/register_api.dart';
import 'package:fixhome/features/auth/forgot_password/api/forgot_password_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  final loginApi = LoginApi(DioClient.instance);
  final registerApi = RegisterApi(DioClient.instance);
  final forgotPasswordApi = ForgotPasswordApi(DioClient.instance);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translation',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      child: FixHomeApp(
        loginApi: loginApi,
        registerApi: registerApi,
        forgotPasswordApi: forgotPasswordApi,
      ),
    ),
  );
}
