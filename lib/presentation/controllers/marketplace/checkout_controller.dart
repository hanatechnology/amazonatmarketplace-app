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
import 'edfali_confirm_controller.dart';
import 'payment_webview_controller.dart';

class CheckoutController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────
  late final CheckoutUseCase _checkoutUseCase;
  late final GetAddressesUseCase _getAddressesUseCase;

  // ── State ─────────────────────────────────────────────────
  late final CheckoutArgs checkoutArgs;
  final addresses          = <CheckoutAddressDto>[].obs;
  final selectedAddressId  = Rx<String?>(null);
  final selectedPayment    = Rx<PaymentMethod?>(null);
  final paymentMethods     = <PaymentMethod>[].obs;
  final shippingFee        = Rx<ShippingFeeEntity?>(null);
  final edfaliMobile       = TextEditingController();
  final edfaliMobileError  = RxnString();
  final isLoadingMethods   = false.obs;
  final isLoadingShipping  = false.obs;
  final isLoadingAddresses = false.obs;
  final isCheckingOut      = false.obs;
  final isSummaryExpanded  = false.obs;
  final addressError       = false.obs;
  final paymentError       = false.obs;

  // ── Computed ──────────────────────────────────────────────
  bool get canPlaceOrder =>
      selectedAddressId.value != null && selectedPayment.value != null;

  /// Items minus discount, plus whatever delivery costs once an address is
  /// picked. The fee is only known after the preview call returns.
  double get total => checkoutArgs.total + (shippingFee.value?.chargeable ?? 0);

  bool get requiresEdfaliMobile =>
      selectedPayment.value == PaymentMethod.edfali;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _checkoutUseCase     = Get.find<CheckoutUseCase>();
    _getAddressesUseCase = Get.find<GetAddressesUseCase>();
    checkoutArgs         = Get.arguments as CheckoutArgs;
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
      onSuccess: (fee, _) => shippingFee.value = fee,
      onError: (_, __) => shippingFee.value = null,
    );
    isLoadingShipping.value = false;
  }

  void toggleSummary() => isSummaryExpanded.toggle();

  /// Opens the address book in pick mode.
  /// If the user picks an address it is inserted (if new) and auto-selected.
  /// If they navigated away without picking, the list is refreshed.
  void navigateToAddAddress() {
    Get.toNamed(
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
      edfaliMobile:
          requiresEdfaliMobile ? edfaliMobile.text.trim() : null,
    );

    final result = await _checkoutUseCase(request);

    result.when(
      onInitial: () {},
      onLoading: () {},
      onSuccess: (data, _) async {
        isCheckingOut.value = false;
        final paymentInit = data.paymentInitiation;

        // Exactly one route applies: Edfali collects an SMS PIN, a hosted
        // gateway opens its checkout page, cash on delivery is already done.
        if (paymentInit != null && paymentInit.requiresOtp) {
          Get.toNamed(
            Routes.MARKETPLACE_EDFALI_CONFIRM,
            arguments: EdfaliConfirmArgs(
              orderId: data.order.id,
              total: total,
              otpSentTo: paymentInit.otpSentTo,
              expiresInSeconds: paymentInit.expiresInSeconds,
            ),
          );
        } else if (paymentInit != null && paymentInit.hasHostedCheckout) {
          await _openPaymentWebView(paymentInit);
        } else {
          _navigateToConfirmed(data.order);
        }
      },
      onError: (message, _) {
        isCheckingOut.value = false;
        Get.snackbar(
          LocaleKeys.error.tr,
          message,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFD32F2F),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }

  // ── Private ───────────────────────────────────────────────
  Future<void> _loadAddresses() async {
    isLoadingAddresses.value = true;

    final result = await _getAddressesUseCase.execute();

    result.maybeWhen(
      onSuccess: (list, _) {
        addresses.assignAll(list.map(_toDto).toList());
        // Auto-select the default address if nothing is selected yet.
        if (selectedAddressId.value == null) {
          try {
            final def = list.firstWhere((a) => a.isDefault);
            selectedAddressId.value = def.id;
          } catch (_) {
            if (list.isNotEmpty) selectedAddressId.value = list.first.id;
          }
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
      );

  Future<void> _openPaymentWebView(PaymentInitiationEntity initiation) async {
    final result = await Get.toNamed(
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
      _navigateToConfirmed(null);
    } else {
      Get.snackbar(
        LocaleKeys.paymentCancelled.tr,
        LocaleKeys.paymentCancelledMessage.tr,
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: const Color(0xFFE65100),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _navigateToConfirmed(OrderSummaryEntity? order) {
    Get.offAllNamed(
      Routes.MARKETPLACE_ORDER_CONFIRMED,
      arguments: OrderConfirmedArgs(
        orderId: order?.id,
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
