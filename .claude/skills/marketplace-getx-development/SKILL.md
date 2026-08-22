---
name: marketplace-getx-development
description: Build features for the Marketplace Flutter app using GetX state management, clean architecture, and the project's exact base classes, design system, and patterns. Apply when creating screens, controllers, use cases, repositories, or data models.
---

# Marketplace GetX Development

This skill enforces the exact architecture, base classes, state management, naming conventions, and design system of the `marketplace_app` project. Every new feature **must** follow these patterns — no exceptions.

> **Prerequisite:** this skill covers *how* to build. Before using it, run
> `amazonat-feature-parity` to establish *what* to build — the exact API contract
> from the `amazonat-client` MCP spec and the shipped behavior of the web client at
> `/Users/mac/Desktop/projects/amazonat-client-portal`. Never invent an endpoint or
> a field; if it is not in the OAS, it does not exist.

---

## Architecture Overview

```
lib/
├── app/
│   ├── bindings/initial_binding.dart     ← App-level DI
│   └── routes/app_pages.dart             ← Route registration
├── core/
│   ├── bases/                            ← Base classes (extend, never bypass)
│   ├── components/                       ← Shared widgets
│   ├── states/app_state.dart             ← AppState sealed class
│   ├── network/result.dart               ← Result<T> sealed class
│   ├── theme/                            ← Design system constants
│   ├── errors/exceptions.dart            ← Typed exceptions
│   └── localization/                     ← i18n keys + translations
├── data/
│   ├── models/marketplace/               ← DTOs (fromJson + toEntity)
│   ├── repositories/                     ← Extends BaseRepository<ApiService>
│   └── services/api_service.dart         ← HTTP layer
├── domain/
│   ├── entities/marketplace/             ← Equatable pure entities
│   └── usecases/marketplace/[feature]/  ← Extends BaseUseCase variants
└── presentation/
    ├── controllers/marketplace/          ← Extends BaseStateController
    └── pages/marketplace/[feature]/
        ├── [feature]_page.dart
        └── bindings/[feature]_binding.dart
```

**Data flow:**
```
UI (Obx) → Controller.handleState(key, () => useCase.call(input))
         → UseCase.call() → Repository.get/post/...()
         → ApiService → Dio → API
         → Result<DTO> → AppState<Entity> → UI re-renders
```

---

## Decision Tree

```
What are you building?
│
├─ New feature (screen + data) → Full stack:
│   Entity → Model → Repository → UseCase → Controller → Page → Binding → Route
│
├─ New screen only (uses existing data) →
│   Controller (new) → Page → Binding → Route
│
├─ New API call only →
│   Model + Repository method + UseCase
│
└─ New widget →
    core/components/ if shared, or page/widgets/ if feature-specific
```

---

## Step-by-Step: Full Feature Implementation

### 1 — Entity  (`domain/entities/marketplace/[feature]_entity.dart`)

```dart
import 'package:equatable/equatable.dart';

class FeatureEntity extends Equatable {
  const FeatureEntity({
    required this.id,
    required this.name,
    // ...
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
```

**Rules:**
- Always extends `Equatable`
- All fields `final`
- Constructor is `const`
- `props` lists every field

---

### 2 — Model  (`data/models/marketplace/[feature]_model.dart`)

```dart
import 'package:get/get.dart';
import 'package:marketplace/domain/entities/marketplace/feature_entity.dart';

class FeatureModel {
  FeatureModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
    );
  }

  FeatureEntity toEntity() {
    return FeatureEntity(
      id: id,
      name: Get.locale?.languageCode == 'ar' ? nameAr : nameEn,
    );
  }
}
```

**Rules:**
- Raw JSON parsing only in `fromJson`
- Locale-aware field selection lives in `toEntity()` (use `Get.locale?.languageCode == 'ar'`)
- Never import `AppState` or `Result` in models
- Use `BaseResponse.fromJson`, `BaseListResponse.fromJson`, or `BasePaginatedResponse.fromJson` helpers in the repository (not in the model)

---

### 3 — Repository  (`data/repositories/[feature]_repository.dart`)

