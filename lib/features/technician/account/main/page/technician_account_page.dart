import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/technician/account/change_password/page/change_password_page.dart';

import 'package:fixhome/features/technician/account/main/api/technician_account_api.dart';
import 'package:fixhome/features/technician/account/main/cubit/technician_account_cubit.dart';
import 'package:fixhome/features/technician/account/main/cubit/technician_account_state.dart';

import 'package:fixhome/features/technician/account/profile/page/technician_profile_page.dart';
import 'package:fixhome/features/technician/account/specialties/page/technician_specialty_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianAccountPage extends StatelessWidget {
  const TechnicianAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianAccountCubit(TechnicianAccountApi())..loadAccount(),
      child: const _TechnicianAccountView(),
    );
  }
}

class _TechnicianAccountView extends StatelessWidget {
  const _TechnicianAccountView();

  // ================= LOGOUT CONFIRMATION =================

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'technician.account.logout_confirm_title'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'technician.account.logout_confirm_message'.tr(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'technician.account.logout'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.read<TechnicianAccountCubit>().logout();
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechnicianAccountCubit, TechnicianAccountState>(
      listener: (context, state) {
        if (state is TechnicianAccountLogoutSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }

        if (state is TechnicianAccountError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<TechnicianAccountCubit, TechnicianAccountState>(
          builder: (context, state) {
            if (state is TechnicianAccountLoading ||
                state is TechnicianAccountInitial ||
                state is TechnicianAccountLogoutSuccess) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is TechnicianAccountError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TechnicianAccountCubit>().loadAccount();
                        },
                        child: Text('common.retry'.tr()),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TechnicianAccountLoaded) {
              final account = state.account;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () {
                  return context.read<TechnicianAccountCubit>().refresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // THÔNG TIN TÀI KHOẢN
                      _buildProfileHeader(
                        name: account.fullName,
                        avatarUrl: account.avatarUrl,
                      ),

                      const SizedBox(height: 12),

                      // VÍ VÀ TÀI CHÍNH
                      _buildSection(
                        title: 'technician.account.finance'.tr(),
                        trailing: _buildTextButton(
                          'technician.account.detail'.tr(),
                          () {},
                        ),
                        children: [
                          _buildWalletBalance(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'technician.account.history'.tr(),
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: 'technician.account.withdraw'.tr(),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TIỆN ÍCH NGHIỆP VỤ
                      _buildSection(
                        title: 'technician.account.utilities'.tr(),
                        children: [
                          _buildMenuItem(
                            icon: Icons.link,
                            title: 'technician.account.linked_accounts'.tr(),
                            subtitle: 'technician.account.linked_accounts_desc'
                                .tr(),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            title: 'technician.account.work_area'.tr(),
                            subtitle: 'technician.account.work_area_desc'.tr(),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.calendar_month_outlined,
                            title: 'technician.account.work_schedule'.tr(),
                            subtitle: 'technician.account.work_schedule_desc'
                                .tr(),
                            onTap: () {},
                          ),

                          // CHỨNG CHỈ VÀ HỒ SƠ PHÁP LÝ
                          _buildMenuItem(
                            icon: Icons.badge_outlined,
                            title: 'technician.account.certificates'.tr(),
                            subtitle: 'technician.account.certificates_desc'
                                .tr(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TechnicianProfilePage(
                                    technicianName: account.fullName ?? '',
                                  ),
                                ),
                              );
                            },
                          ),

                          // QUẢN LÝ NGHIỆP VỤ
                          _buildMenuItem(
                            icon: Icons.work_outline,
                            title: 'technician.account.professional_records'
                                .tr(),
                            subtitle:
                                'technician.account.professional_records_desc'
                                    .tr(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TechnicianSpecialtyPage(),
                                ),
                              );
                            },
                            showDivider: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CÀI ĐẶT VÀ HỖ TRỢ
                      _buildSection(
                        title: 'technician.account.settings_support'.tr(),
                        children: [
                          _buildMenuItem(
                            icon: Icons.support_agent_outlined,
                            title: 'technician.account.support'.tr(),
                            subtitle: 'technician.account.support_desc'.tr(),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.policy_outlined,
                            title: 'technician.account.terms'.tr(),
                            subtitle: 'technician.account.terms_desc'.tr(),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.tune_outlined,
                            title: 'technician.account.settings'.tr(),
                            subtitle: 'technician.account.settings_desc'.tr(),
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.language,
                            title: 'technician.account.language'.tr(),
                            subtitle: 'technician.account.language_desc'.tr(),
                            onTap: () => _showLanguageSheet(context),
                          ),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'technician.account.change_password'.tr(),
                            subtitle: 'technician.account.change_password_desc'
                                .tr(),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePasswordPage(),
                              ),
                            ),
                            showDivider: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ĐĂNG XUẤT
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'technician.account.choose_language'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                title: Text('technician.account.language_vietnamese'.tr()),
                trailing: context.locale.languageCode == 'vi'
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await context.setLocale(const Locale('vi'));
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: Text('technician.account.language_english'.tr()),
                trailing: context.locale.languageCode == 'en'
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await context.setLocale(const Locale('en'));
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _buildProfileHeader({
    required String? name,
    required String? avatarUrl,
  }) {
    final displayName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : 'technician.account.default_name'.tr();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.surfaceMuted,
                backgroundImage: avatarUrl?.trim().isNotEmpty == true
                    ? NetworkImage(avatarUrl!.trim())
                    : null,
                child: avatarUrl?.trim().isNotEmpty == true
                    ? null
                    : const Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.textHint,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SECTION =================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ================= WALLET =================

  Widget _buildWalletBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'technician.account.current_balance'.tr(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '1.000.000đ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= MENU ITEM =================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.surfaceMuted),
      ],
    );
  }

  // ================= LOGOUT =================

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: const Color(0xFFFDECEF),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _showLogoutConfirmation(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppColors.error, size: 16),
              const SizedBox(width: 7),
              Text(
                'technician.account.logout'.tr(),
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
