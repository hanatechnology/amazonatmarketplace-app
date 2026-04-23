import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/marketplace/marketplace_bottom_nav.dart';
import '../../../core/theme/marketplace_colors.dart';
import '../../controllers/marketplace/main_navigation_controller.dart';

// Import tab root pages
import 'home/home_page.dart';
import 'category/category_page.dart';
import 'seller/sellers_list_page.dart';
import 'cart/cart_page.dart';
import 'account/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final controller = Get.find<MainNavigationController>();

  // One GlobalKey per tab for independent navigation stacks
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  final List<Widget Function()> _tabBuilders = [
    () => const HomePage(),
    () => const CategoryPage(),
    () => const SellersListPage(),
    () => const CartPage(),
    () => const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentNav =
            _navigatorKeys[controller.currentIndex.value].currentState;
        if (currentNav != null && currentNav.canPop()) {
          currentNav.pop();
        }
      },
      child: Scaffold(
        
        backgroundColor: MarketplaceColors.surface,
        body: Obx(() => IndexedStack(
              index: controller.currentIndex.value,
              children: List.generate(
                5,
                (i) => Navigator(
                  key: _navigatorKeys[i],
                  onGenerateRoute: (_) => MaterialPageRoute(
                    builder: (_) => _tabBuilders[i](),
                  ),
                ),
              ),
            )),
        bottomNavigationBar: Obx(() => MarketplaceBottomNav(
              currentIndex: controller.currentIndex.value,
              cartCount: controller.cartItemCount.value,
              onTap: (index) {
                if (controller.currentIndex.value == index) {
                  _navigatorKeys[index]
                      .currentState
                      ?.popUntil((route) => route.isFirst);
                }
                controller.changePage(index);
              },
            )),
      ),
    );
  }
}
