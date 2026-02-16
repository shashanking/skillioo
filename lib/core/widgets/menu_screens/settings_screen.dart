import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                decoration: BoxDecoration(color: AppColors.glassWhite12),
                child: Row(
                  children: [
                    IconCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      AppStrings.settings,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Menu items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  children: [
                    _buildSettingsMenuItem(
                      assetIcon: AppAssets.dialSquarePng,
                      label: AppStrings.pinSetup,
                      isFirst: true,
                      onTap: () => context.push('/pin-setup'),
                    ),
                    _buildSettingsMenuItem(
                      icon: Icons.fingerprint,
                      label: AppStrings.biometrics,
                      onTap: () => context.push('/menu-biometrics'),
                    ),
                    _buildSettingsMenuItem(
                      icon: Icons.notifications_outlined,
                      label: AppStrings.notificationPreferences,
                      isLast: true,
                      onTap: () => _showNotificationPreferences(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsMenuItem({
    IconData? icon,
    String? assetIcon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.glassWhite06,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(24.r) : Radius.zero,
            bottom: isLast ? Radius.circular(24.r) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            if (assetIcon != null)
              Image.asset(
                assetIcon,
                width: 24.sp,
                height: 24.sp,
                color: AppColors.foundationBlack20,
              )
            else
              Icon(icon, color: AppColors.foundationBlack20, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _NotificationPreferencesSheet();
      },
    );
  }
}

class _NotificationPreferencesSheet extends StatefulWidget {
  @override
  State<_NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends State<_NotificationPreferencesSheet> {
  bool _likesCommentsFollow = true;
  bool _messagesCalls = true;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 54.h),
      decoration: BoxDecoration(
        color: AppColors.foundationBlack800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48.r),
          topRight: Radius.circular(48.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            AppStrings.notifications,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.likesCommentsFollow,
            _likesCommentsFollow,
            (val) => setState(() => _likesCommentsFollow = val),
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.messagesCalls,
            _messagesCalls,
            (val) => setState(() => _messagesCalls = val),
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.securityAlerts,
            _securityAlerts,
            (val) => setState(() => _securityAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.foundationBlack20, width: 2),
              color: value ? AppColors.foundationBlack20 : Colors.transparent,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 12.sp,
                    color: AppColors.foundationBlack800,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
