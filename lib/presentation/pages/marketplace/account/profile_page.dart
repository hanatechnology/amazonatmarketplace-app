import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/marketplace/menu_list_item.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_icons.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../controllers/marketplace/profile_controller.dart';

/// Account tab — identity summary plus the account menu.
///
/// The web client shows a read-only info card and links to addresses/orders;
/// mobile folds those links into a native menu list and adds language and
/// logout, which the web keeps in its global header.
class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.refreshProfile(),
          color: MarketplaceColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: MarketplaceSpacing.xl),
            children: [
              const _ProfileHeader(),
              const SizedBox(height: MarketplaceSpacing.md),
              const _PersonalInfo(),
              const SizedBox(height: MarketplaceSpacing.md),
              MenuListItem(
                icon: MarketplaceIcons.myOrder,
                label: LocaleKeys.myOrders.tr,
                onTap: controller.goToOrders,
              ),
              MenuListItem(
                icon: MarketplaceIcons.location,
                label: LocaleKeys.addressBook.tr,
                onTap: controller.goToAddresses,
              ),
              MenuListItem(
                icon: Icons.notifications_none_rounded,
                label: LocaleKeys.notifications.tr,
                onTap: controller.goToNotifications,
              ),
              MenuListItem(
                icon: MarketplaceIcons.language,
                label: LocaleKeys.language.tr,
                onTap: controller.toggleLanguage,
              ),
              MenuListItem(
                icon: MarketplaceIcons.helpCenter,
                label: LocaleKeys.helpCenter.tr,
                onTap: controller.goToHelp,
              ),
              MenuListItem(
                icon: MarketplaceIcons.logout,
                label: LocaleKeys.logout.tr,
                showDivider: false,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: MarketplaceColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.lg),
        ),
        title: Text(
          LocaleKeys.logout.tr,
          style: MarketplaceTypography.sectionHeading,
        ),
        content: Text(
          LocaleKeys.logoutConfirm.tr,
          style: MarketplaceTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              LocaleKeys.cancel.tr,
              style: MarketplaceTypography.buttonLabel.copyWith(
                color: MarketplaceColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text(
              LocaleKeys.logout.tr,
              style: MarketplaceTypography.buttonLabel.copyWith(
                color: MarketplaceColors.errorContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends GetView<ProfileController> {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Touch the observable so the header rebuilds after logout / re-login.
      controller.user.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: MarketplaceSpacing.avatarSmall,
              height: MarketplaceSpacing.avatarSmall,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: MarketplaceColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                controller.initial,
                style: MarketplaceTypography.sectionHeading.copyWith(
                  color: MarketplaceColors.primary,
                ),
              ),
            ),
            const SizedBox(width: MarketplaceSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.displayName.isEmpty
                        ? LocaleKeys.myAccount.tr
                        : controller.displayName,
                    style: MarketplaceTypography.sectionHeading,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (controller.phone.isNotEmpty)
                    Text(
                      controller.phone,
                      style: MarketplaceTypography.descriptionBody,
                      textDirection: TextDirection.ltr,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PersonalInfo extends GetView<ProfileController> {
  const _PersonalInfo();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      if (user == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
        ),
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(color: MarketplaceColors.strokeLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: LocaleKeys.phoneNumber.tr,
              value: controller.phone,
              ltr: true,
            ),
            if (controller.email.isNotEmpty)
              _InfoRow(
                label: LocaleKeys.email.tr,
                value: controller.email,
                ltr: true,
              ),
            _InfoRow(
              label: LocaleKeys.language.tr,
              value: Get.find<LocaleController>().isArabic
                  ? LocaleKeys.arabic.tr
                  : LocaleKeys.english.tr,
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarketplaceSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: MarketplaceTypography.descriptionBody),
          ),
          Text(
            value,
            style: MarketplaceTypography.bodyBold,
            textDirection: ltr ? TextDirection.ltr : null,
          ),
        ],
      ),
    );
  }
}
