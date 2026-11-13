import 'package:fixhome/features/customer/home/booking/pages/view_quote_page.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingConfirmPage extends StatefulWidget {
  final int categoryId;
  final int deviceTypeId;

  final String categoryName;
  final String deviceName;

  const BookingConfirmPage({
    super.key,
    required this.categoryId,
    required this.deviceTypeId,
    required this.categoryName,
    required this.deviceName,
  });

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.success && !_navigated) {
          _navigated = true;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                icon: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 55,
                ),
                title: Text('customer.booking.success'.tr()),
                content: Text(
                  '${'customer.booking.booking_code'.tr()}: '
                  '${state.booking?.bookingCode ?? state.booking?.id}',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => ViewQuotePage()),
                      );
                    },
                    child: Text('common.confirm'.tr()),
                  ),
                ],
              );
            },
          );
        }

        if (state.status == BookingStatus.failure &&
            state.errorMessage != null) {
          final error = state.errorMessage!;

          final message = error.startsWith('customer.booking.')
              ? error.tr()
              : error;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('customer.booking.confirm_title'.tr()),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: Column(
            children: [
              const BookingStepIndicator(currentStep: 2),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(
                        icon: Icons.devices,
                        title: 'customer.booking.device_info'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _info(
                              'customer.booking.category'.tr(),
                              widget.categoryName,
                            ),
                            _info(
                              'customer.booking.device'.tr(),
                              widget.deviceName,
                            ),
                          ],
                        ),
                      ),

                      _section(
                        icon: Icons.description_outlined,
                        title: 'customer.booking.description_title'.tr(),
                        child: Text(state.issueDescription),
                      ),

                      _section(
                        icon: Icons.photo_library_outlined,
                        title: 'customer.booking.media_title'.tr(),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...state.mediaList.map(
                              (media) => Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      media.mediaType == 'VIDEO'
                                          ? Icons.videocam
                                          : Icons.image,
                                      color: AppColors.primary,
                                      size: 17,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '#${media.id}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (state.mediaList.isEmpty)
                              Text('customer.booking.no_media'.tr()),
                          ],
                        ),
                      ),

                      _section(
                        icon: Icons.location_on,
                        title: 'customer.booking.location_title'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.address),
                            const SizedBox(height: 5),
                            Text(
                              '${state.latitude}, ${state.longitude}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _section(
                        icon: Icons.access_time,
                        title: 'customer.booking.time_title'.tr(),
                        child: Text(
                          (state.requestedTimeType == 'SCHEDULED' &&
                                  state.scheduledAt != null)
                              ? DateFormat(
                                  'HH:mm - dd/MM/yyyy',
                                ).format(state.scheduledAt!)
                              : 'customer.booking.now'.tr(),
                        ),
                      ),

                      _section(
                        icon: Icons.person_outline,
                        title: 'customer.booking.contact_title'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _info(
                              'customer.booking.contact_name'.tr(),
                              state.contactName,
                            ),
                            _info(
                              'customer.booking.contact_phone'.tr(),
                              state.contactPhone,
                            ),
                            _info(
                              'customer.booking.customer_note'.tr(),
                              state.customerNote.isEmpty
                                  ? 'common.not_available'.tr()
                                  : state.customerNote,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSubmitButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, BookingState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textHint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                state.isSubmitting || state.status == BookingStatus.success
                ? null
                : () {
                    context.read<BookingCubit>().createBooking(
                      categoryId: widget.categoryId,
                      deviceTypeId: widget.deviceTypeId,
                    );
                  },
            child: state.isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'customer.booking.confirm_booking'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
