import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import 'common_background.dart';
import 'custom_text.dart';
import 'icon_button.dart';

class AppMenuScreen extends StatelessWidget {
  const AppMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and close button
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(color: AppColors.glassWhite12),
                child: Row(
                  children: [
                    Container(
                      width: 84.w,
                      height: 84.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: const DecorationImage(
                          image: AssetImage(AppAssets.logoPng),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconCircleButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      // Group 1: Home, About Us, Terms & Conditions
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.home_outlined,
                          label: AppStrings.home,
                          isFirst: true,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        _MenuItemData(
                          icon: Icons.people_outline,
                          label: AppStrings.aboutUs,
                          onTap: () => context.push('/menu-about'),
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          label: AppStrings.termsAndConditions,
                          isLast: true,
                          onTap: () => context.push('/menu-terms'),
                        ),
                      ]),

                      SizedBox(height: 24.h),

                      // Group 2: Settings, Help & Support, Favourites
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.settings_outlined,
                          label: AppStrings.settings,
                          isFirst: true,
                          onTap: () => context.push('/menu-settings'),
                        ),
                        _MenuItemData(
                          icon: Icons.help_outline,
                          label: AppStrings.helpAndSupport,
                          onTap: () => context.push('/menu-help'),
                        ),
                        _MenuItemData(
                          icon: Icons.bookmark_border,
                          label: AppStrings.favourites,
                          isLast: true,
                          onTap: () => context.push('/menu-favourites'),
                        ),
                      ]),

                      SizedBox(height: 24.h),

                      // Group 3: Language, Privacy, FAQs
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.school_outlined,
                          label: AppStrings.faqs,
                          isFirst: true,
                          onTap: () => context.push('/menu-faqs'),
                        ),
                        _MenuItemData(
                          icon: Icons.lock_outline,
                          label: AppStrings.privacyPolicy,
                          onTap: () => context.push('/menu-privacy'),
                        ),
                        _MenuItemData(
                          icon: Icons.translate,
                          label: AppStrings.languageSelection,
                          isLast: true,
                          onTap: () => context.push('/menu-language'),
                        ),
                      ]),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Delete Account Button at bottom
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.foundationBlack800,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48.r),
                    topRight: Radius.circular(48.r),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _showDeleteConfirmationBottomSheet(context),
                  child: Container(
                    width: double.infinity,
                    height: 58.h,
                    decoration: BoxDecoration(
                      color: AppColors.foundationErrorActive,
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      AppStrings.deleteAccount,
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

  // --- Helper Methods ---

  void _showDeleteConfirmationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                AppStrings.areYouSure,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
              SizedBox(height: 12.h),
              CustomText(
                AppStrings.deleteAccountWarning,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
                height: 1.5,
              ),
              SizedBox(height: 24.h),
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
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: AppColors.foundationErrorActive,
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          AppStrings.deleteAccount,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foundationBlack20,
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
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: AppColors.foundationBlack20,
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          AppStrings.cancel,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foundationBlack800,
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

  Widget _buildMenuGroup(List<_MenuItemData> items) {
    return Column(
      children: items.map((item) {
        return _buildMenuItem(item);
      }).toList(),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.glassWhite06,
          borderRadius: BorderRadius.vertical(
            top: item.isFirst ? Radius.circular(24.r) : Radius.zero,
            bottom: item.isLast ? Radius.circular(24.r) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.foundationBlack20, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                item.label,
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
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    this.isFirst = false,
    this.isLast = false,
    required this.onTap,
  });
}
