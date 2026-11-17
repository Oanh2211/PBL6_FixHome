import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/technician_order_detail_cubit.dart';

class TechnicianAcceptancePage extends StatefulWidget {
  const TechnicianAcceptancePage({super.key});

  @override
  State<TechnicianAcceptancePage> createState() =>
      _TechnicianAcceptancePageState();
}

class _TechnicianAcceptancePageState extends State<TechnicianAcceptancePage> {
  final TextEditingController _workCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    final state = context.read<TechnicianOrderDetailCubit>().state;
    if (state is OrderDetailLoaded) {
      _workCtrl.text = state.savedWorkPerformed.isNotEmpty
          ? state.savedWorkPerformed
          : state.order.issueDescription;
    }
  }

  @override
  void dispose() {
    _workCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedFiles.length >= 5) return;
    if (source == ImageSource.gallery) {
      final pickedList = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedList.isNotEmpty) {
        setState(() {
          final remaining = 5 - _selectedFiles.length;
          _selectedFiles.addAll(
            pickedList.take(remaining).map((e) => File(e.path)),
          );
        });
      }
    } else {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedFiles.add(File(picked.path)));
      }
    }
  }

  Future<void> _onConfirmComplete() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chụp hoặc chọn ít nhất 1 ảnh nghiệm thu thiết bị.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final workPerformed = _workCtrl.text.trim();
    if (workPerformed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung công việc đã thực hiện.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await context
        .read<TechnicianOrderDetailCubit>()
        .submitAcceptanceAndComplete(
          workPerformed: workPerformed,
          completionNote: _noteCtrl.text.trim(),
          evidenceFiles: _selectedFiles,
        );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nghiệm thu & Hoàn tất đơn hàng',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<TechnicianOrderDetailCubit, TechnicianOrderDetailState>(
        builder: (context, state) {
          final loaded = state is OrderDetailLoaded ? state : null;
          final finalAmount = loaded?.savedFinalAmount ?? 0;
          final warrantyDays = loaded?.savedWarrantyDays ?? 30;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1: Tóm tắt số tiền & bảo hành đã chốt
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng thanh toán chốt giá',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currencyFormat.format(finalAmount)} đ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Bảo hành: $warrantyDays ngày',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 2: Công việc đã thực hiện & Ghi chú nghiệm thu
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Công việc đã thực hiện *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _workCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Nhập hạng mục đã sửa chữa / thay thế...',
                          filled: true,
                          fillColor: AppColors.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ghi chú nghiệm thu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Tình trạng thiết bị sau khi chạy thử, lưu ý cho khách...',
                          filled: true,
                          fillColor: AppColors.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 3: Khu vực chọn/chụp ảnh nghiệm thu
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hình ảnh nghiệm thu sau sửa chữa *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_selectedFiles.length}/5',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                              ),
                              label: const Text('Chụp ảnh'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 18,
                              ),
                              label: const Text('Thư viện'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Preview danh sách ảnh đã chọn
                      if (_selectedFiles.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedFiles[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedFiles.removeAt(index),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child:
            BlocBuilder<TechnicianOrderDetailCubit, TechnicianOrderDetailState>(
              builder: (context, state) {
                final isSubmitting =
                    state is OrderDetailLoaded && state.isUpdating;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _onConfirmComplete,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      isSubmitting
                          ? 'Đang tải ảnh & hoàn tất...'
                          : 'Gửi nghiệm thu & Hoàn tất đơn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
