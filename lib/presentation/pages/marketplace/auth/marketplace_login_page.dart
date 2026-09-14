import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/marketplace/auth_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Phone entry — the only way into the app.
///
/// `POST /auth/request-otp` is public and doubles as sign-in, sign-up trigger
/// and resend. An unknown number comes back needing a name and email, which is
/// why the note under the field warns about it before the customer hits it.
///
/// The language control is not decoration: the backend picks the Arabic or
/// English SMS template from `Accept-Language`, and on a first signup there is
/// no account row yet to read a preference from.
class MarketplaceLoginPage extends GetView<AuthController> {
  const MarketplaceLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackButton(),
              const SizedBox(height: 14),
              Text(
                LocaleKeys.loginTitle.tr,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 30,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.loginSubtitle.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                LocaleKeys.phoneNumber.tr.toUpperCase(),
                style: MarketplaceTypography.labelCaps.copyWith(
                  color: palette.textMuted,
                  letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const PhoneField(),
              const SizedBox(height: 18),
              const _SmsLanguageToggle(),
              const SizedBox(height: 18),
              _FirstTimeNote(),
              const SizedBox(height: 22),
              const _NextSteps(),
              const SizedBox(height: 26),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.brand,
                      foregroundColor: palette.onBrand,
                      disabledBackgroundColor: palette.surfaceSunken,
                      disabledForegroundColor: palette.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                      ),
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onBrand,
                            ),
                          )
                        : Text(
                            LocaleKeys.sendOtp.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {

    if (!Navigator.of(context).canPop()) return const SizedBox(height: 44);

    return SizedBox(
      height: 44,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: const BackButtonSlot(),
      ),
    );
  }
}

/// `🇱🇾 +218 │ 91 234 5678` — one left-to-right run in both languages. The
/// country code stays ahead of the subscriber number in Arabic too; a phone
/// number is not a sentence and mirroring it is a bug.
class PhoneField extends GetView<AuthController> {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final error = controller.phoneError.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: error != null
                      ? StatusTone.danger.foreground(palette.isDark)
                      : palette.hairline,
                  width: error != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🇱🇾',
                    style: MarketplaceTypography.rowTitle
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    PhoneUtils.countryCode,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 22, color: palette.hairline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.phoneController,
                      focusNode: controller.phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSubmitted: (_) => controller.sendOtp(),
                      cursorColor: palette.brand,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: palette.textPrimary,
                      ),
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
                        hintText: '91 234 5678',
                        hintStyle: MarketplaceTypography.rowTitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Which language the SMS arrives in. It switches the app locale, which is what
/// `Accept-Language` is taken from on the next request.
class _SmsLanguageToggle extends StatelessWidget {
  const _SmsLanguageToggle();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final locale = Get.find<LocaleController>();

    return Row(
      children: [
        Icon(Icons.language_rounded, size: 15, color: palette.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            LocaleKeys.smsLanguage.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(MarketplaceRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguagePill(
                  label: 'العربية',
                  isSelected: locale.isArabic,
                  onTap: locale.switchToArabic,
                ),
                _LanguagePill(
                  label: 'English',
                  isSelected: locale.isEnglish,
                  onTap: locale.switchToEnglish,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? palette.brand : const Color(0x00000000),
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.pillLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? palette.onBrand : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Warns about the registration branch before the customer walks into it.
class _FirstTimeNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: palette.textMuted,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              LocaleKeys.firstTimeNote.tr,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 10.5,
                height: 1.65,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  const _NextSteps();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Step(index: 1, labelKey: LocaleKeys.stepEnterPhone),
        SizedBox(height: 10),
        _Step(index: 2, labelKey: LocaleKeys.stepEnterCode),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.labelKey});

  final int index;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.surfaceSunken,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.labelCaps.copyWith(
              fontSize: 10,
              color: palette.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            labelKey.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              color: palette.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
