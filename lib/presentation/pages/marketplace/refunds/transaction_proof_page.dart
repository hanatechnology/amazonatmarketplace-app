import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/feedback/snackbar.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/image_saver.dart';

/// Arguments for [TransactionProofPage].
class TransactionProofArgs {
  const TransactionProofArgs({required this.imageUrl});

  final String imageUrl;
}

/// Fullscreen view of the transfer receipt attached to a payout, with a save
/// action.
///
/// Same ground rules as the product gallery: dark surround, light chrome, in
/// both themes and both languages — a photographed bank slip reads against
/// dark whatever the app is doing around it. A route rather than a dialog so
/// the system back gesture closes it.
class TransactionProofPage extends StatefulWidget {
  const TransactionProofPage({super.key});

  @override
  State<TransactionProofPage> createState() => _TransactionProofPageState();
}

class _TransactionProofPageState extends State<TransactionProofPage> {
  static const Color _ground = Color(0xFF0B0F0D);
  static const Color _onGround = Color(0xFFF2F5F3);

  late final TransactionProofArgs _args;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final raw = Get.arguments;
    _args = raw is TransactionProofArgs
        ? raw
        : const TransactionProofArgs(imageUrl: '');
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final result = await ImageSaver.saveFromUrl(_args.imageUrl);
    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case SaveImageResult.saved:
        AppSnackbar.success(LocaleKeys.proofSaved.tr);
      case SaveImageResult.permissionDenied:
        AppSnackbar.error(LocaleKeys.photosPermissionDenied.tr);
      case SaveImageResult.failed:
        AppSnackbar.error(LocaleKeys.proofSaveFailed.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _args.imageUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: _ground,
      body: Stack(
        children: [
          if (!hasImage)
            Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: _onGround.withValues(alpha: 0.5),
              ),
            )
          else
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: AppNetworkImage(
                  imageUrl: _args.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // ── Chrome ──────────────────────────────────────
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + MarketplaceSpacing.sm,
            start: MarketplaceSpacing.md,
            child: _GlassCircle(
              icon: Icons.close_rounded,
              onTap: Get.back,
              semanticLabel: LocaleKeys.close.tr,
            ),
          ),
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + MarketplaceSpacing.sm + 9,
            start: MarketplaceSpacing.md + 50,
            end: MarketplaceSpacing.md,
            child: Text(
              LocaleKeys.transactionProof.tr,
              style: MarketplaceTypography.rowTitle.copyWith(color: _onGround),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasImage)
            PositionedDirectional(
              bottom:
                  MediaQuery.paddingOf(context).bottom + MarketplaceSpacing.lg,
              start: MarketplaceSpacing.lg,
              end: MarketplaceSpacing.lg,
              child: Center(child: _SaveButton(busy: _isSaving, onTap: _save)),
            ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.saveToPhotos.tr,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: busy
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _TransactionProofPageState._onGround,
                      )
                    : const Icon(
                        Icons.file_download_outlined,
                        size: 18,
                        color: _TransactionProofPageState._onGround,
                      ),
              ),
              const SizedBox(width: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.saveToPhotos.tr,
                style: MarketplaceTypography.rowTitle.copyWith(
                  color: _TransactionProofPageState._onGround,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.45),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _TransactionProofPageState._onGround,
          ),
        ),
      ),
    );
  }
}
