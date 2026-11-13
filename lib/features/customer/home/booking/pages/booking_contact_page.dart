import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/home/booking/cubit/booking_cubit.dart';
import 'package:fixhome/features/customer/home/booking/pages/booking_confirm_page.dart';
import 'package:fixhome/features/customer/home/booking/pages/widget/booking_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingContactPage extends StatefulWidget {
  final int categoryId;
  final int deviceTypeId;
  final String categoryName;
  final String deviceName;

  const BookingContactPage({
    super.key,
    required this.categoryId,
    required this.deviceTypeId,
    required this.categoryName,
    required this.deviceName,
  });

  @override
  State<BookingContactPage> createState() => _BookingContactPageState();
}

class _BookingContactPageState extends State<BookingContactPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<BookingCubit>().state;
    _nameController = TextEditingController(text: state.contactName);
    _phoneController = TextEditingController(text: state.contactPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continueToConfirm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showError('Vui lòng nhập họ tên người liên hệ.');
      return;
    }
    if (phone.isEmpty) {
      _showError('Vui lòng nhập số điện thoại liên hệ.');
      return;
    }

    // Kiểm tra định dạng số điện thoại cơ bản tại Việt Nam.
    final normalizedPhone = phone.replaceAll(RegExp(r'[\s.-]'), '');
    if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(normalizedPhone)) {
      _showError('Số điện thoại chưa đúng định dạng.');
      return;
    }

    final cubit = context.read<BookingCubit>();
    cubit.updateContact(name: name, phone: normalizedPhone);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BookingConfirmPage(
            categoryId: widget.categoryId,
            deviceTypeId: widget.deviceTypeId,
            categoryName: widget.categoryName,
            deviceName: widget.deviceName,
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _input({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông tin liên hệ'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          const BookingStepIndicator(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Vui lòng cung cấp thông tin để kỹ thuật viên có thể liên hệ và xác nhận lịch sửa chữa.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _input(
                    label: 'Họ và tên người liên hệ *',
                    hint: 'Nhập họ và tên',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  _input(
                    label: 'Số điện thoại *',
                    hint: 'Ví dụ: 0912345678',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                ],
              ),
            ),
          ),
          _bottomButton(),
        ],
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
            onPressed: _continueToConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
