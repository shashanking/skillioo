import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_constants.dart';
import '../../../core/services/auth_prefs.dart';
import '../../../core/services/session_prefs.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../localization/locale_extension.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../gradient_cta_button.dart';
import '../icon_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      tr.settings,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Menu items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  children: [
                    _buildSettingsMenuItem(
                      assetIcon: AppAssets.dialSquarePng,
                      label: tr.pinSetup,
                      onTap: () => _showPinChangeBottomSheet(context, ref),
                      isFirst: true,
                    ),
                    _BiometricToggleTile(label: tr.biometrics),
                    _buildSettingsMenuItem(
                      icon: Icons.notifications_outlined,
                      label: tr.notificationPreferences,
                      isLast: true,
                      onTap: () => _showNotificationPreferences(context),
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

  Widget _buildSettingsMenuItem({
    IconData? icon,
    String? assetIcon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }

  void _showNotificationPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _NotificationPreferencesSheet();
      },
    );
  }

  void _showPinChangeBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _PinChangeBottomSheet();
      },
    );
  }
}

/// Settings row that toggles biometric unlock on/off.
///
/// Enabling it runs a one-time biometric prompt (the device's face or
/// fingerprint — whichever is enrolled; Face ID on iOS) and stores the
/// preference locally via [AuthPrefs]. No biometric data is stored by the
/// app — the OS owns that; we only persist the on/off flag.
class _BiometricToggleTile extends StatefulWidget {
  const _BiometricToggleTile({required this.label});

  final String label;

  @override
  State<_BiometricToggleTile> createState() => _BiometricToggleTileState();
}

class _BiometricToggleTileState extends State<_BiometricToggleTile> {
  final AuthPrefs _authPrefs = AuthPrefs.instance;
  bool _loading = true;
  bool _busy = false;
  bool _available = false;
  bool _enabled = false;
  String _typeLabel = 'Biometric';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await _authPrefs.isBiometricAvailable();
    final enabled = await _authPrefs.isBiometricEnabled();
    final label = await _authPrefs.biometricLabel();
    if (!mounted) return;
    setState(() {
      _available = available;
      _enabled = available && enabled;
      _typeLabel = label;
      _loading = false;
    });
  }

  Future<void> _onToggle(bool value) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    if (value) {
      // Intake: prompt the device biometric once, then persist the flag.
      final ok = await _authPrefs.authenticateWithBiometrics();
      if (!mounted) return;
      setState(() {
        _enabled = ok;
        _busy = false;
      });
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Biometric verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      await _authPrefs.setBiometricEnabled(false);
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFace = _typeLabel.toLowerCase().contains('face');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(color: AppColors.glassWhite06),
      child: Row(
        children: [
          Icon(
            isFace ? Icons.face : Icons.fingerprint,
            color: AppColors.foundationBlack20,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  widget.label,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack20,
                ),
                if (!_loading) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    _available
                        ? 'Unlock with $_typeLabel'
                        : 'Not available on this device',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.foundationBlack20.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
          if (_loading || _busy)
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Switch(
              value: _enabled,
              onChanged: _available ? _onToggle : null,
              activeThumbColor: AppColors.foundationGreenNormal,
            ),
        ],
      ),
    );
  }
}

class _PinChangeBottomSheet extends ConsumerStatefulWidget {
  const _PinChangeBottomSheet();

  @override
  ConsumerState<_PinChangeBottomSheet> createState() =>
      _PinChangeBottomSheetState();
}

enum _PinChangeStep { oldPin, newPin, confirmPin }

