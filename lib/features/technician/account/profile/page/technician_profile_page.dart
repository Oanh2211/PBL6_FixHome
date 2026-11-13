import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/technician/account/profile/api/technician_profile_api.dart';
import 'package:fixhome/features/technician/account/profile/cubit/technician_profile_cubit.dart';
import 'package:fixhome/features/technician/account/profile/cubit/technician_profile_state.dart';
import 'package:fixhome/features/technician/account/profile/model/technician_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

class TechnicianProfilePage extends StatelessWidget {
  final String technicianName;
  final String? phoneNumber;

  // Nhận từ trang upload ảnh nếu đã có chức năng upload.
  final VoidCallback? onAvatarTap;

  const TechnicianProfilePage({
    super.key,
    required this.technicianName,
    this.phoneNumber,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianProfileCubit(TechnicianProfileApi())..loadProfile(),
      child: _TechnicianProfileView(
        technicianName: technicianName,
        phoneNumber: phoneNumber,
        onAvatarTap: onAvatarTap,
      ),
    );
  }
}

class _TechnicianProfileView extends StatefulWidget {
  final String technicianName;
  final String? phoneNumber;
  final VoidCallback? onAvatarTap;

  const _TechnicianProfileView({
    required this.technicianName,
    this.phoneNumber,
    this.onAvatarTap,
  });

  @override
  State<_TechnicianProfileView> createState() => _TechnicianProfileViewState();
}

class _TechnicianProfileViewState extends State<_TechnicianProfileView> {
  final _formKey = GlobalKey<FormState>();

  final _citizenIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController();
  final _provinceController = TextEditingController();

  final _emergencyNameController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String? _gender;
  DateTime? _dateOfBirth;

  TechnicianProfileModel? _currentProfile;

  bool _initialized = false;

  @override
  void dispose() {
    _citizenIdController.dispose();
    _addressController.dispose();
    _wardController.dispose();
    _provinceController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _initializeForm(TechnicianProfileModel profile) {
    if (_initialized) return;

    _currentProfile = profile;

    _citizenIdController.text = profile.citizenId ?? '';
    _addressController.text = profile.currentAddress ?? '';
    _wardController.text = profile.currentWardCode ?? '';
    _provinceController.text = profile.currentProvinceCode ?? '';

    _emergencyNameController.text = profile.emergencyContactName ?? '';

    _emergencyRelationshipController.text =
        profile.emergencyContactRelationship ?? '';

    _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';

    _gender = profile.gender;

    if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
      _dateOfBirth = DateTime.tryParse(profile.dateOfBirth!);
    }

    _initialized = true;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'technician.common.not_updated'.tr();
    }

    return phone;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: context.locale,
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

