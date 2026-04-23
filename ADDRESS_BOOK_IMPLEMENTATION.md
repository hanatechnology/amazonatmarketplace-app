# Address Book Implementation Guide

> **For the coding agent.** Read this entirely before writing a single line of code. Follow the established patterns from `CART_IMPLEMENTATION.md` and `CHECKOUT_IMPLEMENTATION.md` — same DTO architecture, same GetX conventions, same design tokens.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Design Critique & Enhanced Specs](#2-design-critique--enhanced-specs)
3. [Screen Layouts](#3-screen-layouts)
4. [Component Breakdown](#4-component-breakdown)
5. [DTOs](#5-dtos)
6. [Domain Layer](#6-domain-layer)
7. [Data Layer](#7-data-layer)
8. [Controller Implementation](#8-controller-implementation)
9. [Binding & Routes](#9-binding--routes)
10. [Localization Keys](#10-localization-keys)
11. [File Structure](#11-file-structure)
12. [Implementation Checklist](#12-implementation-checklist)

---

## 1. Architecture Overview

### Three Screens

```
AccountPage / CheckoutPage
        │
        ▼
  AddressBookPage  ──────────────────────────────────────────────
        │  (GetView<AddressesController>)                         │
        │                                                         │
  ┌─────┴──────────────────┐                              ┌──────▼──────┐
  │  AddressesController   │                              │ empty state │
  │  • loads address list  │                              │ (no FAB)    │
  │  • handles delete      │                              └─────────────┘
  │  • handles set-default │
  └─────┬──────────────────┘
        │  Get.toNamed(MARKETPLACE_ADD_ADDRESS)
        │  Get.toNamed(MARKETPLACE_EDIT_ADDRESS, arguments: address)
        ▼
  AddEditAddressPage  (GetView<AddEditAddressController>)
        │  handles both Add and Edit mode
        │  mode detected from: Get.arguments == null → Add; else → Edit
        ▼
  After save → Get.back()
  AddressBookPage refreshes via onResume / reactive list
```

### Key Principles

- `AddressBookPage` is the only `GetView<AddressesController>` in its file
- `AddEditAddressPage` is the only `GetView<AddEditAddressController>` in its file
- All sub-widgets are pure `StatelessWidget` with DTOs
- `Obx` wraps only the sections that are reactive (list state, loading, delete confirmation)
- The **same page** handles Add and Edit — mode is determined from `Get.arguments`
- After successful save/delete, `AddressesController` refreshes its list reactively — no need to manually navigate back and forth

---

## 2. Design Critique & Enhanced Specs

### Design Critique: Address Book — List Screen

#### Overall Impression
A typical address list is a plain `ListView` of text rows with no visual hierarchy, making "Default" addresses invisible and delete/edit actions easy to tap accidentally. The enhanced design gives the default address a prominent badge, separates actions visually, and adds a clear empty state.

#### Usability

| Finding | Severity | Recommendation |
|---------|----------|----------------|
| No empty state when user has no addresses | 🔴 Critical | Full empty state with illustration, heading, and "Add your first address" CTA |
| Delete fires immediately without confirmation | 🔴 Critical | Bottom sheet confirmation dialog before delete |
| Default address not visually differentiated | 🟡 Moderate | Green "Default" pill badge on the card, address sorted to top |
| Edit and delete icons too close together | 🟡 Moderate | Minimum 48dp spacing between icons; place them vertically stacked on trailing side |
| No feedback when setting an address as default | 🟡 Moderate | Green checkmark animation + `SnackBar` confirmation |
| "Add Address" only accessible via FAB | 🟢 Minor | Also reachable from address card "Add new" at list bottom |

#### Visual Hierarchy
- **What draws the eye first**: The FAB (Add button) — ✅ correct for an empty or growing list
- **Reading flow**: AppBar title → Default address (pinned top with badge) → Other addresses → FAB
- **Emphasis**: The "Default" badge should use `MarketplaceColors.primary` background with white text — same as CTA buttons

#### Consistency

| Element | Requirement |
|---------|-------------|
| Card shape | `BorderRadius.circular(MarketplaceRadius.card)` + `MarketplaceColors.stroke` 1px border |
| Default badge | Pill shape, `MarketplaceColors.primary` bg, white text, `MarketplaceTypography.smallButton` |
| Delete confirmation | Bottom sheet, `MarketplaceRadius.screen` top corners |
| Edit / Delete icons | `Icons.edit_outlined` / `Icons.delete_outline` in `MarketplaceColors.textSecondary` |
| Location icon | `Icons.location_on` in `MarketplaceColors.primary` on circular `secondary.withOpacity(0.2)` bg |

#### Accessibility
- Edit/delete icon buttons: each ≥ 44dp touch target, `semanticLabel` set
- Address label: `sectionSubheading` (16/500) — ✅ readable
- Full address: `descriptionBody` (13/400) — ✅ at 13px, ensure line height ≥ 1.4

---

### Design Critique: Add / Edit Address Screen

#### Overall Impression
Most address forms are bare text fields with no label shortcuts, making it slow to label an address. The enhanced design adds **quick-label chips** (Home / Work / Other) so tapping a chip fills the label field, and an inline "Set as Default" toggle row rather than hiding it in secondary options.

#### Usability

| Finding | Severity | Recommendation |
|---------|----------|----------------|
| Label field is free-text only — user must type "Home" every time | 🔴 Critical | Quick-label chip row: Home, Work, Other → tapping fills the label field |
| Keyboard covers the save button | 🔴 Critical | Wrap body in `SingleChildScrollView` + `resizeToAvoidBottomInset: true` |
| No inline validation feedback | 🟡 Moderate | Validate on submit; show red border + helper text under each required field |
| "Set as Default" not prominent enough | 🟡 Moderate | Full-width card row with a `Switch`, not a bare checkbox |
| No loading state on save | 🟡 Moderate | CTA shows spinner while the API call is in-flight |
| Map picker optional but completely absent | 🟢 Minor | Show a "Pin on map" tappable card below address field; if not implemented, omit gracefully |

#### Visual Hierarchy
- **What draws the eye first**: Screen title "Add Address" / "Edit Address" → label chips → address field → default toggle → Save button
- **Emphasis**: Save CTA uses same sticky-bottom-bar pattern as checkout

#### Accessibility
- All text inputs: min 48dp height, visible label above (not just placeholder)
- Error text: `Color(0xFFD32F2F)` — contrast ratio 5.6:1 on white ✅ AA
- Chip touch targets: each chip ≥ 44dp tall with horizontal padding ≥ 12dp

---

## 3. Screen Layouts

### Screen 1 — AddressBookPage

```
┌────────────────────────────────────────────┐  ← SafeArea top
│  ←   Address Book                          │  ← AppBar, no elevation
├────────────────────────────────────────────┤
│                                            │
│  ── [LOADED STATE] ──────────────────────  │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │ 📍  Home                   [Default] │  │  ← default card — green border
│  │     123 Al-Jamahiriya, Tripoli       │  │    "Default" badge top-right
│  │                         ✏️   🗑️     │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │ 📍  Work                             │  │  ← regular card
│  │     45 Omar Al-Mukhtar, Benghazi     │  │
│  │                         ✏️   🗑️     │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  ┌──────────────────────────────────────┐  │  ← "Set as default" on long-press
│  │ 📍  Mum's Place                      │  │    OR via overflow menu (⋮)
│  │     12 Airport Rd, Tripoli           │  │
│  │                         ✏️   🗑️     │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  ── [LOADING STATE] ─────────────────────  │
│  [ShimmerCard] × 2                         │
│                                            │
│  ── [EMPTY STATE] ───────────────────────  │
│           🗺️ (illustration)                │
│      No saved addresses                    │  ← sectionHeading
│      Add an address to get started         │  ← descriptionBody
│      ┌──────────────────────────────┐      │
│      │  + Add your first address    │      │  ← primary filled button
│      └──────────────────────────────┘      │
│                                            │
│                        ┌─────────┐         │  ← FAB (bottom-right)
│                        │    +    │         │    MarketplaceColors.primary
│                        └─────────┘         │    size: MarketplaceSpacing.fabSize × 2
└────────────────────────────────────────────┘
```

---

### Screen 2 — AddEditAddressPage (Add Mode)

```
┌────────────────────────────────────────────┐
│  ←   Add Address                           │  ← AppBar; "Edit Address" in edit mode
├────────────────────────────────────────────┤
│  (SingleChildScrollView)                   │
│                                            │
│  Address Label                             │  ← section label (sectionHeading)
│  ┌──────────────────────────────────────┐  │
│  │ [🏠 Home] [💼 Work] [📍 Other]      │  │  ← quick-label chip row
│  └──────────────────────────────────────┘  │
│  ┌──────────────────────────────────────┐  │
│  │  Label...                            │  │  ← TextFormField (pre-filled by chip)
│  └──────────────────────────────────────┘  │
│  ⚠️ Please enter a label                   │  ← error text (hidden unless error)
│                                            │
│  Full Address                              │
│  ┌──────────────────────────────────────┐  │
│  │                                      │  │  ← multi-line TextFormField
│  │                                      │  │    maxLines: 3
│  └──────────────────────────────────────┘  │
│  ⚠️ Please enter an address                │
│                                            │
│  ┌──────────────────────────────────────┐  │  ← "Set as Default" toggle card
│  │  Set as default address      [●  ]   │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  (bottom padding for sticky bar)          │
├────────────────────────────────────────────┤
│  ┌──────────────────────────────────────┐  │  ← sticky bottom bar
│  │           Save Address               │  │    same pattern as checkout CTA
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

---

### Screen 3 — Delete Confirmation (Bottom Sheet)

```
┌────────────────────────────────────────────┐
│  (drag handle)                             │
│                                            │
│  Delete Address?                           │  ← sectionHeading (16/500)
│  "Home — 123 Al-Jamahiriya, Tripoli"      │  ← descriptionBody, the address being deleted
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │           Delete                     │  │  ← red filled button
│  └──────────────────────────────────────┘  │
│  ┌──────────────────────────────────────┐  │
│  │           Cancel                     │  │  ← outlined/ghost button
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

---

## 4. Component Breakdown

All components are pure `StatelessWidget` + DTO.

```
lib/core/components/marketplace/address/
├── address_card.dart              ← card with label, address, default badge, edit/delete buttons
├── address_card_shimmer.dart      ← loading placeholder matching AddressCard dimensions
├── address_empty_state.dart       ← illustration + heading + CTA button
├── address_label_chips.dart       ← Home / Work / Other quick-select chip row
├── address_form_field.dart        ← reusable labeled text field with error state
├── address_default_toggle.dart    ← full-width "Set as default" switch card
└── address_delete_sheet.dart      ← bottom sheet confirmation (static helper method)
```

---

## 5. DTOs

### AddressCardDto

```dart
class AddressCardDto {
  const AddressCardDto({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final String id;
  final String label;
  final String fullAddress;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
}
```

### AddressFormDto

```dart
class AddressFormDto {
  const AddressFormDto({
    this.initialLabel,
    this.initialFullAddress,
    this.initialIsDefault = false,
  });

  final String? initialLabel;
  final String? initialFullAddress;
  final bool initialIsDefault;

  bool get isEditMode => initialLabel != null;
}
```

### AddressLabelChipsDto

```dart
/// Predefined label shortcuts shown above the label text field.
class AddressLabelChipsDto {
  const AddressLabelChipsDto({
    required this.selectedChip,
    required this.onSelect,
  });

  final AddressLabelChip? selectedChip;
  final ValueChanged<AddressLabelChip> onSelect;
}

enum AddressLabelChip {
  home,
  work,
  other;

  String get label => switch (this) {
    home  => 'Home',
    work  => 'Work',
    other => 'Other',
  };

  IconData get icon => switch (this) {
    home  => Icons.home_outlined,
    work  => Icons.work_outline,
    other => Icons.location_on_outlined,
  };
}
```

### AddressDefaultToggleDto

```dart
class AddressDefaultToggleDto {
  const AddressDefaultToggleDto({
    required this.isDefault,
    required this.onChanged,
  });

  final bool isDefault;
  final ValueChanged<bool> onChanged;
}
```

### AddressEmptyStateDto

```dart
class AddressEmptyStateDto {
  const AddressEmptyStateDto({
    required this.onAddAddress,
  });

  final VoidCallback onAddAddress;
}
```

---

## 6. Domain Layer

### Expand AddressEntity

Add `fromModel` factory and `copyWith` to `AddressEntity`:

```dart
// lib/domain/entities/marketplace/address_entity.dart
import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressEntity copyWith({
    String? id,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, label, fullAddress, latitude, longitude, isDefault];
}
```

### Use Cases

Create all in `lib/domain/usecases/marketplace/address/`:

```dart
// get_addresses_use_case.dart
class GetAddressesUseCase
    extends NoInputUseCase<List<AddressEntity>, AddressRepository> {
  GetAddressesUseCase(super.repository);

  @override
  Future<AppState<List<AddressEntity>>> call(void input) async {
    final result = await repository.getAddresses();
    return resultToListState(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
```

```dart
// create_address_use_case.dart
class CreateAddressUseCase
    extends BaseUseCase<CreateAddressRequest, AddressEntity, AddressRepository> {
  CreateAddressUseCase(super.repository);

  @override
  Future<AppState<AddressEntity>> call(CreateAddressRequest input) async {
    final result = await repository.createAddress(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
```

```dart
// update_address_use_case.dart
class UpdateAddressUseCase
    extends BaseUseCase<UpdateAddressRequest, AddressEntity, AddressRepository> {
  UpdateAddressUseCase(super.repository);

  @override
  Future<AppState<AddressEntity>> call(UpdateAddressRequest input) async {
    final result = await repository.updateAddress(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
```

```dart
// delete_address_use_case.dart
class DeleteAddressUseCase
    extends VoidUseCase<String, AddressRepository> {
  DeleteAddressUseCase(super.repository);

  @override
  Future<AppState<void>> call(String id) async {
    final result = await repository.deleteAddress(id);
    return resultToState(result: result);
  }
}
```

```dart
// set_default_address_use_case.dart
class SetDefaultAddressUseCase
    extends VoidUseCase<String, AddressRepository> {
  SetDefaultAddressUseCase(super.repository);

  @override
  Future<AppState<void>> call(String id) async {
    final result = await repository.setDefaultAddress(id);
    return resultToState(result: result);
  }
}
```

### Request Models

```dart
// lib/data/models/marketplace/create_address_request.dart
class CreateAddressRequest {
  const CreateAddressRequest({
    required this.label,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  final String label;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    'label': label,
    'full_address': fullAddress,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'is_default': isDefault,
  };
}
```

```dart
// lib/data/models/marketplace/update_address_request.dart
class UpdateAddressRequest {
  const UpdateAddressRequest({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    'label': label,
    'full_address': fullAddress,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'is_default': isDefault,
  };
}
```

---

## 7. Data Layer

### Fix AddressModel JSON Keys

The existing `AddressModel.fromJson` uses camelCase keys. APIs typically return snake_case. Update the model:

```dart
// lib/data/models/marketplace/address_model.dart
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';

class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),                         // handle int or string
      label: json['label'] as String,
      fullAddress: (json['full_address'] ?? json['fullAddress']) as String,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      isDefault: (json['is_default'] ?? json['isDefault']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'full_address': fullAddress,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
  };

  AddressEntity toEntity() => AddressEntity(
    id: id,
    label: label,
    fullAddress: fullAddress,
    latitude: latitude,
    longitude: longitude,
    isDefault: isDefault,
  );
}
```

### AddressRepository

```dart
// lib/data/repositories/address_repository.dart
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/address_model.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/data/models/marketplace/update_address_request.dart';
import 'package:marketplace/data/services/api_service.dart';

class AddressRepository {
  const AddressRepository(this._api);

  final ApiService _api;

  static const _base = '/client/api/v1/addresses';

  /// GET /client/api/v1/addresses
  Future<Result<List<AddressModel>>> getAddresses() =>
      _api.getList(
        _base,
        (item) => AddressModel.fromJson(item as Map<String, dynamic>),
      );

  /// POST /client/api/v1/addresses
  Future<Result<AddressModel>> createAddress(CreateAddressRequest request) =>
      _api.post(
        _base,
        (data) => AddressModel.fromJson(data as Map<String, dynamic>),
        body: request.toJson(),
      );

  /// PUT /client/api/v1/addresses/{id}
  Future<Result<AddressModel>> updateAddress(UpdateAddressRequest request) =>
      _api.put(
        '$_base/${request.id}',
        (data) => AddressModel.fromJson(data as Map<String, dynamic>),
        body: request.toJson(),
      );

  /// DELETE /client/api/v1/addresses/{id}
  Future<Result<void>> deleteAddress(String id) =>
      _api.delete('$_base/$id');

  /// PATCH /client/api/v1/addresses/{id}/set-default
  Future<Result<void>> setDefaultAddress(String id) =>
      _api.patch('$_base/$id/set-default', (data) => null, body: {});
}
```

> **Note:** `_api.getList`, `_api.put`, `_api.delete`, `_api.patch` — add these to `ApiService` if they don't exist yet, following the same pattern as `_api.post`.

---

## 8. Controller Implementation

### AddressesController

```dart
// lib/presentation/controllers/addresses_controller.dart
import 'package:get/get.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/delete_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/set_default_address_use_case.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_keys.dart';

class AddressesController extends GetxController {
  AddressesController({
    required this.getAddressesUseCase,
    required this.deleteAddressUseCase,
    required this.setDefaultAddressUseCase,
  });

  final GetAddressesUseCase getAddressesUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;

  // ── State ─────────────────────────────────────────────────
  final RxList<AddressEntity> addresses = <AddressEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString? deletingId = ''.obs;   // tracks which item is being deleted

  // ── Computed ──────────────────────────────────────────────
  bool get isEmpty => !isLoading.value && addresses.isEmpty;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // ── Public Actions ────────────────────────────────────────
  Future<void> loadAddresses() async {
    isLoading.value = true;
    final result = await getAddressesUseCase.execute();

    result.when(
      success: (list) {
        // Default address always first
        final sorted = [...list]..sort((a, b) => b.isDefault ? 1 : -1);
        addresses.assignAll(sorted);
      },
      failure: (error) {
        Get.snackbar(
          LocaleKeys.error.tr,
          error ?? LocaleKeys.genericError.tr,
        );
      },
    );

    isLoading.value = false;
  }

  void navigateToAdd() {
    Get.toNamed(Routes.MARKETPLACE_ADD_ADDRESS)?.then((_) => loadAddresses());
  }

  void navigateToEdit(AddressEntity address) {
    Get.toNamed(
      Routes.MARKETPLACE_ADD_ADDRESS,
      arguments: address,
    )?.then((_) => loadAddresses());
  }

  /// Shows bottom sheet confirmation, then deletes on confirm.
  Future<void> confirmDelete(AddressEntity address) async {
    final confirmed = await _showDeleteConfirmation(address);
    if (confirmed != true) return;

    deletingId?.value = address.id;
    final result = await deleteAddressUseCase(address.id);

    result.when(
      success: (_) {
        addresses.removeWhere((a) => a.id == address.id);
        Get.snackbar(
          LocaleKeys.deleted.tr,
          LocaleKeys.addressDeleted.tr,
          backgroundColor: const Color(0xFFEFEFEF),
        );
      },
      failure: (error) {
        Get.snackbar(LocaleKeys.error.tr, error ?? LocaleKeys.genericError.tr);
      },
    );

    deletingId?.value = '';
  }

  Future<void> setDefault(AddressEntity address) async {
    if (address.isDefault) return;

    final result = await setDefaultAddressUseCase(address.id);

    result.when(
      success: (_) {
        // Optimistic update — flip flags locally
        final updated = addresses.map((a) {
          return a.copyWith(isDefault: a.id == address.id);
        }).toList();
        updated.sort((a, b) => b.isDefault ? 1 : -1);
        addresses.assignAll(updated);

        Get.snackbar(
          LocaleKeys.defaultAddressSet.tr,
          '${address.label} ${LocaleKeys.isNowDefault.tr}',
          backgroundColor: MarketplaceColors.secondary,
          colorText: MarketplaceColors.textBody,
        );
      },
      failure: (error) {
        Get.snackbar(LocaleKeys.error.tr, error ?? LocaleKeys.genericError.tr);
      },
    );
  }

  // ── Private ───────────────────────────────────────────────
  Future<bool?> _showDeleteConfirmation(AddressEntity address) {
    return Get.bottomSheet<bool>(
      _DeleteConfirmationSheet(address: address),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
```

### AddEditAddressController

```dart
// lib/presentation/controllers/add_edit_address_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/create_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/update_address_use_case.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/data/models/marketplace/update_address_request.dart';
import 'package:marketplace/core/components/marketplace/address/address_label_chips.dart';

class AddEditAddressController extends GetxController {
  AddEditAddressController({
    required this.createAddressUseCase,
    required this.updateAddressUseCase,
  });

  final CreateAddressUseCase createAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;

  // ── Form controllers ──────────────────────────────────────
  final labelController = TextEditingController();
  final fullAddressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ── Reactive state ────────────────────────────────────────
  final Rx<AddressLabelChip?> selectedChip = Rx(null);
  final RxBool isDefault = false.obs;
  final RxBool isSaving = false.obs;

  // ── Mode ──────────────────────────────────────────────────
  AddressEntity? _editingAddress;
  bool get isEditMode => _editingAddress != null;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _editingAddress = Get.arguments as AddressEntity?;

    if (_editingAddress != null) {
      labelController.text = _editingAddress!.label;
      fullAddressController.text = _editingAddress!.fullAddress;
      isDefault.value = _editingAddress!.isDefault;

      // Pre-select matching chip
      try {
        selectedChip.value = AddressLabelChip.values.firstWhere(
          (c) => c.label.toLowerCase() == _editingAddress!.label.toLowerCase(),
        );
      } catch (_) {
        // No matching chip — leave null (free-text)
      }
    }
  }

  @override
  void onClose() {
    labelController.dispose();
    fullAddressController.dispose();
    super.onClose();
  }

  // ── Actions ───────────────────────────────────────────────
  void selectChip(AddressLabelChip chip) {
    selectedChip.value = chip;
    labelController.text = chip.label;
  }

  void toggleDefault(bool value) => isDefault.value = value;

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;

    if (isEditMode) {
      await _update();
    } else {
      await _create();
    }

    isSaving.value = false;
  }

  // ── Private ───────────────────────────────────────────────
  Future<void> _create() async {
    final request = CreateAddressRequest(
      label: labelController.text.trim(),
      fullAddress: fullAddressController.text.trim(),
      isDefault: isDefault.value,
    );

    final result = await createAddressUseCase(request);

    result.when(
      success: (_) => Get.back(result: true),
      failure: (error) {
        Get.snackbar(LocaleKeys.error.tr, error ?? LocaleKeys.genericError.tr);
      },
    );
  }

  Future<void> _update() async {
    final request = UpdateAddressRequest(
      id: _editingAddress!.id,
      label: labelController.text.trim(),
      fullAddress: fullAddressController.text.trim(),
      isDefault: isDefault.value,
    );

    final result = await updateAddressUseCase(request);

    result.when(
      success: (_) => Get.back(result: true),
      failure: (error) {
        Get.snackbar(LocaleKeys.error.tr, error ?? LocaleKeys.genericError.tr);
      },
    );
  }
}
```

---

## 9. Binding & Routes

### AddressesBinding

```dart
// lib/presentation/pages/marketplace/account/bindings/addresses_binding.dart
import 'package:get/get.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/delete_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/set_default_address_use_case.dart';
import 'package:marketplace/presentation/controllers/addresses_controller.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<GetAddressesUseCase>(
      () => GetAddressesUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<DeleteAddressUseCase>(
      () => DeleteAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<SetDefaultAddressUseCase>(
      () => SetDefaultAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<AddressesController>(
      () => AddressesController(
        getAddressesUseCase: Get.find<GetAddressesUseCase>(),
        deleteAddressUseCase: Get.find<DeleteAddressUseCase>(),
        setDefaultAddressUseCase: Get.find<SetDefaultAddressUseCase>(),
      ),
    );
  }
}
```

### AddEditAddressBinding

```dart
// lib/presentation/pages/marketplace/account/bindings/add_edit_address_binding.dart
import 'package:get/get.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/address/create_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/update_address_use_case.dart';
import 'package:marketplace/presentation/controllers/add_edit_address_controller.dart';

class AddEditAddressBinding extends Bindings {
  @override
  void dependencies() {
    // AddressRepository may already be registered from AddressesBinding
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CreateAddressUseCase>(
      () => CreateAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<UpdateAddressUseCase>(
      () => UpdateAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<AddEditAddressController>(
      () => AddEditAddressController(
        createAddressUseCase: Get.find<CreateAddressUseCase>(),
        updateAddressUseCase: Get.find<UpdateAddressUseCase>(),
      ),
    );
  }
}
```

### Routes to Add in app_routes.dart

```dart
static const MARKETPLACE_ADD_ADDRESS = '/marketplace/add-address';
```

> `MARKETPLACE_ADDRESSES` already exists. Reuse it for the list page.
> `MARKETPLACE_ADD_ADDRESS` is new — handles both add and edit (mode determined by `Get.arguments`).

### Register in app_pages.dart

```dart
GetPage(
  name: Routes.MARKETPLACE_ADDRESSES,
  page: () => const AddressBookPage(),
  binding: AddressesBinding(),
),
GetPage(
  name: Routes.MARKETPLACE_ADD_ADDRESS,
  page: () => const AddEditAddressPage(),
  binding: AddEditAddressBinding(),
),
```

---

## 10. Localization Keys

Add to `locale_keys.dart`:

```dart
static const addressBook         = 'address_book';       // already exists
static const addAddress          = 'add_address';
static const editAddress         = 'edit_address';
static const addressLabel        = 'address_label';
static const fullAddress         = 'full_address';
static const setAsDefault        = 'set_as_default';
static const saveAddress         = 'save_address';
static const deleteAddress       = 'delete_address';
static const deleteAddressConfirm = 'delete_address_confirm';
static const addressDeleted      = 'address_deleted';
static const defaultAddressSet   = 'default_address_set';
static const isNowDefault        = 'is_now_default';
static const noAddresses         = 'no_addresses';
static const noAddressesMessage  = 'no_addresses_message';
static const addFirstAddress     = 'add_first_address';
static const defaultBadge        = 'default_badge';
static const labelRequired       = 'label_required';
static const addressRequired     = 'address_required';
static const deleted             = 'deleted';
static const genericError        = 'generic_error';   // may already exist
```

Add to `en.dart`:

```dart
'add_address':              'Add Address',
'edit_address':             'Edit Address',
'address_label':            'Address Label',
'full_address':             'Full Address',
'set_as_default':           'Set as default address',
'save_address':             'Save Address',
'delete_address':           'Delete Address',
'delete_address_confirm':   'This address will be permanently removed.',
'address_deleted':          'Address has been deleted.',
'default_address_set':      'Default address updated',
'is_now_default':           'is now your default address.',
'no_addresses':             'No saved addresses',
'no_addresses_message':     'Add an address to speed up your checkout.',
'add_first_address':        'Add your first address',
'default_badge':            'Default',
'label_required':           'Please enter a label',
'address_required':         'Please enter an address',
'deleted':                  'Deleted',
```

Add to `ar.dart`:

```dart
'add_address':              'إضافة عنوان',
'edit_address':             'تعديل العنوان',
'address_label':            'اسم العنوان',
'full_address':             'العنوان الكامل',
'set_as_default':           'تعيين كعنوان افتراضي',
'save_address':             'حفظ العنوان',
'delete_address':           'حذف العنوان',
'delete_address_confirm':   'سيتم حذف هذا العنوان نهائيًا.',
'address_deleted':          'تم حذف العنوان.',
'default_address_set':      'تم تحديث العنوان الافتراضي',
'is_now_default':           'هو عنوانك الافتراضي الآن.',
'no_addresses':             'لا توجد عناوين محفوظة',
'no_addresses_message':     'أضف عنوانًا لتسريع عملية الدفع.',
'add_first_address':        'أضف عنوانك الأول',
'default_badge':            'افتراضي',
'label_required':           'يرجى إدخال اسم للعنوان',
'address_required':         'يرجى إدخال العنوان',
'deleted':                  'تم الحذف',
```

---

## 11. File Structure

```
lib/
├── core/
│   ├── components/marketplace/address/
│   │   ├── address_card.dart
│   │   ├── address_card_shimmer.dart
│   │   ├── address_empty_state.dart
│   │   ├── address_label_chips.dart
│   │   ├── address_form_field.dart
│   │   ├── address_default_toggle.dart
│   │   └── address_delete_sheet.dart
│   └── localization/
│       ├── locale_keys.dart         ← add address keys
│       ├── en.dart                  ← add English strings
│       └── ar.dart                  ← add Arabic strings
│
├── domain/
│   ├── entities/marketplace/
│   │   └── address_entity.dart      ← add copyWith
│   └── usecases/marketplace/address/
│       ├── get_addresses_use_case.dart
│       ├── create_address_use_case.dart
│       ├── update_address_use_case.dart
│       ├── delete_address_use_case.dart
│       └── set_default_address_use_case.dart
│
├── data/
│   ├── models/marketplace/
│   │   ├── address_model.dart          ← fix snake_case JSON keys
│   │   ├── create_address_request.dart
│   │   └── update_address_request.dart
│   └── repositories/
│       └── address_repository.dart
│
└── presentation/
    ├── controllers/
    │   ├── addresses_controller.dart
    │   └── add_edit_address_controller.dart
    └── pages/marketplace/account/
        ├── address_book_page.dart       ← replace placeholder
        ├── add_edit_address_page.dart   ← new
        └── bindings/
            ├── addresses_binding.dart
            └── add_edit_address_binding.dart
```

---

## 12. Implementation Checklist

### Domain Layer
- [ ] Add `copyWith` to `AddressEntity`
- [ ] Create `GetAddressesUseCase` extending `NoInputUseCase`
- [ ] Create `CreateAddressUseCase`
- [ ] Create `UpdateAddressUseCase`
- [ ] Create `DeleteAddressUseCase` extending `VoidUseCase<String, ...>`
- [ ] Create `SetDefaultAddressUseCase` extending `VoidUseCase<String, ...>`

### Data Layer
- [ ] Fix `AddressModel.fromJson` to handle both `full_address` and `fullAddress` JSON keys, and `is_default` / `isDefault`
- [ ] Handle `id` as `toString()` (API may return int)
- [ ] Create `CreateAddressRequest` with snake_case `toJson()`
- [ ] Create `UpdateAddressRequest` with `id` + snake_case fields
- [ ] Create `AddressRepository` with all 5 methods
- [ ] Add `getList`, `put`, `delete`, `patch` to `ApiService` if missing

### DTOs
- [ ] `AddressCardDto` with all 6 fields + 3 callbacks
- [ ] `AddressFormDto`
- [ ] `AddressLabelChipsDto` + `AddressLabelChip` enum
- [ ] `AddressDefaultToggleDto`
- [ ] `AddressEmptyStateDto`

### Components
- [ ] `AddressCard` — green location icon in circle bg, label + fullAddress, edit+delete buttons, "Default" badge via `_DefaultBadge` private widget; long-press calls `onSetDefault`
- [ ] `AddressCardShimmer` — shimmer placeholder matching exact card height
- [ ] `AddressEmptyState` — map illustration, heading, description, "Add your first address" primary button
- [ ] `AddressLabelChips` — horizontal `Wrap` of chips: Home/Work/Other; selected chip = green filled, others = outlined
- [ ] `AddressFormField` — label text above + `TextFormField` with border + error helper below
- [ ] `AddressDefaultToggle` — full-width card with `SwitchListTile.adaptive` — no custom switch needed
- [ ] `AddressDeleteSheet` — static `show()` method; returns `Future<bool?>`; uses `MarketplaceRadius.screenBR` top corners

### AddressBookPage
- [ ] `AddressBookPage extends GetView<AddressesController>`
- [ ] `Obx` wraps body: shows `_LoadingView` / `AddressEmptyState` / `_AddressList`
- [ ] `_AddressList` is a `ListView.separated` mapped from `controller.addresses`
- [ ] Each item passes `onEdit: () => controller.navigateToEdit(address)`, `onDelete: () => controller.confirmDelete(address)`, `onSetDefault: () => controller.setDefault(address)`
- [ ] FAB calls `controller.navigateToAdd()`
- [ ] `_LoadingView` renders `AddressCardShimmer` × 2

### AddEditAddressPage
- [ ] `AddEditAddressPage extends GetView<AddEditAddressController>`
- [ ] AppBar title switches: `isEditMode ? LocaleKeys.editAddress : LocaleKeys.addAddress`
- [ ] `Form` with `formKey` wrapping all fields inside `SingleChildScrollView`
- [ ] `Obx` wraps the chip row to reflect `selectedChip.value`
- [ ] `Obx` wraps the default toggle to reflect `isDefault.value`
- [ ] `AddressFormField` for label — validator: required, min 1 char
- [ ] `AddressFormField` for fullAddress — validator: required, min 5 chars
- [ ] `Obx` wraps sticky bottom bar — shows spinner when `isSaving.value`, otherwise "Save Address"

### Bindings & Routes
- [ ] Create `AddressesBinding`
- [ ] Create `AddEditAddressBinding` with `fenix: true` on `AddressRepository`
- [ ] Add `MARKETPLACE_ADD_ADDRESS` to `app_routes.dart`
- [ ] Register both pages in `app_pages.dart`

### Localization
- [ ] Add all keys to `locale_keys.dart`
- [ ] Add English strings to `en.dart`
- [ ] Add Arabic strings to `ar.dart`

### Checkout Integration
- [ ] `CheckoutController._loadAddresses()` calls `GetAddressesUseCase` (wire real use case, remove stub)
- [ ] `CheckoutAddressDto.id` type: verify `String` or `int` consistency — `AddressEntity.id` is `String`, use `int.parse(id)` in the checkout payload if API expects int

### QA & Edge Cases
- [ ] User deletes their default address → list refreshes, no address is default → show no badge
- [ ] User deletes last address → empty state shown
- [ ] Back from Add/Edit refreshes the list (`.then((_) => loadAddresses())`)
- [ ] Arabic RTL: edit/delete icons appear on the left side of the card
- [ ] Very long address text wraps gracefully (not truncated with overflow)
- [ ] "Set as default" on an already-default address is a no-op (guarded in controller)
