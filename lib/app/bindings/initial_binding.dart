import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../data/services/api_service.dart';
import '../../data/services/session_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/theme_service.dart';
import '../../data/repositories/device_token_repository.dart';
import '../../data/repositories/local_cart_repository.dart';
import '../../domain/usecases/marketplace/notification/clear_device_token_use_case.dart';
import '../../domain/usecases/marketplace/notification/register_device_token_use_case.dart';
import '../../core/localization/locale_controller.dart';

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

    // SharedPreferences — already initialised in main() via StorageService.init()
    // We expose the instance here so LocalCartRepository can Get.find() it.
    SharedPreferences.getInstance().then((prefs) {
      if (!Get.isRegistered<SharedPreferences>()) {
        Get.put<SharedPreferences>(prefs, permanent: true);
      }
      if (!Get.isRegistered<LocalCartRepository>()) {
        Get.put<LocalCartRepository>(
          LocalCartRepository(prefs),
          permanent: true,
        );
      }
    });

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
