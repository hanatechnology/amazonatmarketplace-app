import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/account/delete_account_sheet.dart';
import '../../../../core/components/marketplace/appearance_sheet.dart';
import '../../../../core/legal/legal_document.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/components/marketplace/auth/sign_in_required_view.dart';
import '../../../../data/services/session_service.dart';
import '../../../controllers/marketplace/profile_controller.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// The account tab.
///
/// Read-only by necessity: there is no profile endpoint in the contract — no
/// `GET /customers/me`, no `PATCH` — so the only customer data that exists is
/// the object `POST /auth/verify-otp` returned at login. That rules out an
/// edit-profile form, and it rules out a "member since" row: nothing in the
/// payload carries a signup date.
///
/// The avatar is initials only. `POST /uploads/avatar` exists but hands back a
/// `tempId` "to pass when updating the customer profile", and no such endpoint
/// is in the spec — so there is nowhere to send an uploaded image.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // A guest has no customer record to show — there is no `GET /me` to fall
    // back on, and all three counters are bearer-only calls — so the tab
    // becomes an invitation plus the preferences that work without a session.
    // [ProfileController] is never resolved on that path, which is what keeps
    // its three startup calls from firing as guaranteed 401s.
    return Obx(
      () => SessionService.to.isSignedIn
          ? const _SignedInAccount()
          : const _GuestAccount(),
    );
  }
}

/// The account tab proper, once there is a customer behind it.
class _SignedInAccount extends StatelessWidget {
  const _SignedInAccount();

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: palette.brand,
          backgroundColor: palette.surface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 100),
            children: [
              const _Identity(),
              const SizedBox(height: 18),
              const _StatStrip(),
              const SizedBox(height: 22),
              _SectionLabel(text: LocaleKeys.sectionShopping.tr),
              _MenuRow(
                icon: Icons.shopping_bag_outlined,
                label: LocaleKeys.myOrders.tr,
                onTap: controller.goToOrders,
              ),
              _MenuRow(
                icon: Icons.location_on_outlined,
                label: LocaleKeys.myAddresses.tr,
                onTap: controller.goToAddresses,
              ),
              Obx(
                () => _MenuRow(
                  icon: Icons.notifications_none_rounded,
                  label: LocaleKeys.notifications.tr,
                  badgeCount: controller.unreadCount.value,
                  onTap: controller.goToNotifications,
                ),
              ),
              const SizedBox(height: 18),
              _SectionLabel(text: LocaleKeys.sectionPreferences.tr),
              Obx(
                () => _MenuRow(
                  icon: Icons.language_rounded,
                  label: LocaleKeys.language.tr,
                  trailingValue: Get.find<LocaleController>().isArabic
                      ? 'العربية'
                      : 'English',
                  onTap: controller.toggleLanguage,
                ),
              ),
              _MenuRow(
                icon: Icons.brightness_6_outlined,
                label: LocaleKeys.appearance.tr,
                onTap: () => showAppearanceSheet(context),
              ),
              const SizedBox(height: 18),
              _SectionLabel(text: LocaleKeys.sectionAccount.tr),
              _MenuRow(
                icon: Icons.help_outline_rounded,
                label: LocaleKeys.helpCenter.tr,
                onTap: controller.goToHelp,
              ),
              _MenuRow(
                icon: Icons.shield_outlined,
                label: LocaleKeys.privacyPolicy.tr,
                onTap: controller.goToPrivacyPolicy,
              ),
              _MenuRow(
                icon: Icons.description_outlined,
                label: LocaleKeys.termsOfService.tr,
                onTap: controller.goToTerms,
              ),
              _MenuRow(
                icon: Icons.logout_rounded,
                label: LocaleKeys.logout.tr,
                isDanger: true,
                showChevron: false,
                onTap: controller.logout,
              ),
              // Deliberately last and on its own: erasing the account is not a
              // sibling of the settings above it, and both stores require it to
              // be reachable from inside the app.
              Obx(
                () => _MenuRow(
                  icon: Icons.delete_outline_rounded,
                  label: LocaleKeys.deleteAccount.tr,
                  isDanger: true,
                  showChevron: false,
                  isBusy: controller.isDeletingAccount.value,
                  onTap: () async {
                    if (controller.isDeletingAccount.value) return;
                    final confirmed = await showDeleteAccountSheet(context);
                    if (confirmed) await controller.deleteAccount();
                  },
                ),
              ),
              const SizedBox(height: 24),
              const _VersionFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the account tab is for a guest: the reason to sign in, then the
/// settings that need no account at all. Deliberately not a bare wall — the
/// language and appearance switches are the two things customers look for here
/// before they have an account, and both are local.
class _GuestAccount extends StatelessWidget {
  const _GuestAccount();

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 100),
          children: [
            const SizedBox(height: 12),
            const SignInRequiredView(
              titleKey: LocaleKeys.guestAccountTitle,
              bodyKey: LocaleKeys.guestAccountSubtitle,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 26),
            _SectionLabel(text: LocaleKeys.sectionPreferences.tr),
            Obx(
              () => _MenuRow(
                icon: Icons.language_rounded,
                label: LocaleKeys.language.tr,
                trailingValue: Get.find<LocaleController>().isArabic
                    ? 'العربية'
                    : 'English',
                onTap: Get.find<LocaleController>().toggleLocale,
              ),
            ),
            _MenuRow(
              icon: Icons.brightness_6_outlined,
              label: LocaleKeys.appearance.tr,
              onTap: () => showAppearanceSheet(context),
            ),
            const SizedBox(height: 18),
            _SectionLabel(text: LocaleKeys.sectionAccount.tr),
            _MenuRow(
              icon: Icons.help_outline_rounded,
              label: LocaleKeys.helpCenter.tr,
              onTap: () => AppRouter.toNamed<void>(Routes.MARKETPLACE_HELP),
            ),
            _MenuRow(
              icon: Icons.shield_outlined,
              label: LocaleKeys.privacyPolicy.tr,
              onTap: () => AppRouter.toNamed<void>(
                Routes.MARKETPLACE_LEGAL,
                arguments: LegalDocumentKind.privacyPolicy,
              ),
            ),
            _MenuRow(
              icon: Icons.description_outlined,
              label: LocaleKeys.termsOfService.tr,
              onTap: () => AppRouter.toNamed<void>(
                Routes.MARKETPLACE_LEGAL,
                arguments: LegalDocumentKind.termsOfService,
              ),
            ),
            const SizedBox(height: 24),
            const _VersionFooter(),
          ],
        ),
      ),
    );
  }
}

