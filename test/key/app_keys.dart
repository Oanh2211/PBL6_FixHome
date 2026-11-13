import 'package:flutter/material.dart';

class AppKeys {
  // Login Keys (Dùng cho helper đăng nhập tự động)
  static const Key loginEmailField = Key('login_email_field');
  static const Key loginPasswordField = Key('login_password_field');
  static const Key loginButton = Key('login_button');
  // Mobile_F_01
  static const Key categorySearchField = Key('category_search_field');
  static const Key clearCategorySearchBtn = Key('clear_category_search_btn');
  static const Key categoryRetryBtn = Key('category_retry_btn');

  static const Key deviceSearchField = Key('device_search_field');
  static const Key clearDeviceSearchBtn = Key('clear_device_search_btn');
  static const Key deviceRetryBtn = Key('device_retry_btn');
  static const Key changeDeviceBtn = Key('change_device_button');
  static const Key continueDeviceBtn = Key('continue_device_button');

  static Key categoryItem(int id) => Key('category_$id');
  static Key deviceItem(int id) => Key('device_$id');

  // Mobile_F_02
  static const Key txtFullName = Key('txt_full_name');
  static const Key txtPhone = Key('txt_phone');
  static const Key txtEmail = Key('txt_email');
  static const Key btnUpdateProfile = Key('btn_update_profile');

  static const Key txtCurrentPassword = Key('txt_current_password');
  static const Key txtNewPassword = Key('txt_new_password');
  static const Key txtConfirmPassword = Key('txt_confirm_password');
  static const Key toggleEyeCurrentPwd = Key('toggle_eye_current_pwd');
  static const Key toggleEyeNewPwd = Key('toggle_eye_new_pwd');
  static const Key toggleEyeConfirmPwd = Key('toggle_eye_confirm_pwd');
  static const Key btnUpdatePassword = Key('btn_update_password');
  static const Key linkForgotPassword = Key('link_forgot_password');
}
