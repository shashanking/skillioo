import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';

enum _SaveState { idle, saving, success }

class ProfilePrivacyScreen extends StatefulWidget {
  const ProfilePrivacyScreen({super.key});

  @override
  State<ProfilePrivacyScreen> createState() => _ProfilePrivacyScreenState();
}

class _ProfilePrivacyScreenState extends State<ProfilePrivacyScreen> {
  final List<String> _options = [
    AppStrings.publicOption,
    AppStrings.friendsOption,
    AppStrings.privateOption,
  ];

  int? _selected;
  _SaveState _saveState = _SaveState.idle;

  bool get _hasChanges => _selected != null;

  Future<void> _onSave() async {
    if (_saveState == _SaveState.saving || !_hasChanges) return;

    setState(() => _saveState = _SaveState.saving);

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _saveState = _SaveState.success);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _saveState = _SaveState.idle);
      }
    });
  }

  String get _buttonLabel {
    switch (_saveState) {
      case _SaveState.idle:
        return AppStrings.saveChanges;
      case _SaveState.saving:
        return AppStrings.saving;
      case _SaveState.success:
        return AppStrings.changesSaved;
    }
  }

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
                      AppStrings.privacy,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Options
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    children: [
                      ...List.generate(_options.length, (index) {
                        final isSelected = _selected == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = isSelected ? null : index;
                              _saveState = _SaveState.idle;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  _options[index],
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.foundationBlack20,
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.accentCyan
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentCyan
                                          : AppColors.foundationBlack80,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      // Save button (only visible when changes made)
                      if (_hasChanges)
                        GestureDetector(
                          onTap: _onSave,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 58.h,
                            decoration: BoxDecoration(
                              gradient: _saveState == _SaveState.success
                                  ? null
                                  : (_saveState == _SaveState.saving
                                        ? AppColors.ctaGradientDeactivated
                                        : AppColors.ctaGradient),
                              color: _saveState == _SaveState.success
                                  ? AppColors.foundationGreenNormal
                                  : null,
                              borderRadius: BorderRadius.circular(48.r),
                            ),
                            alignment: Alignment.center,
                            child: CustomText(
                              _buttonLabel,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foundationBlack20,
                            ),
                          ),
                        ),
                      SizedBox(height: 24.h),
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
}
