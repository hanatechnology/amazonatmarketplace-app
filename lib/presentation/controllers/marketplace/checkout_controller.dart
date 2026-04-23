import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/components/marketplace/checkout/checkout_address_card.dart';
import 'package:marketplace/core/components/marketplace/checkout/checkout_payment_card.dart';
import 'package:marketplace/data/models/marketplace/checkout_request.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/domain/entities/marketplace/order_summary_entity.dart';
import 'package:marketplace/domain/entities/marketplace/payment_initiation_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/checkout_use_case.dart';
import 'payment_webview_controller.dart';

class CheckoutController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────
  late final CheckoutUseCase _checkoutUseCase;
  late final GetAddressesUseCase _getAddressesUseCase;

  // ── State ─────────────────────────────────────────────────
  late final CheckoutArgs checkoutArgs;
  final addresses          = <CheckoutAddressDto>[].obs;
  final selectedAddressId  = Rx<String?>(null);
  final selectedPayment    = Rx<CheckoutPaymentMethod?>(null);
  final isLoadingAddresses = false.obs;
  final isCheckingOut      = false.obs;
  final isSummaryExpanded  = false.obs;
  final addressError       = false.obs;
  final paymentError       = false.obs;

  // ── Computed ──────────────────────────────────────────────
  bool get canPlaceOrder =>
      selectedAddressId.value != null && selectedPayment.value != null;

  double get total => checkoutArgs.total;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _checkoutUseCase     = Get.find<CheckoutUseCase>();
    _getAddressesUseCase = Get.find<GetAddressesUseCase>();
    checkoutArgs         = Get.arguments as CheckoutArgs;
    _loadAddresses();
  }

  // ── Actions ───────────────────────────────────────────────
  void selectAddress(String id) {
    selectedAddressId.value = id;
    addressError.value = false;
  }

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    selectedPayment.value = method;
    paymentError.value = false;
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
      paymentMethod: selectedPayment.value!.apiValue,
    );

    final result = await _checkoutUseCase(request);

    result.when(
      onInitial: () {},
      onLoading: () {},
      onSuccess: (data, _) async {
        isCheckingOut.value = false;
        final paymentInit = data.paymentInitiation;
        if (paymentInit != null && selectedPayment.value!.requiresWebView) {
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
        checkoutUrl: initiation.checkoutUrl,
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
        paymentMethod: selectedPayment.value!.displayName,
      ),
    );
  }

  String? _extractPattern(String? fullUrl) {
    if (fullUrl == null) return null;
    return Uri.tryParse(fullUrl)?.path;
  }
}
