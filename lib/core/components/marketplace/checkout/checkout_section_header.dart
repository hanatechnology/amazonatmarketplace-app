import 'package:flutter/material.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';

class CheckoutSectionHeaderDto {
  const CheckoutSectionHeaderDto({
    required this.title,
    this.hasError = false,
    this.errorMessage,
  });

  final String title;
  final bool hasError;
  final String? errorMessage;
}

/// Section header with title and optional red validation error below.
class CheckoutSectionHeader extends StatelessWidget {
  const CheckoutSectionHeader({super.key, required this.data});

  final CheckoutSectionHeaderDto data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: MarketplaceTypography.sectionHeading.copyWith(
            color: data.hasError
                ? const Color(0xFFD32F2F)
                : MarketplaceColors.textPrimary,
          ),
        ),
        if (data.hasError && data.errorMessage != null) ...[
          const SizedBox(height: MarketplaceSpacing.xs),
          Text(
            data.errorMessage!,
            style: MarketplaceTypography.descriptionBody.copyWith(
              color: const Color(0xFFD32F2F),
            ),
          ),
        ],
      ],
    );
  }
}
