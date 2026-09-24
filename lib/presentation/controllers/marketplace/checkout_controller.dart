import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/components/marketplace/checkout/checkout_address_card.dart';
import 'package:marketplace/data/models/marketplace/checkout_request.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/domain/entities/marketplace/order_summary_entity.dart';
import 'package:marketplace/domain/entities/marketplace/payment_initiation_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/entities/marketplace/shipping_fee_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/checkout_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_payment_methods_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_shipping_fee_use_case.dart';
import 'cart_controller.dart';
import 'edfali_confirm_controller.dart';
import 'payment_webview_controller.dart';
import 'package:marketplace/app/routes/app_router.dart';

class CheckoutController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────
  late final CheckoutUseCase _checkoutUseCase;
  late final GetAddressesUseCase _getAddressesUseCase;

  // ── State ─────────────────────────────────────────────────
  late final CheckoutArgs checkoutArgs;
  final addresses = <CheckoutAddressDto>[].obs;
  final selectedAddressId = Rx<String?>(null);
  final selectedPayment = Rx<PaymentMethod?>(null);
  final paymentMethods = <PaymentMethod>[].obs;
  final shippingFee = Rx<ShippingFeeEntity?>(null);
  final edfaliMobile = TextEditingController();
  final edfaliMobileError = RxnString();
  final isLoadingMethods = false.obs;
  final isLoadingShipping = false.obs;
  final isLoadingAddresses = false.obs;
  final isCheckingOut = false.obs;
  final isSummaryExpanded = false.obs;

  /// Set when the shipping preview is rejected for this vendor/address pair.
  /// `GET /orders/shipping-fee` answers 400 "This vendor does not ship to
  /// zone: …" — the only signal the contract gives that a store does not cover
  /// an address, and checkout would otherwise fail at submit with the same
  /// error after the customer had filled everything in.
  final deliveryUnavailable = false.obs;
  final addressError = false.obs;
  final paymentError = false.obs;

  // ── Computed ──────────────────────────────────────────────
  bool get canPlaceOrder =>
      selectedAddressId.value != null &&
      selectedPayment.value != null &&
      !deliveryUnavailable.value &&
      !isLoadingShipping.value;

  /// Items minus discount, plus whatever delivery costs once an address is
  /// picked. The fee is only known after the preview call returns.
  double get total => checkoutArgs.total + (shippingFee.value?.chargeable ?? 0);

  bool get requiresEdfaliMobile =>
      selectedPayment.value == PaymentMethod.edfali;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _checkoutUseCase = Get.find<CheckoutUseCase>();
    _getAddressesUseCase = Get.find<GetAddressesUseCase>();
    checkoutArgs = Get.arguments as CheckoutArgs;
    _loadAddresses();
    _loadPaymentMethods();
  }

  @override
  void onClose() {
    edfaliMobile.dispose();
    super.onClose();
  }

  // ── Actions ───────────────────────────────────────────────
  void selectAddress(String id) {
    selectedAddressId.value = id;
    addressError.value = false;
    deliveryUnavailable.value = false;
    _loadShippingFee();
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPayment.value = method;
    paymentError.value = false;
    if (method != PaymentMethod.edfali) edfaliMobileError.value = null;
  }

  /// `GET /orders/payment-methods` — render the payment step from this list
  /// rather than a hardcoded enum, or the app offers options that fail.
  Future<void> _loadPaymentMethods() async {
    isLoadingMethods.value = true;
    final state = await Get.find<GetPaymentMethodsUseCase>().execute();
    state.maybeWhen(
      onSuccess: (methods, _) {
        paymentMethods.assignAll(methods);
        if (methods.length == 1) selectedPayment.value = methods.first;
      },
    );
    isLoadingMethods.value = false;
  }

  /// Previews delivery for the chosen address. A failure leaves the fee unknown
  /// rather than guessing zero — the server prices the order either way.
  Future<void> _loadShippingFee() async {
    final addressId = selectedAddressId.value;
    if (addressId == null) return;

    isLoadingShipping.value = true;
    final state = await Get.find<GetShippingFeeUseCase>().call(
      ShippingFeeInput(
        vendorId: checkoutArgs.vendorId,
        addressId: addressId,
      ),
    );
    state.maybeWhen(
      onSuccess: (fee, _) {
        shippingFee.value = fee;
        deliveryUnavailable.value = false;
      },
      onError: (_, code) {
        shippingFee.value = null;
        // 400 here means the pair was rejected, not that the network failed;
        // anything else leaves the fee merely unknown and still orderable.
        deliveryUnavailable.value = code == 400;
      },
    );
    isLoadingShipping.value = false;
  }

  void toggleSummary() => isSummaryExpanded.toggle();

  /// Opens the address book in pick mode.
  /// If the user picks an address it is inserted (if new) and auto-selected.
  /// If they navigated away without picking, the list is refreshed.
  void navigateToAddAddress() {
    AppRouter.toNamed(
      Routes.MARKETPLACE_ADDRESSES,
      arguments: {'pickMode': true},
    )?.then((result) {
      if (result is AddressEntity) {
        _applyPickedAddress(result);
      } else {
        _loadAddresses();
      }
    });
  }

  Future<void> placeOrder() async {
    bool valid = true;
    if (selectedAddressId.value == null) {
      addressError.value = true;
      valid = false;
    }
    if (selectedPayment.value == null) {
      paymentError.value = true;
      valid = false;
    }
    // The coverage check is the one failure the customer cannot reason about
    // from the form alone, so it is spelled out rather than only flagged.
    if (deliveryUnavailable.value) {
      addressError.value = true;
      _showError(LocaleKeys.vendorDoesNotDeliver.tr);
      valid = false;
    } else if (isLoadingShipping.value) {
      // Submitting mid-preview would charge a total the customer never saw,
      // and the pair may still turn out to be uncovered.
      _showError(LocaleKeys.checkingDelivery.tr);
      valid = false;
    }
    if (requiresEdfaliMobile && edfaliMobile.text.trim().isEmpty) {
      // The API requires the wallet for EDFALI and never falls back to the
      // account phone, so it has to be collected and shown before submitting.
      edfaliMobileError.value = LocaleKeys.fieldRequired.tr;
      valid = false;
    }
    if (!valid) return;

    isCheckingOut.value = true;

    final request = CheckoutRequest(
      items: checkoutArgs.items
          .map((i) => CheckoutItemRequest(
                productId: i.productId,
                quantity: i.quantity,
              ))
          .toList(),
      addressId: selectedAddressId.value!,
      paymentMethod: _wireValue(selectedPayment.value!),
      edfaliMobile: requiresEdfaliMobile ? edfaliMobile.text.trim() : null,
    );

    final result = await _checkoutUseCase(request);

    result.when(
      onInitial: () {},
      onLoading: () {},
      onSuccess: (data, _) async {
        isCheckingOut.value = false;

        // The order now exists server-side, so this store's items leave the
        // cart immediately — before payment completes, exactly as the web does.
        // Leaving them there invites a second order (and a second debit) for
        // goods that are already committed. Other stores' groups stay put.
        if (Get.isRegistered<CartController>()) {
          await Get.find<CartController>().clearVendor(checkoutArgs.vendorId);
        }

        final paymentInit = data.paymentInitiation;

        // Exactly one route applies: Edfali collects an SMS PIN, a hosted
        // gateway opens its checkout page, cash on delivery is already done.
        if (paymentInit != null && paymentInit.requiresOtp) {
          AppRouter.toNamed(
            Routes.MARKETPLACE_EDFALI_CONFIRM,
            arguments: EdfaliConfirmArgs(
              orderId: data.order.id,
              orderNumber: data.order.orderNumber,
              total: total,
              otpSentTo: paymentInit.otpSentTo,
              expiresInSeconds: paymentInit.expiresInSeconds,
            ),
          );
        } else if (paymentInit != null && paymentInit.hasHostedCheckout) {
          await _openPaymentWebView(paymentInit, data.order);
        } else {
          _navigateToConfirmed(data.order);
        }
      },
      onError: (message, _) {
        isCheckingOut.value = false;
        _showError(message);
      },
    );
  }

  // ── Private ───────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      LocaleKeys.error.tr,
      message,
      backgroundColor: const Color(0xFFFFEBEE),
      colorText: const Color(0xFFD32F2F),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _loadAddresses() async {
    isLoadingAddresses.value = true;

    final result = await _getAddressesUseCase.execute();

    result.maybeWhen(
      onSuccess: (list, _) {
        addresses.assignAll(list.map(_toDto).toList());
        // Auto-select the default address — or the only one — if nothing is
        // selected yet. This goes through selectAddress rather than assigning
        // the id: the shipping fee is priced per address, and setting the id
        // alone left the card looking chosen while the total stayed unpriced
        // until the customer tapped the card they were already on.
        if (selectedAddressId.value == null && list.isNotEmpty) {
          final chosen = list.firstWhere(
            (a) => a.isDefault,
            orElse: () => list.first,
          );
          selectAddress(chosen.id);
        }
      },
      onError: (_, __) {},
    );

    isLoadingAddresses.value = false;
  }

  void _applyPickedAddress(AddressEntity address) {
    final exists = addresses.any((a) => a.id == address.id);
    if (!exists) addresses.insert(0, _toDto(address));
    selectAddress(address.id);
  }

  /// Maps an [AddressEntity] to the compact DTO used by checkout address cards.
  /// [city] uses [state] since it is always a human-readable location string.
  CheckoutAddressDto _toDto(AddressEntity a) => CheckoutAddressDto(
        id: a.id,
        label: a.label,
        street: a.addressLine1,
        city: a.state,
        phone: a.phone,
        isDefault: a.isDefault,
      );

  Future<void> _openPaymentWebView(
    PaymentInitiationEntity initiation,
    OrderSummaryEntity order,
  ) async {
    final result = await AppRouter.toNamed(
      Routes.MARKETPLACE_PAYMENT_WEBVIEW,
      arguments: PaymentWebViewArgs(
        checkoutUrl: initiation.checkoutUrl!,
        successUrlPattern:
            _extractPattern(initiation.successRedirectUrl) ?? 'payment/success',
        cancelUrlPattern:
            _extractPattern(initiation.cancelRedirectUrl) ?? 'payment/cancel',
      ),
    );

    if (result == PaymentWebViewResult.success) {
      _navigateToConfirmed(order);
    } else {
      // The order exists and is unpaid; the outcome screen says so plainly
      // rather than a snackbar the customer can miss.
      Get.offAllNamed(
        Routes.MARKETPLACE_ORDER_CANCELLED,
        arguments: OrderCancelledArgs(
          orderNumber: order.orderNumber,
          total: total,
        ),
      );
    }
  }

  void _navigateToConfirmed(OrderSummaryEntity? order) {
    Get.offAllNamed(
      Routes.MARKETPLACE_ORDER_CONFIRMED,
      arguments: OrderConfirmedArgs(
        orderId: order?.id,
        orderNumber: order?.orderNumber,
        total: total,
        paymentMethod: _displayName(selectedPayment.value!),
      ),
    );
  }

  /// The API's payment methods are brand names, so they are shown as-is; only
  /// the delivery option reads as a phrase and gets a localized label.
  static String _displayName(PaymentMethod method) => switch (method) {
        PaymentMethod.plutu => 'Plutu',
        PaymentMethod.sadad => 'Sadad',
        PaymentMethod.paypal => 'PayPal',
        PaymentMethod.stripe => 'Stripe',
        PaymentMethod.edfali => 'Edfali',
        PaymentMethod.payOnDelivery => LocaleKeys.statusCod.tr,
        PaymentMethod.unknown => LocaleKeys.statusUnknown.tr,
      };

  static String _wireValue(PaymentMethod method) => switch (method) {
        PaymentMethod.plutu => 'PLUTU',
        PaymentMethod.sadad => 'SADAD',
        PaymentMethod.paypal => 'PAYPAL',
        PaymentMethod.stripe => 'STRIPE',
        PaymentMethod.edfali => 'EDFALI',
        PaymentMethod.payOnDelivery => 'PAY_ON_DELIVERY',
        // Never reachable: unrecognised methods are filtered out of the list.
        PaymentMethod.unknown => '',
      };

  String? _extractPattern(String? fullUrl) {
    if (fullUrl == null) return null;
    return Uri.tryParse(fullUrl)?.path;
  }
}
