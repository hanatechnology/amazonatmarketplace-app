import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  /// Tab order, matching `_tabBuilders` in `MainNavigationPage`.
  static const int homeTab = 0;
  static const int categoriesTab = 1;
  static const int sellersTab = 2;
  static const int cartTab = 3;
  static const int accountTab = 4;

  final RxInt currentIndex = 0.obs;
  final RxInt cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Screens that hand the customer back to the shell can say where to land —
    // a cancelled payment belongs on the cart, not the home page.
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final tab = args['tab'] as int;
      if (tab >= homeTab && tab <= accountTab) currentIndex.value = tab;
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Called by CartController when cart changes
  void updateCartCount(int count) {
    cartItemCount.value = count;
  }
}
