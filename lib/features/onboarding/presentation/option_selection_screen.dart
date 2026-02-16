import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';

class OptionSelectionScreen extends StatelessWidget {
  const OptionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.w,
                  child: Image.asset(AppAssets.logoPng, fit: BoxFit.contain),
                ),

                Text(
                  'Select Any One Option From Below',
                  style: TextStyle(
                    fontFamily: 'Neue',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32.h),
                _OptionCard(
                  title: 'Select App Language',
                  assetPath: AppAssets.selectLanguagePng,
                  onTap: () {
                    GoRouter.of(context).go('/language');
                  },
                ),
                SizedBox(height: 16.h),
                _OptionCard(
                  title: 'Create Profile',
                  assetPath: AppAssets.createProfilePng,
                  onTap: () {
                    GoRouter.of(context).go('/profile-type');
                  },
                ),
                SizedBox(height: 16.h),
                _OptionCard(
                  title: 'Proceed To Dashboard',
                  assetPath: AppAssets.proceedDashboardPng,
                  onTap: () {
                    GoRouter.of(context).go('/landing');
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String assetPath;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: AppColors.ctaGradient,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                width: 28.w,
                height: 28.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
