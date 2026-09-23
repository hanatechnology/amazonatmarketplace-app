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

  // ── Guest mode / sign-in guards ─────────────────────────
  static const String signInRequiredTitle = 'sign_in_required_title';
  static const String signInRequiredCheckout = 'sign_in_required_checkout';
  static const String signInRequiredStoresTitle =
      'sign_in_required_stores_title';
  static const String signInRequiredStores = 'sign_in_required_stores';
  static const String guestAccountTitle = 'guest_account_title';
  static const String guestAccountSubtitle = 'guest_account_subtitle';
  static const String notNow = 'not_now';
  static const String sendOtp = 'send_otp';
  static const String orContinueWith = 'or_continue_with';
  static const String continueWithGoogle = 'continue_with_google';
  static const String continueWithApple = 'continue_with_apple';
  static const String termsAgreement = 'terms_agreement';
  static const String termsOfService = 'terms_of_service';
  static const String privacyPolicy = 'privacy_policy';
  static const String and = 'and';

  // ── Registration (revealed when the phone has no account) ─
  static const String noAccountFound = 'no_account_found';
  static const String signUpPrompt = 'sign_up_prompt';
  static const String signUp = 'sign_up';
  static const String firstNameLabel = 'first_name_label';
  static const String firstNameHint = 'first_name_hint';
  static const String lastNameLabel = 'last_name_label';
  static const String lastNameHint = 'last_name_hint';
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
  static const String knowMore = 'know_more';
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
  static const String addressBook = 'address_book';
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
  static const String back = 'back';
  static const String refundLabel = 'refund_label';
  static const String refundTracking = 'refund_tracking';
  static const String refundTrack = 'refund_track';
  static const String refundNext = 'refund_next';
  static const String refundNextPending = 'refund_next_pending';
  static const String refundNextUnderReview = 'refund_next_under_review';
  static const String refundNextUnderProcessing =
      'refund_next_under_processing';
  static const String refundNextAwaitingPayout = 'refund_next_awaiting_payout';
  static const String refundNetAmount = 'refund_net_amount';
  static const String refundEligibleLead = 'refund_eligible_lead';
  static const String refundEligibleTitle = 'refund_eligible_title';
  static const String refundEligibleCollect = 'refund_eligible_collect';
  static const String refundEligibleMoney = 'refund_eligible_money';
  static const String refundAmount = 'refund_amount';
  static const String refundRequestedAt = 'refund_requested_at';

  /// Short form for the refund strip, where the row already sits inside a
  /// refund-tinted block. The long form names the refund explicitly because it
  /// appears as a label beside unrelated order rows.
  static const String refundRequestedShort = 'refund_requested_short';
  static const String refundCompletedAt = 'refund_completed_at';
  static const String transportCost = 'transport_cost';
  static const String declineReason = 'decline_reason';
  static const String payouts = 'payouts';
  static const String pickupSchedule = 'pickup_schedule';
  static const String refundStatusPending = 'refund_status_pending';
  static const String refundStatusUnderProcessing =
      'refund_status_under_processing';
  static const String refundStatusUnderReview = 'refund_status_under_review';
  static const String refundStatusAwaitingPayout =
      'refund_status_awaiting_payout';
  static const String refundStatusRejected = 'refund_status_rejected';
  static const String refundStatusRefunded = 'refund_status_refunded';
  static const String payoutStatusPending = 'payout_status_pending';
  static const String payoutStatusProcessing = 'payout_status_processing';
  static const String payoutStatusApproved = 'payout_status_approved';
  static const String payoutStatusCompleted = 'payout_status_completed';
  static const String payoutStatusDeclined = 'payout_status_declined';

  // ── Transfer receipt ────────────────────────────────────
  static const String transactionProof = 'transaction_proof';
  static const String transactionProofHint = 'transaction_proof_hint';
  static const String saveToPhotos = 'save_to_photos';
  static const String proofSaved = 'proof_saved';
  static const String proofSaveFailed = 'proof_save_failed';
  static const String photosPermissionDenied = 'photos_permission_denied';

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
  static const String paymentUnderReviewMessage =
      'payment_under_review_message';
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
  static const String sortNameAsc = 'sort_name_asc';
  static const String searchResultsFor = 'search_results_for';
  static const String activeFilters = 'active_filters';
  static const String searchHint = 'search_hint';
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
  static const String addAddress = 'add_address';
  static const String addressLabel = 'address_label';
  static const String fullAddressField = 'full_address_field';
  static const String recipientName = 'recipient_name';
  static const String addressLine1 = 'address_line_1';
  static const String addressLine2 = 'address_line_2';
  static const String addressLine2Optional = 'address_line_2_optional';
  static const String cityField = 'city_field';
  static const String stateField = 'state_field';
  static const String countryField = 'country_field';
  static const String postalCode = 'postal_code';
  static const String postalCodeOptional = 'postal_code_optional';
  static const String setAsDefault = 'set_as_default';
  static const String saveAddress = 'save_address';
  static const String deleteAddress = 'delete_address';
  static const String deleteAddressConfirm = 'delete_address_confirm';
  static const String addressDeleted = 'address_deleted';
  static const String defaultAddressSet = 'default_address_set';
  static const String isNowDefault = 'is_now_default';
  static const String noAddresses = 'no_addresses';
  static const String noAddressesMessage = 'no_addresses_message';
  static const String addFirstAddress = 'add_first_address';
  static const String defaultBadge = 'default_badge';
  static const String labelRequired = 'label_required';
  static const String addressRequired = 'address_required';
  static const String deleted = 'deleted';

  // ── Notifications ───────────────────────────────────────
  static const String notifications = 'notifications';
  static const String notificationsDescription = 'notifications_description';
  static const String notificationsAll = 'notifications_all';
  static const String notificationsUnread = 'notifications_unread';
  static const String notificationsRead = 'notifications_read';
  static const String markRead = 'mark_read';
  static const String markAllRead = 'mark_all_read';
  static const String noNotifications = 'no_notifications';
  static const String noNotificationsMessage = 'no_notifications_message';
  static const String allNotificationsMarkedRead =
      'all_notifications_marked_read';

  // ── Relative Time ───────────────────────────────────────
  static const String timeJustNow = 'time_just_now';
  static const String timeMinutesAgo = 'time_minutes_ago';
  static const String timeHoursAgo = 'time_hours_ago';
  static const String timeDaysAgo = 'time_days_ago';
  static const String timeWeeksAgo = 'time_weeks_ago';
  static const String timeMonthsAgo = 'time_months_ago';
  static const String timeYearsAgo = 'time_years_ago';

  // ── Validation ──────────────────────────────────────────
  static const String requiredField = 'required_field';
  static const String invalidPhone = 'invalid_phone';
  static const String invalidEmail = 'invalid_email';
  static const String invalidOtp = 'invalid_otp';
  static const String nameTooShort = 'name_too_short';

  // ── Home (redesign) ─────────────────────────────────────
  static const String newArrivals = 'new_arrivals';
  static const String featuredStores = 'featured_stores';
  static const String categoryFilterAll = 'all_categories_filter';
  static const String searchHomeHint = 'search_home_hint';
  static const String homeHeroTitle = 'home_hero_title';
  static const String appearance = 'appearance';
  static const String themeLight = 'theme_light';
  static const String themeDark = 'theme_dark';
  static const String themeSystem = 'theme_system';

  // ── Orders (redesign) ───────────────────────────────────
  static const String orderProgress = 'order_progress';
  static const String stepPlaced = 'step_placed';
  static const String stepPaid = 'step_paid';
  static const String stepShipped = 'step_shipped';
  static const String stepDelivered = 'step_delivered';
  static const String totalPaid = 'total_paid';
  static const String soldShippedBy = 'sold_shipped_by';
  static const String ordersCount = 'orders_count';
  static const String ordersOnTheWay = 'orders_on_the_way';
  static const String itemsCount = 'items_count';
  static const String itemsCountOne = 'items_count_one';

  // ── Sellers + notifications (redesign) ──────────────────
  static const String sellersSubtitle = 'sellers_subtitle';
  static const String chatOnWhatsApp = 'chat_on_whatsapp';
  static const String clearSearch = 'clear_search';
  static const String loadingMoreSellers = 'loading_more_sellers';
  static const String productsLabel = 'products_label';
  static const String groupToday = 'group_today';
  static const String groupYesterday = 'group_yesterday';
  static const String groupEarlier = 'group_earlier';
  static const String unreadOfTotal = 'unread_of_total';
  static const String viewOrder = 'view_order_action';

  // ── Cart (multi-store) ──────────────────────────────────
  static const String cartTotal = 'cart_total';
  static const String cartStoresNote = 'cart_stores_note';
  static const String cartItemsFrom = 'cart_items_from';
  static const String youSaved = 'you_saved';
  static const String payingStore = 'paying_store';
  static const String storesCount = 'stores_count';
  static const String storesCountOne = 'stores_count_one';

  // ── Product detail (redesign) ───────────────────────────
  static const String bestSellers = 'best_sellers';
  static const String adminPicks = 'admin_picks';
  static const String readMore = 'read_more';
  static const String readLess = 'read_less';
  static const String weightLabel = 'weight_label';
  static const String skuLabel = 'sku_label';
  static const String addedLabel = 'added_label';
  static const String moreFromStore = 'more_from_store';
  static const String availableNowStore = 'available_now_store';
  static const String notAvailableOrder = 'not_available_order';
  static const String currentlyUnavailable = 'currently_unavailable';
  static const String outOfStockNote = 'out_of_stock_note';
  static const String productNotFound = 'product_not_found';
  static const String productNotFoundBody = 'product_not_found_body';
  static const String browseProducts = 'browse_products';
  static const String loadingProduct = 'loading_product';

  // ── Checkout (redesign) ─────────────────────────────────
  static const String payEdfaliHint = 'pay_edfali_hint';
  static const String payCodHint = 'pay_cod_hint';
  static const String payGatewayHint = 'pay_gateway_hint';
  static const String shippingPending = 'shipping_pending';

  // ── Payment outcome + Edfali (redesign) ─────────────────
  static const String amountPaid = 'amount_paid';
  static const String amountLabel = 'amount_label';
  static const String statusLabel = 'status_label';
  static const String backToCart = 'back_to_cart';
  static const String edfaliLead = 'edfali_lead';
  static const String codeExpiresIn = 'code_expires_in';
  static const String edfaliHoldWarn = 'edfali_hold_warn';
  static const String edfaliNoResend = 'edfali_no_resend';

  // ── Browse (redesign) ───────────────────────────────────
  static const String priceFrom = 'price_from';
  static const String priceTo = 'price_to';
  static const String searchTheMarket = 'search_the_market';
  static const String searchSubtitle = 'search_subtitle';
  static const String recentSearches = 'recent_searches';
  static const String shopBy = 'shop_by';
  static const String browseCategories = 'browse_categories';
  static const String subcategoriesCount = 'subcategories_count';
  static const String noSubcategories = 'no_subcategories';
  static const String pullToRefresh = 'pull_to_refresh';
  static const String clearFilters = 'clear_filters';
  static const String loadingMore = 'loading_more';
  static const String categoriesTitle = 'categories_title';
  static const String categoriesSubtitle = 'categories_subtitle';
  static const String allProductsTitle = 'all_products_title';
  static const String searchHintShort = 'search_hint_short';

  // ── Auth + entry (redesign) ─────────────────────────────
  static const String splashTagline = 'splash_tagline';
  static const String madeInLibya = 'made_in_libya';
  static const String onboard1Title = 'onboard_1_title';
  static const String onboard1Body = 'onboard_1_body';
  static const String onboard2Title = 'onboard_2_title';
  static const String onboard2Body = 'onboard_2_body';
  static const String onboard3Title = 'onboard_3_title';
  static const String onboard3Body = 'onboard_3_body';
  static const String skip = 'skip';
  static const String next = 'next';
  static const String startShopping = 'start_shopping';
  static const String welcomeTitle = 'welcome_title';
  static const String welcomeSubtitle = 'welcome_subtitle';
  static const String trustPayment = 'trust_payment';
  static const String trustStores = 'trust_stores';
  static const String trustDelivery = 'trust_delivery';
  static const String smsLanguage = 'sms_language';
  static const String firstTimeNote = 'first_time_note';
  static const String stepEnterPhone = 'step_enter_phone';
  static const String stepEnterCode = 'step_enter_code';
  static const String optionalChip = 'optional_chip';
  static const String createAccountSubtitle = 'create_account_subtitle';
  static const String codeSentToPhone = 'code_sent_to_phone';

  // ── Account + addresses (redesign) ──────────────────────
  static const String mapLocation = 'map_location';
  static const String mapPinHint = 'map_pin_hint';
  static const String confirmLocation = 'confirm_location';
  static const String changeLocation = 'change_location';
  static const String locationRequired = 'location_required';
  static const String locationPinned = 'location_pinned';

  // ── Map picker ──────────────────────────────────────────
  static const String mapMoving = 'map_moving';
  static const String mapMovingHint = 'map_moving_hint';
  static const String resolvingAddress = 'resolving_address';
  static const String noStreetAddress = 'no_street_address';
  static const String noStreetAddressHint = 'no_street_address_hint';
  static const String coordinates = 'coordinates';
  static const String coordinatesLive = 'coordinates_live';
  static const String locationServicesOff = 'location_services_off';
  static const String locationPermissionDenied = 'location_permission_denied';
  static const String openSettings = 'open_settings';
  static const String myLocation = 'my_location';
  static const String invalidLibyanPhone = 'invalid_libyan_phone';
  static const String selectCity = 'select_city';
  static const String searchCity = 'search_city';
  static const String districtOptional = 'district_optional';
  static const String fixFields = 'fix_fields';
  static const String sectionShopping = 'section_shopping';
  static const String sectionPreferences = 'section_preferences';
  static const String sectionAccount = 'section_account';
  static const String statOrders = 'stat_orders';
  static const String statAddresses = 'stat_addresses';
  static const String statUnread = 'stat_unread';
  static const String defaultAddress = 'default_address';
  static const String myAddresses = 'my_addresses';
  static const String addressesSubtitle = 'addresses_subtitle';

  // ── Refunds (redesign) ──────────────────────────────────
  static const String refundTypeFullHint = 'refund_type_full_hint';
  static const String refundTypePartialHint = 'refund_type_partial_hint';
  static const String refundWhichItems = 'refund_which_items';
  static const String refundReasonPick = 'refund_reason_pick';
  static const String refundReasonPickHint = 'refund_reason_pick_hint';
  static const String refundTellUs = 'refund_tell_us';
  static const String refundTellUsHint = 'refund_tell_us_hint';
  static const String refundPayoutMethod = 'refund_payout_method';
  static const String refundReview = 'refund_review';
  static const String refundEstimate = 'refund_estimate';
  static const String refundEstimateNote = 'refund_estimate_note';
  static const String refundStep1 = 'refund_step_1';
  static const String refundStep2 = 'refund_step_2';
  static const String refundContinue = 'refund_continue';
  static const String refundSubmit = 'refund_submit';
  static const String refundNoPayoutMethods = 'refund_no_payout_methods';
  static const String refundItemsCount = 'refund_items_count';

  // ── Address label chips ─────────────────────────────────
  static const String labelChipHome = 'label_chip_home';
  static const String labelChipWork = 'label_chip_work';
  static const String labelChipOther = 'label_chip_other';

  // ── Errors ──────────────────────────────────────────────
  static const String errorNoConnection = 'error_no_connection';
  static const String errorTimeout = 'error_timeout';
  static const String errorServer = 'error_server';
  static const String errorNotFound = 'error_not_found';
  static const String errorSessionExpired = 'error_session_expired';
  static const String errorForbidden = 'error_forbidden';
  static const String errorRateLimited = 'error_rate_limited';
  static const String errorUnexpected = 'error_unexpected';
  static const String errorBadRequest = 'error_bad_request';
  static const String errorAccountDeactivated = 'error_account_deactivated';
  static const String errorAccountNotFound = 'error_account_not_found';
  static const String errorAddressNotFound = 'error_address_not_found';
  static const String errorEdfaliAccountNotFound =
      'error_edfali_account_not_found';
  static const String errorEdfaliOtpInvalid = 'error_edfali_otp_invalid';
  static const String errorEdfaliPaymentFailed = 'error_edfali_payment_failed';
  static const String errorEdfaliSessionExpired =
      'error_edfali_session_expired';
  static const String errorPayoutMethodInvalid = 'error_payout_method_invalid';
  static const String errorRefundActiveExists = 'error_refund_active_exists';
  static const String errorRefundItemsRequired = 'error_refund_items_required';
  static const String errorRefundItemInvalid = 'error_refund_item_invalid';
  static const String fieldInvalidEmail = 'field_invalid_email';
  static const String fieldEmailTaken = 'field_email_taken';
  static const String fieldPhoneTaken = 'field_phone_taken';
  static const String fieldTooShort = 'field_too_short';
  static const String fieldTooLong = 'field_too_long';
  static const String stockLimitReached = 'stock_limit_reached';
  static const String onlyNLeft = 'only_n_left';
  static const String vendorDoesNotDeliver = 'vendor_does_not_deliver';
  static const String close = 'close';
  static const String appVersion = 'app_version';
}
