import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/technician/home/register_profile/api/catalog_api.dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/media_upload_api.dart';
import '../api/technician_registration_api.dart';

import '../cubit/technician_registration_cubit.dart';
import '../cubit/technician_registration_state.dart';

import '../models/technician_profile_request.dart';
import '../models/technician_specialty_request.dart';

class TechnicianRegistrationPage extends StatelessWidget {
  final String accountName;
  final String accountPhone;
  final String accountEmail;

  const TechnicianRegistrationPage({
    super.key,
    this.accountName = '',
    this.accountPhone = '',
    this.accountEmail = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TechnicianRegistrationCubit(
        mediaApi: MediaUploadApi(),
        registrationApi: TechnicianRegistrationApi(),
        catalogApi: CatalogApi(),
      ),
      child: TechnicianRegistrationView(
        accountName: accountName,
        accountPhone: accountPhone,
        accountEmail: accountEmail,
      ),
    );
  }
}

class TechnicianRegistrationView extends StatefulWidget {
  final String accountName;
  final String accountPhone;
  final String accountEmail;

  const TechnicianRegistrationView({
    super.key,
    this.accountName = '',
    this.accountPhone = '',
    this.accountEmail = '',
  });

  @override
  State<TechnicianRegistrationView> createState() =>
      _TechnicianRegistrationViewState();
}

