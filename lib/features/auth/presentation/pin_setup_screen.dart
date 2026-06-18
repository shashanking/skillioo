import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_cta_button.dart';
import '../../../constants/app_constants.dart';
import '../../../core/services/auth_prefs.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/widgets/common_background.dart';
import '../../onboarding/application/onboarding_data_provider.dart';
import '../application/auth_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

enum _AuthTab { pin, biometric }

enum _PinStep { set, confirm }

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
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
  bool _isSavingPin = false;
  bool _biometricAuthenticated = false;

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

    if (!mounted) return;
    setState(() {});
  }

  String _currentPin() => _pinControllers.map((c) => c.text).join();

  void _clearPinInputs() {
    for (final c in _pinControllers) {
      c.clear();
    }
    _pinFocusNodes.first.requestFocus();
  }

  /// Persist PIN on the backend then flip to the biometric tab.
  ///
  /// If the backend update fails we stay on the PIN screen and surface the
  /// error — silently advancing would let the user think their PIN is set
  /// when it actually isn't, which then blows up at the next login.
  Future<void> _persistPinAndAdvance(String pin) async {
    setState(() => _isSavingPin = true);

    final rawPhone = ref.read(onboardingDataProvider).phoneNumber;
    final accessToken = await SessionPrefs.instance.getAccessToken();

    if (rawPhone.isEmpty || accessToken.isEmpty) {
      if (!mounted) return;
      _showPinFailure(
        'Session lost — please restart sign-up to set your PIN.',
      );
      return;
    }

    try {
      final service = ref.read(profileAuthServiceProvider);
      final response = await service.updatePin(
        credential: rawPhone,
        pin: pin,
        accessToken: accessToken,
      );
      final status = response['status'] as int? ?? 0;
      final success = response['success'] as bool? ?? (status == 200);
      if (!success) {
        if (!mounted) return;
        final message =
            response['message'] as String? ?? 'Failed to save PIN.';
        _showPinFailure(message);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      _showPinFailure('Could not save PIN. Please try again.');
      return;
    }

    // Server has the PIN — only now mirror it locally and advance.
    await _authPrefs.setPin(pin);
    ref.read(onboardingDataProvider.notifier).state =
        ref.read(onboardingDataProvider).copyWith(pin: pin);

    if (!mounted) return;
    setState(() {
      _isSavingPin = false;
      _currentTab = _AuthTab.biometric;
      _pinStep = _PinStep.set;
      _firstPin = null;
      _showPinError = false;
    });
    for (final c in _pinControllers) {
      c.clear();
    }
  }

  void _showPinFailure(String message) {
    setState(() {
      _isSavingPin = false;
      _pinStep = _PinStep.set;
      _firstPin = null;
      _showPinError = true;
    });
    for (final c in _pinControllers) {
      c.clear();
    }
    _pinFocusNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _onPinPrimaryPressed() async {
    final pin = _currentPin();

    // "Skip" path — no digits entered. Jump to biometric tab without saving.
    if (_pinStep == _PinStep.set && pin.isEmpty) {
      setState(() {
        _currentTab = _AuthTab.biometric;
        _showPinError = false;
      });
      return;
    }

    if (pin.length != 4) {
      setState(() {
        _showPinError = true;
      });
      return;
    }

    if (_pinStep == _PinStep.set) {
      _firstPin = pin;
      setState(() {
        _pinStep = _PinStep.confirm;
        _showPinError = false;
      });
      _clearPinInputs();
      return;
    }

    // Confirm step.
    final matches = pin == _firstPin;
    setState(() => _showPinError = !matches);
    if (matches) {
      await _persistPinAndAdvance(pin);
    }
  }

  Future<void> _onBiometricTap() async {
    final didAuth = await _authPrefs.authenticateWithBiometrics();
    if (!mounted) return;
    if (didAuth) {
      setState(() => _biometricAuthenticated = true);
    }
  }

  void _onBiometricPrimaryPressed() {
    GoRouter.of(context).go('/auth-success');
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
          height: 48.h,
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
            width: 0.19.sw,
            height: 0.19.sw,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
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
    required VoidCallback? onPressed,
  }) {
    return GradientCtaButton(
      label: label,
      width: double.infinity,
      height: 58,
      enabled: onPressed != null,
      onPressed: onPressed,
    );
  }

  Widget _buildPinContent() {
    final isConfirm = _pinStep == _PinStep.confirm;
    // Button label flips to "Continue" as soon as any digit is entered,
    // or when we're in the confirm step (which always expects Continue).
    final pinLength = _currentPin().length;
    final label = (isConfirm || pinLength > 0)
        ? (_isSavingPin ? 'Saving...' : 'Continue')
        : 'Skip';
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
          label: label,
          onPressed: _isSavingPin ? null : _onPinPrimaryPressed,
        ),
      ],
    );
  }

  Widget _buildBiometricContent() {
    final label = _biometricAuthenticated ? 'Continue' : 'Skip';
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
          _biometricAuthenticated
              ? 'Biometric enabled. Tap continue to proceed.'
              : 'Touch fingerprint sensor or use Face ID',
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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 55, 84, 250),
                  Color.fromARGB(34, 47, 76, 223),
                  Color.fromARGB(73, 24, 46, 144),
                  Color.fromARGB(124, 8, 29, 91),
                  Color.fromARGB(205, 0, 19, 62),
                  Color.fromARGB(255, 0, 16, 50),
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
          label: label,
          onPressed: _onBiometricPrimaryPressed,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                SizedBox(
                  width: 180.w,
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
                Builder(builder: (context) {
                  final phone =
                      ref.watch(onboardingDataProvider).phoneNumber;
                  return Text(
                    phone.isNotEmpty
                        ? 'Set up PIN for $phone'
                        : 'Choose your preferred authentication method',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  );
                }),
                SizedBox(height: 24.h),
                Container(
                  height: 48.h,
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
