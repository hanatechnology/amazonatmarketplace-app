import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/components/marketplace/address/address_card.dart';
import 'package:marketplace/core/components/marketplace/address/address_card_shimmer.dart';
import 'package:marketplace/core/components/marketplace/address/address_empty_state.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/presentation/controllers/addresses_controller.dart';

class AddressBookPage extends GetView<AddressesController> {
  const AddressBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        backgroundColor: MarketplaceColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: MarketplaceColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.pickMode
              ? LocaleKeys.pickAddressTitle.tr
              : LocaleKeys.addressBook.tr,
          style: const TextStyle(
            color: MarketplaceColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _Body(controller: controller),
      floatingActionButton: Obx(() {
        if (controller.addresses.isEmpty && !controller.isLoading) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          onPressed: controller.navigateToAdd,
          backgroundColor: MarketplaceColors.primary,
          child: const Icon(Icons.add, color: MarketplaceColors.onPrimary),
        );
      }),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final AddressesController controller;

  @override
  Widget build(BuildContext context) {
    // if (controller.isLoading) {
    //   return const _LoadingView();
    // }
    // if (controller.isEmpty) {
    //   return AddressEmptyState(
    //     dto: AddressEmptyStateDto(onAddAddress: controller.navigateToAdd),
    //   );
    // }
    return _AddressList(controller: controller);
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      children: const [
        AddressCardShimmer(),
        SizedBox(height: MarketplaceSpacing.md),
        AddressCardShimmer(),
      ],
    );
  }
}

class _AddressList extends StatelessWidget {
  const _AddressList({required this.controller});

  final AddressesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading
          ? const _LoadingView()
          : controller.isEmpty
              ? AddressEmptyState(
                  dto: AddressEmptyStateDto(
                      onAddAddress: controller.navigateToAdd),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(MarketplaceSpacing.md),
                  itemCount: controller.addresses.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: MarketplaceSpacing.md),
                  itemBuilder: (_, index) {
                    final address = controller.addresses[index];
                    return _AddressItem(
                        address: address, controller: controller);
                  },
                ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({required this.address, required this.controller});

  final AddressEntity address;
  final AddressesController controller;

  @override
  Widget build(BuildContext context) {
    final cityName = controller.cityNameFor(address.cityId);
    final card = AddressCard(
      dto: AddressCardDto(
        id: address.id,
        label: address.label,
        fullName: address.fullName,
        phone: address.phone,
        addressLine1: address.addressLine1,
        addressLine2: address.addressLine2,
        cityName: cityName,
        state: address.state,
        isDefault: address.isDefault,
        isPickMode: controller.pickMode,
        onEdit: () => controller.navigateToEdit(address),
        onDelete: () => controller.confirmDelete(address),
        onSetDefault: () => controller.setDefault(address),
        onPick: () => controller.pickAddress(address),
      ),
    );
    return card;
  }
}
