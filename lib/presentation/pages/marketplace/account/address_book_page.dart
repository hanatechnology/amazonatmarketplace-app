import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/address/address_card.dart';
import '../../../../core/components/marketplace/address/address_card_shimmer.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../controllers/addresses_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Saved delivery addresses.
///
/// `GET /addresses` is unpaginated and unfiltered, so the whole book arrives in
/// one call and the list needs no scroll loading.
class AddressBookPage extends GetView<AddressesController> {
  const AddressBookPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.loadAddresses,
          color: palette.brand,
          backgroundColor: palette.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _NavRow(),
                      const SizedBox(height: 6),
                      Text(
                        LocaleKeys.myAddresses.tr,
                        style: MarketplaceTypography.heroDisplay.copyWith(
                          fontSize: 28,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        LocaleKeys.addressesSubtitle.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.isLoading) {
                  return const SliverToBoxAdapter(child: _ListShimmer());
                }
                if (controller.addresses.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(onAdd: controller.navigateToAdd),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: _gutter),
                  sliver: SliverList.separated(
                    itemCount: controller.addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final address = controller.addresses[index];
                      return AddressCard(
                        address: address,
                        cityName: controller.cityNameFor(address.cityId),
                        isBusy: controller.deletingId.value == address.id,
                        onTap: controller.pickMode
                            ? () => controller.pickAddress(address)
                            : null,
                        onDelete: () => controller.confirmDelete(address),
                        onSetDefault: () => controller.setDefault(address),
                      );
                    },
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      )),
      bottomNavigationBar: Obx(
        () => controller.addresses.isEmpty && !controller.isLoading
            ? const SizedBox.shrink()
            : _AddBar(onAdd: controller.navigateToAdd),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: const BackButtonSlot(),
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AddressBookPage._gutter),
      child: Column(
        children: [
          AddressCardShimmer(),
          SizedBox(height: 12),
          AddressCardShimmer(),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 36,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.noAddresses.tr,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 24,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.noAddressesMessage.tr,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              height: 1.7,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.brand,
                foregroundColor: palette.onBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
              child: Text(
                LocaleKeys.addFirstAddress.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.onBrand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.brand,
                foregroundColor: palette.onBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 17, color: palette.onBrand),
                  const SizedBox(width: 7),
                  Text(
                    LocaleKeys.addAddress.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.onBrand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