    if (selectedDate != null) {
      setState(() {
        _dateOfBirth = selectedDate;
      });
    }
  }

  void _submitProfile() {
    if (!_formKey.currentState!.validate()) return;

    final profile = _currentProfile;

    if (profile == null) return;

    final updatedProfile = profile.copyWith(
      gender: _gender,
      dateOfBirth: _dateOfBirth == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
      citizenId: _citizenIdController.text.trim(),
      currentAddress: _addressController.text.trim(),
      currentWardCode: _wardController.text.trim(),
      currentProvinceCode: _provinceController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactRelationship: _emergencyRelationshipController.text
          .trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
    );

    context.read<TechnicianProfileCubit>().updateProfile(updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'technician.account.profile_page.title'.tr(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<TechnicianProfileCubit, TechnicianProfileState>(
        listener: (context, state) {
          if (state is TechnicianProfileLoaded) {
            _initializeForm(state.profile);
          }

          if (state is TechnicianProfileUpdateSuccess) {
            _currentProfile = state.profile;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'technician.account.profile_page.update_success'.tr(),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state is TechnicianProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, maxLines: 3),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TechnicianProfileInitial ||
              state is TechnicianProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TechnicianProfileError && _currentProfile == null) {
            return _buildError(context, state.message);
          }

          if (state is TechnicianProfileLoaded) {
            _currentProfile ??= state.profile;
          }

          if (state is TechnicianProfileUpdateSuccess) {
            _currentProfile = state.profile;
          }

          if (state is TechnicianProfileUpdating) {
            _currentProfile = state.profile;
          }

          final profile = _currentProfile;

          if (profile == null) {
            return const SizedBox.shrink();
          }

          final isUpdating = state is TechnicianProfileUpdating;

          return AbsorbPointer(
            absorbing: isUpdating,
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                    child: Column(
                      children: [
                        // Avatar và tên
                        _buildProfileHeader(profile),

                        const SizedBox(height: 12),

                        // Thông tin cá nhân
                        _buildPersonalInfo(),

                        const SizedBox(height: 12),

                        // Thông tin liên hệ khẩn cấp
                        _buildEmergencyInfo(),

                        const SizedBox(height: 16),

                        // Nút cập nhật
                        _buildUpdateButton(context),
                      ],
                    ),
                  ),
                ),

                if (isUpdating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.12),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildProfileHeader(TechnicianProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: AppColors.surfaceMuted,
                backgroundImage: profile.avatarUrl?.isNotEmpty == true
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl?.isNotEmpty == true
                    ? null
                    : const Icon(
                        Icons.person,
                        size: 35,
                        color: AppColors.textHint,
                      ),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: widget.onAvatarTap,
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.technicianName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PERSONAL INFO =================

  Widget _buildPersonalInfo() {
    return _buildCard(
      title: 'technician.account.profile_page.personal_info'.tr(),
      icon: Icons.badge_outlined,
      children: [
        // Ngày sinh
        _buildInfoBox(
          icon: Icons.calendar_month_outlined,
          label: 'technician.account.profile_page.date_of_birth'.tr(),
          child: InkWell(
            onTap: _selectDate,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateOfBirth == null
                        ? 'technician.common.select_date'.tr()
                        : '${_formatDate(_dateOfBirth)} '
                              '(${_calculateAge(_dateOfBirth!)} ${'technician.account.profile_page.age'.tr()})',
                    style: _valueStyle(),
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Giới tính
        _buildInfoBox(
          icon: Icons.person_outline,
          label: 'technician.account.profile_page.gender'.tr(),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
              child: DropdownButton<String>(
                value:
                    _gender != null &&
                        ['male', 'female', 'other'].contains(_gender)
                    ? _gender
                    : null,
                isExpanded: true,
                isDense: true,
                hint: Text(
                  'technician.common.select'.tr(),
                  style: _valueStyle(),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('technician.account.profile_page.male'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('technician.account.profile_page.female'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('technician.account.profile_page.other'.tr()),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // CCCD
        _buildTextField(
          controller: _citizenIdController,
          label: 'technician.account.profile_page.citizen_id'.tr(),
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 12),

        // Địa chỉ
        _buildTextField(
          controller: _addressController,
          label: 'technician.account.profile_page.current_address'.tr(),
          icon: Icons.location_on_outlined,
          maxLines: 1,
        ),
      ],
    );
  }

  // ================= EMERGENCY INFO =================

  Widget _buildEmergencyInfo() {
    return _buildCard(
      title: 'technician.account.profile_page.emergency_info'.tr(),
      icon: Icons.contact_emergency_outlined,
      children: [
        _buildTextField(
          controller: _emergencyNameController,
          label: 'technician.account.profile_page.emergency_name'.tr(),
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 9),
        _buildTextField(
          controller: _emergencyRelationshipController,
          label: 'technician.account.profile_page.relationship'.tr(),
          icon: Icons.people_outline,
        ),
        const SizedBox(height: 9),
        _buildTextField(
          controller: _emergencyPhoneController,
          label: 'technician.account.profile_page.emergency_phone'.tr(),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ================= CARD =================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ================= INFO BOX =================

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: _valueStyle(),
        decoration: InputDecoration(
          icon: Icon(icon, size: 16, color: AppColors.textSecondary),
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
      ),
    );
  }

  TextStyle _valueStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  // ================= UPDATE BUTTON =================

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _submitProfile,
        icon: const Icon(Icons.save_outlined, size: 16),
        label: Text(
          'technician.account.profile_page.update'.tr(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    );
  }

  int _calculateAge(DateTime date) {
    final now = DateTime.now();

    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  // ================= ERROR =================

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 45, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initialized = false;
                });

                context.read<TechnicianProfileCubit>().loadProfile();
              },
              child: Text('technician.common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
