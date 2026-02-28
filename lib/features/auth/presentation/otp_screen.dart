import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/auth_providers.dart';
import '../application/states/auth_state.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
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

  void _onResend() {
    ref.read(authNotifierProvider.notifier).resendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.otpVerified) {
        GoRouter.of(context).go('/verified');
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
                SizedBox(height: 32.h),
                Text(
                  'Step: 1 of 2',
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
                      Text(
                        'Peep your phone and enter the code we just sent.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
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
                      GestureDetector(
                        onTap: authState.isResending ? null : _onResend,
                        child: Text(
                          authState.isResending ? 'Resending...' : 'Resend OTP',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFF5F5F5),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFF5F5F5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: 380.w,
                    height: 78.h,
                    child: TextButton(
                      onPressed: isLoading ? null : _onVerify,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 20.h,
                        ),
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
                            'Verify',
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
