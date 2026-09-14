import 'package:flutter/material.dart';
import '../../../theme/marketplace_spacing.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../app_network_image.dart';
import 'package:get/get.dart';

/// Full-bleed product gallery with the glass back control over it.
///
/// The scrim is weighted to the top so the status bar and the back button stay
/// readable on any photograph. The featured badge sits at the start edge and
/// the page dots at the end edge, so both swap sides with the text direction.
class ProductHero extends StatelessWidget {
  const ProductHero({
    super.key,
    required this.imageUrls,
    required this.activeIndex,
    required this.onPageChanged,
    this.featuredLabel,
    this.isAvailable = true,
    this.onImageTap,
  });

  /// Height of the 4:5 canonical box at the current screen width. The hero is
  /// full-bleed, so its width is the screen's.
  static double heightFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width /
      MarketplaceSpacing.productImageAspectRatio;

  /// Fallback for places that need a figure before they have a context.
  static const double height = 252;

  final List<String> imageUrls;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;

  /// Opens the fullscreen gallery at the tapped image.
  final ValueChanged<int>? onImageTap;

  /// Resolved label for `featured_section`, or null when the product carries
  /// no section.
  final String? featuredLabel;

  /// `is_active`. False greys the artwork and stamps it unorderable.
  final bool isAvailable;

  /// Luminance-weighted greyscale, matching the mock's `grayscale(.82)`.
  static const List<double> _greyscale = <double>[
    0.33, 0.53, 0.14, 0, 0,
    0.33, 0.53, 0.14, 0, 0,
    0.33, 0.53, 0.14, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final height = heightFor(context);
    final palette = context.palette;
    final images = imageUrls.where((url) => url.isNotEmpty).toList();

    Widget gallery = images.isEmpty
        ? ColoredBox(color: palette.surfaceSunken)
        : PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, index) => GestureDetector(
              onTap: () => onImageTap?.call(index),
              behavior: HitTestBehavior.opaque,
              child: AppNetworkImage(
                imageUrl: images[index],
                width: double.infinity,
                height: height,
                // contain, not cover: off-ratio photos are letterboxed on the
                // sunken ground rather than having their edges cropped away on
                // the one screen where the customer is inspecting the item.
                fit: BoxFit.contain,
              ),
            ),
          );

    if (!isAvailable) {
      gallery = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_greyscale),
        child: gallery,
      );
    }

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: gallery),
          if (!isAvailable)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Color(0x47080B09)),
              ),
            ),
          IgnorePointer(
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x9E080B09), Color(0x00080B09)],
                  ),
                ),
              ),
            ),
          ),
          if (!isAvailable) const Center(child: _UnavailableStamp()),
          if (isAvailable && featuredLabel != null)
            PositionedDirectional(
              start: 20,
              bottom: 44,
              child: _FeaturedBadge(label: featuredLabel!),
            ),
          if (images.length > 1)
            PositionedDirectional(
              end: 20,
              bottom: 46,
              child: _Dots(count: images.length, activeIndex: activeIndex),
            ),
        ],
      ),
    );
  }
}


class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 24,
      padding: const EdgeInsetsDirectional.only(start: 9, end: 11),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 11, color: palette.onAccent),
          const SizedBox(width: 5),
          Text(
            label,
            style: MarketplaceTypography.pillLabel.copyWith(
              fontSize: 9.5,
              color: palette.onAccent,
              letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isActive ? 16 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFFFFF) : const Color(0x73FFFFFF),
              borderRadius: BorderRadius.circular(MarketplaceRadius.full),
            ),
          ),
        );
      }),
    );
  }
}

/// Says outright what the greyed artwork already implies.
class _UnavailableStamp extends StatelessWidget {
  const _UnavailableStamp();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xB80E1310),
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Text(
        LocaleKeys.notAvailableOrder.tr,
        style: MarketplaceTypography.pillLabel.copyWith(
          fontSize: 11,
          color: const Color(0xFFFFFFFF),
          letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.4,
        ),
      ),
    );
  }
}
