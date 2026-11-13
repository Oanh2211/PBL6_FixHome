import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/auth/forgot_password/api/forgot_password_api.dart';
import 'package:fixhome/features/auth/forgot_password/page/forgot_password_page.dart';
import 'package:fixhome/features/auth/forgot_password/page/reset_password_page.dart';
import 'package:fixhome/features/auth/login/api/login_api.dart';
import 'package:fixhome/features/auth/login/pages/loginPage.dart';
import 'package:fixhome/features/auth/register/api/register_api.dart';
import 'package:fixhome/features/auth/register/pages/register_page.dart';
import 'package:fixhome/features/customer/main/page/customer_main_page.dart';
import 'package:fixhome/features/select_language/page/select_language_page.dart';
import 'package:fixhome/features/technician/main/page/technician_main_page.dart';
import 'package:flutter/material.dart';

class FixHomeApp extends StatelessWidget {
  final LoginApi loginApi;
  final RegisterApi registerApi;
  final ForgotPasswordApi forgotPasswordApi;

  const FixHomeApp({
    super.key,
    required this.loginApi,
    required this.registerApi,
    required this.forgotPasswordApi,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixHome',
      debugShowCheckedModeBanner: false,

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
          return LoginPage(api: loginApi);
        },
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
        '/technician-main': (context) {
          return MainTechnicianPage();
        },
        '/customer-main': (context) {
          return MainCustomerPage();
        },
      },
    );
  }
}
