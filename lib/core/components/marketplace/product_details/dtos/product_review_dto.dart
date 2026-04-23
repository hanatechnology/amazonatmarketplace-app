/// Data for a single review row inside [ProductReviewsSection].
class ProductReviewDto {
  const ProductReviewDto({
    required this.avatarUrl,
    required this.name,
    required this.rating,
    required this.text,
    this.date,
  });

  final String avatarUrl;
  final String name;

  /// Rating on a 0–5 scale.
  final double rating;

  final String text;

  /// Optional display date string, e.g. "Mar 2025".
  final String? date;
}
