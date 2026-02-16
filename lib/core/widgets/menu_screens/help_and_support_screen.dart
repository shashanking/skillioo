import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite12,
                ),
                child: Row(
                  children: [
                    IconCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      AppStrings.helpAndSupport,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        AppStrings.accountHelp,
                        AppStrings.accountHelpBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        AppStrings.profileAndUploads,
                        AppStrings.profileAndUploadsBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        AppStrings.hiringOrPickTalent,
                        AppStrings.hiringOrPickTalentBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        AppStrings.payments,
                        AppStrings.paymentsBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        AppStrings.contactSupport,
                        AppStrings.contactSupportBody,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 12.h),
        CustomText(
          body,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
          height: 1.5,
        ),
      ],
    );
  }
}
