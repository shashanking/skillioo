import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../core/widgets/common_background.dart';
import '../../onboarding/application/onboarding_data_provider.dart';
import '../application/auth_providers.dart';
import '../application/states/auth_state.dart';
import '../../../core/services/session_state_provider.dart';

const int _kOtpResendSeconds = 120;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _showError = false;
  Timer? _resendTimer;
  int _secondsRemaining = _kOtpResendSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = _kOtpResendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  String _formatRemaining() {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onChangedDigit(int index, String value) {
    if (value.length == 1 && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onVerify() {
    final code = _controllers.map((c) => c.text).join();
    final isValid = code.length == 4;

    setState(() {
      _showError = !isValid;
    });

    if (isValid) {
      ref.read(authNotifierProvider.notifier).verifyOtp(otpCode: code);
    }
  }

  Future<void> _onResend() async {
    if (_secondsRemaining > 0) return;
    await ref.read(authNotifierProvider.notifier).resendOtp();
    if (!mounted) return;
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) async {
      if (next.status == AuthStatus.otpVerified) {
        ref.read(onboardingDataProvider.notifier).state = ref
            .read(onboardingDataProvider)
            .copyWith(phoneVerificationId: next.verificationId);
        // Fully-onboarded creators land on the dashboard. Everyone else
        // goes through the success → /pin → /options flow.
        if (next.isCreator) {
          await ref.read(sessionStateProvider.notifier).refresh();
          if (context.mounted) GoRouter.of(context).go('/landing');
        } else {
          GoRouter.of(context).go('/verified');
        }
      } else if (next.status == AuthStatus.error &&
          next.errorMessage.isNotEmpty) {
        setState(() => _showError = true);
      }
    });

    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (GoRouter.of(context).canPop()) {
                          GoRouter.of(context).pop();
                        } else {
                          GoRouter.of(context).go('/phone');
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
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  'Step: 2 of 2',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: 380.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP Time !',
                        style: TextStyle(
                          fontFamily: 'Neue',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Builder(builder: (context) {
                        final phone =
                            ref.watch(authNotifierProvider).phoneNumber;
                        final display = phone.isNotEmpty ? phone : '';
                        return Text(
                          display.isNotEmpty
                              ? 'Enter the code we sent to $display'
                              : 'Peep your phone and enter the code we just sent.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: const Color(0xFFF5F5F5),
                          ),
                        );
                      }),
                      SizedBox(height: 24.h),
                      Row(
                        children: List.generate(4, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == 3 ? 0 : 16.w,
                            ),
                            child: Container(
                              width: 0.19.sw,
                              height: 0.19.sw,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.r),
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
                                  height: 1.33,
                                  color: const Color(0xFFF5F5F5),
                                ),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                                onChanged: (v) => _onChangedDigit(index, v),
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_showError) ...[
                        SizedBox(height: 12.h),
                        Text(
                          authState.errorMessage.isNotEmpty
                              ? authState.errorMessage
                              : 'Invalid OTP. Try Again.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFFF3B3B),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Builder(builder: (_) {
                        final canResend =
                            _secondsRemaining == 0 && !authState.isResending;
                        final label = authState.isResending
                            ? 'Resending...'
                            : (_secondsRemaining > 0
                                ? 'Resend OTP in ${_formatRemaining()}'
                                : 'Resend OTP');
                        return GestureDetector(
                          onTap: canResend ? _onResend : null,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: canResend
                                  ? const Color(0xFFF5F5F5)
                                  : Colors.white54,
                              decoration: canResend
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: const Color(0xFFF5F5F5),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 58.h,
                    child: GradientCtaButton(
                      label: 'Verify',
                      width: double.infinity,
                      height: 58,
                      enabled: !isLoading,
                      onPressed: _onVerify,
                    ),
                  ),
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
