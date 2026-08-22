/// Centralized translation key constants.
/// NEVER use raw strings for translation keys — always reference this class.
/// Usage: LocaleKeys.login_title.tr
abstract class LocaleKeys {
  LocaleKeys._();

  // ── General ─────────────────────────────────────────────
  static const String appName = 'app_name';
  static const String ok = 'ok';
  static const String cancel = 'cancel';
  static const String retry = 'retry';
  static const String save = 'save';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String search = 'search';
  static const String seeAll = 'see_all';
  static const String continueText = 'continue_text';
  static const String loading = 'loading';
  static const String noData = 'no_data';
  static const String error = 'error';
  static const String success = 'success';

  // ── Auth / Login ────────────────────────────────────────
  static const String loginTitle = 'login_title';
  static const String loginSubtitle = 'login_subtitle';
  static const String phoneNumber = 'phone_number';
  static const String phoneHint = 'phone_hint';
  static const String continueAsGuest = 'continue_as_guest';
  static const String sendOtp = 'send_otp';
  static const String orContinueWith = 'or_continue_with';
  static const String continueWithGoogle = 'continue_with_google';
  static const String continueWithApple = 'continue_with_apple';
  static const String termsAgreement = 'terms_agreement';
  static const String termsOfService = 'terms_of_service';
  static const String privacyPolicy = 'privacy_policy';
  static const String and = 'and';

  // ── Registration (revealed when the phone has no account) ─
  static const String noAccountFound   = 'no_account_found';
  static const String signUpPrompt     = 'sign_up_prompt';
  static const String signUp           = 'sign_up';
  static const String firstNameLabel   = 'first_name_label';
  static const String firstNameHint    = 'first_name_hint';
  static const String lastNameLabel    = 'last_name_label';
  static const String lastNameHint     = 'last_name_hint';
  static const String lastNameOptional = 'last_name_optional';

  // ── OTP / Verification ─────────────────────────────────
  static const String verifyPhoneTitle = 'verify_phone_title';
  static const String verifyPhoneSubtitle = 'verify_phone_subtitle';
  static const String otpSentTo = 'otp_sent_to';
  static const String enterOtp = 'enter_otp';
  static const String verifyOtp = 'verify_otp';
  static const String resendOtp = 'resend_otp';
  static const String resendIn = 'resend_in';
  static const String didntReceiveCode = 'didnt_receive_code';
  static const String editPhone = 'edit_phone';
  static const String otpRateLimited = 'otp_rate_limited';
  static const String otpTooManyAttempts = 'otp_too_many_attempts';

  // ── Complete Details ────────────────────────────────────
  static const String completeDetailsTitle = 'complete_details_title';
  static const String completeDetailsSubtitle = 'complete_details_subtitle';
  static const String fullName = 'full_name';
  static const String fullNameHint = 'full_name_hint';
  static const String email = 'email';
  static const String emailHint = 'email_hint';
  static const String createAccount = 'create_account';

  // ── Join Now ────────────────────────────────────────────
  static const String joinNowTitle = 'join_now_title';
  static const String joinNowSubtitle = 'join_now_subtitle';
  static const String getStarted = 'get_started';
  static const String alreadyHaveAccount = 'already_have_account';
  static const String login = 'login';

  // ── Home Screen ─────────────────────────────────────────
  static const String home = 'home';
  static const String category = 'category';
  static const String popularProducts = 'popular_products';
  static const String newCollection = 'new_collection';
  static const String discountBanner = 'discount_banner';
  static const String shopNow = 'shop_now';
  static const String searchProducts = 'search_products';
  static const String viewAll = 'view_all';

  // ── Product ─────────────────────────────────────────────
  static const String productDetails = 'product_details';
  static const String details = 'details';
  static const String description = 'description';
  static const String reviews = 'reviews';
  static const String reviewsAndRating = 'reviews_and_rating';
  static const String addToCart = 'add_to_cart';
  static const String seller = 'seller';
  static const String allSellers = 'all_sellers';
  static const String learnMore = 'learn_more';

