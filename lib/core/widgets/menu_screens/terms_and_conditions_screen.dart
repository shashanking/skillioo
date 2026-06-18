import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../localization/locale_extension.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class TermsAndConditionsScreen extends ConsumerWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(color: AppColors.glassWhite12),
                child: Row(
                  children: [
                    IconCircleButton(
                      assetPath: 'assets/images/arrow-left.png',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      tr.termsAndConditions,
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
                        tr.accountAndPrivacy,
                        tr.accountAndPrivacyBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(tr.contentUpload, tr.contentUploadBody),
                      SizedBox(height: 24.h),
                      _buildSection(
                        tr.paymentsAndSubscriptions,
                        tr.paymentsAndSubscriptionsBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        tr.behaviorAndSafety,
                        tr.behaviorAndSafetyBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(
                        tr.rightsAndOwnership,
                        tr.rightsAndOwnershipBody,
                      ),
                      SizedBox(height: 24.h),
                      _buildSection(tr.modifications, tr.modificationsBody),
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
