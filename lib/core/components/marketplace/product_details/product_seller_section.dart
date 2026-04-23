import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../seller_info_card.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_seller_section_dto.dart';

/// Section header + [SellerInfoCard] for the product details screen.
///
/// Design fix: the original implementation had the [SellerInfoCard] commented
/// out, leaving an empty section. It is now wired up and rendered.
class ProductSellerSection extends StatelessWidget {
  const ProductSellerSection({super.key, required this.dto});

  final ProductSellerSectionDto dto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.seller.tr,
              style: MarketplaceTypography.sectionHeading,
            ),
            if (dto.onSeeAll != null)
              GestureDetector(
                onTap: dto.onSeeAll,
                child: Text(
                  LocaleKeys.allSellers.tr,
                  style: MarketplaceTypography.seeAll,
                ),
              ),
          ],
        ),
        const SizedBox(height: MarketplaceSpacing.sm),

        // ── Seller card ───────────────────────────────────────
        SellerInfoCard(
          imageUrl: dto.imageUrl,
          name: dto.name,
          location: dto.location,
          rating: dto.rating,
          isVerified: dto.isVerified,
          isOpen: dto.isOpen,
          followerCount: dto.followerCount,
          onFollow: dto.onFollow,
        ),
      ],
    );
  }
}
