import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/category_controller.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../app/routes/app_routes.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(
          LocaleKeys.allCategories.tr,
          style: MarketplaceTypography.screenTitle,
        ),
        backgroundColor: MarketplaceColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshCategory,
        color: MarketplaceColors.primary,
        child: Obx(() {
          final state = controller.stateFor<List<CategoryEntity>>(kCategoryProducts);
          return state.value.when(
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => GridView.builder(
              padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: MarketplaceSpacing.md,
                mainAxisSpacing: MarketplaceSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemCount: 9,
              itemBuilder: (_, __) => const CategoryChipShimmer(),
            ),
            onSuccess: (data, _) {
              final categories = data;
              return GridView.builder(
                padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: MarketplaceSpacing.md,
                  mainAxisSpacing: MarketplaceSpacing.md,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  return _CategoryGridItem(
                    category: cat,
                    onTap: () => Get.toNamed(
                      Routes.MARKETPLACE_PRODUCTS_LIST,
                      arguments: {
                        'categoryId': cat.id,
                        'categoryName': cat.name,
                      },
                    ),
                  );
                },
              );
            },
            onError: (message, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message ?? LocaleKeys.error.tr,
                    style: MarketplaceTypography.descriptionBody,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: controller.refreshCategory,
                    child: Text(LocaleKeys.retry.tr),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({required this.category, required this.onTap});

  final CategoryEntity category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MarketplaceRadius.card),
              child: AppNetworkImage(
                imageUrl: category.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: MarketplaceTypography.cardSubtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
