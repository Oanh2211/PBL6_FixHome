import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/select_language/cubit/select_language_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(String initialLang)
    : super(LanguageInitial(selectedCode: initialLang));

  // Chọn ngôn ngữ và đổi locale ngay lập tức
  Future<void> selectLanguage(BuildContext context, String languageCode) async {
    if (state is LanguageLoading) return;

    // Cập nhật UI chọn card ngay lập tức
    emit(LanguageInitial(selectedCode: languageCode));

    // Cập nhật ngôn ngữ toàn ứng dụng
    try {
      await context.setLocale(Locale(languageCode));
    } catch (e) {
      debugPrint('Lỗi đổi ngôn ngữ: $e');
    }
  }

  // Xác nhận và chuyển trang
  void confirmLanguage(String languageCode) {
    emit(LanguageChangedSuccess(languageCode));
  }
}
