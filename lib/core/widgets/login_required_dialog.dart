import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import 'custom_text.dart';
import 'gradient_cta_button.dart';

/// Shows a dialog prompting anonymous users to log in to access a feature
void showLoginRequiredDialog(BuildContext context, {String? feature}) {
  showDialog(
    context: context,
    builder: (context) => LoginRequiredDialog(feature: feature),
  );
}

class LoginRequiredDialog extends StatelessWidget {
  final String? feature;

  const LoginRequiredDialog({super.key, this.feature});

  @override
  Widget build(BuildContext context) {
    final featureText = feature ?? 'this feature';
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.ctaGradient,
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.foundationBlack20,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Title
            CustomText(
              'Login Required',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Neue',
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            
            // Message
            CustomText(
              'Please create a profile or log in to access $featureText',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        'Cancel',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GradientCtaButton(
                    label: 'Create Profile',
                    height: 48,
                    borderRadius: BorderRadius.circular(24.r),
                    labelColor: AppColors.foundationBlack20,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/profile-type');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
