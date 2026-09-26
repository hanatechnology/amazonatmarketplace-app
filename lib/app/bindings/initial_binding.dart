import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../data/services/api_service.dart';
import '../../data/services/session_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/theme_service.dart';
import '../../data/repositories/device_token_repository.dart';
import '../../data/repositories/local_cart_repository.dart';
import '../../domain/usecases/marketplace/cart/add_to_local_cart_use_case.dart';
import '../../domain/usecases/marketplace/cart/clear_local_cart_use_case.dart';
import '../../domain/usecases/marketplace/cart/get_local_cart_use_case.dart';
import '../../domain/usecases/marketplace/cart/remove_from_local_cart_use_case.dart';
import '../../domain/usecases/marketplace/cart/set_local_cart_select_all_use_case.dart';
import '../../domain/usecases/marketplace/cart/toggle_local_cart_selection_use_case.dart';
import '../../domain/usecases/marketplace/cart/update_local_cart_quantity_use_case.dart';
import '../../domain/usecases/marketplace/notification/clear_device_token_use_case.dart';
import '../../domain/usecases/marketplace/notification/register_device_token_use_case.dart';
import '../../core/localization/locale_controller.dart';
import '../../presentation/controllers/marketplace/cart_controller.dart';

/// Initial binding that registers permanent services for the entire app lifecycle.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register StorageService (permanent)
    Get.put<StorageService>(
      StorageService.instance,
      permanent: true,
    );
    // Theme preference (permanent) — read by the account screen's toggle.
    Get.put<ThemeService>(ThemeService(), permanent: true);

    // Who the app is acting as: signed-in customer, guest, or undecided.
    // Permanent because the route guards and both shells read it, and it must
    // exist before the first route is built.
    Get.put<SessionService>(SessionService(), permanent: true);

    // Register DioClient (permanent, no token yet — token is injected below
    // after reading secure storage, and again after every login/logout).
    final dioClient = DioClient();
    Get.put<DioClient>(dioClient, permanent: true);

    // Register ApiService (permanent)
    Get.put<ApiService>(ApiService(dioClient), permanent: true);

    // Hydrate the token from secure storage so authenticated users stay
    // logged in across cold starts without an async race condition.
    dioClient.beginHydration();
    StorageService.instance.getToken().then((token) {
      // updateToken also releases requests parked during hydration; the null
      // branch releases them without a token — that customer is logged out.
      if (token != null) {
        dioClient.updateToken(token);
        // The guards read this, not the Dio field — a guest and a signed-in
        // customer are told apart here and nowhere else.
        Get.find<SessionService>().markSignedIn();
      } else {
        dioClient.finishHydration();
      }
    }).catchError((Object _) {
      dioClient.finishHydration();
      return null;
    });

    // SharedPreferences — already initialised in main() via StorageService.init(),
    // so this is synchronous: the cart layer below must exist before the first
    // build, not one microtask after it.
    final prefs = StorageService.prefs;
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<LocalCartRepository>(LocalCartRepository(prefs), permanent: true);

    // ── Cart (permanent, app-lifetime) ────────────────────────
    //
    // The cart is not a screen, it is app state: the tab, the nav badge and
    // every "add to cart" button across the app read the same controller.
    // Registering it on a route instead meant `Get.offAllNamed(MAIN)` after
    // sign-in killed the instance the already-built cart tab was listening to
    // (GetX deletes a route's dependencies by *key* when that route disposes,
    // and re-running the binding is a no-op while the key is still live). The
    // next "add to cart" then built a second controller: the write landed in
    // storage, but the cart tab was wired to a dead one and stayed empty.
    // Permanent instances are exempt from that deletion — one cart, always.
    final localCart = Get.find<LocalCartRepository>();
    Get.put<GetLocalCartUseCase>(GetLocalCartUseCase(localCart),
        permanent: true);
    Get.put<AddToLocalCartUseCase>(AddToLocalCartUseCase(localCart),
        permanent: true);
    Get.put<RemoveFromLocalCartUseCase>(RemoveFromLocalCartUseCase(localCart),
        permanent: true);
    Get.put<UpdateLocalCartQuantityUseCase>(
        UpdateLocalCartQuantityUseCase(localCart),
        permanent: true);
    Get.put<ToggleLocalCartSelectionUseCase>(
        ToggleLocalCartSelectionUseCase(localCart),
        permanent: true);
    Get.put<SetLocalCartSelectAllUseCase>(
        SetLocalCartSelectAllUseCase(localCart),
        permanent: true);
    Get.put<ClearLocalCartUseCase>(ClearLocalCartUseCase(localCart),
        permanent: true);
    Get.put<CartController>(CartController(), permanent: true);

    // Push token plumbing — permanent because registration runs from the splash
    // screen and from login, both before the main shell's binding has executed.
    Get.lazyPut<DeviceTokenRepository>(
      () => DeviceTokenRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<RegisterDeviceTokenUseCase>(
      () => RegisterDeviceTokenUseCase(Get.find<DeviceTokenRepository>()),
      fenix: true,
    );
    Get.lazyPut<ClearDeviceTokenUseCase>(
      () => ClearDeviceTokenUseCase(Get.find<DeviceTokenRepository>()),
      fenix: true,
    );

    // Localization — permanent so it persists across all screens
    Get.put<LocaleController>(
      LocaleController(),
      permanent: true,
    );
  }
}
