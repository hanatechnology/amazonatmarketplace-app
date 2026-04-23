import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class CompleteDetailsPage extends GetView<AuthController> {
  const CompleteDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
    // return Scaffold(
    //   backgroundColor: MarketplaceColors.surface,
    //   appBar: MarketplaceAppBar(title: ''),
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       padding: const EdgeInsets.symmetric(
    //         horizontal: MarketplaceSpacing.screenPaddingH,
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.stretch,
    //         children: [
    //           const SizedBox(height: MarketplaceSpacing.lg),

    //           Text(
    //             LocaleKeys.completeDetailsTitle.tr,
    //             style: MarketplaceTypography.sectionHeading,
    //           ),
    //           const SizedBox(height: MarketplaceSpacing.sm),
    //           Text(
    //             LocaleKeys.completeDetailsSubtitle.tr,
    //             style: MarketplaceTypography.descriptionBody,
    //           ),

    //           const SizedBox(height: MarketplaceSpacing.xl),

    //           // ── Full Name ───────────────────────────────
    //           Text(LocaleKeys.fullName.tr,
    //               style: MarketplaceTypography.cardTitle),
    //           const SizedBox(height: MarketplaceSpacing.sm),
    //           Obx(() => TextField(
    //                 controller: controller.nameController,
    //                 style: MarketplaceTypography.body,
    //                 decoration: InputDecoration(
    //                   hintText: LocaleKeys.fullNameHint.tr,
    //                   errorText: controller.nameError.value,
    //                 ),
    //                 onChanged: (_) => controller.nameError.value = null,
    //               )),

    //           const SizedBox(height: MarketplaceSpacing.lg),

    //           // ── Email ───────────────────────────────────
    //           Text(LocaleKeys.email.tr, style: MarketplaceTypography.cardTitle),
    //           const SizedBox(height: MarketplaceSpacing.sm),
    //           Obx(() => TextField(
    //                 controller: controller.emailController,
    //                 keyboardType: TextInputType.emailAddress,
    //                 style: MarketplaceTypography.body,
    //                 decoration: InputDecoration(
    //                   hintText: LocaleKeys.emailHint.tr,
    //                   errorText: controller.emailError.value,
    //                 ),
    //                 onChanged: (_) => controller.emailError.value = null,
    //               )),

    //           const SizedBox(height: MarketplaceSpacing.xl),

    //           // ── Create Account Button ───────────────────
    //           Obx(() => ElevatedButton(
    //                 onPressed: controller.isLoading.value
    //                     ? null
    //                     : controller.continueWithApple,
    //                 style: ElevatedButton.styleFrom(
    //                   minimumSize: const Size(
    //                       double.infinity, MarketplaceSpacing.buttonHeight),
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius:
    //                         BorderRadius.circular(MarketplaceRadius.button),
    //                   ),
    //                 ),
    //                 child: controller.isLoading.value
    //                     ? const SizedBox(
    //                         width: 20,
    //                         height: 20,
    //                         child: CircularProgressIndicator(
    //                           strokeWidth: 2,
    //                           color: MarketplaceColors.onPrimary,
    //                         ),
    //                       )
    //                     : Text(
    //                         LocaleKeys.createAccount.tr,
    //                         style: MarketplaceTypography.buttonLabel,
    //                       ),
    //               )),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
