import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/technician/home/quote/cubit/technician_quote_cubit.dart';
import 'package:fixhome/features/technician/home/quote/model/technician_submit_quote_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianSubmitQuotePage extends StatefulWidget {
  final int quoteId;

  // Giữ tham số detail để tương thích với lời gọi
  // từ trang chi tiết yêu cầu trước đó.
  final Object? detail;

  const TechnicianSubmitQuotePage({
    super.key,
    required this.quoteId,
    this.detail,
  });

  @override
  State<TechnicianSubmitQuotePage> createState() =>
      _TechnicianSubmitQuotePageState();
}

class _TechnicianSubmitQuotePageState extends State<TechnicianSubmitQuotePage> {
  final _formKey = GlobalKey<FormState>();

  final _noteController = TextEditingController();

  // Tiền công kỹ thuật
  final _laborMinController = TextEditingController();
  final _laborMaxController = TextEditingController();

  // Thời gian bảo hành
  final _warrantyController = TextEditingController(text: '365');

  final List<_QuotePart> _parts = [];

  bool _isSubmitting = false;

  int get _laborMin => _parseMoney(_laborMinController.text);

  int get _laborMax => _parseMoney(_laborMaxController.text);

  int get _partsMin {
    return _parts.fold(0, (sum, part) => sum + part.quantity * part.minPrice);
  }

  int get _partsMax {
    return _parts.fold(0, (sum, part) => sum + part.quantity * part.maxPrice);
  }

  int get _totalMin => _laborMin + _partsMin;

  int get _totalMax => _laborMax + _partsMax;

  int _parseMoney(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String _formatMoney(int value) {
    return NumberFormat('#,###', 'vi_VN').format(value);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _laborMinController.dispose();
    _laborMaxController.dispose();
    _warrantyController.dispose();

    for (final part in _parts) {
      part.dispose();
    }

    super.dispose();
  }

  // ==========================================
  // ADD PART
  // ==========================================

  void _addPart() {
    setState(() {
      _parts.add(_QuotePart());
    });
  }

  void _removePart(int index) {
    setState(() {
      _parts[index].dispose();
      _parts.removeAt(index);
    });
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  // ==========================================
  // VALIDATE
  // ==========================================

  bool _validateQuote() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_laborMin > _laborMax) {
      _showMessage(
        'technician.quote_submit.invalid_labor_price'.tr(),
        isError: true,
      );
      return false;
    }

    for (int i = 0; i < _parts.length; i++) {
      final part = _parts[i];

      if (part.minPrice > part.maxPrice) {
        _showMessage(
          'technician.quote_submit.invalid_part_price'.tr(args: ['${i + 1}']),
          isError: true,
        );
        return false;
      }
    }

    if (_totalMin > _totalMax) {
      _showMessage('technician.quote_submit.invalid_total'.tr(), isError: true);
      return false;
    }

    return true;
  }

  // ==========================================
  // SUBMIT API
  // ==========================================

  Future<void> _submitQuote() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;
    if (!_validateQuote()) return;

    // 1. Tạo item tiền công (LABOR)
    final laborItem = TechnicianSubmitQuoteItemModel(
      quantity: 1,
      itemName: 'Tiền công kỹ thuật', // Hoặc dùng key localization tương ứng
      itemType: 'LABOR',
      minUnitPrice: _laborMin,
      maxUnitPrice: _laborMax,
    );

    // 2. Tạo danh sách linh kiện (PART)
    final partItems = _parts.map((part) {
      return TechnicianSubmitQuoteItemModel(
        quantity: part.quantity,
        itemName: part.nameController.text.trim(),
        itemType: 'PART',
        minUnitPrice: part.minPrice,
        maxUnitPrice: part.maxPrice,
      );
    }).toList();

    // 3. Gộp cả LABOR và PART vào items để khớp với _totalMin và _totalMax
    final items = [laborItem, ...partItems];

    final request = TechnicianSubmitQuoteRequestModel(
      note: _noteController.text.trim(),
      items: items,
      estimatedMinAmount: _totalMin,
      estimatedMaxAmount: _totalMax,
      warrantyDurationDays: int.parse(_warrantyController.text.trim()),
    );

    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<TechnicianQuoteCubit>();

      final success = await cubit.submitQuote(
        quoteId: widget.quoteId,
        request: request,
      );

      if (!mounted) return;

      if (!success) {
        final message =
            cubit.lastActionError ?? 'technician.quote_submit.error'.tr();
        debugPrint('UI SUBMIT QUOTE ERROR: $message');
        _showMessage(message, isError: true);
        return;
      }

      _showMessage('technician.quote_submit.success'.tr(), isError: false);

