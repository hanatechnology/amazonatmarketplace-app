# Cart — Implementation Guide

> **Strategy:** Cart lives entirely on the device (SharedPreferences). Every add / remove / quantity change is a local write. The server is only touched once — at checkout — where the selected items are posted to the checkout API. The server never owns the cart; the phone does.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Local Storage Schema](#2-local-storage-schema)
3. [Data Layer](#3-data-layer)
4. [Domain Layer](#4-domain-layer)
5. [Controller](#5-controller)
6. [UI Design Specs](#6-ui-design-specs)
7. [Component Specs](#7-component-specs)
8. [Checkout Flow](#8-checkout-flow)
9. [File Structure](#9-file-structure)
10. [Implementation Checklist](#10-implementation-checklist)

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CartPage (GetView)                       │
│  Obx → CartController                                           │
└────────────────────────────┬────────────────────────────────────┘
                             │ reads / calls
┌────────────────────────────▼────────────────────────────────────┐
│                      CartController                             │
│  items: RxList<LocalCartItem>   selectedIds: RxList<String>     │
│  isCheckingOut: RxBool          cartCount: int (getter)         │
│  subtotal / discount / total    (computed getters)              │
└───────┬──────────────────────────────────────────┬─────────────┘
        │ local ops                                │ checkout
┌───────▼──────────┐                  ┌────────────▼────────────┐
│ LocalCartUseCase │                  │  CheckoutUseCase        │
│  - get           │                  │  POST /checkout         │
│  - add / update  │                  │  {items:[{id,qty}]}     │
│  - remove        │                  └─────────────────────────┘
│  - toggleSelect  │
│  - selectAll     │
│  - clear         │
└───────┬──────────┘
        │
┌───────▼────────────────┐
│  LocalCartRepository   │  ← wraps SharedPreferences
│  key: "local_cart"     │
│  value: JSON array     │
└────────────────────────┘
```

**What stays local:** Everything until checkout.
**What hits the network:** Only `POST /checkout` — carries `[{productId, quantity}]` for selected items.

---

## 2. Local Storage Schema

**SharedPreferences key:** `local_cart`
**Value:** JSON-encoded list of cart item objects.

```json
[
  {
    "productId":      "prod_abc123",
    "productName":    "Running Shoes",
    "imageUrl":       "https://cdn.example.com/shoes.jpg",
    "sellerName":     "Sport Store",
    "sellerId":       "seller_xyz",
    "price":          59.99,
    "originalPrice":  79.99,
    "discountPercent": 25,
    "quantity":       2,
    "isSelected":     true,
    "addedAt":        "2025-03-19T10:00:00.000Z"
  }
]
```

**Rules:**
- `productId` is the unique key — adding an existing product increments `quantity`.
- Maximum quantity per item: 99.
- Maximum items in cart: no hard cap (paginated UI if > 20).
- `isSelected` persists between sessions — user's selection survives app restart.
- `addedAt` is used to sort items (newest first).

---

## 3. Data Layer

### 3.1 LocalCartItemModel

```dart
// lib/data/models/marketplace/local_cart_item_model.dart

class LocalCartItemModel {
  final String productId;
  final String productName;
  final String imageUrl;
  final String sellerName;
  final String sellerId;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;

  const LocalCartItemModel({ ... });

  factory LocalCartItemModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  LocalCartItemModel copyWith({
    int? quantity,
    bool? isSelected,
  }) { ... }

  LocalCartItemEntity toEntity() { ... }

  /// Build from a ProductEntity when adding to cart for the first time.
  factory LocalCartItemModel.fromProduct(ProductEntity product, int quantity) {
    return LocalCartItemModel(
      productId:       product.id,
      productName:     product.name,
      imageUrl:        product.imageUrl,
      sellerName:      product.sellerName,
      sellerId:        product.sellerId,
      price:           product.price,
      originalPrice:   product.originalPrice,
      discountPercent: product.discountPercent,
      quantity:        quantity,
      isSelected:      true,   // auto-select on add
      addedAt:         DateTime.now(),
    );
  }
}
```

### 3.2 LocalCartRepository

```dart
// lib/data/repositories/local_cart_repository.dart

class LocalCartRepository {
  static const _key = 'local_cart';
  final SharedPreferences _prefs;

  LocalCartRepository(this._prefs);

  // ── Read ───────────────────────────────────────────────────
  List<LocalCartItemModel> getItems() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LocalCartItemModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // newest first
  }

  // ── Write ──────────────────────────────────────────────────
  Future<void> _save(List<LocalCartItemModel> items) async {
    await _prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> addOrUpdate(LocalCartItemModel item) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      // Already in cart — increment quantity
      final existing = items[idx];
      final newQty = (existing.quantity + item.quantity).clamp(1, 99);
      items[idx] = existing.copyWith(quantity: newQty);
    } else {
      items.insert(0, item); // add at top
    }
    await _save(items);
  }

  Future<void> remove(String productId) async {
    final items = getItems()..removeWhere((e) => e.productId == productId);
    await _save(items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(quantity: quantity.clamp(1, 99));
    await _save(items);
  }

  Future<void> toggleSelection(String productId) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(isSelected: !items[idx].isSelected);
    await _save(items);
  }

  Future<void> setSelectAll(bool selected) async {
    final items = getItems().map((e) => e.copyWith(isSelected: selected)).toList();
    await _save(items);
  }

  Future<void> clear() async => _prefs.remove(_key);
}
```

---

## 4. Domain Layer

### 4.1 LocalCartItemEntity

```dart
// lib/domain/entities/marketplace/local_cart_item_entity.dart

class LocalCartItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String imageUrl;
  final String sellerName;
  final String sellerId;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;

  double get lineTotal => price * quantity;
  double get lineSaving =>
      originalPrice != null ? (originalPrice! - price) * quantity : 0;

  @override
  List<Object?> get props => [productId, quantity, isSelected];
}
```

### 4.2 Use Cases

All cart use cases are **synchronous wrappers** — they return immediately because there is no network call.

```dart
// lib/domain/usecases/marketplace/cart/

// GetLocalCartUseCase  — returns current items from storage
// AddToLocalCartUseCase(AddToCartInput) — add product to local cart
// RemoveFromLocalCartUseCase(productId) — remove item
// UpdateLocalCartQuantityUseCase(UpdateQtyInput{productId, quantity})
// ToggleLocalCartSelectionUseCase(productId)
// SetLocalCartSelectAllUseCase(bool)
// ClearLocalCartUseCase  — wipes cart (called after successful checkout)
```

Example:

```dart
class AddToLocalCartUseCase {
  final LocalCartRepository _repo;
  AddToLocalCartUseCase(this._repo);

  void call(ProductEntity product, int quantity) {
    _repo.addOrUpdate(LocalCartItemModel.fromProduct(product, quantity));
  }
}
```

> **Note on ProductDetailsController.addToCart():**
> Replace the simulated delay with an actual call:
> ```dart
> Get.find<AddToLocalCartUseCase>().call(product, quantity.value);
> ```
> The success snackbar stays the same.

### 4.3 CheckoutUseCase (placeholder — you'll fill the body)

```dart
class CheckoutInput {
  final List<({String productId, int quantity})> items;
  final String? deliveryAddressId;
  final String? paymentMethodId;
}

class CheckoutUseCase
    extends BaseUseCase<CheckoutInput, CheckoutResult, CheckoutRepository> {
  @override
  Future<AppState<CheckoutResult>> call(CheckoutInput input) async {
    final result = await repository.checkout(
      items: input.items,
      deliveryAddressId: input.deliveryAddressId,
      paymentMethodId:   input.paymentMethodId,
    );
    return resultToStateWithMapping(result: result, mapper: (m) => m.toEntity());
  }
}
```

**API contract (for when you implement CheckoutRepository):**

```
POST /checkout
Content-Type: application/json

{
  "items": [
    { "productId": "prod_abc", "quantity": 2 },
    { "productId": "prod_xyz", "quantity": 1 }
  ],
  "deliveryAddressId": "addr_123",   // nullable — set in checkout screen
  "paymentMethodId":   "pay_456"     // nullable — set in checkout screen
}

→ 200 { "orderId": "ord_789", "total": 179.97, ... }
→ 422 { "errors": [{ "productId": "prod_abc", "reason": "out_of_stock" }] }
```

---

## 5. Controller

```dart
// lib/presentation/controllers/marketplace/cart_controller.dart

class CartController extends GetxController {
  // Dependencies injected via Get.find in onInit
  late final GetLocalCartUseCase        _getCart;
  late final AddToLocalCartUseCase      _addToCart;
  late final RemoveFromLocalCartUseCase _removeItem;
  late final UpdateLocalCartQuantityUseCase _updateQty;
  late final ToggleLocalCartSelectionUseCase _toggleSelect;
  late final SetLocalCartSelectAllUseCase _setSelectAll;
  late final ClearLocalCartUseCase      _clearCart;

  // ── Reactive state ──────────────────────────────────────
  final items        = <LocalCartItemEntity>[].obs;
  final isLoading    = true.obs;
  final isCheckingOut = false.obs;

  // ── Computed getters ────────────────────────────────────
  List<LocalCartItemEntity> get selectedItems =>
      items.where((e) => e.isSelected).toList();

  bool get isAllSelected =>
      items.isNotEmpty && items.every((e) => e.isSelected);

  int get cartCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      selectedItems.fold(0, (sum, e) => sum + e.lineTotal);

  double get discount =>
      selectedItems.fold(0, (sum, e) => sum + e.lineSaving);

  double get total => subtotal - discount;

  bool get hasItems => items.isNotEmpty;
  bool get hasSelection => selectedItems.isNotEmpty;

  // ── Lifecycle ───────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    loadCart();
  }

  void _initDependencies() {
    _getCart       = Get.find();
    _addToCart     = Get.find();
    _removeItem    = Get.find();
    _updateQty     = Get.find();
    _toggleSelect  = Get.find();
    _setSelectAll  = Get.find();
    _clearCart     = Get.find();
  }

  // ── Operations ──────────────────────────────────────────
  void loadCart() {
    isLoading.value = true;
    items.assignAll(_getCart.call());
    isLoading.value = false;
  }

  void addProduct(ProductEntity product, int quantity) {
    _addToCart.call(product, quantity);
    _refresh();
    _showAddedSnackbar(product.name);
  }

  void removeItem(String productId) {
    _removeItem.call(productId);
    _refresh();
  }

  void updateQuantity(String productId, int quantity) {
    _updateQty.call(productId, quantity);
    _refresh();
  }

  void toggleSelection(String productId) {
    _toggleSelect.call(productId);
    _refresh();
  }

  void toggleSelectAll() {
    _setSelectAll.call(!isAllSelected);
    _refresh();
  }

  Future<void> checkout() async {
    if (!hasSelection || isCheckingOut.value) return;
    isCheckingOut.value = true;
    // TODO: call CheckoutUseCase — see §8 Checkout Flow
    // On success: _clearCart.call(); Get.toNamed(Routes.CHECKOUT);
    isCheckingOut.value = false;
  }

  // ── Helpers ─────────────────────────────────────────────
  void _refresh() => items.assignAll(_getCart.call());

  void _showAddedSnackbar(String productName) {
    Get.snackbar(
      '',
      '',
      messageText: Text(
        LocaleKeys.addedToCart.tr,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green.shade600,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
```

---

## 6. UI Design Specs

### 6.1 Screen Overview

```
┌─────────────────────────────────────────────────────────┐
│  ← My Cart                                3 items       │  AppBar
├─────────────────────────────────────────────────────────┤
│  [☑ Select All]                  3 Items  [Delete all]  │  Toolbar row
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐    │
│  │ [☑] [IMG] Product Name             [−][2][+] 🗑 │    │  CartItemCard
│  │         Seller Name                              │    │
│  │         $59.99  ~~$79.99~~                       │    │
│  └─────────────────────────────────────────────────┘    │
│                  ↑ repeats, gap: spacing-md              │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Subtotal             $179.98                   │    │
│  │  Discount             -$40.00                   │    │
│  │  ─────────────────────────────                  │    │  PriceSummary
│  │  Total                $139.98                   │    │  Card
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  [         Checkout (2)          ]                       │  Sticky CTA
└─────────────────────────────────────────────────────────┘
```

### 6.2 Design Tokens

| Token | Value | Used For |
|-------|-------|----------|
| `primary` | `#2E5129` | Checkbox fill, checkout button, select-all accent |
| `secondary` | `#DDEB9D` | Price summary card background tint |
| `textPrimary` | `#101828` | Section headings |
| `textBody` | `#4A4A4A` | Product names, prices |
| `textSecondary` | `#767676` | Seller names, count labels |
| `textMuted` | `#A2A2A2` | Strikethrough original price |
| `stroke` | `#C1C1C1` | Card borders, dividers |
| `deleteBackground` | `#EAEAEA` | Delete icon circle background |
| `surface` | `#FFFFFF` | Page and card backgrounds |
| `spacing-sm` | `8px` | Gaps within a card row |
| `spacing-md` | `16px` | Between cards, horizontal padding |
| `spacing-lg` | `24px` | Section gaps |
| `radius-cartItem` | `14px` | Cart item card radius |
| `radius-button` | `20px` | Checkout button radius |
| `cartItemHeight` | `110px` | Cart card fixed height |
| `cartImageWidth` | `100px` | Product image width |
| `cartImageHeight` | `94px` | Product image height |

### 6.3 States

| State | Trigger | UI |
|-------|---------|-----|
| **Loading** | `isLoading == true` on init | Shimmer skeleton — 3 ghost CartItemCards |
| **Empty** | `items.isEmpty` after load | Illustration + "Your cart is empty" + "Shop Now" button |
| **Populated** | `items.isNotEmpty` | Full layout with item list + price summary |
| **No selection** | `selectedItems.isEmpty` | Checkout button disabled (opacity 0.5), total shows $0.00 |
| **Checking out** | `isCheckingOut == true` | Checkout button shows spinner, disabled |
| **Error** | local read failure | Centered error + retry button |

### 6.4 Animations & Motion

| Element | Trigger | Animation | Duration | Easing |
|---------|---------|-----------|----------|--------|
| Cart item removal | `removeItem()` | Slide out right + fade, then list reflows | 250ms | `easeOut` |
| Item added (from product page) | `addProduct()` | Cart badge in bottom nav bounces once | 300ms | `spring` |
| Quantity change | `updateQuantity()` | Number cross-fades in place | 150ms | `linear` |
| Checkout button | `isCheckingOut` → true | Label cross-fades to spinner | 200ms | `easeIn` |
| Empty state appears | `items` → empty | Fade in illustration | 300ms | `easeIn` |

Use `AnimatedList` for the item list to enable item removal animations.

---

## 7. Component Specs

### 7.1 CartPage

```
File: lib/presentation/pages/marketplace/cart/cart_page.dart
Controller: CartController (GetView)
```

**AppBar**
- Title: `LocaleKeys.myCart.tr`
- Trailing: `"${items.length} ${LocaleKeys.items.tr}"` in `textSecondary / 14sp / Medium`
- No back button when reached via bottom nav tab

**Toolbar Row** (shown only when `hasItems`)
- Left: custom checkbox + `"Select All"` label — taps `controller.toggleSelectAll()`
- Right: `"X Items"` count (selected items only) in `textSecondary`
- Height: 48px, horizontal padding: `screenPaddingH`

**Item List**
- `AnimatedList` with `ListView.separated` fallback
- `separatorBuilder`: `SizedBox(height: spacing-md)`
- Each item wrapped in a `Dismissible` for swipe-to-delete:
  - Direction: `endToStart` (right → left swipe)
  - Background: red container with trash icon on the right
  - `onDismissed`: `controller.removeItem(item.productId)`
  - Confirm dialog: optional, skip for speed

**Price Summary Card**
- Full-width container, `spacing-md` horizontal margin
- Background: `secondary.withOpacity(0.3)` — subtle green tint
- Border radius: `radius-card (15px)`
- Rows: Subtotal, Discount (hidden if 0), divider, **Total** (bold)
- Numbers right-aligned, labels left-aligned

**Checkout Button**
- Full-width `ElevatedButton` inside `SafeArea` bottom bar
- Label: `"${LocaleKeys.checkout.tr} (${selectedItems.length})"`
- Disabled when `!hasSelection`
- Loading: replaces label with 20×20 `CircularProgressIndicator(strokeWidth:2)`

### 7.2 CartItemCard (update existing)

```
File: lib/core/components/marketplace/cart_item_card.dart
```

**Current issues to fix:**
- Price prefix is `"Rp"` — should use `"\$"` or be passed as a formatted string
- Fixed `height: 110` — works for most cases, but long product names may clip. Consider `IntrinsicHeight` or clamped max-height.
- No discount badge visible on the card — add strikethrough + percentage if `discountPercent` is set

**Updated props to add:**
```dart
final int? discountPercent;   // show "–XX%" badge on image corner
final VoidCallback onTap;     // tap card → go to product details
```

**Layout (updated):**
```
[☑ 20×20] [IMG 100×94] [  Product Name (1 line, ellipsis)      ]  [−][qty][+]
                         [  Seller Name  (1 line, ellipsis)     ]
                         [  $price  ~~$orig~~  [-25%]           ]  [🗑 24×24]
```

Checkbox: 20×20, custom rounded square (not Material Checkbox — use existing impl)
Quantity stepper: `QuantityStepperVariant.compact`
Delete button: 24×24 circle, `deleteBackground`, trash icon 12px

**Swipe-to-delete background:**
```dart
background: Container(
  alignment: Alignment.centerRight,
  padding: EdgeInsets.only(right: spacing-md),
  decoration: BoxDecoration(
    color: Color(0xFFD32F2F),
    borderRadius: BorderRadius.circular(radius-cartItem),
  ),
  child: Icon(Icons.delete_outline, color: Colors.white, size: 24),
)
```

### 7.3 CartShimmer (new)

Show 3 ghost cards while loading. Each card matches the `CartItemCard` dimensions (110px tall, full width) with shimmer animation on the image placeholder, name lines, and price line.

```dart
// lib/core/components/marketplace/cart_item_shimmer.dart
// Use existing shimmer package: Shimmer.fromColors(...)
```

### 7.4 EmptyCartView (new)

```
File: lib/core/components/marketplace/empty_cart_view.dart

Center column:
  Icon(Icons.shopping_cart_outlined, size: 80, color: stroke)
  SizedBox(height: spacing-lg)
  Text(LocaleKeys.emptyCart.tr,  style: sectionHeading)
  SizedBox(height: spacing-sm)
  Text(LocaleKeys.emptyCartMessage.tr, style: descriptionBody, textAlign: center)
  SizedBox(height: spacing-lg)
  ElevatedButton(
    onPressed: () => Get.back(),   // or navigate to home
    child: Text(LocaleKeys.continueShopping.tr)
  )
```

### 7.5 CartPriceSummary (new)

```
File: lib/core/components/marketplace/cart_price_summary.dart

Props (DTO pattern):
  class CartPriceSummaryDto {
    final double subtotal;
    final double discount;    // pass 0 to hide the row
    final double total;
  }
```

Layout — all rows use the same `_PriceRow` private widget:
```
  Subtotal        $179.98   ← descriptionBody / textSecondary
  Discount        -$40.00   ← descriptionBody / Color(0xFFD32F2F)  (hidden if 0)
  ─────────────────────────   Divider(color: stroke)
  Total           $139.98   ← sectionSubheading / textBody (bold)
```

---

## 8. Checkout Flow

### 8.1 Sequence

```
User taps [Checkout (2)]
        │
        ▼
CartController.checkout()
        │  build payload from selectedItems
        ▼
CheckoutUseCase.call(CheckoutInput)
        │  POST /checkout
        │  { items: [{productId, quantity}, ...] }
        ▼
  ┌─────────────────────────────┐
  │  SUCCESS (200)              │
  │  → Clear selected items     │  _clearCart.call()  (or only clear selected)
  │  → Navigate to order screen │  Get.toNamed(Routes.CHECKOUT, arguments: result)
  └─────────────────────────────┘
  ┌─────────────────────────────┐
  │  PARTIAL FAILURE (422)      │
  │  Some items out of stock    │
  │  → Show error snackbar      │  list which products failed
  │  → Highlight problem items  │  mark them on the cart list
  │  → Keep cart unchanged      │
  └─────────────────────────────┘
  ┌─────────────────────────────┐
  │  NETWORK FAILURE            │
  │  → Show retry snackbar      │
  │  → Keep cart unchanged      │
  └─────────────────────────────┘
```

### 8.2 Checkout Payload Builder

```dart
// Inside CartController.checkout()

final payload = selectedItems
    .map((item) => (productId: item.productId, quantity: item.quantity))
    .toList();

await handleState(
  kCheckout,
  () => Get.find<CheckoutUseCase>().call(
    CheckoutInput(items: payload),
  ),
  onSuccess: (result, _) {
    _clearCart.call();
    Get.toNamed(Routes.CHECKOUT_CONFIRMATION, arguments: result);
  },
  onError: (msg, _) {
    Get.snackbar('Checkout failed', msg, snackPosition: SnackPosition.BOTTOM);
  },
);
```

### 8.3 Cart Binding (updated)

```dart
class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddToLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RemoveFromLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateLocalCartQuantityUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ToggleLocalCartSelectionUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SetLocalCartSelectAllUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ClearLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
  }
}
```

### 8.4 Registering LocalCartRepository

In your dependency injection / `AppBinding`:

```dart
// Register SharedPreferences instance (do once at app startup)
final prefs = await SharedPreferences.getInstance();
Get.put<SharedPreferences>(prefs, permanent: true);

// Register LocalCartRepository
Get.lazyPut(() => LocalCartRepository(Get.find<SharedPreferences>()), fenix: true);
```

---

## 9. File Structure

```
lib/
├── data/
│   ├── models/marketplace/
│   │   └── local_cart_item_model.dart          ← NEW
│   └── repositories/
│       └── local_cart_repository.dart          ← NEW
│
├── domain/
│   ├── entities/marketplace/
│   │   └── local_cart_item_entity.dart         ← NEW
│   └── usecases/marketplace/cart/
│       ├── get_local_cart_use_case.dart         ← NEW
│       ├── add_to_local_cart_use_case.dart      ← NEW
│       ├── remove_from_local_cart_use_case.dart ← NEW
│       ├── update_local_cart_quantity_use_case.dart ← NEW
│       ├── toggle_local_cart_selection_use_case.dart ← NEW
│       ├── set_local_cart_select_all_use_case.dart ← NEW
│       ├── clear_local_cart_use_case.dart       ← NEW
│       └── checkout_use_case.dart               ← NEW (body TBD)
│
├── presentation/
│   ├── controllers/marketplace/
│   │   └── cart_controller.dart                ← REWRITE
│   └── pages/marketplace/cart/
│       ├── bindings/cart_binding.dart           ← UPDATE
│       └── cart_page.dart                      ← IMPLEMENT
│
└── core/components/marketplace/
    ├── cart_item_card.dart                      ← UPDATE (fix Rp, add onTap)
    ├── cart_item_shimmer.dart                   ← NEW
    ├── empty_cart_view.dart                     ← NEW
    └── cart_price_summary.dart                  ← NEW
```

---

## 10. Implementation Checklist

### Data Layer
- [ ] Create `LocalCartItemModel` with `fromJson` / `toJson` / `copyWith` / `fromProduct`
- [ ] Create `LocalCartItemEntity` with `lineTotal` and `lineSaving` computed fields
- [ ] Create `LocalCartRepository` with all 6 operations
- [ ] Register `LocalCartRepository` in app-level binding / `AppBinding`

### Domain Layer
- [ ] `GetLocalCartUseCase` — synchronous, returns `List<LocalCartItemEntity>`
- [ ] `AddToLocalCartUseCase(ProductEntity, int quantity)`
- [ ] `RemoveFromLocalCartUseCase(String productId)`
- [ ] `UpdateLocalCartQuantityUseCase(String productId, int quantity)`
- [ ] `ToggleLocalCartSelectionUseCase(String productId)`
- [ ] `SetLocalCartSelectAllUseCase(bool)`
- [ ] `ClearLocalCartUseCase`
- [ ] `CheckoutUseCase` stub (input + API contract defined, body TBD)

### Controller
- [ ] Rewrite `CartController` to use local use cases
- [ ] Remove dependency on `GetCartUseCase` (old API-backed version)
- [ ] Expose `cartCount` getter for bottom nav badge
- [ ] Wire `ProductDetailsController.addToCart()` to call `AddToLocalCartUseCase`

### UI
- [ ] Implement `CartPage` with `AnimatedList` + `Dismissible` items
- [ ] Implement toolbar row (Select All / item count)
- [ ] Implement `CartPriceSummary` widget + DTO
- [ ] Implement `EmptyCartView`
- [ ] Implement `CartItemShimmer` (loading skeleton)
- [ ] Update `CartItemCard` — fix currency prefix, add `onTap`, add discount badge
- [ ] Wire checkout button → `CartController.checkout()`
- [ ] Show cart badge count on bottom nav cart icon

### Checkout Integration (your part)
- [ ] Create `CheckoutRepository` + `POST /checkout` call
- [ ] Implement `CheckoutUseCase` body
- [ ] Handle 422 partial-stock failures
- [ ] Navigate to order confirmation on success
- [ ] Decide: clear full cart or only selected items after checkout

### Edge Cases
- [ ] Cart survives app restart (SharedPreferences persists)
- [ ] Adding existing product increments quantity (no duplicate entries)
- [ ] Quantity capped at 99 per item
- [ ] Empty state shown when last item is removed via swipe
- [ ] Checkout button disabled until at least one item is selected
- [ ] Arabic RTL layout — swipe direction reverses, text aligns right
