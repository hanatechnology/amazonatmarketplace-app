import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

/// Every push in the app goes through here instead of `Get.toNamed`.
///
/// GetX's own `preventDuplicates` compares the target against `Get.currentRoute`
/// alone, which only catches a second push while the *first* is already on top.
/// It misses the two cases that actually produce doubled screens:
///
/// * a double tap whose two pushes are dispatched before either route has
///   registered — common on a slow first frame, and the reason a hard tap on
///   "sign in" can open two login screens;
/// * a push of a screen that is already further down the stack — a
///   notification opening Orders while Orders is two screens back, leaving two
///   copies to pop through.
///
/// [AppRouteObserver] keeps the live stack, so both are decidable here.
abstract class AppRouter {
  AppRouter._();

  /// Screens that legitimately appear more than once in a stack, because each
  /// copy shows different content: a product's "related" rail opens another
  /// product, a store opens a product which opens that store's page again.
  /// Everything else is a single-instance screen.
  static const Set<String> _stackable = <String>{
    Routes.MARKETPLACE_PRODUCT,
    Routes.MARKETPLACE_PRODUCTS_LIST,
    Routes.MARKETPLACE_SELLER,
    Routes.MARKETPLACE_PRODUCT_GALLERY,
  };

  /// How long an identical push is refused after one is accepted. Covers the
  /// window between the tap and the route appearing in the stack, including
  /// pushes that follow an awaited call — two taps on "send code" fire two
  /// requests whose responses land milliseconds apart.
  static const Duration _repeatWindow = Duration(milliseconds: 700);

  static final Map<String, Stopwatch> _recent = <String, Stopwatch>{};

  /// Drop-in replacement for `Get.toNamed`. Returns null — the same thing GetX
  /// returns for a refused push — when the navigation is suppressed, so
  /// `await`ing callers carry on unharmed.
  ///
  /// Set [allowDuplicate] for the rare screen that must open a second copy of
  /// itself on purpose.
  static Future<T?>? toNamed<T>(
    String route, {
    Object? arguments,
    int? id,
    Map<String, String>? parameters,
    bool allowDuplicate = false,
  }) {
    if (!allowDuplicate && _isRepeat(route, arguments)) return null;

    if (!allowDuplicate &&
        !_stackable.contains(route) &&
        AppRouteObserver.instance.contains(route)) {
      return null;
    }

    _remember(route, arguments);
    return Get.toNamed<T>(
      route,
      arguments: arguments,
      id: id,
      parameters: parameters,
      // GetX's own check refuses ANY push whose name matches the current route,
      // arguments included — which silently swallowed "open the related
      // product" from a product page. The decision belongs here, where the
      // arguments and the whole stack are visible, so its version is off.
      preventDuplicates: false,
    );
  }

  /// The same push twice in quick succession. Keyed by route *and* arguments,
  /// so tapping two different products in fast sequence still opens both while
  /// a double tap on one opens it once.
  static bool _isRepeat(String route, Object? arguments) {
    final watch = _recent[_key(route, arguments)];
    return watch != null && watch.elapsed < _repeatWindow;
  }

  static void _remember(String route, Object? arguments) {
    _recent[_key(route, arguments)] = Stopwatch()..start();
    // The map only ever holds routes touched in the last window; anything older
    // can never block again, so it is dropped rather than kept for the session.
    _recent.removeWhere((_, watch) => watch.elapsed > _repeatWindow);
  }

  static String _key(String route, Object? arguments) {
    if (arguments == null) return route;
    // Identity, not equality: entities without `==` would otherwise collide by
    // `toString`, and two different orders must not look like one repeat.
    return '$route#${identityHashCode(arguments)}#${arguments.hashCode}';
  }

  /// Test/debug hook — forgets the repeat window.
  @visibleForTesting
  static void reset() => _recent.clear();
}

/// Keeps the names currently on the root navigator, in push order.
///
/// Registered on `GetMaterialApp.navigatorObservers`, which GetX merges with
/// its own observer rather than replacing it.
class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver._();

  static final AppRouteObserver instance = AppRouteObserver._();

  final List<String> _stack = <String>[];

  /// Snapshot of the live stack, oldest first. Dialogs, bottom sheets and
  /// snackbars carry no route name and never appear here.
  List<String> get stack => List<String>.unmodifiable(_stack);

  bool contains(String route) => _stack.contains(route);

  /// Test hook — the observer is a singleton, so a widget test that builds a
  /// fresh app would otherwise inherit the previous test's stack.
  @visibleForTesting
  void resetStack() => _stack.clear();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) _stack.add(name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _remove(oldRoute);
    final name = newRoute?.settings.name;
    if (name != null) _stack.add(name);
  }

  void _remove(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;
    // Last occurrence: a stackable screen can hold several copies, and the one
    // leaving is always the newest.
    final index = _stack.lastIndexOf(name);
    if (index != -1) _stack.removeAt(index);
  }
}
