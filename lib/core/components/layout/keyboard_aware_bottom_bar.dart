import 'package:flutter/material.dart';

/// Keeps a pinned bottom bar above the software keyboard.
///
/// `Scaffold` shrinks its body for the keyboard but leaves
/// `bottomNavigationBar` glued to the physical bottom of the window, where the
/// keyboard covers it — so on any screen that pairs an input with a bottom
/// action button, the button disappears exactly when the customer needs it.
///
/// Padding the bar by the view inset makes it taller instead, and the Scaffold
/// positions it by its own height, so the visible part sits directly above the
/// keyboard and the scrolling body shortens to match.
///
/// Wrap the widget passed to `bottomNavigationBar`:
///
/// ```dart
/// bottomNavigationBar: const KeyboardAwareBottomBar(child: _BottomBar()),
/// ```
///
/// Not for the app's main tab bar — that one should stay under the keyboard.
class KeyboardAwareBottomBar extends StatelessWidget {
  const KeyboardAwareBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The inset already animates frame by frame as the keyboard opens, so no
      // second animation on top of it.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}
