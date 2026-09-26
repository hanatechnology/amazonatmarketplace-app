import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/marketplace/marketplace_bottom_nav.dart';
import '../../../core/theme/marketplace_palette.dart';
import '../../controllers/marketplace/cart_controller.dart';
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

  /// The cart lives for the whole app, not for this route — the badge, the cart
  /// tab and every "add to cart" button read this one instance.
  final cart = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Landing tab is per entry into the shell (a cancelled payment comes back
    // to the cart), while the controller itself is permanent.
    controller.applyRouteArguments(Get.arguments);
  }

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
        // The tab bar floats over the content as a pill, so the body has to
        // run underneath it.
        extendBody: true,
        backgroundColor: context.palette.background,
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
              cartCount: cart.cartCount,
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
