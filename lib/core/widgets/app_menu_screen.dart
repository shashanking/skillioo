import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../core/services/session_prefs.dart';
import '../../core/services/session_state_provider.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/onboarding/application/onboarding_data_provider.dart';
import '../../features/profile/domain/profile_service.dart';
import '../localization/locale_extension.dart';
import 'common_background.dart';
import 'custom_text.dart';
import 'icon_button.dart';

class AppMenuScreen extends ConsumerStatefulWidget {
  const AppMenuScreen({super.key});

  @override
  ConsumerState<AppMenuScreen> createState() => _AppMenuScreenState();
}

class _AppMenuScreenState extends ConsumerState<AppMenuScreen> {
  bool _isAnonymous = true;

  @override
  void initState() {
    super.initState();
    _checkAnonymousStatus();
  }

  Future<void> _checkAnonymousStatus() async {
    final isAnon = await SessionPrefs.instance.isAnonymous();
    if (mounted) {
      setState(() => _isAnonymous = isAnon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
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
                          assetPath: 'assets/images/home-03.png',
                          label: tr.home,
                          isFirst: true,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        _MenuItemData(
                          assetPath: 'assets/images/user-group.png',
                          label: tr.aboutUs,
                          onTap: () => context.push('/menu-about'),
                        ),
                        _MenuItemData(
                          assetPath: 'assets/images/file-02.png',
                          label: tr.termsAndConditions,
                          isLast: true,
                          onTap: () => context.push('/menu-terms'),
                        ),
                      ]),

                      SizedBox(height: 24.h),

                      // Group 2: Settings, Help & Support, Favourites
                      _buildMenuGroup([
                        _MenuItemData(
                          assetPath: 'assets/images/setting-01.png',
                          label: tr.settings,
                          isFirst: true,
                          onTap: () => context.push('/menu-settings'),
                        ),
                        _MenuItemData(
                          assetPath: 'assets/images/help-circle.png',
                          label: tr.helpAndSupport,
                          isLast: true,
                          onTap: () => context.push('/menu-help'),
                        ),
                      ]),

                      SizedBox(height: 24.h),

                      // Group 3: FAQs, Privacy, Language
                      _buildMenuGroup([
                        _MenuItemData(
                          assetPath: 'assets/images/online-learning-03.png',
                          label: tr.faqs,
                          isFirst: true,
                          onTap: () => context.push('/menu-faqs'),
                        ),
                        _MenuItemData(
                          assetPath: 'assets/images/circle-lock-01.png',
                          label: tr.privacyPolicy,
                          onTap: () => context.push('/menu-privacy'),
                        ),
                        _MenuItemData(
                          assetPath: 'assets/images/online-learning-03.png',
                          label: tr.languageSelection,
                          isLast: true,
                          onTap: () => context.push('/menu-language'),
                        ),
                      ]),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Delete Account Button at bottom (hidden for anonymous users)
              if (!_isAnonymous)
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
                        tr.deleteAccount,
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
                AppStrings.areYouSure, // Static — bottom sheet has no ref
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
              SizedBox(height: 12.h),
              CustomText(
                AppStrings
                    .deleteAccountWarning, // Static — bottom sheet has no ref
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
                      onTap: () => _performDeleteAccount(context),
                      child: Container(
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: AppColors.foundationErrorActive,
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          AppStrings
                              .deleteAccount, // Static — bottom sheet has no ref
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
                          AppStrings.cancel, // Static — bottom sheet has no ref
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

  Future<void> _performDeleteAccount(BuildContext sheetContext) async {
    // Close the confirmation bottom sheet
    Navigator.pop(sheetContext);

    // Show a loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final profileId = await SessionPrefs.instance.getProfileId();

      if (token.isNotEmpty && profileId.isNotEmpty) {
        final service = ProfileService();
        await service.deleteProfile(
          profileId: profileId,
          accessToken: token,
        );
      }
    } catch (e) {
      debugPrint('Delete account API error: $e');
      // Continue with local cleanup even if API call fails
    }

    // Clear all local data
    await SessionPrefs.instance.clear();
    await ref.read(sessionStateProvider.notifier).refresh();
    if (!mounted) return;
    await ref.read(authNotifierProvider.notifier).reset();
    ref.read(onboardingDataProvider.notifier).state = const OnboardingData();

    // Dismiss loading indicator and navigate to welcome screen
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
    if (!mounted) return;
    context.go('/start');
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
            if (item.assetPath != null)
              Image.asset(
                item.assetPath!,
                width: 24.sp,
                height: 24.sp,
                color: AppColors.foundationBlack20,
              )
            else
              Icon(item.icon!, color: AppColors.foundationBlack20, size: 24.sp),
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
  final IconData? icon;
  final String? assetPath;
  final String label;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItemData({
    this.icon,
    this.assetPath,
    required this.label,
    this.isFirst = false,
    this.isLast = false,
    required this.onTap,
  }) : assert(icon != null || assetPath != null);
}