class _PinChangeBottomSheetState extends ConsumerState<_PinChangeBottomSheet> {
  _PinChangeStep _currentStep = _PinChangeStep.oldPin;
  bool _hasPin = true;

  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  String? _newPin;
  bool _showError = false;
  String _errorText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initStep();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNodes.first.requestFocus();
    });
  }

  Future<void> _initStep() async {
    final hasPin = await AuthPrefs.instance.hasPin();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      if (!hasPin) _currentStep = _PinChangeStep.newPin;
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

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _pinFocusNodes.length - 1) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
    if (mounted) setState(() {});
  }

  String _currentPin() => _pinControllers.map((c) => c.text).join();

  void _clearPinFields() {
    for (final c in _pinControllers) {
      c.clear();
    }
    _pinFocusNodes.first.requestFocus();
  }

  Future<void> _onContinue() async {
    final pin = _currentPin();
    if (pin.length != 4) {
      setState(() {
        _showError = true;
        _errorText = 'Please enter 4 digit PIN';
      });
      return;
    }

    switch (_currentStep) {
      case _PinChangeStep.oldPin:
        // Verify old PIN locally against what was saved by AuthPrefs.setPin
        final savedPin = await AuthPrefs.instance.hasPin()
            ? (await AuthPrefs.instance.getPin())
            : '';
        if (savedPin.isNotEmpty && pin != savedPin) {
          setState(() {
            _showError = true;
            _errorText = 'Incorrect current PIN';
          });
          return;
        }
        setState(() {
          _currentStep = _PinChangeStep.newPin;
          _showError = false;
        });
        _clearPinFields();
        break;

      case _PinChangeStep.newPin:
        _newPin = pin;
        setState(() {
          _currentStep = _PinChangeStep.confirmPin;
          _showError = false;
        });
        _clearPinFields();
        break;

      case _PinChangeStep.confirmPin:
        if (pin != _newPin) {
          setState(() {
            _showError = true;
            _errorText = "PINs don't match";
          });
          return;
        }
        await _updatePinOnServer(pin);
        break;
    }
  }

  Future<void> _updatePinOnServer(String pin) async {
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      // Resolve phone: prefer last_phone_number (stored with +91 on login),
      // fall back to nickName for legacy accounts.
      final phone = await SessionPrefs.instance.getLastPhoneNumber();
      final fallback = await SessionPrefs.instance.getNickName();
      final rawCredential = phone.isNotEmpty ? phone : fallback;

      if (rawCredential.isEmpty) {
        throw Exception('Phone number not found. Please re-login.');
      }

      // forgotPin expects +91 prefix; add it if absent.
      final credential = rawCredential.startsWith('+')
          ? rawCredential
          : '+91$rawCredential';

      debugPrint('PIN set/update: credential=$credential');
      final service = ref.read(profileAuthServiceProvider);
      final response = await service.forgotPin(
        credential: credential,
        pin: pin,
        confirmPin: pin,
      );

      debugPrint('PIN Response: $response');

      final status = response['status'] as int? ?? 0;
      final success = response['success'] as bool? ?? (status == 200);
      if (!success) {
        final message = response['message'] ?? 'Failed to set PIN';
        throw Exception(message);
      }

      await AuthPrefs.instance.setPin(pin);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasPin ? 'PIN updated successfully!' : 'PIN set successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('PIN Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorText = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    switch (_currentStep) {
      case _PinChangeStep.oldPin:
        title = 'Current PIN';
        subtitle = 'Enter your current 4 digit PIN';
        break;
      case _PinChangeStep.newPin:
        title = _hasPin ? 'New PIN' : 'Set PIN';
        subtitle = _hasPin ? 'Enter new 4 digit PIN' : 'Enter a 4 digit PIN';
        break;
      case _PinChangeStep.confirmPin:
        title = 'Confirm PIN';
        subtitle = 'Re-enter your new PIN';
        break;
    }

    return Padding(
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
              title,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Neue',
              color: AppColors.foundationBlack20,
            ),
            SizedBox(height: 12.h),
            CustomText(
              subtitle,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
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
                        ? Border.all(color: const Color(0xFFFF3B3B), width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _pinControllers[index],
                    focusNode: _pinFocusNodes[index],
                    textAlign: TextAlign.center,
                    obscureText: true,
                    keyboardType: TextInputType.number,
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
                    onChanged: (v) => _onDigitChanged(index, v),
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
              onPressed: _isLoading ? null : _onContinue,
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
                      'Continue',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foundationBlack20,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreferencesSheet extends StatefulWidget {
  @override
  State<_NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends State<_NotificationPreferencesSheet> {
  bool _likesCommentsFollow = true;
  bool _messagesCalls = true;
  bool _securityAlerts = true;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            AppStrings.notifications,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.likesCommentsFollow,
            _likesCommentsFollow,
            (val) => setState(() => _likesCommentsFollow = val),
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.messagesCalls,
            _messagesCalls,
            (val) => setState(() => _messagesCalls = val),
          ),
          SizedBox(height: 24.h),
          _buildToggleRow(
            AppStrings.securityAlerts,
            _securityAlerts,
            (val) => setState(() => _securityAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.foundationBlack20, width: 2),
              color: value ? AppColors.foundationBlack20 : Colors.transparent,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 12.sp,
                    color: AppColors.foundationBlack800,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
