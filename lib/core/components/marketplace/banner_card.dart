import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../localization/locale_keys.dart';
import '../../theme/marketplace_palette.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_typography.dart';
import '../../../domain/entities/marketplace/banner_entity.dart';
import 'app_network_image.dart';

/// One slide of the home hero.
///
/// The whole slide is the tap target, and it carries everything that belongs to
/// *this* banner: its artwork, the scrim that keeps the hero's chrome legible
/// on top of it, and its own call to action. The hero above it owns only what
/// belongs to the carousel as a whole — the header, the headline and the slide
/// counter.
///
/// Artwork is `mobile_image_url` from the API, cut for this near-square block;
/// `GET /banners` does not return banners that lack it.
class BannerCard extends StatelessWidget {
  const BannerCard({
    super.key,
    required this.banner,
    required this.height,
    required this.sheetOverlap,
    required this.onTap,
  });

  final BannerEntity banner;

  /// Full hero height, status-bar inset included.
  final double height;

  /// How far the content sheet below rides up over the hero. The copy block
  /// clears it — anything laid out inside that band is behind the sheet.
  final double sheetOverlap;

  final VoidCallback onTap;

  /// Gap between the CTA and the top edge of the content sheet.
  static const double copyGap = 20;

  /// Where the copy block's baseline sits, measured from the hero's bottom.
  /// The hero's own chrome — the slide counter — reads this so it lands on the
  /// CTA's line rather than guessing at it.
  static double copyBottom(double sheetOverlap) => sheetOverlap + copyGap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            imageUrl: banner.imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
          const BannerScrim(),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: copyBottom(sheetOverlap),
            child: BannerCopy(
              title: banner.title?.trim().isNotEmpty == true
                  ? banner.title!.trim()
                  : LocaleKeys.homeHeroTitle.tr,
              cta: banner.isTappable
                  ? _BannerCta(banner: banner, onTap: onTap)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The banner's words: the standing eyebrow, the banner's own headline, and its
/// CTA under them.
///
/// One column rather than three positioned children — headline and button move
/// together on a swipe because they say the same thing, and a two-line title
/// pushes the button down instead of overlapping it.
class BannerCopy extends StatelessWidget {
  const BannerCopy({super.key, required this.title, this.cta});

  final String title;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LocaleKeys.newCollection.tr.toUpperCase(),
          style: MarketplaceTypography.labelCaps.copyWith(
            color: palette.accent,
            shadows: const [Shadow(blurRadius: 6, color: Color(0xBF0E1310))],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: MarketplaceTypography.heroDisplay.copyWith(
            color: const Color(0xFFECF1E3),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (cta != null) ...[
          const SizedBox(height: 14),
          cta!,
        ],
      ],
    );
  }
}

/// The gradient that makes light chrome readable over any photograph.
///
/// Dark at both ends: the top carries the header, the bottom carries the
/// headline and the CTA, then hands off into the content sheet. Public because
/// an empty hero — no banners, brand-coloured ground — needs the same treatment
/// without a card to draw it.
class BannerScrim extends StatelessWidget {
  const BannerScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.scrim.withValues(alpha: 0.72),
              palette.scrim.withValues(alpha: 0.25),
              palette.scrim.withValues(alpha: 0.94),
            ],
            stops: const [0.0, 0.34, 0.96],
          ),
        ),
      ),
    );
  }
}

/// The banner's call to action.
///
/// Its wording is the promise the tap keeps: a PRODUCT banner opens a product,
/// so it says "shop now"; an IMAGE_LINK banner opens a page somewhere else,
/// where "shop now" would be a lie.
class _BannerCta extends StatelessWidget {
  const _BannerCta({required this.banner, required this.onTap});

  /// Shared with the hero's slide counter, which sits on this line.
  static const double height = 36;

  final BannerEntity banner;
  final VoidCallback onTap;

  String get _label => switch (banner.type) {
        BannerType.product => LocaleKeys.shopNow.tr,
        BannerType.imageLink => LocaleKeys.knowMore.tr,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _label,
              // height 1: the inherited 1.4 line box left the label sitting
              // above the optical centre of a fixed-height pill.
              style: MarketplaceTypography.pillLabel.copyWith(
                color: palette.onAccent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              // "Forward" is towards the end of the line, so it points the other
              // way in Arabic.
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded,
              size: 15,
              color: palette.onAccent,
            ),
          ],
        ),
      ),
    );
  }
}

/// Height of the CTA pill, for chrome that has to sit on its line.
const double kBannerCtaHeight = _BannerCta.height;
