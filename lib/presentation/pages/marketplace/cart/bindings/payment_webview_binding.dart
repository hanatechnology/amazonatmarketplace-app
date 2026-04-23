import 'package:get/get.dart';
import 'package:marketplace/presentation/controllers/marketplace/payment_webview_controller.dart';

class PaymentWebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentWebViewController>(() => PaymentWebViewController());
  }
}
