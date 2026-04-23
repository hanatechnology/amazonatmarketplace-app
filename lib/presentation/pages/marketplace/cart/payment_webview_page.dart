import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../controllers/marketplace/payment_webview_controller.dart';

class PaymentWebViewPage extends GetView<PaymentWebViewController> {
  const PaymentWebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(LocaleKeys.completePayment.tr),
        elevation: 0,
        backgroundColor: MarketplaceColors.surface,
        foregroundColor: MarketplaceColors.textPrimary,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller.webViewController),
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                MarketplaceColors.primary,
              ),
            );
          }),
        ],
      ),
    );
  }
}
