import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';
import 'package:fixhome/features/customer/activity/page/order_tracking_page.dart';
import 'package:fixhome/features/customer/chat/page/chat_page.dart';
import 'package:fixhome/features/customer/home/find_technician/page/view_quote_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';

class CustomerActivityPage extends StatelessWidget {
  const CustomerActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityCubit(ActivityApiService())..loadOrders(),
      child: const _CustomerActivityView(),
    );
  }
}

class _CustomerActivityView extends StatelessWidget {
  const _CustomerActivityView();

  String _getStatusLabel(String status) {
    final key = 'customer.activity.status.${status.toLowerCase()}';
    final translated = key.tr();
    return translated == key ? status : translated;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading || state is ActivityInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ActivityError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ActivityCubit>().loadOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ActivityLoaded) {
          final displayedOrders = state.selectedTabIndex == 0
              ? state.activeOrders
              : state.completedOrders;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Tab Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          title: 'customer.activity.in_progress_tab'.tr(),
                          count: state.activeOrders.length,
                          isSelected: state.selectedTabIndex == 0,
                          onTap: () =>
                              context.read<ActivityCubit>().switchTab(0),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          title: 'customer.activity.completed_history_tab'.tr(),
                          count: state.completedOrders.length,
                          isSelected: state.selectedTabIndex == 1,
                          onTap: () =>
                              context.read<ActivityCubit>().switchTab(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tiêu đề "Đơn sửa chữa hiện tại"
              if (state.selectedTabIndex == 0 && displayedOrders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'customer.activity.current_repair_order'.tr(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Danh sách đơn hàng
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<ActivityCubit>().loadOrders(),
                  child: displayedOrders.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Center(
                                child: Text(
                                  'customer.activity.no_orders_found'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: displayedOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final order = displayedOrders[index];
                            return _OrderActivityCard(
                              order: order,
                              statusLabel: _getStatusLabel(order.status),
                            );
                          },
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
}

class _TabButton extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderActivityCard extends StatelessWidget {
  final RepairOrderModel order;
  final String statusLabel;

  const _OrderActivityCard({required this.order, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final tech = order.matchedQuote?.technician;
    final canChatWithTechnician = !const {
      'PENDING',
      'QUOTING',
      'WAITING_QUOTES',
      'NO_TECHNICIAN_FOUND',
    }.contains(order.status.toUpperCase());

    final formattedTime = order.scheduledAt != null
        ? DateFormat('HH:mm dd/MM/yyyy').format(order.scheduledAt!.toLocal())
        : (order.createdAt != null
              ? DateFormat(
                  'HH:mm dd/MM/yyyy',
                ).format(order.createdAt!.toLocal())
              : '');

    final deviceAndIssueTitle = [
      if (order.deviceTypeName != null && order.deviceTypeName!.isNotEmpty)
        order.deviceTypeName!,
      if (order.issueDescription.isNotEmpty) order.issueDescription,
    ].join(' - ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Tên dịch vụ (Category) + Badge trạng thái + Tên thiết bị & Mô tả
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_repair_service_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (order.categoryName ??
                                    'customer.activity.default_category'.tr())
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceAndIssueTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Box thông tin kỹ thuật viên (khi technician_id != null và map từ Quote API)
          if (order.technicianId != null && tech != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight.withValues(
                      alpha: 0.2,
                    ),
                    backgroundImage:
                        (tech.avatarUrl != null &&
                            tech.avatarUrl!.startsWith('http'))
                        ? NetworkImage(tech.avatarUrl!)
                        : null,
                    child:
                        (tech.avatarUrl == null ||
                            !tech.avatarUrl!.startsWith('http'))
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tech.fullName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              tech.averageRating.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            if (tech.experienceLevel != null &&
                                tech.experienceLevel!.isNotEmpty) ...[
                              const Text(
                                '  •  ',
                                style: TextStyle(color: AppColors.textHint),
                              ),
                              Flexible(
                                child: Text(
                                  tech.experienceLevel!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      onPressed: () {
                        // Xử lý gọi điện
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'customer.activity.finding_technician'.tr(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Thời gian & Địa chỉ
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  order.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2 Nút hành động: Nhắn tin KTV & Theo dõi đơn
          Row(
            children: [
              if (canChatWithTechnician) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final technicianName = order
                          .matchedQuote
                          ?.technician
                          ?.fullName
                          .trim();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            orderId: order.id,
                            orderCode: order.orderCode,
                            contactName:
                                technicianName == null || technicianName.isEmpty
                                ? 'customer.chat.technician'.tr()
                                : technicianName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withValues(
                        alpha: 0.12,
                      ),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      'customer.activity.chat_technician'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Đơn đang chờ báo giá: mở trang tìm thợ
                    if (order.status.toUpperCase() == 'WAITING_QUOTES') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewQuotePage(orderId: order.id),
                        ),
                      );
                    } else {
                      // Các trạng thái khác: mở trang theo dõi đơn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingPage(orderId: order.id),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(
                    'customer.activity.track_order'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
