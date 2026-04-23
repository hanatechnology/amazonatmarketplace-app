import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_description_dto.dart';

/// Collapsible product description section.
///
/// Design fixes applied:
/// - "Show less" was previously a hardcoded English string — now uses
///   [LocaleKeys.showLess] so it translates correctly in Arabic.
/// - Toggle target uses [InkWell] instead of bare [GestureDetector] for
///   proper ink ripple and accessible hit area.
class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({super.key, required this.dto});

  final ProductDescriptionDto dto;

  @override
  Widget build(BuildContext context) {
    final desc = dto.description;
    if (desc == null || desc.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.description.tr,
          style: MarketplaceTypography.sectionHeading,
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        Text(
          desc,
          style: MarketplaceTypography.descriptionBody,
          maxLines: dto.isExpanded ? null : 3,
          overflow: dto.isExpanded ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: MarketplaceSpacing.xs),
        InkWell(
          onTap: dto.onToggle,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              dto.isExpanded
                  ? LocaleKeys.showLess.tr
                  : LocaleKeys.learnMore.tr,
              style: MarketplaceTypography.micro.copyWith(
                color: MarketplaceColors.link,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
