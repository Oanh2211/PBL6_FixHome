import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/shared/widget/app_network_image.dart';
import 'package:fixhome/features/technician/activity/api/technician_activity_api.dart';
import 'package:fixhome/features/technician/activity/page/technician_order_detail_page.dart';
import 'package:fixhome/features/technician/chat/page/technician_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/technician_activity_cubit.dart';
import '../model/technician_order_model.dart';

class TechnicianActivityPage extends StatelessWidget {
  const TechnicianActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianActivityCubit(TechnicianActivityApi())
            ..loadOrders(scope: 'ACTIVE'),
      child: const _TechnicianActivityView(),
    );
  }
}

class _TechnicianActivityView extends StatefulWidget {
  const _TechnicianActivityView();

  @override
  State<_TechnicianActivityView> createState() =>
      _TechnicianActivityViewState();
}

class _TechnicianActivityViewState extends State<_TechnicianActivityView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedScope = 'ACTIVE';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectTab(String scope) {
    setState(() => _selectedScope = scope);
    _searchController.clear();
    context.read<TechnicianActivityCubit>().loadOrders(scope: scope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 3 Tabs: Đã nhận | Đã huỷ | Đã xong
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                BlocBuilder<TechnicianActivityCubit, TechnicianActivityState>(
                  builder: (context, state) {
                    final activeCount =
                        (state is TechnicianActivityLoaded &&
                            state.currentScope == 'ACTIVE')
                        ? state.orders.length
                        : null;
                    return Row(
                      children: [
                        _buildTabChip(
                          label: 'technician.activity.tabs.active'.tr(),
                          scope: 'ACTIVE',
                          count: activeCount,
                        ),
                        const SizedBox(width: 8),
                        _buildTabChip(
                          label: 'technician.activity.tabs.cancelled'.tr(),
                          scope: 'CANCELLED',
                        ),
                        const SizedBox(width: 8),
                        _buildTabChip(
                          label: 'technician.activity.tabs.completed'.tr(),
                          scope: 'COMPLETED',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Thanh tìm kiếm
                TextField(
                  controller: _searchController,
                  onChanged: (value) => context
                      .read<TechnicianActivityCubit>()
                      .searchOrders(value),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'technician.activity.search_hint'.tr(),
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách đơn hàng
          Expanded(
            child:
                BlocBuilder<TechnicianActivityCubit, TechnicianActivityState>(
                  builder: (context, state) {
                    if (state is TechnicianActivityLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (state is TechnicianActivityError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<TechnicianActivityCubit>()
                                  .loadOrders(scope: _selectedScope),
                              child: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is TechnicianActivityLoaded) {
                      if (state.filteredOrders.isEmpty) {
                        return Center(
                          child: Text(
                            'technician.activity.empty_orders'.tr(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<TechnicianActivityCubit>()
                            .loadOrders(scope: _selectedScope),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _OrderCard(
                              order: state.filteredOrders[index],
                              onRefreshList: () => context
                                  .read<TechnicianActivityCubit>()
                                  .loadOrders(scope: _selectedScope),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required String scope,
    int? count,
  }) {
    final isSelected = _selectedScope == scope;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSelectTab(scope),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.textPrimary : Colors.white,
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

class _OrderCard extends StatelessWidget {
  final TechnicianOrderModel order;
  final VoidCallback onRefreshList;

  const _OrderCard({required this.order, required this.onRefreshList});

  @override
  Widget build(BuildContext context) {
    final isScheduled = order.requestedTimeType == 'SCHEDULED';
    final timeStr = order.scheduledAt != null
        ? DateFormat('HH:mm - dd/MM').format(order.scheduledAt!)
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng trạng thái hẹn giờ (nếu có)
          if (isScheduled) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'technician.activity.scheduled_badge'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'technician.activity.scheduled_slot'.tr(args: [timeStr]),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Tên thiết bị & Dịch vụ đã map từ API
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppNetworkImage(
                  url: order.deviceIconUrl,
                  fit: BoxFit.contain,
                  fallback: const Icon(
                    Icons.build_circle_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deviceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${order.categoryName} • #${order.orderCode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: AppColors.border),

          // Thông tin khách hàng
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceMuted,
                child: Text(
                  order.contactName.isNotEmpty
                      ? order.contactName[0].toUpperCase()
                      : 'K',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.contactName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    order.contactPhone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Địa chỉ
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Banner trạng thái hiện tại
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'technician.activity.status.${order.status}'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2 Nút hành động: Nhắn tin & Xem chi tiết
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianChatPage(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text('technician.activity.message_btn'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TechnicianOrderDetailPage(orderId: order.id),
                      ),
                    );
                    onRefreshList();
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'technician.activity.view_detail_btn'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