```dart
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/feature_model.dart';

class FeatureRepository extends BaseRepository<ApiService> {
  FeatureRepository(super.service);

  // Single item
  Future<Result<FeatureModel>> getFeatureById(String id) {
    return get(
      '/features/$id',
      (json) => BaseResponse.fromJson(json, FeatureModel.fromJson).data,
    );
  }

  // Paginated list
  Future<Result<List<FeatureModel>>> getFeatures({
    int page = 1,
    int limit = 20,
  }) {
    return get(
      '/features',
      (json) => BasePaginatedResponse.fromJson(json, FeatureModel.fromJson).data,
      queryParams: {'page': page, 'limit': limit},
    );
  }

  // Create
  Future<Result<FeatureModel>> createFeature(Map<String, dynamic> body) {
    return post(
      '/features',
      (json) => BaseResponse.fromJson(json, FeatureModel.fromJson).data,
      body: body,
    );
  }

  // Update
  Future<Result<FeatureModel>> updateFeature(String id, Map<String, dynamic> body) {
    return put(
      '/features/$id',
      (json) => BaseResponse.fromJson(json, FeatureModel.fromJson).data,
      body: body,
    );
  }

  // Delete (void response)
  Future<Result<void>> deleteFeature(String id) {
    return delete(
      '/features/$id',
      (_) {},
    );
  }
}
```

**Rules:**
- Always extends `BaseRepository<ApiService>`
- Use `get`, `post`, `put`, `patch`, `delete` helpers — never call `service` or `dio` directly
- Wrap response with the correct base response class: `BaseResponse` (single), `BaseListResponse` (flat list), `BasePaginatedResponse` (paged list)
- Return `Result<T>` — never throw, never return raw types

---

### 4 — Use Cases  (`domain/usecases/marketplace/[feature]/`)

**No-input use case (most common for GET lists):**
```dart
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/feature_entity.dart';
import 'package:marketplace/data/repositories/feature_repository.dart';

class GetFeaturesUseCase
    extends NoInputUseCase<List<FeatureEntity>, FeatureRepository> {
  GetFeaturesUseCase(super.repository);

  @override
  Future<AppState<List<FeatureEntity>>> call(_) async {
    final result = await repository.getFeatures();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
```

**Use case with input:**
```dart
class GetFeatureByIdUseCase
    extends BaseUseCase<String, FeatureEntity, FeatureRepository> {
  GetFeatureByIdUseCase(super.repository);

  @override
  Future<AppState<FeatureEntity>> call(String id) async {
    final result = await repository.getFeatureById(id);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
```

**Void use case (DELETE, side-effect calls):**
```dart
class DeleteFeatureUseCase
    extends VoidUseCase<String, FeatureRepository> {
  DeleteFeatureUseCase(super.repository);

  @override
  Future<AppState<void>> call(String id) async {
    final result = await repository.deleteFeature(id);
    return resultToState(result: result);
  }
}
```

**Rules:**
- Choose the right base: `NoInputUseCase`, `BaseUseCase`, `VoidUseCase`, `PaginationUseCase`
- Always call `resultToStateWithMapping` (when mapping DTO → Entity) or `resultToState` (when T is already the entity) or `resultToListState` (for lists)
- Never do HTTP calls or business logic inside use cases — call repository only

---

### 5 — Controller  (`presentation/controllers/marketplace/[feature]_controller.dart`)

```dart
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/feature/get_features_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/feature/delete_feature_use_case.dart';

class FeatureController extends BaseStateController<GetFeaturesUseCase> {
  // ── Operation keys ────────────────────────────────────────
  static const String kFeatures = 'features';
  static const String kDelete   = 'delete';

  // ── Local reactive state ──────────────────────────────────
  final selectedId = Rx<String?>(null);
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeatures();
  }

  /// Load all features
  Future<void> loadFeatures() async {
    await handleState<List<FeatureEntity>>(
      kFeatures,
      () => useCase.execute(),
    );
  }

  /// Pull-to-refresh
  Future<void> refresh() => loadFeatures();

  /// Delete a feature
  Future<void> deleteFeature(String id) async {
    await handleState<void>(
      kDelete,
      () => Get.find<DeleteFeatureUseCase>().call(id),
      onSuccess: (_, __) {
        loadFeatures(); // reload list after delete
      },
      onError: (message, _) {
        // custom error handling if needed
      },
    );
  }

  /// Load multiple things in parallel
  Future<void> loadAll() async {
    await handleMultipleStates({
      kFeatures: () => useCase.execute(),
      // add more keys here for parallel loads
    });
  }
}
```

**Rules:**
- Always extends `BaseStateController<PrimaryUseCase>`
- Operation keys are `static const String` — never use raw strings in UI
- Use `handleState` for single operations, `handleMultipleStates` for parallel, `handlePaginationState` for paginated append
- Extra use cases are resolved via `Get.find<OtherUseCase>()` in the method body
- Local reactive state uses `.obs` (GetX observables)
- Never put HTTP logic, mapping, or business rules in controllers

---

