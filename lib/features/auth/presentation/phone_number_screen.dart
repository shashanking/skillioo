import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../../onboarding/application/onboarding_data_provider.dart';
import '../application/auth_providers.dart';
import '../application/states/auth_state.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;
  String _errorText = "Invalid number. Fix it and we're good.";
  final FocusNode _focusNode = FocusNode();
  bool _isComplete = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onVerify() {
    final value = _controller.text.trim();
    final isValid = RegExp(r'^\d{10}$').hasMatch(value);
    setState(() {
      _showError = !isValid;
    });
    if (isValid) {
      final phoneNumber = '+91$value';
      ref.read(onboardingDataProvider.notifier).state = ref
          .read(onboardingDataProvider)
          .copyWith(phoneNumber: phoneNumber);
      ref
          .read(authNotifierProvider.notifier)
          .sendOtp(phoneNumber: phoneNumber, purpose: 'SIGNUP');
    } else {
      setState(() => _errorText = "Invalid number. Fix it and we're good.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.otpSent) {
        ref.read(onboardingDataProvider.notifier).state = ref
            .read(onboardingDataProvider)
            .copyWith(phoneVerificationId: next.verificationId);
        GoRouter.of(context).go('/otp');
      } else if (next.status == AuthStatus.error &&
          next.errorMessage.isNotEmpty) {
        setState(() {
          _showError = true;
          _errorText = next.errorMessage;
        });
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
                        "What's your number?",
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
                        "Promise we’ll only use it to send your OTP.",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
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
                        child: Row(
                          children: [
                            Text(
                              '91+',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: const Color(0xFFB0B0B0),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.phone,
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: const Color(0xFFF5F5F5),
                                ),
                                cursorColor: Colors.white,
                                onChanged: (value) {
                                  final digits = value.trim();
                                  final complete = digits.length == 10;
                                  if (complete && !_isComplete) {
                                    FocusScope.of(context).unfocus();
                                  }
                                  setState(() {
                                    _isComplete = complete;
                                    if (!complete) {
                                      _showError = false;
                                    }
                                  });
                                },
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,

                                  hintStyle: TextStyle(
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showError) ...[
                        SizedBox(height: 8.h),
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
                    ],
                  ),
                ),
                const Spacer(),
                if (_isComplete)
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 78.h,
                      child: TextButton(
                        onPressed: isLoading ? null : _onVerify,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
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
