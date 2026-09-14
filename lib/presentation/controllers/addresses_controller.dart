import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/entities/marketplace/city_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/delete_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_cities_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/set_default_address_use_case.dart';
import 'package:marketplace/core/components/marketplace/address/address_delete_sheet.dart';

const String kAddresses = 'addresses';

class AddressesController extends BaseStateController<GetAddressesUseCase> {
  late final DeleteAddressUseCase _deleteAddress;
  late final SetDefaultAddressUseCase _setDefault;
  late final GetCitiesUseCase _getCities;

  // ── State ─────────────────────────────────────────────────
  final RxList<AddressEntity> addresses = <AddressEntity>[].obs;
  final RxList<CityEntity> cities       = <CityEntity>[].obs;
  final RxString deletingId             = ''.obs;

  // ── Computed ──────────────────────────────────────────────
  /// Reactive inside any [Obx] — reads [kAddresses] state.
  bool get isLoading =>
      stateFor<List<AddressEntity>>(kAddresses).value.isLoading;

  bool get isEmpty => !isLoading && addresses.isEmpty;

  /// Returns the localised city name for [cityId], falls back to the id.
  String cityNameFor(String cityId) {
    try {
      final city = cities.firstWhere((c) => c.id == cityId);
      return Get.locale?.languageCode == 'ar' ? city.nameAr : city.nameEn;
    } catch (_) {
      return cityId;
    }
  }

  // ── Pick mode ─────────────────────────────────────────────
  /// True when opened from checkout to select a delivery address.
  bool get pickMode {
    final args = Get.arguments;
    return args is Map && args['pickMode'] == true;
  }

  /// Called in pick mode — returns the address to the previous route.
  void pickAddress(AddressEntity address) => Get.back(result: address);

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit(); // resolves useCase = GetAddressesUseCase via Get.find
    _deleteAddress = Get.find<DeleteAddressUseCase>();
    _setDefault    = Get.find<SetDefaultAddressUseCase>();
    _getCities     = Get.find<GetCitiesUseCase>();
    _loadAll();
  }

  // ── Data loading ──────────────────────────────────────────
  Future<void> _loadAll() => Future.wait([loadAddresses(), _loadCities()]);

  Future<void> loadAddresses() => handleState<List<AddressEntity>>(
        kAddresses,
        () async => await useCase.execute(),
        onSuccess: (list, _) {
          final sorted = [...list]..sort((a, b) => b.isDefault ? 1 : -1);
          addresses.assignAll(sorted);
        },
      );

  Future<void> _loadCities() async {
    final result = await _getCities.execute();
    result.maybeWhen(
      onSuccess: (list, _) => cities.assignAll(list),
      onError: (_, __) {}, // non-fatal — city names degrade to IDs
    );
  }

  // ── Navigation ────────────────────────────────────────────
  void navigateToAdd() {
    Get.toNamed(Routes.MARKETPLACE_ADD_ADDRESS)
        ?.then((_) => loadAddresses());
  }

  // ── Delete ────────────────────────────────────────────────
  Future<void> confirmDelete(AddressEntity address) async {
    final confirmed = await AddressDeleteSheet.show(address);
    if (confirmed != true) return;

    deletingId.value = address.id;
    final result = await _deleteAddress(address.id);

    result.maybeWhen(
      onSuccess: (_, __) {
        addresses.removeWhere((a) => a.id == address.id);
        Get.snackbar(
          LocaleKeys.deleted.tr,
          LocaleKeys.addressDeleted.tr,
          backgroundColor: const Color(0xFFEFEFEF),
          colorText: MarketplaceColors.textBody,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
    );

    deletingId.value = '';
  }

  // ── Set default ───────────────────────────────────────────
  Future<void> setDefault(AddressEntity address) async {
    if (address.isDefault) return;

    final result = await _setDefault(address.id);
    result.maybeWhen(
      onSuccess: (_, __) {
        final updated = addresses
            .map((a) => a.copyWith(isDefault: a.id == address.id))
            .toList()
          ..sort((a, b) => b.isDefault ? 1 : -1);
        addresses.assignAll(updated);

        Get.snackbar(
          LocaleKeys.defaultAddressSet.tr,
          '${address.label} ${LocaleKeys.isNowDefault.tr}',
          backgroundColor: MarketplaceColors.secondary,
          colorText: MarketplaceColors.textBody,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.check_circle, color: MarketplaceColors.primary),
        );
      },
      onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
    );
  }
}
