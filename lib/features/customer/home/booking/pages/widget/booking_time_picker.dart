import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

class BookingTimePicker extends StatelessWidget {
  final String selectedType;
  final DateTime? scheduledAt;
  final Function() onSelectNow;
  final Function(DateTime) onSelectScheduled;

  const BookingTimePicker({
    super.key,
    required this.selectedType,
    required this.scheduledAt,
    required this.onSelectNow,
    required this.onSelectScheduled,
  });

  Future<void> _chooseDateTime(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!result.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('customer.booking.invalid_schedule'.tr())),
      );
      return;
    }

    onSelectScheduled(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'customer.booking.time_title'.tr(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        _option(
          title: 'customer.booking.now'.tr(),
          subtitle: 'customer.booking.now_description'.tr(),
          selected: selectedType == 'NOW',
          icon: Icons.flash_on_rounded,
          onTap: onSelectNow,
        ),

        const SizedBox(height: 10),

        _option(
          title: 'customer.booking.scheduled'.tr(),
          subtitle: 'customer.booking.scheduled_description'.tr(),
          selected: selectedType == 'SCHEDULED',
          icon: Icons.calendar_month,
          onTap: () => _chooseDateTime(context),
        ),

        if (selectedType == 'SCHEDULED' && scheduledAt != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(scheduledAt!),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _chooseDateTime(context),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _option({
    required String title,
    required String subtitle,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
