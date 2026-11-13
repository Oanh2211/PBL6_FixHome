import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

class BookingStepIndicator extends StatelessWidget {
  final int currentStep;

  const BookingStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'customer.booking.step_description',
      'customer.booking.step_location',
      'customer.booking.step_confirm',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (i) {
          // Các vị trí chẵn (0, 2, 4) là từng bước (CircleAvatar + Text)
          if (i.isEven) {
            final index = i ~/ 2;
            final active = index <= currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: active
                      ? AppColors.primary
                      : AppColors.border,
                  child: Icon(
                    index < currentStep ? Icons.check : Icons.circle,
                    size: index < currentStep ? 15 : 7,
                    color: active ? Colors.white : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  steps[index].tr(),
                  style: TextStyle(
                    fontSize: 9,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          // Các vị trí lẻ (1, 3) là đường kẻ nối giãn đều ở giữa
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              // Căn giữa đường kẻ theo chiều dọc của CircleAvatar (radius 13 - height/2 = 12)
              margin: const EdgeInsets.only(top: 12, left: 6, right: 6),
              color: stepIndex < currentStep
                  ? AppColors.primary
                  : AppColors.border,
            ),
          );
        }),
      ),
    );
  }
}
