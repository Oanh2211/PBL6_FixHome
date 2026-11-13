import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/profile_api.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(ProfileApi())..getProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, dynamic>> _addresses = [
    {
      'title': 'customer.account.profile_page.profile_home',
      'address': 'Số 18 Duy Tân, Dịch Vọng Hậu, Cầu Giấy, Hà Nội',
      'isDefault': true,
      'icon': Icons.home_outlined,
    },
    {
      'title': 'customer.account.profile_page.profile_office',
      'address': 'Tòa FPT Tower, Phạm Văn Bạch, Cầu Giấy, Hà Nội',
      'isDefault': false,
      'icon': Icons.apartment_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateProfile() async {
    final cubit = context.read<ProfileCubit>();

    final success = await cubit.updateProfile(fullName: _nameController.text);

    if (!mounted) return;

    if (success) {
      _showMessage('customer.account.profile_page.profile_update_success'.tr());
    } else {
      final error = cubit.state.errorMessage;

      _showMessage(
        error == null
            ? 'customer.account.profile_page.profile_error'.tr()
            : error.tr(),
        isError: true,
      );
    }
  }

  void _showAddressNotice() {
    _showMessage(
      'customer.account.profile_page.profile_address_not_supported'.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.profile?.fullName != current.profile?.fullName &&
          current.profile != null,
      listener: (context, state) {
        _nameController.text = state.profile!.fullName;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 19,
              color: AppColors.textPrimary,
            ),
          ),
          title: Text(
            'customer.account.profile_page.profile_title'.tr(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.profile == null) {
              return _buildError(state);
            }

            final profile = state.profile!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PERSONAL INFORMATION
                  _buildSection(
                    title: 'customer.account.profile_page.profile_personal_info'
                        .tr(),
                    icon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInput(
                          key: const Key('txt_full_name'),
                          label:
                              'customer.account.profile_page.profile_full_name'
                                  .tr(),
                          controller: _nameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          key: const Key('txt_phone'),
                          label: 'customer.account.profile_page.profile_phone'
                              .tr(),
                          initialValue: profile.phoneNumber,
                          icon: Icons.phone_iphone,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          key: const Key('txt_email'),
                          label: 'customer.account.profile_page.profile_email'
                              .tr(),
                          initialValue: profile.email,
                          icon: Icons.mail_outline,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ADDRESS SECTION
                  _buildSection(
                    title:
                        'customer.account.profile_page.profile_address_section'
                            .tr(),
                    icon: Icons.location_on_outlined,
                    trailing: Text(
                      '${_addresses.length} ${'customer.account.profile_page.profile_address_count'.tr()}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Column(
                      children: [
                        ..._addresses.map(
                          (address) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildAddressCard(address),
                          ),
                        ),

                        // ADD NEW ADDRESS
                        SizedBox(
                          width: double.infinity,
                          height: 43,
                          child: OutlinedButton.icon(
                            onPressed: _showAddressNotice,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                            ),
                            label: Text(
                              'customer.account.profile_page.profile_add_address'
                                  .tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceMuted,
                              side: BorderSide(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.6,
                                ),
                                style: BorderStyle.solid,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // UPDATE PROFILE
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('btn_update_profile'),
                      onPressed: state.isUpdating ? null : _updateProfile,
                      icon: state.isUpdating
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 17),
                      label: Text(
                        state.isUpdating
                            ? 'customer.account.profile_page.profile_updating'
                                  .tr()
                            : 'customer.account.profile_page.profile_update'
                                  .tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryDark
                            .withValues(alpha: 0.6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // SECTION CONTAINER
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 17),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  // INPUT FIELD
  Widget _buildInput({
    required String label,
    IconData? icon,
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    Key? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          key: key,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: readOnly,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: Icon(icon, size: 16, color: AppColors.textHint),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 35,
              minHeight: 35,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // ADDRESS CARD
  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(address['icon'] as IconData, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      (address['title'] as String).tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (address['isDefault'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'customer.account.profile_page.profile_default'.tr(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address['address'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showAddressNotice,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _showAddressNotice,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.delete_outline,
              size: 15,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR VIEW
  Widget _buildError(ProfileState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 45),
            const SizedBox(height: 12),
            Text(
              state.errorMessage == null
                  ? 'customer.account.profile_page.profile_error'.tr()
                  : state.errorMessage!.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileCubit>().getProfile();
              },
              child: Text('customer.account.profile_page.profile_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
