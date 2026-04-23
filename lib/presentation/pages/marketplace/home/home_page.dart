import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/presentation/controllers/marketplace/cart_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/search_bar_widget.dart';
import '../../../../core/components/marketplace/promo_banner.dart';
import '../../../../core/components/marketplace/category_chip.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/home_controller.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../app/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.find<HomeController>();
  final _bannerController = PageController();
  Timer? _autoScrollTimer;
  bool _userInteractingWithBanner = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_userInteractingWithBanner) return;
      if (_bannerController.hasClients && controller.banners.isNotEmpty) {
        final next = (_bannerController.page?.round() ?? 0) + 1;
        _bannerController.animateToPage(
          next % controller.banners.length,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: MarketplaceColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── Search Bar ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: SearchBarWidget(
                    hintText: LocaleKeys.searchProducts.tr,
                    onSearch: controller.searchProducts,
                    onFilter: () {
                      // TODO: Open filter bottom sheet
                    },
                  ),
                ),
              ),

              // ── Banner Carousel ─────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.banners.isEmpty)
                    return const SizedBox.shrink();
                  return Column(
                    children: [
                      SizedBox(
                        height: MarketplaceSpacing.bannerHeight,
                        child: GestureDetector(
                          onPanDown: (_) =>
                              setState(() => _userInteractingWithBanner = true),
                          onPanEnd: (_) => setState(
                              () => _userInteractingWithBanner = false),
                          onPanCancel: () => setState(
                              () => _userInteractingWithBanner = false),
                          child: PageView.builder(
                            controller: _bannerController,
                            itemCount: controller.banners.length,
                            onPageChanged: controller.onBannerChanged,
                            itemBuilder: (_, index) {
                              final banner = controller.banners[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: MarketplaceSpacing.screenPaddingH,
                                ),
                                child: PromoBanner(
                                  title: banner['title']!.tr,
                                  subtitle: banner['subtitle']!.tr,
                                  ctaLabel: banner['cta']!.tr,
                                  imageUrl: banner['image']!,
                                  onCta: () {
                                    // TODO: Navigate to promotion
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: MarketplaceSpacing.sm),
                      Obx(() => SmoothPageIndicator(
                            controller: _bannerController,
                            count: controller.banners.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: MarketplaceColors.primary,
                              dotColor: MarketplaceColors.stroke,
                              dotHeight: 6,
                              dotWidth: 6,
                              expansionFactor: 3,
                            ),
                          )),
                    ],
                  );
                }),
              ),

              // ── Category Section ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.lg,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: _SectionHeader(
                    title: LocaleKeys.category.tr,
                    onSeeAll: () {
                      // TODO: Navigate to full category page (tab 1)
                    },
                  ),
                ),
              ),

              // ── Category Chips (horizontal scroll) ──────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MarketplaceSpacing.categoryImageHeight +
                      24, // image + label
                  child: _buildCategoryList(),
                ),
              ),

              // ── Popular Products Header ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.lg,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                  ),
                  child: _SectionHeader(
                    title: LocaleKeys.popularProducts.tr,
                    onSeeAll: () =>
                        Get.toNamed(Routes.MARKETPLACE_PRODUCTS_LIST),
                  ),
                ),
              ),

              // ── Product Grid ────────────────────────────
              _buildProductGrid(),

              // ── Bottom spacing for nav bar ──────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: MarketplaceSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Categories horizontal list with StateBuilder
  Widget _buildCategoryList() {
    return Obx(() {
      final state = controller.stateFor(HomeController.kCategories);
      return state.value.when(
        onInitial: () => const SizedBox.shrink(),
        onLoading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          itemCount: 6,
          separatorBuilder: (_, __) =>
              const SizedBox(width: MarketplaceSpacing.categoryGap),
          itemBuilder: (_, __) => const CategoryChipShimmer(),
        ),
        onSuccess: (data, _) {
          final categories = data as List<CategoryEntity>;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: MarketplaceSpacing.categoryGap),
            itemBuilder: (_, index) => CategoryChip(
              imageUrl: categories[index].imageUrl,
              label: categories[index].name,
              isSelected: _selectedCategoryId == categories[index].id,
              onTap: () {
                setState(() => _selectedCategoryId = categories[index].id);
                Get.toNamed(
                  Routes.MARKETPLACE_PRODUCTS_LIST,
                  arguments: {
                    'categoryId': categories[index].id,
                    'categoryName': categories[index].name,
                  },
                );
              },
            ),
          );
        },
        onError: (message, _) => Center(
          child: Text(message),
        ),
      );
    });
  }

  /// Products grid with StateBuilder
  Widget _buildProductGrid() {
    return Obx(() {
      final state = controller.stateFor(HomeController.kProducts);
      return state.value.when(
        onInitial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        onLoading: () => SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          sliver: SliverGrid.count(
            crossAxisCount: MarketplaceSpacing.productGridColumns,
            crossAxisSpacing: MarketplaceSpacing.productGridGap,
            mainAxisSpacing: MarketplaceSpacing.productGridGap,
            childAspectRatio: MarketplaceSpacing.productCardWidth /
                MarketplaceSpacing.productCardHeight,
            children: List.generate(4, (_) => const ProductCardShimmer()),
          ),
        ),
        onSuccess: (data, _) {
          final products = data as List<ProductEntity>;
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: MarketplaceSpacing.productGridColumns,
              crossAxisSpacing: MarketplaceSpacing.productGridGap,
              mainAxisSpacing: MarketplaceSpacing.productGridGap,
              childAspectRatio: MarketplaceSpacing.productCardWidth /
                  MarketplaceSpacing.productCardHeight,
              children: products
                  .map((product) => ProductCard(
                        imageUrl: product.imageUrl,
                        name: product.name,
                        sellerName: product.sellerName,
                        price: product.price,
                        rating: product.rating,
                        onTap: () => Get.toNamed(
                          Routes.MARKETPLACE_PRODUCT,
                          arguments: product.id,
                        ),
                        onAddToCart: () async {
                          await Get.find<CartController>()
                              .addProduct(product, 1);
                        },
                      ))
                  .toList(),
            ),
          );
        },
        onError: (message, _) => SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                Text(message),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.loadHomeData,
                  child: Text(LocaleKeys.retry.tr),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Section header with title + "See All" action
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: MarketplaceTypography.sectionHeading),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            LocaleKeys.seeAll.tr,
            style: MarketplaceTypography.seeAll,
          ),
        ),
      ],
    );
  }
}
