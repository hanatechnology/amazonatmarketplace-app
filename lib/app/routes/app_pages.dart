import 'package:get/get.dart';
import 'app_routes.dart';

// Pages
import '../../presentation/pages/marketplace/splash/marketplace_splash_page.dart';
import '../../presentation/pages/marketplace/onboarding/onboarding_page.dart';
import '../../presentation/pages/marketplace/auth/join_now_page.dart';
import '../../presentation/pages/marketplace/auth/marketplace_login_page.dart';
import '../../presentation/pages/marketplace/auth/verify_phone_page.dart';
import '../../presentation/pages/marketplace/auth/verification_page.dart';
import '../../presentation/pages/marketplace/auth/complete_details_page.dart';
import '../../presentation/pages/marketplace/main_navigation_page.dart';
import '../../presentation/pages/marketplace/product/product_details_page.dart';
import '../../presentation/pages/marketplace/category/products_list_page.dart';
import '../../presentation/pages/marketplace/category/bindings/products_list_binding.dart';
import '../../presentation/pages/marketplace/product/reviews_page.dart';
import '../../presentation/pages/marketplace/product/product_sellers_page.dart';
import '../../presentation/pages/marketplace/seller/seller_profile_page.dart';
import '../../presentation/pages/marketplace/cart/checkout_page.dart';
import '../../presentation/pages/marketplace/cart/add_card_page.dart';
import '../../presentation/pages/marketplace/cart/order_confirmed_page.dart';
import '../../presentation/pages/marketplace/cart/payment_webview_page.dart';
import '../../presentation/pages/marketplace/cart/order_cancelled_page.dart';
import '../../presentation/pages/marketplace/orders/my_orders_page.dart';
import '../../presentation/pages/marketplace/orders/order_details_page.dart';
import '../../presentation/pages/marketplace/orders/tracking_page.dart';
import '../../presentation/pages/marketplace/orders/return_page.dart';
import '../../presentation/pages/marketplace/orders/pickup_page.dart';
import '../../presentation/pages/marketplace/account/address_book_page.dart';
import '../../presentation/pages/marketplace/account/add_edit_address_page.dart';
import '../../presentation/pages/marketplace/account/delivery_areas_page.dart';
import '../../presentation/pages/marketplace/account/help_center_page.dart';

// Bindings
import '../../presentation/pages/marketplace/auth/bindings/marketplace_auth_binding.dart';
import '../../presentation/pages/marketplace/home/bindings/home_binding.dart';
import '../../presentation/pages/marketplace/cart/bindings/cart_binding.dart';
import '../../presentation/pages/marketplace/cart/bindings/checkout_binding.dart';
import '../../presentation/pages/marketplace/cart/bindings/payment_webview_binding.dart';
import '../../presentation/pages/marketplace/orders/bindings/orders_binding.dart';
import '../../presentation/pages/marketplace/orders/bindings/order_details_binding.dart';
import '../../presentation/pages/marketplace/refunds/refund_request_page.dart';
import '../../presentation/pages/marketplace/refunds/bindings/refund_request_binding.dart';
import '../../presentation/pages/marketplace/cart/edfali_confirm_page.dart';
import '../../presentation/pages/marketplace/cart/bindings/edfali_confirm_binding.dart';
import '../../presentation/pages/marketplace/seller/bindings/seller_binding.dart';
import '../../presentation/pages/marketplace/account/bindings/account_binding.dart';
import '../../presentation/pages/marketplace/account/bindings/addresses_binding.dart';
import '../../presentation/pages/marketplace/account/bindings/add_edit_address_binding.dart';
import '../../presentation/pages/marketplace/product/bindings/product_binding.dart';
import '../../presentation/pages/marketplace/bindings/main_navigation_binding.dart';
import '../../presentation/pages/marketplace/notifications/notifications_page.dart';
import '../../presentation/pages/marketplace/notifications/bindings/notifications_binding.dart';

abstract class AppPages {
  static final routes = [
    GetPage(
      name: Routes.MARKETPLACE,
      page: () => const MarketplaceSplashPage(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ONBOARDING,
      page: () => const OnboardingPage(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_JOIN,
      page: () => const JoinNowPage(),
      binding: MarketplaceAuthBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_LOGIN,
      page: () => const MarketplaceLoginPage(),
      binding: MarketplaceAuthBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_VERIFY,
      page: () => const VerifyPhonePage(),
      binding: MarketplaceAuthBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_VERIFICATION,
      page: () => const VerificationPage(),
      binding: MarketplaceAuthBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_COMPLETE_DETAILS,
      page: () => const CompleteDetailsPage(),
      binding: MarketplaceAuthBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_MAIN,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_PRODUCTS_LIST,
      page: () => const ProductsListPage(),
      binding: ProductsListBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.MARKETPLACE_PRODUCT,
      page: () => const ProductDetailsPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_REVIEWS,
      page: () => const ReviewsPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_PRODUCT_SELLERS,
      page: () => const ProductSellersPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_SELLER,
      page: () => const SellerProfilePage(),
      binding: SellerBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_CHECKOUT,
      page: () => const CheckoutPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ADD_CARD,
      page: () => const AddCardPage(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ORDER_CONFIRMED,
      page: () => const OrderConfirmedPage(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_PAYMENT_WEBVIEW,
      page: () => const PaymentWebViewPage(),
      binding: PaymentWebViewBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ORDER_CANCELLED,
      page: () => const OrderCancelledPage(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_EDFALI_CONFIRM,
      page: () => const EdfaliConfirmPage(),
      binding: EdfaliConfirmBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ORDERS,
      page: () => const MyOrdersPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ORDER_DETAILS,
      page: () => const OrderDetailsPage(),
      binding: OrderDetailsBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_TRACKING,
      page: () => const TrackingPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_RETURN,
      page: () => const ReturnPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_PICKUP,
      page: () => const PickupPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_REFUND_REQUEST,
      page: () => const RefundRequestPage(),
      binding: RefundRequestBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_NOTIFICATIONS,
      page: () => const NotificationsPage(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.MARKETPLACE_ADDRESSES,
      page: () => const AddressBookPage(),
      binding: AddressesBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_ADD_ADDRESS,
      page: () => const AddEditAddressPage(),
      binding: AddEditAddressBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.MARKETPLACE_DELIVERY_AREAS,
      page: () => const DeliveryAreasPage(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: Routes.MARKETPLACE_HELP,
      page: () => const HelpCenterPage(),
      binding: AccountBinding(),
    ),
  ];
}
