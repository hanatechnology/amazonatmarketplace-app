# Checkout Implementation Guide

> **For the coding agent.** Read this entirely before writing a single line of code. Follow the patterns established in the cart implementation (`CART_IMPLEMENTATION.md`) — same DTO architecture, same GetX controller conventions, same design tokens.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Design Critique & Enhancement](#2-design-critique--enhancement)
3. [Screen Layout & UX Spec](#3-screen-layout--ux-spec)
4. [Component Breakdown](#4-component-breakdown)
5. [DTOs](#5-dtos)
6. [Data Flow & State](#6-data-flow--state)
7. [API Contract](#7-api-contract)
8. [Payment Method Handling](#8-payment-method-handling)
9. [WebView Payment Flow](#9-webview-payment-flow)
10. [Success & Cancellation Screens](#10-success--cancellation-screens)
11. [Controller Implementation](#11-controller-implementation)
12. [Binding & Routes](#12-binding--routes)
13. [Localization Keys](#13-localization-keys)
14. [File Structure](#14-file-structure)
15. [Implementation Checklist](#15-implementation-checklist)

---

## 1. Architecture Overview

```
CartPage  ──(selected items + totals as CheckoutArgs)──►  CheckoutPage
                                                              │
                                            ┌─────────────────────────────────┐
                                            │        CheckoutController        │
                                            │  • loads saved addresses         │
                                            │  • holds selectedAddress (Rx)    │
                                            │  • holds selectedPayment (Rx)    │
                                            │  • calls CheckoutUseCase         │
                                            └─────────────────────────────────┘
                                                              │
                                                    ┌─────────┴──────────┐
                                                    ▼                    ▼
                                             paymentInitiation?    PAY_ON_DELIVERY
                                             checkoutUrl?          or SADAD (no URL)
                                                    │                    │
                                             ┌──────▼──────┐            │
                                             │ PaymentWebView│           │
                                             │  (WebView)   │           │
                                             └──────┬───────┘           │
                                            redirect URL matches        │
                                          success or cancel pattern     │
                                                    │                   │
                                            ┌───────▼───────────────────▼────┐
                                            │    OrderConfirmedPage           │
                                            │    OR OrderCancelledPage        │
                                            └────────────────────────────────┘
```

**Key Principles:**
- `CheckoutPage` is the only `GetView<CheckoutController>` in the file
- All sub-widgets are pure `StatelessWidget` receiving DTOs
- `Obx` lives only at the page level — one reactive wrapper per section that needs it
- Address list is fetched once on controller `onInit`
- `CheckoutArgs` is passed via `Get.arguments` from the cart

---

## 2. Design Critique & Enhancement

The following critique was applied to the standard checkout pattern to produce the enhanced design below.

### Design Critique: Checkout Screen

#### Overall Impression
A typical single-page checkout suffers from visual overload — all sections compete equally. The enhanced design uses **progressive disclosure** and **visual anchoring** so the user always knows what to do next, with the CTA always visible.

#### Usability Findings

| Finding | Severity | Recommendation |
|---------|----------|----------------|
| No empty-address state guidance | 🔴 Critical | Show an "Add new address" card with a `+` icon when no addresses exist |
| Payment method list lacks affordance | 🔴 Critical | Use large tappable radio-card rows (min 56dp tall) with brand icons |
| CTA buried below the fold | 🔴 Critical | Sticky `SafeArea` bottom bar — always visible regardless of scroll position |
| No loading state during POST | 🔴 Critical | Disable CTA + show `CircularProgressIndicator` inside button during checkout |
| No validation feedback | 🟡 Moderate | Highlight missing section (address or payment) in red before submission |
| Items section shows raw data | 🟡 Moderate | Collapsed item thumbnails row so screen isn't dominated by the order list |
| No delivery fee row | 🟡 Moderate | Reserve a delivery fee row in price summary (show "Calculated at checkout" until known) |
| Back navigation loses state | 🟢 Minor | Controller persists state across `onInit` — no refetch on back |

#### Visual Hierarchy (Enhanced Design)
- **What draws the eye first**: "Checkout" title + sticky total bottom bar — ✅ Correct
- **Reading flow**: Title → Order summary (collapsed) → Address → Payment → Price breakdown → Sticky CTA
- **Emphasis**: Selected address and selected payment method use primary-green border + green label — the right elements stand out

#### Consistency with Design System
| Element | Requirement |
|---------|-------------|
| Section headers | `MarketplaceTypography.sectionHeading` (16/600, `textPrimary`) |
| Section sub-labels | `MarketplaceTypography.bodySecondary` (16/400, `textSecondary`) |
| Cards | `BorderRadius.circular(MarketplaceRadius.card)` + `MarketplaceColors.stroke` border |
| Selected state | `MarketplaceColors.primary` border (2px) + `MarketplaceColors.secondary` background tint |
| CTA button | `MarketplaceSpacing.buttonHeight` (48dp), `MarketplaceRadius.button`, full-width |
| Screen padding | `MarketplaceSpacing.screenPaddingH` (16dp) horizontal |
| Section gap | `MarketplaceSpacing.sectionGap` (16dp) between each section |

#### Accessibility
- All tappable rows ≥ 48dp tall (WCAG AA touch target)
- Primary green `#2E5129` on white: contrast ratio 7.3:1 ✅ AAA
- Error red `#D32F2F` on white: contrast ratio 5.6:1 ✅ AA
- Selected state communicates both via color **and** a checkmark icon (not color-only)

#### What Works Well
- Existing `CartPriceSummary` widget can be reused directly
- The `MarketplaceColors.secondary` tint card style from cart provides natural visual continuity

---

## 3. Screen Layout & UX Spec

```
┌─────────────────────────────────────────────┐  ← SafeArea top
│  ← (back)    Checkout           (16px lr pad)│  ← AppBar (no elevation)
├─────────────────────────────────────────────┤
│  ┌───────────────────────────────────────┐   │
│  │  ORDER SUMMARY  (collapsible header)  │   │  ← _CheckoutOrderSummary
│  │  3 items · LYD 127.50                 │   │    collapsed by default
│  │  ▼ Show items                         │   │    tap → AnimatedContainer expand
│  │                                       │   │
│  │  [img] Product name       qty × price │   │  ← visible only when expanded
│  │  [img] Product name       qty × price │   │
│  └───────────────────────────────────────┘   │
│                                               │
│  ┌───────────────────────────────────────┐   │
│  │  DELIVERY ADDRESS                     │   │  ← _CheckoutAddressSection
│  │                                       │   │
│  │  ┌─────────────────────────────────┐  │   │  ← tappable address card
│  │  │ ● Home                     ✓   │  │   │    selected = green border
│  │  │ 123 Al-Jamahiriya St, Tripoli  │  │   │
│  │  └─────────────────────────────────┘  │   │
│  │  ┌─────────────────────────────────┐  │   │
│  │  │   Work                          │  │   │
│  │  │ 45 Omar Al-Mukhtar, Benghazi   │  │   │
│  │  └─────────────────────────────────┘  │   │
│  │  ┌─────────────────────────────────┐  │   │  ← "Add new address" card
│  │  │  +  Add new address             │  │   │    navigates to addresses flow
│  │  └─────────────────────────────────┘  │   │
│  └───────────────────────────────────────┘   │
│                                               │
│  ┌───────────────────────────────────────┐   │
│  │  PAYMENT METHOD                       │   │  ← _CheckoutPaymentSection
│  │                                       │   │
│  │  ┌──────────────────────────────┐     │   │  ← payment method radio card
│  │  │ [icon]  Cash on Delivery  ✓ │     │   │    selected = green border + bg
│  │  └──────────────────────────────┘     │   │
│  │  ┌──────────────────────────────┐     │   │
│  │  │ [icon]  SADAD               │     │   │
│  │  └──────────────────────────────┘     │   │
│  │  ┌──────────────────────────────┐     │   │
│  │  │ [icon]  PayPal              │     │   │
│  │  └──────────────────────────────┘     │   │
│  │  ┌──────────────────────────────┐     │   │
│  │  │ [icon]  Stripe              │     │   │
│  │  └──────────────────────────────┘     │   │
│  │  ┌──────────────────────────────┐     │   │
│  │  │ [icon]  PLUTU               │     │   │
│  │  └──────────────────────────────┘     │   │
│  └───────────────────────────────────────┘   │
│                                               │
│  ┌───────────────────────────────────────┐   │
│  │  ORDER TOTAL                          │   │  ← CartPriceSummary (reused)
│  │  Subtotal               LYD 100.00   │   │
│  │  Discount                -LYD 10.00  │   │
│  │  ─────────────────────────────────── │   │
│  │  Total                  LYD 90.00    │   │
│  └───────────────────────────────────────┘   │
│                                               │
│  (bottom padding for sticky bar)             │
├─────────────────────────────────────────────┤
│  ┌───────────────────────────────────────┐   │  ← Sticky bottom bar
│  │   Place Order · LYD 90.00             │   │    SafeArea + white bg + top shadow
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

### State Variations

| State | Behavior |
|-------|----------|
| Loading addresses | `_AddressShimmer` × 2 placeholder cards |
| No saved addresses | Single "Add new address" card only |
| No address selected | Address section header turns red, validation message shown |
| No payment selected | Payment section header turns red on submit attempt |
| Submitting | CTA becomes `SizedBox(24×24, CircularProgressIndicator)` + disabled |
| API error | `SnackBar` with error message + CTA re-enabled |
| WebView payment | Push `PaymentWebViewPage` with `checkoutUrl` |
| Success | Replace entire stack with `OrderConfirmedPage` |
| Cancelled | Pop back to `CheckoutPage` + show cancellation `SnackBar` |

---

## 4. Component Breakdown

### Components (all pure `StatelessWidget` + DTO)

```
lib/core/components/marketplace/checkout/
├── checkout_section_header.dart         ← reusable section label + optional validation error
├── checkout_order_summary.dart          ← collapsible items list with AnimatedContainer
├── checkout_order_item_row.dart         ← single item: thumbnail + name + qty × price
├── checkout_address_section.dart        ← address cards list + add-address card
├── checkout_address_card.dart           ← single address card with selected state
├── checkout_payment_section.dart        ← payment method radio cards
├── checkout_payment_card.dart           ← single payment method row
└── checkout_bottom_bar.dart             ← sticky CTA bar with total price
```

### Pages

```
lib/presentation/pages/marketplace/checkout/
├── checkout_page.dart                   ← GetView<CheckoutController>
├── payment_webview_page.dart            ← WebView for online payment URLs
├── order_confirmed_page.dart            ← success screen
├── order_cancelled_page.dart            ← cancellation/failure screen
└── bindings/
    └── checkout_binding.dart
```

---

## 5. DTOs

### CheckoutArgs (passed from CartPage via Get.arguments)

```dart
class CheckoutArgs {
  const CheckoutArgs({
    required this.items,
    required this.subtotal,
    required this.discount,
  });

  /// Items to be submitted to the checkout API.
  final List<CheckoutItemRecord> items;

  /// Pre-calculated subtotal for display (sum of lineTotal for selected items).
  final double subtotal;

  /// Pre-calculated discount for display (sum of lineSaving for selected items).
  final double discount;

  double get total => subtotal - discount;
}

/// Immutable record type — one item in the checkout payload.
typedef CheckoutItemRecord = ({int productId, int quantity});
```

### CheckoutSectionHeaderDto

```dart
class CheckoutSectionHeaderDto {
  const CheckoutSectionHeaderDto({
    required this.title,
    this.hasError = false,
    this.errorMessage,
  });

  final String title;
  final bool hasError;
  final String? errorMessage;
}
```

### CheckoutOrderSummaryDto

```dart
class CheckoutOrderSummaryDto {
  const CheckoutOrderSummaryDto({
    required this.items,
    required this.subtotal,
    this.isExpanded = false,
    required this.onToggle,
  });

  final List<CheckoutOrderItemDto> items;
  final double subtotal;
  final bool isExpanded;
  final VoidCallback onToggle;
}

class CheckoutOrderItemDto {
  const CheckoutOrderItemDto({
    required this.imageUrl,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String imageUrl;
  final String name;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}
```

### CheckoutAddressSectionDto

```dart
class CheckoutAddressSectionDto {
  const CheckoutAddressSectionDto({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onAddNew,
    this.hasError = false,
  });

  final List<CheckoutAddressDto> addresses;
  final int? selectedAddressId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddNew;
  final bool hasError;
}

class CheckoutAddressDto {
  const CheckoutAddressDto({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
  });

  final int id;
  final String label;   // "Home", "Work", etc.
  final String street;
  final String city;
}
```

### CheckoutPaymentSectionDto

```dart
class CheckoutPaymentSectionDto {
  const CheckoutPaymentSectionDto({
    required this.selectedMethod,
    required this.onSelect,
    this.hasError = false,
  });

  final CheckoutPaymentMethod? selectedMethod;
  final ValueChanged<CheckoutPaymentMethod> onSelect;
  final bool hasError;
}

enum CheckoutPaymentMethod {
  payOnDelivery,
  sadad,
  paypal,
  stripe,
  plutu;

  String get apiValue => switch (this) {
    payOnDelivery => 'PAY_ON_DELIVERY',
    sadad         => 'SADAD',
    paypal        => 'PAYPAL',
    stripe        => 'STRIPE',
    plutu         => 'PLUTU',
  };

  String get displayName => switch (this) {
    payOnDelivery => 'Cash on Delivery',
    sadad         => 'SADAD',
    paypal        => 'PayPal',
    stripe        => 'Stripe',
    plutu         => 'PLUTU',
  };

  /// Icon asset path — place SVG/PNG assets in assets/icons/payment/
  String get iconAsset => switch (this) {
    payOnDelivery => 'assets/icons/payment/cash.svg',
    sadad         => 'assets/icons/payment/sadad.svg',
    paypal        => 'assets/icons/payment/paypal.svg',
    stripe        => 'assets/icons/payment/stripe.svg',
    plutu         => 'assets/icons/payment/plutu.svg',
  };

  /// Whether this method requires opening a WebView for payment.
  bool get requiresWebView => switch (this) {
    paypal  => true,
    stripe  => true,
    plutu   => true,
    sadad   => true,
    _       => false,
  };
}
```

### CheckoutBottomBarDto

```dart
class CheckoutBottomBarDto {
  const CheckoutBottomBarDto({
    required this.total,
    required this.isLoading,
    required this.isEnabled,
    required this.onPlaceOrder,
  });

  final double total;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPlaceOrder;
}
```

### PaymentWebViewArgs

```dart
class PaymentWebViewArgs {
  const PaymentWebViewArgs({
    required this.checkoutUrl,
    required this.successUrlPattern,
    required this.cancelUrlPattern,
  });

  final String checkoutUrl;

  /// Partial URL to match for detecting successful redirect.
  /// Example: '/payment/success' or 'order-confirmed'
  final String successUrlPattern;

  /// Partial URL to match for detecting cancelled/failed redirect.
  final String cancelUrlPattern;
}
```

---

## 6. Data Flow & State

### Arguments from Cart

In `CartController.checkout()`, after building the items list, navigate to checkout:

```dart
// In CartController
void navigateToCheckout() {
  final selected = items.where((i) => i.isSelected).toList();
  if (selected.isEmpty) return;

  final args = CheckoutArgs(
    items: selected
        .map((i) => (productId: i.productId, quantity: i.quantity))
        .toList(),
    subtotal: selectedSubtotal,
    discount: selectedDiscount,
  );

  Get.toNamed(Routes.MARKETPLACE_CHECKOUT, arguments: args);
}
```

### CheckoutController Reactive State

```dart
// Core reactive state
final Rx<CheckoutArgs?> args = Rx(null);           // parsed from Get.arguments
final RxList<CheckoutAddressDto> addresses = <CheckoutAddressDto>[].obs;
final Rx<int?> selectedAddressId = Rx(null);
final Rx<CheckoutPaymentMethod?> selectedPayment = Rx(null);
final RxBool isLoadingAddresses = false.obs;
final RxBool isCheckingOut = false.obs;
final RxBool isOrderSummaryExpanded = false.obs;

// Validation error flags (set to true on failed submit attempt)
final RxBool addressError = false.obs;
final RxBool paymentError = false.obs;
```

### onInit

```dart
@override
void onInit() {
  super.onInit();
  args.value = Get.arguments as CheckoutArgs?;
  _loadAddresses();
}

Future<void> _loadAddresses() async {
  isLoadingAddresses.value = true;
  // Use GetAddressesUseCase (you'll implement this separately)
  // For now stub as empty — agent should wire real use case when available
  isLoadingAddresses.value = false;
}
```

---

## 7. API Contract

### Endpoint

```
POST {{baseUrl}}/client/api/v1/orders/checkout
Authorization: Bearer <token>
Content-Type: application/json
```

### Request Body

```json
{
  "items": [
    { "product_id": 12, "quantity": 2 },
    { "product_id": 7,  "quantity": 1 }
  ],
  "address_id": 3,
  "payment_method": "PAY_ON_DELIVERY"
}
```

Allowed `payment_method` values: `PLUTU` | `SADAD` | `PAYPAL` | `STRIPE` | `PAY_ON_DELIVERY`

### Response — 200 OK

```json
{
  "data": {
    "order": {
      "id": 1042,
      "status": "PENDING",
      "total": 90.00,
      "created_at": "2026-03-20T10:00:00Z"
    },
    "paymentInitiation": {
      "checkoutUrl": "https://payment-gateway.com/pay/abc123",
      "successRedirectUrl": "https://yourapp.com/payment/success",
      "cancelRedirectUrl": "https://yourapp.com/payment/cancel"
    }
  }
}
```

`paymentInitiation` is `null` for `PAY_ON_DELIVERY`. For online payment methods it contains `checkoutUrl` and optionally redirect URL patterns.

### Response — 422 Unprocessable Entity

```json
{
  "message": "Some items are out of stock",
  "errors": {
    "items.0.product_id": ["Product is no longer available"]
  }
}
```

### Response — 401 / 403

Token expired or unauthorized — redirect to login via global interceptor.

### Entity Models

```dart
class CheckoutResultEntity {
  const CheckoutResultEntity({
    required this.order,
    this.paymentInitiation,
  });

  final OrderSummaryEntity order;
  final PaymentInitiationEntity? paymentInitiation;
}

class OrderSummaryEntity {
  const OrderSummaryEntity({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  final int id;
  final String status;
  final double total;
  final DateTime createdAt;
}

class PaymentInitiationEntity {
  const PaymentInitiationEntity({
    required this.checkoutUrl,
    this.successRedirectUrl,
    this.cancelRedirectUrl,
  });

  final String checkoutUrl;
  final String? successRedirectUrl;
  final String? cancelRedirectUrl;
}
```

### CheckoutRequest Model

```dart
class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.addressId,
    required this.paymentMethod,
  });

  final List<CheckoutItemRequest> items;
  final int addressId;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'address_id': addressId,
    'payment_method': paymentMethod,
  };
}

class CheckoutItemRequest {
  const CheckoutItemRequest({
    required this.productId,
    required this.quantity,
  });

  final int productId;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}
```

---

## 8. Payment Method Handling

### Display Order

Always render in this order for UX consistency:

1. Cash on Delivery (`PAY_ON_DELIVERY`) — most familiar, shown first
2. SADAD
3. PayPal
4. Stripe
5. PLUTU

### Payment Card Design

Each payment card is a tappable row with:

```
┌──────────────────────────────────────────────────────┐
│  [icon 32×32]   Payment Method Name             [●]  │  ← 56dp min height
└──────────────────────────────────────────────────────┘
```

**Selected state:**
- Border: `2px solid MarketplaceColors.primary`
- Background: `MarketplaceColors.secondary.withOpacity(0.2)`
- Trailing icon: `Icons.check_circle_rounded` in `MarketplaceColors.primary`

**Unselected state:**
- Border: `1px solid MarketplaceColors.stroke`
- Background: `MarketplaceColors.surface`
- Trailing icon: `Icons.radio_button_unchecked` in `MarketplaceColors.stroke`

---

## 9. WebView Payment Flow

### Page: `PaymentWebViewPage`

```dart
/// Arguments via Get.arguments: PaymentWebViewArgs
class PaymentWebViewPage extends GetView<PaymentWebViewController> {
  // AppBar: "Complete Payment" + back button
  // Body: WebViewWidget(controller: controller.webViewController)
  // Loading overlay: LinearProgressIndicator at top while page loads
}
```

### PaymentWebViewController

```dart
class PaymentWebViewController extends GetxController {
  late final WebViewController webViewController;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as PaymentWebViewArgs;

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => isLoading.value = true,
        onPageFinished: (_) => isLoading.value = false,
        onNavigationRequest: (request) {
          final url = request.url;

          if (url.contains(args.successUrlPattern)) {
            // Pop WebView + signal success
            Get.back(result: PaymentWebViewResult.success);
            return NavigationDecision.prevent;
          }

          if (url.contains(args.cancelUrlPattern)) {
            Get.back(result: PaymentWebViewResult.cancelled);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(args.checkoutUrl));
  }
}

enum PaymentWebViewResult { success, cancelled }
```

### Redirect URL Patterns

Default patterns to detect (configure in `CheckoutController`):

| Scenario | URL Pattern to Match |
|----------|---------------------|
| Success | `payment/success` or `order-confirmed` |
| Cancel | `payment/cancel` or `payment/failed` |

If `successRedirectUrl` is returned by the API, extract its path segment for matching. Otherwise fall back to the defaults above.

### Handling WebView Result in CheckoutController

```dart
Future<void> _openPaymentWebView(PaymentInitiationEntity initiation) async {
  final result = await Get.toNamed(
    Routes.MARKETPLACE_PAYMENT_WEBVIEW,
    arguments: PaymentWebViewArgs(
      checkoutUrl: initiation.checkoutUrl,
      successUrlPattern: _extractPattern(initiation.successRedirectUrl) ?? 'payment/success',
      cancelUrlPattern: _extractPattern(initiation.cancelRedirectUrl) ?? 'payment/cancel',
    ),
  );

  if (result == PaymentWebViewResult.success) {
    _navigateToConfirmed();
  } else {
    // Cancelled — stay on checkout, show snackbar
    Get.snackbar(
      LocaleKeys.paymentCancelled.tr,
      LocaleKeys.paymentCancelledMessage.tr,
      backgroundColor: const Color(0xFFFFF3E0),
      colorText: const Color(0xFFE65100),
    );
  }
}

String? _extractPattern(String? fullUrl) {
  if (fullUrl == null) return null;
  final uri = Uri.tryParse(fullUrl);
  return uri?.path;
}
```

---

## 10. Success & Cancellation Screens

### OrderConfirmedPage

**Route:** `Routes.MARKETPLACE_ORDER_CONFIRMED`

**Layout:**

```
┌──────────────────────────────────┐
│                                  │
│   ┌──────────────────────────┐   │
│   │   ✅ (Lottie animation)   │   │  ← green checkmark Lottie or Icon
│   └──────────────────────────┘   │
│                                  │
│   Order Confirmed! 🎉            │  ← sectionHeading, centered
│   Your order #1042 is on its way │  ← descriptionBody, centered
│                                  │
│   ┌──────────────────────────┐   │
│   │ Order ID        #1042    │   │  ← summary rows
│   │ Payment         COD      │   │
│   │ Total           LYD 90   │   │
│   └──────────────────────────┘   │
│                                  │
│   ┌──────────────────────────┐   │
│   │    Track My Order        │   │  ← primary button
│   └──────────────────────────┘   │
│   ┌──────────────────────────┐   │
│   │    Continue Shopping     │   │  ← outlined/text button
│   └──────────────────────────┘   │
└──────────────────────────────────┘
```

**Navigation:** Clears the back stack back to main — use `Get.offAllNamed(Routes.MARKETPLACE_MAIN)` then push order details, or `Get.offNamed(Routes.MARKETPLACE_ORDER_DETAILS, arguments: orderId)`. This prevents the user from going "Back" into the checkout flow.

**Passed arguments:** `OrderConfirmedArgs(orderId, paymentMethod, total)`

### OrderCancelledPage (optional separate page)

Only navigate here for hard failures (non-recoverable). For soft cancellations (user clicked back in WebView), stay on `CheckoutPage` and show a `SnackBar` instead — less disruptive.

---

## 11. Controller Implementation

```dart
class CheckoutController extends GetxController {
  CheckoutController({
    required this.checkoutUseCase,
    // inject GetAddressesUseCase when ready
  });

  final CheckoutUseCase checkoutUseCase;

  // ── State ─────────────────────────────────────────────────
  late final CheckoutArgs checkoutArgs;
  final RxList<CheckoutAddressDto> addresses = <CheckoutAddressDto>[].obs;
  final Rx<int?> selectedAddressId = Rx(null);
  final Rx<CheckoutPaymentMethod?> selectedPayment = Rx(null);
  final RxBool isLoadingAddresses = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool isSummaryExpanded = false.obs;
  final RxBool addressError = false.obs;
  final RxBool paymentError = false.obs;

  // ── Computed ──────────────────────────────────────────────
  bool get canPlaceOrder =>
      selectedAddressId.value != null && selectedPayment.value != null;

  double get total => checkoutArgs.total;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    checkoutArgs = Get.arguments as CheckoutArgs;
    _loadAddresses();
  }

  // ── Actions ───────────────────────────────────────────────
  void selectAddress(int id) {
    selectedAddressId.value = id;
    addressError.value = false;
  }

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    selectedPayment.value = method;
    paymentError.value = false;
  }

  void toggleSummary() => isSummaryExpanded.toggle();

  void navigateToAddAddress() {
    Get.toNamed(Routes.MARKETPLACE_ADDRESSES)?.then((_) => _loadAddresses());
  }

  Future<void> placeOrder() async {
    // Validate
    bool valid = true;
    if (selectedAddressId.value == null) {
      addressError.value = true;
      valid = false;
    }
    if (selectedPayment.value == null) {
      paymentError.value = true;
      valid = false;
    }
    if (!valid) return;

    isCheckingOut.value = true;

    final request = CheckoutRequest(
      items: checkoutArgs.items
          .map((i) => CheckoutItemRequest(
                productId: i.productId,
                quantity: i.quantity,
              ))
          .toList(),
      addressId: selectedAddressId.value!,
      paymentMethod: selectedPayment.value!.apiValue,
    );

    final result = await checkoutUseCase(request);

    result.when(
      success: (data) async {
        isCheckingOut.value = false;
        final paymentInit = data.paymentInitiation;

        if (paymentInit != null && selectedPayment.value!.requiresWebView) {
          await _openPaymentWebView(paymentInit);
        } else {
          _navigateToConfirmed(data.order);
        }
      },
      failure: (error) {
        isCheckingOut.value = false;
        Get.snackbar(
          LocaleKeys.error.tr,
          error.message ?? LocaleKeys.genericError.tr,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFD32F2F),
        );
      },
    );
  }

  // ── Private ───────────────────────────────────────────────
  Future<void> _loadAddresses() async {
    isLoadingAddresses.value = true;
    // TODO: wire GetAddressesUseCase — stub empty for now
    // final result = await getAddressesUseCase();
    // result.when(success: (list) => addresses.assignAll(...), failure: (_) {});
    isLoadingAddresses.value = false;
  }

  Future<void> _openPaymentWebView(PaymentInitiationEntity initiation) async {
    final result = await Get.toNamed(
      Routes.MARKETPLACE_PAYMENT_WEBVIEW,
      arguments: PaymentWebViewArgs(
        checkoutUrl: initiation.checkoutUrl,
        successUrlPattern:
            _extractPattern(initiation.successRedirectUrl) ?? 'payment/success',
        cancelUrlPattern:
            _extractPattern(initiation.cancelRedirectUrl) ?? 'payment/cancel',
      ),
    );

    if (result == PaymentWebViewResult.success) {
      // result is void here — navigate to confirmed with stored order
      _navigateToConfirmed(null);
    } else {
      Get.snackbar(
        LocaleKeys.paymentCancelled.tr,
        LocaleKeys.paymentCancelledMessage.tr,
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: const Color(0xFFE65100),
      );
    }
  }

  void _navigateToConfirmed(OrderSummaryEntity? order) {
    Get.offAllNamed(
      Routes.MARKETPLACE_ORDER_CONFIRMED,
      arguments: OrderConfirmedArgs(
        orderId: order?.id,
        total: total,
        paymentMethod: selectedPayment.value!.displayName,
      ),
    );
  }

  String? _extractPattern(String? fullUrl) {
    if (fullUrl == null) return null;
    return Uri.tryParse(fullUrl)?.path;
  }
}

class OrderConfirmedArgs {
  const OrderConfirmedArgs({
    this.orderId,
    required this.total,
    required this.paymentMethod,
  });

  final int? orderId;
  final double total;
  final String paymentMethod;
}
```

---

## 12. Binding & Routes

### CheckoutBinding

```dart
// lib/presentation/pages/marketplace/checkout/bindings/checkout_binding.dart

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutRepository>(
      () => CheckoutRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<CheckoutUseCase>(
      () => CheckoutUseCase(Get.find<CheckoutRepository>()),
    );
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(
        checkoutUseCase: Get.find<CheckoutUseCase>(),
      ),
    );
  }
}
```

### PaymentWebViewBinding

```dart
class PaymentWebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentWebViewController>(() => PaymentWebViewController());
  }
}
```

### Routes to Add

Add to `app_routes.dart` if not already present:

```dart
static const MARKETPLACE_PAYMENT_WEBVIEW = '/marketplace/payment-webview';
static const MARKETPLACE_ORDER_CANCELLED  = '/marketplace/order-cancelled';
```

Add to `app_pages.dart`:

```dart
GetPage(
  name: Routes.MARKETPLACE_CHECKOUT,
  page: () => const CheckoutPage(),
  binding: CheckoutBinding(),
),
GetPage(
  name: Routes.MARKETPLACE_PAYMENT_WEBVIEW,
  page: () => const PaymentWebViewPage(),
  binding: PaymentWebViewBinding(),
),
GetPage(
  name: Routes.MARKETPLACE_ORDER_CONFIRMED,
  page: () => const OrderConfirmedPage(),
),
GetPage(
  name: Routes.MARKETPLACE_ORDER_CANCELLED,
  page: () => const OrderCancelledPage(),
),
```

### Pubspec Dependency

Add `webview_flutter` if not already present:

```yaml
dependencies:
  webview_flutter: ^4.7.0
```

---

## 13. Localization Keys

Add to `locale_keys.dart`:

```dart
static const checkout             = 'checkout';
static const deliveryAddress      = 'delivery_address';
static const paymentMethod        = 'payment_method';
static const orderSummary         = 'order_summary';
static const placeOrder           = 'place_order';
static const addNewAddress        = 'add_new_address';
static const completePayment      = 'complete_payment';
static const selectAddress        = 'select_address';
static const selectPayment        = 'select_payment';
static const paymentCancelled     = 'payment_cancelled';
static const paymentCancelledMsg  = 'payment_cancelled_message';
static const orderConfirmed       = 'order_confirmed';
static const orderOnItsWay        = 'order_on_its_way';
static const trackMyOrder         = 'track_my_order';
static const continueShopping     = 'continue_shopping';
static const showItems            = 'show_items';
static const hideItems            = 'hide_items';
static const cashOnDelivery       = 'cash_on_delivery';
static const genericError         = 'generic_error';
```

Add to `en.dart`:

```dart
'checkout':                  'Checkout',
'delivery_address':          'Delivery Address',
'payment_method':            'Payment Method',
'order_summary':             'Order Summary',
'place_order':               'Place Order',
'add_new_address':           'Add new address',
'complete_payment':          'Complete Payment',
'select_address':            'Please select a delivery address',
'select_payment':            'Please select a payment method',
'payment_cancelled':         'Payment Cancelled',
'payment_cancelled_message': 'Your payment was not completed. You can try again.',
'order_confirmed':           'Order Confirmed!',
'order_on_its_way':          'Your order is on its way.',
'track_my_order':            'Track My Order',
'continue_shopping':         'Continue Shopping',
'show_items':                'Show items',
'hide_items':                'Hide items',
'cash_on_delivery':          'Cash on Delivery',
'generic_error':             'Something went wrong. Please try again.',
```

Add to `ar.dart`:

```dart
'checkout':                  'الدفع',
'delivery_address':          'عنوان التوصيل',
'payment_method':            'طريقة الدفع',
'order_summary':             'ملخص الطلب',
'place_order':               'تأكيد الطلب',
'add_new_address':           'إضافة عنوان جديد',
'complete_payment':          'إتمام الدفع',
'select_address':            'يرجى اختيار عنوان التوصيل',
'select_payment':            'يرجى اختيار طريقة الدفع',
'payment_cancelled':         'تم إلغاء الدفع',
'payment_cancelled_message': 'لم يتم إكمال عملية الدفع. يمكنك المحاولة مرة أخرى.',
'order_confirmed':           'تم تأكيد الطلب!',
'order_on_its_way':          'طلبك في الطريق إليك.',
'track_my_order':            'تتبع طلبي',
'continue_shopping':         'متابعة التسوق',
'show_items':                'عرض المنتجات',
'hide_items':                'إخفاء المنتجات',
'cash_on_delivery':          'الدفع عند الاستلام',
'generic_error':             'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
```

---

## 14. File Structure

```
lib/
├── core/
│   ├── components/marketplace/checkout/
│   │   ├── checkout_section_header.dart
│   │   ├── checkout_order_summary.dart
│   │   ├── checkout_order_item_row.dart
│   │   ├── checkout_address_section.dart
│   │   ├── checkout_address_card.dart
│   │   ├── checkout_payment_section.dart
│   │   ├── checkout_payment_card.dart
│   │   └── checkout_bottom_bar.dart
│   └── localization/
│       ├── locale_keys.dart           ← add checkout keys
│       ├── en.dart                    ← add English strings
│       └── ar.dart                    ← add Arabic strings
│
├── domain/
│   ├── entities/
│   │   ├── checkout_result_entity.dart
│   │   ├── order_summary_entity.dart
│   │   └── payment_initiation_entity.dart
│   └── usecases/marketplace/
│       └── checkout_usecase.dart      ← already stubbed in cart_binding
│
├── data/
│   ├── models/
│   │   ├── checkout_request.dart
│   │   └── checkout_response.dart
│   └── repositories/
│       └── checkout_repository.dart   ← already registered in cart_binding
│
└── presentation/
    ├── controllers/marketplace/
    │   ├── checkout_controller.dart
    │   └── payment_webview_controller.dart
    └── pages/marketplace/checkout/
        ├── checkout_page.dart
        ├── payment_webview_page.dart
        ├── order_confirmed_page.dart
        ├── order_cancelled_page.dart
        └── bindings/
            ├── checkout_binding.dart
            └── payment_webview_binding.dart
```

---

## 15. Implementation Checklist

### Domain Layer
- [ ] Create `CheckoutResultEntity`, `OrderSummaryEntity`, `PaymentInitiationEntity`
- [ ] Create `CheckoutUseCase` (replace stub) — takes `CheckoutRequest`, returns `AppState<CheckoutResultEntity>`
- [ ] Create `CheckoutRepository` with `checkout(CheckoutRequest)` method

### Data Layer
- [ ] Create `CheckoutRequest` + `CheckoutItemRequest` with `toJson()`
- [ ] Create `CheckoutResponseModel` (parse API 200 response)
- [ ] Parse `paymentInitiation` as nullable in response model
- [ ] Handle 422 errors — extract first error message for display

### DTOs
- [ ] `CheckoutArgs` + `CheckoutItemRecord` typedef
- [ ] `CheckoutOrderSummaryDto` + `CheckoutOrderItemDto`
- [ ] `CheckoutAddressSectionDto` + `CheckoutAddressDto`
- [ ] `CheckoutPaymentSectionDto`
- [ ] `CheckoutPaymentMethod` enum with `apiValue`, `displayName`, `iconAsset`, `requiresWebView`
- [ ] `CheckoutBottomBarDto`
- [ ] `PaymentWebViewArgs`
- [ ] `OrderConfirmedArgs`

### Components
- [ ] `CheckoutSectionHeader` — title + optional red error label below
- [ ] `CheckoutOrderSummary` — collapsible via `AnimatedContainer` (duration 250ms, curve `easeInOut`)
- [ ] `CheckoutOrderItemRow` — thumbnail (40×40, radius 8) + name (max 2 lines) + qty × price
- [ ] `CheckoutAddressSection` — maps addresses + "Add new" card
- [ ] `CheckoutAddressCard` — selected = green border + bg tint + checkmark; unselected = stroke border
- [ ] `CheckoutPaymentSection` — renders all 5 payment method cards in order
- [ ] `CheckoutPaymentCard` — icon (32×32) + name + selected indicator
- [ ] `CheckoutBottomBar` — `SafeArea` + white bg + top shadow + full-width CTA

### Pages & Controllers
- [ ] `CheckoutController` — full implementation per section 11
- [ ] `CheckoutPage` — single `GetView`; `Obx` wraps each section; `CustomScrollView` with `SliverList`
- [ ] `PaymentWebViewController` — webview setup + redirect detection
- [ ] `PaymentWebViewPage` — `WebViewWidget` + `LinearProgressIndicator` overlay
- [ ] `OrderConfirmedPage` — success animation + order summary rows + two CTA buttons
- [ ] `OrderCancelledPage` (optional) — error state + retry / go home buttons

### Bindings & Routes
- [ ] `CheckoutBinding` — register `CheckoutRepository`, `CheckoutUseCase`, `CheckoutController`
- [ ] `PaymentWebViewBinding`
- [ ] Add `MARKETPLACE_PAYMENT_WEBVIEW` to `app_routes.dart`
- [ ] Register all 4 new `GetPage` entries in `app_pages.dart`
- [ ] Add `webview_flutter: ^4.7.0` to `pubspec.yaml`

### Cart Integration
- [ ] Change `CartController.checkout()` to call `navigateToCheckout()` instead of posting directly
- [ ] Pass `CheckoutArgs` via `Get.arguments`

### Localization
- [ ] Add all keys to `locale_keys.dart`
- [ ] Add English translations to `en.dart`
- [ ] Add Arabic translations to `ar.dart`

### Payment Assets
- [ ] Add payment icons to `assets/icons/payment/` (SVG preferred)
  - `cash.svg`, `sadad.svg`, `paypal.svg`, `stripe.svg`, `plutu.svg`
- [ ] Register in `pubspec.yaml` under `flutter.assets`

### QA & Edge Cases
- [ ] Verify back-navigation from WebView does NOT submit the order
- [ ] Test 422 response: correct error message shown, CTA re-enabled
- [ ] Test `PAY_ON_DELIVERY` skips WebView and goes directly to confirmed
- [ ] Test `offAllNamed` clears checkout + cart from back stack on success
- [ ] Test Arabic locale — RTL layout for address cards and payment rows
- [ ] Verify `SafeArea` on bottom bar handles iPhone notch and Android nav bar
