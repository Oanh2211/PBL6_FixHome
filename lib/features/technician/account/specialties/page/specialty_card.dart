import 'package:fixhome/features/technician/account/specialties/models/technician_specialty_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';

import 'specialty_status_badge.dart';

class SpecialtyCard extends StatelessWidget {
  final TechnicianSpecialtyModel specialty;
  final String categoryName;
  final VoidCallback onTap;

  const SpecialtyCard({
    super.key,
    required this.specialty,
    required this.categoryName,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (categoryName.toLowerCase()) {
      case 'điện lạnh':
      case 'air conditioning':
        return Icons.ac_unit;
      case 'điện nước':
      case 'plumbing':
        return Icons.water_drop_outlined;
      case 'thiết bị nhà bếp':
      case 'kitchen appliances':
        return Icons.kitchen_outlined;
      default:
        return Icons.home_repair_service_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: AppColors.primary, size: 23),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    specialty.acceptAllDevices
                        ? 'technician.account.specialty_page.all_devices'.tr()
                        : 'technician.account.specialty_page.device_count'.tr(
                            namedArgs: {
                              'count': '${specialty.deviceTypeIds.length}',
                            },
                          ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SpecialtyStatusBadge(status: specialty.status),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
