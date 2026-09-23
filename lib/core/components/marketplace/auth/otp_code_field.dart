import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';

/// A code row that is one text field wearing several boxes.
///
/// The obvious build — one `TextField` per digit, `requestFocus` on the next as
/// each one fills — flickers the iOS keyboard: every focus hop closes the text
/// input connection and opens a new one, and iOS animates that as a dismiss
/// followed by a re-present. There is no per-field fix; the fix is to stop
/// moving focus at all.
///
/// So a single invisible field owns the whole code and the keyboard, and the
/// boxes below are painted from its text. That also makes SMS autofill and
/// paste trivial — the platform drops six digits into one field, which is
/// exactly what this one expects — and backspace behaves the way the customer
/// expects without any index bookkeeping.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    this.hasError = false,
    this.onChanged,
    this.boxHeight = 56,
    this.gap = 8,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Number of boxes, and the maximum the field will accept.
  final int length;

  /// Paints the row in the danger tone — a rejected code.
  final bool hasError;

  final ValueChanged<String>? onChanged;
  final double boxHeight;
  final double gap;

  /// The screen exists to take a code, so the keyboard comes up with it.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedBuilder(
      // Both matter: the text decides what each box shows, the focus decides
      // which box is highlighted.
      animation: Listenable.merge(<Listenable>[controller, focusNode]),
      builder: (context, _) {
        final digits = controller.text;
        final active = digits.length.clamp(0, length - 1);
        final isFocused = focusNode.hasFocus;

        return SizedBox(
          height: boxHeight,
          child: Stack(
            children: [
              Row(
                children: [
                  for (var i = 0; i < length; i++) ...[
                    Expanded(
                      child: _OtpBox(
                        digit: i < digits.length ? digits[i] : '',
                        isActive: isFocused && i == active,
                        hasError: hasError,
                        palette: palette,
                      ),
                    ),
                    if (i != length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
              // On top of the boxes so a tap anywhere on the row opens the
              // keyboard. Invisible rather than hidden: an offstage field
              // cannot hold the platform input connection.
              Positioned.fill(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  showCursor: false,
                  cursorWidth: 0,
                  enableInteractiveSelection: false,
                  // The glyphs are drawn by the boxes underneath; this field
                  // only has to be tappable and keep the connection alive.
                  style: const TextStyle(
                    color: Colors.transparent,
                    height: 0.01,
                    fontSize: 1,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One painted digit cell. Latin digits, LTR, in both languages — a code is a
/// number, not prose, and Arabic must not reorder it.
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
    required this.palette,
  });

  final String digit;
  final bool isActive;
  final bool hasError;
  final MarketplacePalette palette;

  @override
  Widget build(BuildContext context) {
    final danger = StatusTone.danger.foreground(palette.isDark);
    final borderColor = hasError
        ? danger
        : isActive
            ? palette.brand
            : palette.hairline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isActive || hasError ? 1.5 : 1,
        ),
      ),
      child: Text(
        digit,
        textDirection: TextDirection.ltr,
        style: MarketplaceTypography.rowTitle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: hasError ? danger : palette.textPrimary,
        ),
      ),
    );
  }
}
