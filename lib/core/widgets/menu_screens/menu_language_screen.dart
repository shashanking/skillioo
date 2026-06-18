import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../localization/app_locale.dart';
import '../../localization/locale_extension.dart';
import '../../localization/locale_notifier.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../gradient_cta_button.dart';
import '../icon_button.dart';

class MenuLanguageScreen extends ConsumerStatefulWidget {
  const MenuLanguageScreen({super.key});

  @override
  ConsumerState<MenuLanguageScreen> createState() => _MenuLanguageScreenState();
}

class _MenuLanguageScreenState extends ConsumerState<MenuLanguageScreen> {
  @override
  Widget build(BuildContext context) {
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
                  // Header
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    decoration: BoxDecoration(color: AppColors.glassWhite20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        IconCircleButton(
                          assetPath: 'assets/images/arrow-left.png',
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        SizedBox(height: 24.h),
                        CustomText(
                          tr.selectYourLanguage,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Neue',
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
                    ),
                  ),
                  // Language list
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        children: List.generate(AppLocale.values.length, (
                          index,
                        ) {
                          final locale = AppLocale.values[index];
                          final isSelected = locale == currentLocale;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(localeNotifierProvider.notifier)
                                    .setLocale(locale);
                              },
                              child: Container(
                                width: double.infinity,
                                height: 68.h,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 10.h,
                                ),
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
                      ),
                    ),
                  ),
                ],
              ),
              // Continue button
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 24.h,
                child: GradientCtaButton(
                  label: tr.continueText,
                  onPressed: () => Navigator.of(context).maybePop(),
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(48.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
