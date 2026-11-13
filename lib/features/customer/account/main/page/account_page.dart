import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/account/change_password/page/change_password_page.dart';
import 'package:fixhome/features/customer/account/profile/page/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/account_api.dart';
import '../cubit/account_cubit.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback onLoggedOut;
  final String? accountName;
  final String? accountEmail;

  const AccountPage({
    super.key,
    required this.onLoggedOut,
    this.accountName,
    this.accountEmail,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountCubit(AccountApi()),
      child: _AccountView(
        onLoggedOut: onLoggedOut,
        accountName: accountName,
        accountEmail: accountEmail,
      ),
    );
  }
}

class _AccountView extends StatelessWidget {
  final VoidCallback onLoggedOut;
  final String? accountName;
  final String? accountEmail;

  const _AccountView({
    required this.onLoggedOut,
    this.accountName,
    this.accountEmail,
  });

  static const Color orange = Color(0xFFF97316);
  static const Color paleBlue = Color(0xFFE8F1FF);
  static const Color paleOrange = Color(0xFFFFE8DA);
  static const Color palePurple = Color(0xFFF0EAFE);
  static const Color paleGreen = Color(0xFFE0F5F0);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AccountStatus.logoutSuccess) {
          onLoggedOut();
        } else if (state.status == AccountStatus.logoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'customer.account.logout_failed'.tr(),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 12),
                  _buildReferralCard(context),
                  const SizedBox(height: 16),
                  _sectionTitle('customer.account.services'.tr()),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.badge_outlined,
                      color: AppColors.primary,
                      background: paleBlue,
                      title: 'customer.account.profile'.tr(),
                      subtitle: 'customer.account.profile_desc'.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.local_offer_outlined,
                      color: orange,
                      background: paleOrange,
                      title: 'customer.account.vouchers'.tr(),
                      subtitle: 'customer.account.vouchers_desc'.tr(),
                      badge: 'customer.account.new'.tr(),
                      onTap: () => _showMessage(
                        context,
                        'customer.account.vouchers'.tr(),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.card_giftcard_outlined,
                      color: orange,
                      background: paleOrange,
                      title: 'customer.account.referral'.tr(),
                      subtitle: 'customer.account.referral_desc'.tr(),
                      onTap: () => _showMessage(
                        context,
                        'customer.account.referral'.tr(),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _sectionTitle('customer.account.security'.tr()),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.lock_reset_outlined,
                      color: AppColors.primary,
                      background: paleBlue,
                      title: 'customer.account.change_password'.tr(),
                      subtitle: 'customer.account.change_password_desc'.tr(),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.tune_outlined,
                      color: const Color(0xFF8B78C6),
                      background: palePurple,
                      title: 'customer.account.settings'.tr(),
                      subtitle: 'customer.account.settings_desc'.tr(),
                      onTap: () => _showLanguageSheet(context),
                    ),
                    _MenuItem(
                      icon: Icons.support_agent_outlined,
                      color: const Color(0xFF1687A7),
                      background: paleGreen,
                      title: 'customer.account.support'.tr(),
                      subtitle: 'customer.account.support_desc'.tr(),
                      onTap: () => _showMessage(
                        context,
                        'customer.account.support'.tr(),
                      ),
                    ),
                  ]),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: paleBlue,
              child: Icon(
                Icons.person_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName ?? 'customer.account.default_name'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (accountEmail != null && accountEmail!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      accountEmail!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'customer.account.referral_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'customer.account.referral_content'.tr(),
                  style: const TextStyle(
                    color: Color(0xFFDCE6FF),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      _showMessage(context, 'customer.account.referral'.tr()),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'customer.account.invite_now'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildMenuItem(items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 44,
                color: AppColors.border.withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      decoration: const BoxDecoration(color: AppColors.background),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            final isLoading = state.status == AccountStatus.loggingOut;

            return OutlinedButton.icon(
              onPressed: isLoading ? null : () => _confirmLogout(context),
              icon: isLoading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded, size: 17),
              label: Text(
                isLoading
                    ? 'customer.account.logging_out'.tr()
                    : 'customer.account.logout'.tr(),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                backgroundColor: const Color(0xFFFFF1F2),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('customer.account.logout'.tr()),
        content: Text('customer.account.logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('customer.account.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AccountCubit>().logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('customer.account.logout'.tr()),
          ),
        ],
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
                'customer.account.choose_language'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                title: const Text('Tiếng Việt'),
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
                title: const Text('English'),
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

  void _showMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
}
