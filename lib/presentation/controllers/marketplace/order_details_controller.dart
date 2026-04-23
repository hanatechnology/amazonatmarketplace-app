import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_order_details_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';

const String kOrderDetails = 'orderDetails';

class OrderDetailsController
    extends BaseStateController<GetOrderDetailsUseCase> {
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments ?? '';
    if (orderId.isNotEmpty) {
      loadOrderDetails();
    }
  }

  Future<void> loadOrderDetails() {
    return handleState(
      kOrderDetails,
      () async => await useCase.call(orderId),
    );
  }

  Future<void> refreshOrderDetails() {
    return handleState(
      kOrderDetails,
      () async => await useCase.call(orderId),
    );
  }
}
