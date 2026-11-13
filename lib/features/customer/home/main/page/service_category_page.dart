import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/customer/home/main/api/service_category_api.dart';
import 'package:fixhome/features/customer/home/main/cubit/service_category_cubit.dart';
import 'package:fixhome/features/customer/home/main/cubit/service_category_state.dart';
import 'package:fixhome/features/customer/home/main/model/service_category_model.dart';
import 'package:fixhome/features/customer/home/main/model/catalog_search_model.dart';
import 'package:fixhome/features/customer/home/select_device/page/device_type_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:fixhome/common/constants/app_color.dart';

class ServiceCategoryPage extends StatelessWidget {
  final Function(ServiceCategoryModel)? onCategoryTap;

  const ServiceCategoryPage({super.key, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceCategoryCubit(ServiceCategoryApi(dio: DioClient.instance))
            ..loadCategories(),
      child: _ServiceCategoryView(onCategoryTap: onCategoryTap),
    );
  }
}

class _ServiceCategoryView extends StatefulWidget {
  final Function(ServiceCategoryModel)? onCategoryTap;

  const _ServiceCategoryView({this.onCategoryTap});

  @override
  State<_ServiceCategoryView> createState() => _ServiceCategoryViewState();
}

class _ServiceCategoryViewState extends State<_ServiceCategoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ServiceCategoryCubit, ServiceCategoryState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              return context.read<ServiceCategoryCubit>().refreshCategories();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar(context)),
                SliverToBoxAdapter(child: _buildPromotionBanner()),
                SliverToBoxAdapter(child: _buildSectionTitle()),
                _buildCategoryContent(context, state),
                if (state.searchQuery.trim().isNotEmpty)
                  _buildDeviceTypeSection(state),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= SEARCH BAR =================

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          key: const Key('category_search_field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'customer.home_tab.service_category.search_hint'.tr(),
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 21,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      context.read<ServiceCategoryCubit>().loadCategories();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close, size: 19),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
          onChanged: (value) {
            setState(() {});
            context.read<ServiceCategoryCubit>().searchCategories(value);
          },
        ),
      ),
    );
  }

  // ================= PROMOTION BANNER =================

  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3159B8), Color(0xFF12376D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 5,
              child: Icon(
                Icons.verified_user_outlined,
                size: 75,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'customer.home_tab.service_category.promotion_tag'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'customer.home_tab.service_category.promotion_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'customer.home_tab.service_category.promotion_description'
                      .tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'customer.home_tab.service_category.promotion_code'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'customer.home_tab.service_category.promotion_discount'
                          .tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY TITLE =================

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 12),
      child: Text(
        'customer.home_tab.service_category.title'.tr(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CATEGORY CONTENT =================

  Widget _buildCategoryContent(
    BuildContext context,
    ServiceCategoryState state,
  ) {
    if (state.status == ServiceCategoryStatus.loading &&
        state.categories.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.status == ServiceCategoryStatus.failure &&
        state.categories.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 45,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  'customer.home_tab.service_category.load_error'.tr(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<ServiceCategoryCubit>().loadCategories();
                  },
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Text(
              'customer.home_tab.service_category.empty'.tr(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = state.categories[index];
          return _buildCategoryItem(category);
        }, childCount: state.categories.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }

  // ================= DEVICE TYPE SECTION =================

  Widget _buildDeviceTypeSection(ServiceCategoryState state) {
    if (state.deviceTypes.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.devices_other_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Text(
                  'customer.home_tab.service_category.device_type'.tr(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'customer.home_tab.service_category.items_found'.tr(
                    args: [state.deviceTypes.length.toString()],
                  ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.deviceTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) {
                final device = state.deviceTypes[index];
                return _buildDeviceItem(device);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= DEVICE ITEM =================

  Widget _buildDeviceItem(DeviceTypeModel device) {
    return InkWell(
      key: Key('home_device_${device.id}'),
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        debugPrint('Device ID: ${device.id}');
        debugPrint('Device Name: ${device.name}');
        debugPrint('Category ID: ${device.categoryId}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _buildDeviceIcon(device),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                device.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
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

    return _buildNetworkIcon(url, color: AppColors.primary, size: 40);
  }

  // ================= CATEGORY ITEM =================

  Widget _buildCategoryItem(ServiceCategoryModel category) {
    final iconColor = _getCategoryColor();

    return InkWell(
      key: Key('category_${category.id}'),
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (widget.onCategoryTap != null) {
          widget.onCategoryTap!(category);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceTypePage(
              categoryId: category.id,
              categoryName: category.name,
              onDeviceTap: (device) {
                debugPrint('Category ID: ${category.id}');
                debugPrint('Category Name: ${category.name}');
                debugPrint('Device ID: ${device.id}');
                debugPrint('Device Name: ${device.name}');
              },
            ),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryBackground(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCategoryIcon(category, iconColor),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CATEGORY ICON =================

  Widget _buildCategoryIcon(ServiceCategoryModel category, Color iconColor) {
    final url = category.iconUrl?.trim() ?? '';

    return Center(child: _buildNetworkIcon(url, color: iconColor, size: 40));
  }

  // ================= NETWORK ICON =================

  Widget _buildNetworkIcon(
    String url, {
    Color color = AppColors.primary,
    double size = 40,
  }) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      return _buildFallbackIcon(_getFallbackIcon(), color: color, size: size);
    }

    final uri = Uri.tryParse(trimmedUrl);
    final path = uri?.path.toLowerCase() ?? '';
    final isSvg = path.endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        trimmedUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) {
          return _buildFallbackIcon(
            _getFallbackIcon(),
            color: color,
            size: size,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Lỗi tải SVG icon: $trimmedUrl');
          debugPrint('Chi tiết: $error');

          return _buildFallbackIcon(
            _getFallbackIcon(),
            color: color,
            size: size,
          );
        },
      );
    }

    // Các định dạng ảnh thông thường như PNG/JPG/JPEG/WebP.
    return Image.network(
      trimmedUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Lỗi tải ảnh icon: $trimmedUrl');
        debugPrint('Chi tiết: $error');

        return _buildFallbackIcon(_getFallbackIcon(), color: color, size: size);
      },
    );
  }

  // ================= FALLBACK ICON =================

  IconData _getFallbackIcon() {
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
      Icons.air_rounded,
      Icons.plumbing_rounded,
      Icons.build_circle_outlined,
    ];

    return icons[Random().nextInt(icons.length)];
  }

  Widget _buildFallbackIcon(
    IconData icon, {
    Color color = AppColors.primary,
    double size = 40,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(icon, color: color, size: size),
    );
  }

  // ================= CATEGORY STYLE =================

  Color _getCategoryColor() {
    return AppColors.primary;
  }

  Color _getCategoryBackground() {
    return const Color(0xFFE8EDFF);
  }
}
