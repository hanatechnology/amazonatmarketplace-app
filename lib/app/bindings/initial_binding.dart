import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/local_cart_repository.dart';
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
    // Register DioClient (permanent, no token yet — token is injected below
    // after reading secure storage, and again after every login/logout).
    final dioClient = DioClient();
    Get.put<DioClient>(dioClient, permanent: true);

    // Register ApiService (permanent)
    Get.put<ApiService>(ApiService(dioClient), permanent: true);

    // Hydrate the token from secure storage so authenticated users stay
    // logged in across cold starts without an async race condition.
    StorageService.instance.getToken().then((token) {
      if (token != null) dioClient.updateToken(token);
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

    // Localization — permanent so it persists across all screens
    Get.put<LocaleController>(
      LocaleController(),
      permanent: true,
    );
  }
}
