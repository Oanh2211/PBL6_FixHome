import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/shared/widget/app_network_image.dart';
import 'package:fixhome/features/technician/activity/api/technician_activity_api.dart';
import 'package:fixhome/features/technician/activity/page/technician_acceptance_sheet.dart';
import 'package:fixhome/features/technician/activity/page/technician_final_quote_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/technician_order_detail_cubit.dart';
import '../model/technician_order_model.dart';

class TechnicianOrderDetailPage extends StatelessWidget {
  final int orderId;

  const TechnicianOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianOrderDetailCubit(TechnicianActivityApi())
            ..fetchDetail(orderId),
      child: const _TechnicianOrderDetailView(),
    );
  }
}

class _TechnicianOrderDetailView extends StatelessWidget {
  const _TechnicianOrderDetailView();

  int _getCurrentStep(OrderDetailLoaded loaded) {
    if (loaded.isCompletedLocally ||
        loaded.order.status == 'COMPLETED' ||
        loaded.order.status == 'PENDING_ACCEPTANCE') {
      return 6; // Hoàn thành
    }
    if (loaded.isQuoteSubmitted) {
      return 5; // Đã gửi chốt giá -> Đang ở bước Nghiệm thu
    }
    switch (loaded.order.status) {
      case 'TECHNICIAN_SELECTED':
        return 1;
      case 'TRAVELLING':
        return 2;
      case 'ARRIVED':
        return 3;
      case 'REPAIRING':
        return 4;
      default:
        return 1;
    }
  }