  // ── Category ────────────────────────────────────────────
  static const String categories = 'categories';
  static const String allCategories = 'all_categories';

  // ── Cart ────────────────────────────────────────────────
  static const String cart = 'cart';
  static const String myCart = 'my_cart';
  static const String items = 'items';
  static const String selectAll = 'select_all';
  static const String subtotal = 'subtotal';
  static const String discount = 'discount';
  static const String totalCost = 'total_cost';
  static const String checkout = 'checkout';
  static const String removeItem = 'remove_item';
  static const String emptyCart = 'empty_cart';
  static const String emptyCartMessage = 'empty_cart_message';

  // ── Checkout ────────────────────────────────────────────
  static const String checkoutTitle = 'checkout_title';
  static const String deliveryAddress = 'delivery_address';
  static const String paymentMethod = 'payment_method';
  static const String addCard = 'add_card';
  static const String placeOrder = 'place_order';
  static const String orderSummary = 'order_summary';
  static const String addNewAddress = 'add_new_address';
  static const String completePayment = 'complete_payment';
  static const String selectAddress = 'select_address';
  static const String selectPayment = 'select_payment';
  static const String paymentCancelled = 'payment_cancelled';
  static const String paymentCancelledMessage = 'payment_cancelled_message';
  static const String orderConfirmed = 'order_confirmed';
  static const String orderConfirmedMessage = 'order_confirmed_message';
  static const String orderOnItsWay = 'order_on_its_way';
  static const String trackMyOrder = 'track_my_order';
  static const String continueShopping = 'continue_shopping';
  static const String showItems = 'show_items';
  static const String hideItems = 'hide_items';
  static const String genericError = 'generic_error';

  // ── Orders ──────────────────────────────────────────────
  static const String myOrders = 'my_orders';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String orderDetails = 'order_details';
  static const String trackOrder = 'track_order';
  static const String returnOrder = 'return_order';
  static const String pickup = 'pickup';
  static const String noOrders = 'no_orders';
  static const String noOrdersDesc = 'no_orders_desc';
  static const String orderNumber = 'order_number';
  static const String viewDetails = 'view_details';
  static const String orderItems = 'order_items';
  static const String shippingFee = 'shipping_fee';
  static const String totalAmount = 'total_amount';
  static const String vendor = 'vendor';
  static const String shippingAddress = 'shipping_address';
  static const String cancelOrder = 'cancel_order';
  static const String cancelOrderConfirm = 'cancel_order_confirm';
  static const String cancelOrderReasonHint = 'cancel_order_reason_hint';
  static const String orderCancelled = 'order_cancelled';
  static const String orderCancelledMessage = 'order_cancelled_message';
  static const String orderPlacedOn = 'order_placed_on';
  static const String cancellationReason = 'cancellation_reason';
  static const String statusPending = 'status_pending';
  static const String statusPaid = 'status_paid';
  static const String statusCod = 'status_cod';
  static const String statusProcessing = 'status_processing';
  static const String statusShipped = 'status_shipped';
  static const String statusReadyForPickup = 'status_ready_for_pickup';
  static const String statusDelivered = 'status_delivered';
  static const String statusCancelled = 'status_cancelled';
  static const String statusRefunded = 'status_refunded';
  static const String statusUnknown = 'status_unknown';

  // ── Seller ──────────────────────────────────────────────
  static const String sellers = 'sellers';
  static const String viewStore = 'view_store';
  static const String storeProducts = 'store_products';
  static const String noStoreProducts = 'no_store_products';
  static const String searchSellers = 'search_sellers';
  static const String noSellers = 'no_sellers';
  static const String noSellersMessage = 'no_sellers_message';
  static const String verified = 'verified';
  static const String follow = 'follow';
  static const String following = 'following';
  static const String followers = 'followers';
  static const String closed = 'closed';
  static const String open = 'open';

