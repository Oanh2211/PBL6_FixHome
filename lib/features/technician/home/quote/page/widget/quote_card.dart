import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';

import '../../model/technician_quote_model.dart';
import 'quote_status_badge.dart';

class QuoteCard extends StatelessWidget {
  final TechnicianQuoteModel quote;
  final VoidCallback onTap;

  const QuoteCard({super.key, required this.quote, required this.onTap});

  String _formatDate(DateTime? date) {
    if (date == null) return '---';

    return DateFormat('HH:mm - dd/MM/yyyy').format(date.toLocal());
  }

  String _formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }

  IconData _deviceIcon(int id) {
    // Có thể thay bằng dữ liệu danh mục từ API.
    switch (id) {
      case 1:
        return Icons.ac_unit;
      case 2:
        return Icons.kitchen_outlined;
      case 3:
        return Icons.local_laundry_service_outlined;
      case 4:
        return Icons.dry_cleaning_outlined;
      case 5:
        return Icons.water_drop_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }

  String _timeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'NOW':
      case 'IMMEDIATE':
        return 'technician.quotes.time.now'.tr();
      case 'SCHEDULED':
        return 'technician.quotes.time.scheduled'.tr();
      default:
        return type.isEmpty ? '---' : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatDistance(quote.distanceKm),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  QuoteStatusBadge(status: quote.status),
                ],
              ),

              const SizedBox(height: 9),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 39,
                    width: 39,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _deviceIcon(quote.deviceTypeId),
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.issueDescription.isNotEmpty
                              ? quote.issueDescription
                              : 'technician.quotes.no_description'.tr(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'technician.quotes.order_code'.tr(
                            args: [quote.orderCode],
                          ),
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

              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      quote.address.isNotEmpty
                          ? quote.address
                          : 'technician.quotes.no_address'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'technician.quotes.customer_time'.tr(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Text(
                      quote.requestedTimeType.toUpperCase() == 'NOW' ||
                              quote.requestedTimeType.toUpperCase() ==
                                  'IMMEDIATE'
                          ? _timeLabel(quote.requestedTimeType)
                          : _formatDate(quote.scheduledAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
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
                    'technician.quotes.view_detail'.tr(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
