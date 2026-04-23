# Marketplace Flutter App — Kickstart System Design

> **IMPORTANT**: This document is written for a **coding agent**. Follow instructions literally.
> Every file path, class name, import, and pattern must match what is described here.
>
> **Source**: Figma file `Market-place` (key: `NO3iZ9gUb03kQWQELYob7F`)
> **Existing Project**: `the_koshk_app` — reuse ALL existing core/base infrastructure
> **State Management**: GetX (already in project)
> **Architecture**: Clean Architecture with AppState<T> + BaseStateController (already in project)
> **Font**: Inter (English-first marketplace app, LTR)

---

## Table of Contents

1. [Architecture Overview — What Already Exists](#1-architecture-overview--what-already-exists)
2. [New Dependencies to Add](#2-new-dependencies-to-add)
3. [New Folder Structure](#3-new-folder-structure)
4. [Design Tokens — Colors](#4-design-tokens--colors)
5. [Design Tokens — Typography](#5-design-tokens--typography)
6. [Design Tokens — Spacing & Radius](#6-design-tokens--spacing--radius)
7. [Design Tokens — Shadows](#7-design-tokens--shadows)
8. [Design Tokens — Icons](#8-design-tokens--icons)
9. [Theme Configuration — Marketplace Override](#9-theme-configuration--marketplace-override)
10. [Navigation Architecture — Nested Tab Solution](#10-navigation-architecture--nested-tab-solution)
11. [Screen Inventory & Routes](#11-screen-inventory--routes)
12. [New Shared Widgets (Marketplace-Specific)](#12-new-shared-widgets-marketplace-specific)
13. [Data Models](#13-data-models)
14. [Use Cases](#14-use-cases)
15. [Controllers](#15-controllers)
16. [Bindings](#16-bindings)
17. [Implementation Priority Order](#17-implementation-priority-order)

---

## 1. Architecture Overview — What Already Exists

### DO NOT recreate these — they already work:

| File | Purpose | Location |
|------|---------|----------|
| `AppState<T>` | Reactive state: Initial/Loading/Success/Error with `when()` pattern matching | `lib/core/states/app_state.dart` |
| `BaseStateController<T>` | Controller base with `handleState()`, `handleMultipleStates()`, `handlePaginationState()` | `lib/core/bases/base_state_controller.dart` |
| `BaseRepository<T>` | Repository base with `handleApiCall()`, `get()`, `post()`, `put()`, `delete()` | `lib/core/bases/base_repository.dart` |
| `BaseService` | HTTP service base | `lib/core/bases/base_service.dart` |
| `BaseUseCase<Input, Output, T>` | Use case base with `resultToStateWithMapping()`, `resultToState()`, `resultToPaginatedState()` | `lib/domain/usecases/base_use_case.dart` |
| `Result<T>` | Either-like: `Success<T>` / `Failure<T>` with `fold()` | `lib/core/network/result.dart` |
| `AppException` hierarchy | 15+ exception types | `lib/core/errors/exceptions.dart` |
| `StateBuilder<T>` family | `StateBuilder`, `ListStateBuilder`, `PaginatedStateBuilder`, `MultiStateBuilder`, `ConditionalStateBuilder`, `StateLoadingOverlay`, `StateErrorBanner` | `lib/core/components/feedback/state_builder.dart` |
| `BaseButton` | Button with `primary`/`secondary`/`text`/`outlined` types + `small`/`medium`/`large` sizes + loading state | `lib/core/components/buttons/base_button.dart` |
| `BaseTextField` | Text input with validation | `lib/core/components/inputs/base_text_field.dart` |
| `BaseDropdown` | Generic dropdown | `lib/core/components/inputs/base_dropdown.dart` |
| `AppScaffold` | RTL-aware scaffold | `lib/core/components/layout/app_scaffold.dart` |
| `BaseCard` | Consistent card styling | `lib/core/components/layout/base_card.dart` |
| `LoadingIndicator` | Loading spinner + message | `lib/core/components/feedback/loading_indicator.dart` |
| `BaseErrorWidget` | Error states with retry | `lib/core/components/feedback/error_widget.dart` |
| `EmptyStateWidget` | Empty list states | `lib/core/components/feedback/empty_state.dart` |
| `AppSnackbar` | Success/Error/Warning/Info snackbars | `lib/core/components/feedback/snackbar.dart` |
| `DioClient` | Dio HTTP client | `lib/core/network/dio_client.dart` |
| `StorageService` | Secure + local storage | `lib/data/services/storage_service.dart` |
| `ApiService` | HTTP request methods | `lib/data/services/api_service.dart` |
| `PaginatedResult<T>` | Pagination wrapper with `appendPage()` | `lib/domain/usecases/base_use_case.dart` |
| `PaginationInput<T>` | Pagination input with filters/page/limit | `lib/domain/usecases/base_use_case.dart` |

### Existing patterns to follow exactly:

**Controller pattern:**
```dart
class XyzController extends BaseStateController<XyzUseCase> {
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await handleState(
      'operationKey',
      () => useCase.call(input),
      onSuccess: (data, message) { /* UI side effects */ },
    );
  }
}
```

**Use case pattern:**
```dart
class XyzUseCase extends BaseUseCase<Input, Output, XyzRepository> {
  XyzUseCase(super.repository);

  @override
  Future<AppState<Output>> call(Input input) async {
    final result = await repository.someMethod(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (dto) => dto.toEntity(),
    );
  }
}
```

**Repository pattern:**
```dart
class XyzRepository extends BaseRepository<ApiService> {
  Future<Result<XyzModel>> getData() => get(
    '/endpoint',
    (json) => XyzModel.fromJson(json['data']),
  );
}
```

**Binding pattern:**
```dart
class XyzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => XyzRepository());
    Get.lazyPut(() => XyzUseCase(Get.find()));
    Get.lazyPut(() => XyzController());
  }
}
```

**UI pattern:**
```dart
StateBuilder<DataType>(
  controller: controller,
  operationKey: 'operationKey',
  onSuccess: (data, message) => buildContent(data),
)
```

---

## 2. New Dependencies to Add

Add these to `pubspec.yaml` under `dependencies:`:

```yaml
  # Marketplace — New dependencies
  cached_network_image: ^3.3.0       # Product images with caching
  shimmer: ^3.0.0                     # Skeleton loading for product cards
  smooth_page_indicator: ^1.1.0       # Banner carousel dots
  flutter_staggered_grid_view: ^0.7.0 # Product grid layout
```

Add the Inter font under `flutter:` → `fonts:`:

```yaml
  fonts:
    # ... existing Cairo, NotoSansArabic, Roboto fonts ...
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

> **Action**: Download Inter font files from Google Fonts and place in `assets/fonts/`.

---

## 3. New Folder Structure

Create these directories and files. Do NOT modify existing files unless noted.

```
lib/
├── core/
│   ├── theme/                              # ← NEW DIRECTORY
│   │   ├── marketplace_colors.dart         # Color tokens
│   │   ├── marketplace_typography.dart     # Text style tokens
│   │   ├── marketplace_spacing.dart        # Spacing + dimensions
│   │   ├── marketplace_radius.dart         # Border radius tokens
│   │   ├── marketplace_shadows.dart        # Shadow tokens
│   │   ├── marketplace_icons.dart          # Icon mapping
│   │   └── marketplace_theme.dart          # ThemeData builder
│   │
│   └── components/                         # ← ADD to existing directory
│       └── marketplace/                    # ← NEW subdirectory
│           ├── product_card.dart
│           ├── category_chip.dart
│           ├── promo_banner.dart
│           ├── star_rating.dart
│           ├── quantity_stepper.dart
│           ├── cart_item_card.dart
│           ├── price_summary.dart
│           ├── menu_list_item.dart
│           ├── review_item.dart
│           ├── seller_info_card.dart
│           ├── discount_badge.dart
│           ├── search_bar_widget.dart
│           ├── marketplace_bottom_nav.dart
│           ├── marketplace_app_bar.dart
│           ├── app_network_image.dart
│           └── loading_shimmer.dart
│
├── data/
│   ├── models/
│   │   └── marketplace/                    # ← NEW subdirectory
│   │       ├── product_model.dart
│   │       ├── category_model.dart
│   │       ├── cart_item_model.dart
│   │       ├── order_model.dart
│   │       ├── seller_model.dart
│   │       ├── review_model.dart
│   │       └── marketplace_user_model.dart
│   ├── providers/
│   │   └── remote/
│   │       ├── product_api_provider.dart    # ← NEW
│   │       ├── cart_api_provider.dart       # ← NEW
│   │       ├── order_api_provider.dart      # ← NEW
│   │       └── seller_api_provider.dart     # ← NEW
│   └── repositories/
│       ├── product_repository.dart          # ← NEW
│       ├── cart_repository.dart             # ← NEW
│       ├── marketplace_order_repository.dart # ← NEW
│       └── seller_repository.dart           # ← NEW
│
├── domain/
│   ├── entities/
│   │   └── marketplace/                    # ← NEW subdirectory
│   │       ├── product_entity.dart
│   │       ├── category_entity.dart
│   │       ├── cart_item_entity.dart
│   │       ├── order_entity.dart
│   │       ├── seller_entity.dart
│   │       └── review_entity.dart
│   ├── repositories/                       # ← ADD interfaces
│   │   ├── i_product_repository.dart
│   │   ├── i_cart_repository.dart
│   │   ├── i_order_repository.dart
│   │   └── i_seller_repository.dart
│   └── usecases/
│       ├── marketplace/                    # ← NEW subdirectory
│       │   ├── product/
│       │   │   ├── get_products_use_case.dart
│       │   │   ├── get_product_details_use_case.dart
│       │   │   └── search_products_use_case.dart
│       │   ├── cart/
│       │   │   ├── get_cart_use_case.dart
│       │   │   ├── add_to_cart_use_case.dart
│       │   │   ├── update_cart_item_use_case.dart
│       │   │   └── remove_from_cart_use_case.dart
│       │   ├── order/
│       │   │   ├── create_order_use_case.dart
│       │   │   ├── get_orders_use_case.dart
│       │   │   └── get_order_details_use_case.dart
│       │   └── seller/
│       │       ├── get_sellers_use_case.dart
│       │       └── get_seller_details_use_case.dart
│       └── mappers/
│           └── marketplace_mappers.dart    # ← NEW
│
├── presentation/
│   ├── controllers/
│   │   └── marketplace/                    # ← NEW subdirectory
│   │       ├── home_controller.dart
│   │       ├── category_controller.dart
│   │       ├── product_details_controller.dart
│   │       ├── cart_controller.dart
│   │       ├── checkout_controller.dart
│   │       ├── orders_controller.dart
│   │       ├── order_details_controller.dart
│   │       ├── sellers_controller.dart
│   │       ├── seller_profile_controller.dart
│   │       ├── reviews_controller.dart
│   │       ├── profile_controller.dart
│   │       └── main_navigation_controller.dart
│   └── pages/
│       └── marketplace/                    # ← NEW subdirectory
│           ├── main_navigation_page.dart   # Shell with BottomNav + IndexedStack
│           ├── splash/
│           │   └── marketplace_splash_page.dart
│           ├── onboarding/
│           │   └── onboarding_page.dart
│           ├── auth/
│           │   ├── marketplace_login_page.dart
│           │   ├── verify_phone_page.dart
│           │   ├── verification_page.dart
│           │   ├── complete_details_page.dart
│           │   ├── join_now_page.dart
│           │   └── bindings/
│           │       └── marketplace_auth_binding.dart
│           ├── home/
│           │   ├── home_page.dart
│           │   └── bindings/
│           │       └── home_binding.dart
│           ├── category/
│           │   ├── category_page.dart
│           │   └── bindings/
│           │       └── category_binding.dart
│           ├── product/
│           │   ├── product_details_page.dart
│           │   ├── reviews_page.dart
│           │   ├── product_sellers_page.dart
│           │   └── bindings/
│           │       └── product_binding.dart
│           ├── seller/
│           │   ├── sellers_list_page.dart
│           │   ├── seller_profile_page.dart
│           │   └── bindings/
│           │       └── seller_binding.dart
│           ├── cart/
│           │   ├── cart_page.dart
│           │   ├── checkout_page.dart
│           │   ├── add_card_page.dart
│           │   ├── order_confirmed_page.dart
│           │   └── bindings/
│           │       └── cart_binding.dart
│           ├── orders/
│           │   ├── my_orders_page.dart
│           │   ├── order_details_page.dart
│           │   ├── tracking_page.dart
│           │   ├── return_page.dart
│           │   ├── pickup_page.dart
│           │   └── bindings/
│           │       └── orders_binding.dart
│           └── account/
│               ├── profile_page.dart
│               ├── address_book_page.dart
│               ├── delivery_areas_page.dart
│               ├── help_center_page.dart
│               └── bindings/
│                   └── account_binding.dart
```

---

## 4. Design Tokens — Colors

### `lib/core/theme/marketplace_colors.dart`

```dart
import 'package:flutter/material.dart';

/// All colors extracted from the Marketplace Figma design file.
/// Figma variables: --body-text (#4A4A4A), --icon-1 (#5E5E5E), CTA (#2E5129)
abstract class MarketplaceColors {
  MarketplaceColors._();

  // ── Brand / Primary ──────────────────────────────────────
  /// Primary CTA — buttons, active tab icons, screen titles
  static const Color primary = Color(0xFF2E5129);

  /// Secondary accent — banner bg, discount badge bg, price summary bg
  static const Color secondary = Color(0xFFDDEB9D);

  // ── Neutral / Text ───────────────────────────────────────
  /// Darkest text — section headings ("New Collection"), section titles
  static const Color textPrimary = Color(0xFF101828);

  /// Body text — product names, prices, descriptions, menu items
  /// Figma variable: --body-text
  static const Color textBody = Color(0xFF4A4A4A);

  /// Secondary text — seller names, ratings, muted labels
  static const Color textSecondary = Color(0xFF898989);

  /// Description text — long-form body, slightly different gray
  static const Color textDescription = Color(0xFF969694);

  /// Muted text — placeholders, faint labels
  static const Color textMuted = Color(0xFFA2A2A2);

  // ── UI Elements ──────────────────────────────────────────
  /// Stroke/border — card borders, input borders, dividers
  static const Color stroke = Color(0xFFC1C1C1);

  /// Lighter stroke variant
  static const Color strokeLight = Color(0xFFCBCBCB);

  /// Background surface — screen bg
  static const Color surface = Color(0xFFFFFFFF);

  /// Inactive icon/label color in bottom nav
  /// Figma variable: --icon-1
  static const Color iconInactive = Color(0xFF5E5E5E);

  /// Delete button bg, cart item delete circle
  static const Color deleteBackground = Color(0xFFEAEAEA);

  /// Profile header bg rectangle
  static const Color profileHeaderBg = Color(0xFFC1C1C1);

  // ── Semantic ─────────────────────────────────────────────
  /// Link text — "Learn more" in descriptions/reviews
  static const Color link = Color(0xFF4897FF);

  /// WhatsApp FAB background
  static const Color whatsapp = Color(0xFF60D668);

  /// Status "Closed" dot
  static const Color statusClosed = Color(0xFFFF0000);

  /// Text on primary-colored surfaces
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text on secondary-colored surfaces
  static const Color onSecondary = Color(0xFF4A4A4A);
}
```

---

## 5. Design Tokens — Typography

### `lib/core/theme/marketplace_typography.dart`

```dart
import 'package:flutter/material.dart';
import 'marketplace_colors.dart';

/// Text styles from the Marketplace Figma design.
/// Font: Inter (400 Regular, 500 Medium, 600 SemiBold, 700 Bold)
abstract class MarketplaceTypography {
  MarketplaceTypography._();

  static const String fontFamily = 'Inter';

  // ── Screen Titles (24px) ─────────────────────────────────
  /// Screen titles — "Details", "My Cart", "My Order"
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.primary,
  );

  /// Product name on detail screen
  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Large price display on detail screen
  static const TextStyle priceTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  // ── Section Headings (16px) ──────────────────────────────
  /// "Category", "Popular Product" on Home
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// "Description", "Reviews & Rating", profile name, "My Account"
  static const TextStyle sectionSubheading = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );

  /// Profile menu items, body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// CTA button labels — "Add To Cart", "CheckOut"
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500,
    height: 1.4, color: MarketplaceColors.onPrimary,
  );

  /// Cart item count "3 Items", "Select All"
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textSecondary,
  );

  /// Seller name on detail, price summary labels
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textSecondary,
  );

  /// Old price with strikethrough
  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody, decoration: TextDecoration.lineThrough,
  );

  // ── Description (13px) ───────────────────────────────────
  /// Description body, banner subtitle
  static const TextStyle descriptionBody = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textSecondary,
  );

  // ── Card / Compact (12px) ────────────────────────────────
  /// Product card names, tab bar labels
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Seller name on cards, prices, location text
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Price text on product card
  static const TextStyle cardPrice = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Rating number "4.2" next to star
  static const TextStyle cardRating = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// "Add to cart" small card button text
  static const TextStyle smallButton = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.onPrimary,
  );

  /// Search placeholder, category labels
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Bottom nav active/inactive labels
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Banner title "New Collection"
  static const TextStyle bannerTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// Banner subtitle "Discount 20%..."
  static const TextStyle bannerSubtitle = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textMuted,
  );

  /// "Shop now" CTA inside banner
  static const TextStyle bannerCta = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
    color: MarketplaceColors.onPrimary,
  );

  // ── Micro (10px) ─────────────────────────────────────────
  /// Discount badge, review body, strikethrough card price
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textBody,
  );

  /// Quantity number in stepper (detail screen)
  static const TextStyle quantityNumber = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// Quantity in cart (compact)
  static const TextStyle cartQuantity = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );
}
```

---

## 6. Design Tokens — Spacing & Radius

### `lib/core/theme/marketplace_spacing.dart`

```dart
/// Spacing and dimension constants from Figma measurements.
abstract class MarketplaceSpacing {
  MarketplaceSpacing._();

  // ── Spacing scale ────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── Screen-level ─────────────────────────────────────────
  static const double screenPaddingH = 16.0;
  static const double screenTopOffset = 52.0;

  // ── Component gaps ───────────────────────────────────────
  static const double sectionGap = 16.0;
  static const double productGridGap = 16.0;
  static const double categoryGap = 16.0;
  static const double cartItemGap = 16.0;
  static const double menuItemGap = 16.0;

  // ── Component dimensions ─────────────────────────────────
  static const double bottomNavHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 28.0;
  static const double searchBarHeight = 48.0;
  static const double filterButtonSize = 48.0;

  static const double productCardWidth = 164.0;
  static const double productCardHeight = 231.0;
  static const double productImageHeight = 119.0;
  static const double bannerHeight = 146.0;
  static const double categoryChipWidth = 74.0;
  static const double categoryImageHeight = 71.0;
  static const double detailImageHeight = 314.0;

  static const double cartItemHeight = 110.0;
  static const double cartImageWidth = 100.0;
  static const double cartImageHeight = 94.0;

  static const double avatarLarge = 98.0;
  static const double avatarSmall = 50.0;
  static const double fabSize = 40.0;

  static const double sellerCardImageWidth = 90.0;
  static const double sellerCardHeight = 111.0;

  static const int productGridColumns = 2;
}
```

### `lib/core/theme/marketplace_radius.dart`

```dart
import 'package:flutter/material.dart';

/// Border radius constants from Figma design.
abstract class MarketplaceRadius {
  MarketplaceRadius._();

  // ── Raw values ───────────────────────────────────────────
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 15.0;
  static const double xl = 20.0;
  static const double xxl = 30.0;
  static const double xxxl = 32.0;
  static const double full = 100.0;

  // ── Named use-cases ──────────────────────────────────────
  static const double screen = 30.0;
  static const double bottomNav = 30.0;
  static const double card = 15.0;
  static const double cardImage = 10.0;
  static const double cartItem = 14.0;
  static const double button = 20.0;
  static const double smallButton = 15.0;
  static const double bannerCta = 10.0;
  static const double detailImage = 32.0;
  static const double stepper = 30.0;
  static const double badge = 15.0;
  static const double discountBadge = 10.0;
  static const double avatar = 100.0;
  static const double profileHeader = 30.0;

  // ── Pre-built ────────────────────────────────────────────
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius buttonBR = BorderRadius.circular(button);
  static final BorderRadius smallButtonBR = BorderRadius.circular(smallButton);
  static final BorderRadius screenBR = BorderRadius.circular(screen);
  static final BorderRadius bottomNavBR = BorderRadius.only(
    topLeft: Radius.circular(bottomNav),
    topRight: Radius.circular(bottomNav),
  );
}
```

---

## 7. Design Tokens — Shadows

### `lib/core/theme/marketplace_shadows.dart`

```dart
import 'package:flutter/material.dart';

abstract class MarketplaceShadows {
  MarketplaceShadows._();

  static const BoxShadow activeTabIcon = BoxShadow(
    color: Color(0x3D000000), blurRadius: 4.0, offset: Offset.zero,
  );

  static const BoxShadow cardElevation = BoxShadow(
    color: Color(0x14000000), blurRadius: 8.0, offset: Offset(0, 2),
  );

  static const BoxShadow bottomNav = BoxShadow(
    color: Color(0x0A000000), blurRadius: 12.0, offset: Offset(0, -2),
  );
}
```

---

## 8. Design Tokens — Icons

### `lib/core/theme/marketplace_icons.dart`

```dart
import 'package:flutter/material.dart';

/// Icon mappings from Figma Iconify → Flutter Material Icons.
/// For icons without a Material equivalent, export SVG from Figma
/// and place in assets/icons/.
abstract class MarketplaceIcons {
  MarketplaceIcons._();

  // Navigation
  static const IconData backArrow = Icons.arrow_back_ios_new_rounded;
  static const IconData forwardArrow = Icons.arrow_forward_ios_rounded;

  // Bottom Tab — inactive (outlined) / active (filled)
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData homeFilled = Icons.home_rounded;
  static const IconData categoryOutlined = Icons.grid_view_outlined;
  static const IconData categoryFilled = Icons.grid_view_rounded;
  static const IconData sellerOutlined = Icons.storefront_outlined;
  static const IconData sellerFilled = Icons.storefront_rounded;
  static const IconData cartOutlined = Icons.shopping_cart_outlined;
  static const IconData cartFilled = Icons.shopping_cart_rounded;
  static const IconData accountOutlined = Icons.person_outline_rounded;
  static const IconData accountFilled = Icons.person_rounded;

  // Actions
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData selectAll = Icons.select_all_rounded;
  static const IconData minus = Icons.remove_rounded;
  static const IconData plus = Icons.add_rounded;

  // Info
  static const IconData star = Icons.star_rounded;
  static const IconData starOutline = Icons.star_outline_rounded;
  static const IconData verified = Icons.verified_rounded;
  static const IconData location = Icons.location_on_outlined;
  static const IconData language = Icons.language_rounded;
  static const IconData helpCenter = Icons.help_outline_rounded;
  static const IconData logout = Icons.logout_rounded;

  // Profile menu
  static const IconData myOrder = Icons.shopping_bag_outlined;
  static const IconData follow = Icons.person_add_outlined;
  static const IconData payment = Icons.payment_rounded;

  // Star sizes per context
  static const double starSizeCard = 16.0;
  static const double starSizeDetail = 24.0;
  static const double starSizeReview = 16.0;
}
```

---

## 9. Theme Configuration — Marketplace Override

### `lib/core/theme/marketplace_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'marketplace_colors.dart';
import 'marketplace_typography.dart';
import 'marketplace_radius.dart';

/// Marketplace theme — replaces AppTheme.lightTheme for marketplace screens.
/// Uses Inter font (LTR), green primary, and marketplace-specific tokens.
class MarketplaceTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: MarketplaceTypography.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: MarketplaceColors.primary,
        secondary: MarketplaceColors.secondary,
        surface: MarketplaceColors.surface,
        onPrimary: MarketplaceColors.onPrimary,
        onSecondary: MarketplaceColors.onSecondary,
        outline: MarketplaceColors.stroke,
        error: Colors.red,
      ),

      scaffoldBackgroundColor: MarketplaceColors.surface,

      appBarTheme: const AppBarTheme(
        backgroundColor: MarketplaceColors.surface,
        foregroundColor: MarketplaceColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: MarketplaceTypography.screenTitle,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MarketplaceColors.primary,
          foregroundColor: MarketplaceColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
          textStyle: MarketplaceTypography.buttonLabel,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MarketplaceColors.primary,
          side: const BorderSide(color: MarketplaceColors.stroke),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MarketplaceColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: MarketplaceTypography.inputPlaceholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.primary, width: 1.5),
        ),
      ),

      cardTheme: CardTheme(
        color: MarketplaceColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: MarketplaceRadius.cardBR,
          side: const BorderSide(color: MarketplaceColors.stroke),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: MarketplaceColors.stroke, thickness: 1, space: 0,
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}
```

---

## 10. Navigation Architecture — Nested Tab Solution

### The Problem

GetX `Get.toNamed()` uses a single navigation stack. The marketplace requires 5 tabs, each with independent back stacks (e.g., Home → ProductDetails → Reviews should not affect Cart tab's stack).

### The Solution: IndexedStack + per-tab Navigator

Create a `MainNavigationPage` as the shell that wraps an `IndexedStack` of 5 `Navigator` widgets, one per tab. The `MarketplaceBottomNav` widget controls which tab is visible. Inner screens push within their tab's `Navigator`.

### `lib/presentation/controllers/marketplace/main_navigation_controller.dart`

```dart
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    if (currentIndex.value == index) {
      // If tapping same tab, pop to root of that tab
      // This requires each tab's Navigator key — handled in MainNavigationPage
    }
    currentIndex.value = index;
  }
}
```

### `lib/presentation/pages/marketplace/main_navigation_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/marketplace/marketplace_bottom_nav.dart';
import '../../../core/theme/marketplace_colors.dart';
import '../../controllers/marketplace/main_navigation_controller.dart';