class _TechnicianRegistrationViewState
    extends State<TechnicianRegistrationView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _citizenIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardCodeController = TextEditingController();

  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _birthDate;

  String _gender = 'MALE';
  String _relationship = 'SPOUSE';

  @override
  void initState() {
    super.initState();

    // Thông tin tài khoản được truyền từ màn hình trước.
    _nameController.text = widget.accountName;
    _phoneController.text = widget.accountPhone;
    _emailController.text = widget.accountEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _citizenIdController.dispose();
    _addressController.dispose();
    _wardCodeController.dispose();

    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();

    super.dispose();
  }

  // =====================================================
  // NGÀY SINH
  // =====================================================

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'technician.register_profile.birth_date'.tr(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  String get _formattedBirthDate {
    if (_birthDate == null) return '';

    return DateFormat('yyyy-MM-dd').format(_birthDate!);
  }

  String get _displayBirthDate {
    if (_birthDate == null) {
      return 'technician.register_profile.select_date'.tr();
    }

    return DateFormat('dd/MM/yyyy').format(_birthDate!);
  }

  // =====================================================
  // TẠO PROFILE REQUEST
  // =====================================================

  TechnicianProfileRequest _buildProfileRequest(
    TechnicianRegistrationState state,
  ) {
    return TechnicianProfileRequest(
      gender: _gender,
      avatarUrl: state.avatarUrl,
      dateOfBirth: _formattedBirthDate,
      citizenId: _citizenIdController.text.trim(),
      currentAddress: _addressController.text.trim(),
      currentWardCode: _wardCodeController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactRelationship: _relationship,
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      identityMediaUrls: [
        IdentityMediaRequest(
          mediaUrl: state.frontCccdUrl,
          mediaType: 'CCCD_FRONT',
        ),
        IdentityMediaRequest(
          mediaUrl: state.backCccdUrl,
          mediaType: 'CCCD_BACK',
        ),
      ],
    );
  }

  // =====================================================
  // TẠO SPECIALTY REQUEST
  // =====================================================

  TechnicianSpecialtyRequest _buildSpecialtyRequest(
    TechnicianRegistrationState state,
  ) {
    return TechnicianSpecialtyRequest(
      categoryId: state.categoryId!,
      experienceLevel: state.experienceLevel,
      acceptAllDevices: state.acceptAllDevices,
      deviceTypeIds: state.acceptAllDevices ? [] : state.selectedDeviceIds,
      evidenceUrls: state.evidenceUrls,
    );
  }

  // =====================================================
  // HIỂN THỊ THÔNG BÁO
  // =====================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
  }

  // =====================================================
  // KIỂM TRA DỮ LIỆU THEO TỪNG BƯỚC
  // =====================================================

  bool _validateCurrentStep(TechnicianRegistrationState state) {
    switch (state.currentStep) {
      case 0:
        if (_citizenIdController.text.trim().isEmpty || _birthDate == null) {
          _showMessage('technician.register_profile.fill_personal'.tr());
          return false;
        }

        return true;

      case 1:
        if (_addressController.text.trim().isEmpty ||
            _wardCodeController.text.trim().isEmpty) {
          _showMessage('technician.register_profile.fill_address'.tr());
          return false;
        }

        return true;

      case 2:
        if (_emergencyNameController.text.trim().isEmpty ||
            _emergencyPhoneController.text.trim().isEmpty) {
          _showMessage('technician.register_profile.fill_emergency'.tr());
          return false;
        }

        return true;

      case 3:
        if (state.frontCccdUrl.isEmpty || state.backCccdUrl.isEmpty) {
          _showMessage('technician.register_profile.upload_cccd'.tr());
          return false;
        }

        return true;

      case 4:
        if (state.categoryId == null) {
          _showMessage('technician.register_profile.select_category'.tr());
          return false;
        }

        if (!state.acceptAllDevices && state.selectedDeviceIds.isEmpty) {
          _showMessage('technician.register_profile.select_device'.tr());
          return false;
        }

        return true;

      default:
        return true;
    }
  }

  // =====================================================
  // KIỂM TRA TOÀN BỘ HỒ SƠ TRƯỚC KHI GỬI
  // =====================================================

  bool _validateAll(TechnicianRegistrationState state) {
    if (_citizenIdController.text.trim().isEmpty || _birthDate == null) {
      _showMessage('technician.register_profile.fill_personal'.tr());
      return false;
    }

    if (_addressController.text.trim().isEmpty ||
        _wardCodeController.text.trim().isEmpty) {
      _showMessage('technician.register_profile.fill_address'.tr());
      return false;
    }

    if (_emergencyNameController.text.trim().isEmpty ||
        _emergencyPhoneController.text.trim().isEmpty) {
      _showMessage('technician.register_profile.fill_emergency'.tr());
      return false;
    }

    if (state.avatarUrl.isEmpty ||
        state.frontCccdUrl.isEmpty ||
        state.backCccdUrl.isEmpty) {
      _showMessage('technician.register_profile.upload_required'.tr());
      return false;
    }

    if (state.categoryId == null) {
      _showMessage('technician.register_profile.select_category'.tr());
      return false;
    }

    if (!state.acceptAllDevices && state.selectedDeviceIds.isEmpty) {
      _showMessage('technician.register_profile.select_device'.tr());
      return false;
    }

    return true;
  }

  // =====================================================
  // CHUYỂN BƯỚC
  // =====================================================

  void _nextStep(TechnicianRegistrationState state) {
    if (!_validateCurrentStep(state)) return;

    context.read<TechnicianRegistrationCubit>().nextStep();
  }

  // =====================================================
  // GỬI HỒ SƠ
  // =====================================================

  Future<void> _submit(TechnicianRegistrationState state) async {
    if (!_validateAll(state)) return;

    final profile = _buildProfileRequest(state);
    final specialty = _buildSpecialtyRequest(state);

    await context.read<TechnicianRegistrationCubit>().submitRegistration(
      profile: profile,
      specialty: specialty,
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      TechnicianRegistrationCubit,
      TechnicianRegistrationState
    >(
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showMessage(state.errorMessage!);
        }

        if (state.isSuccess) {
          _showMessage('technician.register_profile.submit_success'.tr());
        }
      },
      builder: (context, state) {
        if (state.isSuccess) {
          return _buildSuccessPage();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(state),
          body: Column(
            children: [
              _buildStepper(state),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildCurrentStep(state),
                ),
              ),
              _buildBottomButton(state),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar(TechnicianRegistrationState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 19,
          color: AppColors.textPrimary,
        ),
        onPressed: state.isLoading
            ? null
            : () {
                if (state.currentStep == 0) {
                  Navigator.pop(context);
                } else {
                  context.read<TechnicianRegistrationCubit>().previousStep();
                }
              },
      ),
      title: const Text(
        'FixHome',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }

  // =====================================================
  // STEPPER
  // =====================================================

  Widget _buildStepper(TechnicianRegistrationState state) {
    const titles = [
      'technician.register_profile.personal',
      'technician.register_profile.area',
      'technician.register_profile.emergency',
      'technician.register_profile.identity',
      'technician.register_profile.specialty',
      'technician.register_profile.review',
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.register_profile.title'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(6, (index) {
              final active = index <= state.currentStep;

              return Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: active
                          ? AppColors.primary
                          : AppColors.surfaceMuted,
                      child: Icon(
                        index < state.currentStep ? Icons.check : Icons.circle,
                        size: 12,
                        color: active ? Colors.white : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      titles[index].tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CHỌN GIAO DIỆN THEO BƯỚC
  // =====================================================

  Widget _buildCurrentStep(TechnicianRegistrationState state) {
    switch (state.currentStep) {
      case 0:
        return _personalStep(state);

      case 1:
        return _areaStep();

      case 2:
        return _emergencyStep();

      case 3:
        return _identityStep(state);

      case 4:
        return _specialtyStep(state);

      case 5:
        return _reviewStep(state);

      default:
        return const SizedBox.shrink();
    }
  }

  // =====================================================
  // BƯỚC 1: THÔNG TIN CÁ NHÂN
  // =====================================================

  Widget _personalStep(TechnicianRegistrationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.personal'.tr()),

        const SizedBox(height: 16),

        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: state.isLoading
                    ? null
                    : () {
                        context
                            .read<TechnicianRegistrationCubit>()
                            .selectAvatar();
                      },
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surfaceMuted,
                  backgroundImage: state.avatarFile != null
                      ? FileImage(state.avatarFile!)
                      : null,
                  child: state.avatarFile == null
                      ? const Icon(
                          Icons.person,
                          size: 45,
                          color: AppColors.textHint,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () {
                        context
                            .read<TechnicianRegistrationCubit>()
                            .selectAvatar();
                      },
                icon: const Icon(Icons.camera_alt),
                label: Text('technician.register_profile.avatar'.tr()),
              ),
            ],
          ),
        ),

        _input(
          'technician.register_profile.full_name'.tr(),
          _nameController,
          readOnly: false,
          prefix: Icons.person_outline,
        ),

        _input(
          'technician.register_profile.phone'.tr(),
          _phoneController,
          keyboardType: TextInputType.number,
          prefix: Icons.phone_outlined,
        ),

        _input(
          'technician.register_profile.email'.tr(),
          _emailController,
          readOnly: false,
          prefix: Icons.email_outlined,
        ),

        _input(
          'technician.register_profile.citizen_id'.tr(),
          _citizenIdController,
          keyboardType: TextInputType.number,
          prefix: Icons.badge_outlined,
        ),

        _sectionTitle('technician.register_profile.birth_date'.tr()),

        _selectBox(_displayBirthDate, Icons.calendar_month, _selectBirthDate),

        _sectionTitle('technician.register_profile.gender'.tr()),

        _dropdown<String>(
          value: _gender,
          items: const {
            'MALE': 'technician.register_profile.male',
            'FEMALE': 'technician.register_profile.female',
          },
          onChanged: (value) {
            if (value == null) return;
            setState(() => _gender = value);
          },
        ),
      ],
    );
  }

  // =====================================================
  // BƯỚC 2: KHU VỰC HOẠT ĐỘNG
  // =====================================================

  Widget _areaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.area'.tr()),

        const SizedBox(height: 8),

        _input(
          'technician.register_profile.address'.tr(),
          _addressController,
          prefix: Icons.location_on_outlined,
        ),

        _input(
          'technician.register_profile.ward_code'.tr(),
          _wardCodeController,
          prefix: Icons.map_outlined,
          keyboardType: TextInputType.number,
        ),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'technician.register_profile.ward_note'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BƯỚC 3: LIÊN HỆ KHẨN CẤP
  // =====================================================

  Widget _emergencyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.emergency'.tr()),

        const SizedBox(height: 8),

        _input(
          'technician.register_profile.emergency_name'.tr(),
          _emergencyNameController,
          prefix: Icons.person_outline,
        ),

        _sectionTitle('technician.register_profile.relationship'.tr()),

        _dropdown<String>(
          value: _relationship,
          items: const {
            'SPOUSE': 'technician.register_profile.spouse',
            'PARENT': 'technician.register_profile.parent',
            'SIBLING': 'technician.register_profile.sibling',
            'OTHER': 'technician.register_profile.other',
          },
          onChanged: (value) {
            if (value == null) return;
            setState(() => _relationship = value);
          },
        ),

        const SizedBox(height: 8),

        _input(
          'technician.register_profile.emergency_phone'.tr(),
          _emergencyPhoneController,
          prefix: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // =====================================================
  // BƯỚC 4: GIẤY TỜ XÁC MINH
  // =====================================================

  Widget _identityStep(TechnicianRegistrationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.identity'.tr()),

        const SizedBox(height: 8),

        Text(
          'technician.register_profile.identity_note'.tr(),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _uploadCard(
                title: 'technician.register_profile.front_cccd'.tr(),
                file: state.frontCccdFile,
                onTap: state.isLoading
                    ? null
                    : () {
                        context
                            .read<TechnicianRegistrationCubit>()
                            .selectFrontCccd();
                      },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _uploadCard(
                title: 'technician.register_profile.back_cccd'.tr(),
                file: state.backCccdFile,
                onTap: state.isLoading
                    ? null
                    : () {
                        context
                            .read<TechnicianRegistrationCubit>()
                            .selectBackCccd();
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =====================================================
  // BƯỚC 5: CHUYÊN MÔN
  // =====================================================

  Widget _specialtyStep(TechnicianRegistrationState state) {
    final selectedCategory = state.categories.any(
      (category) => category.id == state.categoryId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.specialty'.tr()),

        const SizedBox(height: 8),

        // -------------------------
        // DANH SÁCH NGÀNH NGHỀ
        // -------------------------
        if (state.isLoadingCategories)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.categories.isEmpty)
          _catalogError(
            message: state.catalogError,
            onRetry: () {
              context.read<TechnicianRegistrationCubit>().loadCategories();
            },
          )
        else
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: selectedCategory ? state.categoryId : null,
                hint: Text(
                  'technician.register_profile.select_category'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
                items: state.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(
                      category.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: state.isLoading
                    ? null
                    : (id) {
                        if (id == null) return;

                        context
                            .read<TechnicianRegistrationCubit>()
                            .selectCategory(id);
                      },
              ),
            ),
          ),

        // -------------------------
        // KINH NGHIỆM
        // -------------------------
        _sectionTitle('technician.register_profile.experience'.tr()),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _experienceChip(state, '0-2'),
            _experienceChip(state, '3-5'),
            _experienceChip(state, '5+'),
          ],
        ),

        const SizedBox(height: 20),

        // -------------------------
        // THIẾT BỊ
        // -------------------------
        _sectionTitle('technician.register_profile.devices'.tr()),

        if (state.categoryId == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'technician.register_profile.select_category_first'.tr(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else if (state.isLoadingDevices)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.catalogError != null)
          _catalogError(
            message: state.catalogError,
            onRetry: () {
              context.read<TechnicianRegistrationCubit>().loadDeviceTypes(
                state.categoryId!,
              );
            },
          )
        else if (state.deviceTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'technician.register_profile.no_devices'.tr(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'technician.register_profile.all_devices'.tr(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            value: state.acceptAllDevices,
            activeColor: AppColors.primary,
            onChanged: state.isLoading
                ? null
                : (value) {
                    context
                        .read<TechnicianRegistrationCubit>()
                        .toggleAllDevices(value ?? false);
                  },
          ),

          ...state.deviceTypes.map((device) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(device.name, style: const TextStyle(fontSize: 13)),
              value: state.selectedDeviceIds.contains(device.id),
              activeColor: AppColors.primary,
              onChanged: state.acceptAllDevices || state.isLoading
                  ? null
                  : (_) {
                      context.read<TechnicianRegistrationCubit>().toggleDevice(
                        device.id,
                      );
                    },
            );
          }),
        ],

        const SizedBox(height: 16),

        // -------------------------
        // TÀI LIỆU MINH CHỨNG
        // -------------------------
        _sectionTitle('technician.register_profile.evidence'.tr()),

        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: state.isLoading
              ? null
              : () {
                  context.read<TechnicianRegistrationCubit>().selectEvidence();
                },
          icon: const Icon(Icons.upload_file),
          label: Text('technician.register_profile.upload_evidence'.tr()),
        ),

        ...state.evidenceUrls.asMap().entries.map((entry) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle, color: AppColors.success),
            title: Text(
              '${'technician.register_profile.evidence'.tr()} ${entry.key + 1}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: state.isLoading
                  ? null
                  : () {
                      context
                          .read<TechnicianRegistrationCubit>()
                          .removeEvidence(entry.key);
                    },
            ),
          );
        }),
      ],
    );
  }

  // =====================================================
  // LỖI DANH MỤC
  // =====================================================

  Widget _catalogError({String? message, required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message ?? 'Không thể tải dữ liệu.',
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 17),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CHIP KINH NGHIỆM
  // =====================================================

  Widget _experienceChip(TechnicianRegistrationState state, String value) {
    final selected = state.experienceLevel == value;

    String label;

    switch (value) {
      case '0-2':
        label = '0 - 2 ${'technician.register_profile.years'.tr()}';
        break;
      case '3-5':
        label = '3 - 5 ${'technician.register_profile.years'.tr()}';
        break;
      default:
        label = '> 5 ${'technician.register_profile.years'.tr()}';
    }

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryLight.withOpacity(0.2),
      onSelected: state.isLoading
          ? null
          : (_) {
              context.read<TechnicianRegistrationCubit>().selectExperience(
                value,
              );
            },
    );
  }

  // =====================================================
  // BƯỚC 6: KIỂM TRA THÔNG TIN
  // =====================================================

  Widget _reviewStep(TechnicianRegistrationState state) {
    final category = state.categories.where(
      (item) => item.id == state.categoryId,
    );

    final categoryName = category.isNotEmpty ? category.first.name : '--';

    final selectedDevices = state.acceptAllDevices
        ? 'technician.register_profile.all_devices'.tr()
        : state.deviceTypes
              .where((device) => state.selectedDeviceIds.contains(device.id))
              .map((device) => device.name)
              .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('technician.register_profile.review'.tr()),

        const SizedBox(height: 12),

        _reviewItem(
          'technician.register_profile.full_name'.tr(),
          _nameController.text,
        ),

        _reviewItem(
          'technician.register_profile.phone'.tr(),
          _phoneController.text,
        ),

        _reviewItem(
          'technician.register_profile.email'.tr(),
          _emailController.text,
        ),

        _reviewItem(
          'technician.register_profile.citizen_id'.tr(),
          _citizenIdController.text,
        ),

        _reviewItem(
          'technician.register_profile.birth_date'.tr(),
          _displayBirthDate,
        ),

        _reviewItem(
          'technician.register_profile.gender'.tr(),
          _gender == 'MALE'
              ? 'technician.register_profile.male'.tr()
              : 'technician.register_profile.female'.tr(),
        ),

        _reviewItem(
          'technician.register_profile.address'.tr(),
          _addressController.text,
        ),

        _reviewItem(
          'technician.register_profile.ward_code'.tr(),
          _wardCodeController.text,
        ),

        _reviewItem(
          'technician.register_profile.emergency_name'.tr(),
          _emergencyNameController.text,
        ),

        _reviewItem(
          'technician.register_profile.emergency_phone'.tr(),
          _emergencyPhoneController.text,
        ),

        _reviewItem('technician.register_profile.specialty'.tr(), categoryName),

        _reviewItem(
          'technician.register_profile.experience'.tr(),
          state.experienceLevel,
        ),

        _reviewItem(
          'technician.register_profile.devices'.tr(),
          selectedDevices.isEmpty ? '--' : selectedDevices,
        ),

        const SizedBox(height: 16),

        _sectionTitle('technician.register_profile.uploaded_documents'.tr()),

        _reviewDocument(
          'technician.register_profile.avatar'.tr(),
          state.avatarUrl,
        ),

        _reviewDocument(
          'technician.register_profile.front_cccd'.tr(),
          state.frontCccdUrl,
        ),

        _reviewDocument(
          'technician.register_profile.back_cccd'.tr(),
          state.backCccdUrl,
        ),

        ...state.evidenceUrls.asMap().entries.map((entry) {
          return _reviewDocument(
            '${'technician.register_profile.evidence'.tr()} ${entry.key + 1}',
            entry.value,
          );
        }),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'technician.register_profile.confirm_note'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // NÚT CUỐI TRANG
  // =====================================================

  Widget _buildBottomButton(TechnicianRegistrationState state) {
    final isLastStep = state.currentStep == 5;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (isLastStep) {
                    _submit(state);
                  } else {
                    _nextStep(state);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep
                          ? 'technician.register_profile.submit'.tr()
                          : 'common.continue'.tr(),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  // =====================================================
  // TRANG THÀNH CÔNG
  // =====================================================

  Widget _buildSuccessPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.primary,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'technician.register_profile.pending_title'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'technician.register_profile.pending_description'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('technician.register_profile.back_home'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: TIÊU ĐỀ
  // =====================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: INPUT
  // =====================================================

  Widget _input(
    String label,
    TextEditingController controller, {
    IconData? prefix,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefix != null ? Icon(prefix, size: 19) : null,
          filled: true,
          fillColor: readOnly ? AppColors.surfaceMuted : AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: CHỌN NGÀY
  // =====================================================

  Widget _selectBox(String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: DROPDOWN
  // =====================================================

  Widget _dropdown<T>({
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.entries.map((entry) {
            return DropdownMenuItem<T>(
              value: entry.key,
              child: Text(
                entry.value.tr(),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: UPLOAD ẢNH
  // =====================================================

  Widget _uploadCard({
    required String title,
    required File? file,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 155,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.success : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: file == null
                  ? const Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),

            const SizedBox(height: 4),

            Icon(
              file != null ? Icons.check_circle : Icons.add,
              color: file != null ? AppColors.success : AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: THÔNG TIN KIỂM TRA
  // =====================================================

  Widget _reviewItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value.isEmpty ? '--' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WIDGET DÙNG CHUNG: TÀI LIỆU ĐÃ UPLOAD
  // =====================================================

  Widget _reviewDocument(String title, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.primary,
      ),
      title: Text(title, style: const TextStyle(fontSize: 12)),
      trailing: Icon(
        url.isNotEmpty ? Icons.check_circle : Icons.error_outline,
        color: url.isNotEmpty ? AppColors.success : AppColors.error,
      ),
    );
  }
}
