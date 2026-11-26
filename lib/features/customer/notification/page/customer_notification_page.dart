import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/activity/page/order_tracking_page.dart';
import 'package:fixhome/features/customer/home/find_technician/page/view_quote_page.dart';
import 'package:fixhome/features/customer/notification/api/notification_api_service.dart';
import 'package:fixhome/features/customer/notification/cubit/notification_cubit.dart';
import 'package:fixhome/features/customer/notification/cubit/notification_state.dart';
import 'package:fixhome/features/customer/notification/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerNotificationPage extends StatelessWidget {
  const CustomerNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationCubit(NotificationApiService())..loadNotifications(),
      child: const _CustomerNotificationView(),
    );
  }
}

class _CustomerNotificationView extends StatelessWidget {
  const _CustomerNotificationView();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatRelativeTime(BuildContext context, DateTime? createdAt) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (_isSameDay(createdAt, now)) {
      if (diff.inMinutes < 1) {
        return 'customer.notification.just_now'.tr();
      }
      if (diff.inMinutes < 60) {
        return 'customer.notification.minutes_ago'.tr(
          args: ['${diff.inMinutes}'],
        );
      }
      return DateFormat('HH:mm').format(createdAt);
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(createdAt, yesterday)) {
      return 'customer.notification.yesterday_at'.tr(
        args: [DateFormat('HH:mm').format(createdAt)],
      );
    }

