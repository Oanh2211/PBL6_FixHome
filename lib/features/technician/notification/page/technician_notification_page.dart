import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/technician/account/profile/page/technician_profile_page.dart';
import 'package:fixhome/features/technician/activity/page/technician_order_detail_page.dart';
import 'package:fixhome/features/technician/home/quote/page/technician_quotes_page.dart';
import 'package:fixhome/features/technician/notification/api/technician_notification_api_service.dart';
import 'package:fixhome/features/technician/notification/cubit/technician_notification_cubit.dart';
import 'package:fixhome/features/technician/notification/cubit/technician_notification_state.dart';
import 'package:fixhome/features/technician/notification/model/technician_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianNotificationPage extends StatelessWidget {
  const TechnicianNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianNotificationCubit(TechnicianNotificationApiService())
            ..loadNotifications(),
      child: const _TechnicianNotificationView(),
    );
  }
}

class _TechnicianNotificationView extends StatelessWidget {
  const _TechnicianNotificationView();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatRelativeTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (_isSameDay(createdAt, now)) {
      if (diff.inMinutes < 1) {
        return 'technician.notification.just_now'.tr();
      }
      if (diff.inMinutes < 60) {
        return 'technician.notification.minutes_ago'.tr(
          args: ['${diff.inMinutes}'],
        );
      }
      return DateFormat('HH:mm').format(createdAt);
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(createdAt, yesterday)) {
      return 'technician.notification.yesterday_at'.tr(
        args: [DateFormat('HH:mm').format(createdAt)],
      );
    }

    final days = now
        .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
        .inDays;
    if (days > 0 && days < 7) {
      return 'technician.notification.days_ago'.tr(args: ['$days']);
    }

    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicianNotificationCubit, TechnicianNotificationState>(
      builder: (context, state) {
        if (state is TechnicianNotificationLoading ||
            state is TechnicianNotificationInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is TechnicianNotificationError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<TechnicianNotificationCubit>()
                .loadNotifications(),
          );
        }

        if (state is TechnicianNotificationLoaded) {
          final filtered = state.filteredNotifications;
          final now = DateTime.now();

          final todayItems = <TechnicianNotificationModel>[];
          final earlierItems = <TechnicianNotificationModel>[];

          for (final item in filtered) {
            if (item.createdAt != null && _isSameDay(item.createdAt!, now)) {
              todayItems.add(item);
            } else {
              earlierItems.add(item);
            }
          }

          final todayUnreadCount =
              todayItems.where((item) => !item.isRead).length;

          return Column(
            children: [
              _TechnicianFilterBar(
                selectedCategory: state.selectedCategory,
                totalUnreadCount: state.totalUnreadCount,
                ordersUnreadCount: state.ordersUnreadCount,
                onSelectCategory: (category) => context
                    .read<TechnicianNotificationCubit>()
                    .switchTab(category),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<TechnicianNotificationCubit>().refresh(),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.55,
                              child: const _EmptyNotificationView(),
                            ),
                          ],
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 150) {
                              context
                                  .read<TechnicianNotificationCubit>()
                                  .loadMore();
                            }
                            return false;
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                            children: [
                              if (todayItems.isNotEmpty) ...[
                                _TodaySectionHeader(
                                  unreadCount: todayUnreadCount,
                                  totalUnreadCount: state.totalUnreadCount,
                                  isMarkingAllRead: state.isMarkingAllRead,
                                  onMarkAllRead: () => context
                                      .read<TechnicianNotificationCubit>()
                                      .markAllAsRead(),
                                ),
                                const SizedBox(height: 10),
                                ...todayItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TechnicianNotificationCard(
                                      notification: item,
                                      timeText:
                                          _formatRelativeTime(item.createdAt),
                                      onTap: () => _handleTap(context, item),
                                      onActionTap: () =>
                                          _handleActionTap(context, item),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (earlierItems.isNotEmpty) ...[
                                _EarlierSectionHeader(
                                  count: earlierItems.length,
                                  showMarkAllRead:
                                      todayItems.isEmpty &&
                                      state.totalUnreadCount > 0,
                                  isMarkingAllRead: state.isMarkingAllRead,
                                  onMarkAllRead: () => context
                                      .read<TechnicianNotificationCubit>()
                                      .markAllAsRead(),
                                ),
                                const SizedBox(height: 10),
                                ...earlierItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TechnicianNotificationCard(
                                      notification: item,
                                      timeText:
                                          _formatRelativeTime(item.createdAt),
                                      onTap: () => _handleTap(context, item),
                                      onActionTap: () =>
                                          _handleActionTap(context, item),
                                    ),
                                  ),
                                ),
                              ],
                              if (state.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleTap(BuildContext context, TechnicianNotificationModel item) {
    _navigateFromNotification(context, item);
  }

  void _handleActionTap(
    BuildContext context,
    TechnicianNotificationModel item,
  ) {
    _navigateFromNotification(context, item);
  }

  void _navigateFromNotification(
    BuildContext context,
    TechnicianNotificationModel item,
  ) {
    context.read<TechnicianNotificationCubit>().markAsRead(item.id);

    if (item.isProfileVerification) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TechnicianProfilePage(technicianName: ''),
        ),
      );
      return;
    }

    final upperType = item.type.trim().toUpperCase();

    if (upperType.startsWith('QUOTE') && upperType != 'QUOTE_ACCEPTED') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TechnicianQuotesPage(),
        ),
      );
      return;
    }

    final refId = item.referenceId;
    if ((upperType.startsWith('REPAIR') || upperType == 'QUOTE_ACCEPTED') &&
        refId != null &&
        refId > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TechnicianOrderDetailPage(orderId: refId),
        ),
      );
      return;
    }

    if (item.isOrderReference) {
      if (refId != null && refId > 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TechnicianOrderDetailPage(orderId: refId),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TechnicianQuotesPage(),
          ),
        );
      }
    }
  }
}

