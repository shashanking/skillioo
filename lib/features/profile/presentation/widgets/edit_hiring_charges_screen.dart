import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';

enum _SaveState { idle, saving, success, error }

class EditHiringChargesScreen extends StatefulWidget {
  const EditHiringChargesScreen({super.key});

  @override
  State<EditHiringChargesScreen> createState() =>
      _EditHiringChargesScreenState();
}

class _EditHiringChargesScreenState extends State<EditHiringChargesScreen> {
  late final TextEditingController _hourlyController;
  late final TextEditingController _dailyController;
  late final TextEditingController _weeklyController;
  late final TextEditingController _monthlyController;

  late final FocusNode _hourlyFocus;
  late final FocusNode _dailyFocus;
  late final FocusNode _weeklyFocus;
  late final FocusNode _monthlyFocus;

  _SaveState _saveState = _SaveState.idle;
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _hourlyController = TextEditingController(text: '200');
    _dailyController = TextEditingController(text: '400');
    _weeklyController = TextEditingController(text: '1000');
    _monthlyController = TextEditingController(text: '15000');

    _hourlyFocus = FocusNode();
    _dailyFocus = FocusNode();
    _weeklyFocus = FocusNode();
    _monthlyFocus = FocusNode();

    _hourlyFocus.addListener(() => _onFocusChange(0));
    _dailyFocus.addListener(() => _onFocusChange(1));
    _weeklyFocus.addListener(() => _onFocusChange(2));
    _monthlyFocus.addListener(() => _onFocusChange(3));
  }

  void _onFocusChange(int index) {
    setState(() {
      if ([_hourlyFocus, _dailyFocus, _weeklyFocus, _monthlyFocus][index]
          .hasFocus) {
        _focusedIndex = index;
      } else if (_focusedIndex == index) {
        _focusedIndex = null;
      }
    });
  }

  @override
  void dispose() {
    _hourlyController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    _hourlyFocus.dispose();
    _dailyFocus.dispose();
    _weeklyFocus.dispose();
    _monthlyFocus.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_saveState == _SaveState.saving) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _saveState = _SaveState.saving);

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulate success (toggle to error to test error state)
    setState(() => _saveState = _SaveState.success);

    // Reset to idle after a delay
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
      case _SaveState.error:
        return AppStrings.somethingWentWrong;
    }
  }

  Color? get _buttonColor {
    switch (_saveState) {
      case _SaveState.idle:
      case _SaveState.saving:
        return null; // uses gradient
      case _SaveState.success:
        return AppColors.foundationGreenNormal;
      case _SaveState.error:
        return AppColors.foundationErrorActive;
    }
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
                      AppStrings.editHiringCharges,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Fields
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPricingField(
                        label: AppStrings.hourlyPricing,
                        controller: _hourlyController,
                        focusNode: _hourlyFocus,
                        index: 0,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: AppStrings.dailyPricing,
                        controller: _dailyController,
                        focusNode: _dailyFocus,
                        index: 1,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: AppStrings.weeklyPricing,
                        controller: _weeklyController,
                        focusNode: _weeklyFocus,
                        index: 2,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: AppStrings.monthlyPricing,
                        controller: _monthlyController,
                        focusNode: _monthlyFocus,
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Save Button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: GestureDetector(
                  onTap: _saveState == _SaveState.saving ? null : _onSave,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 58.h,
                    decoration: BoxDecoration(
                      gradient: _buttonColor == null
                          ? (_saveState == _SaveState.saving
                              ? AppColors.ctaGradientDeactivated
                              : AppColors.ctaGradient)
                          : null,
                      color: _buttonColor,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int index,
  }) {
    final isFocused = _focusedIndex == index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack80,
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isFocused
                  ? AppColors.accentCyan
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
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
}
