import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _eventsCountController;

  final List<_SocialAccount> _accounts = [
    _SocialAccount(icon: Icons.facebook, label: '10K ${AppStrings.followers}'),
    _SocialAccount(
      icon: Icons.camera_alt_outlined,
      label: '10K ${AppStrings.followers}',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: 'Lisa');
    _lastNameController = TextEditingController(text: 'Dancer');
    _eventsCountController = TextEditingController(text: '25');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _eventsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      AppStrings.editProfile,
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
                      // Profile picture
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 140.w,
                              height: 140.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.glassWhite48,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    AppAssets.professionalProfileJpg,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: () {
                                // TODO: open image picker
                              },
                              child: CustomText(
                                AppStrings.changeProfilePicture,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      // First Name
                      _buildTextField(
                        label: AppStrings.firstName,
                        controller: _firstNameController,
                      ),
                      SizedBox(height: 20.h),
                      // Last Name
                      _buildTextField(
                        label: AppStrings.lastName,
                        controller: _lastNameController,
                      ),
                      SizedBox(height: 20.h),
                      // Events Count
                      _buildTextField(
                        label: AppStrings.eventsCount,
                        controller: _eventsCountController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 32.h),
                      // Accounts Binded
                      CustomText(
                        AppStrings.accountsBinded,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Neue',
                        color: AppColors.foundationBlack20,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          ..._accounts.map((account) {
                            return Padding(
                              padding: EdgeInsets.only(right: 24.w),
                              child: _buildSocialItem(
                                icon: account.icon,
                                label: account.label,
                              ),
                            );
                          }),
                          _buildAddAccountItem(),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              // Save Button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: GestureDetector(
                  onTap: () {
                    // TODO: save profile changes
                    Navigator.of(context).maybePop();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 58.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.ctaGradient,
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      AppStrings.saveChanges,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.glassWhite48, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
            cursorColor: AppColors.accentCyan,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassWhite12,
            border: Border.all(color: AppColors.glassWhite48, width: 0.5),
          ),
          child: Icon(icon, color: AppColors.foundationBlack20, size: 24.sp),
        ),
        SizedBox(height: 6.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
        ),
      ],
    );
  }

  Widget _buildAddAccountItem() {
    return GestureDetector(
      onTap: () => context.push('/profile-add-account'),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassWhite12,
              border: Border.all(color: AppColors.glassWhite48, width: 0.5),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.foundationBlack20,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 6.h),
          CustomText(
            AppStrings.addAccount,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }
}

class _SocialAccount {
  final IconData icon;
  final String label;

  const _SocialAccount({required this.icon, required this.label});
}
