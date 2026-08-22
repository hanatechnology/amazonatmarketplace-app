import 'product_filter.dart';

/// Search text plus filter state for one `GET /products` request.
///
/// Carried as `PaginationInput.filters` so the paginated use case takes a
/// single value instead of growing a parameter per dimension.
class ProductQuery {
  const ProductQuery({this.search, this.filter = const ProductFilter()});

  final String? search;
  final ProductFilter filter;

  /// Price bounds only — the rest map to dedicated query params.
  Map<String, dynamic> get priceParams => {
        if (filter.minPrice != null) 'filters[gte_base_price]': filter.minPrice,
        if (filter.maxPrice != null) 'filters[lte_base_price]': filter.maxPrice,
      };
}
