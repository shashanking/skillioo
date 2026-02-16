import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class MenuLanguageScreen extends StatefulWidget {
  const MenuLanguageScreen({super.key});

  @override
  State<MenuLanguageScreen> createState() => _MenuLanguageScreenState();
}

class _MenuLanguageScreenState extends State<MenuLanguageScreen> {
  final List<String> _languages = const [
    'English',
    'Hindi',
    'Marathi',
    'Kannada',
    'Telugu',
    'Malayalam',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                    decoration: BoxDecoration(color: AppColors.glassWhite12),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        IconCircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        SizedBox(height: 24.h),
                        CustomText(
                          AppStrings.selectYourLanguage,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Neue',
                          color: AppColors.foundationBlack20,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          AppStrings.languageSubtitle,
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
                        children: List.generate(_languages.length, (index) {
                          final isSelected = index == _selectedIndex;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
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
                                child: CustomText(
                                  _languages[index],
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foundationBlack20,
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
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: double.infinity,
                    height: 58.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.ctaGradient,
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      AppStrings.continueText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foundationBlack20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
