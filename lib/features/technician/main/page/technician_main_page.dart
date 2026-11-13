import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/technician/account/main/page/technician_account_page.dart';
import 'package:fixhome/features/technician/home/main/page/technician_home_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MainTechnicianPage extends StatefulWidget {
  const MainTechnicianPage({super.key});

  @override
  State<MainTechnicianPage> createState() => _MainTechnicianView();
}

class _MainTechnicianView extends State<MainTechnicianPage> {
  int _currentIndex = 0;

  // Danh sách các trang tương ứng với các tab
  final List<Widget> _pages = [
    const TechnicianHomePage(), // Tab 0: Trang chủ
    const Center(child: Text('Hoạt động Tech')), // Tab 1: Hoạt động
    const Center(child: Text('Thông báo Tech')), // Tab 2: Thông báo
    const TechnicianAccountPage(), // Tab 3: Tài khoản
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false, // Không cần padding phía dưới của SafeArea ở đây
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo bên trái
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo_fixhome.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.close,
                            color: Colors.amber,
                            size: 20,
                          );
                        },
                      ),
                    ),

                    // Tiêu đề ở giữa
                    const Text(
                      'FixHome',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Nút icon tài khoản bên phải (Chuyển nhanh sang tab Tài khoản)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentIndex =
                                3; // Chuyển sang tab Tài khoản (Tab 3)
                          });
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),

      // 3. THANH ĐIỀU HƯỚNG DƯỚI CÙNG (BOTTOM NAVIGATION BAR)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Cập nhật tab khi người dùng bấm
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: 'technician.main_nav.home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              label: 'technician.main_nav.activity'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_none_outlined),
              label: 'technician.main_nav.notification'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'technician.main_nav.profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
