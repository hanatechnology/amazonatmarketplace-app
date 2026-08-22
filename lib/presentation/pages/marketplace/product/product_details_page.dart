import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/product_details/product_image_gallery.dart';
import '../../../../core/components/marketplace/product_details/product_price_row.dart';
import '../../../../core/components/marketplace/product_details/product_rating_row.dart';
import '../../../../core/components/marketplace/product_details/product_seller_section.dart';
import '../../../../core/components/marketplace/product_details/product_quantity_section.dart';
import '../../../../core/components/marketplace/product_details/product_description_section.dart';
import '../../../../core/components/marketplace/product_details/product_reviews_section.dart';
import '../../../../core/components/marketplace/product_details/product_add_to_cart_bar.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_image_gallery_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_price_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_rating_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_seller_section_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_quantity_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_description_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_reviews_section_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_review_dto.dart';
import '../../../../core/components/marketplace/product_details/dtos/product_add_to_cart_dto.dart';
import '../../../../domain/entities/marketplace/product_details_entity.dart';
import '../../../controllers/marketplace/product_details_controller.dart';

// ── Product Details Page ─────────────────────────────────────────────────────
//
// Architecture rules enforced here:
//   • [ProductDetailsPage] is the ONLY widget that extends [GetView].
//     It owns the controller reference and maps reactive state → DTOs.
//   • All child components (ProductImageGallery, ProductPriceRow, etc.)
//     are pure [StatelessWidget]s that receive pre-built DTOs — no GetX
//     dependency injection inside them.
//   • [Obx] is used at the page level only, wrapping the data-loading state
//     and each reactive slot that needs fine-grained rebuilds.

class ProductDetailsPage extends GetView<ProductDetailsController> {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(
        title: LocaleKeys.details.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            color: MarketplaceColors.primary,
            onPressed: () {
              // TODO: Implement share product URL
            },
          ),
        ],
      ),
      body: Obx(() {
        final state = controller.stateFor<ProductDetailsEntity>(ProductDetailsController.kProduct);
        return state.value.when(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => const Center(
            child: CircularProgressIndicator(
              color: MarketplaceColors.primary,
            ),
          ),
          onSuccess: (data, _) => _ProductDetailsBody(
            product: data,
            controller: controller,
          ),
          onError: (message, _) => _ErrorView(
            message: message,
            onRetry: controller.refresh,
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => ProductAddToCartBar(
          dto: ProductAddToCartDto(
            isAddingToCart: controller.isAddingToCart.value,
            unitPrice: _currentProduct()?.price ?? 0,
            quantity: controller.quantity.value,
            onAddToCart: controller.addToCart,
          ),
        ),
      ),
    );
  }

  /// Safely extracts the loaded product from the state, or null.
  ProductDetailsEntity? _currentProduct() {
    final state = controller.stateFor<ProductDetailsEntity>(ProductDetailsController.kProduct).value;
    return state.when(
      onInitial: () => null,
      onLoading: () => null,
      onSuccess: (data, _) => data as ProductDetailsEntity?,
      onError: (_, __) => null,
    );
  }
}

// ── Body (rendered when product loads) ──────────────────────────────────────
//
// Pure [StatelessWidget] — receives [ProductDetailsEntity] and
// [ProductDetailsController] so it can build DTOs and wire callbacks.
// No GetX FindMe / GetView usage inside.

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({
    required this.product,
    required this.controller,
  });

  final ProductDetailsEntity product;
  final ProductDetailsController controller;

  // ── Mock data ────────────────────────────────────────────
  // TODO: Replace with real data from ReviewsUseCase / SellerUseCase once
  // the relevant endpoints are available.
  static const _mockReviews = <ProductReviewDto>[
    ProductReviewDto(
      avatarUrl: '',
      name: 'Ahmed M.',
      rating: 5.0,
      text: 'Excellent product! Great quality and fast shipping.',
      date: 'Mar 2025',
    ),
    ProductReviewDto(
      avatarUrl: '',
      name: 'Sara K.',
      rating: 4.0,
      text: 'Good value for money. Would recommend to others.',
      date: 'Feb 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        product.imageUrls.isNotEmpty ? product.imageUrls : [product.imageUrl];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image gallery ──────────────────────────────────
          ProductImageGallery(
            dto: ProductImageGalleryDto(
              imageUrls: imageUrls,
              onPageChanged: controller.onImageChanged,
            ),
          ),

          // ── Main info ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
              vertical: MarketplaceSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name — line height 1.3 so multi-line titles breathe
                Text(
                  product.name,
                  style: MarketplaceTypography.productTitle.copyWith(
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.sm),

                // Price row with stock indicator
                ProductPriceRow(
                  dto: ProductPriceDto(
                    price: product.price,
                    originalPrice: product.originalPrice,
                    discountPercent: product.discountPercent,
                    isInStock: true, // TODO: wire from entity when available
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.sm),

                // Rating row — tappable, navigates to reviews
                ProductRatingRow(
                  dto: ProductRatingDto(
                    rating: product.rating,
                    // TODO: replace 0 with product.reviewCount when added
                    reviewCount: 0,
                    onTap: controller.goToReviews,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.lg),

                // Seller section
                ProductSellerSection(
                  dto: ProductSellerSectionDto(
                    imageUrl: product.vendor.logoUrl, // TODO: from SellerEntity
                    name: product.vendor.name,
                    location: null, // TODO: from SellerEntity
                    rating: 4.5, // TODO: from SellerEntity
                    isVerified: true, // TODO: from SellerEntity
                    isOpen: true, // TODO: from SellerEntity
                    followerCount: 0, // TODO: from SellerEntity
                    onFollow: () {}, // TODO: FollowSellerUseCase
                    onSeeAll: controller.goToProductSellers,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.lg),

                // Quantity — rebuilt reactively when quantity changes
                Obx(() => ProductQuantitySection(
                      dto: ProductQuantityDto(
                        value: controller.quantity.value,
                        onChanged: (val) {
                          if (val > controller.quantity.value) {
                            controller.increment();
                          } else {
                            controller.decrement();
                          }
                        },
                      ),
                    )),
                const SizedBox(height: MarketplaceSpacing.lg),

                const Divider(color: MarketplaceColors.stroke),
                const SizedBox(height: MarketplaceSpacing.md),

                // Description — rebuilt reactively when expanded state changes
                Obx(() => ProductDescriptionSection(
                      dto: ProductDescriptionDto(
                        description: product.description,
                        isExpanded: controller.isDescriptionExpanded.value,
                        onToggle: controller.toggleDescription,
                      ),
                    )),
                const SizedBox(height: MarketplaceSpacing.lg),

                const Divider(color: MarketplaceColors.stroke),
                const SizedBox(height: MarketplaceSpacing.md),

                // Reviews section
                ProductReviewsSection(
                  dto: ProductReviewsSectionDto(
                    reviews: _mockReviews,
                    averageRating: product.rating,
                    totalReviews: 0, // TODO: from ReviewsUseCase
                    onSeeAll: controller.goToReviews,
                  ),
                ),

                const SizedBox(height: MarketplaceSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: MarketplaceColors.stroke,
            ),
            const SizedBox(height: MarketplaceSpacing.md),
            Text(
              message ?? LocaleKeys.error.tr,
              style: MarketplaceTypography.descriptionBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(LocaleKeys.retry.tr),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, MarketplaceSpacing.buttonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