  String _getPrimaryButtonLabel(OrderDetailLoaded loaded) {
    if (loaded.isQuoteSubmitted) {
      return 'Gửi ảnh nghiệm thu & Hoàn thành';
    }
    switch (loaded.order.status) {
      case 'TECHNICIAN_SELECTED':
        return 'technician.activity.detail.btn_start_travelling'.tr();
      case 'TRAVELLING':
        return 'technician.activity.detail.btn_arrived'.tr();
      case 'ARRIVED':
        return 'technician.activity.detail.btn_start_repair'.tr();
      case 'REPAIRING':
        return 'technician.activity.detail.btn_complete_repair'.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechnicianOrderDetailCubit, TechnicianOrderDetailState>(
      listener: (context, state) {
        if (state is OrderDetailLoaded) {
          if (state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!.tr()),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionErrorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is OrderDetailLoading || state is OrderDetailInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is OrderDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        final loaded = state as OrderDetailLoaded;
        final order = loaded.order;
        final activeStep = _getCurrentStep(loaded);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '• ${'technician.activity.detail.header_badge'.tr()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'technician.activity.detail.header_title'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Card Thông tin khách hàng & Địa chỉ
                _buildCustomerCard(order),
                const SizedBox(height: 12),

                // 2. Card Thông tin thiết bị sự cố
                _buildDeviceIssueCard(context, order),
                const SizedBox(height: 12),
                if (loaded.isQuoteSubmitted && loaded.savedFinalAmount > 0) ...[
                  _buildSubmittedQuoteCard(loaded),
                  const SizedBox(height: 12),
                ],

                // 3. Card Tiến trình thực hiện (6 bước theo UI)
                _buildProgressStepperCard(activeStep),
              ],
            ),
          ),
          bottomNavigationBar:
              (loaded.isCompletedLocally ||
                  order.status == 'COMPLETED' ||
                  order.status == 'PENDING_ACCEPTANCE' ||
                  order.status == 'CANCELLED')
              ? null
              : Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Nút Huỷ đơn (ẩn sau khi đã gửi chốt giá)
                      if (!loaded.isQuoteSubmitted &&
                          order.status != 'PENDING_ACCEPTANCE') ...[
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: loaded.isUpdating ? null : () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'technician.activity.detail.cancel_order'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Nút hành động chính theo từng trạng thái
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: loaded.isUpdating
                              ? null
                              : () async {
                                  final cubit = context
                                      .read<TechnicianOrderDetailCubit>();
                                  if (loaded.isQuoteSubmitted) {
                                    // Đã gửi chốt giá -> Mở Page gửi ảnh nghiệm thu & gọi API complete
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: cubit,
                                          child:
                                              const TechnicianAcceptancePage(),
                                        ),
                                      ),
                                    );
                                  } else if (order.status == 'REPAIRING') {
                                    // Đang sửa chữa -> Mở form Chốt giá
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: cubit,
                                          child: TechnicianFinalQuotePage(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    cubit.progressNextStatus();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: loaded.isUpdating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _getPrimaryButtonLabel(loaded),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCustomerCard(TechnicianOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.contactName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
              ),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.phone, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.apartment, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIssueCard(
    BuildContext context,
    TechnicianOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.devices_other,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'technician.activity.detail.device_issue_title'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Box Thiết bị & Dịch vụ: Icon bên cạnh luôn lấy deviceIconUrl từ API device-types
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _deviceIconOrPlaceholder(order),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.deviceName} (${order.categoryName})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'technician.activity.detail.symptom_prefix'.tr()}${order.issueDescription}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Khu vực Hình ảnh tình trạng thiết bị (issueMedia) ở phía dưới
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Hình ảnh tình trạng thiết bị',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (order.issueMedia.isNotEmpty)
                Text(
                  '${order.issueMedia.length} ảnh',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.issueMedia.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'technician.activity.detail.no_media'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.issueMedia.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final media = order.issueMedia[index];
                  return GestureDetector(
                    onTap: () =>
                        _showMediaPreviewDialog(context, media.fileUrl),
                    child: AppNetworkImage(
                      url: media.fileUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                      fallback: Container(
                        width: 84,
                        height: 84,
                        color: AppColors.surfaceMuted,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showMediaPreviewDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: AppNetworkImage(
                url: imageUrl,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Cập nhật _deviceIconOrPlaceholder:
  Widget _deviceIconOrPlaceholder(TechnicianOrderModel order) {
    if (order.deviceIconUrl.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(10),
        color: AppColors.primary.withValues(alpha: 0.08),
        child: AppNetworkImage(
          url: order.deviceIconUrl,
          fit: BoxFit.contain,
          fallback: _placeholderImage(),
        ),
      );
    }
    return _placeholderImage();
  }

  Widget _buildSubmittedQuoteCard(OrderDetailLoaded loaded) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Đã gửi chốt giá',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${currencyFormat.format(loaded.savedFinalAmount)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Bảo hành: ${loaded.savedWarrantyDays} ngày',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.border,
      child: const Icon(Icons.home_repair_service, color: AppColors.textHint),
    );
  }

  Widget _buildProgressStepperCard(int activeStep) {
    final steps = [
      (1, 'technician.activity.detail.step_1_title'.tr(), null),
      (2, 'technician.activity.detail.step_2_title'.tr(), null),
      (
        3,
        'technician.activity.detail.step_3_title'.tr(),
        'technician.activity.detail.step_3_sub'.tr(),
      ),
      (
        4,
        'technician.activity.detail.step_4_title'.tr(),
        'technician.activity.detail.step_4_sub'.tr(),
      ),
      (
        5,
        'technician.activity.detail.step_5_title'.tr(),
        'technician.activity.detail.step_5_sub'.tr(),
      ),
      (6, 'technician.activity.detail.step_6_title'.tr(), null),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.activity.detail.progress_title'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final (stepNum, title, subtitle) = steps[index];
            final isDoneOrActive = stepNum <= activeStep;
            final isLast = index == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDoneOrActive
                              ? AppColors.primaryDark
                              : AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDoneOrActive
                                ? Colors.white
                                : AppColors.textHint,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: stepNum < activeStep
                                ? AppColors.primaryDark
                                : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isDoneOrActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isDoneOrActive
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
