import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/home/booking/cubit/booking_cubit.dart';
import 'package:fixhome/features/customer/home/booking/cubit/booking_state.dart';
import 'package:fixhome/features/customer/home/booking/pages/booking_contact_page.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_step_indicator.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_time_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingTimeNotePage extends StatefulWidget {
  final int categoryId;
  final int deviceTypeId;
  final String categoryName;
  final String deviceName;

  const BookingTimeNotePage({
    super.key,
    required this.categoryId,
    required this.deviceTypeId,
    required this.categoryName,
    required this.deviceName,
  });

  @override
  State<BookingTimeNotePage> createState() => _BookingTimeNotePageState();
}

class _BookingTimeNotePageState extends State<BookingTimeNotePage> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    _noteController = TextEditingController(
      text: context.read<BookingCubit>().state.customerNote,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Lưu ghi chú và chuyển sang trang nhập thông tin liên hệ.
  void _continue() {
    final cubit = context.read<BookingCubit>();

    cubit.updateCustomerNote(_noteController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BookingContactPage(
            categoryId: widget.categoryId,
            deviceTypeId: widget.deviceTypeId,
            categoryName: widget.categoryName,
            deviceName: widget.deviceName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('customer.booking.time_note_page_title'.tr()),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Column(
            children: [
              const BookingStepIndicator(currentStep: 2),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Địa chỉ sửa chữa đã chọn.
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'customer.booking.repair_location'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.address.isEmpty
                                        ? 'customer.booking.no_address'.tr()
                                        : state.address,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Chọn thời gian sửa chữa.
                      BookingTimePicker(
                        selectedType: state.requestedTimeType,
                        scheduledAt: state.scheduledAt,
                        onSelectNow: () {
                          context.read<BookingCubit>().selectNow();
                        },
                        onSelectScheduled: (date) {
                          context.read<BookingCubit>().selectScheduled(date);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Tiêu đề ghi chú.
                      Text(
                        'customer.booking.note_title'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Nội dung ghi chú.
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'customer.booking.note_hint'.tr(),
                          filled: true,
                          fillColor: AppColors.surface,
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _bottomButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'customer.booking.continue'.tr(),
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
