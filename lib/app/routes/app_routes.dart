// ignore_for_file: constant_identifier_names
/// All named routes for the Marketplace app.
abstract class Routes {
  Routes._();

  // ── Auth / Onboarding ─────────────────────────────────────
  static const MARKETPLACE = '/marketplace';
  static const MARKETPLACE_MAIN = '/marketplace/main';
  static const MARKETPLACE_ONBOARDING = '/marketplace/onboarding';
  static const MARKETPLACE_LOGIN = '/marketplace/login';
  static const MARKETPLACE_VERIFY = '/marketplace/verify';
  static const MARKETPLACE_COMPLETE_DETAILS = '/marketplace/complete-details';
  static const MARKETPLACE_JOIN = '/marketplace/join';

  // ── Product ───────────────────────────────────────────────
  static const MARKETPLACE_PRODUCT = '/marketplace/product';
  // Products list — handles both "See All" and category-filtered views
  static const String MARKETPLACE_PRODUCTS_LIST = '/marketplace/products-list';
  static const String MARKETPLACE_SEARCH = '/marketplace/search';
  static const String MARKETPLACE_PRODUCT_GALLERY =
      '/marketplace/product-gallery';

  // ── Seller ────────────────────────────────────────────────
  static const MARKETPLACE_SELLER = '/marketplace/seller';

  // ── Cart / Checkout ───────────────────────────────────────
  static const MARKETPLACE_CHECKOUT = '/marketplace/checkout';
  static const MARKETPLACE_ORDER_CONFIRMED = '/marketplace/order-confirmed';
  static const MARKETPLACE_PAYMENT_WEBVIEW = '/marketplace/payment-webview';
  static const MARKETPLACE_ORDER_CANCELLED = '/marketplace/order-cancelled';
  static const MARKETPLACE_EDFALI_CONFIRM = '/marketplace/edfali-confirm';

  // ── Orders ────────────────────────────────────────────────
  static const MARKETPLACE_ORDERS = '/marketplace/orders';
  static const MARKETPLACE_ORDER_DETAILS = '/marketplace/order-details';

  // ── Refunds ───────────────────────────────────────────────
  static const MARKETPLACE_REFUND_REQUEST = '/marketplace/refund-request';
  static const MARKETPLACE_TRANSACTION_PROOF =
      '/marketplace/transaction-proof';

  // ── Notifications ─────────────────────────────────────────
  static const MARKETPLACE_NOTIFICATIONS = '/marketplace/notifications';

  // ── Account ───────────────────────────────────────────────
  static const MARKETPLACE_ADDRESSES = '/marketplace/addresses';
  static const MARKETPLACE_ADD_ADDRESS = '/marketplace/add-address';
  static const MARKETPLACE_HELP = '/marketplace/help';
  static const MARKETPLACE_LEGAL = '/marketplace/legal';
}
