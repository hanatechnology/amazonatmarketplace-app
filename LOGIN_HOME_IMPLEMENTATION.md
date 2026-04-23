# Login & Home Screen Implementation + GetX Translation Setup

> **IMPORTANT**: This document is written for a **coding agent**. Follow instructions literally.
> Every file path, class name, import, and pattern must match what is described here.
>
> **Project**: `marketplace_app` (package name: `marketplace`)
> **State Management**: GetX with `AppState<T>` + `BaseStateController`
> **Architecture**: Clean Architecture — Presentation → Domain → Data
> **Font**: Inter (with Arabic fallback)
> **Figma file key**: `NO3iZ9gUb03kQWQELYob7F`

---

## Table of Contents

1. [PREREQUISITE — GetX Translation Setup (Do First)](#1-prerequisite--getx-translation-setup-do-first)
2. [Login Screen — Auth Flow](#2-login-screen--auth-flow)
3. [Home Screen — Components & Layout](#3-home-screen--components--layout)
4. [Implementation Priority Order](#4-implementation-priority-order)

---

## 1. PREREQUISITE — GetX Translation Setup (Do First)

### Why first?

Every screen in this document uses `.tr` on static strings. You **MUST** set up the translation system before implementing any screens, otherwise every `.tr` call will fail silently or show raw keys.

### 1.1 Create Translation Keys File

#### `lib/core/localization/locale_keys.dart`

```dart
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

  // ── OTP / Verification ─────────────────────────────────
  static const String verifyPhoneTitle = 'verify_phone_title';
  static const String verifyPhoneSubtitle = 'verify_phone_subtitle';
  static const String otpSentTo = 'otp_sent_to';
  static const String enterOtp = 'enter_otp';
  static const String verifyOtp = 'verify_otp';
  static const String resendOtp = 'resend_otp';
  static const String resendIn = 'resend_in';
  static const String didntReceiveCode = 'didnt_receive_code';

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
  static const String orderConfirmed = 'order_confirmed';
  static const String orderConfirmedMessage = 'order_confirmed_message';
  static const String continueShopping = 'continue_shopping';

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

  // ── Seller ──────────────────────────────────────────────
  static const String sellers = 'sellers';
  static const String follow = 'follow';
  static const String following = 'following';
  static const String followers = 'followers';
  static const String closed = 'closed';
  static const String open = 'open';

  // ── Account / Profile ───────────────────────────────────
  static const String myAccount = 'my_account';
  static const String profile = 'profile';
  static const String addressBook = 'address_book';
  static const String deliveryAreas = 'delivery_areas';
  static const String helpCenter = 'help_center';
  static const String language = 'language';
  static const String logout = 'logout';
  static const String logoutConfirm = 'logout_confirm';

  // ── Bottom Nav ──────────────────────────────────────────
  static const String navHome = 'nav_home';
  static const String navCategory = 'nav_category';
  static const String navSeller = 'nav_seller';
  static const String navCart = 'nav_cart';
  static const String navAccount = 'nav_account';

  // ── Validation ──────────────────────────────────────────
  static const String requiredField = 'required_field';
  static const String invalidPhone = 'invalid_phone';
  static const String invalidEmail = 'invalid_email';
  static const String invalidOtp = 'invalid_otp';
  static const String nameTooShort = 'name_too_short';
}
```

### 1.2 Create English Translation

#### `lib/core/localization/en.dart`

```dart
const Map<String, String> en = {
  // ── General ─────────────────────────────────────────────
  'app_name': 'Amazonat',
  'ok': 'OK',
  'cancel': 'Cancel',
  'retry': 'Retry',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'search': 'Search',
  'see_all': 'See All',
  'continue_text': 'Continue',
  'loading': 'Loading...',
  'no_data': 'No data available',
  'error': 'Something went wrong',
  'success': 'Success',

  // ── Auth / Login ────────────────────────────────────────
  'login_title': 'Welcome Back',
  'login_subtitle': 'Sign in to continue shopping',
  'phone_number': 'Phone Number',
  'phone_hint': 'Enter your phone number',
  'continue_as_guest': 'Continue as Guest',
  'send_otp': 'Send OTP',
  'or_continue_with': 'Or continue with',
  'continue_with_google': 'Continue with Google',
  'continue_with_apple': 'Continue with Apple',
  'terms_agreement': 'By continuing, you agree to our',
  'terms_of_service': 'Terms of Service',
  'privacy_policy': 'Privacy Policy',
  'and': 'and',

  // ── OTP / Verification ─────────────────────────────────
  'verify_phone_title': 'Verify Phone',
  'verify_phone_subtitle': 'We sent a verification code to your phone',
  'otp_sent_to': 'OTP sent to @phone',
  'enter_otp': 'Enter OTP code',
  'verify_otp': 'Verify',
  'resend_otp': 'Resend Code',
  'resend_in': 'Resend in @seconds s',
  'didnt_receive_code': "Didn't receive the code?",

  // ── Complete Details ────────────────────────────────────
  'complete_details_title': 'Complete Your Profile',
  'complete_details_subtitle': 'Tell us a bit about yourself',
  'full_name': 'Full Name',
  'full_name_hint': 'Enter your full name',
  'email': 'Email',
  'email_hint': 'Enter your email address',
  'create_account': 'Create Account',

  // ── Join Now ────────────────────────────────────────────
  'join_now_title': 'Join Amazonat',
  'join_now_subtitle': 'Discover amazing products from local sellers',
  'get_started': 'Get Started',
  'already_have_account': 'Already have an account?',
  'login': 'Login',

  // ── Home Screen ─────────────────────────────────────────
  'home': 'Home',
  'category': 'Category',
  'popular_products': 'Popular Product',
  'new_collection': 'New Collection',
  'discount_banner': 'Discount 20% for\nnew members',
  'shop_now': 'Shop now',
  'search_products': 'Search Products',
  'view_all': 'View All',

  // ── Product ─────────────────────────────────────────────
  'product_details': 'Product Details',
  'details': 'Details',
  'description': 'Description',
  'reviews': 'Reviews',
  'reviews_and_rating': 'Reviews & Rating',
  'add_to_cart': 'Add To Cart',
  'seller': 'Seller',
  'all_sellers': 'All Sellers',
  'learn_more': 'Learn more',

  // ── Category ────────────────────────────────────────────
  'categories': 'Categories',
  'all_categories': 'All Categories',

  // ── Cart ────────────────────────────────────────────────
  'cart': 'Cart',
  'my_cart': 'My Cart',
  'items': '@count Items',
  'select_all': 'Select All',
  'subtotal': 'Sub_Total',
  'discount': 'Discount',
  'total_cost': 'Total Cost',
  'checkout': 'CheckOut',
  'remove_item': 'Remove Item',
  'empty_cart': 'Your cart is empty',
  'empty_cart_message': 'Looks like you haven\'t added anything to your cart yet',

  // ── Checkout ────────────────────────────────────────────
  'checkout_title': 'Checkout',
  'delivery_address': 'Delivery Address',
  'payment_method': 'Payment Method',
  'add_card': 'Add Card',
  'place_order': 'Place Order',
  'order_confirmed': 'Order Confirmed!',
  'order_confirmed_message': 'Your order has been placed successfully',
  'continue_shopping': 'Continue Shopping',

  // ── Orders ──────────────────────────────────────────────
  'my_orders': 'My Order',
  'active': 'Active',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
  'order_details': 'Order Details',
  'track_order': 'Track Order',
  'return_order': 'Return',
  'pickup': 'Pickup',
  'no_orders': 'No orders yet',

  // ── Seller ──────────────────────────────────────────────
  'sellers': 'Sellers',
  'follow': 'Follow',
  'following': 'Following',
  'followers': 'Followers',
  'closed': 'Closed',
  'open': 'Open',

  // ── Account / Profile ───────────────────────────────────
  'my_account': 'My Account',
  'profile': 'Profile',
  'address_book': 'Address Book',
  'delivery_areas': 'Delivery Areas',
  'help_center': 'Help Center',
  'language': 'Language',
  'logout': 'Logout',
  'logout_confirm': 'Are you sure you want to logout?',

  // ── Bottom Nav ──────────────────────────────────────────
  'nav_home': 'Home',
  'nav_category': 'Category',
  'nav_seller': 'Seller',
  'nav_cart': 'Cart',
  'nav_account': 'Account',

  // ── Validation ──────────────────────────────────────────
  'required_field': 'This field is required',
  'invalid_phone': 'Please enter a valid phone number',
  'invalid_email': 'Please enter a valid email address',
  'invalid_otp': 'Please enter a valid OTP code',
  'name_too_short': 'Name must be at least 2 characters',
};
```

### 1.3 Create Arabic Translation

#### `lib/core/localization/ar.dart`

```dart
const Map<String, String> ar = {
  // ── General ─────────────────────────────────────────────
  'app_name': 'أمازونات',
  'ok': 'حسناً',
  'cancel': 'إلغاء',
  'retry': 'إعادة المحاولة',
  'save': 'حفظ',
  'delete': 'حذف',
  'edit': 'تعديل',
  'search': 'بحث',
  'see_all': 'عرض الكل',
  'continue_text': 'متابعة',
  'loading': 'جاري التحميل...',
  'no_data': 'لا توجد بيانات',
  'error': 'حدث خطأ ما',
  'success': 'تمت العملية بنجاح',

  // ── Auth / Login ────────────────────────────────────────
  'login_title': 'مرحباً بعودتك',
  'login_subtitle': 'سجل دخولك لمتابعة التسوق',
  'phone_number': 'رقم الهاتف',
  'phone_hint': 'أدخل رقم هاتفك',
  'continue_as_guest': 'المتابعة كزائر',
  'send_otp': 'إرسال رمز التحقق',
  'or_continue_with': 'أو المتابعة عبر',
  'continue_with_google': 'المتابعة عبر جوجل',
  'continue_with_apple': 'المتابعة عبر أبل',
  'terms_agreement': 'بالمتابعة، أنت توافق على',
  'terms_of_service': 'شروط الخدمة',
  'privacy_policy': 'سياسة الخصوصية',
  'and': 'و',

  // ── OTP / Verification ─────────────────────────────────
  'verify_phone_title': 'تحقق من الهاتف',
  'verify_phone_subtitle': 'أرسلنا رمز التحقق إلى هاتفك',
  'otp_sent_to': 'تم إرسال الرمز إلى @phone',
  'enter_otp': 'أدخل رمز التحقق',
  'verify_otp': 'تحقق',
  'resend_otp': 'إعادة إرسال الرمز',
  'resend_in': 'إعادة الإرسال خلال @seconds ث',
  'didnt_receive_code': 'لم تستلم الرمز؟',

  // ── Complete Details ────────────────────────────────────
  'complete_details_title': 'أكمل ملفك الشخصي',
  'complete_details_subtitle': 'أخبرنا قليلاً عن نفسك',
  'full_name': 'الاسم الكامل',
  'full_name_hint': 'أدخل اسمك الكامل',
  'email': 'البريد الإلكتروني',
  'email_hint': 'أدخل بريدك الإلكتروني',
  'create_account': 'إنشاء حساب',

  // ── Join Now ────────────────────────────────────────────
  'join_now_title': 'انضم إلى أمازونات',
  'join_now_subtitle': 'اكتشف منتجات مميزة من البائعين المحليين',
  'get_started': 'ابدأ الآن',
  'already_have_account': 'لديك حساب بالفعل؟',
  'login': 'تسجيل الدخول',

  // ── Home Screen ─────────────────────────────────────────
  'home': 'الرئيسية',
  'category': 'الفئات',
  'popular_products': 'المنتجات الشائعة',
  'new_collection': 'مجموعة جديدة',
  'discount_banner': 'خصم 20%\nللأعضاء الجدد',
  'shop_now': 'تسوق الآن',
  'search_products': 'ابحث عن المنتجات',
  'view_all': 'عرض الكل',

  // ── Product ─────────────────────────────────────────────
  'product_details': 'تفاصيل المنتج',
  'details': 'التفاصيل',
  'description': 'الوصف',
  'reviews': 'التقييمات',
  'reviews_and_rating': 'التقييمات والمراجعات',
  'add_to_cart': 'أضف إلى السلة',
  'seller': 'البائع',
  'all_sellers': 'جميع البائعين',
  'learn_more': 'اقرأ المزيد',

  // ── Category ────────────────────────────────────────────
  'categories': 'الفئات',
  'all_categories': 'جميع الفئات',

  // ── Cart ────────────────────────────────────────────────
  'cart': 'السلة',
  'my_cart': 'سلتي',
  'items': '@count عناصر',
  'select_all': 'تحديد الكل',
  'subtotal': 'المجموع الفرعي',
  'discount': 'الخصم',
  'total_cost': 'المجموع الكلي',
  'checkout': 'إتمام الشراء',
  'remove_item': 'إزالة العنصر',
  'empty_cart': 'سلتك فارغة',
  'empty_cart_message': 'يبدو أنك لم تضف أي شيء إلى سلتك بعد',

  // ── Checkout ────────────────────────────────────────────
  'checkout_title': 'إتمام الشراء',
  'delivery_address': 'عنوان التوصيل',
  'payment_method': 'طريقة الدفع',
  'add_card': 'إضافة بطاقة',
  'place_order': 'تأكيد الطلب',
  'order_confirmed': 'تم تأكيد الطلب!',
  'order_confirmed_message': 'تم تقديم طلبك بنجاح',
  'continue_shopping': 'متابعة التسوق',

  // ── Orders ──────────────────────────────────────────────
  'my_orders': 'طلباتي',
  'active': 'نشطة',
  'completed': 'مكتملة',
  'cancelled': 'ملغاة',
  'order_details': 'تفاصيل الطلب',
  'track_order': 'تتبع الطلب',
  'return_order': 'إرجاع',
  'pickup': 'استلام',
  'no_orders': 'لا توجد طلبات بعد',

  // ── Seller ──────────────────────────────────────────────
  'sellers': 'البائعون',
  'follow': 'متابعة',
  'following': 'متابَع',
  'followers': 'المتابعون',
  'closed': 'مغلق',
  'open': 'مفتوح',

  // ── Account / Profile ───────────────────────────────────
  'my_account': 'حسابي',
  'profile': 'الملف الشخصي',
  'address_book': 'دفتر العناوين',
  'delivery_areas': 'مناطق التوصيل',
  'help_center': 'مركز المساعدة',
  'language': 'اللغة',
  'logout': 'تسجيل الخروج',
  'logout_confirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',

  // ── Bottom Nav ──────────────────────────────────────────
  'nav_home': 'الرئيسية',
  'nav_category': 'الفئات',
  'nav_seller': 'البائع',
  'nav_cart': 'السلة',
  'nav_account': 'حسابي',

  // ── Validation ──────────────────────────────────────────
  'required_field': 'هذا الحقل مطلوب',
  'invalid_phone': 'الرجاء إدخال رقم هاتف صحيح',
  'invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
  'invalid_otp': 'الرجاء إدخال رمز تحقق صحيح',
  'name_too_short': 'الاسم يجب أن يكون حرفين على الأقل',
};
```

### 1.4 Create AppTranslations Class

#### `lib/core/localization/app_translations.dart`

```dart
import 'package:get/get.dart';
import 'en.dart';
import 'ar.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'ar_SA': ar,
      };
}
```

### 1.5 Create Locale Controller

#### `lib/core/localization/locale_controller.dart`

```dart
import 'dart:ui';
import 'package:get/get.dart';
import '../../data/services/storage_service.dart';

/// Controls app locale and persists user preference.
/// Registered in InitialBinding as permanent.
class LocaleController extends GetxController {
  static const String _storageKey = 'app_locale';

  /// Current locale — observable for UI reactivity
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  /// Supported locales list
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  /// Load persisted locale on startup
  void _loadSavedLocale() {
    final stored = StorageService.to.getString(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      final parts = stored.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        Get.updateLocale(locale);
      }
    }
  }

  /// Switch to Arabic
  void switchToArabic() => changeLocale(const Locale('ar', 'SA'));

  /// Switch to English
  void switchToEnglish() => changeLocale(const Locale('en', 'US'));

  /// Toggle between English and Arabic
  void toggleLocale() {
    if (isArabic) {
      switchToEnglish();
    } else {
      switchToArabic();
    }
  }

  /// Change to any supported locale
  void changeLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    StorageService.to.setString(_storageKey, '${locale.languageCode}_${locale.countryCode}');
  }

  /// Convenience getters
  bool get isArabic => currentLocale.value.languageCode == 'ar';
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  bool get isRTL => isArabic;
}
```

### 1.6 Update `main.dart`

**MODIFY** the existing `lib/main.dart` — add translation and locale properties to `GetMaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/services/storage_service.dart';
import 'core/network/dio_client.dart';
import 'core/theme/marketplace_theme.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Marketplace',
      debugShowCheckedModeBanner: false,
      theme: MarketplaceTheme.lightTheme,

      // ── Translation setup ──────────────────────────────
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),       // Default locale
      fallbackLocale: const Locale('en', 'US'), // Fallback if key missing

      initialRoute: Routes.MARKETPLACE,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      smartManagement: SmartManagement.full,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page not found')),
    );
  }
}
```

### 1.7 Update `initial_binding.dart`

**MODIFY** the existing `lib/app/bindings/initial_binding.dart` — add `LocaleController`:

```dart
import 'package:get/get.dart';
import '../../data/services/storage_service.dart';
import '../../core/network/dio_client.dart';
import '../../data/services/api_service.dart';
import '../../core/localization/locale_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(DioClient(), permanent: true);
    Get.put(ApiService(Get.find<DioClient>()), permanent: true);
    Get.put(StorageService.to, permanent: true);

    // Localization — permanent so it persists across all screens
    Get.put(LocaleController(), permanent: true);
  }
}
```

### 1.8 Update `marketplace_bottom_nav.dart`

**MODIFY** the existing `lib/core/components/marketplace/marketplace_bottom_nav.dart` — replace hardcoded labels with translation keys:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_shadows.dart';
import '../../theme/marketplace_icons.dart';
import '../../theme/marketplace_radius.dart';
import '../../../core/localization/locale_keys.dart';

class MarketplaceBottomNav extends StatelessWidget {
  const MarketplaceBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  // USE .tr for all labels
  List<String> get _labels => [
    LocaleKeys.navHome.tr,
    LocaleKeys.navCategory.tr,
    LocaleKeys.navSeller.tr,
    LocaleKeys.navCart.tr,
    LocaleKeys.navAccount.tr,
  ];

  static const _outlinedIcons = [
    MarketplaceIcons.homeOutlined,
    MarketplaceIcons.categoryOutlined,
    MarketplaceIcons.sellerOutlined,
    MarketplaceIcons.cartOutlined,
    MarketplaceIcons.accountOutlined,
  ];
  static const _filledIcons = [
    MarketplaceIcons.homeFilled,
    MarketplaceIcons.categoryFilled,
    MarketplaceIcons.sellerFilled,
    MarketplaceIcons.cartFilled,
    MarketplaceIcons.accountFilled,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: MarketplaceRadius.bottomNavBR,
          boxShadow: const [MarketplaceShadows.bottomNav],
        ),
        child: Row(
          children: List.generate(5, (i) => _buildTab(i)),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final isActive = currentIndex == index;
    final color = isActive ? MarketplaceColors.primary : MarketplaceColors.iconInactive;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? _filledIcons[index] : _outlinedIcons[index],
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              _labels[index],
              style: MarketplaceTypography.navLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 1.9 Translation Usage Rules

**CRITICAL**: Apply these rules to EVERY screen and widget from now on:

```dart
// ✅ CORRECT — always use .tr with LocaleKeys
Text(LocaleKeys.addToCart.tr)
Text(LocaleKeys.myCart.tr)
hintText: LocaleKeys.searchProducts.tr

// ✅ CORRECT — parameterized translations
Text(LocaleKeys.items.trParams({'count': '${cart.length}'}))
Text(LocaleKeys.otpSentTo.trParams({'phone': phoneNumber}))
Text(LocaleKeys.resendIn.trParams({'seconds': '$countdown'}))

// ❌ WRONG — never use hardcoded strings for UI text
Text('Add To Cart')      // ← WRONG
Text('My Cart')          // ← WRONG
hintText: 'Search...'    // ← WRONG

// ❌ WRONG — never use raw string keys
Text('add_to_cart'.tr)   // ← WRONG, use LocaleKeys.addToCart.tr
```

---

## 2. Login Screen — Auth Flow

### Auth Flow Overview (from Figma)

```
Join Now → Login → Verify Phone → OTP Verification → Complete Details → Main Navigation
                                                                  ↓
                                              (or) Continue as Guest → Main Navigation
```

**Social login options**: Google + Apple (displayed as buttons below OTP flow)

### 2.1 Auth Controller

#### `lib/presentation/controllers/marketplace/auth_controller.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../data/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';

/// Handles the entire auth flow: phone entry → OTP → profile completion.
/// Also supports Google/Apple social login.
class AuthController extends GetxController {
  // ── Phone Entry ────────────────────────────────────────
  final phoneController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final phoneError = RxnString();

  // ── OTP ────────────────────────────────────────────────
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final otpError = RxnString();
  final isResendEnabled = false.obs;
  final resendCountdown = 60.obs;
  Timer? _resendTimer;

  // ── Complete Details ───────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nameError = RxnString();
  final emailError = RxnString();

  // ── State ──────────────────────────────────────────────
  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  @override
  void onClose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    for (final c in otpControllers) c.dispose();
    for (final f in otpFocusNodes) f.dispose();
    nameController.dispose();
    emailController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // ── Validation ─────────────────────────────────────────

  bool validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = LocaleKeys.requiredField.tr;
      return false;
    }
    // Basic phone validation — adjust regex for your region
    if (phone.length < 9 || !RegExp(r'^[0-9+]+$').hasMatch(phone)) {
      phoneError.value = LocaleKeys.invalidPhone.tr;
      return false;
    }
    phoneError.value = null;
    return true;
  }

  bool validateOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      otpError.value = LocaleKeys.invalidOtp.tr;
      return false;
    }
    otpError.value = null;
    return true;
  }

  bool validateDetails() {
    bool valid = true;
    if (nameController.text.trim().length < 2) {
      nameError.value = LocaleKeys.nameTooShort.tr;
      valid = false;
    } else {
      nameError.value = null;
    }
    final email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      emailError.value = LocaleKeys.invalidEmail.tr;
      valid = false;
    } else {
      emailError.value = null;
    }
    return valid;
  }

  // ── Actions ────────────────────────────────────────────

  /// Step 1: Send OTP to phone number
  Future<void> sendOtp() async {
    if (!validatePhone()) return;

    isLoading.value = true;
    phoneNumber.value = phoneController.text.trim();

    try {
      // TODO: Call auth API to send OTP
      // await authRepository.sendOtp(phoneNumber.value);

      // Simulate API delay for now
      await Future.delayed(const Duration(seconds: 1));

      Get.toNamed(Routes.MARKETPLACE_VERIFY);
      _startResendTimer();
    } catch (e) {
      Get.snackbar(LocaleKeys.error.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify OTP code
  Future<void> verifyOtp() async {
    if (!validateOtp()) return;

    isLoading.value = true;
    final otp = otpControllers.map((c) => c.text).join();

    try {
      // TODO: Call auth API to verify OTP
      // final result = await authRepository.verifyOtp(phoneNumber.value, otp);

      await Future.delayed(const Duration(seconds: 1));

      // If new user → complete details, if existing → go to main
      // For now, always go to complete details
      Get.toNamed(Routes.MARKETPLACE_COMPLETE_DETAILS);
    } catch (e) {
      otpError.value = LocaleKeys.invalidOtp.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3: Complete profile details
  Future<void> completeProfile() async {
    if (!validateDetails()) return;

    isLoading.value = true;

    try {
      // TODO: Call API to update profile
      // await authRepository.updateProfile(name, email);

      await Future.delayed(const Duration(seconds: 1));

      // Navigate to main and remove all auth routes from stack
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
    } catch (e) {
      Get.snackbar(LocaleKeys.error.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Guest login — skip auth entirely
  void continueAsGuest() {
    // TODO: Set guest flag in StorageService
    Get.offAllNamed(Routes.MARKETPLACE_MAIN);
  }

  /// Social login: Google
  Future<void> continueWithGoogle() async {
    isLoading.value = true;
    try {
      // TODO: Implement Google Sign-In
      // 1. google_sign_in package → get idToken
      // 2. Send idToken to your backend
      // 3. Backend returns JWT
      // 4. Store JWT in StorageService
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
    } catch (e) {
      Get.snackbar(LocaleKeys.error.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Social login: Apple
  Future<void> continueWithApple() async {
    isLoading.value = true;
    try {
      // TODO: Implement Apple Sign-In
      // 1. sign_in_with_apple package → get credential
      // 2. Send credential to your backend
      // 3. Backend returns JWT
      // 4. Store JWT in StorageService
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
    } catch (e) {
      Get.snackbar(LocaleKeys.error.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── OTP Resend Timer ───────────────────────────────────

  void _startResendTimer() {
    isResendEnabled.value = false;
    resendCountdown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        isResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    if (!isResendEnabled.value) return;
    // Clear previous OTP
    for (final c in otpControllers) c.clear();
    sendOtp();
  }

  // ── OTP Field Navigation ───────────────────────────────

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits entered
    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      verifyOtp();
    }
  }
}
```

### 2.2 Auth Binding Update

#### **MODIFY** `lib/presentation/pages/marketplace/auth/bindings/marketplace_auth_binding.dart`

```dart
import 'package:get/get.dart';
import '../../../../controllers/marketplace/auth_controller.dart';

class MarketplaceAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
```

### 2.3 Login Page (Full Implementation)

#### **REWRITE** `lib/presentation/pages/marketplace/auth/marketplace_login_page.dart`

**Figma node**: `119:5377` — Figma file key: `NO3iZ9gUb03kQWQELYob7F`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class MarketplaceLoginPage extends GetView<AuthController> {
  const MarketplaceLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.md),

              // ── Guest Skip Button (top right) ───────────
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: controller.continueAsGuest,
                  child: Text(
                    LocaleKeys.continueAsGuest.tr,
                    style: MarketplaceTypography.cardTitle.copyWith(
                      color: MarketplaceColors.textBody,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xxl),

              // ── App Logo / Brand ────────────────────────
              Center(
                child: Text(
                  LocaleKeys.appName.tr,
                  style: MarketplaceTypography.screenTitle.copyWith(
                    fontSize: 32,
                    color: MarketplaceColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.sm),

              // ── Title & Subtitle ────────────────────────
              Center(
                child: Text(
                  LocaleKeys.loginTitle.tr,
                  style: MarketplaceTypography.sectionHeading,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Center(
                child: Text(
                  LocaleKeys.loginSubtitle.tr,
                  style: MarketplaceTypography.descriptionBody,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Phone Number Field ──────────────────────
              Text(
                LocaleKeys.phoneNumber.tr,
                style: MarketplaceTypography.cardTitle.copyWith(
                  color: MarketplaceColors.textBody,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Obx(() => TextField(
                controller: controller.phoneController,
                focusNode: controller.phoneFocusNode,
                keyboardType: TextInputType.phone,
                style: MarketplaceTypography.body,
                decoration: InputDecoration(
                  hintText: LocaleKeys.phoneHint.tr,
                  errorText: controller.phoneError.value,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Country flag / code — customize per region
                        Text('+964 ', style: TextStyle(fontSize: 16)),
                        SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            color: MarketplaceColors.stroke,
                            width: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onChanged: (_) => controller.phoneError.value = null,
              )),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Send OTP Button ─────────────────────────
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.sendOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.onPrimary,
                        ),
                      )
                    : Text(
                        LocaleKeys.sendOtp.tr,
                        style: MarketplaceTypography.buttonLabel,
                      ),
              )),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Divider with "Or continue with" ─────────
              Row(
                children: [
                  const Expanded(child: Divider(color: MarketplaceColors.stroke)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.md),
                    child: Text(
                      LocaleKeys.orContinueWith.tr,
                      style: MarketplaceTypography.descriptionBody,
                    ),
                  ),
                  const Expanded(child: Divider(color: MarketplaceColors.stroke)),
                ],
              ),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Google Button ───────────────────────────
              _SocialLoginButton(
                label: LocaleKeys.continueWithGoogle.tr,
                iconPath: 'assets/icons/google.svg', // Add SVG asset
                onTap: controller.continueWithGoogle,
              ),

              const SizedBox(height: MarketplaceSpacing.md),

              // ── Apple Button ────────────────────────────
              _SocialLoginButton(
                label: LocaleKeys.continueWithApple.tr,
                iconPath: 'assets/icons/apple.svg', // Add SVG asset
                onTap: controller.continueWithApple,
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Terms Agreement ─────────────────────────
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.termsAgreement.tr,
                      style: MarketplaceTypography.micro.copyWith(
                        color: MarketplaceColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {/* TODO: Open Terms URL */},
                      child: Text(
                        LocaleKeys.termsOfService.tr,
                        style: MarketplaceTypography.micro.copyWith(
                          color: MarketplaceColors.link,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' ${LocaleKeys.and.tr} ',
                      style: MarketplaceTypography.micro.copyWith(
                        color: MarketplaceColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {/* TODO: Open Privacy URL */},
                      child: Text(
                        LocaleKeys.privacyPolicy.tr,
                        style: MarketplaceTypography.micro.copyWith(
                          color: MarketplaceColors.link,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable social login button (outlined style)
class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.button),
        ),
        side: const BorderSide(color: MarketplaceColors.stroke),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Image.asset for PNG or flutter_svg for SVG
          // For now, use a placeholder icon
          const Icon(Icons.login, size: 20, color: MarketplaceColors.textBody),
          const SizedBox(width: 12),
          Text(
            label,
            style: MarketplaceTypography.body.copyWith(
              color: MarketplaceColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.4 Verify Phone Page

#### **REWRITE** `lib/presentation/pages/marketplace/auth/verify_phone_page.dart`

**Figma node**: `119:5432`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class VerifyPhonePage extends GetView<AuthController> {
  const VerifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.verifyPhoneTitle.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Title ───────────────────────────────────
              Text(
                LocaleKeys.verifyPhoneTitle.tr,
                style: MarketplaceTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),

              // ── Subtitle with phone number ──────────────
              Obx(() => Text(
                LocaleKeys.otpSentTo.trParams({
                  'phone': controller.phoneNumber.value,
                }),
                style: MarketplaceTypography.descriptionBody,
                textAlign: TextAlign.center,
              )),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── OTP Input Fields (6 digits) ─────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => SizedBox(
                  width: 48,
                  height: 56,
                  child: TextField(
                    controller: controller.otpControllers[i],
                    focusNode: controller.otpFocusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: MarketplaceTypography.sectionHeading,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
                        borderSide: const BorderSide(color: MarketplaceColors.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
                        borderSide: const BorderSide(
                          color: MarketplaceColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => controller.onOtpChanged(i, value),
                  ),
                )),
              ),

              // ── OTP Error ───────────────────────────────
              Obx(() => controller.otpError.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: MarketplaceSpacing.sm),
                      child: Text(
                        controller.otpError.value!,
                        style: MarketplaceTypography.micro.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Verify Button ───────────────────────────
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.onPrimary,
                        ),
                      )
                    : Text(
                        LocaleKeys.verifyOtp.tr,
                        style: MarketplaceTypography.buttonLabel,
                      ),
              )),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Resend Timer ────────────────────────────
              Center(
                child: Obx(() {
                  if (controller.isResendEnabled.value) {
                    return GestureDetector(
                      onTap: controller.resendOtp,
                      child: Text(
                        LocaleKeys.resendOtp.tr,
                        style: MarketplaceTypography.body.copyWith(
                          color: MarketplaceColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        LocaleKeys.didntReceiveCode.tr,
                        style: MarketplaceTypography.descriptionBody,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.resendIn.trParams({
                          'seconds': '${controller.resendCountdown.value}',
                        }),
                        style: MarketplaceTypography.cardTitle.copyWith(
                          color: MarketplaceColors.primary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.5 Complete Details Page

#### **REWRITE** `lib/presentation/pages/marketplace/auth/complete_details_page.dart`

**Figma node**: `153:645`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class CompleteDetailsPage extends GetView<AuthController> {
  const CompleteDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.lg),

              Text(
                LocaleKeys.completeDetailsTitle.tr,
                style: MarketplaceTypography.sectionHeading,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.completeDetailsSubtitle.tr,
                style: MarketplaceTypography.descriptionBody,
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Full Name ───────────────────────────────
              Text(LocaleKeys.fullName.tr, style: MarketplaceTypography.cardTitle),
              const SizedBox(height: MarketplaceSpacing.sm),
              Obx(() => TextField(
                controller: controller.nameController,
                style: MarketplaceTypography.body,
                decoration: InputDecoration(
                  hintText: LocaleKeys.fullNameHint.tr,
                  errorText: controller.nameError.value,
                ),
                onChanged: (_) => controller.nameError.value = null,
              )),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Email ───────────────────────────────────
              Text(LocaleKeys.email.tr, style: MarketplaceTypography.cardTitle),
              const SizedBox(height: MarketplaceSpacing.sm),
              Obx(() => TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                style: MarketplaceTypography.body,
                decoration: InputDecoration(
                  hintText: LocaleKeys.emailHint.tr,
                  errorText: controller.emailError.value,
                ),
                onChanged: (_) => controller.emailError.value = null,
              )),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Create Account Button ───────────────────
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.completeProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.onPrimary,
                        ),
                      )
                    : Text(
                        LocaleKeys.createAccount.tr,
                        style: MarketplaceTypography.buttonLabel,
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.6 Join Now Page

#### **REWRITE** `lib/presentation/pages/marketplace/auth/join_now_page.dart`

**Figma node**: `95:3758`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../app/routes/app_routes.dart';

class JoinNowPage extends StatelessWidget {
  const JoinNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // ── Illustration Placeholder ────────────────
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: MarketplaceColors.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: MarketplaceColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              Text(
                LocaleKeys.joinNowTitle.tr,
                style: MarketplaceTypography.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.joinNowSubtitle.tr,
                style: MarketplaceTypography.descriptionBody,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Get Started Button ──────────────────────
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.MARKETPLACE_LOGIN),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: Text(
                  LocaleKeys.getStarted.tr,
                  style: MarketplaceTypography.buttonLabel,
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.md),

              // ── Already have account? Login ─────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.alreadyHaveAccount.tr,
                    style: MarketplaceTypography.descriptionBody,
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.MARKETPLACE_LOGIN),
                    child: Text(
                      LocaleKeys.login.tr,
                      style: MarketplaceTypography.body.copyWith(
                        color: MarketplaceColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: MarketplaceSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Home Screen — Components & Layout

### 3.1 Home Page Layout (from Figma node `97:5446`)

The Home screen layout from top to bottom:

```
┌─────────────────────────────────────┐
│ SearchBarWidget + Filter button     │ ← sticky top
├─────────────────────────────────────┤
│ PromoBanner carousel (PageView)     │ ← 343×146, auto-scroll
│ SmoothPageIndicator (dots)          │
├─────────────────────────────────────┤
│ "Category" heading + "See All" →    │
│ Horizontal scroll: CategoryChip ×N  │ ← 74 wide each
├─────────────────────────────────────┤
│ "Popular Product" heading           │
│ GridView: ProductCard (2 columns)   │ ← 164×231 each
│ (staggered or fixed grid)           │
└─────────────────────────────────────┘
```

### 3.2 Home Controller Update

#### **REWRITE** `lib/presentation/controllers/marketplace/home_controller.dart`

```dart
import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/product/search_products_use_case.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/entities/marketplace/category_entity.dart';

class HomeController extends BaseStateController<GetProductsUseCase> {
  // ── Operation keys ─────────────────────────────────────
  static const String kCategories = 'categories';
  static const String kProducts = 'products';
  static const String kSearch = 'search';

  // ── Local reactive state ───────────────────────────────
  final searchQuery = ''.obs;
  final activeBannerIndex = 0.obs;

  // ── Banner data (static for now, later from API) ───────
  final banners = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBanners();
    loadHomeData();
  }

  void _loadBanners() {
    // TODO: Replace with API call when banner endpoint is ready
    banners.value = [
      {
        'title': 'new_collection',
        'subtitle': 'discount_banner',
        'cta': 'shop_now',
        'image': 'assets/images/banner_1.png',
      },
      {
        'title': 'new_collection',
        'subtitle': 'discount_banner',
        'cta': 'shop_now',
        'image': 'assets/images/banner_2.png',
      },
    ];
  }

  /// Load categories + products in parallel
  Future<void> loadHomeData() async {
    await handleMultipleStates({
      kCategories: () => Get.find<GetCategoriesUseCase>().execute(),
      kProducts: () => useCase.execute(),
    });
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      // Reset to normal products
      await handleState(
        kProducts,
        () => useCase.execute(),
      );
      return;
    }
    await handleState(
      kSearch,
      () => Get.find<SearchProductsUseCase>().call(query),
    );
  }

  void onBannerChanged(int index) {
    activeBannerIndex.value = index;
  }
}
```

### 3.3 Home Binding Update

#### **REWRITE** `lib/presentation/pages/marketplace/home/bindings/home_binding.dart`

```dart
import 'package:get/get.dart';
import '../../../../controllers/marketplace/home_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()));
    Get.lazyPut(() => SearchProductsUseCase(Get.find()));
    Get.lazyPut(() => HomeController());
  }
}
```

### 3.4 Home Page (Full Implementation)

#### **REWRITE** `lib/presentation/pages/marketplace/home/home_page.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/search_bar_widget.dart';
import '../../../../core/components/marketplace/promo_banner.dart';
import '../../../../core/components/marketplace/category_chip.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/home_controller.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../app/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.find<HomeController>();
  final _bannerController = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerController.hasClients && controller.banners.isNotEmpty) {
        final next = (_bannerController.page?.round() ?? 0) + 1;
        _bannerController.animateToPage(
          next % controller.banners.length,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: MarketplaceColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── Search Bar ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: SearchBarWidget(
                    hintText: LocaleKeys.searchProducts.tr,
                    onSearch: controller.searchProducts,
                    onFilter: () {
                      // TODO: Open filter bottom sheet
                    },
                  ),
                ),
              ),

              // ── Banner Carousel ─────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.banners.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      SizedBox(
                        height: MarketplaceSpacing.bannerHeight,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: controller.banners.length,
                          onPageChanged: controller.onBannerChanged,
                          itemBuilder: (_, index) {
                            final banner = controller.banners[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: MarketplaceSpacing.screenPaddingH,
                              ),
                              child: PromoBanner(
                                title: banner['title']!.tr,
                                subtitle: banner['subtitle']!.tr,
                                ctaLabel: banner['cta']!.tr,
                                imageUrl: banner['image']!,
                                onCta: () {
                                  // TODO: Navigate to promotion
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: MarketplaceSpacing.sm),
                      Obx(() => SmoothPageIndicator(
                        controller: _bannerController,
                        count: controller.banners.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: MarketplaceColors.primary,
                          dotColor: MarketplaceColors.stroke,
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 3,
                        ),
                      )),
                    ],
                  );
                }),
              ),

              // ── Category Section ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.lg,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: _SectionHeader(
                    title: LocaleKeys.category.tr,
                    onSeeAll: () {
                      // TODO: Navigate to full category page (tab 1)
                    },
                  ),
                ),
              ),

              // ── Category Chips (horizontal scroll) ──────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MarketplaceSpacing.categoryImageHeight + 24, // image + label
                  child: _buildCategoryList(),
                ),
              ),

              // ── Popular Products Header ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.lg,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: _SectionHeader(
                    title: LocaleKeys.popularProducts.tr,
                    onSeeAll: () {
                      // TODO: Navigate to products list with filter
                    },
                  ),
                ),
              ),

              // ── Product Grid ────────────────────────────
              _buildProductGrid(),

              // ── Bottom spacing for nav bar ──────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: MarketplaceSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Categories horizontal list with StateBuilder
  Widget _buildCategoryList() {
    // Use StateBuilder if you have it wired up, otherwise:
    return Obx(() {
      final state = controller.stateFor(HomeController.kCategories);
      return state.value.when(
        initial: () => const SizedBox.shrink(),
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: MarketplaceSpacing.categoryGap),
          itemBuilder: (_, __) => const CategoryChipShimmer(),
        ),
        success: (data, _) {
          final categories = data as List<CategoryEntity>;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: MarketplaceSpacing.categoryGap),
            itemBuilder: (_, index) => CategoryChip(
              category: categories[index],
              onTap: () {
                // TODO: Navigate to category products
              },
            ),
          );
        },
        error: (message, _) => Center(
          child: Text(message ?? LocaleKeys.error.tr),
        ),
      );
    });
  }

  /// Products grid with StateBuilder
  Widget _buildProductGrid() {
    return Obx(() {
      final state = controller.stateFor(HomeController.kProducts);
      return state.value.when(
        initial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        loading: () => SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          sliver: SliverGrid.count(
            crossAxisCount: MarketplaceSpacing.productGridColumns,
            crossAxisSpacing: MarketplaceSpacing.productGridGap,
            mainAxisSpacing: MarketplaceSpacing.productGridGap,
            childAspectRatio: MarketplaceSpacing.productCardWidth / MarketplaceSpacing.productCardHeight,
            children: List.generate(4, (_) => const ProductCardShimmer()),
          ),
        ),
        success: (data, _) {
          final products = data as List<ProductEntity>;
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: MarketplaceSpacing.productGridColumns,
              crossAxisSpacing: MarketplaceSpacing.productGridGap,
              mainAxisSpacing: MarketplaceSpacing.productGridGap,
              childAspectRatio: MarketplaceSpacing.productCardWidth / MarketplaceSpacing.productCardHeight,
              children: products.map((product) => ProductCard(
                product: product,
                onTap: () => Get.toNamed(
                  Routes.MARKETPLACE_PRODUCT,
                  arguments: product.id,
                ),
                onAddToCart: () {
                  // TODO: Call add to cart
                },
              )).toList(),
            ),
          );
        },
        error: (message, _) => SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                Text(message ?? LocaleKeys.error.tr),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.loadHomeData,
                  child: Text(LocaleKeys.retry.tr),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Section header with title + "See All" action
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: MarketplaceTypography.sectionHeading),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            LocaleKeys.seeAll.tr,
            style: MarketplaceTypography.cardTitle.copyWith(
              color: MarketplaceColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer placeholder for CategoryChip
class CategoryChipShimmer extends StatelessWidget {
  const CategoryChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MarketplaceSpacing.categoryChipWidth,
      child: Column(
        children: [
          Container(
            width: MarketplaceSpacing.categoryChipWidth,
            height: MarketplaceSpacing.categoryImageHeight,
            decoration: BoxDecoration(
              color: MarketplaceColors.stroke.withOpacity(0.3),
              borderRadius: BorderRadius.circular(MarketplaceRadius.card),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              color: MarketplaceColors.stroke.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.5 New Dependency Needed

Add `smooth_page_indicator` if not already present (it should be, check `pubspec.yaml`):

```yaml
smooth_page_indicator: ^1.1.0  # Already in pubspec.yaml ✓
```

### 3.6 Missing Shimmer Widgets

Ensure `lib/core/components/marketplace/loading_shimmer.dart` exports these classes:
- `ProductCardShimmer` — matches ProductCard dimensions (164×231)
- `CartItemShimmer` — matches CartItemCard dimensions (full-width × 110)
- `BannerShimmer` — matches PromoBanner dimensions (343×146)

If the existing `loading_shimmer.dart` doesn't have `ProductCardShimmer`, add it.

---

## 4. Implementation Priority Order

### Phase A — Translation Infrastructure (DO FIRST)

1. Create `lib/core/localization/locale_keys.dart`
2. Create `lib/core/localization/en.dart`
3. Create `lib/core/localization/ar.dart`
4. Create `lib/core/localization/app_translations.dart`
5. Create `lib/core/localization/locale_controller.dart`
6. **MODIFY** `lib/main.dart` — add translations, locale, fallbackLocale
7. **MODIFY** `lib/app/bindings/initial_binding.dart` — add LocaleController
8. **MODIFY** `lib/core/components/marketplace/marketplace_bottom_nav.dart` — use `.tr` keys

### Phase B — Auth Flow

9. Create `lib/presentation/controllers/marketplace/auth_controller.dart`
10. **MODIFY** `lib/presentation/pages/marketplace/auth/bindings/marketplace_auth_binding.dart`
11. **REWRITE** `lib/presentation/pages/marketplace/auth/join_now_page.dart`
12. **REWRITE** `lib/presentation/pages/marketplace/auth/marketplace_login_page.dart`
13. **REWRITE** `lib/presentation/pages/marketplace/auth/verify_phone_page.dart`
14. **REWRITE** `lib/presentation/pages/marketplace/auth/complete_details_page.dart`

### Phase C — Home Screen

15. **REWRITE** `lib/presentation/controllers/marketplace/home_controller.dart`
16. **REWRITE** `lib/presentation/pages/marketplace/home/bindings/home_binding.dart`
17. **REWRITE** `lib/presentation/pages/marketplace/home/home_page.dart`
18. Verify shimmer widgets exist in `loading_shimmer.dart`

### Phase D — Retrofit Existing Screens

19. Update ALL existing placeholder screens to use `LocaleKeys.xxx.tr` instead of hardcoded strings
20. Update `SearchBarWidget` hintText default to use `LocaleKeys.search.tr`
21. Update `MarketplaceAppBar` and any other widgets that have hardcoded English text

---

## Figma Node ID Reference (for future Figma MCP queries)

| Screen | Node ID | File Key |
|--------|---------|----------|
| Login | `119:5377` | `NO3iZ9gUb03kQWQELYob7F` |
| Verify Phone | `119:5432` | `NO3iZ9gUb03kQWQELYob7F` |
| Verification | `119:5617` | `NO3iZ9gUb03kQWQELYob7F` |
| Complete Details | `153:645` | `NO3iZ9gUb03kQWQELYob7F` |
| Join Now | `95:3758` | `NO3iZ9gUb03kQWQELYob7F` |
| Home | `97:5446` | `NO3iZ9gUb03kQWQELYob7F` |
| Components | `119:5866` | `NO3iZ9gUb03kQWQELYob7F` |

---

*This document builds on the existing `MARKETPLACE_FLUTTER_KICKSTART.md`. All patterns (AppState<T>, BaseStateController, BaseRepository, BaseUseCase, Result<T>, StateBuilder<T>) are reused. Translation keys MUST be used for every static string — no exceptions.*
