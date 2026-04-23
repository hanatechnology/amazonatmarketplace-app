import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';

class AddressCardDto {
  const AddressCardDto({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.cityName,
    required this.state,
    required this.isDefault,
    this.isPickMode = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    required this.onPick,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String cityName;
  final String state;
  final bool isDefault;
  final bool isPickMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onPick;
}

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.dto});

  final AddressCardDto dto;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dto.isPickMode ? dto.onPick : null,
      onLongPress: (dto.isPickMode || dto.isDefault) ? null : dto.onSetDefault,
      child: Container(
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: MarketplaceRadius.cardBR,
          border: Border.all(
            color: dto.isDefault
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
            width: dto.isDefault ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LocationIcon(),
            const SizedBox(width: MarketplaceSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dto.label,
                          style: MarketplaceTypography.sectionSubheading,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dto.isDefault) ...[
                        const SizedBox(width: MarketplaceSpacing.xs),
                        const _DefaultBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dto.fullName,
                    style: MarketplaceTypography.descriptionBody.copyWith(
                      color: MarketplaceColors.textBody,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dto.phone,
                    style: MarketplaceTypography.descriptionBody,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildAddressLine(),
                    style: MarketplaceTypography.descriptionBody,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            if (!dto.isPickMode) ...[
            const SizedBox(width: MarketplaceSpacing.xs),
            Column(
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  semanticLabel: LocaleKeys.edit,
                  onTap: dto.onEdit,
                ),
                const SizedBox(height: MarketplaceSpacing.xs),
                _ActionButton(
                  icon: Icons.delete_outline,
                  semanticLabel: LocaleKeys.delete,
                  onTap: dto.onDelete,
                ),
              ],
            ),
            ], // end if (!dto.isPickMode)
          ],
        ),
      ),
    );
  }

  String _buildAddressLine() {
    final parts = [
      dto.addressLine1,
      if (dto.addressLine2 != null && dto.addressLine2!.isNotEmpty)
        dto.addressLine2!,
      dto.cityName,
      dto.state,
    ];
    return parts.join(', ');
  }
}

class _LocationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on,
        color: MarketplaceColors.primary,
        size: 20,
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MarketplaceColors.primary,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Text(
        LocaleKeys.defaultBadge.tr,
        style: MarketplaceTypography.smallButton,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: MarketplaceColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