### 6 — Page  (`presentation/pages/marketplace/[feature]/[feature]_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/presentation/controllers/marketplace/feature_controller.dart';
import 'package:marketplace/domain/entities/marketplace/feature_entity.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeatureController>();

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(LocaleKeys.featureTitle.tr),
      ),
      body: Obx(() {
        final state = controller.stateFor<List<FeatureEntity>>(
          FeatureController.kFeatures,
        );
        return state.value.when(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => const Center(child: CircularProgressIndicator()),
          onSuccess: (items, _) => _buildList(items, controller),
          onError: (message, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: MarketplaceTypography.body),
                const SizedBox(height: MarketplaceSpacing.sm),
                TextButton(
                  onPressed: controller.refresh,
                  child: Text(LocaleKeys.retry.tr),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildList(List<FeatureEntity> items, FeatureController controller) {
    if (items.isEmpty) {
      return Center(child: Text(LocaleKeys.noItems.tr));
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: MarketplaceColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.md,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: MarketplaceSpacing.sm),
        itemBuilder: (_, index) => _FeatureCard(item: items[index]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});
  final FeatureEntity item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        child: Text(item.name, style: MarketplaceTypography.body),
      ),
    );
  }
}
```

**State pattern cheat-sheet:**
```dart
// In Obx, always:
Obx(() {
  final state = controller.stateFor<T>(FeatureController.kKey);
  return state.value.when(
    onInitial: () => const SizedBox.shrink(),
    onLoading: () => LoadingWidget(),       // use shimmer for lists
    onSuccess: (data, _) => ContentWidget(data),
    onError: (msg, _) => ErrorWidget(msg),
  );
})
```

**Rules:**
- Always use `Obx(() { ... })` to wrap reactive state, NOT `GetBuilder`
- Get controller via `Get.find<Controller>()`; for `StatefulWidget` store in a field
- All colors from `MarketplaceColors`, spacing from `MarketplaceSpacing`, text from `MarketplaceTypography`
- Localized strings via `LocaleKeys.key.tr` — never hardcode strings
- Show shimmer on loading for lists (use existing shimmer widgets from `core/components/marketplace/loading_shimmer.dart`)

---

### 7 — Binding  (`presentation/pages/marketplace/[feature]/bindings/[feature]_binding.dart`)

```dart
import 'package:get/get.dart';
import 'package:marketplace/presentation/controllers/marketplace/feature_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/feature/get_features_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/feature/delete_feature_use_case.dart';

