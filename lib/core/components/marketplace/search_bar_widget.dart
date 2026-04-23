import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_icons.dart';
import '../../localization/locale_keys.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onFilter,
    this.controller,
    this.hintText,
    this.debounceMs = 400,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback? onFilter;
  final TextEditingController? controller;
  final String? hintText;
  final int debounceMs;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Search field ────────────────────────────────
        Expanded(
          child: SizedBox(
            height: MarketplaceSpacing.searchBarHeight,
            child: TextField(
              controller: _controller,
              style: MarketplaceTypography.body,
              decoration: InputDecoration(
                hintText: widget.hintText ?? LocaleKeys.search.tr,
                hintStyle: MarketplaceTypography.inputPlaceholder,
                prefixIcon: const Icon(
                  MarketplaceIcons.search,
                  color: MarketplaceColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: MarketplaceColors.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(color: MarketplaceColors.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(color: MarketplaceColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(
                    color: MarketplaceColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: MarketplaceSpacing.md,
                ),
                filled: true,
                fillColor: MarketplaceColors.surface,
              ),
            ),
          ),
        ),

        // ── Filter button ────────────────────────────────
        if (widget.onFilter != null) ...[
          const SizedBox(width: MarketplaceSpacing.md),
          Semantics(
            label: 'Filter',
            button: true,
            child: GestureDetector(
              onTap: widget.onFilter,
              child: Container(
                width: MarketplaceSpacing.filterButtonSize,
                height: MarketplaceSpacing.filterButtonSize,
                decoration: BoxDecoration(
                  color: MarketplaceColors.surface,
                  border: Border.all(color: MarketplaceColors.stroke),
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                ),
                child: const Icon(
                  MarketplaceIcons.filter,
                  color: MarketplaceColors.textBody,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
