import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_categories_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_category_tree_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/category_controller.dart';
import 'package:marketplace/presentation/controllers/marketplace/home_controller.dart';
import '../../../../presentation/controllers/marketplace/main_navigation_controller.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/seller_repository.dart';
import '../../../../data/repositories/marketplace_order_repository.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/usecases/marketplace/auth/delete_account_use_case.dart';
import '../../../../data/services/api_service.dart';
import '../../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';
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
    // Permanent: signing in runs `Get.offAllNamed(MAIN)` from a stack whose
    // root is already MAIN, and GetX deletes the old route's dependencies by
    // key after the new route's binding has run — a route-scoped shell
    // controller is left orphaned, its badge frozen. Permanent is exempt.
    if (!Get.isRegistered<MainNavigationController>()) {
      Get.put(MainNavigationController(), permanent: true);
    }

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
    Get.lazyPut(() => GetProductsPageUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetSellersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetOrdersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()), fenix: true);
    // The Categories tab needs `children`, which only the tree endpoint returns.
    Get.lazyPut(() => GetCategoryTreeUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetBannersUseCase(Get.find()), fenix: true);

    // Unread badge on the home header — count only, never the full list.
    Get.lazyPut(() => GetUnreadCountUseCase(Get.find()), fenix: true);

    // The account tab counts saved addresses, so the repository has to exist
    // before the address book itself is opened.
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut(() => AddressRepository(Get.find<ApiService>()), fenix: true);
    }
    Get.lazyPut(() => GetAddressesUseCase(Get.find()), fenix: true);

    // Account deletion lives on the account tab, so its repository cannot wait
    // for the auth binding — that one is only built on the sign-in route.
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(Get.find<ApiService>()), fenix: true);
    }
    Get.lazyPut(() => DeleteAccountUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationBadgeController(), fenix: true);

    // The local cart layer (repository, use cases, CartController) is
    // registered permanently in InitialBinding — app state, not route state.
    Get.lazyPut(() => CheckoutUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetPaymentMethodsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetShippingFeeUseCase(Get.find()), fenix: true);

    // Controllers
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
    Get.lazyPut(() => SellersController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
