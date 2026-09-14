import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/components/marketplace/address/address_label_chips.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/utils/phone_utils.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/entities/marketplace/address_location.dart';
import 'package:marketplace/domain/entities/marketplace/city_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/create_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_cities_use_case.dart';

const String kSaveAddress = 'save_address';
const String kAddrCities = 'addr_cities';

/// Add one delivery address.
///
/// Required by `CreateAddressDto`, and required here: `full_name`, `phone`,
/// `address_line_1`, `city_id`, `location`. Everything else is optional in the
/// spec and optional here — the previous form demanded `label`, `state` and
/// `country` as well, rejecting customers the backend would have accepted, and
/// never collected `location` at all, which made every save a 400.
///
/// A saved address is final: it can be made default or deleted, never edited.
/// A wrong address is replaced, not amended, so a courier is never handed a
/// half-corrected one.
class AddAddressController
    extends BaseStateController<CreateAddressUseCase> {
  late final GetCitiesUseCase _getCities;

  // ── Form controllers ──────────────────────────────────────
  final labelController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final stateController = TextEditingController();

  // ── Reactive state ────────────────────────────────────────
  final Rx<AddressLabelChip?> selectedChip = Rx(null);
  final RxList<CityEntity> cities = <CityEntity>[].obs;
  final Rx<CityEntity?> selectedCity = Rx(null);
  final RxBool isDefault = false.obs;
  final Rx<AddressLocation?> location = Rx(null);

  // ── Per-field errors, surfaced only after a submit attempt ─
  final fullNameError = RxnString();
  final phoneError = RxnString();
  final cityError = RxnString();
  final addressLine1Error = RxnString();
  final locationError = RxnString();

  /// How many fields the summary banner should name. Zero hides it.
  int get errorCount => [
        fullNameError.value,
        phoneError.value,
        cityError.value,
        addressLine1Error.value,
        locationError.value,
      ].whereType<String>().length;

  // ── Derived loading flags (reactive inside Obx) ───────────
  bool get isSaving =>
      stateFor<AddressEntity>(kSaveAddress).value.isLoading;
  bool get isCitiesLoading =>
      stateFor<List<CityEntity>>(kAddrCities).value.isLoading;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit(); // resolves useCase = CreateAddressUseCase via Get.find
    _getCities = Get.find<GetCitiesUseCase>();
    _loadCities();
  }

  @override
  void onClose() {
    labelController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    stateController.dispose();
    super.onClose();
  }

  // ── Cities ────────────────────────────────────────────────
  Future<void> _loadCities() => handleState<List<CityEntity>>(
        kAddrCities,
        () async => await _getCities.execute(),
        onSuccess: (list, _) => cities.assignAll(list),
        onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
      );

  // ── Actions ───────────────────────────────────────────────
  void selectChip(AddressLabelChip chip) {
    selectedChip.value = chip;
    labelController.text = chip.label;
  }

  void selectCity(CityEntity? city) {
    selectedCity.value = city;
    if (city != null) cityError.value = null;
  }

  void toggleDefault(bool value) => isDefault.value = value;

  void setLocation(AddressLocation? picked) {
    if (picked == null) return;
    // The picker reads the readable half off the device geocoder. It comes back
    // empty when the geocoder had nothing for that point — then, and only then,
    // the form's own fields stand in, because `location.address` is required.
    final resolved = picked.address.trim();
    location.value = picked.copyWith(
      address: resolved.isNotEmpty ? resolved : _composedAddress(),
    );
    locationError.value = null;
  }

  /// What goes into `location.address` — the line the courier reads.
  String _composedAddress() {
    final parts = [
      addressLine1Controller.text.trim(),
      stateController.text.trim(),
      selectedCity.value?.name ?? '',
    ].where((part) => part.isNotEmpty);
    return parts.join('، ');
  }

  /// Full E.164 number for the API, built from the national digits typed.
  String get _phoneForApi =>
      PhoneUtils.normalize('${PhoneUtils.countryCode}${phoneController.text.trim()}');

  bool validate() {
    fullNameError.value =
        fullNameController.text.trim().isEmpty ? LocaleKeys.labelRequired.tr : null;

    phoneError.value = PhoneUtils.isValid(_phoneForApi)
        ? null
        : LocaleKeys.invalidLibyanPhone.tr;

    cityError.value =
        selectedCity.value == null ? LocaleKeys.labelRequired.tr : null;

    addressLine1Error.value = addressLine1Controller.text.trim().length < 3
        ? LocaleKeys.addressRequired.tr
        : null;

    locationError.value =
        location.value == null ? LocaleKeys.locationRequired.tr : null;

    return errorCount == 0;
  }

  Future<void> save() async {
    if (!validate()) return;
    await _create();
  }

  // ── Private ───────────────────────────────────────────────
  Future<void> _create() => handleState<AddressEntity>(
        kSaveAddress,
        () async => await useCase(
          CreateAddressRequest(
            fullName: fullNameController.text.trim(),
            phone: _phoneForApi,
            addressLine1: addressLine1Controller.text.trim(),
            cityId: selectedCity.value!.id,
            location: location.value!.copyWith(address: _composedAddress()),
            label: labelController.text.trim(),
            addressLine2: addressLine2Controller.text.trim(),
            state: stateController.text.trim(),
            isDefault: isDefault.value,
          ),
        ),
        onSuccess: (_, __) => Get.back(result: true),
        onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
      );
}
