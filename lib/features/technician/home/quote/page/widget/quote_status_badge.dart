import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';

class QuoteStatusBadge extends StatelessWidget {
  final String status;

  const QuoteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();

    Color color;
    Color background;
    String label;

    switch (normalized) {
      case 'PENDING':
      case 'INVITED':
      case 'NEW':
        color = const Color(0xFF2563EB);
        background = const Color(0xFFEFF6FF);
        label = 'technician.quotes.status.pending'.tr();
        break;

      case 'ACCEPTED':
      case 'RESPONDED':
        color = AppColors.success;
        background = const Color(0xFFDCFCE7);
        label = 'technician.quotes.status.accepted'.tr();
        break;

      case 'REJECTED':
      case 'DECLINED':
        color = AppColors.error;
        background = const Color(0xFFFEE2E2);
        label = 'technician.quotes.status.rejected'.tr();
        break;

      case 'EXPIRED':
        color = AppColors.textSecondary;
        background = AppColors.surfaceMuted;
        label = 'technician.quotes.status.expired'.tr();
        break;

      default:
        color = AppColors.textSecondary;
        background = AppColors.surfaceMuted;
        label = status.isEmpty ? '---' : status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
