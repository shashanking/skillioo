import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/core/widgets/custom_text.dart';

/// Subscription required bottom sheet that shows when user tries to access premium features
/// without an active subscription
class SubscriptionRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onViewPlans;
  final VoidCallback? onMaybeLater;

  const SubscriptionRequiredDialog({
    super.key,
    this.title = 'Subscription required',
    this.message =
        'Calling is available exclusively for Pro and Elite members.\nUpgrade your subscription to start calling your followers.',
    required this.onViewPlans,
    this.onMaybeLater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, 40.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          CustomText(
            title,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          SizedBox(height: 16.h),

          // Message
          CustomText(
            message,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.5,
          ),
          SizedBox(height: 32.h),

          // Buttons
          Row(
            children: [
              // Maybe Later Button
              Expanded(
                child: _MaybeLaterButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    onMaybeLater?.call();
                  },
                ),
              ),
              SizedBox(width: 12.w),

              // View Plans Button
              Expanded(
                child: _ViewPlansButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    onViewPlans();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show the subscription required bottom sheet
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    required VoidCallback onViewPlans,
    VoidCallback? onMaybeLater,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      isScrollControlled: true,
      builder: (context) => SubscriptionRequiredDialog(
        title: title ?? 'Subscription required',
        message:
            message ??
            'Calling is available exclusively for Pro and Elite members.\nUpgrade your subscription to start calling your followers.',
        onViewPlans: onViewPlans,
        onMaybeLater: onMaybeLater,
      ),
    );
  }
}

/// Maybe Later button with light gray background
class _MaybeLaterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MaybeLaterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: CustomText(
          'Maybe Later',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}

/// View Plans button with gradient background
class _ViewPlansButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewPlansButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF2E5A7D), // Blue-ish
              Color(0xFF6B3D7A), // Purple-ish
            ],
          ),
        ),
        child: CustomText(
          'View Plans',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
