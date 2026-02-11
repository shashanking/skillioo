import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/auth_prefs.dart';
import '../../../core/widgets/common_background.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

enum _AuthTab { pin, biometric }

enum _PinStep { set, confirm }

class _PinSetupScreenState extends State<PinSetupScreen> {
  _AuthTab _currentTab = _AuthTab.pin;
  _PinStep _pinStep = _PinStep.set;

  final AuthPrefs _authPrefs = AuthPrefs.instance;

  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  String? _firstPin;
  bool _showPinError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPinDigitChanged(int index, String value) {
    if (value.length == 1 && index < _pinFocusNodes.length - 1) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
  }

  String _currentPin() => _pinControllers.map((c) => c.text).join();

  Future<void> _onPinContinue() async {
    final pin = _currentPin();
    if (pin.length != 4) return;

    if (_pinStep == _PinStep.set) {
      _firstPin = pin;
      setState(() {
        _pinStep = _PinStep.confirm;
        _showPinError = false;
      });
      for (final c in _pinControllers) {
        c.clear();
      }
      _pinFocusNodes.first.requestFocus();
    } else {
      final matches = pin == _firstPin;
      setState(() {
        _showPinError = !matches;
      });
      if (matches) {
        // Persist PIN securely in local storage.
        await _authPrefs.setPin(pin);
        setState(() {
          _currentTab = _AuthTab.biometric;
          _pinStep = _PinStep.set;
        });
        for (final c in _pinControllers) {
          c.clear();
        }
      }
    }
  }

  Future<void> _onPinPrimaryButtonPressed() async {
    final isConfirm = _pinStep == _PinStep.confirm;
    final pinLength = _currentPin().length;

    // SET step behaviour
    if (!isConfirm) {
      // When fewer than 4 digits are entered, button is "Skip" → go straight to Biometric.
      if (pinLength < 4) {
        setState(() {
          _currentTab = _AuthTab.biometric;
          _pinStep = _PinStep.set;
          _showPinError = false;
        });
        for (final c in _pinControllers) {
          c.clear();
        }
        return;
      }

      // Exactly 4 digits: button label is "Continue" and we proceed to confirm PIN.
      await _onPinContinue();
      return;
    }

    // CONFIRM step behaviour: always "Continue" and uses existing confirm logic.
    await _onPinContinue();
  }

  Future<void> _onBiometricTap() async {
    final didAuth = await _authPrefs.authenticateWithBiometrics();
    if (didAuth && mounted) {
      GoRouter.of(context).go('/auth-success');
    }
  }

  Widget _buildTabChip(String label, _AuthTab tab) {
    final isActive = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = tab;
          });
        },
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == 3 ? 0 : 16.w),
          child: Container(
            width: 0.17.sw,
            height: 0.17.sw,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24.r),
              border: _showPinError
                  ? Border.all(color: const Color(0xFFFF3B3B), width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _pinControllers[index],
              focusNode: _pinFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: TextStyle(
                fontFamily: 'Neue',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                height: 1.33,
                color: const Color(0xFFF5F5F5),
              ),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (v) => _onPinDigitChanged(index, v),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 78.h,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.r),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(48.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinContent() {
    final isConfirm = _pinStep == _PinStep.confirm;
    final pinLength = _currentPin().length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 32.h),
        Text(
          isConfirm ? 'Confirm Pin' : 'Set Pin',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        _buildPinDots(),
        if (_showPinError) ...[
          SizedBox(height: 12.h),
          Text(
            "Pin doesn't match. Try Again.",
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFF3B3B),
            ),
          ),
        ],
        const Spacer(),
        _buildGradientButton(
          // Set step: show Continue only when 4 digits entered, else Skip.
          // Confirm step: always show Continue (action will only succeed when pins match).
          label: isConfirm
              ? 'Continue'
              : (pinLength == 4 ? 'Continue' : 'Skip'),
          onPressed: _onPinPrimaryButtonPressed,
        ),
      ],
    );
  }

  Widget _buildBiometricContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 32.h),
        Text(
          'Biometric Authentication',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Touch fingerprint sensor or use Face ID',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 48.h),
        GestureDetector(
          onTap: _onBiometricTap,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // need gradient color background:
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // linear-gradient(
                  // 180deg,
                  const Color.fromARGB(255, 55, 84, 250),
                  const Color.fromARGB(34, 47, 76, 223),
                  const Color.fromARGB(73, 24, 46, 144),
                  const Color.fromARGB(124, 8, 29, 91),
                  const Color.fromARGB(205, 0, 19, 62),
                  const Color.fromARGB(255, 0, 16, 50),

                  //rgba(47, 75, 223, 0.25) 13.46%,
                  // rgba(24, 47, 144, 0.25) 30.77%,
                  // rgba(8, 29, 91, 0.25) 51.92%,
                  //rgba(0, 19, 62, 0.25) 65.87%,
                  // rgba(0, 16, 50, 0.25) 100%);
                ],
              ),
            ),
            child: SizedBox(
              width: 60.w,
              height: 124.w,
              child: Image.asset(AppAssets.thumbPng, fit: BoxFit.contain),
            ),
          ),
        ),
        const Spacer(),
        _buildGradientButton(
          label: 'Skip',
          onPressed: () {
            // Skip biometric setup and continue to the next step.
            GoRouter.of(context).go('/auth-success');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                SizedBox(
                  width: 80.w,
                  child: Image.asset(AppAssets.logoPng, fit: BoxFit.contain),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Welcome To Talent Hub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Neue',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Choose your preferred authentication method',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      _buildTabChip('Pin', _AuthTab.pin),
                      SizedBox(width: 4.w),
                      _buildTabChip('Biometric', _AuthTab.biometric),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _currentTab == _AuthTab.pin
                        ? _buildPinContent()
                        : _buildBiometricContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
