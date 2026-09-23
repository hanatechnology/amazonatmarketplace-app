import 'package:get/get.dart';

import 'storage_service.dart';

/// Who the app is acting as right now.
///
/// Three states, not two: a signed-in customer, a guest who chose to browse
/// without an account, and neither — a first launch that has not answered the
/// welcome screen yet. The guest choice is persisted, so a cold start after it
/// goes straight to the shell instead of asking again.
///
/// Guest browsing is possible because the catalogue endpoints are open:
/// `GET /products`, `GET /products/{id}`, `GET /categories`,
/// `GET /categories/tree`, `GET /banners` and `GET /dropdowns/cities` all
/// answer 200 without a bearer. Everything else — `/stores`, `/orders`,
/// `/addresses`, `/notifications`, the remaining `/dropdowns` — answers 401,
/// and those screens are what [AuthGuardMiddleware] and the in-tab sign-in
/// walls cover. (The OAS snapshot marks the catalogue endpoints as requiring
/// `clientAccessToken`; the backend does not enforce that. Contract and
/// backend disagree here.)
class SessionService extends GetxService {
  static SessionService get to => Get.find<SessionService>();

  /// SharedPreferences key holding the "browse without an account" choice.
  static const String guestModeKey = 'guest_mode';

  final RxBool _signedIn = false.obs;
  final RxBool _guest = false.obs;

  /// Where the customer was headed when a guard turned them back to login.
  /// Consumed once, by the first successful sign-in after it was set.
  String? _intendedRoute;
  Object? _intendedArguments;

  @override
  void onInit() {
    super.onInit();
    _guest.value = StorageService.instance.read<bool>(guestModeKey) ?? false;
  }

  /// Reactive: reading either of these inside an `Obx` rebuilds on sign-in and
  /// sign-out, which is how the account and sellers tabs swap their contents.
  bool get isSignedIn => _signedIn.value;

  /// A guest is someone browsing *by choice*. Before the welcome screen is
  /// answered this is false, which is what keeps the splash on onboarding.
  bool get isGuest => !_signedIn.value && _guest.value;

  /// True once the welcome screen has been answered either way — the shell is
  /// reachable.
  bool get hasChosen => _signedIn.value || _guest.value;

  // ── Transitions ───────────────────────────────────────────

  /// A token exists: hydrated from secure storage at startup, or just issued by
  /// `POST /auth/verify-otp`. Clears the guest choice — a signed-in customer
  /// who later logs out gets the welcome screen's decision again.
  void markSignedIn() {
    _signedIn.value = true;
    _guest.value = false;
    StorageService.instance.remove(guestModeKey);
  }

  /// The token is gone. [asGuest] keeps the customer inside the shell with the
  /// catalogue still browsable, which is what logging out does — the web client
  /// behaves the same way.
  void markSignedOut({bool asGuest = false}) {
    _signedIn.value = false;
    _guest.value = asGuest;
    if (asGuest) {
      StorageService.instance.write(guestModeKey, true);
    } else {
      StorageService.instance.remove(guestModeKey);
    }
  }

  /// Chosen from the welcome screen. Persisted so later launches skip it.
  void continueAsGuest() {
    _signedIn.value = false;
    _guest.value = true;
    StorageService.instance.write(guestModeKey, true);
  }

  // ── Intended route ────────────────────────────────────────

  /// Remembers a guarded destination so sign-in can finish the journey the
  /// customer actually started — the mobile counterpart of the web's
  /// `/login?redirect=…`.
  void rememberIntendedRoute(String? route, [Object? arguments]) {
    // A sign-in with no destination replaces whatever was remembered rather
    // than inheriting it — otherwise tapping "sign in" from the account tab
    // would drop the customer onto a checkout they abandoned an hour ago.
    if (route == null || route.isEmpty) {
      forgetIntendedRoute();
      return;
    }
    _intendedRoute = route;
    _intendedArguments = arguments;
  }

  /// Returns the remembered destination and forgets it, so a later sign-in does
  /// not replay a journey from hours ago.
  ({String route, Object? arguments})? takeIntendedRoute() {
    final route = _intendedRoute;
    if (route == null) return null;
    final arguments = _intendedArguments;
    _intendedRoute = null;
    _intendedArguments = null;
    return (route: route, arguments: arguments);
  }

  void forgetIntendedRoute() {
    _intendedRoute = null;
    _intendedArguments = null;
  }
}
