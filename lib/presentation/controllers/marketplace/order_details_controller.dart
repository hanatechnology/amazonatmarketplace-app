import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/order/cancel_order_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_order_details_use_case.dart';
import 'orders_controller.dart';

const String kOrderDetails = 'orderDetails';
const String kCancelOrder = 'cancelOrder';

class OrderDetailsController
    extends BaseStateController<GetOrderDetailsUseCase> {
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String? ?? '';
    if (orderId.isNotEmpty) {
      loadOrderDetails();
    }
  }

  Future<void> loadOrderDetails() {
    return handleState<OrderEntity>(
      kOrderDetails,
      () => useCase.call(orderId),
    );
  }

  Future<void> refreshOrderDetails() => loadOrderDetails();

  /// Anchors the refund tracker card so the strip at the top can scroll to it.
  final GlobalKey refundTrackerKey = GlobalKey();

  /// Brings the tracker into view. A no-op when the card is not mounted — the
  /// strip is only tappable when a refund exists, but the list is virtualised
  /// and the key can be unattached mid-rebuild.
  Future<void> scrollToRefundTracker() async {
    final context = refundTrackerKey.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  OrderEntity? get order => getOperationData<OrderEntity>(kOrderDetails);

  bool get isCancelling => getState<OrderEntity>(kCancelOrder).isLoading;

  /// Cancels the order and swaps the detail payload for the server's response.
  /// The list controller, if it is alive behind this page, is patched too.
  ///
  /// The cancel response omits `items`, `vendor`, and `shippingAddress`, so the
  /// loaded order is kept and only the changed fields are taken from it.
  Future<void> cancelOrder({String? reason}) async {
    final current = order;
    if (current == null || !current.canCancel) return;

    await handleState<OrderEntity>(
      kCancelOrder,
      () => Get.find<CancelOrderUseCase>().call(
        CancelOrderInput(orderId: orderId, reason: reason),
      ),
      onSuccess: (cancelled, _) {
        final merged = OrderEntity(
          id: current.id,
          orderNumber: current.orderNumber,
          status: cancelled.status,
          paymentMethod: current.paymentMethod,
          vendorId: current.vendorId,
          vendorName: current.vendorName,
          subtotal: current.subtotal,
          shippingFee: current.shippingFee,
          totalAmount: current.totalAmount,
          items: current.items,
          createdAt: current.createdAt,
          cancellationReason: cancelled.cancellationReason,
          refundedAt: cancelled.refundedAt,
          shippingAddress: current.shippingAddress,
        );

        stateFor<OrderEntity>(kOrderDetails).value = AppStateSuccess(merged);

        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().patchOrder(merged);
        }

        Get.snackbar(
          LocaleKeys.orderCancelled.tr,
          LocaleKeys.orderCancelledMessage.tr,
        );
      },
    );
  }
}
