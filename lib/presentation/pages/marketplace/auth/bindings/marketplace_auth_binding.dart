import 'package:get/get.dart';
import 'package:marketplace/data/repositories/auth_repository.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/request_otp_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/verify_otp_use_case.dart';
import '../../../../controllers/marketplace/auth_controller.dart';

class MarketplaceAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepository(Get.find()));

    Get.lazyPut(() => VerifyOtpUseCase(Get.find()));
    Get.lazyPut(() => RequestOtpUseCase(Get.find()));

    Get.lazyPut(() => AuthController());
  }
}
