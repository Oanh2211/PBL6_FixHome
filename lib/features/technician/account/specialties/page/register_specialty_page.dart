import 'dart:io';

import 'package:fixhome/common/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/register_specialty_api.dart';
import '../models/service_category_model.dart';
import '../models/device_type_model.dart';
import '../cubit/technician_register_specialty_cubit.dart';
import '../cubit/technician_register_specialty_state.dart';

class RegisterSpecialtyPage extends StatelessWidget {
  const RegisterSpecialtyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TechnicianRegisterSpecialtyCubit(
        api: TechnicianRegisterSpecialtyApi(dio: DioClient.instance),
      )..loadCategories(),
      child: const RegisterSpecialtyView(),
    );
  }
}

class RegisterSpecialtyView extends StatefulWidget {
  const RegisterSpecialtyView({super.key});

  @override
  State<RegisterSpecialtyView> createState() => _RegisterSpecialtyViewState();
}

class _RegisterSpecialtyViewState extends State<RegisterSpecialtyView> {
  final TextEditingController _searchController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================
  // SELECT IMAGE
  // ==============================

  Future<void> _pickEvidence(int categoryId) async {
    // Không cho mở picker nhiều lần
    if (_isPickingImage) return;

    _isPickingImage = true;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (!mounted || image == null) return;

      await context.read<TechnicianRegisterSpecialtyCubit>().uploadEvidence(
        categoryId: categoryId,
        file: File(image.path),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      _isPickingImage = false;
    }
  }

  // ==============================
  // SUBMIT
  // ==============================

  Future<void> _submit() async {
    final cubit = context.read<TechnicianRegisterSpecialtyCubit>();

    final success = await cubit.submitSpecialties();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'technician.account.specialty_page.register_specialty.register_success'
                .tr(),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      TechnicianRegisterSpecialtyCubit,
      TechnicianRegisterSpecialtyState
    >(
      listener: (context, state) {
        if (state.errorMessage != null) {
          final message = state.errorMessage!;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.contains('.') ? message.tr() : message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                if (state.currentStep == 1) {
                  context
                      .read<TechnicianRegisterSpecialtyCubit>()
                      .backToStep1();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              'technician.account.specialty_page.register_specialty.register_title'
                  .tr(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // STEP INDICATOR
                _buildStepIndicator(state.currentStep),

                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: state.currentStep == 0
                              ? _buildStepOne(state)
                              : _buildStepTwo(state),
                        ),
                ),

                // BOTTOM BUTTON
                _buildBottomButton(state),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================
  // STEP INDICATOR
  // ==============================

  Widget _buildStepIndicator(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _stepItem(
            number: '1',
            title: 'technician.account.specialty_page.register_specialty.step_1'
                .tr(),
            active: currentStep == 0,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep == 1 ? AppColors.primary : AppColors.border,
            ),
          ),
          _stepItem(
            number: '2',
            title: 'technician.account.specialty_page.register_specialty.step_2'
                .tr(),
            active: currentStep == 1,
          ),
        ],
      ),
    );
  }