    final days = now
        .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
        .inDays;
    if (days > 0 && days < 7) {
      return 'customer.notification.days_ago'.tr(args: ['$days']);
    }

    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading || state is NotificationInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is NotificationError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<NotificationCubit>().loadNotifications(),
          );
        }

        if (state is NotificationLoaded) {
          final filtered = state.filteredNotifications;
          final now = DateTime.now();

          final todayItems = <NotificationModel>[];
          final earlierItems = <NotificationModel>[];

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
              // Filter Tabs
              _NotificationFilterBar(
                selectedCategory: state.selectedCategory,
                totalUnreadCount: state.totalUnreadCount,
                onSelectCategory: (category) =>
                    context.read<NotificationCubit>().switchTab(category),
              ),

              // Notification List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<NotificationCubit>().refresh(),
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
                              context.read<NotificationCubit>().loadMore();
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
                                      .read<NotificationCubit>()
                                      .markAllAsRead(),
                                ),
                                const SizedBox(height: 12),
                                ...todayItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(
                                      notification: item,
                                      timeText: _formatRelativeTime(
                                        context,
                                        item.createdAt,
                                      ),
                                      onTap: () => _handleTap(context, item),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (earlierItems.isNotEmpty) ...[
                                _EarlierSectionHeader(
                                  showMarkAllRead:
                                      todayItems.isEmpty &&
                                      state.totalUnreadCount > 0,
                                  isMarkingAllRead: state.isMarkingAllRead,
                                  onMarkAllRead: () => context
                                      .read<NotificationCubit>()
                                      .markAllAsRead(),
                                ),
                                const SizedBox(height: 12),
                                ...earlierItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(
                                      notification: item,
                                      timeText: _formatRelativeTime(
                                        context,
                                        item.createdAt,
                                      ),
                                      onTap: () => _handleTap(context, item),
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

  void _handleTap(BuildContext context, NotificationModel item) {
    context.read<NotificationCubit>().markAsRead(item.id);

    final refId = item.referenceId;
    if (refId == null || refId <= 0) return;

    final upperType = item.type.trim().toUpperCase();

    if (upperType == 'QUOTE_SUBMITTED') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewQuotePage(orderId: refId),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(orderId: refId),
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final int totalUnreadCount;
  final ValueChanged<NotificationCategory> onSelectCategory;

  const _NotificationFilterBar({
    required this.selectedCategory,
    required this.totalUnreadCount,
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
              label: 'customer.notification.tab_all'.tr(),
              badgeCount: totalUnreadCount,
              isSelected: selectedCategory == NotificationCategory.all,
              onTap: () => onSelectCategory(NotificationCategory.all),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'customer.notification.tab_service_order'.tr(),
              icon: Icons.build_outlined,
              isSelected: selectedCategory == NotificationCategory.serviceOrder,
              onTap: () => onSelectCategory(NotificationCategory.serviceOrder),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'customer.notification.tab_system'.tr(),
              icon: Icons.notifications_none_outlined,
              isSelected: selectedCategory == NotificationCategory.system,
              onTap: () => onSelectCategory(NotificationCategory.system),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.icon,
    this.badgeCount = 0,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary
          : AppColors.primaryLight.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 6),
              ],
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA580C),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
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
    final locale = context.locale.toString();
    final todayDateStr = DateFormat('EEE, dd/MM', locale).format(DateTime.now());

    return Row(
      children: [
        Text(
          'customer.notification.today'.tr(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (unreadCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'customer.notification.new_count'.tr(args: ['$unreadCount']),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (totalUnreadCount > 0)
          _MarkAllReadButton(
            isLoading: isMarkingAllRead,
            onTap: onMarkAllRead,
          )
        else
          Text(
            todayDateStr,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _EarlierSectionHeader extends StatelessWidget {
  final bool showMarkAllRead;
  final bool isMarkingAllRead;
  final VoidCallback onMarkAllRead;

  const _EarlierSectionHeader({
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
            'customer.notification.earlier'.tr(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showMarkAllRead)
          _MarkAllReadButton(
            isLoading: isMarkingAllRead,
            onTap: onMarkAllRead,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'customer.notification.mark_all_read'.tr(),
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

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String timeText;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeText,
    required this.onTap,
  });

  _NotificationVisual _resolveVisual() {
    final type = notification.type.toUpperCase();
    final ref = notification.referenceType.toUpperCase();

    if (type.contains('CHAT') ||
        type.contains('MESSAGE') ||
        ref.contains('CHAT') ||
        ref.contains('MESSAGE')) {
      return _NotificationVisual(
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: const Color(0xFF0284C7),
        bgColor: const Color(0xFFE0F2FE),
      );
    }

    if (type.contains('QUOTE') || ref.contains('QUOTE')) {
      return _NotificationVisual(
        icon: Icons.receipt_long_outlined,
        iconColor: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFEDD5),
      );
    }

    if (type.contains('WARRANTY') || ref.contains('WARRANTY')) {
      return _NotificationVisual(
        icon: Icons.verified_user_outlined,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryLight.withValues(alpha: 0.14),
      );
    }

    if (type.contains('VOUCHER') ||
        type.contains('PROMO') ||
        ref.contains('VOUCHER') ||
        ref.contains('PROMO')) {
      return _NotificationVisual(
        icon: Icons.local_offer_outlined,
        iconColor: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFEDD5),
      );
    }

    if (notification.category == NotificationCategory.serviceOrder) {
      return _NotificationVisual(
        icon: Icons.handyman_outlined,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryLight.withValues(alpha: 0.14),
      );
    }

    return _NotificationVisual(
      icon: Icons.notifications_none_rounded,
      iconColor: AppColors.primaryDark,
      bgColor: AppColors.surfaceMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final visual = _resolveVisual();

    return Material(
      color: isUnread
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
              color: isUnread
                  ? AppColors.primaryLight.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box + unread dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: visual.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.iconColor,
                      size: 22,
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: isUnread
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              fontSize: 12,
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (notification.referenceId != null &&
                        notification.referenceId! > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: notification.category ==
                                  NotificationCategory.serviceOrder
                              ? AppColors.primaryLight.withValues(alpha: 0.14)
                              : const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              notification.isOrderReference
                                  ? Icons.bolt_rounded
                                  : Icons.tag_rounded,
                              size: 13,
                              color: notification.category ==
                                      NotificationCategory.serviceOrder
                                  ? AppColors.primary
                                  : const Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.isOrderReference
                                  ? 'customer.notification.order_ref_tag'.tr(
                                      args: ['${notification.referenceId}'],
                                    )
                                  : 'customer.notification.ref_tag'.tr(
                                      args: ['${notification.referenceId}'],
                                    ),
                              style: TextStyle(
                                color: notification.category ==
                                        NotificationCategory.serviceOrder
                                    ? AppColors.primaryDark
                                    : const Color(0xFFC2410C),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationVisual {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _NotificationVisual({
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
              'customer.notification.empty_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'customer.notification.empty_desc'.tr(),
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
              'customer.notification.load_error'.tr(),
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
