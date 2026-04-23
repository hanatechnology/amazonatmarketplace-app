import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/components/marketplace/address/address_default_toggle.dart';
import 'package:marketplace/core/components/marketplace/address/address_form_field.dart';
import 'package:marketplace/core/components/marketplace/address/address_label_chips.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/domain/entities/marketplace/city_entity.dart';
import 'package:marketplace/presentation/controllers/add_edit_address_controller.dart';

class AddEditAddressPage extends GetView<AddEditAddressController> {
  const AddEditAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: MarketplaceColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: MarketplaceColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.isEditMode
              ? LocaleKeys.editAddress.tr
              : LocaleKeys.addAddress.tr,
          style: const TextStyle(
            color: MarketplaceColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MarketplaceSpacing.md),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label ─────────────────────────────────────
                    Text(
                      LocaleKeys.addressLabel.tr,
                      style: MarketplaceTypography.sectionHeading,
                    ),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    Obx(() => AddressLabelChips(
                          dto: AddressLabelChipsDto(
                            selectedChip: controller.selectedChip.value,
                            onSelect: controller.selectChip,
                          ),
                        )),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    AddressFormField(
                      label: '',
                      hint: LocaleKeys.addressLabel.tr,
                      controller: controller.labelController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? LocaleKeys.labelRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Full name ─────────────────────────────────
                    AddressFormField(
                      label: LocaleKeys.recipientName.tr,
                      hint: LocaleKeys.recipientName.tr,
                      controller: controller.fullNameController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? LocaleKeys.labelRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Phone ─────────────────────────────────────
                    AddressFormField(
                      label: LocaleKeys.phoneNumber.tr,
                      hint: LocaleKeys.phoneHint.tr,
                      controller: controller.phoneController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? LocaleKeys.labelRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Address line 1 ────────────────────────────
                    AddressFormField(
                      label: LocaleKeys.addressLine1.tr,
                      hint: LocaleKeys.addressLine1.tr,
                      controller: controller.addressLine1Controller,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? LocaleKeys.addressRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Address line 2 (optional) ─────────────────
                    AddressFormField(
                      label: LocaleKeys.addressLine2.tr,
                      hint: LocaleKeys.addressLine2Optional.tr,
                      controller: controller.addressLine2Controller,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      validator: (_) => null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── City dropdown ─────────────────────────────
                    _CityDropdown(controller: controller),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── State ─────────────────────────────────────
                    AddressFormField(
                      label: LocaleKeys.stateField.tr,
                      hint: LocaleKeys.stateField.tr,
                      controller: controller.stateController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? LocaleKeys.labelRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Country ───────────────────────────────────
                    AddressFormField(
                      label: LocaleKeys.countryField.tr,
                      hint: LocaleKeys.countryField.tr,
                      controller: controller.countryController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? LocaleKeys.labelRequired.tr
                          : null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Postal code (optional) ────────────────────
                    AddressFormField(
                      label: LocaleKeys.postalCode.tr,
                      hint: LocaleKeys.postalCodeOptional.tr,
                      controller: controller.postalCodeController,
                      textInputAction: TextInputAction.done,
                      validator: (_) => null,
                    ),

                    const SizedBox(height: MarketplaceSpacing.md),

                    // ── Default toggle ────────────────────────────
                    Obx(() => AddressDefaultToggle(
                          dto: AddressDefaultToggleDto(
                            isDefault: controller.isDefault.value,
                            onChanged: controller.toggleDefault,
                          ),
                        )),

                    const SizedBox(height: MarketplaceSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
          _StickyBottomBar(controller: controller),
        ],
      ),
    );
  }
}

// ── City dropdown ─────────────────────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.controller});

  final AddEditAddressController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocaleKeys.cityField.tr,
              style: MarketplaceTypography.sectionSubheading),
          const SizedBox(height: MarketplaceSpacing.xs),
          if (controller.isCitiesLoading)
            _LoadingDropdown()
          else
            _CityFormField(controller: controller),
        ],
      ),
    );
  }
}

class _LoadingDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
        border: Border.all(color: MarketplaceColors.stroke),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MarketplaceColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CityFormField extends StatelessWidget {
  const _CityFormField({required this.controller});

  final AddEditAddressController controller;

  String _cityLabel(CityEntity city) {
    return Get.locale?.languageCode == 'ar' ? city.nameAr : city.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CityEntity>(
      value: controller.selectedCity.value,
      onChanged: controller.selectCity,
      validator: (v) => v == null ? LocaleKeys.labelRequired.tr : null,
      isExpanded: true,
      hint: Text(
        LocaleKeys.cityField.tr,
        style: MarketplaceTypography.inputPlaceholder,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: 14,
        ),
        filled: true,
        fillColor: MarketplaceColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
          borderSide: const BorderSide(color: MarketplaceColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
          borderSide:
              const BorderSide(color: MarketplaceColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
      ),
      items: controller.cities
          .map((city) => DropdownMenuItem<CityEntity>(
                value: city,
                child: Text(
                  _cityLabel(city),
                  style: MarketplaceTypography.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
    );
  }
}

// ── Sticky bottom bar ─────────────────────────────────────────────────────────

class _StickyBottomBar extends StatelessWidget {
  const _StickyBottomBar({required this.controller});

  final AddEditAddressController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        MarketplaceSpacing.md,
        MarketplaceSpacing.sm,
        MarketplaceSpacing.md,
        MediaQuery.of(context).padding.bottom + MarketplaceSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: MarketplaceColors.surface,
        border: Border(top: BorderSide(color: MarketplaceColors.stroke)),
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: MarketplaceSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: controller.isSaving ? null : controller.save,
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketplaceColors.primary,
              disabledBackgroundColor:
                  MarketplaceColors.primary.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: MarketplaceRadius.buttonBR,
              ),
            ),
            child: controller.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MarketplaceColors.onPrimary,
                    ),
                  )
                : Text(
                    LocaleKeys.saveAddress.tr,
                    style: MarketplaceTypography.buttonLabel,
                  ),
          ),
        ),
      ),
    );
  }
}
