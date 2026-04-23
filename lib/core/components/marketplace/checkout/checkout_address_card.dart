import 'package:flutter/material.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';

class CheckoutAddressDto {
  const CheckoutAddressDto({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
  });

  final String id;
  final String label;
  final String street;
  final String city;
}

/// Single address card with selected/unselected visual state.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final CheckoutAddressDto address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? MarketplaceColors.secondary.withValues(alpha: 0.2)
              : MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(
            color: isSelected
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: isSelected
                  ? MarketplaceColors.primary
                  : MarketplaceColors.textSecondary,
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: MarketplaceTypography.sectionSubheading.copyWith(
                      color: isSelected
                          ? MarketplaceColors.primary
                          : MarketplaceColors.textBody,
                    ),
                  ),
                  const SizedBox(height: MarketplaceSpacing.xxs),
                  Text(
                    '${address.street}, ${address.city}',
                    style: MarketplaceTypography.descriptionBody,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? MarketplaceColors.primary
                  : MarketplaceColors.stroke,
            ),
          ],
        ),
      ),
    );
  }
}
