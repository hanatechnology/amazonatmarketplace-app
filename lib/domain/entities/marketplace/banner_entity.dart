import 'package:equatable/equatable.dart';

/// What a banner does when tapped.
enum BannerType {
  /// Opens [BannerEntity.linkUrl].
  imageLink,

  /// Opens the product named by [BannerEntity.productId].
  product;

  static BannerType fromWire(String? value) =>
      value == 'PRODUCT' ? BannerType.product : BannerType.imageLink;
}

class BannerEntity extends Equatable {
  const BannerEntity({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.sortOrder,
    this.title,
    this.linkUrl,
    this.productId,
  });

  final String id;
  final BannerType type;
  final String imageUrl;
  final int sortOrder;
  final String? title;
  final String? linkUrl;
  final String? productId;

  /// False for a banner whose destination is missing, so the UI can render it
  /// as plain artwork instead of a dead tap target.
  bool get isTappable => switch (type) {
        BannerType.product => productId != null && productId!.isNotEmpty,
        BannerType.imageLink => linkUrl != null && linkUrl!.isNotEmpty,
      };

  @override
  List<Object?> get props =>
      [id, type, imageUrl, sortOrder, title, linkUrl, productId];
}
