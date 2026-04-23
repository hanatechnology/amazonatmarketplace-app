import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../app_network_image.dart';
import 'dtos/product_image_gallery_dto.dart';

/// Full-width image carousel with a smooth dot indicator.
///
/// **StatefulWidget** — manages its own [PageController] so that:
/// 1. The controller is created once in [initState] and disposed in [dispose],
///    preventing the `'!semantics.parentDataDirty'` assertion spam.
/// 2. [SmoothPageIndicator] is deferred to the first post-frame callback so
///    it never subscribes to the [PageController] before [hasSize] is set
///    (prevents the `_RenderSingleChildViewport NEEDS-PAINT` assertion).
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({super.key, required this.dto});

  final ProductImageGalleryDto dto;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _controller;
  bool _indicatorReady = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    // Defer indicator rendering until PageController is fully attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _indicatorReady = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.dto.imageUrls;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main image pager ─────────────────────────────────
        SizedBox(
          height: MarketplaceSpacing.detailImageHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: imageUrls.length,
            onPageChanged: widget.dto.onPageChanged,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MarketplaceSpacing.screenPaddingH,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(MarketplaceRadius.detailImage),
                child: AppNetworkImage(
                  imageUrl: imageUrls[index],
                  width: double.infinity,
                  height: MarketplaceSpacing.detailImageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ── Dot indicator ─────────────────────────────────────
        if (_indicatorReady && imageUrls.length > 1) ...[
          const SizedBox(height: MarketplaceSpacing.sm),
          SmoothPageIndicator(
            controller: _controller,
            count: imageUrls.length,
            effect: ExpandingDotsEffect(
              activeDotColor: MarketplaceColors.primary,
              dotColor: MarketplaceColors.stroke,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3,
            ),
          ),
        ],
        const SizedBox(height: MarketplaceSpacing.sm),
      ],
    );
  }
}
