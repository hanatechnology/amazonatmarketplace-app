import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Debounced search pill for the stores list.
///
/// `GET /stores` filters on `contain_name`, so this matches store names only —
/// the placeholder says so rather than promising a product search it cannot do.
class StoreSearchField extends StatefulWidget {
  const StoreSearchField({
    super.key,
    required this.onSearch,
    this.controller,
    this.debounceMs = 400,
  });

  final ValueChanged<String> onSearch;
  final TextEditingController? controller;
  final int debounceMs;

  @override
  State<StoreSearchField> createState() => _StoreSearchFieldState();
}

class _StoreSearchFieldState extends State<StoreSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(_controller.text.trim());
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 44,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        children: [
          Icon(MarketplaceIcons.search, size: 18, color: palette.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              style: MarketplaceTypography.body.copyWith(
                fontSize: 13,
                color: palette.textPrimary,
              ),
              cursorColor: palette.brand,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: LocaleKeys.searchSellers.tr,
                hintStyle: MarketplaceTypography.body.copyWith(
                  fontSize: 13,
                  color: palette.textMuted,
                ),
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: palette.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
