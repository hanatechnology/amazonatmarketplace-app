import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_categories_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/add_to_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/remove_from_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/update_local_cart_quantity_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/toggle_local_cart_selection_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/set_local_cart_select_all_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/clear_local_cart_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/cart_controller.dart';
import 'package:marketplace/presentation/controllers/marketplace/category_controller.dart';
import 'package:marketplace/presentation/controllers/marketplace/home_controller.dart';
import 'package:marketplace/presentation/pages/marketplace/home/bindings/home_binding.dart';
import '../../../../presentation/controllers/marketplace/main_navigation_controller.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/seller_repository.dart';
import '../../../../data/repositories/marketplace_order_repository.dart';
import '../../../../data/services/api_service.dart';
import '../../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../../domain/usecases/marketplace/seller/get_sellers_use_case.dart';
import '../../../../domain/usecases/marketplace/order/get_orders_use_case.dart';
import '../../../../data/repositories/checkout_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../domain/usecases/marketplace/notification/get_unread_count_use_case.dart';
import '../../../controllers/marketplace/notification_badge_controller.dart';
import '../../../../data/repositories/banner_repository.dart';
import '../../../../domain/usecases/marketplace/banner/get_banners_use_case.dart';
import '../../../controllers/marketplace/profile_controller.dart';
import '../../../controllers/marketplace/sellers_controller.dart';
import '../../../../domain/usecases/marketplace/cart/checkout_use_case.dart';
import '../../../../domain/usecases/marketplace/cart/get_payment_methods_use_case.dart';
import '../../../../domain/usecases/marketplace/cart/get_shipping_fee_use_case.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavigationController());

    // Repositories — fenix: true so they persist across tab switches
    Get.lazyPut(() => ProductRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => BannerRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => SellerRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => MarketplaceOrderRepository(Get.find<ApiService>()),
        fenix: true);
    Get.lazyPut(() => CheckoutRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => NotificationRepository(Get.find<ApiService>()),
        fenix: true);

    // Product / seller / order use cases
    Get.lazyPut(() => GetProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetSellersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetOrdersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetBannersUseCase(Get.find()), fenix: true);

    // Unread badge on the home header — count only, never the full list.
    Get.lazyPut(() => GetUnreadCountUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationBadgeController(), fenix: true);

    // Local cart use cases (LocalCartRepository is permanent from InitialBinding)
    Get.lazyPut(() => GetLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddToLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RemoveFromLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateLocalCartQuantityUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ToggleLocalCartSelectionUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SetLocalCartSelectAllUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ClearLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CheckoutUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetPaymentMethodsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetShippingFeeUseCase(Get.find()), fenix: true);

    // Controllers
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => SellersController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