// Import tab root pages
import 'home/home_page.dart';
import 'category/category_page.dart';
import 'seller/sellers_list_page.dart';
import 'cart/cart_page.dart';
import 'account/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final controller = Get.find<MainNavigationController>();

  // One GlobalKey per tab for independent navigation stacks
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  final List<Widget Function()> _tabBuilders = [
    () => const HomePage(),
    () => const CategoryPage(),
    () => const SellersListPage(),
    () => const CartPage(),
    () => const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentNav = _navigatorKeys[controller.currentIndex.value].currentState;
        if (currentNav != null && currentNav.canPop()) {
          currentNav.pop();
        }
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: List.generate(5, (i) => Navigator(
            key: _navigatorKeys[i],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => _tabBuilders[i](),
            ),
          )),
        )),
        bottomNavigationBar: Obx(() => MarketplaceBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            if (controller.currentIndex.value == index) {
              _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
            }
            controller.changePage(index);
          },
        )),
      ),
    );
  }
}
```

### Routes — Add to `lib/app/routes/app_routes.dart`

```dart
// Marketplace routes — add to existing Routes class:
static const MARKETPLACE = '/marketplace';
static const MARKETPLACE_MAIN = '/marketplace/main';
static const MARKETPLACE_ONBOARDING = '/marketplace/onboarding';
static const MARKETPLACE_LOGIN = '/marketplace/login';
static const MARKETPLACE_VERIFY = '/marketplace/verify';
static const MARKETPLACE_VERIFICATION = '/marketplace/verification';
static const MARKETPLACE_COMPLETE_DETAILS = '/marketplace/complete-details';
static const MARKETPLACE_JOIN = '/marketplace/join';
static const MARKETPLACE_PRODUCT = '/marketplace/product';
static const MARKETPLACE_REVIEWS = '/marketplace/reviews';
static const MARKETPLACE_PRODUCT_SELLERS = '/marketplace/product-sellers';
static const MARKETPLACE_SELLER = '/marketplace/seller';
static const MARKETPLACE_CHECKOUT = '/marketplace/checkout';
static const MARKETPLACE_ADD_CARD = '/marketplace/add-card';
static const MARKETPLACE_ORDER_CONFIRMED = '/marketplace/order-confirmed';
static const MARKETPLACE_ORDERS = '/marketplace/orders';
static const MARKETPLACE_ORDER_DETAILS = '/marketplace/order-details';
static const MARKETPLACE_TRACKING = '/marketplace/tracking';
static const MARKETPLACE_RETURN = '/marketplace/return';
static const MARKETPLACE_PICKUP = '/marketplace/pickup';
static const MARKETPLACE_ADDRESSES = '/marketplace/addresses';
static const MARKETPLACE_DELIVERY_AREAS = '/marketplace/delivery-areas';
static const MARKETPLACE_HELP = '/marketplace/help';
```

### Add pages to `lib/app/routes/app_pages.dart`

```dart
// Add these GetPage entries to the routes list:
GetPage(
  name: Routes.MARKETPLACE_MAIN,
  page: () => const MainNavigationPage(),
  binding: MainNavigationBinding(),
),
// ... each inner screen gets its own GetPage with binding
```

---

## 11. Screen Inventory & Routes

| # | Screen | GetX Route | Auth | Binding |
|---|--------|-----------|------|---------|
| 1 | Splash | `MARKETPLACE` | No | — |
| 2 | Join Now | `MARKETPLACE_JOIN` | No | MarketplaceAuthBinding |
| 3 | Onboarding | `MARKETPLACE_ONBOARDING` | No | — |
| 4 | Login | `MARKETPLACE_LOGIN` | No | MarketplaceAuthBinding |
| 5 | Verify Phone | `MARKETPLACE_VERIFY` | No | MarketplaceAuthBinding |
| 6 | Verification | `MARKETPLACE_VERIFICATION` | No | MarketplaceAuthBinding |
| 7 | Complete Details | `MARKETPLACE_COMPLETE_DETAILS` | No | MarketplaceAuthBinding |
| 8 | **Main Nav Shell** | `MARKETPLACE_MAIN` | Yes | MainNavigationBinding |
| 9 | Home | Tab 0 (inside shell) | Yes | HomeBinding |
| 10 | Category | Tab 1 (inside shell) | Yes | CategoryBinding |
| 11 | Sellers List | Tab 2 (inside shell) | Yes | SellerBinding |
| 12 | Cart | Tab 3 (inside shell) | Yes | CartBinding |
| 13 | Profile | Tab 4 (inside shell) | Yes | AccountBinding |
| 14 | Product Details | `MARKETPLACE_PRODUCT` | Yes | ProductBinding |
| 15 | Reviews | `MARKETPLACE_REVIEWS` | Yes | ProductBinding |
| 16 | Product Sellers | `MARKETPLACE_PRODUCT_SELLERS` | Yes | ProductBinding |
| 17 | Seller Profile | `MARKETPLACE_SELLER` | Yes | SellerBinding |
| 18 | Checkout | `MARKETPLACE_CHECKOUT` | Yes | CartBinding |
| 19 | Add Card | `MARKETPLACE_ADD_CARD` | Yes | CartBinding |
| 20 | Order Confirmed | `MARKETPLACE_ORDER_CONFIRMED` | Yes | — |
| 21 | My Orders | `MARKETPLACE_ORDERS` | Yes | OrdersBinding |
| 22 | Order Details | `MARKETPLACE_ORDER_DETAILS` | Yes | OrdersBinding |
| 23 | Tracking | `MARKETPLACE_TRACKING` | Yes | OrdersBinding |
| 24 | Return | `MARKETPLACE_RETURN` | Yes | OrdersBinding |
| 25 | Pickup | `MARKETPLACE_PICKUP` | Yes | OrdersBinding |
| 26 | Address Book | `MARKETPLACE_ADDRESSES` | Yes | AccountBinding |
| 27 | Delivery Areas | `MARKETPLACE_DELIVERY_AREAS` | Yes | AccountBinding |
| 28 | Help Center | `MARKETPLACE_HELP` | Yes | AccountBinding |

---

## 12. New Shared Widgets (Marketplace-Specific)

All placed in `lib/core/components/marketplace/`.

### 12.1 `marketplace_bottom_nav.dart`

```
Widget: MarketplaceBottomNav
Props: currentIndex (int), onTap (Function(int))
Spec:
  - Container: height 56, bg white, borderRadius top-left/right 30
  - 5 tabs: Home, Category, Seller, Cart, Account
  - Active: MarketplaceColors.primary (#2E5129), filled icon variant
  - Inactive: MarketplaceColors.iconInactive (#5E5E5E), outlined icon variant
  - Label: MarketplaceTypography.navLabel (12px Medium)
  - Shadow: MarketplaceShadows.bottomNav
```

### 12.2 `marketplace_app_bar.dart`

```
Widget: MarketplaceAppBar (implements PreferredSizeWidget)
Props: title (String), onBack (VoidCallback?)
Spec:
  - Back icon: MarketplaceIcons.backArrow, size 24, positioned left:0
  - Title: centered, MarketplaceTypography.screenTitle
  - If onBack is null, uses Get.back()
```

### 12.3 `product_card.dart`

```
Widget: ProductCard
Props: product (ProductEntity), onTap, onAddToCart
Spec:
  - Container: 164 × 231, border 1px stroke, borderRadius 15
  - Image: 148 × 119, borderRadius 10, inside padding 7
  - DiscountBadge: optional, top-right of image
  - Name: cardTitle (12px Medium)
  - Seller: cardSubtitle (12px Regular)
  - Price row: cardPrice + strikethrough micro
  - Rating: star icon 16px + cardRating "4.2"
  - Add to Cart button: 132 × 28, bg primary, radius 15, smallButton text
  - Use AppNetworkImage for product image
```

### 12.4 `category_chip.dart`

```
Widget: CategoryChip
Props: category (CategoryEntity), onTap
Spec:
  - Container: 74 wide, Column
  - Image: 74 × 71, borderRadius 15, AppNetworkImage
  - Label: cardSubtitle (12px Regular), centered
```

### 12.5 `promo_banner.dart`

```
Widget: PromoBanner
Props: title, subtitle, ctaLabel, imageUrl, onCta
Spec:
  - Container: 343 × 146, borderRadius 15, bg secondary (#DDEB9D)
  - Title: bannerTitle (16px SemiBold #101828)
  - Subtitle: bannerSubtitle (13px Regular #A2A2A2)
  - CTA: 90 × 31, bg primary, radius 10, bannerCta text
  - Image: right side, clipped
```

### 12.6 `star_rating.dart`

```
Widget: StarRating
Props: rating (double), size (double), maxStars (int = 5), showLabel (bool = false)
Spec:
  - Uses MarketplaceIcons.star / starOutline
  - Filled stars = rating.floor(), partial for fractional
  - Gap: -2px between stars
  - Label: cardRating style when showLabel is true
```

### 12.7 `quantity_stepper.dart`

```
Widget: QuantityStepper
Props: value (int), onChanged (Function(int)), variant (bordered | compact)
Spec:
  - bordered: Container border 1px stroke, radius 30, padding 8
    Row: [MinusIcon(16), gap(16), Text(quantityNumber 16px), gap(16), PlusIcon(16)]
  - compact: No border, Row: [MinusIcon(18), gap(8), Text(cartQuantity 14px), gap(8), PlusIcon(18)]
```

### 12.8 `cart_item_card.dart`

```
Widget: CartItemCard
Props: item (CartItemEntity), isSelected (bool), onSelect, onDelete, onQuantityChange
Spec:
  - Container: full-width × 110, border 1px stroke, radius 14
  - Checkbox: 16×16, outside card left
  - Image: 100×94, radius 10, left:7 top:7
  - Name/Seller/Price column
  - Delete button: 24×24 circle bg deleteBackground
  - QuantityStepper compact variant, bottom-right
```

### 12.9 `price_summary.dart`

```
Widget: PriceSummary
Props: subtotal (double), discount (double), total (double), onCheckout
Spec:
  - Container: full-width, bg secondary (#DDEB9D), padding 16
  - Sub_Total row, Discount row, dashed divider, Total Cost row
  - CheckOut button: full-width, 48h, bg primary, radius 20
```

### 12.10 `menu_list_item.dart`

```
Widget: MenuListItem
Props: icon (IconData), label (String), onTap, showDivider (bool = true)
Spec:
  - Row: [Icon(24), gap(16), Text(body 16px Regular #4A4A4A), Spacer, ForwardArrow(24)]
  - Divider: 1px stroke below, if showDivider
  - Gap between items: 16px
```

### 12.11 `review_item.dart`

```
Widget: ReviewItem
Props: review (ReviewEntity)
Spec:
  - Row: [Avatar(50 circle), Expanded(Column)]
  - Column: name(cardTitle), StarRating(16px), text(micro #898989, max 3 lines + "Learn more" link)
```

### 12.12 `seller_info_card.dart`

```
Widget: SellerInfoCard
Props: seller (SellerEntity), onFollow
Spec:
  - Container: 343 × 111, border 1px strokeLight, radius 15
  - Image: 90 × 110, radius 15
  - Name + location + rating + verified badge
  - Status dot + "Closed" text top-right
  - Follow button: bg primary, radius 15, 12px white text
```

### 12.13 `discount_badge.dart`

```
Widget: DiscountBadge
Props: percentage (int)
Spec:
  - Container: 28 × 18, bg secondary, radius 10
  - Text: "$percentage%", micro style
```

### 12.14 `search_bar_widget.dart`

```
Widget: SearchBarWidget
Props: onSearch (Function(String)), onFilter
Spec:
  - Row: gap 16
  - Search: 279 × 48, border 1px stroke, radius 15, search icon + placeholder
  - Filter: 48 × 48, border 1px stroke, radius 15, filter icon
```

### 12.15 `app_network_image.dart`

```
Widget: AppNetworkImage
Props: imageUrl (String), width, height, borderRadius, fit (BoxFit = cover)
Spec:
  - Uses CachedNetworkImage
  - placeholder: Shimmer effect matching dimensions
  - errorWidget: icon placeholder with bytesize:photo style
  - borderRadius: ClipRRect
```

### 12.16 `loading_shimmer.dart`

```
Widget: ProductCardShimmer, CartItemShimmer, BannerShimmer
Spec:
  - Uses shimmer package
  - Match exact dimensions of real components
  - Used as placeholder in StateBuilder's onLoading
```

---

## 13. Data Models

Place in `lib/data/models/marketplace/`. Each model must have:
- `fromJson(Map<String, dynamic> json)` factory
- `toJson()` method
- `toEntity()` method for domain conversion

### ProductModel fields:
`id, name, sellerName, sellerId, price, originalPrice?, discountPercent?, rating, imageUrl, imageUrls, description?, categoryId`

### CategoryModel fields:
`id, name, imageUrl`

### CartItemModel fields:
`id, productId, product (ProductModel), quantity, isSelected`

### OrderModel fields:
`id, orderNumber, status (active/completed/cancelled), items, totalAmount, createdAt, trackingInfo?`

### SellerModel fields:
`id, name, imageUrl, location?, rating, isVerified, isOpen, followerCount`

### ReviewModel fields:
`id, userName, avatarUrl, rating, text, createdAt`

### MarketplaceUserModel fields:
`id, name, phone, avatarUrl?, addresses`

### AddressModel fields:
`id, label, fullAddress, latitude?, longitude?, isDefault`

---

## 14. Use Cases

Place in `lib/domain/usecases/marketplace/`.

Each use case extends `BaseUseCase<Input, Output, Repository>` and uses `resultToStateWithMapping()` for DTO → Entity conversion.

### Product use cases:
- `GetProductsUseCase` — extends `PaginationUseCase`, fetches paginated product list
- `GetProductDetailsUseCase` — extends `BaseUseCase<String, ProductEntity>`, fetches single product
- `SearchProductsUseCase` — extends `BaseUseCase<String, List<ProductEntity>>`, search by query

### Cart use cases:
- `GetCartUseCase` — extends `NoInputUseCase<List<CartItemEntity>>`
- `AddToCartUseCase` — extends `BaseUseCase<AddToCartInput, CartItemEntity>`
- `UpdateCartItemUseCase` — extends `BaseUseCase<UpdateCartInput, CartItemEntity>`
- `RemoveFromCartUseCase` — extends `VoidUseCase<String>`

### Order use cases:
- `CreateOrderUseCase` — extends `BaseUseCase<CreateOrderInput, OrderEntity>`
- `GetOrdersUseCase` — extends `BaseUseCase<String, List<OrderEntity>>` (input = status filter)
- `GetOrderDetailsUseCase` — extends `BaseUseCase<String, OrderEntity>`

### Seller use cases:
- `GetSellersUseCase` — extends `PaginationUseCase`
- `GetSellerDetailsUseCase` — extends `BaseUseCase<String, SellerEntity>`

---

## 15. Controllers

Place in `lib/presentation/controllers/marketplace/`.

Every controller extends `BaseStateController<PrimaryUseCase>`.

### `HomeController`

```dart
class HomeController extends BaseStateController<GetProductsUseCase> {
  // Operation keys
  static const kBanners = 'banners';
  static const kCategories = 'categories';
  static const kProducts = 'products';

  // Local state
  final searchQuery = ''.obs;
  final activeBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    await handleMultipleStates({
      kCategories: () => Get.find<GetCategoriesUseCase>().execute(),
      kProducts: () => useCase.call(PaginationInput(page: 1)),
    });
  }
}
```

### `ProductDetailsController`

```dart
class ProductDetailsController extends BaseStateController<GetProductDetailsUseCase> {
  static const kProduct = 'product';
  static const kReviews = 'reviews';
  static const kSeller = 'seller';

  final quantity = 1.obs;
  final activeImageIndex = 0.obs;

  late String productId;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String;
    loadProduct();
  }

  Future<void> loadProduct() async {
    await handleState<ProductEntity>(
      kProduct,
      () => useCase.call(productId),
    );
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }
}
```

### `CartController`

```dart
class CartController extends BaseStateController<GetCartUseCase> {
  static const kCart = 'cart';
  static const kAddToCart = 'addToCart';

  final selectedIds = <String>{}.obs;
  final isSelectAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    await handleState<List<CartItemEntity>>(kCart, () => useCase.execute());
  }

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    _updateSelectAll();
  }

  void toggleSelectAll() {
    final items = getOperationData<List<CartItemEntity>>(kCart);
    if (items == null) return;
    if (isSelectAll.value) {
      selectedIds.clear();
    } else {
      selectedIds.addAll(items.map((e) => e.id));
    }
    isSelectAll.value = !isSelectAll.value;
  }

  void _updateSelectAll() {
    final items = getOperationData<List<CartItemEntity>>(kCart);
    isSelectAll.value = items != null && selectedIds.length == items.length;
  }

  double get subtotal { /* calculate from selected items */ }
  double get discount { /* calculate from selected items */ }
  double get total => subtotal - discount;
}
```

### `OrdersController`

```dart
class OrdersController extends BaseStateController<GetOrdersUseCase> {
  static const kOrders = 'orders';

  final activeTab = 'active'.obs; // 'active' | 'completed' | 'cancelled'

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    ever(activeTab, (_) => loadOrders());
  }

  Future<void> loadOrders() async {
    await handleState<List<OrderEntity>>(
      kOrders,
      () => useCase.call(activeTab.value),
    );
  }
}
```

---

## 16. Bindings

### `MainNavigationBinding`

```dart
class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavigationController());

    // Repositories — permanent so they persist across tab switches
    Get.lazyPut(() => ProductRepository(), fenix: true);
    Get.lazyPut(() => CartRepository(), fenix: true);
    Get.lazyPut(() => SellerRepository(), fenix: true);
    Get.lazyPut(() => MarketplaceOrderRepository(), fenix: true);

    // Use cases — fenix: true so they recreate when needed
    Get.lazyPut(() => GetProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetSellersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetOrdersUseCase(Get.find()), fenix: true);
  }
}
```

### Per-tab bindings follow the same pattern:

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()));
    Get.lazyPut(() => HomeController());
  }
}
```

---

## 17. Implementation Priority Order

### Phase 1 — Design Tokens (do first, no dependencies)

1. Create `lib/core/theme/marketplace_colors.dart`
2. Create `lib/core/theme/marketplace_typography.dart`
3. Create `lib/core/theme/marketplace_spacing.dart`
4. Create `lib/core/theme/marketplace_radius.dart`
5. Create `lib/core/theme/marketplace_shadows.dart`
6. Create `lib/core/theme/marketplace_icons.dart`
7. Create `lib/core/theme/marketplace_theme.dart`
8. Download and add Inter font files

### Phase 2 — Navigation Shell

9. Create `MainNavigationController`
10. Create `MarketplaceBottomNav` widget
11. Create `MarketplaceAppBar` widget
12. Create `MainNavigationPage` (IndexedStack + per-tab Navigator)
13. Add routes to `app_routes.dart` and `app_pages.dart`
14. Create `MainNavigationBinding`

### Phase 3 — Shared Marketplace Widgets

15. `app_network_image.dart` (required by all image-using widgets)
16. `loading_shimmer.dart` (required by StateBuilder onLoading)
17. `product_card.dart`
18. `category_chip.dart`
19. `promo_banner.dart`
20. `star_rating.dart`
21. `quantity_stepper.dart`
22. `cart_item_card.dart`
23. `price_summary.dart`
24. `menu_list_item.dart`
25. `discount_badge.dart`
26. `search_bar_widget.dart`
27. `review_item.dart`
28. `seller_info_card.dart`

### Phase 4 — Data Layer

29. Data models (all 8 models with `fromJson`, `toJson`, `toEntity`)
30. Domain entities (all 6 entities)
31. Repository interfaces
32. Repository implementations (extending `BaseRepository<ApiService>`)
33. Use cases (extending `BaseUseCase` / `NoInputUseCase` / `PaginationUseCase`)

### Phase 5 — Screens (in user-flow order)

34. Splash → Onboarding (3 steps) → Join Now
35. Login → Verify Phone → Verification → Complete Details
36. Home screen (with HomeController, HomeBinding)
37. Category screen
38. Product Details screen
39. Cart → Checkout → Order Confirmed
40. My Orders (3 tabs) → Order Details → Tracking
41. Profile → all sub-screens
42. Seller screens
43. Return flow, Pickup, Address Book, Delivery Areas, Help Center

---

## Figma Node ID Reference

For future Figma MCP queries (when the tool call limit resets):

| Screen | Node ID |
|--------|---------|
| Home | `97:5446` |
| Details | `112:687` |
| My Cart | `112:820` |
| Profile | `118:4719` |
| Splash | `95:3751` |
| Join Now | `95:3758` |
| Onboarding 1 | `86:3604` |
| Category | `110:186` |
| Checkout | `116:2825` |
| Sellers | `112:1304` |
| Order Confirmed | `117:3668` |
| Tracking | `118:3985` |
| My Order Active | `118:3768` |
| Address Book | `116:2982` |
| Reviews | `116:2672` |
| Login | `119:5377` |
| Verify Phone | `119:5432` |
| Verification | `119:5617` |
| Complete Details | `153:645` |
| Components Section | `119:5866` |

**Figma file key**: `NO3iZ9gUb03kQWQELYob7F`

---

*This document uses your existing `AppState<T>`, `BaseStateController`, `BaseRepository`, `BaseUseCase`, `Result<T>`, `StateBuilder<T>`, and all other core infrastructure. No existing files need modification except adding routes to `app_routes.dart` and `app_pages.dart`, and adding dependencies to `pubspec.yaml`. Start with Phase 1.*
