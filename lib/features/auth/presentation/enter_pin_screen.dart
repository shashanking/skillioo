import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/core/widgets/gradient_cta_button.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
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
      // Backend expects the credential exactly as it was set on the profile,
      // i.e. with the +91 prefix for phone-number based logins.
      final rawPhone = onboarding.phoneNumber;
      final credential = rawPhone.startsWith('+')
          ? rawPhone
          : '+91${rawPhone.replaceFirst(RegExp(r'^\+?91'), '')}';

      final service = ref.read(profileAuthServiceProvider);
      final response = await service.login(credential: credential, pin: pin);

      final success = response['success'] as bool? ?? false;
      if (!success) {
        // Only show "Invalid credentials" when the login fails for wrong phone or pin.
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorText = 'Invalid credentials';
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

        // Keep the credential phone around for downstream flows
        // (subscription init, settings PIN update — those use phone as
        // the lookup key on the backend).
        await SessionPrefs.instance.setLastPhoneNumber(credential);

        await _bootstrapProfileState();
        // Refresh reactive session state so providers reflect logged-in user
        await ref.read(sessionStateProvider.notifier).refresh();
      }

      if (!mounted) return;
      // Only fully-onboarded creators land on the dashboard. Anyone else
      // (PIN set but profile not finished) goes to the options/menu page
      // so they can complete onboarding.
      final isCreator = profile['isCreator'] as bool? ?? false;
      GoRouter.of(context).go(isCreator ? '/landing' : '/options');
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

      // Save portfolio fields (category, proficiency, profileType, etc.)
      final nestedPortfolioForMerge =
          nestedProfile?['portfolio'] as Map<String, dynamic>? ??
          data['portfolio'] as Map<String, dynamic>? ??
          {};
      final category =
          (data['category'] as String?) ??
          (nestedProfile?['category'] as String?) ??
          (nestedPortfolioForMerge['category'] as String?);
      if (category != null && category.isNotEmpty) {
        merged['category'] = category;
      }
      final proficiency =
          (data['proficiency'] as String?) ??
          (nestedProfile?['proficiency'] as String?) ??
          (nestedPortfolioForMerge['proficiency'] as String?);
      if (proficiency != null && proficiency.isNotEmpty) {
        merged['proficiency'] = proficiency;
      }
      final profileType =
          (data['profileType'] as String?) ??
          (nestedProfile?['profileType'] as String?);
      if (profileType != null && profileType.isNotEmpty) {
        merged['profileType'] = profileType;
      }
      if (nestedPortfolioForMerge.isNotEmpty) {
        merged['portfolio'] = nestedPortfolioForMerge;
      }

      final rawPic =
          data['profilePictureId'] ?? nestedProfile?['profilePictureId'];
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
                Builder(builder: (context) {
                  final phone =
                      ref.watch(onboardingDataProvider).phoneNumber;
                  return Text(
                    phone.isNotEmpty
                        ? 'Logging in as $phone'
                        : 'Use the 4 digit PIN you set earlier.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFF5F5F5),
                    ),
                  );
                }),
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
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => GoRouter.of(context).push('/forgot-pin'),
                  child: Text(
                    'Forgot PIN?',
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
                const Spacer(),
                GradientCtaButton(
                  label: _isLoading ? 'Loading' : 'Login',
                  width: double.infinity,
                  height: 58,
                  enabled: !_isLoading && pinLength >= 4,
                  onPressed: _isLoading || pinLength < 4 ? null : _onLogin,
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
