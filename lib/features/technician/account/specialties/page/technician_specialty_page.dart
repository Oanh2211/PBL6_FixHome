import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/technician/account/specialties/api/device_type_api.dart';
import 'package:fixhome/features/technician/account/specialties/page/register_specialty_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/common/network/dio_client.dart';

// API danh mục chuyên môn
import 'package:fixhome/features/customer/home/main/api/service_category_api.dart';
import 'package:fixhome/features/customer/home/main/model/service_category_model.dart';

// API thiết bị

// Các trang nghiệp vụ
import 'package:fixhome/features/technician/account/specialties/page/specialty_card.dart';
import 'package:fixhome/features/technician/account/specialties/page/specialty_detail_page.dart';

// Cubit nghiệp vụ
import '../api/technician_specialty_api.dart';
import '../cubit/technician_specialty_cubit.dart';
import '../cubit/technician_specialty_state.dart';

// ================= OPTION MODEL =================

class SpecialtyOption {
  final int id;
  final String name;

  const SpecialtyOption({required this.id, required this.name});
}

// ================= SPECIALTY PAGE =================

class TechnicianSpecialtyPage extends StatelessWidget {
  const TechnicianSpecialtyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianSpecialtyCubit(TechnicianSpecialtyApi())..loadSpecialties(),
      child: const _TechnicianSpecialtyView(),
    );
  }
}

// ================= SPECIALTY VIEW =================

class _TechnicianSpecialtyView extends StatefulWidget {
  const _TechnicianSpecialtyView();

  @override
  State<_TechnicianSpecialtyView> createState() =>
      _TechnicianSpecialtyViewState();
}

class _TechnicianSpecialtyViewState extends State<_TechnicianSpecialtyView> {
  final ServiceCategoryApi _categoryApi = ServiceCategoryApi(
    dio: DioClient.instance,
  );

  final DeviceTypeApi _deviceApi = DeviceTypeApi(dio: DioClient.instance);

  List<SpecialtyOption> categories = [];
  List<SpecialtyOption> deviceTypes = [];

  bool isCatalogLoading = true;
  String? catalogError;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  // ================= LOAD CATEGORY + DEVICE =================

  Future<void> _loadCatalog() async {
    setState(() {
      isCatalogLoading = true;
      catalogError = null;
    });

    try {
      // 1. GET /service-categories
      final List<ServiceCategoryModel> categoryModels = await _categoryApi
          .getCategories();

      final categoryOptions = categoryModels.map((category) {
        return SpecialtyOption(id: category.id, name: category.name);
      }).toList();

      // 2. GET /service-categories/{categoryId}/device-types
      // Gọi API thiết bị theo từng category.
      final deviceResults = await Future.wait(
        categoryModels.map(
          (category) => _deviceApi.getDeviceTypes(categoryId: category.id),
        ),
      );

      final allDevices = <SpecialtyOption>[];

      for (final devices in deviceResults) {
        for (final device in devices) {
          allDevices.add(SpecialtyOption(id: device.id, name: device.name));
        }
      }

      if (!mounted) return;

      setState(() {
        categories = categoryOptions;
        deviceTypes = allDevices;
        isCatalogLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCatalogLoading = false;
        catalogError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ================= GET CATEGORY NAME =================

  String categoryName(int id) {
    for (final category in categories) {
      if (category.id == id) {
        return category.name;
      }
    }

    return '${'technician.account.specialty_page.category'.tr()} #$id';
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'technician.account.specialty_page.list_title'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isCatalogLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (catalogError != null) {
      return _ErrorView(message: catalogError!, onRetry: _loadCatalog);
    }

    return BlocBuilder<TechnicianSpecialtyCubit, TechnicianSpecialtyState>(
      builder: (context, state) {
        if (state.isLoading && state.specialties.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.errorMessage != null && state.specialties.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () {
              context.read<TechnicianSpecialtyCubit>().loadSpecialties();
            },
          );
        }

        final approved = state.specialties
            .where((e) => e.status.toLowerCase() == 'approved')
            .toList();

        final pending = state.specialties
            .where((e) => e.status.toLowerCase() != 'approved')
            .toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await _loadCatalog();

            if (!context.mounted) return;

            await context.read<TechnicianSpecialtyCubit>().loadSpecialties();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // DANH SÁCH ĐÃ ĐĂNG KÝ
              _sectionHeader(
                'technician.account.specialty_page.registered'.tr(),
                approved.length,
              ),

              const SizedBox(height: 12),

              if (approved.isEmpty)
                _emptySection()
              else
                ...approved.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SpecialtyCard(
                      specialty: item,
                      categoryName: categoryName(item.categoryId),
                      onTap: () => _openDetail(context, item.id),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // ĐĂNG KÝ MỚI
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _openRegister(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'technician.account.specialty_page.register_new'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // DANH SÁCH CHỜ DUYỆT
              _sectionHeader(
                'technician.account.specialty_page.waiting'.tr(),
                pending.length,
              ),

              const SizedBox(height: 12),

              if (pending.isEmpty)
                _emptySection()
              else
                ...pending.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SpecialtyCard(
                      specialty: item,
                      categoryName: categoryName(item.categoryId),
                      onTap: () => _openDetail(context, item.id),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ================= SECTION HEADER =================

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count ${'technician.account.specialty_page.items'.tr()}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= EMPTY =================

  Widget _emptySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          'technician.account.specialty_page.empty'.tr(),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  // ================= OPEN DETAIL =================

  void _openDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialtyDetailPage(
          id: id,
          categories: categories,
          deviceTypes: deviceTypes,
        ),
      ),
    );
  }

  // ================= OPEN REGISTER =================

  Future<void> _openRegister(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RegisterSpecialtyPage()),
    );

    if (result == true && mounted) {
      context.read<TechnicianSpecialtyCubit>().loadSpecialties();
    }
  }
}

// ================= ERROR VIEW =================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 45, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('technician.account.specialty_page.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
