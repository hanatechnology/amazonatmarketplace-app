import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import 'app_network_image.dart';
import 'star_rating.dart';

/// Review item widget with avatar, name, rating, and review text.
class ReviewItem extends StatelessWidget {
  const ReviewItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.rating,
    required this.text,
    this.onLearnMore,
  });

  final String avatarUrl;
  final String name;
  final double rating;
  final String text;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        AppNetworkImage(
          imageUrl: avatarUrl,
          width: MarketplaceSpacing.avatarSmall,
          height: MarketplaceSpacing.avatarSmall,
          borderRadius: MarketplaceRadius.full,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: MarketplaceSpacing.md),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: MarketplaceTypography.sectionSubheading,
              ),
              const SizedBox(height: MarketplaceSpacing.xs),
              // Rating
              StarRating(
                rating: rating,
                maxStars: 5,
                showLabel: true,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              // Review text with "Learn more" link
              RichText(
                text: TextSpan(
                  style: MarketplaceTypography.descriptionBody,
                  children: [
                    TextSpan(text: text),
                    if (onLearnMore != null) ...[
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: onLearnMore,
                          child: Text(
                            'Learn more',
                            style: MarketplaceTypography.descriptionBody.copyWith(
                              color: MarketplaceColors.link,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
