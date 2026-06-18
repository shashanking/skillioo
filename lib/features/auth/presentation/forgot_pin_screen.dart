import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/auth_prefs.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../onboarding/application/onboarding_data_provider.dart';
import '../application/auth_providers.dart';

/// Forgot PIN reset screen.
///
/// Flow:
///   user types new PIN + confirm → tap Confirm
///   → PUT /v1/profile/forgotPin (no auth)
///   → POST /v1/profile/login with the new PIN
///   → route by `isCreator` (true → /landing, else → /options).
class ForgotPinScreen extends ConsumerStatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  ConsumerState<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

enum _Step { newPin, confirmPin }

class _ForgotPinScreenState extends ConsumerState<ForgotPinScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  _Step _step = _Step.newPin;
  String? _newPin;
  bool _isLoading = false;
  bool _showError = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _currentPin() => _controllers.map((c) => c.text).join();

  void _clearInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (mounted) setState(() {});
  }

  /// Resolves the credential to send to the backend. Phone number is the
  /// primary identifier — must be sent in `+91...` form (login + forgotPin
  /// both look up by exact match).
  String _resolveCredential() {
    final raw = ref.read(onboardingDataProvider).phoneNumber;
    if (raw.startsWith('+')) return raw;
    return '+91${raw.replaceFirst(RegExp(r'^\+?91'), '')}';
  }

  Future<void> _onConfirm() async {
    final pin = _currentPin();
    if (pin.length != 4) {
      setState(() {
        _showError = true;
        _errorText = 'Please enter a 4-digit PIN.';
      });
      return;
    }

    if (_step == _Step.newPin) {
      _newPin = pin;
      setState(() {
        _step = _Step.confirmPin;
        _showError = false;
      });
      _clearInputs();
      return;
    }

    // Confirm step.
    if (pin != _newPin) {
      setState(() {
        _showError = true;
        _errorText = "PIN doesn't match. Try again.";
      });
      _clearInputs();
      return;
    }

    final credential = _resolveCredential();
    if (credential.isEmpty || credential == '+91') {
      setState(() {
        _showError = true;
        _errorText = 'Phone number missing. Please go back and start over.';
      });
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final service = ref.read(profileAuthServiceProvider);
      final resetResponse = await service.forgotPin(
        credential: credential,
        pin: pin,
        confirmPin: pin,
      );
      final resetStatus = resetResponse['status'] as int? ?? 0;
      final resetSuccess =
          resetResponse['success'] as bool? ?? (resetStatus == 200);
      if (!resetSuccess) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorText = resetResponse['message'] as String? ??
              'Could not reset PIN. Please try again.';
        });
        return;
      }

      // Reset succeeded — log in with the new PIN so we can route by
      // isCreator without the user having to type the PIN again.
      final loginResponse =
          await service.login(credential: credential, pin: pin);
      final loginSuccess = loginResponse['success'] as bool? ?? false;
      if (!loginSuccess) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        // Reset worked but auto-login failed — bounce back to PIN entry.
        messenger.showSnackBar(
          const SnackBar(
            content: Text('PIN reset. Please log in with your new PIN.'),
          ),
        );
        router.go('/enter-pin');
        return;
      }

      final data = loginResponse['data'] as Map<String, dynamic>? ?? {};
      final profile = data['profile'] as Map<String, dynamic>? ?? {};
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        await SessionPrefs.instance.setSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          profile: profile,
        );
        await AuthPrefs.instance.setPin(pin);
        const storage = FlutterSecureStorage();
        await storage.write(key: 'last_phone_number', value: credential);
        await ref.read(sessionStateProvider.notifier).refresh();
      }

      if (!mounted) return;
      final isCreator = profile['isCreator'] as bool? ?? false;
      router.go(isCreator ? '/landing' : '/options');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorText = 'Could not reset PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirm = _step == _Step.confirmPin;
    final pinLength = _currentPin().length;
    final canSubmit = pinLength == 4 && !_isLoading;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    if (GoRouter.of(context).canPop()) {
                      GoRouter.of(context).pop();
                    } else {
                      GoRouter.of(context).go('/enter-pin');
                    }
                  },
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(124.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/arrow-left.png',
                        color: const Color(0xFFF5F5F5),
                        width: 20.sp,
                        height: 20.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  isConfirm ? 'Confirm New PIN' : 'Set a New PIN',
                  style: TextStyle(
                    fontFamily: 'Neue',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isConfirm
                      ? 'Re-enter the 4-digit PIN to confirm.'
                      : 'Choose a new 4-digit PIN for your account.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: index == 3 ? 0 : 16.w),
                      child: Container(
                        width: 0.19.sw,
                        height: 0.19.sw,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24.r),
                          border: _showError
                              ? Border.all(
                                  color: const Color(0xFFFF3B3B),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
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
                            color: const Color(0xFFF5F5F5),
                          ),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          onChanged: (v) => _onDigitChanged(index, v),
                        ),
                      ),
                    );
                  }),
                ),
                if (_showError) ...[
                  SizedBox(height: 12.h),
                  Text(
                    _errorText,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFF3B3B),
                    ),
                  ),
                ],
                const Spacer(),
                GradientCtaButton(
                  label: _isLoading ? 'Loading' : 'Confirm',
                  width: double.infinity,
                  height: 58,
                  enabled: canSubmit,
                  onPressed: canSubmit ? _onConfirm : null,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
