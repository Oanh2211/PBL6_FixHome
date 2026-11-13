import 'package:fixhome/features/technician/account/specialties/models/technician_specialty_model.dart';
import 'package:fixhome/features/technician/account/specialties/page/specialty_status_badge.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/technician_specialty_api.dart';
import '../cubit/technician_specialty_cubit.dart';
import '../cubit/technician_specialty_state.dart';
import 'technician_specialty_page.dart';

class SpecialtyDetailPage extends StatelessWidget {
  final int id;
  final List<SpecialtyOption> categories;
  final List<SpecialtyOption> deviceTypes;

  const SpecialtyDetailPage({
    super.key,
    required this.id,
    required this.categories,
    required this.deviceTypes,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianSpecialtyCubit(TechnicianSpecialtyApi())..loadDetail(id),
      child: _SpecialtyDetailView(
        id: id,
        categories: categories,
        deviceTypes: deviceTypes,
      ),
    );
  }
}

class _SpecialtyDetailView extends StatelessWidget {
  final int id;
  final List<SpecialtyOption> categories;
  final List<SpecialtyOption> deviceTypes;

  const _SpecialtyDetailView({
    required this.id,
    required this.categories,
    required this.deviceTypes,
  });

  // ================= CATEGORY NAME =================

  String getCategoryName(int id) {
    for (final item in categories) {
      if (item.id == id) return item.name;
    }

    return '${'technician.account.specialty_page.category'.tr()} #$id';
  }

  // ================= DEVICE NAME =================