class _TechnicianFilterBar extends StatelessWidget {
  final TechnicianNotificationCategory selectedCategory;
  final int totalUnreadCount;
  final int ordersUnreadCount;
  final ValueChanged<TechnicianNotificationCategory> onSelectCategory;

  const _TechnicianFilterBar({
    required this.selectedCategory,
    required this.totalUnreadCount,
    required this.ordersUnreadCount,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterPill(
              label: 'technician.notification.tab_all'.tr(),
              badgeCount: totalUnreadCount,
              isSelected:
                  selectedCategory == TechnicianNotificationCategory.all,
              onTap: () => onSelectCategory(TechnicianNotificationCategory.all),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'technician.notification.tab_orders'.tr(),
              badgeCount: ordersUnreadCount,
              isSelected:
                  selectedCategory == TechnicianNotificationCategory.orders,
              onTap: () =>
                  onSelectCategory(TechnicianNotificationCategory.orders),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'technician.notification.tab_income_wallet'.tr(),
              isSelected: selectedCategory ==
                  TechnicianNotificationCategory.incomeWallet,
              onTap: () => onSelectCategory(
                TechnicianNotificationCategory.incomeWallet,
              ),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'technician.notification.tab_system'.tr(),
              isSelected:
                  selectedCategory == TechnicianNotificationCategory.system,
              onTap: () =>
                  onSelectCategory(TechnicianNotificationCategory.system),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.badgeCount = 0,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySectionHeader extends StatelessWidget {
  final int unreadCount;
  final int totalUnreadCount;
  final bool isMarkingAllRead;
  final VoidCallback onMarkAllRead;

  const _TodaySectionHeader({
    required this.unreadCount,
    required this.totalUnreadCount,
    required this.isMarkingAllRead,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'technician.notification.today'.tr(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const Spacer(),
        if (totalUnreadCount > 0) ...[
          _MarkAllReadButton(
            isLoading: isMarkingAllRead,
            onTap: onMarkAllRead,
          ),
          const SizedBox(width: 10),
        ],
        if (unreadCount > 0)
          Text(
            'technician.notification.new_updates_count'.tr(
              args: ['$unreadCount'],
            ),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _EarlierSectionHeader extends StatelessWidget {
  final int count;
  final bool showMarkAllRead;
  final bool isMarkingAllRead;
  final VoidCallback onMarkAllRead;

  const _EarlierSectionHeader({
    required this.count,
    required this.showMarkAllRead,
    required this.isMarkingAllRead,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'technician.notification.earlier'.tr(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (showMarkAllRead) ...[
          _MarkAllReadButton(
            isLoading: isMarkingAllRead,
            onTap: onMarkAllRead,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          'technician.notification.notifications_count'.tr(args: ['$count']),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _MarkAllReadButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.done_all,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'technician.notification.mark_all_read'.tr(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TechnicianNotificationCard extends StatelessWidget {
  final TechnicianNotificationModel notification;
  final String timeText;
  final VoidCallback onTap;
  final VoidCallback onActionTap;

  const _TechnicianNotificationCard({
    required this.notification,
    required this.timeText,
    required this.onTap,
    required this.onActionTap,
  });

  _TechNotificationVisual _resolveVisual() {
    if (notification.isProfileVerification) {
      return const _TechNotificationVisual(
        icon: Icons.verified_user_outlined,
        iconColor: Color(0xFFEA580C),
        bgColor: Color(0xFFFFEDD5),
      );
    }

    if (notification.isReviewNotification) {
      return const _TechNotificationVisual(
        icon: Icons.star_rounded,
        iconColor: Color(0xFFEA580C),
        bgColor: Color(0xFFFFEDD5),
      );
    }

    if (notification.category == TechnicianNotificationCategory.incomeWallet) {
      return _TechNotificationVisual(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.success,
        bgColor: AppColors.success.withValues(alpha: 0.14),
      );
    }

    if (notification.category == TechnicianNotificationCategory.orders) {
      return _TechNotificationVisual(
        icon: Icons.handyman_outlined,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryLight.withValues(alpha: 0.14),
      );
    }

    return const _TechNotificationVisual(
      icon: Icons.notifications_none_rounded,
      iconColor: AppColors.primaryDark,
      bgColor: AppColors.surfaceMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final visual = _resolveVisual();
    final isHighlightOrderCard =
        isUnread && notification.category == TechnicianNotificationCategory.orders;

    final subtitleParts = <String>[
      if (timeText.isNotEmpty) timeText,
      if (notification.isOrderReference &&
          notification.referenceId != null &&
          notification.referenceId! > 0)
        'technician.notification.order_ref'.tr(
          args: ['${notification.referenceId}'],
        ),
    ];

    return Material(
      color: isHighlightOrderCard
          ? AppColors.primaryLight.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlightOrderCard
                  ? AppColors.primaryLight.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: visual.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    notification.title,
                                    style: TextStyle(
                                      color: isHighlightOrderCard
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (notification.isProfileVerification)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDD5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'technician.notification.important_badge'
                                            .tr(),
                                        style: const TextStyle(
                                          color: Color(0xFFC2410C),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtitleParts.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitleParts.join(' • '),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (notification.body.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: notification.isReviewNotification
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            notification.body,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.45,
                            ),
                          ),
                        )
                      : Text(
                          notification.body,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                ),
              ],

              if (notification.isOrderReference &&
                  !notification.isReviewNotification) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onActionTap,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        'technician.notification.view_details_accept'.tr(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (notification.isProfileVerification) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: ElevatedButton.icon(
                    onPressed: onActionTap,
                    icon: const Icon(Icons.note_add_outlined, size: 18),
                    label: Text(
                      'technician.notification.update_profile_now'.tr(),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TechNotificationVisual {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _TechNotificationVisual({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class _EmptyNotificationView extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'technician.notification.empty_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'technician.notification.empty_desc'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'technician.notification.load_error'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
