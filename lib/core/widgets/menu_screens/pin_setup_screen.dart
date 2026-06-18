import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../localization/locale_extension.dart';
import '../../services/session_prefs.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../gradient_cta_button.dart';
import '../icon_button.dart';

/// Pin Setup flow: New Pin → Confirm Pin
/// Each step has states: empty, filled, error, success
enum _PinStep { newPin, confirmPin }

enum _PinFieldState { empty, filled, error, success }

class MenuPinSetupScreen extends ConsumerStatefulWidget {
  const MenuPinSetupScreen({super.key});

  @override
  ConsumerState<MenuPinSetupScreen> createState() => _MenuPinSetupScreenState();
}

class _MenuPinSetupScreenState extends ConsumerState<MenuPinSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPinBottomSheet();
    });
  }

  void _showPinBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return const _PinFlowSheet();
      },
    ).then((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header (same as Settings)
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
                      tr.settings,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Settings menu items (visual backdrop)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      assetIcon: AppAssets.dialSquarePng,
                      label: tr.pinSetup,
                      isFirst: true,
                    ),
                    _buildSettingsItem(
                      icon: Icons.fingerprint,
                      label: tr.biometrics,
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      label: tr.notificationPreferences,
                      isLast: true,
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

  Widget _buildSettingsItem({
    IconData? icon,
    String? assetIcon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
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
    );
  }
}

class _PinFlowSheet extends ConsumerStatefulWidget {
  const _PinFlowSheet();

  @override
  ConsumerState<_PinFlowSheet> createState() => _PinFlowSheetState();
}

class _PinFlowSheetState extends ConsumerState<_PinFlowSheet> {
  _PinStep _currentStep = _PinStep.newPin;
  _PinFieldState _fieldState = _PinFieldState.empty;

  final List<String> _newPinDigits = ['', '', '', ''];
  final List<String> _confirmPinDigits = ['', '', '', ''];

  int _activeIndex = 0;
  bool _isVerifying = false;
  String? _errorMessage;

  List<String> get _currentDigits {
    switch (_currentStep) {
      case _PinStep.newPin:
        return _newPinDigits;
      case _PinStep.confirmPin:
        return _confirmPinDigits;
    }
  }

  String get _title {
    if (_fieldState == _PinFieldState.error) {
      switch (_currentStep) {
        case _PinStep.newPin:
          return AppStrings.enterNewPin;
        case _PinStep.confirmPin:
          return _errorMessage ?? AppStrings.pinMismatch;
      }
    }
    switch (_currentStep) {
      case _PinStep.newPin:
        return AppStrings.enterNewPin;
      case _PinStep.confirmPin:
        return AppStrings.enterNewPinAgain;
    }
  }

  String get _subtitle {
    if (_fieldState == _PinFieldState.error) {
      switch (_currentStep) {
        case _PinStep.newPin:
          return AppStrings.enterNewPinBody;
        case _PinStep.confirmPin:
          return _errorMessage != null
              ? 'Something went wrong. Please try again.'
              : AppStrings.pinMismatchBody;
      }
    }
    switch (_currentStep) {
      case _PinStep.newPin:
        return AppStrings.enterNewPinBody;
      case _PinStep.confirmPin:
        return AppStrings.enterNewPinAgainBody;
    }
  }

  String get _buttonLabel {
    if (_isVerifying) return AppStrings.verifying;
    if (!_allFilled) return AppStrings.skip;
    switch (_currentStep) {
      case _PinStep.newPin:
        return AppStrings.continueText;
      case _PinStep.confirmPin:
        return AppStrings.confirm;
    }
  }

  bool get _allFilled => _currentDigits.every((d) => d.isNotEmpty);

  Color _boxBorderColor(int index) {
    final digit = _currentDigits[index];
    if (digit.isEmpty) return Colors.transparent;
    switch (_fieldState) {
      case _PinFieldState.empty:
        return Colors.transparent;
      case _PinFieldState.filled:
        return Colors.transparent;
      case _PinFieldState.success:
        return AppColors.foundationGreenNormal;
      case _PinFieldState.error:
        return AppColors.foundationErrorActive;
    }
  }

  Color _digitColor(int index) {
    final digit = _currentDigits[index];
    if (digit.isEmpty) return AppColors.foundationBlack20;
    switch (_fieldState) {
      case _PinFieldState.empty:
      case _PinFieldState.filled:
        return AppColors.foundationBlack20;
      case _PinFieldState.success:
        return AppColors.foundationGreenNormal;
      case _PinFieldState.error:
        return AppColors.foundationErrorActive;
    }
  }

  void _onDigitEntered(String digit) {
    if (_activeIndex >= 4) return;
    setState(() {
      _currentDigits[_activeIndex] = digit;
      _activeIndex++;
      if (_allFilled) {
        _fieldState = _PinFieldState.filled;
      }
    });
  }

  void _onBackspace() {
    if (_activeIndex <= 0) return;
    setState(() {
      _activeIndex--;
      _currentDigits[_activeIndex] = '';
      _fieldState = _PinFieldState.empty;
    });
  }

  void _onContinue() {
    if (!_allFilled || _isVerifying) return;

    switch (_currentStep) {
      case _PinStep.newPin:
        setState(() {
          _fieldState = _PinFieldState.success;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _currentStep = _PinStep.confirmPin;
            _fieldState = _PinFieldState.empty;
            _activeIndex = 0;
          });
        });
        break;

      case _PinStep.confirmPin:
        final match = _newPinDigits.join() == _confirmPinDigits.join();
        if (match) {
          _submitPinUpdate();
        } else {
          setState(() {
            _fieldState = _PinFieldState.error;
            _errorMessage = null;
          });
        }
        break;
    }
  }

  Future<void> _submitPinUpdate() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(profileAuthServiceProvider);
      final token = await SessionPrefs.instance.getAccessToken();
      // Backend's /v1/profile/pin lookup keys on phone number. nickName
      // works for some legacy creator accounts but not for hirer-type
      // profiles whose nickName is a client-generated handle. Phone is
      // the universal credential — fall back to nickName only when we
      // truly have no phone stored (older installs from before this fix).
      final phone = await SessionPrefs.instance.getLastPhoneNumber();
      final fallbackNickName = await SessionPrefs.instance.getNickName();
      final credential = phone.isNotEmpty ? phone : fallbackNickName;

      if (token.isEmpty || credential.isEmpty) {
        setState(() {
          _isVerifying = false;
          _fieldState = _PinFieldState.error;
          _errorMessage = 'Session expired';
        });
        return;
      }

      final response = await service.updatePin(
        credential: credential,
        pin: _newPinDigits.join(),
        accessToken: token,
      );

      if (!mounted) return;

      final status = response['status'];
      if (status == 200) {
        setState(() {
          _fieldState = _PinFieldState.success;
          _isVerifying = false;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          _isVerifying = false;
          _fieldState = _PinFieldState.error;
          _errorMessage = response['message'] as String? ?? 'Update failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _fieldState = _PinFieldState.error;
        _errorMessage = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppTransitions.duration,
      curve: Curves.easeInOut,
      child: Container(
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
            // Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CustomText(
                _title,
                key: ValueKey('title_${_currentStep}_$_fieldState'),
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
            ),
            SizedBox(height: 12.h),
            // Subtitle
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CustomText(
                _subtitle,
                key: ValueKey('subtitle_${_currentStep}_$_fieldState'),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            // Pin boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 16.w : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 0.18.sw,
                    height: 0.18.sw,
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite12,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: _boxBorderColor(index),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _currentDigits[index].isNotEmpty
                        ? CustomText(
                            _currentDigits[index],
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Neue',
                            color: _digitColor(index),
                          )
                        : null,
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),
            // CTA Button
            GradientCtaButton(
              label: _buttonLabel,
              onPressed: _allFilled
                  ? _onContinue
                  : () => Navigator.of(context).pop(),
              width: double.infinity,
              borderRadius: BorderRadius.circular(48.r),
              enabled: _allFilled,
            ),
            // Number pad
            SizedBox(height: 24.h),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        SizedBox(height: 12.h),
        _buildNumberRow(['4', '5', '6']),
        SizedBox(height: 12.h),
        _buildNumberRow(['7', '8', '9']),
        SizedBox(height: 12.h),
        _buildNumberRow(['.', '0', 'backspace']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == 'backspace') {
          return _buildKeyButton(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.foundationBlack20,
              size: 24.sp,
            ),
            onTap: _onBackspace,
          );
        }
        if (key == '.') {
          return SizedBox(width: 83.w, height: 56.h);
        }
        return _buildKeyButton(
          child: CustomText(
            key,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          onTap: () => _onDigitEntered(key),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 83.w,
        height: 56.h,
        child: Center(child: child),
      ),
    );
  }
}
