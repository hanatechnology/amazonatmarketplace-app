import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import 'app_network_image.dart';

/// Promotional banner — 343×146 from Figma.
/// Supports both local asset and network image URLs.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    required this.onCta,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl; // network URL or local asset path
  final VoidCallback onCta;

  bool get _isNetworkImage =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MarketplaceSpacing.bannerHeight,
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary,
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // ── Left content ─────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: MarketplaceTypography.bannerTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: MarketplaceTypography.bannerSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // CTA — auto-width, not hardcoded 90px
                  TextButton(
                    onPressed: onCta,
                    style: TextButton.styleFrom(
                      backgroundColor: MarketplaceColors.primary,
                      foregroundColor: MarketplaceColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MarketplaceRadius.bannerCta,
                        ),
                      ),
                    ),
                    child: Text(
                      ctaLabel,
                      style: MarketplaceTypography.bannerCta,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right image ───────────────────────────────
          Expanded(
            flex: 2,
            child: _isNetworkImage
                ? AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),
        ],
      ),
    );
  }
}

