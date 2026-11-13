import 'package:fixhome/features/technician/home/quote/page/widget/quote_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/technician_quote_api.dart';
import '../cubit/technician_quote_cubit.dart';
import '../cubit/technician_quote_state.dart';
import '../model/technician_quote_model.dart';

class TechnicianQuoteDetailPage extends StatelessWidget {
  final int quoteId;

  // Cho phép truyền callback để kết nối với chức năng gửi báo giá
  // hoặc từ chối yêu cầu khi đã có API tương ứng.

  final VoidCallback? onSendQuote;
  final VoidCallback? onRejectQuote;

  const TechnicianQuoteDetailPage({
    super.key,
    required this.quoteId,
    this.onSendQuote,
    this.onRejectQuote,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianQuoteCubit(api: TechnicianQuoteApi())
            ..getQuoteDetail(quoteId),
      child: _TechnicianQuoteDetailView(
        quoteId: quoteId,
        onSendQuote: onSendQuote,
        onRejectQuote: onRejectQuote,
      ),
    );
  }
}

class _TechnicianQuoteDetailView extends StatelessWidget {
  final VoidCallback? onSendQuote;
  final VoidCallback? onRejectQuote;
  final int quoteId;

  const _TechnicianQuoteDetailView({
    required this.quoteId,
    this.onSendQuote,
    this.onRejectQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'technician.quotes.detail_title'.tr(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<TechnicianQuoteCubit, TechnicianQuoteState>(
        builder: (context, state) {
          if (state is TechnicianQuoteDetailLoading ||
              state is TechnicianQuoteInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TechnicianQuoteDetailError) {
            return _buildError(context, state.message);
          }

          if (state is TechnicianQuoteDetailLoaded) {
            return _buildDetail(context, state.detail);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 45),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<TechnicianQuoteCubit>().getQuoteDetail(
                  _currentQuoteId(context),
                );
              },
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  int _currentQuoteId(BuildContext context) {
    return (context.findAncestorWidgetOfExactType<TechnicianQuoteDetailPage>())
            ?.quoteId ??
        0;
  }

  Widget _buildDetail(BuildContext context, TechnicianQuoteDetailModel detail) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // 1. THỜI HẠN PHẢN HỒI
              _buildCountdownCard(detail),

              const SizedBox(height: 13),

              // 2. THÔNG TIN YÊU CẦU
              _buildRequestCard(detail),

              const SizedBox(height: 12),

              // 3. HÌNH ẢNH HIỆN TRƯỜNG
              _buildMediaCard(detail),

              const SizedBox(height: 12),

              // 4. KHOẢNG CÁCH VÀ VỊ TRÍ
              _buildLocationCard(detail),

              const SizedBox(height: 12),

              // 5. ĐỊA CHỈ
              _buildAddressCard(detail),

              const SizedBox(height: 12),

              // 6. NGƯỜI LIÊN HỆ
              _buildContactCard(detail),

              const SizedBox(height: 12),

              // 7. CHI TIẾT HẠNG MỤC
              _buildItemsCard(detail),

              const SizedBox(height: 12),

              // 8. KHOẢNG GIÁ THAM KHẢO
              _buildPriceCard(detail),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // 9. NÚT HÀNH ĐỘNG
        _buildBottomActions(context, detail),
      ],
    );
  }

  // =====================================================
  // COUNTDOWN
  // =====================================================

  Widget _buildCountdownCard(TechnicianQuoteDetailModel detail) {
    final remaining = _remainingTime(detail.expiresAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF641F), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.quotes.response_deadline'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 25),
              const SizedBox(width: 8),
              Text(
                remaining,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 4,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          if (detail.expiresAt != null) ...[
            const SizedBox(height: 7),
            Text(
              'technician.quotes.expires_at'.tr(
                args: [_formatDate(detail.expiresAt)],
              ),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  String _remainingTime(DateTime? expiresAt) {
    if (expiresAt == null) return '--:--';

    final duration = expiresAt.difference(DateTime.now());

    if (duration.isNegative) {
      return 'technician.quotes.expired'.tr();
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // REQUEST INFORMATION
  // =====================================================

  Widget _buildRequestCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.home_repair_service_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'technician.quotes.request_information'.tr(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'technician.quotes.order_code'.tr(
                        args: [detail.orderCode],
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              QuoteStatusBadge(status: detail.status),
            ],
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.category_outlined,
            'technician.quotes.category_id'.tr(),
            detail.categoryId.toString(),
          ),

          _infoRow(
            Icons.devices_outlined,
            'technician.quotes.device_id'.tr(),
            detail.deviceTypeId.toString(),
          ),

          _infoRow(
            Icons.calendar_month_outlined,
            'technician.quotes.requested_time'.tr(),
            _requestedTime(detail),
          ),

          _infoRow(
            Icons.repeat,
            'technician.quotes.invite_round'.tr(),
            detail.inviteRound.toString(),
          ),

          const SizedBox(height: 10),

          Text(
            'technician.quotes.issue_description'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),

          const SizedBox(height: 7),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              detail.issueDescription.isNotEmpty
                  ? detail.issueDescription
                  : 'technician.quotes.no_description'.tr(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          if (detail.customerNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'technician.quotes.customer_note'.tr(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              detail.customerNote,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // MEDIA
  // =====================================================

  Widget _buildMediaCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.quotes.media'.tr(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (detail.mediaIds.isEmpty)
            Container(
              height: 95,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textHint,
                    size: 28,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'technician.quotes.no_media'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.mediaIds.map((id) {
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 5),
                      Text('ID: $id', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // LOCATION
  // =====================================================

  Widget _buildLocationCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: AppColors.primary, size: 19),
              const SizedBox(width: 7),
              Text(
                '${detail.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 55,
                  color: Color(0xFF86A98A),
                ),

                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${detail.latitude}, ${detail.longitude}',
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'technician.quotes.coordinates'.tr(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),

          Text(
            '${detail.latitude}, ${detail.longitude}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ADDRESS
  // =====================================================

  Widget _buildAddressCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on,
            size: 19,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'technician.quotes.customer_address'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  detail.address.isNotEmpty
                      ? detail.address
                      : 'technician.quotes.no_address'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (detail.wardCode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${'technician.quotes.ward_code'.tr()}: ${detail.wardCode}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CONTACT
  // =====================================================

  Widget _buildContactCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(
              detail.contactName.isNotEmpty
                  ? detail.contactName.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.contactName.isNotEmpty
                      ? detail.contactName
                      : 'technician.quotes.unknown_customer'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'technician.quotes.contact_description'.tr(),
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

  // =====================================================
  // ITEMS
  // =====================================================

  Widget _buildItemsCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.quotes.items'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),

          const SizedBox(height: 10),

          if (detail.items.isEmpty)
            Text(
              'technician.quotes.no_items'.tr(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            )
          else
            ...detail.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${'technician.quotes.item_type'.tr()}: ${item.itemType}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${'technician.quotes.quantity'.tr()}: ${item.quantity}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const Spacer(),
                        Text(
                          '${_money(item.minUnitPrice)} - ${_money(item.maxUnitPrice)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // =====================================================
  // PRICE
  // =====================================================

  Widget _buildPriceCard(TechnicianQuoteDetailModel detail) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'technician.quotes.estimated_price'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),

          const SizedBox(height: 12),

          _priceRow(
            'technician.quotes.minimum_price'.tr(),
            _money(detail.estimatedMinAmount),
          ),

          _priceRow(
            'technician.quotes.maximum_price'.tr(),
            _money(detail.estimatedMaxAmount),
          ),

          _priceRow(
            'technician.quotes.discount'.tr(),
            _money(detail.discountAmount),
          ),

          _priceRow(
            'technician.quotes.warranty'.tr(),
            '${detail.warrantyDurationDays} ${'technician.quotes.days'.tr()}',
          ),

          if (detail.note.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              'technician.quotes.note'.tr(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              detail.note,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // BOTTOM ACTIONS
  // =====================================================

  Widget _buildBottomActions(
    BuildContext context,
    TechnicianQuoteDetailModel detail,
  ) {
    final status = detail.status.toUpperCase();

    final canRespond = ['PENDING', 'INVITED', 'NEW'].contains(status);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: canRespond
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          onRejectQuote ?? () => _showNotConnected(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'technician.quotes.reject'.tr(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          onSendQuote ?? () => _showNotConnected(context),
                      icon: const Icon(
                        Icons.monetization_on_outlined,
                        size: 17,
                      ),
                      label: Text(
                        'technician.quotes.send_quote'.tr(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: Text(
                  'technician.quotes.cannot_respond'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }

  void _showNotConnected(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('technician.quotes.action_not_connected'.tr())),
    );
  }

  // =====================================================
  // COMMON WIDGETS
  // =====================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _requestedTime(TechnicianQuoteDetailModel detail) {
    final type = detail.requestedTimeType.toUpperCase();

    if (type == 'NOW' || type == 'IMMEDIATE') {
      return 'technician.quotes.time.now'.tr();
    }

    return _formatDate(detail.scheduledAt);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '---';

    return DateFormat('HH:mm - dd/MM/yyyy').format(date.toLocal());
  }

  String _money(double amount) {
    return '${NumberFormat('#,##0', 'vi_VN').format(amount)} đ';
  }
}
