import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../routes/app_routes.dart';

/// Route-level sign-in guard.
///
/// Sits on every page whose data comes from a bearer-only endpoint — orders,
/// addresses, notifications, refunds, checkout, stores. A guest who reaches one
/// (a deep link, a push tap, a stale back stack) is sent to login, and the
/// destination is kept so [SessionService.takeIntendedRoute] can resume it once
/// the OTP is verified.
///
/// Arguments are deliberately not captured here: GetX hands `redirect` the
/// route name only. Flows that carry arguments — checkout, a store profile —
/// guard at the call site with [AuthGuard.ensureSignedIn] instead, which keeps
/// them; this middleware is the backstop for everything else.
class AuthGuardMiddleware extends GetMiddleware {
  AuthGuardMiddleware({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    if (SessionService.to.isSignedIn) return null;
    SessionService.to.rememberIntendedRoute(route);
    return const RouteSettings(name: Routes.MARKETPLACE_LOGIN);
  }
}
