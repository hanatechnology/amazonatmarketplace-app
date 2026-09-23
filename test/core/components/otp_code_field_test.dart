import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace/core/components/marketplace/auth/otp_code_field.dart';
import 'package:marketplace/core/theme/marketplace_theme.dart';

/// The iOS bug behind this widget: six fields meant five focus hops, and every
/// hop dropped and re-opened the keyboard. These lock in the property that
/// prevents it — the row owns exactly one text field, whatever is typed.
void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  Widget harness({int length = 6, ValueChanged<String>? onChanged}) =>
      MaterialApp(
        theme: MarketplaceTheme.lightTheme,
        home: Scaffold(
          body: OtpCodeField(
            controller: controller,
            focusNode: focusNode,
            length: length,
            onChanged: onChanged,
            autofocus: false,
          ),
        ),
      );

  testWidgets('renders one text field for the whole code', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('typing keeps focus on that single field', (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    // The check that matters: no second field ever took over, so the platform
    // input connection was never torn down mid-code.
    expect(find.byType(TextField), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('each digit is painted in its own box', (tester) async {
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextField), '4821');
    await tester.pump();

    for (final digit in ['4', '8', '2', '1']) {
      expect(find.text(digit), findsOneWidget);
    }
  });

  testWidgets('a whole pasted code arrives in one callback', (tester) async {
    final received = <String>[];
    await tester.pumpWidget(harness(onChanged: received.add));

    // What SMS autofill delivers: the entire code at once.
    await tester.enterText(find.byType(TextField), '918273');
    await tester.pump();

    expect(received, ['918273']);
    expect(controller.text, '918273');
  });

  testWidgets('refuses more than length digits and non-digits',
      (tester) async {
    await tester.pumpWidget(harness(length: 4));

    await tester.enterText(find.byType(TextField), '12a34567');
    await tester.pump();

    expect(controller.text, '1234');
  });
}
