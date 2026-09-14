/// Sort options offered for product lists.
///
/// Each maps to `sortBy` + `sortDirection` on `GET /products`. Field names come
/// from the web client's `ProductSortBy` type (`PRICE` -> `base_price`,
/// `NAME_EN` / `NAME_AR`); the OAS documents the params but not the field names.
///
/// There is deliberately no rating sort: the API returns no rating field, and
/// ProductModel currently hardcodes it, so such a sort could not do anything.
enum ProductSortOption {
  relevance,
  priceLowHigh,
  priceHighLow,
  nameAsc;

  /// Null for [relevance] — the API already defaults to `created_at desc`.
  String? get sortBy => switch (this) {
        ProductSortOption.relevance => null,
        ProductSortOption.priceLowHigh => 'base_price',
        ProductSortOption.priceHighLow => 'base_price',
        ProductSortOption.nameAsc => 'name_en',
      };

  String? get sortDirection => switch (this) {
        ProductSortOption.relevance => null,
        ProductSortOption.priceLowHigh => 'asc',
        ProductSortOption.priceHighLow => 'desc',
        ProductSortOption.nameAsc => 'asc',
      };
}

/// Active product filter state, shared by every product list.
class ProductFilter {
  const ProductFilter({
    this.sort = ProductSortOption.relevance,
    this.minPrice,
    this.maxPrice,
    this.categoryId,
    this.categoryName,
    this.featuredSection,
  });

  final ProductSortOption sort;
  final double? minPrice;
  final double? maxPrice;
  final String? categoryId;
  final String? categoryName;

  /// `NEW_ARRIVALS` / `BEST_SELLERS` / `ADMIN_PICKS` — the only values the
  /// endpoint's `featured_section` enum accepts.
  final String? featuredSection;

  bool get hasActiveFilters =>
      sort != ProductSortOption.relevance ||
      minPrice != null ||
      maxPrice != null ||
      categoryId != null ||
      featuredSection != null;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Query params for `GET /products`.
  ///
  /// Price bounds go through the endpoint's generic `filters` object. The
  /// mechanism (`gte_` / `lte_` prefixes) is documented; the `base_price` field
  /// name is inferred from the web client and the mobile parser, NOT from the
  /// spec — if the backend names it differently this silently returns unfiltered
  /// results.
  Map<String, dynamic> toQueryParams() => {
        if (sort.sortBy != null) 'sortBy': sort.sortBy,
        if (sort.sortDirection != null) 'sortDirection': sort.sortDirection,
        if (categoryId != null) 'category_id': categoryId,
        if (featuredSection != null) 'featured_section': featuredSection,
        if (minPrice != null) 'filters[gte_base_price]': minPrice,
        if (maxPrice != null) 'filters[lte_base_price]': maxPrice,
      };

  ProductFilter copyWith({
    ProductSortOption? sort,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? categoryName,
    String? featuredSection,
    bool clearPriceRange = false,
    bool clearCategory = false,
    bool clearFeatured = false,
  }) {
    return ProductFilter(
      sort: sort ?? this.sort,
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
      featuredSection:
          clearFeatured ? null : (featuredSection ?? this.featuredSection),
    );
  }
}
