import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../dashboard/application/states/profile_list_state.dart';
import '../../application/current_profile_provider.dart';
import '../../application/hiring_rate_providers.dart';
import '../../application/states/hiring_rate_state.dart';

enum _SaveState { idle, saving, success, error }

class EditHiringChargesScreen extends ConsumerStatefulWidget {
  const EditHiringChargesScreen({super.key});

  @override
  ConsumerState<EditHiringChargesScreen> createState() =>
      _EditHiringChargesScreenState();
}

class _EditHiringChargesScreenState
    extends ConsumerState<EditHiringChargesScreen> {
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
  String _hiringRateId = '';
  bool _isLoading = true;
  ProfileItem? _currentProfile;

  @override
  void initState() {
    super.initState();
    _hourlyController = TextEditingController();
    _dailyController = TextEditingController();
    _weeklyController = TextEditingController();
    _monthlyController = TextEditingController();

    _hourlyFocus = FocusNode();
    _dailyFocus = FocusNode();
    _weeklyFocus = FocusNode();
    _monthlyFocus = FocusNode();

    _hourlyFocus.addListener(() => _onFocusChange(0));
    _dailyFocus.addListener(() => _onFocusChange(1));
    _weeklyFocus.addListener(() => _onFocusChange(2));
    _monthlyFocus.addListener(() => _onFocusChange(3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHiringRates();
    });
  }

  Future<void> _loadHiringRates() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null || profile.portfolioId.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    _currentProfile = profile;

    try {
      final hiringRatesAsync = ref.read(
        hiringRateProvider(profile.portfolioId),
      );

      hiringRatesAsync.when(
        data: (data) {
          if (!mounted) return;

          _hiringRateId = data['id']?.toString() ?? '';
          _hourlyController.text = (data['hourlyPricing'] ?? 0).toString();
          _dailyController.text = (data['dailyPricing'] ?? 0).toString();
          _weeklyController.text = (data['weeklyPricing'] ?? 0).toString();
          _monthlyController.text = (data['monthlyPricing'] ?? 0).toString();

          setState(() => _isLoading = false);
        },
        loading: () {
          // Keep loading
        },
        error: (e, _) {
          if (!mounted) return;
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onFocusChange(int index) {
    setState(() {
      if ([
        _hourlyFocus,
        _dailyFocus,
        _weeklyFocus,
        _monthlyFocus,
      ][index].hasFocus) {
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
    if (_saveState == _SaveState.saving || _hiringRateId.isEmpty) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _saveState = _SaveState.saving);

    try {
      final hourly = double.tryParse(_hourlyController.text) ?? 0.0;
      final daily = double.tryParse(_dailyController.text) ?? 0.0;
      final weekly = double.tryParse(_weeklyController.text) ?? 0.0;
      final monthly = double.tryParse(_monthlyController.text) ?? 0.0;

      await ref
          .read(hiringRateNotifierProvider.notifier)
          .updateHiringRate(
            id: _hiringRateId,
            hourlyPricing: hourly,
            dailyPricing: daily,
            weeklyPricing: weekly,
            monthlyPricing: monthly,
          );

      if (!mounted) return;

      final state = ref.read(hiringRateNotifierProvider);
      if (state.status == HiringRateStatus.success) {
        setState(() => _saveState = _SaveState.success);

        // Invalidate the hiring rate provider to refresh data
        final portfolioId = _currentProfile?.portfolioId ?? '';
        if (portfolioId.isNotEmpty) {
          ref.invalidate(hiringRateProvider(portfolioId));
        }

        // Reset to idle and pop after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        setState(() => _saveState = _SaveState.error);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _saveState = _SaveState.idle);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveState = _SaveState.error);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _saveState = _SaveState.idle);
        }
      });
    }
  }

  String _buttonLabel() {
    final tr = ref.tr;
    switch (_saveState) {
      case _SaveState.idle:
        return tr.saveChanges;
      case _SaveState.saving:
        return tr.saving;
      case _SaveState.success:
        return tr.changesSaved;
      case _SaveState.error:
        return tr.somethingWentWrong;
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
    final tr = ref.tr;

    if (_isLoading) {
      return Scaffold(
        body: CommonBackground(
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

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
                      assetPath: 'assets/images/arrow-left.png',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      tr.editHiringCharges,
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
                        label: tr.hourlyPricing,
                        controller: _hourlyController,
                        focusNode: _hourlyFocus,
                        index: 0,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: tr.dailyPricing,
                        controller: _dailyController,
                        focusNode: _dailyFocus,
                        index: 1,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: tr.weeklyPricing,
                        controller: _weeklyController,
                        focusNode: _weeklyFocus,
                        index: 2,
                      ),
                      SizedBox(height: 20.h),
                      _buildPricingField(
                        label: tr.monthlyPricing,
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
                child: SizedBox(
                  width: double.infinity,
                  height: 58.h,
                  child: Stack(
                    children: [
                      // Border gradient
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: _buttonColor != null
                                ? null
                                : (_saveState == _SaveState.saving
                                      ? AppColors.ctaGradientDeactivated
                                      : AppColors.ctaBorderGradient),
                            color: _buttonColor,
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                        ),
                      ),
                      // Black inset
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(1.2.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              (48.r - 1.2.w).clamp(0.0, double.infinity),
                            ),
                            child: Container(color: Colors.black),
                          ),
                        ),
                      ),
                      // Content
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _saveState == _SaveState.saving
                              ? null
                              : _onSave,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              gradient: _buttonColor == null
                                  ? (_saveState == _SaveState.saving
                                        ? AppColors.ctaGradientDeactivated
                                        : AppColors.ctaGradient)
                                  : null,
                              color: _buttonColor,
                              borderRadius: BorderRadius.circular(
                                (48.r - 2.6.w).clamp(0.0, double.infinity),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: CustomText(
                              _buttonLabel(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontFamily: 'Outfit',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Color(0xFFF5F5F5),
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(24.r),
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
