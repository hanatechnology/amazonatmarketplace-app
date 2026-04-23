import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';

class AddressEmptyStateDto {
  const AddressEmptyStateDto({required this.onAddAddress});
  final VoidCallback onAddAddress;
}

class AddressEmptyState extends StatelessWidget {
  const AddressEmptyState({super.key, required this.dto});

  final AddressEmptyStateDto dto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: MarketplaceColors.secondary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 56,
                color: MarketplaceColors.primary,
              ),
            ),
            const SizedBox(height: MarketplaceSpacing.lg),
            Text(
              LocaleKeys.noAddresses.tr,
              style: MarketplaceTypography.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.noAddressesMessage.tr,
              style: MarketplaceTypography.descriptionBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: MarketplaceSpacing.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: dto.onAddAddress,
                icon: const Icon(Icons.add, color: MarketplaceColors.onPrimary),
                label: Text(
                  LocaleKeys.addFirstAddress.tr,
                  style: MarketplaceTypography.buttonLabel,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MarketplaceColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: MarketplaceRadius.buttonBR,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
