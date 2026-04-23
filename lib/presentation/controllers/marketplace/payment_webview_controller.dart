import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewArgs {
  const PaymentWebViewArgs({
    required this.checkoutUrl,
    required this.successUrlPattern,
    required this.cancelUrlPattern,
  });

  final String checkoutUrl;
  final String successUrlPattern;
  final String cancelUrlPattern;
}

enum PaymentWebViewResult { success, cancelled }

class PaymentWebViewController extends GetxController {
  late final WebViewController webViewController;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as PaymentWebViewArgs;

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => isLoading.value = true,
        onPageFinished: (_) => isLoading.value = false,
        onNavigationRequest: (request) {
          final url = request.url;

          if (url.contains(args.successUrlPattern)) {
            Get.back(result: PaymentWebViewResult.success);
            return NavigationDecision.prevent;
          }

          if (url.contains(args.cancelUrlPattern)) {
            Get.back(result: PaymentWebViewResult.cancelled);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(args.checkoutUrl));
  }
}