  String getDeviceName(int id) {
    for (final item in deviceTypes) {
      if (item.id == id) return item.name;
    }

    return '${'technician.account.specialty_page.device'.tr()} #$id';
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'technician.account.specialty_page.detail_title'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TechnicianSpecialtyCubit, TechnicianSpecialtyState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TechnicianSpecialtyCubit>().loadDetail(id);
                      },
                      child: Text(
                        'technician.account.specialty_page.retry'.tr(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final specialty = state.selectedSpecialty;

          if (specialty == null) {
            return Center(
              child: Text('technician.account.specialty_page.no_data'.tr()),
            );
          }

          return _buildContent(context, specialty);
        },
      ),
    );
  }

  // ================= MAIN CONTENT =================

  Widget _buildContent(BuildContext context, TechnicianSpecialtyModel item) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // ================= THÔNG TIN CHUYÊN MÔN =================
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.ac_unit,
                      color: AppColors.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getCategoryName(item.categoryId),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SpecialtyStatusBadge(status: item.status),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 28),

              _infoRow(
                'technician.account.specialty_page.experience'.tr(),
                _experienceLabel(item.experienceLevel),
              ),

              const SizedBox(height: 15),

              _infoRow(
                'technician.account.specialty_page.device_count_label'.tr(),
                item.acceptAllDevices
                    ? 'technician.account.specialty_page.all_devices'.tr()
                    : '${item.deviceTypeIds.length} ${'technician.account.specialty_page.devices'.tr()}',
              ),

              const SizedBox(height: 15),

              _infoRow(
                'technician.account.specialty_page.register_date'.tr(),
                _formatDate(item.createdAt),
              ),

              if (item.reviewedAt != null) ...[
                const SizedBox(height: 15),
                _infoRow(
                  'technician.account.specialty_page.review_date'.tr(),
                  _formatDate(item.reviewedAt),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ================= THIẾT BỊ PHỤ TRÁCH =================
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                Icons.devices_outlined,
                'technician.account.specialty_page.devices_title'.tr(),
              ),

              const SizedBox(height: 15),

              if (item.acceptAllDevices)
                _deviceItem(
                  Icons.devices,
                  'technician.account.specialty_page.all_devices'.tr(),
                )
              else if (item.deviceTypeIds.isEmpty)
                Text(
                  'technician.account.specialty_page.no_devices'.tr(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              else
                ...item.deviceTypeIds.map(
                  (deviceId) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _deviceItem(
                      Icons.devices_other,
                      getDeviceName(deviceId),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ================= CHỨNG CHỈ VÀ HỒ SƠ =================
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                Icons.workspace_premium_outlined,
                'technician.account.specialty_page.evidence'.tr(),
              ),

              const SizedBox(height: 15),

              if (item.evidenceUrls.isEmpty)
                Text(
                  'technician.account.specialty_page.no_evidence'.tr(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              else
                ...item.evidenceUrls.map(
                  (url) => _buildEvidenceItem(context, url),
                ),
            ],
          ),
        ),

        // ================= LÝ DO TỪ CHỐI =================
        if (item.status.toLowerCase() == 'rejected') ...[
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'technician.account.specialty_page.rejection_reason'
                            .tr(),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  item.rejectionReason ??
                      'technician.account.specialty_page.no_reason'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // ================= ACTIONS =================
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editSpecialty(context, item),
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  'technician.account.specialty_page.update_specialty'.tr(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: Text(
                  'technician.account.specialty_page.delete_specialty'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _editSpecialty(
    BuildContext context,
    TechnicianSpecialtyModel item,
  ) async {
    final experienceValues = ['under_2_years', '3_5_years', 'over_5_years'];
    String experience = item.experienceLevel;
    if (!experienceValues.contains(experience)) {
      experience = item.experienceLevel == '3 - 5 năm'
          ? '3_5_years'
          : item.experienceLevel == 'Trên 5 năm'
          ? 'over_5_years'
          : 'under_2_years';
    }
    bool acceptAll = item.acceptAllDevices;
    final selectedDevices = Set<int>.from(item.deviceTypeIds);
    final evidenceControllers = item.evidenceUrls
        .map((url) => TextEditingController(text: url))
        .toList();
    if (evidenceControllers.isEmpty)
      evidenceControllers.add(TextEditingController());

    final formKey = GlobalKey<FormState>();
    final cubit = context.read<TechnicianSpecialtyCubit>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa chuyên môn'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kinh nghiệm',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: experience,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'under_2_years',
                          child: Text('Dưới 2 năm'),
                        ),
                        DropdownMenuItem(
                          value: '3_5_years',
                          child: Text('3 - 5 năm'),
                        ),
                        DropdownMenuItem(
                          value: 'over_5_years',
                          child: Text('Trên 5 năm'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setDialogState(() => experience = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nhận tất cả thiết bị'),
                      value: acceptAll,
                      onChanged: (value) => setDialogState(() {
                        acceptAll = value;
                        if (value) selectedDevices.clear();
                      }),
                    ),
                    if (!acceptAll) ...[
                      const Text(
                        'Thiết bị phụ trách',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ...deviceTypes.map(
                        (device) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(device.name),
                          value: selectedDevices.contains(device.id),
                          onChanged: (checked) => setDialogState(() {
                            if (checked == true) {
                              selectedDevices.add(device.id);
                            } else {
                              selectedDevices.remove(device.id);
                            }
                          }),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Minh chứng',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setDialogState(
                            () => evidenceControllers.add(
                              TextEditingController(),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm'),
                        ),
                      ],
                    ),
                    ...List.generate(
                      evidenceControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: evidenceControllers[index],
                                decoration: const InputDecoration(
                                  hintText: 'https://...',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'Không được để trống';
                                  final uri = Uri.tryParse(value.trim());
                                  if (uri == null ||
                                      !uri.hasAbsolutePath ||
                                      !(uri.scheme == 'http' ||
                                          uri.scheme == 'https')) {
                                    return 'URL không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: evidenceControllers.length == 1
                                  ? null
                                  : () => setDialogState(() {
                                      evidenceControllers[index].dispose();
                                      evidenceControllers.removeAt(index);
                                    }),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (!acceptAll && selectedDevices.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn ít nhất một thiết bị'),
                    ),
                  );
                  return;
                }
                final request = UpdateTechnicianSpecialtyRequest(
                  experienceLevel: experience,
                  acceptAllDevices: acceptAll,
                  deviceTypeIds: acceptAll ? [] : selectedDevices.toList(),
                  evidenceUrls: evidenceControllers
                      .map((e) => e.text.trim())
                      .toList(),
                );
                final ok = await cubit.updateSpecialty(item.id, request);
                if (dialogContext.mounted) Navigator.pop(dialogContext, ok);
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );

    for (final controller in evidenceControllers) {
      controller.dispose();
    }
    if (saved == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa chuyên môn?'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa chuyên môn này không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final success = await context
        .read<TechnicianSpecialtyCubit>()
        .deleteSpecialty(id);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa chuyên môn thành công')),
      );
      Navigator.pop(context, true);
    } else {
      final message =
          context.read<TechnicianSpecialtyCubit>().state.errorMessage ??
          'Không thể xóa chuyên môn';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ================= EVIDENCE ITEM =================

  Widget _buildEvidenceItem(BuildContext context, String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? '';
    final isSvg = path.endsWith('.svg');
    final isPdf = path.endsWith('.pdf');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPdf)
            _buildPdfNotice()
          else if (isSvg)
            _buildSvgPreview(context, url)
          else
            _buildImagePreview(context, url),
        ],
      ),
    );
  }

  // ================= SVG PREVIEW =================

  Widget _buildSvgPreview(BuildContext context, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          height: 210,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: SvgPicture.network(
            url,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildFullscreenButton(context, url, isSvg: true),
      ],
    );
  }

  // ================= IMAGE PREVIEW =================

  Widget _buildImagePreview(BuildContext context, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 230),
            color: Colors.white,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _previewError(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildFullscreenButton(context, url),
      ],
    );
  }

  // ================= FULLSCREEN BUTTON =================

  Widget _buildFullscreenButton(
    BuildContext context,
    String url, {
    bool isSvg = false,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _showEvidenceFullscreen(context, url, isSvg: isSvg),
      icon: const Icon(Icons.fullscreen, size: 20),
      label: Text('technician.account.specialty_page.view_fullscreen'.tr()),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }

  // ================= FULLSCREEN VIEWER =================

  void _showEvidenceFullscreen(
    BuildContext context,
    String url, {
    bool isSvg = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EvidenceFullscreenPage(url: url, isSvg: isSvg),
      ),
    );
  }

  // ================= PDF NOTICE =================

  Widget _buildPdfNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Column(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: AppColors.error, size: 38),
          SizedBox(height: 8),
          Text(
            'Tệp chứng chỉ đang ở định dạng PDF. Hiện tại màn hình chỉ hỗ trợ xem ảnh (JPG, PNG, WEBP, SVG).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ================= PREVIEW ERROR =================

  Widget _previewError() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: AppColors.error, size: 35),
          SizedBox(height: 8),
          Text(
            'Không thể tải hình ảnh chứng chỉ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ================= EXPERIENCE =================

  String _experienceLabel(String value) {
    switch (value) {
      case '2 năm':
      case 'under_2_years':
        return 'technician.account.specialty_page.experience_2'.tr();

      case '3 - 5 năm':
      case '3_5_years':
        return 'technician.account.specialty_page.experience_3_5'.tr();

      case 'Trên 5 năm':
      case 'over_5_years':
        return 'technician.account.specialty_page.experience_over_5'.tr();

      default:
        return value;
    }
  }

  // ================= FORMAT DATE =================

  String _formatDate(DateTime? date) {
    if (date == null) return '--';

    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  // ================= CARD =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ================= INFO ROW =================

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DEVICE ITEM =================

  Widget _deviceItem(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Màn hình xem chứng chỉ toàn màn hình.
/// Người dùng có thể phóng to/thu nhỏ ảnh bằng thao tác pinch.
class _EvidenceFullscreenPage extends StatelessWidget {
  final String url;
  final bool isSvg;

  const _EvidenceFullscreenPage({required this.url, this.isSvg = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'technician.account.specialty_page.evidence'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: isSvg
              ? SvgPicture.network(
                  url,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Không thể tải hình ảnh chứng chỉ',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