class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    // Register use cases first (they depend on repositories/services)
    Get.lazyPut(() => GetFeaturesUseCase(Get.find()));
    Get.lazyPut(() => DeleteFeatureUseCase(Get.find()));
    // Register controller last
    Get.lazyPut(() => FeatureController());
  }
}
```

**Rules:**
- Use `Get.lazyPut` for all registrations — never `Get.put` in bindings
- Repositories are already registered as permanent in `InitialBinding` or registered via `Get.find()` — if a new repository is needed, register it here too:
  ```dart
  Get.lazyPut(() => FeatureRepository(Get.find<ApiService>()));
  ```
- Register use cases before the controller that depends on them
- Never register services (`ApiService`, `DioClient`, `StorageService`) in feature bindings — they are permanent singletons from `InitialBinding`

---

### 8 — Route Registration  (`app/routes/app_pages.dart` + `app_routes.dart`)

Add to `app_routes.dart`:
```dart
static const MARKETPLACE_FEATURE = '/marketplace/feature';
```

Add to `app_pages.dart`:
```dart
GetPage(
  name: Routes.MARKETPLACE_FEATURE,
  page: () => const FeaturePage(),
  binding: FeatureBinding(),
  transition: Transition.rightToLeft, // optional
),
```

Navigate from UI:
```dart
Get.toNamed(Routes.MARKETPLACE_FEATURE);
// With arguments:
Get.toNamed(Routes.MARKETPLACE_FEATURE, arguments: entity.id);
// Read argument in controller:
final id = Get.arguments as String;
```

---

## Design System — Non-Negotiable

### Colors (`core/theme/marketplace_colors.dart`)
```dart
✅ MarketplaceColors.primary
✅ MarketplaceColors.surface
✅ MarketplaceColors.stroke
✅ MarketplaceColors.textPrimary
✅ MarketplaceColors.error
❌ Color(0xFF...), Colors.blue, hardcoded hex
```

### Spacing (`core/theme/marketplace_spacing.dart`)
```dart
✅ MarketplaceSpacing.xs    // 4
✅ MarketplaceSpacing.sm    // 8
✅ MarketplaceSpacing.md    // 16
✅ MarketplaceSpacing.lg    // 24
✅ MarketplaceSpacing.xl    // 32
✅ MarketplaceSpacing.xxl   // 48
✅ MarketplaceSpacing.screenPaddingH  // horizontal screen padding
✅ MarketplaceSpacing.bannerHeight
✅ MarketplaceSpacing.productGridColumns
✅ MarketplaceSpacing.productCardWidth / productCardHeight
❌ EdgeInsets.all(16), hardcoded numbers
```

### Typography (`core/theme/marketplace_typography.dart`)
```dart
✅ MarketplaceTypography.sectionHeading
✅ MarketplaceTypography.body
✅ MarketplaceTypography.seeAll
✅ (any style defined in that file)
❌ TextStyle(fontSize: 16), inline styles
```

### Localization (`core/localization/locale_keys.dart`)
```dart
✅ LocaleKeys.featureTitle.tr
✅ LocaleKeys.retry.tr
✅ LocaleKeys.noItems.tr
❌ Text('My hardcoded string')
```
When adding new strings: add the key to `locale_keys.dart`, then add translations to `en.dart` and `ar.dart`.

---

## Bilingual Content Pattern

API data with Arabic/English variants must follow this pattern:

**Model** — store both raw fields:
```dart
final String nameAr;
final String nameEn;
```

**toEntity()** — resolve locale at mapping time:
```dart
name: Get.locale?.languageCode == 'ar' ? nameAr : nameEn,
```

**Entity** — single resolved field:
```dart
final String name; // already locale-resolved
```

---

## State Handling Patterns

### Single operation
```dart
await handleState<T>(
  FeatureController.kKey,
  () => useCase.execute(),   // or useCase.call(input)
  onSuccess: (data, message) { /* navigate, show snackbar, etc */ },
  onError: (message, code) { /* custom error handling */ },
);
```

### Multiple parallel operations
```dart
await handleMultipleStates({
  FeatureController.kKey1: () => useCase1.execute(),
  FeatureController.kKey2: () => Get.find<UseCase2>().call(input),
}, onAllSuccess: () { /* all done */ });
```

### Paginated / infinite scroll
```dart
await handlePaginationState<FeatureEntity>(
  FeatureController.kKey,
  () => useCase.call(PaginationInput(page: _currentPage, limit: 20)),
  append: _currentPage > 1,  // true = append to existing list
  onSuccess: (newItems) { _currentPage++; },
);
```

---

## Common Reusable Widgets

Always check `core/components/` before creating new widgets:

| Widget | Import path |
|--------|-------------|
| `ProductCard` / `ProductCardShimmer` | `core/components/marketplace/product_card.dart` |
| `CategoryChip` / `CategoryChipShimmer` | `core/components/marketplace/category_chip.dart` |
| `CartItemCard` | `core/components/marketplace/cart_item_card.dart` |
| `MarketplaceAppBar` | `core/components/marketplace/marketplace_app_bar.dart` |
| `SearchBarWidget` | `core/components/marketplace/search_bar_widget.dart` |
| `QuantityStepper` | `core/components/marketplace/quantity_stepper.dart` |
| `StarRating` | `core/components/marketplace/star_rating.dart` |
| `DiscountBadge` | `core/components/marketplace/discount_badge.dart` |
| `AppNetworkImage` | `core/components/marketplace/app_network_image.dart` |
| `BaseButton` | `core/components/buttons/base_button.dart` |
| `BaseTextField` | `core/components/inputs/base_text_field.dart` |

---

## Checklist Before Finishing Any Feature

- [ ] Entity extends `Equatable` with all fields in `props`
- [ ] Model has `fromJson` and `toEntity()`, bilingual fields resolved in `toEntity()`
- [ ] Repository extends `BaseRepository<ApiService>`, uses HTTP helpers, returns `Result<T>`
- [ ] Use case extends correct base class, calls `resultToStateWithMapping` / `resultToState`
- [ ] Controller extends `BaseStateController<PrimaryUseCase>`, has `static const` keys
- [ ] All async ops use `handleState` / `handleMultipleStates` / `handlePaginationState`
- [ ] UI wrapped in `Obx()`, uses `stateFor(key).value.when(...)` pattern
- [ ] Zero hardcoded colors, spacing, typography, or strings
- [ ] All strings use `LocaleKeys.key.tr` with entries in both `en.dart` and `ar.dart`
- [ ] Binding uses `Get.lazyPut` for all registrations
- [ ] Route added to `app_routes.dart` and `app_pages.dart`
- [ ] New repository (if any) registered in the feature binding via `Get.lazyPut(() => Repo(Get.find()))`
