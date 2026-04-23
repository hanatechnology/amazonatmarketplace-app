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
    required this.followerCount,
    required this.onFollow,
    this.isFollowing = false,
  });

  final String imageUrl;
  final String name;
  final String? location;
  final double rating;
  final bool isVerified;
  final bool isOpen;
  final int followerCount;
  final VoidCallback onFollow;

  /// When true the button shows "Following" in the filled primary style.
  final bool isFollowing;

  /// Formats a follower count: 1200 → "1.2K", 1000000 → "1M".
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}K';
    }
    return count.toString();
  }

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

                      // ── Followers + Follow button ─────────────
                      // Row inside Expanded → bounded width → Spacer works.
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.people_outline,
                      //       size: 14,
                      //       color: MarketplaceColors.textSecondary,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       '${_formatCount(followerCount)} ${LocaleKeys.followers.tr}',
                      //       style: MarketplaceTypography.cardSubtitle,
                      //     ),
                      //     const Spacer(),
                      //     _FollowButton(
                      //       isFollowing: isFollowing,
                      //       onTap: onFollow,
                      //     ),
                      //   ],
                      // ),
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
        ? MarketplaceColors.primary.withOpacity(0.1)
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

// ── Follow / Following toggle button ─────────────────────────────────────

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.onTap,
  });

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isFollowing) {
      // Filled style when already following
      return SizedBox(
        height: 28,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: MarketplaceColors.primary,
            foregroundColor: MarketplaceColors.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(MarketplaceRadius.smallButton),
            ),
            elevation: 0,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.check, size: 13),
          label: Text(
            LocaleKeys.following.tr,
            style: MarketplaceTypography.smallButton.copyWith(
              color: MarketplaceColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Outlined style when not yet following
    return SizedBox(
      height: 28,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: MarketplaceColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MarketplaceRadius.smallButton),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          MarketplaceIcons.follow,
          size: 13,
          color: MarketplaceColors.primary,
        ),
        label: Text(
          LocaleKeys.follow.tr,
          style: MarketplaceTypography.smallButton.copyWith(
            color: MarketplaceColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
