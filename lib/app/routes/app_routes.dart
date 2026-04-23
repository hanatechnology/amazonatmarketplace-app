/// All named routes for the Marketplace app.
abstract class Routes {
  Routes._();

  // ── Auth / Onboarding ─────────────────────────────────────
  static const MARKETPLACE = '/marketplace';
  static const MARKETPLACE_MAIN = '/marketplace/main';
  static const MARKETPLACE_ONBOARDING = '/marketplace/onboarding';
  static const MARKETPLACE_LOGIN = '/marketplace/login';
  static const MARKETPLACE_VERIFY = '/marketplace/verify';
  static const MARKETPLACE_VERIFICATION = '/marketplace/verification';
  static const MARKETPLACE_COMPLETE_DETAILS = '/marketplace/complete-details';
  static const MARKETPLACE_JOIN = '/marketplace/join';

  // ── Product ───────────────────────────────────────────────
  static const MARKETPLACE_PRODUCT = '/marketplace/product';
  // Products list — handles both "See All" and category-filtered views
  static const String MARKETPLACE_PRODUCTS_LIST = '/marketplace/products-list';
  static const MARKETPLACE_REVIEWS = '/marketplace/reviews';
  static const MARKETPLACE_PRODUCT_SELLERS = '/marketplace/product-sellers';

  // ── Seller ────────────────────────────────────────────────
  static const MARKETPLACE_SELLER = '/marketplace/seller';

  // ── Cart / Checkout ───────────────────────────────────────
  static const MARKETPLACE_CHECKOUT = '/marketplace/checkout';
  static const MARKETPLACE_ADD_CARD = '/marketplace/add-card';
  static const MARKETPLACE_ORDER_CONFIRMED = '/marketplace/order-confirmed';
  static const MARKETPLACE_PAYMENT_WEBVIEW = '/marketplace/payment-webview';
  static const MARKETPLACE_ORDER_CANCELLED = '/marketplace/order-cancelled';

  // ── Orders ────────────────────────────────────────────────
  static const MARKETPLACE_ORDERS = '/marketplace/orders';
  static const MARKETPLACE_ORDER_DETAILS = '/marketplace/order-details';
  static const MARKETPLACE_TRACKING = '/marketplace/tracking';
  static const MARKETPLACE_RETURN = '/marketplace/return';
  static const MARKETPLACE_PICKUP = '/marketplace/pickup';

  // ── Account ───────────────────────────────────────────────
  static const MARKETPLACE_ADDRESSES = '/marketplace/addresses';
  static const MARKETPLACE_ADD_ADDRESS = '/marketplace/add-address';
  static const MARKETPLACE_DELIVERY_AREAS = '/marketplace/delivery-areas';
  static const MARKETPLACE_HELP = '/marketplace/help';
}
