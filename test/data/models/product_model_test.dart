import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace/data/models/marketplace/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    // Shape taken verbatim from staging GET /products.
    Map<String, dynamic> payload({
      Object? imageUrl = 'https://cdn.example.com/a.png',
      Object? images = const ['https://cdn.example.com/a.png'],
    }) =>
        jsonDecode(jsonEncode({
          'id': '3df0021f-073e-48b1-873c-0f7bbcdd7103',
          'name_ar': 'مفرش سرير زوجي',
          'name_en': 'Double bedspread',
          'description_ar': 'وصف',
          'description_en': 'Description',
          'base_price': '100.000',
          'vendor_id': '5b80f510-7051-49bd-9887-4e74226267a0',
          'store_name_ar': 'الأنامل الليبية',
          'store_name_en': 'Al namel ellibya',
          'store_logo_url': 'https://cdn.example.com/logo.jpg',
          'images': images,
          'image_url': imageUrl,
          'category_id': 'e59136e1-eca8-4573-8be7-35b4c00c2813',
        })) as Map<String, dynamic>;

    test('parses a fully populated product', () {
      final product = ProductModel.fromJson(payload());

      expect(product.imageUrl, 'https://cdn.example.com/a.png');
      expect(product.imageUrls, hasLength(1));
      expect(product.price, '100.000');
    });

    test('survives a product saved before any photo was uploaded', () {
      // A real staging row: the vendor created the product with no images, so
      // the list payload carries image_url: null and images: []. This used to
      // throw and fail the whole page.
      final product = ProductModel.fromJson(
        payload(imageUrl: null, images: const []),
      );

      expect(product.imageUrl, '');
      expect(product.imageUrls, isEmpty);
      expect(product.nameEn, 'Double bedspread');
    });

    test('falls back to the first gallery image when image_url is null', () {
      final product = ProductModel.fromJson(
        payload(imageUrl: null, images: const ['https://cdn.example.com/b.png']),
      );

      expect(product.imageUrl, 'https://cdn.example.com/b.png');
    });
  });
}