/// Build identifier at the foot of the account list, so a tester reporting a
/// bug can say which build they are on. Renders nothing if the platform read
/// in `main()` failed.
class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    final label = AppConfig.versionLabel;
    if (label.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final style = MarketplaceTypography.micro.copyWith(
      color: palette.textMuted,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(LocaleKeys.appVersion.tr, style: style),
        const SizedBox(width: 6),
        // Version numbers stay Latin-digit and LTR inside Arabic, otherwise the
        // bidi algorithm reorders the dotted number and the parenthesised build.
        Text(label, style: style, textDirection: TextDirection.ltr),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final palette = context.palette;

    return Obx(() {
      final name = controller.displayName;
      final email = controller.email;

      return Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              controller.initial,
              style: MarketplaceTypography.heroDisplay.copyWith(
                fontSize: 26,
                color: palette.brand,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.isEmpty ? LocaleKeys.appName.tr : name,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 24,
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  controller.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11.5,
                    color: palette.textSecondary,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// Three counters, each one a real call. A counter that has not landed shows a
/// dash — a zero would read as a fact.
class _StatStrip extends StatelessWidget {
  const _StatStrip();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.hairline),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _Stat(
                value: controller.orderCount.value,
                label: LocaleKeys.statOrders.tr,
              ),
            ),
            _Divider(color: palette.hairline),
            Expanded(
              child: _Stat(
                value: controller.addressCount.value,
                label: LocaleKeys.statAddresses.tr,
              ),
            ),
            _Divider(color: palette.hairline),
            Expanded(
              child: _Stat(
                value: controller.unreadCount.value,
                label: LocaleKeys.statUnread.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: color);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value?.toString() ?? '—',
          textDirection: TextDirection.ltr,
          style: MarketplaceTypography.heroDisplay.copyWith(
            fontSize: 22,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: MarketplaceTypography.rowMeta.copyWith(
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
      child: Text(
        text.toUpperCase(),
        style: MarketplaceTypography.labelCaps.copyWith(
          color: palette.textMuted,
          letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.3,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingValue,
    this.badgeCount,
    this.isDanger = false,
    this.showChevron = true,
    this.isBusy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingValue;
  final int? badgeCount;
  final bool isDanger;
  final bool showChevron;

  /// Swaps the chevron for a spinner and swallows taps while a row's action is
  /// still running.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final tint =
        isDanger ? StatusTone.danger.foreground(isDark) : palette.textSecondary;

    return GestureDetector(
      onTap: isBusy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDanger
                    ? StatusTone.danger.background(isDark)
                    : palette.surfaceSunken,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 16, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 12.5,
                  color: isDanger
                      ? StatusTone.danger.foreground(isDark)
                      : palette.textPrimary,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
                child: Text(
                  '$badgeCount',
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 9.5,
                    color: palette.onAccent,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailingValue != null) ...[
              Text(
                trailingValue!,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isBusy)
              SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 1.8, color: tint),
              )
            else if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: palette.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
