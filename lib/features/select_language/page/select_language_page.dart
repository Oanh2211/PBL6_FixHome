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
              Navigator.pushNamed(context, '/register');
            }
          },
          builder: (context, state) {
            final String currentSelected = state is LanguageInitial
                ? state.selectedCode
                : (state is LanguageChangedSuccess ? state.selectedCode : 'vi');

            final bool isLoading = state is LanguageLoading;

            return Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(color: AppColors.surface),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/logo_fixhome.png',
                          width: 25,
                          height: 25,
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
                ),

                // PHẦN NỘI DUNG
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Nội dung có thể cuộn
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 24),

                                // ICON LANGUAGE
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.translate,
                                    color: AppColors.primary,
                                    size: 36,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TITLE
                                Text(
                                  'select_language_page.title'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // VIETNAMESE
                                _buildLanguageCard(
                                  context: context,
                                  code: 'vi',
                                  title: 'select_language_page.vietnamese'.tr(),
                                  isSelected: currentSelected == 'vi',
                                ),

                                const SizedBox(height: 16),

                                // ENGLISH
                                _buildLanguageCard(
                                  context: context,
                                  code: 'en',
                                  title: 'select_language_page.english'.tr(),
                                  isSelected: currentSelected == 'en',
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // BUTTON CONTINUE
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<LanguageCubit>()
                                        .confirmLanguage(currentSelected);
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'select_language_page.continue'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // LANGUAGE CARD
  Widget _buildLanguageCard({
    required BuildContext context,
    required String code,
    required String title,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<LanguageCubit>().selectLanguage(context, code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.borderFocused : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // LANGUAGE CODE
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

            // LANGUAGE NAME
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // CHECK ICON
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