  Widget _stepItem({
    required String number,
    required String title,
    required bool active,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted,
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==============================
  // STEP 1
  // ==============================

  Widget _buildStepOne(TechnicianRegisterSpecialtyState state) {
    return SingleChildScrollView(
      key: const ValueKey('step_one'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.account.specialty_page.register_specialty.select_title'
                .tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'technician.account.specialty_page.register_specialty.select_description'
                .tr(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          // SEARCH
          TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<TechnicianRegisterSpecialtyCubit>().searchCatalog(
                value,
              );
            },
            decoration: InputDecoration(
              hintText:
                  'technician.account.specialty_page.register_specialty.search_hint'
                      .tr(),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<TechnicianRegisterSpecialtyCubit>()
                            .searchCatalog('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'technician.account.specialty_page.register_specialty.category_title'
                    .tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${state.selectedCategoryIds.length} ${'technician.account.specialty_page.register_specialty.selected'.tr()}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (state.categories.isEmpty)
            _emptyWidget(
              'technician.account.specialty_page.register_specialty.empty_categories'
                  .tr(),
            )
          else
            ...state.categories.map(
              (category) => _buildCategoryCard(category, state),
            ),
        ],
      ),
    );
  }

  // ==============================
  // CATEGORY CARD
  // ==============================

  Widget _buildCategoryCard(
    ServiceCategoryModel category,
    TechnicianRegisterSpecialtyState state,
  ) {
    final cubit = context.read<TechnicianRegisterSpecialtyCubit>();

    final selected = state.selectedCategoryIds.contains(category.id);

    final expanded = state.expandedCategoryIds.contains(category.id);

    final devices = state.devicesByCategory[category.id] ?? [];

    final selectedDevices = state.selectedDeviceIds[category.id] ?? {};

    final acceptAll = state.acceptAllDevices[category.id] ?? false;

    final loading = state.loadingDeviceCategoryIds.contains(category.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              cubit.toggleCategory(category.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _categoryIcon(category.iconUrl),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  Checkbox(
                    value: selected,
                    activeColor: AppColors.primary,
                    onChanged: (_) {
                      cubit.toggleCategory(category.id);
                    },
                  ),
                ],
              ),
            ),
          ),

          if (selected)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                children: [
                  const Divider(color: AppColors.border),

                  InkWell(
                    onTap: () {
                      cubit.toggleExpandCategory(category.id);
                    },
                    child: Row(
                      children: [
                        Text(
                          'technician.account.specialty_page.register_specialty.choose_devices'
                              .tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  if (expanded) ...[
                    const SizedBox(height: 10),

                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else ...[
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          tileColor: Colors.transparent,
                          title: Text(
                            'technician.account.specialty_page.register_specialty.accept_all_devices'
                                .tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          value: acceptAll,
                          onChanged: (value) {
                            cubit.toggleAcceptAllDevices(
                              category.id,
                              value ?? false,
                            );
                          },
                        ),
                      ),

                      if (devices.isEmpty)
                        _emptyWidget(
                          'technician.account.specialty_page.register_specialty.empty_devices'
                              .tr(),
                        )
                      else
                        ...devices.map(
                          (device) => _buildDeviceItem(
                            category.id,
                            device,
                            selectedDevices,
                            acceptAll,
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(
    int categoryId,
    DeviceTypeModel device,
    Set<int> selectedDevices,
    bool acceptAll,
  ) {
    return Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.only(left: 8),
        dense: true,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        tileColor: Colors.transparent,
        title: Text(
          device.name,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
        value: acceptAll || selectedDevices.contains(device.id),
        onChanged: acceptAll
            ? null
            : (_) {
                context.read<TechnicianRegisterSpecialtyCubit>().toggleDevice(
                  categoryId,
                  device.id,
                );
              },
      ),
    );
  }

  // ==============================
  // STEP 2
  // ==============================

  Widget _buildStepTwo(TechnicianRegisterSpecialtyState state) {
    final categories = state.categories
        .where((e) => state.selectedCategoryIds.contains(e.id))
        .toList();

    return SingleChildScrollView(
      key: const ValueKey('step_two'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.account.specialty_page.register_specialty.experience_title'
                .tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'technician.account.specialty_page.register_specialty.experience_description'
                .tr(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          ...categories.map(
            (category) => _buildExperienceCard(category, state),
          ),
        ],
      ),
    );
  }

  // ==============================
  // EXPERIENCE CARD
  // ==============================

  Widget _buildExperienceCard(
    ServiceCategoryModel category,
    TechnicianRegisterSpecialtyState state,
  ) {
    final experience = state.experienceLevels[category.id];

    final evidence = state.evidenceUrls[category.id] ?? [];

    final uploading = state.uploadingCategoryIds.contains(category.id);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'technician.account.specialty_page.register_specialty.experience_question'
                .tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: [
              _experienceChip(
                category.id,
                'technician.account.specialty_page.register_specialty.under_2_years'
                    .tr(),
                'UNDER_2_YEARS',
                experience,
              ),
              _experienceChip(
                category.id,
                'technician.account.specialty_page.register_specialty.3_5_years'
                    .tr(),
                '3_5_YEARS',
                experience,
              ),
              _experienceChip(
                category.id,
                'technician.account.specialty_page.register_specialty.over_5_years'
                    .tr(),
                'OVER_5_YEARS',
                experience,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.primary,
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'technician.account.specialty_page.register_specialty.certificate_title'
                      .tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'technician.account.specialty_page.register_specialty.optional'
                    .tr(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          InkWell(
            onTap: uploading ? null : () => _pickEvidence(category.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.upload_file,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'technician.account.specialty_page.register_specialty.upload_certificate'
                          .tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (uploading)
                    const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.add, color: AppColors.primary),
                ],
              ),
            ),
          ),

          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 12),

            Text(
              'technician.account.specialty_page.register_specialty.uploaded_certificates'
                  .tr(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            ...evidence.map((url) => _buildEvidenceItem(category.id, url)),
          ],
        ],
      ),
    );
  }

  Widget _experienceChip(
    int categoryId,
    String label,
    String value,
    String? selected,
  ) {
    final isSelected = selected == value;

    return InkWell(
      onTap: () {
        context.read<TechnicianRegisterSpecialtyCubit>().setExperienceLevel(
          categoryId,
          value,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceItem(int categoryId, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<TechnicianRegisterSpecialtyCubit>().removeEvidence(
                categoryId,
                url,
              );
            },
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  // ==============================
  // BOTTOM BUTTON
  // ==============================

  Widget _buildBottomButton(TechnicianRegisterSpecialtyState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: state.isSubmitting
              ? null
              : () {
                  if (state.currentStep == 0) {
                    context
                        .read<TechnicianRegisterSpecialtyCubit>()
                        .validateStep1();
                  } else {
                    _submit();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.textHint,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: state.isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.currentStep == 0
                          ? 'technician.account.specialty_page.register_specialty.continue'
                                .tr()
                          : 'technician.account.specialty_page.register_specialty.submit'
                                .tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
    );
  }

  // ==============================
  // COMMON WIDGETS
  // ==============================

  Widget _categoryIcon(String url) {
    if (url.isEmpty) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.home_repair_service_outlined,
          color: AppColors.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Image.network(
        url,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.home_repair_service_outlined,
            color: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _emptyWidget(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
