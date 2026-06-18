import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/app_constants.dart';
import '../../features/auth/application/auth_providers.dart';
import '../services/session_prefs.dart';
import '../services/session_state_provider.dart';
import 'custom_text.dart';
import 'gradient_cta_button.dart';

/// Bottom sheet for re-authenticating with PIN when access token expires
class PinReauthBottomSheet extends ConsumerStatefulWidget {
  const PinReauthBottomSheet({super.key});

  @override
  ConsumerState<PinReauthBottomSheet> createState() =>
      _PinReauthBottomSheetState();
}

class _PinReauthBottomSheetState extends ConsumerState<PinReauthBottomSheet> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  bool _showError = false;
  String _errorText = '';
  bool _isLoading = false;
  String _phoneNumber = '';

  static const _kLastPhoneNumberKey = 'last_phone_number';
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    _pinFocusNodes.first.requestFocus();
  }

  Future<void> _loadPhoneNumber() async {
    // Try to get phone from secure storage first (saved during login)
    final savedPhone = await _storage.read(key: _kLastPhoneNumberKey);

    if (savedPhone != null && savedPhone.isNotEmpty) {
      _phoneNumber = savedPhone;
      if (_phoneNumber.startsWith('+91')) {
        _phoneNumber = _phoneNumber.substring(3);
      }
    } else {
      // Fallback to profile if available
      final profile = await SessionPrefs.instance.getProfile();
      final phoneList = profile?['phoneNumber'];
      if (phoneList is List && phoneList.isNotEmpty) {
        _phoneNumber = phoneList.first.toString();
        if (_phoneNumber.startsWith('+91')) {
          _phoneNumber = _phoneNumber.substring(3);
        }
      }
    }

    if (mounted) setState(() {});
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
    if (mounted) setState(() {});
  }

  String _currentPin() => _pinControllers.map((c) => c.text).join();

  Future<void> _onLogin() async {
    final pin = _currentPin();
    if (pin.length != 4) {
      setState(() {
        _showError = true;
        _errorText = 'Please enter 4 digit PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final service = ref.read(profileAuthServiceProvider);
      final response = await service.login(credential: _phoneNumber, pin: pin);

      final success = response['success'] as bool? ?? false;
      if (!success) {
        throw Exception('Invalid PIN');
      }

      // Extract and save new session data
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';
        final profile = data['profile'];

        if (accessToken.isNotEmpty && profile is Map) {
          await SessionPrefs.instance.setSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            profile: Map<String, dynamic>.from(profile),
          );

          // Save phone number to secure storage for subscription flow
          await _storage.write(
            key: _kLastPhoneNumberKey,
            value: '+91$_phoneNumber',
          );
        }
      }

      await ref.read(sessionStateProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorText = 'Invalid PIN. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissal by swipe/back
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
              CustomText(
                'Session Expired',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
              SizedBox(height: 12.h),
              CustomText(
                'Please enter your PIN to continue',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
              ),
              if (_phoneNumber.isNotEmpty) ...[
                SizedBox(height: 8.h),
                CustomText(
                  'Phone: $_phoneNumber',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack20.withValues(alpha: 0.7),
                ),
              ],
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 0.18.sw,
                    height: 0.18.sw,
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite12,
                      borderRadius: BorderRadius.circular(16.r),
                      border: _showError
                          ? Border.all(
                              color: const Color(0xFFFF3B3B),
                              width: 1.5,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _pinControllers[index],
                      focusNode: _pinFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: TextStyle(
                        fontFamily: 'Neue',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foundationBlack20,
                      ),
                      cursorColor: AppColors.foundationBlack20,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (v) => _onPinDigitChanged(index, v),
                    ),
                  );
                }),
              ),
              if (_showError) ...[
                SizedBox(height: 12.h),
                CustomText(
                  _errorText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFFF3B3B),
                ),
              ],
              SizedBox(height: 24.h),
              GradientCtaButton(
                onPressed: _isLoading ? null : _onLogin,
                width: double.infinity,
                borderRadius: BorderRadius.circular(48.r),
                child: _isLoading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : CustomText(
                        'Login',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foundationBlack20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
