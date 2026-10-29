import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fixhome/features/auth/login/pages/loginPage.dart';

import 'package:fixhome/features/auth/register/api/register_api.dart';
import 'package:fixhome/features/auth/register/pages/register_page.dart';

import 'package:fixhome/features/auth/forgot_password/api/forgot_password_api.dart';
import 'package:fixhome/features/auth/forgot_password/page/forgot_password_page.dart';
import 'package:fixhome/features/auth/forgot_password/page/reset_password_page.dart';

import 'package:fixhome/features/select_language/page/select_language_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  final dio = Dio();

  final registerApi = RegisterApi(dio);
  final forgotPasswordApi = ForgotPasswordApi(dio);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translation',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      child: FixHomeApp(
        registerApi: registerApi,
        forgotPasswordApi: forgotPasswordApi,
      ),
    ),
  );
}

class FixHomeApp extends StatelessWidget {
  final RegisterApi registerApi;
  final ForgotPasswordApi forgotPasswordApi;

  const FixHomeApp({
    super.key,
    required this.registerApi,
    required this.forgotPasswordApi,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixHome',
      debugShowCheckedModeBanner: false,

      // Cấu hình đa ngôn ngữ.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Màn hình khởi đầu.
      home: const LanguagePage(),

      routes: {
        '/register': (context) {
          return RegisterPage(registerApi: registerApi);
        },

        '/login': (context) {
          return const LoginPage();
        },

        // Màn hình quên mật khẩu: nhập email và xác thực OTP.
        '/forgot-password': (context) {
          return ForgotPasswordPage(
            api: forgotPasswordApi,
            onBackToLogin: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          );
        },

        // Màn hình đặt lại mật khẩu.
        // Luồng chính nên mở màn hình này từ ForgotPasswordPage
        // sau khi OTP được xác thực thành công để giữ reset_token.
        '/reset-password': (context) {
          return ResetPasswordPage(
            onBackToLogin: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          );
        },
      },
    );
  }
}
