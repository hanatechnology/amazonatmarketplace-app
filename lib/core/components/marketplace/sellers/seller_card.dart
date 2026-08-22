import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../app_network_image.dart';

/// Store card for the sellers list — banner strip, overlapping logo, name,
/// verified mark, and the store's own description.
class SellerCard extends StatelessWidget {
  const SellerCard({super.key, required this.seller, required this.onTap});

  final SellerEntity seller;
  final VoidCallback onTap;

  static const double _bannerHeight = 84;
  static const double _logoSize = 48;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MarketplaceRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(color: MarketplaceColors.strokeLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The logo hangs off the bottom of the banner, so the stack is
            // allowed to overflow and the content below is padded to match.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: _bannerHeight,
                  width: double.infinity,
                  color: MarketplaceColors.secondary,
                  child: seller.bannerUrl == null
                      ? null
                      : AppNetworkImage(
                          imageUrl: seller.bannerUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
                PositionedDirectional(
                  start: MarketplaceSpacing.md,
                  bottom: -_logoSize / 2,
                  child: _Logo(seller: seller, size: _logoSize),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MarketplaceSpacing.md,
                _logoSize / 2 + MarketplaceSpacing.sm,
                MarketplaceSpacing.md,
                MarketplaceSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          seller.name,
                          style: MarketplaceTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (seller.isVerified) ...[
                        const SizedBox(width: MarketplaceSpacing.xs),
                        const Icon(
                          MarketplaceIcons.verified,
                          size: 16,
                          color: MarketplaceColors.successContent,
                        ),
                      ],
                    ],
                  ),
                  if (seller.description != null &&
                      seller.description!.isNotEmpty) ...[
                    const SizedBox(height: MarketplaceSpacing.xxs),
                    Text(
                      seller.description!,
                      style: MarketplaceTypography.micro.copyWith(
                        color: MarketplaceColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: MarketplaceSpacing.sm),
                  Text(
                    LocaleKeys.viewStore.tr,
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.seller, required this.size});

  final SellerEntity seller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.cardImage),
        border: Border.all(color: MarketplaceColors.surface, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: seller.logoUrl != null
          ? AppNetworkImage(imageUrl: seller.logoUrl!, fit: BoxFit.cover)
          : Container(
              color: MarketplaceColors.secondary,
              alignment: Alignment.center,
              child: Text(
                seller.name.isEmpty ? '?' : seller.name.substring(0, 1).toUpperCase(),
                style: MarketplaceTypography.cardTitle.copyWith(
                  color: MarketplaceColors.primary,
                ),
              ),
            ),
    );
  }
}
