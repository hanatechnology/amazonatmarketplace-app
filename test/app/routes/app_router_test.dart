import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_router.dart';
import 'package:marketplace/app/routes/app_routes.dart';

/// The duplicate-screen bug these cover: two fast taps used to push two copies
/// of the same screen, because GetX only compares the target against the route
/// currently on top.
void main() {
  Widget harness() => GetMaterialApp(
        initialRoute: Routes.MARKETPLACE_MAIN,
        navigatorObservers: [AppRouteObserver.instance],
        getPages: [
          GetPage(
            name: Routes.MARKETPLACE_MAIN,
            page: () => const Scaffold(body: Text('main')),
          ),
          GetPage(
            name: Routes.MARKETPLACE_LOGIN,
            page: () => const Scaffold(body: Text('login')),
          ),
          GetPage(
            name: Routes.MARKETPLACE_ORDERS,
            page: () => const Scaffold(body: Text('orders')),
          ),
          GetPage(
            name: Routes.MARKETPLACE_PRODUCT,
            page: () => const Scaffold(body: Text('product')),
          ),
        ],
      );

  setUp(() {
    AppRouter.reset();
    AppRouteObserver.instance.resetStack();
  });

  int occurrences(String route) =>
      AppRouteObserver.instance.stack.where((r) => r == route).length;

  testWidgets('a double tap opens one login screen', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_LOGIN), 1);
  });

  testWidgets('a screen already deeper in the stack is not pushed again',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppRouter.toNamed<void>(Routes.MARKETPLACE_ORDERS);
    await tester.pumpAndSettle();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
    await tester.pumpAndSettle();

    // A push from the top of the stack, e.g. a notification tap.
    AppRouter.reset();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_ORDERS);
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_ORDERS), 1);
  });

  testWidgets('drill-down screens still stack on themselves', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // Product A, then a related product B — two copies is the correct result.
    AppRouter.toNamed<void>(Routes.MARKETPLACE_PRODUCT, arguments: 'a');
    await tester.pumpAndSettle();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_PRODUCT, arguments: 'b');
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_PRODUCT), 2);
  });

  testWidgets('a double tap on one product card opens it once', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    const id = 'same-product';
    AppRouter.toNamed<void>(Routes.MARKETPLACE_PRODUCT, arguments: id);
    AppRouter.toNamed<void>(Routes.MARKETPLACE_PRODUCT, arguments: id);
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_PRODUCT), 1);
  });

  testWidgets('clearing the stack frees a screen to be opened again',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppRouter.toNamed<void>(Routes.MARKETPLACE_ORDERS);
    await tester.pumpAndSettle();

    // What sign-in does: rebuild the shell, then resume the journey.
    Get.offAllNamed<void>(Routes.MARKETPLACE_MAIN);
    await tester.pumpAndSettle();

    AppRouter.reset();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_ORDERS);
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_ORDERS), 1);
  });

  testWidgets('popping frees the screen to be opened again', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
    await tester.pumpAndSettle();
    Get.back<void>();
    await tester.pumpAndSettle();

    AppRouter.reset();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
    await tester.pumpAndSettle();

    expect(occurrences(Routes.MARKETPLACE_LOGIN), 1);
  });
}
