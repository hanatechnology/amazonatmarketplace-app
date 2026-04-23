import 'package:flutter/material.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';

enum AddressLabelChip {
  home,
  work,
  other;

  String get label => switch (this) {
        home => 'Home',
        work => 'Work',
        other => 'Other',
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
      spacing: MarketplaceSpacing.sm,
      runSpacing: MarketplaceSpacing.sm,
      children: AddressLabelChip.values
          .map((chip) => _LabelChip(
                chip: chip,
                isSelected: dto.selectedChip == chip,
                onTap: () => dto.onSelect(chip),
              ))
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? MarketplaceColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chip.icon,
              size: 16,
              color: isSelected
                  ? MarketplaceColors.onPrimary
                  : MarketplaceColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              chip.label,
              style: MarketplaceTypography.cardTitle.copyWith(
                color: isSelected
                    ? MarketplaceColors.onPrimary
                    : MarketplaceColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
