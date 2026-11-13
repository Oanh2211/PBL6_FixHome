import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/booking/pages/booking_page.dart';
import 'package:fixhome/features/customer/home/select_device/api/device_type_api.dart';
import 'package:fixhome/features/customer/home/select_device/cubit/device_type_cubit.dart';
import 'package:fixhome/features/customer/home/select_device/cubit/device_type_state.dart';
import 'package:fixhome/features/customer/home/select_device/model/device_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class DeviceTypePage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Function(DeviceTypeModel)? onDeviceTap;

  const DeviceTypePage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeviceTypeCubit(DeviceTypeApi(dio: DioClient.instance))
            ..setCategory(categoryId),
      child: _DeviceTypeView(
        categoryId: categoryId,
        categoryName: categoryName,
        onDeviceTap: onDeviceTap,
      ),
    );
  }
}

class _DeviceTypeView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Function(DeviceTypeModel)? onDeviceTap;

  const _DeviceTypeView({
    required this.categoryId,
    required this.categoryName,
    this.onDeviceTap,
  });

  @override
  State<_DeviceTypeView> createState() => _DeviceTypeViewState();
}

class _DeviceTypeViewState extends State<_DeviceTypeView> {
  final TextEditingController _searchController = TextEditingController();

  DeviceTypeModel? _selectedDevice;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<DeviceTypeCubit, DeviceTypeState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () {
                    return context.read<DeviceTypeCubit>().refreshDeviceTypes();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildSearchBar(context)),
                      SliverToBoxAdapter(child: _buildTitle()),
                      _buildDeviceContent(context, state),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          key: const Key('device_search_field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            context.read<DeviceTypeCubit>().searchDeviceTypes(value.trim());

            setState(() {
              _selectedDevice = null;
            });
          },
          decoration: InputDecoration(
            hintText: 'customer.device_type.search_hint'.tr(),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: const Icon(
              Icons.search,
              size: 21,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _selectedDevice = null;
                      });

                      context.read<DeviceTypeCubit>().clearSearch();
                    },
                    icon: const Icon(Icons.close, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            context.read<DeviceTypeCubit>().searchDeviceTypes(value.trim());

            setState(() {
              _selectedDevice = null;
            });
          },
        ),
      ),
    );
  }

  // ================= TITLE =================

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Text(
            'customer.device_type.title'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DEVICE CONTENT =================

  Widget _buildDeviceContent(BuildContext context, DeviceTypeState state) {
    if (state.status == DeviceTypeStatus.loading && state.devices.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.status == DeviceTypeStatus.failure && state.devices.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildError(context),
      );
    }

    if (state.devices.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildEmpty());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final device = state.devices[index];
          return _buildDeviceItem(device);
        }, childCount: state.devices.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
      ),
    );
  }

  // ================= DEVICE ITEM =================

  Widget _buildDeviceItem(DeviceTypeModel device) {
    final isSelected = _selectedDevice?.id == device.id;
    final color = _getDeviceColor(device.code);

    return InkWell(
      key: Key('device_${device.id}'),
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedDevice = device;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      color: _getDeviceBackground(device.code),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(child: _buildDeviceIcon(device)),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 19,
                        height: 19,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              device.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DEVICE ICON =================

  Widget _buildDeviceIcon(DeviceTypeModel device) {
    final url = device.iconUrl?.trim() ?? '';

    // URL null hoặc rỗng: hiển thị icon thay thế.
    if (url.isEmpty) {
      return _buildFallbackIcon(
        _getRandomFallbackIcon('${device.id}_${device.code}'),
      );
    }

    // URL có dữ liệu: thử tải SVG từ server.
    return SvgPicture.network(
      url,
      fit: BoxFit.contain,
      width: 40,
      height: 40,
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      placeholderBuilder: (context) {
        return const SizedBox(
          width: 40,
          height: 40,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // URL lỗi hoặc không tải được SVG: dùng icon thay thế.
        return _buildFallbackIcon(
          _getRandomFallbackIcon('${device.id}_${device.code}'),
        );
      },
    );
  }

  // ================= FALLBACK ICON =================

  IconData _getRandomFallbackIcon(String key) {
    final icons = <IconData>[
      Icons.ac_unit_rounded,
      Icons.kitchen_rounded,
      Icons.local_laundry_service_rounded,
      Icons.water_drop_rounded,
      Icons.microwave_rounded,
      Icons.tv_rounded,
      Icons.lightbulb_outline_rounded,
      Icons.electrical_services_rounded,
      Icons.home_repair_service_rounded,
      Icons.air,
      Icons.plumbing_rounded,
      Icons.build_circle_outlined,
      Icons.cleaning_services_outlined,
      Icons.settings_outlined,
    ];

    final index = key.hashCode.abs() % icons.length;
    return icons[index];
  }

  Widget _buildFallbackIcon(IconData icon) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Icon(icon, color: AppColors.primary, size: 35),
    );
  }

  // ================= EMPTY =================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.devices_other_outlined,
              size: 55,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'customer.device_type.empty'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ERROR =================

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'customer.device_type.load_error'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<DeviceTypeCubit>().refreshDeviceTypes();
              },
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM BUTTON =================

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _selectedDevice?.name ??
                        'customer.device_type.not_selected'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_selectedDevice != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDevice = null;
                      });
                    },
                    child: Text(
                      'customer.device_type.change'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _selectedDevice == null
                    ? null
                    : () {
                        final device = _selectedDevice!;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(
                              categoryId: widget.categoryId,
                              categoryName: widget.categoryName,
                              deviceTypeId: device.id,
                              deviceName: device.name,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.textHint.withValues(
                    alpha: 0.35,
                  ),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  'customer.device_type.continue'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DEVICE COLORS =================

  Color _getDeviceColor(String code) {
    final value = code.toLowerCase();

    if (value.contains('washing') || value.contains('washer')) {
      return const Color(0xFF3156B8);
    }

    if (value.contains('air') || value.contains('conditioner')) {
      return const Color(0xFF1687B8);
    }

    if (value.contains('water')) {
      return const Color(0xFF168F9D);
    }

    if (value.contains('oven') || value.contains('microwave')) {
      return const Color(0xFFE36C36);
    }

    return AppColors.primary;
  }

  Color _getDeviceBackground(String code) {
    final value = code.toLowerCase();

    if (value.contains('washing')) {
      return const Color(0xFFE8EDFF);
    }

    if (value.contains('air')) {
      return const Color(0xFFE0F4FF);
    }

    if (value.contains('water')) {
      return const Color(0xFFE1F7F7);
    }

    if (value.contains('oven')) {
      return const Color(0xFFFFE9DF);
    }

    return const Color(0xFFE8EDFF);
  }
}
