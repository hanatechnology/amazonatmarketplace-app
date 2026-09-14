import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/address/address_label_chips.dart';
import '../../../../core/components/marketplace/address/city_picker_sheet.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/add_address_controller.dart';
import 'location_picker_page.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Add or edit a delivery address.
///
/// Only the five fields `CreateAddressDto` actually requires carry an asterisk:
/// recipient name, phone, city, address line 1 and the map location. Label,
/// district and the second address line are optional, and country is sent as
/// "Libya" without asking — the web hardcodes it and there is no country UI
/// anywhere in the product. Postal code is dropped: Libya does not use one.
class AddAddressPage extends GetView<AddAddressController> {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _NavRow(),
              const SizedBox(height: 6),
              Text(
                LocaleKeys.addAddress.tr,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 28,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const _ErrorSummary(),
              _Label(text: LocaleKeys.addressLabel.tr),
              Obx(
                () => AddressLabelChips(
                  dto: AddressLabelChipsDto(
                    selectedChip: controller.selectedChip.value,
                    onSelect: controller.selectChip,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _TextField(
                  label: LocaleKeys.recipientName.tr,
                  isRequired: true,
                  controller: controller.fullNameController,
                  error: controller.fullNameError.value,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              const _PhoneField(),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 135, child: _CityField()),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 100,
                    child: _TextField(
                      label: LocaleKeys.districtOptional.tr,
                      controller: controller.stateController,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Obx(
                () => _TextField(
                  label: LocaleKeys.addressLine1.tr,
                  isRequired: true,
                  controller: controller.addressLine1Controller,
                  error: controller.addressLine1Error.value,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _TextField(
                label: LocaleKeys.addressLine2Optional.tr,
                controller: controller.addressLine2Controller,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              const _LocationCard(),
              const SizedBox(height: 16),
              const _DefaultSwitch(),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSaving ? null : controller.save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.brand,
                      foregroundColor: palette.onBrand,
                      disabledBackgroundColor: palette.surfaceSunken,
                      disabledForegroundColor: palette.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                      ),
                    ),
                    child: controller.isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onBrand,
                            ),
                          )
                        : Text(
                            LocaleKeys.saveAddress.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: const BackButtonSlot(),
      ),
    );
  }
}

/// Per-field messages alone do not read at a glance on a form this long.
class _ErrorSummary extends GetView<AddAddressController> {
  const _ErrorSummary();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final count = controller.errorCount;
      if (count == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: StatusTone.danger.background(palette.isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: StatusTone.danger.foreground(palette.isDark),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                LocaleKeys.fixFields.trParams({'count': '$count'}),
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11.5,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: MarketplaceTypography.labelCaps.copyWith(
              color: palette.textMuted,
              letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.2,
            ),
          ),
          if (isRequired)
            Text(
              ' *',
              style: MarketplaceTypography.labelCaps.copyWith(
                color: StatusTone.danger.foreground(palette.isDark),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.error,
    this.isRequired = false,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final bool isRequired;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(text: label, isRequired: isRequired),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? StatusTone.danger.foreground(palette.isDark)
                  : palette.hairline,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              textInputAction: textInputAction,
              cursorColor: palette.brand,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 13.5,
                color: palette.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11,
                color: StatusTone.danger.foreground(palette.isDark),
              ),
            ),
          ),
      ],
    );
  }
}

/// `+218` is fixed chrome and only the nine national digits are typed. The row
/// is an LTR run in both languages — a phone number is not a sentence.
class _PhoneField extends GetView<AddAddressController> {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final error = controller.phoneError.value;
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: LocaleKeys.phoneNumber.tr, isRequired: true),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? StatusTone.danger.foreground(palette.isDark)
                      : palette.hairline,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    PhoneUtils.countryCode,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: palette.hairline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          PhoneUtils.nationalLength,
                        ),
                      ],
                      cursorColor: palette.brand,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 13.5,
                        letterSpacing: 0.5,
                        color: palette.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '91 234 5678',
                        hintStyle: MarketplaceTypography.rowTitle.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _CityField extends GetView<AddAddressController> {
  const _CityField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final city = controller.selectedCity.value;
      final error = controller.cityError.value;
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: LocaleKeys.cityField.tr, isRequired: true),
          GestureDetector(
            onTap: () async {
              final picked = await CityPickerSheet.show(
                cities: controller.cities,
                selectedId: city?.id,
              );
              if (picked != null) controller.selectCity(picked);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? StatusTone.danger.foreground(palette.isDark)
                      : palette.hairline,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      city?.name ?? LocaleKeys.selectCity.tr,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 13.5,
                        color: city == null
                            ? palette.textMuted
                            : palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// `location` is required by the create endpoint, so this is not an extra —
/// without a pin the address cannot be saved at all.
class _LocationCard extends GetView<AddAddressController> {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final location = controller.location.value;
      final error = controller.locationError.value;
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: LocaleKeys.mapLocation.tr, isRequired: true),
          GestureDetector(
            onTap: () async {
              final picked = await LocationPickerPage.show(initial: location);
              controller.setLocation(picked);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? StatusTone.danger.foreground(palette.isDark)
                      : palette.hairline,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.surfaceSunken,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: location == null
                          ? palette.textMuted
                          : palette.brand,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // Once the picker has read a street off the map, that
                          // line is what identifies the point — "Location
                          // pinned" says nothing the pin did not already say.
                          location == null
                              ? LocaleKeys.mapPinHint.tr
                              : location.address.trim().isNotEmpty
                                  ? location.address.trim()
                                  : LocaleKeys.locationPinned.tr,
                          style: MarketplaceTypography.rowTitle.copyWith(
                            fontSize: 12.5,
                            color: palette.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            '${location.lat.toStringAsFixed(5)}, '
                            '${location.lng.toStringAsFixed(5)}',
                            textDirection: TextDirection.ltr,
                            style: MarketplaceTypography.rowMeta.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKeys.changeLocation.tr,
                    style: MarketplaceTypography.pillLabel.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: palette.brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _DefaultSwitch extends GetView<AddAddressController> {
  const _DefaultSwitch();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 13, end: 6),
      height: 52,
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKeys.setAsDefault.tr,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 12.5,
                color: palette.textPrimary,
              ),
            ),
          ),
          Obx(
            () => Switch.adaptive(
              value: controller.isDefault.value,
              onChanged: controller.toggleDefault,
              activeThumbColor: palette.onBrand,
              activeTrackColor: palette.brand,
            ),
          ),
        ],
      ),
    );
  }
}
