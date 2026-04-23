import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';

class AddressDefaultToggleDto {
  const AddressDefaultToggleDto({
    required this.isDefault,
    required this.onChanged,
  });

  final bool isDefault;
  final ValueChanged<bool> onChanged;
}

class AddressDefaultToggle extends StatelessWidget {
  const AddressDefaultToggle({super.key, required this.dto});

  final AddressDefaultToggleDto dto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: MarketplaceRadius.cardBR,
        border: Border.all(color: MarketplaceColors.stroke),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: MarketplaceSpacing.xs,
        ),
        title: Text(
          LocaleKeys.setAsDefault.tr,
          style: MarketplaceTypography.sectionSubheading,
        ),
        value: dto.isDefault,
        onChanged: dto.onChanged,
        activeThumbColor: MarketplaceColors.onPrimary,
        activeTrackColor: MarketplaceColors.primary,
      ),
    );
  }
}
