import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt cartItemCount = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Called by CartController when cart changes
  void updateCartCount(int count) {
    cartItemCount.value = count;
  }
}