      // Trả kết quả về trang chi tiết.
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('SUBMIT QUOTE PAGE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      final message = context
          .read<TechnicianQuoteCubit>()
          .getActionErrorMessage(e);
      _showMessage(message, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _moneyField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => _updateUI(),
      decoration: _inputDecoration(
        label: label,
        hint: hint ?? '0',
        prefix: const Icon(Icons.payments_outlined, size: 19),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'technician.quote_submit.required'.tr();
        }

        if (_parseMoney(value) <= 0) {
          return 'technician.quote_submit.invalid_price'.tr();
        }

        return null;
      },
    );
  }

  // ==========================================
  // LABOR SECTION
  // ==========================================

  Widget _buildLaborSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'technician.quote_submit.labor_title'.tr(),
            icon: Icons.handyman_outlined,
          ),

          const SizedBox(height: 6),

          Text(
            'technician.quote_submit.labor_description'.tr(),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _moneyField(
                  label: 'technician.quote_submit.min_price'.tr(),
                  controller: _laborMinController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _moneyField(
                  label: 'technician.quote_submit.max_price'.tr(),
                  controller: _laborMaxController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PART CARD
  // ==========================================

  Widget _buildPartCard(int index) {
    final part = _parts[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'technician.quote_submit.part'.tr()} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removePart(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                tooltip: 'common.delete'.tr(),
              ),
            ],
          ),

          TextFormField(
            controller: part.nameController,
            decoration: _inputDecoration(
              label: 'technician.quote_submit.part_name'.tr(),
              hint: 'technician.quote_submit.part_hint'.tr(),
              prefix: const Icon(Icons.build_outlined, size: 19),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'technician.quote_submit.required'.tr();
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          Text(
            'technician.quote_submit.quantity'.tr(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (part.quantity > 1) {
                    setState(() => part.quantity--);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),

              Text(
                '${part.quantity}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() => part.quantity++);
                },
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _moneyField(
                  label: 'technician.quote_submit.min_price'.tr(),
                  controller: part.minController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _moneyField(
                  label: 'technician.quote_submit.max_price'.tr(),
                  controller: part.maxController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${'technician.quote_submit.part_total'.tr()}: '
              '${_formatMoney(part.quantity * part.minPrice)}'
              ' - '
              '${_formatMoney(part.quantity * part.maxPrice)} đ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PART SECTION
  // ==========================================

  Widget _buildPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                'technician.quote_submit.parts_title'.tr(),
                icon: Icons.inventory_2_outlined,
              ),
            ),

            TextButton.icon(
              onPressed: _addPart,
              icon: const Icon(Icons.add, size: 17),
              label: Text(
                'technician.quote_submit.add_part'.tr(),
                style: const TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (_parts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textHint,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  'technician.quote_submit.no_parts'.tr(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addPart,
                  icon: const Icon(Icons.add, size: 17),
                  label: Text('technician.quote_submit.add_part'.tr()),
                ),
              ],
            ),
          )
        else
          ...List.generate(_parts.length, (index) => _buildPartCard(index)),
      ],
    );
  }

  // ==========================================
  // WARRANTY
  // ==========================================

  Widget _buildWarrantySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'technician.quote_submit.warranty_title'.tr(),
            icon: Icons.verified_outlined,
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _warrantyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              label: 'technician.quote_submit.warranty_days'.tr(),
              hint: '365',
              prefix: const Icon(Icons.calendar_month_outlined, size: 19),
            ),
            validator: (value) {
              final days = int.tryParse(value ?? '');

              if (days == null || days < 0) {
                return 'technician.quote_submit.invalid_warranty'.tr();
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NOTE
  // ==========================================

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'technician.quote_submit.note_title'.tr(),
            icon: Icons.notes_outlined,
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _noteController,
            maxLines: 4,
            decoration: _inputDecoration(
              label: 'technician.quote_submit.note'.tr(),
              hint: 'technician.quote_submit.note_hint'.tr(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOTAL
  // ==========================================

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'technician.quote_submit.total_title'.tr(),
            icon: Icons.receipt_long_outlined,
          ),

          const SizedBox(height: 15),

          _totalRow('technician.quote_submit.labor'.tr(), _laborMin, _laborMax),

          const SizedBox(height: 9),

          _totalRow(
            'technician.quote_submit.parts_title'.tr(),
            _partsMin,
            _partsMax,
          ),

          const Divider(height: 22),

          Text(
            'technician.quote_submit.estimated_total'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '${_formatMoney(_totalMin)} - '
            '${_formatMoney(_totalMax)} đ',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'technician.quote_submit.total_hint'.tr(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, int min, int max) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '${_formatMoney(min)} - ${_formatMoney(max)} đ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'technician.quote_submit.title'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'technician.quote_submit.description'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildLaborSection(),

              const SizedBox(height: 18),

              _buildPartsSection(),

              const SizedBox(height: 18),

              _buildWarrantySection(),

              const SizedBox(height: 18),

              _buildNoteSection(),

              const SizedBox(height: 18),

              _buildTotalSection(),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitQuote,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 17,
                          width: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                  label: Text(
                    _isSubmitting
                        ? 'common.loading'.tr()
                        : 'technician.quote_submit.submit'.tr(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PART MODEL LOCAL
// ==========================================

class _QuotePart {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController minController = TextEditingController();

  final TextEditingController maxController = TextEditingController();

  int quantity = 1;

  int get minPrice => int.tryParse(minController.text.trim()) ?? 0;

  int get maxPrice => int.tryParse(maxController.text.trim()) ?? 0;

  void dispose() {
    nameController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}
