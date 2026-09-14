import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/refund_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Picks `reason_id` from `GET /dropdowns/refund-reasons`.
///
/// Optional in `CreateRefundDto` — the required explanation is the free-text
/// `reason` — so the sheet offers a "no particular reason" way out rather than
/// trapping the customer in a list that does not describe their problem.
class RefundReasonSheet extends StatelessWidget {
  const RefundReasonSheet({
    super.key,
    required this.reasons,
    this.selectedId,
  });

  final List<RefundReasonEntity> reasons;
  final String? selectedId;

  /// Returns the picked reason, `null` for "clear", and nothing when dismissed.
  static Future<RefundReasonEntity?> show({
    required List<RefundReasonEntity> reasons,
    String? selectedId,
  }) async {
    return Get.bottomSheet<RefundReasonEntity>(
      RefundReasonSheet(reasons: reasons, selectedId: selectedId),
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.refundReasonPick.tr,
                      style: MarketplaceTypography.heroDisplay.copyWith(
                        fontSize: 23,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                itemCount: reasons.length,
                itemBuilder: (_, index) {
                  final reason = reasons[index];
                  final isSelected = reason.id == selectedId;

                  return GestureDetector(
                    onTap: () => Get.back(result: reason),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.surfaceSunken
                            : palette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? palette.brand
                              : palette.hairline,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason.label,
                              style: MarketplaceTypography.rowTitle.copyWith(
                                fontSize: 12.5,
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: palette.brand,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
