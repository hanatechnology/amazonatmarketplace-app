import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/components/marketplace/address/address_label_chips.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/data/models/marketplace/update_address_request.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/entities/marketplace/city_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/create_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_cities_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/update_address_use_case.dart';

const String kSaveAddress  = 'save_address';
const String kAddrCities   = 'addr_cities';

class AddEditAddressController extends BaseStateController<CreateAddressUseCase> {
  late final UpdateAddressUseCase _updateAddress;
  late final GetCitiesUseCase _getCities;

  // ── Form controllers ──────────────────────────────────────
  final labelController        = TextEditingController();
  final fullNameController     = TextEditingController();
  final phoneController        = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final stateController        = TextEditingController();
  final countryController      = TextEditingController();
  final postalCodeController   = TextEditingController();
  final formKey                = GlobalKey<FormState>();

  // ── Reactive state ────────────────────────────────────────
  final Rx<AddressLabelChip?> selectedChip = Rx(null);
  final RxList<CityEntity> cities          = <CityEntity>[].obs;
  final Rx<CityEntity?> selectedCity       = Rx(null);
  final RxBool isDefault                   = false.obs;

  // ── Derived loading flags (reactive inside Obx) ───────────
  bool get isSaving       => stateFor<AddressEntity>(kSaveAddress).value.isLoading;
  bool get isCitiesLoading => stateFor<List<CityEntity>>(kAddrCities).value.isLoading;

  // ── Mode ──────────────────────────────────────────────────
  AddressEntity? _editingAddress;
  bool get isEditMode => _editingAddress != null;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit(); // resolves useCase = CreateAddressUseCase via Get.find
    _updateAddress  = Get.find<UpdateAddressUseCase>();
    _getCities      = Get.find<GetCitiesUseCase>();
    _editingAddress = Get.arguments as AddressEntity?;
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
    countryController.dispose();
    postalCodeController.dispose();
    super.onClose();
  }

  // ── Cities ────────────────────────────────────────────────
  Future<void> _loadCities() => handleState<List<CityEntity>>(
        kAddrCities,
        () async => await _getCities.execute(),
        onSuccess: (list, _) {
          cities.assignAll(list);
          _prefillForm();
        },
        onError: (message, _) {
          Get.snackbar(LocaleKeys.error.tr, message);
          _prefillForm(); // still pre-fill other fields
        },
      );

  void _prefillForm() {
    if (_editingAddress == null) return;
    final addr = _editingAddress!;

    labelController.text        = addr.label;
    fullNameController.text     = addr.fullName;
    phoneController.text        = addr.phone;
    addressLine1Controller.text = addr.addressLine1;
    addressLine2Controller.text = addr.addressLine2 ?? '';
    stateController.text        = addr.state;
    countryController.text      = addr.country;
    postalCodeController.text   = addr.postalCode ?? '';
    isDefault.value             = addr.isDefault;

    try {
      selectedChip.value = AddressLabelChip.values.firstWhere(
        (c) => c.label.toLowerCase() == addr.label.toLowerCase(),
      );
    } catch (_) {}

    try {
      selectedCity.value = cities.firstWhere((c) => c.id == addr.cityId);
    } catch (_) {}
  }

  // ── Actions ───────────────────────────────────────────────
  void selectChip(AddressLabelChip chip) {
    selectedChip.value  = chip;
    labelController.text = chip.label;
  }

  void selectCity(CityEntity? city) => selectedCity.value = city;

  void toggleDefault(bool value) => isDefault.value = value;

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    isEditMode ? await _update() : await _create();
  }

  // ── Private ───────────────────────────────────────────────
  Future<void> _create() => handleState<AddressEntity>(
        kSaveAddress,
        () async => await useCase(CreateAddressRequest(
          label:        labelController.text.trim(),
          fullName:     fullNameController.text.trim(),
          phone:        phoneController.text.trim(),
          addressLine1: addressLine1Controller.text.trim(),
          addressLine2: addressLine2Controller.text.trim(),
          cityId:       selectedCity.value!.id,
          state:        stateController.text.trim(),
          country:      countryController.text.trim(),
          postalCode:   postalCodeController.text.trim(),
          isDefault:    isDefault.value,
        )),
        onSuccess: (_, __) => Get.back(result: true),
        onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
      );

  Future<void> _update() => handleState<AddressEntity>(
        kSaveAddress,
        () async => await _updateAddress(UpdateAddressRequest(
          id:           _editingAddress!.id,
          label:        labelController.text.trim(),
          fullName:     fullNameController.text.trim(),
          phone:        phoneController.text.trim(),
          addressLine1: addressLine1Controller.text.trim(),
          addressLine2: addressLine2Controller.text.trim(),
          cityId:       selectedCity.value!.id,
          state:        stateController.text.trim(),
          country:      countryController.text.trim(),
          postalCode:   postalCodeController.text.trim(),
          isDefault:    isDefault.value,
        )),
        onSuccess: (_, __) => Get.back(result: true),
        onError: (message, _) => Get.snackbar(LocaleKeys.error.tr, message),
      );
}
