import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// The three shorthand labels an address can carry.
///
/// `label` is optional in `CreateAddressDto`, so these chips are a convenience,
/// not a requirement. The wire value stays English and stable — it is stored on
/// the record — while the chip shows the customer's language.
enum AddressLabelChip {
  home,
  work,
  other;

  /// What is sent to the API. Never localized: it is persisted data.
  String get label => switch (this) {
        home => 'Home',
        work => 'Work',
        other => 'Other',
      };

  String get displayLabel => switch (this) {
        home => LocaleKeys.labelChipHome.tr,
        work => LocaleKeys.labelChipWork.tr,
        other => LocaleKeys.labelChipOther.tr,
      };

  IconData get icon => switch (this) {
        home => Icons.home_outlined,
        work => Icons.work_outline,
        other => Icons.location_on_outlined,
      };
}

class AddressLabelChipsDto {
  const AddressLabelChipsDto({
    required this.selectedChip,
    required this.onSelect,
  });

  final AddressLabelChip? selectedChip;
  final ValueChanged<AddressLabelChip> onSelect;
}

class AddressLabelChips extends StatelessWidget {
  const AddressLabelChips({super.key, required this.dto});

  final AddressLabelChipsDto dto;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AddressLabelChip.values
          .map(
            (chip) => _LabelChip(
              chip: chip,
              isSelected: dto.selectedChip == chip,
              onTap: () => dto.onSelect(chip),
            ),
          )
          .toList(),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.chip,
    required this.isSelected,
    required this.onTap,
  });

  final AddressLabelChip chip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? palette.brand : palette.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chip.icon,
              size: 15,
              color: isSelected ? palette.onBrand : palette.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              chip.displayLabel,
              style: MarketplaceTypography.pillLabel.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? palette.onBrand : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
