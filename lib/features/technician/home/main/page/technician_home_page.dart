import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/technician/home/quote/page/technician_quotes_page.dart';
import 'package:fixhome/features/technician/home/quote/page/widget/new_quotes_section.dart';
import 'package:fixhome/features/technician/home/register_profile/page/technician_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/technician_profile_api.dart';
import '../model/technician_profile_model.dart';
import '../cubit/technician_profile_cubit.dart';
import '../cubit/technician_profile_state.dart';

class TechnicianHomePage extends StatelessWidget {
  const TechnicianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianProfileCubit(api: TechnicianProfileApi())..getProfile(),
      child: const _TechnicianHomeView(),
    );
  }
}

class _TechnicianHomeView extends StatelessWidget {
  const _TechnicianHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicianProfileCubit, TechnicianProfileState>(
      builder: (context, state) {
        if (state is TechnicianProfileLoading ||
            state is TechnicianProfileInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is TechnicianProfileError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 45,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TechnicianProfileCubit>().getProfile();
                    },
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TechnicianProfileLoaded) {
          final profile = state.profile;
          final me = state.me;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<TechnicianProfileCubit>().refresh(),
            child: profile.isProfileCompleted
                ? _CompletedProfileView(profile: profile, fullName: me.fullName)
                : _IncompleteProfileView(
                    profile: profile,
                    fullName: me.fullName,
                  ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// =====================================================
// PROFILE HEADER
// =====================================================

class _ProfileHeader extends StatelessWidget {
  final TechnicianProfileModel profile;
  final String? fullName;

  const _ProfileHeader({required this.profile, this.fullName});

  @override
  Widget build(BuildContext context) {
    final displayName = fullName?.trim().isNotEmpty == true
        ? fullName!.trim()
        : 'Technician';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: profile.avatarUrl ?? '',
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(radius: 22, backgroundImage: imageProvider);
            },
            placeholder: (context, url) => const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceMuted,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(Icons.person, color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          if (profile.isProfileCompleted)
            const Row(
              children: [
                Icon(Icons.star, color: Color(0xFFF59E0B), size: 15),
                SizedBox(width: 4),
                Text(
                  '4.96',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// =====================================================
// AVAILABILITY
// =====================================================

class _AvailabilityCard extends StatelessWidget {
  final TechnicianProfileModel profile;
  final bool completed;

  const _AvailabilityCard({required this.profile, required this.completed});

  @override
  Widget build(BuildContext context) {
    final available = completed && profile.isAvailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes,
            color: available ? AppColors.success : AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed
                      ? (available
                            ? 'technician.home_page.available'.tr()
                            : 'technician.home_page.unavailable'.tr())
                      : 'technician.home_page.ready_profile'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (!completed)
                  Text(
                    'technician.home_page.complete_to_work'.tr(),
                    style: const TextStyle(
                      color: Color(0xFFFF641F),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: available,
            activeColor: AppColors.success,
            onChanged: completed
                ? (value) {
                    context.read<TechnicianProfileCubit>().toggleAvailability(
                      value,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// INCOMPLETE PROFILE
// =====================================================

class _IncompleteProfileView extends StatelessWidget {
  final TechnicianProfileModel profile;
  final String? fullName;

  const _IncompleteProfileView({required this.profile, this.fullName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _ProfileHeader(profile: profile, fullName: fullName),

        const SizedBox(height: 12),

        _AvailabilityCard(profile: profile, completed: false),

        const SizedBox(height: 12),

        // Banner hoàn thiện hồ sơ
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'technician.home_page.complete_profile'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TechnicianRegistrationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF641F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text('technician.home_page.complete_now'.tr()),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'technician.home_page.benefits'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        _BenefitCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'technician.home_page.income_benefit'.tr(),
          description: 'technician.home_page.income_description'.tr(),
        ),

        _BenefitCard(
          icon: Icons.verified_user_outlined,
          title: 'technician.home_page.insurance'.tr(),
          description: 'technician.home_page.insurance_description'.tr(),
          iconColor: const Color(0xFFFF641F),
        ),

        _BenefitCard(
          icon: Icons.near_me_outlined,
          title: 'technician.home_page.nearby_jobs'.tr(),
          description: 'technician.home_page.nearby_description'.tr(),
        ),
      ],
    );
  }
}

// =====================================================
// COMPLETED PROFILE
// =====================================================

class _CompletedProfileView extends StatefulWidget {
  final TechnicianProfileModel profile;
  final String? fullName;

  const _CompletedProfileView({required this.profile, this.fullName});

  @override
  State<_CompletedProfileView> createState() => _CompletedProfileViewState();
}

class _CompletedProfileViewState extends State<_CompletedProfileView> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final filters = [
      'technician.home_page.all'.tr(),
      'technician.home_page.today'.tr(),
      'technician.home_page.scheduled'.tr(),
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _ProfileHeader(profile: widget.profile, fullName: widget.fullName),

        const SizedBox(height: 12),

        _AvailabilityCard(profile: widget.profile, completed: true),

        const SizedBox(height: 12),

        // Thu nhập tuần
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'technician.home_page.week_income'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '5.850.000 đ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            const Icon(Icons.circle, size: 9, color: Color(0xFFFF641F)),
            const SizedBox(width: 7),
            Text(
              'technician.home_page.new_jobs'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 12),

        // Bộ lọc
        Row(
          children: List.generate(filters.length, (index) {
            final selected = selectedFilter == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFEEF0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),
        const NewQuotesSection(),
      ],
    );
  }
}

// =====================================================
// BENEFIT CARD
// =====================================================

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// JOB CARD
// =====================================================

class _JobCard extends StatelessWidget {
  final String distance;
  final IconData icon;
  final String title;
  final String location;
  final String time;

  const _JobCard({
    required this.distance,
    required this.icon,
    required this.title,
    required this.location,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'technician.home_page.customer_time'.tr(),
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Mở trang chi tiết công việc
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'technician.home_page.view_job'.tr(),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
