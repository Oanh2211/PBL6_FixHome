// lib/features/settings/language/pages/language_page.dart
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/select_language/cubit/select_language_cubit.dart';
import 'package:fixhome/features/select_language/cubit/select_language_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;

    return BlocProvider(
      create: (context) => LanguageCubit(currentLang),
      child: const _LanguageView(),
    );
  }
}

class _LanguageView extends StatelessWidget {
  const _LanguageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<LanguageCubit, LanguageState>(
          listener: (context, state) {
            if (state is LanguageChangedSuccess) {
              Navigator.pushReplacementNamed(context, '/register');
            }
          },
          builder: (context, state) {
            final String currentSelected = state is LanguageInitial
                ? state.selectedCode
                : (state is LanguageChangedSuccess ? state.selectedCode : 'vi');

            final bool isLoading = state is LanguageLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FixHome',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 2. Icon chuyển ngữ ở giữa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.translate,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Tiêu đề "Chọn ngôn ngữ"
                  const Text(
                    'Chọn ngôn ngữ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Card Lựa chọn Tiếng Việt
                  _buildLanguageCard(
                    context: context,
                    code: 'vi',
                    title: 'Tiếng Việt',
                    subtitle: 'Vietnamese',
                    isSelected: currentSelected == 'vi',
                  ),
                  const SizedBox(height: 16),

                  // 5. Card Lựa chọn English
                  _buildLanguageCard(
                    context: context,
                    code: 'en',
                    title: 'English',
                    subtitle: 'Tiếng Anh',
                    isSelected: currentSelected == 'en',
                  ),

                  const Spacer(),

                  // 6. Nút Tiếp tục / Continue
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<LanguageCubit>().confirmLanguage(
                                context,
                                currentSelected,
                              );
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tiếp tục / Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget con tạo Card chọn ngôn ngữ
  Widget _buildLanguageCard({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<LanguageCubit>().selectLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.borderFocused : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ô chứa chữ VI / EN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Tên ngôn ngữ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Radio/Check Icon
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
