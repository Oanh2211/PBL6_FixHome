import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/select_language/cubit/select_language_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(String initialLang)
    : super(LanguageInitial(selectedCode: initialLang));

  // Hàm chọn ngôn ngữ (chưa bấm Tiếp tục)
  void selectLanguage(String languageCode) {
    emit(LanguageInitial(selectedCode: languageCode));
  }

  // Hàm xác nhận đổi ngôn ngữ và chuyển trang
  Future<void> confirmLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    emit(const LanguageLoading());

    // Cập nhật ngôn ngữ qua thư viện easy_localization
    if (languageCode == 'vi') {
      await context.setLocale(const Locale('vi'));
    } else {
      await context.setLocale(const Locale('en'));
    }

    emit(LanguageChangedSuccess(languageCode));
  }
}
