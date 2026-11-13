import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/account/main/page/account_page.dart';
import 'package:fixhome/features/customer/home/main/page/service_category_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MainCustomerPage extends StatefulWidget {
  const MainCustomerPage({super.key});

  @override
  State<MainCustomerPage> createState() => _MainCustomerView();
}

class _MainCustomerView extends State<MainCustomerPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    ServiceCategoryPage(),
    const Center(child: Text('Hoạt động Customer')), // Tab 1: Hoạt động
    const Center(child: Text('Thông báo Customer')), // Tab 2: Thông báo
    AccountPage(
      onLoggedOut: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header cố định phía trên
          Container(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
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

                    // Nút icon tài khoản bên phải
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
                            _currentIndex = 3;
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

      // Thanh điều hướng dưới cùng
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
              _currentIndex = index;
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
              label: 'customer.main_nav.home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              label: 'customer.main_nav.activity'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_none_outlined),
              label: 'customer.main_nav.notification'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'customer.main_nav.profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
