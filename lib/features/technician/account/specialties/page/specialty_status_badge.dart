import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';

class SpecialtyStatusBadge extends StatelessWidget {
  final String status;

  const SpecialtyStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color background;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        color = AppColors.success;
        background = AppColors.success.withOpacity(0.1);
        label = 'technician.account.specialty_page.approved'.tr();
        break;

      case 'rejected':
        color = AppColors.error;
        background = AppColors.error.withOpacity(0.1);
        label = 'technician.account.specialty_page.rejected'.tr();
        break;

      default:
        color = Colors.orange;
        background = Colors.orange.withOpacity(0.12);
        label = 'technician.account.specialty_page.pending'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
