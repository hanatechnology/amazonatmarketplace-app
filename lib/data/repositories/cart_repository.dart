import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/cart_item_model.dart';

class CartRepository extends BaseRepository<ApiService> {
  CartRepository(super.service);

  Future<Result<List<CartItemModel>>> getCartItems() {
    return get(
      '/cart',
      (json) => (json as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<CartItemModel>> addToCart(
    String productId,
    int quantity,
  ) {
    return post(
      '/cart/add',
      (json) => CartItemModel.fromJson(json as Map<String, dynamic>),
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  Future<Result<CartItemModel>> updateCartItem(
    String id,
    int quantity,
  ) {
    return patch(
      '/cart/$id',
      (json) => CartItemModel.fromJson(json as Map<String, dynamic>),
      body: {'quantity': quantity},
    );
  }

  Future<Result<bool>> removeFromCart(String id) {
    return delete(
      '/cart/$id',
      (json) => json as bool,
    );
  }
}
