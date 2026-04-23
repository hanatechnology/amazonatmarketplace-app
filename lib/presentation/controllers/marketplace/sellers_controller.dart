import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_sellers_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';

const String kSellers = 'sellers';

class SellersController extends BaseStateController<GetSellersUseCase> {
  @override
  void onInit() {
    super.onInit();
    loadSellers();
  }

  Future<void> loadSellers() {
    return handleState(
      kSellers,
      () async => await useCase.execute(),
    );
  }

  Future<void> refreshSellers() {
    return handleState(
      kSellers,
      () async => await useCase.execute(),
    );
  }
}
