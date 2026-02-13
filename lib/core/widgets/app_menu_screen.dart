import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/core/widgets/icon_button.dart';

import '../../../../core/widgets/custom_text.dart';

class AppMenuScreen extends StatelessWidget {
  const AppMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Deep Purple Top
              Color(0xFF121212), // Dark Middle
              Color(0xFF000000), // Black Bottom
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Logo Area
              Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  top: 20.h,
                  bottom: 30.h,
                  right: 24.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        image: const DecorationImage(
                          // Replace with your actual logo asset
                          image: AssetImage(AppAssets.logoPng),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconCircleButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      // Group 1
                      _buildMenuContainer([
                        _buildMenuItem(
                          Icons.home_outlined,
                          "Home",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          Icons.people_outline,
                          "About Us",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          Icons.description_outlined,
                          "Terms & Conditions",
                          isLast: true,
                          onTap: () {},
                        ),
                      ]),

                      SizedBox(height: 20.h),

                      // Group 2
                      _buildMenuContainer([
                        _buildMenuItem(
                          Icons.settings_outlined,
                          "Settings",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          Icons.help_outline,
                          "FAQs",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          Icons.bookmark_border,
                          "Favourites",
                          isLast: true,
                          onTap: () {},
                        ),
                      ]),

                      SizedBox(height: 20.h),

                      // Group 3
                      _buildMenuContainer([
                        _buildMenuItem(
                          Icons.translate,
                          "Language Selection",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          Icons.lock_outline,
                          "Privacy Policy",
                          isLast: true,
                          onTap: () {},
                        ),
                      ]),

                      SizedBox(height: 40.h),

                      // Delete Account Button (Triggers Bottom Sheet)
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmationBottomSheet(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD50000), // Bright Red
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                          alignment: Alignment.center,
                          child: CustomText(
                            "Delete Account",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
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

  // --- Helper Methods ---

  void _showDeleteConfirmationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Deep black background
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                "Are You Sure?",
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              CustomText(
                "All your profile data, videos, and documents will be permanently removed. This action cannot be undone.",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  // Delete Button (Red)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Implement actual delete logic
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828), // Darker Red
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          "Delete Account",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Cancel Button (White)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          "Cancel",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1E1E2C,
        ).withValues(alpha: 0.6), // Dark glassy background
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomText(
                title,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