  // ── Account / Profile ───────────────────────────────────
  static const String myAccount = 'my_account';
  static const String profile = 'profile';
  static const String addressBook      = 'address_book';
  static const String pickAddressTitle = 'pick_address_title';
  static const String deliveryAreas = 'delivery_areas';
  static const String helpCenter = 'help_center';
  static const String language = 'language';
  static const String arabic = 'arabic';
  static const String english = 'english';
  static const String logout = 'logout';
  static const String logoutConfirm = 'logout_confirm';

  // ── Refunds ─────────────────────────────────────────────
  static const String requestRefund = 'request_refund';
  static const String refundType = 'refund_type';
  static const String refundTypeFull = 'refund_type_full';
  static const String refundTypePartial = 'refund_type_partial';
  static const String refundReason = 'refund_reason';
  static const String refundReasonHint = 'refund_reason_hint';
  static const String refundExplanation = 'refund_explanation';
  static const String selectItems = 'select_items';
  static const String selectAtLeastOneItem = 'select_at_least_one_item';
  static const String payoutMethod = 'payout_method';
  static const String submitRefund = 'submit_refund';
  static const String refundRequested = 'refund_requested';
  static const String refundRequestedMessage = 'refund_requested_message';
  static const String fieldRequired = 'field_required';
  static const String fieldInvalid = 'field_invalid';
  static const String refundTracker = 'refund_tracker';
  static const String refundAmount = 'refund_amount';
  static const String refundRequestedAt = 'refund_requested_at';
  static const String refundCompletedAt = 'refund_completed_at';
  static const String transportCost = 'transport_cost';
  static const String declineReason = 'decline_reason';
  static const String payouts = 'payouts';
  static const String pickupSchedule = 'pickup_schedule';
  static const String refundStatusPending = 'refund_status_pending';
  static const String refundStatusUnderProcessing = 'refund_status_under_processing';
  static const String refundStatusUnderReview = 'refund_status_under_review';
  static const String refundStatusAwaitingPayout = 'refund_status_awaiting_payout';
  static const String refundStatusRejected = 'refund_status_rejected';
  static const String refundStatusRefunded = 'refund_status_refunded';
  static const String payoutStatusPending = 'payout_status_pending';
  static const String payoutStatusProcessing = 'payout_status_processing';
  static const String payoutStatusApproved = 'payout_status_approved';
  static const String payoutStatusCompleted = 'payout_status_completed';
  static const String payoutStatusDeclined = 'payout_status_declined';

  // ── Edfali payment ──────────────────────────────────────
  static const String edfaliWallet = 'edfali_wallet';
  static const String edfaliWalletHint = 'edfali_wallet_hint';
  static const String edfaliConfirmTitle = 'edfali_confirm_title';
  static const String edfaliCodeSentTo = 'edfali_code_sent_to';
  static const String edfaliAttemptsRemaining = 'edfali_attempts_remaining';
  static const String edfaliOtpInvalid = 'edfali_otp_invalid';
  static const String edfaliAttemptsExceeded = 'edfali_attempts_exceeded';
  static const String edfaliSessionExpired = 'edfali_session_expired';
  static const String edfaliPaymentFailed = 'edfali_payment_failed';
  static const String paymentUnderReview = 'payment_under_review';
  static const String paymentUnderReviewMessage = 'payment_under_review_message';
  static const String confirmPayment = 'confirm_payment';
  static const String singleSellerCheckout = 'single_seller_checkout';

  // ── Bottom Nav ──────────────────────────────────────────
  static const String navHome = 'nav_home';
  static const String navCategory = 'nav_category';
  static const String navSeller = 'nav_seller';
  static const String navCart = 'nav_cart';
  static const String navAccount = 'nav_account';

