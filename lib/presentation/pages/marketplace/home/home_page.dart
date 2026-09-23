import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marketplace/presentation/controllers/marketplace/cart_controller.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/feedback/loading_indicator.dart';
import '../../../../core/components/marketplace/home/home_category_pill.dart';
import '../../../../core/components/marketplace/home/home_hero.dart';
import '../../../../core/components/marketplace/home/home_product_rail_card.dart';
import '../../../../core/components/marketplace/home/home_search_pill.dart';
import '../../../../core/components/marketplace/home/home_section_header.dart';
import '../../../../core/components/marketplace/home/home_store_row.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../../../controllers/marketplace/home_controller.dart';
import '../../../controllers/marketplace/main_navigation_controller.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// Home — editorial layout: a full-bleed banner hero the content sheet
/// overlaps, then a category pill row, a "New arrivals" rail, featured stores,
/// and the paginated popular grid.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Horizontal page padding inside the content sheet.
  static const double _gutter = 20.0;

  /// How many products the "New arrivals" rail shows before the grid repeats
  /// the catalogue in full.
  static const int _railSize = 6;

  /// Hero artwork height, excluding the status-bar inset the hero adds itself.
  static const double _heroHeight = 296.0;

  /// How far the content sheet rides up over the hero. Defined by the hero,
  /// which lays its copy out around it.
  static const double _sheetOverlap = HomeHero.sheetOverlap;

  final controller = Get.find<HomeController>();
  // Starts on the carousel's loop base rather than 0, so the very first swipe
  // can go backwards into the last banner. See [HomeHero.loopBase].
  final _bannerController = PageController(initialPage: HomeHero.loopBase);
  final _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _userInteractingWithBanner = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _scrollController.addListener(_onScroll);
  }

  /// Fetch the next page once the user is within one viewport of the end, so
  /// the next batch is already arriving before they hit the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >=
        position.maxScrollExtent - position.viewportDimension) {
      controller.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_userInteractingWithBanner) return;
      // One banner is not a carousel; anything more pages forever, so the
      // next page is simply the next one — no wrap arithmetic, and no jump
      // back to the first slide for the customer to see.
      if (_bannerController.hasClients && controller.banners.length > 1) {
        final current = _bannerController.page?.round() ?? HomeHero.loopBase;
        _bannerController.animateToPage(
          current + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The hero artwork sits under the status bar in both themes, so the
      // clock and icons must stay light even while the app theme is light.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        // The hero runs under the status bar, so no top SafeArea here — the hero
        // applies the inset itself.
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          color: palette.brand,
          backgroundColor: palette.surface,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Hero + content sheet ────────────────────
              // One sliver, stacked: the hero is positioned and the sheet is the
              // sizing child, offset down by the hero's height less the overlap.
              // Stacking rather than translating keeps the sliver's height honest
              // — a Transform would leave the original box behind and open a gap
              // above the grid.
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: 0,
                      start: 0,
                      end: 0,
                      child: Obx(() => HomeHero(
                            banners: controller.banners,
                            pageController: _bannerController,
                            activeIndex: controller.activeBannerIndex.value,
                            onPageChanged: controller.onBannerChanged,
                            onBannerTap: controller.onBannerTap,
                            onInteractionStart: () =>
                                _userInteractingWithBanner = true,
                            onInteractionEnd: () =>
                                _userInteractingWithBanner = false,
                            height: _heroHeight,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: _heroHeight +
                            MediaQuery.paddingOf(context).top -
                            _sheetOverlap,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(_gutter, 16, _gutter, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeSearchPill(
                              onTap: _openSearch,
                              onFilterTap: _openSearch,
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryPills(),
                            const SizedBox(height: 16),
                            HomeSectionHeader(
                              title: LocaleKeys.newArrivals.tr,
                              onAction: () => AppRouter.toNamed(
                                  Routes.MARKETPLACE_PRODUCTS_LIST),
                            ),
                            const SizedBox(height: 10),
                            _buildProductRail(),
                            const SizedBox(height: 18),
                            _buildFeaturedStores(),
                            const SizedBox(height: 18),
                            HomeSectionHeader(
                              title: LocaleKeys.popularProducts.tr,
                              onAction: () => AppRouter.toNamed(
                                  Routes.MARKETPLACE_PRODUCTS_LIST),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Popular grid ────────────────────────────
              _buildProductGrid(),

              // ── Infinite-scroll footer ──────────────────
              _buildProductsLoadMoreIndicator(),

              // Clears the floating bottom nav.
              const SliverToBoxAdapter(
                child: SizedBox(height: MarketplaceSpacing.xxl + 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the search screen. Filters live there too, so the filter button
  /// lands in the same place.
  void _openSearch() => AppRouter.toNamed(Routes.MARKETPLACE_SEARCH);

  /// Stores have no standalone route — they are the third tab of the shell,
  /// so "See all" switches tabs instead of pushing a page.
  void _openStoresTab() {
    if (Get.isRegistered<MainNavigationController>()) {
      Get.find<MainNavigationController>().changePage(2);
    }
  }

  void _openCategory(CategoryEntity category) {
    AppRouter.toNamed(
      Routes.MARKETPLACE_PRODUCTS_LIST,
      arguments: {'categoryId': category.id, 'categoryName': category.name},
    );
  }

  // ── Categories ────────────────────────────────────────

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 32,
      child: Obx(() {
        final state = controller
            .stateFor<List<CategoryEntity>>(HomeController.kCategories);

        return state.value.when(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) =>
                HomeCategoryPillShimmer(width: index.isEven ? 64 : 86),
          ),
          onSuccess: (categories, _) {
            // Shortcuts, not filters: each pill opens that category's own page,
            // so none of them is ever the "current" one and there is nothing for
            // an "All" pill to reset.
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = categories[index];
                return HomeCategoryPill(
                  label: category.name,
                  onTap: () => _openCategory(category),
                );
              },
            );
          },
          // A failed category list must not cost the user the rest of Home.
          onError: (_, __) => const SizedBox.shrink(),
        );
      }),
    );
  }

  // ── New arrivals rail ─────────────────────────────────

  Widget _buildProductRail() {
    return SizedBox(
      height: 192,
      child: Obx(() {
        final state =
            controller.stateFor<List<ProductEntity>>(HomeController.kProducts);

        return state.value.when(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const HomeProductRailCardShimmer(),
          ),
          onSuccess: (products, _) {
            if (products.isEmpty) return const SizedBox.shrink();
            final rail = products.take(_railSize).toList();

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: rail.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final product = rail[index];
                return HomeProductRailCard(
                  imageUrl: product.imageUrl,
                  name: product.name,
                  sellerName: product.sellerName,
                  price: product.price,
                  rating: product.rating,
                  onTap: () => AppRouter.toNamed(
                    Routes.MARKETPLACE_PRODUCT,
                    arguments: product.id,
                  ),
                );
              },
            );
          },
          // The grid below reports the same failure with a retry — one error
          // message per screen is enough.
          onError: (_, __) => const SizedBox.shrink(),
        );
      }),
    );
  }

  // ── Featured stores ───────────────────────────────────

  Widget _buildFeaturedStores() {
    return Obx(() {
      final state =
          controller.stateFor<List<SellerEntity>>(HomeController.kStores);

      return state.value.when(
        onInitial: () => const SizedBox.shrink(),
        onLoading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(title: LocaleKeys.featuredStores.tr),
            const SizedBox(height: 6),
            ...List.generate(2, (_) => const HomeStoreRowShimmer()),
          ],
        ),
        onSuccess: (stores, _) {
          if (stores.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSectionHeader(
                title: LocaleKeys.featuredStores.tr,
                onAction: _openStoresTab,
              ),
              const SizedBox(height: 2),
              for (var i = 0; i < stores.length; i++)
                HomeStoreRow(
                  name: stores[i].name,
                  logoUrl: stores[i].logoUrl,
                  isVerified: stores[i].isVerified,
                  description: stores[i].description,
                  showDivider: i != 0,
                  onTap: () => AppRouter.toNamed(
                    Routes.MARKETPLACE_SELLER,
                    arguments: stores[i].id,
                  ),
                ),
            ],
          );
        },
        // Stores need a customer token; an unauthenticated or failing call
        // simply drops the section rather than blocking the page.
        onError: (_, __) => const SizedBox.shrink(),
      );
    });
  }

  // ── Popular grid ──────────────────────────────────────

  Widget _buildProductGrid() {
    return Obx(() {
      final state =
          controller.stateFor<List<ProductEntity>>(HomeController.kProducts);

      return state.value.when(
        onInitial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        onLoading: () => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          sliver: SliverGrid.count(
            crossAxisCount: MarketplaceSpacing.productGridColumns,
            crossAxisSpacing: MarketplaceSpacing.productGridGap,
            mainAxisSpacing: MarketplaceSpacing.productGridGap,
            childAspectRatio: MarketplaceSpacing.productCardWidth /
                MarketplaceSpacing.productCardHeight,
            children: List.generate(4, (_) => const ProductCardShimmer()),
          ),
        ),
        onSuccess: (products, _) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
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
                      onTap: () => AppRouter.toNamed(
                        Routes.MARKETPLACE_PRODUCT,
                        arguments: product.id,
                      ),
                      onAddToCart: () async {
                        await Get.find<CartController>().addProduct(product, 1);
                      },
                    ))
                .toList(),
          ),
        ),
        onError: (message, _) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _gutter,
              vertical: MarketplaceSpacing.lg,
            ),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: MarketplaceTypography.body.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.sm),
                TextButton(
                  onPressed: controller.loadHomeData,
                  child: Text(
                    LocaleKeys.retry.tr,
                    style: MarketplaceTypography.body.copyWith(
                      color: context.palette.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Spinner shown while the next product page is in flight.
  Widget _buildProductsLoadMoreIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (!controller.isLoadingMoreProducts.value) {
          return const SizedBox.shrink();
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: MarketplaceSpacing.lg),
          child: Center(child: LoadingIndicator()),
        );
      }),
    );
  }
}
