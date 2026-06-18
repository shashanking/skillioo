import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/auth_prefs.dart';
import '../../localization/locale_extension.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../gradient_cta_button.dart';
import '../icon_button.dart';

class BiometricsScreen extends ConsumerStatefulWidget {
  const BiometricsScreen({super.key});

  @override
  ConsumerState<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends ConsumerState<BiometricsScreen> {
  List<String> _fingerprints = [];

  @override
  void initState() {
    super.initState();
    // Initialize with localized fingerprint names after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _fingerprints = [ref.tr.fingerprint1, ref.tr.fingerprint2];
      });
    });
  }

  void _onAddFingerprint() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _AddFingerprintSheet(
          onFingerprintAdded: () {
            setState(() {
              _fingerprints.add('Fingerprint ${_fingerprints.length + 1}');
            });
          },
        );
      },
    );
  }

  void _onDeleteFingerprint(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final fingerprint = _fingerprints[index];
        return _DeleteFingerprintSheet(
          fingerprintName: fingerprint,
          onConfirm: () {
            setState(() {
              _fingerprints.removeAt(index);
            });
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
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
                      tr.biometrics,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    children: [
                      ..._fingerprints.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildFingerprintTile(entry.value, entry.key),
                        );
                      }),
                      const Spacer(),
                      // Add New Fingerprint CTA
                      GradientCtaButton(
                        label: tr.addNewFingerprint,
                        onPressed: _onAddFingerprint,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(48.r),
                        leading: Icon(
                          Icons.add,
                          color: AppColors.foundationBlack20,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
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

  Widget _buildFingerprintTile(String label, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.glassWhite06,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint,
            color: AppColors.foundationBlack20,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomText(
              label,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
          ),
          GestureDetector(
            onTap: () => _onDeleteFingerprint(index),
            child: Icon(
              Icons.delete_outline,
              color: AppColors.foundationErrorActive,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Fingerprint Bottom Sheet ───────────────────────────────────────────

enum _AddFingerprintStep { verify, register, success, error }

class _AddFingerprintSheet extends StatefulWidget {
  final VoidCallback onFingerprintAdded;

  const _AddFingerprintSheet({required this.onFingerprintAdded});

  @override
  State<_AddFingerprintSheet> createState() => _AddFingerprintSheetState();
}

class _AddFingerprintSheetState extends State<_AddFingerprintSheet> {
  _AddFingerprintStep _step = _AddFingerprintStep.verify;
  final AuthPrefs _authPrefs = AuthPrefs.instance;
  bool _isProcessing = false;

  String get _title {
    switch (_step) {
      case _AddFingerprintStep.verify:
        return AppStrings.verifyIdentity;
      case _AddFingerprintStep.register:
        return AppStrings.placeYourFinger;
      case _AddFingerprintStep.success:
        return AppStrings.fingerprintAdded;
      case _AddFingerprintStep.error:
        return AppStrings.verificationFailed;
    }
  }

  String get _subtitle {
    switch (_step) {
      case _AddFingerprintStep.verify:
        return AppStrings.verifyIdentityBody;
      case _AddFingerprintStep.register:
        return AppStrings.placeYourFingerBody;
      case _AddFingerprintStep.success:
        return AppStrings.fingerprintAddedBody;
      case _AddFingerprintStep.error:
        return AppStrings.verificationFailedBody;
    }
  }

  IconData get _icon {
    switch (_step) {
      case _AddFingerprintStep.verify:
      case _AddFingerprintStep.register:
        return Icons.fingerprint;
      case _AddFingerprintStep.success:
        return Icons.check_circle_outline;
      case _AddFingerprintStep.error:
        return Icons.error_outline;
    }
  }

  Color get _iconColor {
    switch (_step) {
      case _AddFingerprintStep.verify:
      case _AddFingerprintStep.register:
        return AppColors.foundationBlack20;
      case _AddFingerprintStep.success:
        return AppColors.foundationGreenNormal;
      case _AddFingerprintStep.error:
        return AppColors.foundationErrorActive;
    }
  }

  Future<void> _onVerify() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final didAuth = await _authPrefs.authenticateWithBiometrics();

    if (!mounted) return;

    if (didAuth) {
      setState(() {
        _step = _AddFingerprintStep.register;
        _isProcessing = false;
      });
    } else {
      setState(() {
        _step = _AddFingerprintStep.error;
        _isProcessing = false;
      });
    }
  }

  Future<void> _onRegister() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final didAuth = await _authPrefs.authenticateWithBiometrics();

    if (!mounted) return;

    if (didAuth) {
      widget.onFingerprintAdded();
      setState(() {
        _step = _AddFingerprintStep.success;
        _isProcessing = false;
      });
    } else {
      setState(() {
        _step = _AddFingerprintStep.error;
        _isProcessing = false;
      });
    }
  }

  void _onRetry() {
    setState(() {
      _step = _AddFingerprintStep.verify;
    });
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CustomText(
                _title,
                key: ValueKey('bio_title_$_step'),
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomText(
                  _subtitle,
                  key: ValueKey('bio_subtitle_$_step'),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack20,
                  height: 1.5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            // Fingerprint icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey('bio_icon_$_step'),
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassWhite12,
                  border: Border.all(
                    color: _step == _AddFingerprintStep.success
                        ? AppColors.foundationGreenNormal
                        : _step == _AddFingerprintStep.error
                        ? AppColors.foundationErrorActive
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(_icon, size: 56.sp, color: _iconColor),
              ),
            ),
            SizedBox(height: 40.h),
            // CTA Button
            _buildCta(),
          ],
        ),
      ),
    );
  }

  Widget _buildCta() {
    switch (_step) {
      case _AddFingerprintStep.verify:
        return _buildButton(
          label: _isProcessing ? AppStrings.verifying : AppStrings.verify,
          onTap: _onVerify,
          active: !_isProcessing,
        );
      case _AddFingerprintStep.register:
        return _buildButton(
          label: _isProcessing
              ? AppStrings.verifying
              : AppStrings.addNewFingerprint,
          onTap: _onRegister,
          active: !_isProcessing,
        );
      case _AddFingerprintStep.success:
        return _buildButton(
          label: AppStrings.done,
          onTap: () => Navigator.of(context).pop(),
          active: true,
        );
      case _AddFingerprintStep.error:
        return _buildButton(
          label: AppStrings.tryAgain,
          onTap: _onRetry,
          active: true,
        );
    }
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          gradient: active
              ? AppColors.ctaGradient
              : AppColors.ctaGradientDeactivated,
          borderRadius: BorderRadius.circular(48.r),
        ),
        alignment: Alignment.center,
        child: CustomText(
          label,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.foundationBlack20,
        ),
      ),
    );
  }
}