  // ── Products List / Filter ────────────────────────────
  static const String allProducts = 'all_products';
  static const String productsFound = 'products_found';
  static const String filterTitle = 'filter_title';
  static const String clearAll = 'clear_all';
  static const String applyFilters = 'apply_filters';
  static const String sortBy = 'sort_by';
  static const String sortRelevance = 'sort_relevance';
  static const String sortPriceLowHigh = 'sort_price_low_high';
  static const String sortPriceHighLow = 'sort_price_high_low';
  static const String sortRating = 'sort_rating';
  static const String priceRange = 'price_range';
  static const String minRating = 'min_rating';
  static const String andAbove = 'and_above';
  static const String noProducts = 'no_products';
  static const String noProductsMessage = 'no_products_message';
  static const String allFilter = 'all_filter';

  // ── Product Details ───────────────────────────────────
  static const String quantity = 'quantity';
  static const String inStock = 'in_stock';
  static const String outOfStock = 'out_of_stock';
  static const String seeAllReviews = 'see_all_reviews';
  static const String viewAllSellers = 'view_all_sellers';
  static const String shareProduct = 'share_product';
  static const String addedToCart = 'added_to_cart';
  static const String showLess = 'show_less';
  static const String totalPrice = 'total_price';

  // ── Address Book ────────────────────────────────────────
  static const String addAddress           = 'add_address';
  static const String editAddress          = 'edit_address';
  static const String addressLabel         = 'address_label';
  static const String fullAddressField     = 'full_address_field';
  static const String recipientName        = 'recipient_name';
  static const String addressLine1         = 'address_line_1';
  static const String addressLine2         = 'address_line_2';
  static const String addressLine2Optional = 'address_line_2_optional';
  static const String cityField            = 'city_field';
  static const String stateField           = 'state_field';
  static const String countryField         = 'country_field';
  static const String postalCode           = 'postal_code';
  static const String postalCodeOptional   = 'postal_code_optional';
  static const String setAsDefault         = 'set_as_default';
  static const String saveAddress          = 'save_address';
  static const String deleteAddress        = 'delete_address';
  static const String deleteAddressConfirm = 'delete_address_confirm';
  static const String addressDeleted       = 'address_deleted';
  static const String defaultAddressSet    = 'default_address_set';
  static const String isNowDefault         = 'is_now_default';
  static const String noAddresses          = 'no_addresses';
  static const String noAddressesMessage   = 'no_addresses_message';
  static const String addFirstAddress      = 'add_first_address';
  static const String defaultBadge         = 'default_badge';
  static const String labelRequired        = 'label_required';
  static const String addressRequired      = 'address_required';
  static const String deleted              = 'deleted';

  // ── Notifications ───────────────────────────────────────
  static const String notifications              = 'notifications';
  static const String notificationsDescription   = 'notifications_description';
  static const String notificationsAll           = 'notifications_all';
  static const String notificationsUnread        = 'notifications_unread';
  static const String notificationsRead          = 'notifications_read';
  static const String markRead                   = 'mark_read';
  static const String markAllRead                = 'mark_all_read';
  static const String noNotifications            = 'no_notifications';
  static const String noNotificationsMessage     = 'no_notifications_message';
  static const String allNotificationsMarkedRead = 'all_notifications_marked_read';

  // ── Relative Time ───────────────────────────────────────
  static const String timeJustNow    = 'time_just_now';
  static const String timeMinutesAgo = 'time_minutes_ago';
  static const String timeHoursAgo   = 'time_hours_ago';
  static const String timeDaysAgo    = 'time_days_ago';
  static const String timeWeeksAgo   = 'time_weeks_ago';
  static const String timeMonthsAgo  = 'time_months_ago';
  static const String timeYearsAgo   = 'time_years_ago';

  // ── Validation ──────────────────────────────────────────
  static const String requiredField = 'required_field';
  static const String invalidPhone = 'invalid_phone';
  static const String invalidEmail = 'invalid_email';
  static const String invalidOtp = 'invalid_otp';
  static const String nameTooShort = 'name_too_short';
}
