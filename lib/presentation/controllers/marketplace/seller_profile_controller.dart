import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_seller_details_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';

const String kSellerProfile = 'sellerProfile';

class SellerProfileController
    extends BaseStateController<GetSellerDetailsUseCase> {
  late String sellerId;

  @override
  void onInit() {
    super.onInit();
    sellerId = Get.arguments ?? '';
    if (sellerId.isNotEmpty) {
      loadSellerProfile();
    }
  }

  Future<void> loadSellerProfile() {
    return handleState(
      kSellerProfile,
      () async => await useCase.call(sellerId),
    );
  }

  Future<void> refreshSellerProfile() {
    return handleState(
      kSellerProfile,
      () async => await useCase.call(sellerId),
    );
  }
}
