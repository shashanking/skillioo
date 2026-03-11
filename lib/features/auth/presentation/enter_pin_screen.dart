import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/widgets/common_background.dart';
import '../../onboarding/domain/document_service.dart';
import '../../onboarding/application/onboarding_data_provider.dart';
import '../../profile/domain/profile_service.dart';
import '../application/auth_providers.dart';

class EnterPinScreen extends ConsumerStatefulWidget {
  const EnterPinScreen({super.key});

  @override
  ConsumerState<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends ConsumerState<EnterPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  bool _showError = false;
  String _errorText = 'Invalid PIN. Try again.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pinFocusNodes.isNotEmpty) {
        _pinFocusNodes.first.requestFocus();
      }
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

  String _currentPin() => _pinControllers.map((c) => c.text).join();

  void _onPinDigitChanged(int index, String value) {
    if (value.length == 1 && index < _pinFocusNodes.length - 1) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onLogin() async {
    final pin = _currentPin();
    if (pin.length != 4) {
      setState(() {
        _showError = true;
        _errorText = 'Please enter 4 digit PIN.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final onboarding = ref.read(onboardingDataProvider);
      final rawPhone = onboarding.phoneNumber;
      final phone = rawPhone.startsWith('+91')
          ? rawPhone.substring(3)
          : rawPhone;

      final service = ref.read(profileAuthServiceProvider);
      final response = await service.login(credential: phone, pin: pin);

      final success = response['success'] as bool? ?? false;
      if (!success) {
        final message = response['message'] as String? ?? 'Login failed';
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorText = message;
        });
        return;
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final profile = data['profile'] as Map<String, dynamic>? ?? {};
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        await SessionPrefs.instance.setSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          profile: profile,
        );

        await _bootstrapProfileState();
      }

      if (!mounted) return;
      GoRouter.of(context).go('/landing');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorText = e.toString();
      });
    }
  }

  Future<void> _bootstrapProfileState() async {
    try {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      final profileId = await SessionPrefs.instance.getProfileId();
      if (accessToken.isEmpty || profileId.isEmpty) return;

      final service = ProfileService();
      final response = await service.getProfile(
        profileId: profileId,
        accessToken: accessToken,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        await SessionPrefs.instance.setProfileCreated(false);
        return;
      }
      await SessionPrefs.instance.setProfileCreated(true);

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final nestedProfile = data['profile'] as Map<String, dynamic>?;
      final merged = <String, dynamic>{};

      if (nestedProfile != null) {
        final groupName = nestedProfile['groupName'] as String?;
        if (groupName != null && groupName.isNotEmpty) {
          merged['name'] = groupName;
        }

        final nickName = nestedProfile['nickName'] as String?;
        if (nickName != null && nickName.isNotEmpty) {
          merged['nickName'] = nickName;
        }

        final portfolioId = nestedProfile['portfolioId'] as String?;
        if (portfolioId != null && portfolioId.isNotEmpty) {
          merged['portfolioId'] = portfolioId;
        }

        final bio = nestedProfile['bio'] as String?;
        if (bio != null) {
          merged['bio'] = bio;
        }

        final isSubscribed = nestedProfile['isSubscribed'];
        if (isSubscribed != null) {
          merged['isSubscribed'] = isSubscribed;
        }
      } else {
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) {
          merged['name'] = name;
        }

        final nickName = data['nickName'] as String?;
        if (nickName != null && nickName.isNotEmpty) {
          merged['nickName'] = nickName;
        }

        final portfolioId = data['portfolioId'] as String?;
        if (portfolioId != null && portfolioId.isNotEmpty) {
          merged['portfolioId'] = portfolioId;
        }

        final bio = data['bio'] as String?;
        if (bio != null) {
          merged['bio'] = bio;
        }

        final isSubscribed = data['isSubscribed'];
        if (isSubscribed != null) {
          merged['isSubscribed'] = isSubscribed;
        }
      }

      final firstName =
          (data['firstName'] as String?) ??
          (nestedProfile?['firstName'] as String?);
      if (firstName != null) merged['firstName'] = firstName;
      final lastName =
          (data['lastName'] as String?) ??
          (nestedProfile?['lastName'] as String?);
      if (lastName != null) merged['lastName'] = lastName;

      final nestedPortfolio =
          nestedProfile?['portfolio'] as Map<String, dynamic>?;
      final dataPortfolio = data['portfolio'] as Map<String, dynamic>?;

      final rawTotalEvents =
          data['totalEvents'] ??
          nestedProfile?['totalEvents'] ??
          dataPortfolio?['totalEvents'] ??
          nestedPortfolio?['totalEvents'];
      int? totalEvents;
      if (rawTotalEvents is int) {
        totalEvents = rawTotalEvents;
      } else if (rawTotalEvents is double) {
        totalEvents = rawTotalEvents.toInt();
      } else if (rawTotalEvents is String) {
        totalEvents = int.tryParse(rawTotalEvents);
      }
      if (totalEvents != null) merged['totalEvents'] = totalEvents;

      if ((merged['name'] as String?) == null ||
          (merged['name'] as String?)?.isEmpty == true) {
        final computedName = [
          (merged['firstName'] as String?) ?? '',
          (merged['lastName'] as String?) ?? '',
        ].where((e) => e.trim().isNotEmpty).join(' ');
        if (computedName.isNotEmpty) {
          merged['name'] = computedName;
        }
      }

      final rawPic = data['profilePictureId'];
      if (rawPic is Map<String, dynamic>) {
        final picId = rawPic['id'] as String?;
        if (picId != null && picId.isNotEmpty) {
          merged['profilePictureId'] = picId;
        }
      } else if (rawPic is String && rawPic.isNotEmpty) {
        merged['profilePictureId'] = rawPic;
      }

      if (merged.isNotEmpty) {
        await SessionPrefs.instance.mergeProfile(merged);
      }

      await _bootstrapProfilePhotoUrl(
        accessToken: accessToken,
        profileId: profileId,
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _bootstrapProfilePhotoUrl({
    required String accessToken,
    required String profileId,
  }) async {
    try {
      final docService = DocumentService();
      final profile = await SessionPrefs.instance.getProfile();
      final expectedPicId = profile?['profilePictureId'] as String? ?? '';
      if (expectedPicId.isEmpty) return;

      final response = await docService.getDocumentsByIds(
        ids: [expectedPicId],
        accessToken: accessToken,
      );

      final success = response['success'] as bool? ?? false;
      final data = response['data'];
      if (!success || data is! List) return;

      final picked = data
          .cast<dynamic>()
          .whereType<Map<String, dynamic>>()
          .firstWhere(
            (e) => e['id'] == expectedPicId,
            orElse: () => <String, dynamic>{},
          );

      final url = picked['url'] as String? ?? '';
      if (url.isEmpty) return;

      final normalizedUrl = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;

      await SessionPrefs.instance.mergeProfile({
        'profilePhotoUrl': normalizedUrl,
      });
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinLength = _currentPin().length;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          child: Icon(
                            Icons.arrow_back,
                            color: const Color(0xFFF5F5F5),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Text(
                  'Enter your PIN',
                  style: TextStyle(
                    fontFamily: 'Neue',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Use the 4 digit PIN you set earlier.',
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
                SizedBox(
                  width: double.infinity,
                  height: 78.h,
                  child: TextButton(
                    onPressed: (_isLoading || pinLength < 4) ? null : _onLogin,
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
                        child: _isLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Login',
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
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
