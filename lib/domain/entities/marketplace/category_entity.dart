import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.parentId,
    this.children = const [],
  });

  final String id;
  final String name;
  final String imageUrl;

  /// Null for a top-level category.
  final String? parentId;

  /// Populated only by `GET /categories/tree`; the flat `GET /categories`
  /// carries no nesting, so this stays empty there.
  final List<CategoryEntity> children;

  /// What the tiles and the subcategory rail count. Zero means either a leaf
  /// category or a flat-list entity — both render the same way.
  int get subcategoryCount => children.length;

  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props => [id, name, imageUrl, parentId, children];
}
