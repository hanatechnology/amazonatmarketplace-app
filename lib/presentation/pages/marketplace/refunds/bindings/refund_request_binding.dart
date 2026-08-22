import 'package:get/get.dart';
import 'package:marketplace/data/repositories/refund_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/get_payout_methods_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/get_refund_reasons_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/request_refund_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/refund_request_controller.dart';

class RefundRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RefundRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => GetRefundReasonsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetPayoutMethodsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RequestRefundUseCase(Get.find()), fenix: true);

    // Deliberately not fenix: the controller takes its order from
    // Get.arguments in onInit, so each visit must build a fresh one.
    Get.lazyPut(() => RefundRequestController());
  }
}