// ─── Delete Fingerprint Confirmation Bottom Sheet ───────────────────────────

class _DeleteFingerprintSheet extends StatelessWidget {
  final String fingerprintName;
  final VoidCallback onConfirm;

  const _DeleteFingerprintSheet({
    required this.fingerprintName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassWhite12,
              border: Border.all(
                color: AppColors.foundationErrorActive,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.fingerprint,
              size: 40.sp,
              color: AppColors.foundationErrorActive,
            ),
          ),
          SizedBox(height: 24.h),
          CustomText(
            '${AppStrings.deleteFingerprint}?',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomText(
              AppStrings.deleteFingerprintBody,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
              height: 1.5,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          // Delete button
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              width: double.infinity,
              height: 58.h,
              decoration: BoxDecoration(
                color: AppColors.foundationErrorActive,
                borderRadius: BorderRadius.circular(48.r),
              ),
              alignment: Alignment.center,
              child: CustomText(
                AppStrings.deleteFingerprint,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.foundationBlack20,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Cancel button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 58.h,
              decoration: BoxDecoration(
                color: AppColors.glassWhite12,
                borderRadius: BorderRadius.circular(48.r),
              ),
              alignment: Alignment.center,
              child: CustomText(
                AppStrings.cancel,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.foundationBlack20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
