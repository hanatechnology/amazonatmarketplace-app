import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_typography.dart';
import '../../../domain/entities/marketplace/banner_entity.dart';
import 'app_network_image.dart';

/// One slide of the home banner carousel.
///
/// The API supplies artwork and an optional title — no subtitle and no CTA
/// copy — so the whole card is the tap target rather than a button inside it.
class BannerCard extends StatelessWidget {
  const BannerCard({super.key, required this.banner, required this.onTap});

  final BannerEntity banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: banner.isTappable ? onTap : null,
      child: Container(
        height: MarketplaceSpacing.bannerHeight,
        decoration: BoxDecoration(
          color: MarketplaceColors.secondary,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.imageUrl.isNotEmpty)
              AppNetworkImage(imageUrl: banner.imageUrl, fit: BoxFit.cover),
            if (banner.title != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(MarketplaceSpacing.sm),
                  // Scrim so the title stays readable over any artwork.
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        MarketplaceColors.textPrimary.withValues(alpha: 0.65),
                        MarketplaceColors.textPrimary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Text(
                    banner.title!,
                    style: MarketplaceTypography.bannerTitle.copyWith(
                      color: MarketplaceColors.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
