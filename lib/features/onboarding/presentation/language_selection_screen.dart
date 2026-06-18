import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_cta_button.dart';
import '../../../constants/app_constants.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/localization/locale_extension.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final tr = ref.tr;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    decoration: BoxDecoration(color: AppColors.glassWhite06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBackButton(context),
                        SizedBox(height: 24.h),
                        _buildHeader(tr),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 24.h,
                      ),
                      child: _buildLanguageList(ref, currentLocale),
                    ),
                  ),
                ],
              ),
              _buildContinueButton(context, tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/options');
        }
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.glassWhite12,
          borderRadius: BorderRadius.circular(124.r),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/arrow-left.png',
            color: AppColors.foundationBlack20,
            width: 20.sp,
            height: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          tr.selectYourLanguage,
          fontFamily: 'Neue',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 4.h),
        CustomText(
          tr.languageSubtitle,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
        ),
      ],
    );
  }

  Widget _buildLanguageList(WidgetRef ref, AppLocale currentLocale) {
    return Column(
      children: List.generate(AppLocale.values.length, (index) {
        final locale = AppLocale.values[index];
        final isSelected = locale == currentLocale;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: GestureDetector(
            onTap: () {
              ref.read(localeNotifierProvider.notifier).setLocale(locale);
            },
            child: Container(
              width: double.infinity,
              height: 68.h,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.glassWhite48
                    : AppColors.glassWhite12,
                borderRadius: BorderRadius.circular(48.r),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      locale.displayName,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foundationBlack20,
                    ),
                  ),
                  CustomText(
                    locale.nativeName,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.foundationBlack20,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton(BuildContext context, tr) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GradientCtaButton(
          label: tr.continueText,
          width: double.infinity,
          height: 58,
          labelColor: AppColors.foundationBlack20,
          onPressed: () => context.push('/options'),
        ),
      ),
    );
  }
}
