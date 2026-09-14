import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_icons.dart';
import '../../localization/locale_keys.dart';
import 'app_network_image.dart';
import 'star_rating.dart';

/// Seller info card — name, location, rating, open/closed status,
/// follower count, and a follow/following toggle button.
///
/// Layout rule: the content side is wrapped in [Expanded] so that the
/// inner [Row] (followers + follow button) gets a *bounded* width and
/// [Spacer] can work correctly. Without [Expanded] the outer [Row]
/// passes maxWidth:infinity → Spacer tries to fill infinity → crash.
class SellerInfoCard extends StatelessWidget {
  const SellerInfoCard({
    super.key,
    required this.imageUrl,
    required this.name,
    this.location,
    required this.rating,
    required this.isVerified,
    required this.isOpen,
  });

  final String imageUrl;
  final String name;
  final String? location;
  final double rating;
  final bool isVerified;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        border: Border.all(color: MarketplaceColors.strokeLight),
        borderRadius: BorderRadius.circular(MarketplaceRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // ClipRRect ensures the image respects the card's rounded corners.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MarketplaceRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Content (Expanded keeps inner layout bounded) ─────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketplaceSpacing.md,
                    vertical: MarketplaceSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Name + verified ───────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MarketplaceTypography.sectionSubheading,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              MarketplaceIcons.verified,
                              size: 16,
                              color: MarketplaceColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: MarketplaceSpacing.xs),

                      // ── Location ──────────────────────────────
                      if (location != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              MarketplaceIcons.location,
                              size: 12,
                              color: MarketplaceColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MarketplaceTypography.cardSubtitle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: MarketplaceSpacing.xs),
                      ],

                      // ── Rating + open/closed chip ─────────────
                      Row(
                        children: [
                          StarRating(
                            rating: rating,
                            size: 12,
                            maxStars: 5,
                            showLabel: true,
                          ),
                          const SizedBox(width: MarketplaceSpacing.sm),
                          _StatusChip(isOpen: isOpen),
                        ],
                      ),
                      const SizedBox(height: MarketplaceSpacing.sm),

                    ],
                  ),
                ),
              ),

              // ── Seller image (right side, full height) ────────────
              AppNetworkImage(
                imageUrl: imageUrl,
                width: MarketplaceSpacing.sellerCardImageWidth,
                fit: BoxFit.cover,
                height: MarketplaceSpacing.sellerCardImageWidth
                ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Open / Closed status chip ─────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? MarketplaceColors.primary : const Color(0xFFD32F2F);
    final bg = isOpen
        ? MarketplaceColors.primary.withValues(alpha: 0.1)
        : const Color(0xFFFFEEEE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? LocaleKeys.open.tr : LocaleKeys.closed.tr,
            style: MarketplaceTypography.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
