import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';

class AddressDeleteSheet extends StatelessWidget {
  const AddressDeleteSheet({super.key, required this.address});

  final AddressEntity address;

  /// Shows the sheet and returns [true] if the user confirmed deletion.
  static Future<bool?> show(AddressEntity address) {
    return Get.bottomSheet<bool>(
      AddressDeleteSheet(address: address),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        MarketplaceSpacing.md,
        MarketplaceSpacing.sm,
        MarketplaceSpacing.md,
        MediaQuery.of(context).padding.bottom + MarketplaceSpacing.md,
      ),
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(MarketplaceRadius.screen),
          topRight: Radius.circular(MarketplaceRadius.screen),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: MarketplaceSpacing.md),
            decoration: BoxDecoration(
              color: MarketplaceColors.stroke,
              borderRadius: BorderRadius.circular(MarketplaceRadius.full),
            ),
          ),
          Text(
            LocaleKeys.deleteAddress.tr,
            style: MarketplaceTypography.sectionHeading,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            '${address.label} — ${address.addressLine1}',
            style: MarketplaceTypography.descriptionBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.xs),
          Text(
            LocaleKeys.deleteAddressConfirm.tr,
            style: MarketplaceTypography.descriptionBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: MarketplaceSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: MarketplaceRadius.buttonBR,
                ),
              ),
              child: Text(
                LocaleKeys.delete.tr,
                style: MarketplaceTypography.buttonLabel,
              ),
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: MarketplaceSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: () => Get.back(result: false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: MarketplaceColors.stroke),
                shape: RoundedRectangleBorder(
                  borderRadius: MarketplaceRadius.buttonBR,
                ),
              ),
              child: Text(
                LocaleKeys.cancel.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  color: MarketplaceColors.textBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
