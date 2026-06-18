import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../application/privacy_provider.dart';
import '../../domain/privacy_models.dart';

enum _SaveState { idle, saving, success }

class ProfilePrivacyScreen extends ConsumerStatefulWidget {
  const ProfilePrivacyScreen({super.key});

  @override
  ConsumerState<ProfilePrivacyScreen> createState() =>
      _ProfilePrivacyScreenState();
}

class _ProfilePrivacyScreenState extends ConsumerState<ProfilePrivacyScreen> {
  int? _selected;
  int? _initialSelection;
  _SaveState _saveState = _SaveState.idle;

  bool get _hasChanges => _selected != _initialSelection;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    setState(() {
    });

    try {
      final userId = await SessionPrefs.instance.getProfileId();
      if (userId.isEmpty) {
        setState(() {
        });
        return;
      }

      final service = ref.read(privacyServiceProvider);
      final token = await SessionPrefs.instance.getAccessToken();
      if (token.isNotEmpty) {
        service.setAuthToken(token);
      }

      final response = await service.getPrivacy(userReferenceId: userId);
      final status = response['status'] as int? ?? 0;
      final data = response['data'];

      if (status == 200 && data is Map) {
        final privacy = PrivacyResponse.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Map privacy type to index: PUBLIC=0, FOLLOWERS=1, PRIVATE=2
        int? index;
        switch (privacy.type) {
          case 'PUBLIC':
            index = 0;
            break;
          case 'FOLLOWERS':
            index = 1;
            break;
          case 'PRIVATE':
            index = 2;
            break;
        }

        setState(() {
          _selected = index;
          _initialSelection = index;
        });
      } else {
        // Privacy not found, will create on save
        setState(() {
        });
      }
    } catch (e) {
      setState(() {
      });
    }
  }

  Future<void> _onSave() async {
    if (_saveState == _SaveState.saving || !_hasChanges || _selected == null)
      return;

    setState(() => _saveState = _SaveState.saving);

    try {
      final userId = await SessionPrefs.instance.getProfileId();
      if (userId.isEmpty) {
        if (mounted) {
          setState(() => _saveState = _SaveState.idle);
        }
        return;
      }

      // Map index to privacy type: 0=PUBLIC, 1=FOLLOWERS, 2=PRIVATE
      String privacyType;
      switch (_selected) {
        case 0:
          privacyType = 'PUBLIC';
          break;
        case 1:
          privacyType = 'FOLLOWERS';
          break;
        case 2:
          privacyType = 'PRIVATE';
          break;
        default:
          privacyType = 'PUBLIC';
      }

      final service = ref.read(privacyServiceProvider);
      final token = await SessionPrefs.instance.getAccessToken();
      if (token.isNotEmpty) {
        service.setAuthToken(token);
      }

      // Update privacy (privacy is auto-created on profile creation)
      final response = await service.updatePrivacy(type: privacyType);

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        if (!mounted) return;
        setState(() {
          _saveState = _SaveState.success;
          _initialSelection = _selected;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _saveState = _SaveState.idle);
          }
        });
      } else {
        if (!mounted) return;
        setState(() => _saveState = _SaveState.idle);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveState = _SaveState.idle);
    }
  }

  String _buttonLabel() {
    final tr = ref.tr;
    switch (_saveState) {
      case _SaveState.idle:
        return tr.saveChanges;
      case _SaveState.saving:
        return tr.saving;
      case _SaveState.success:
        return tr.changesSaved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final options = [tr.publicOption, tr.friendsOption, tr.privateOption];
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
                      tr.privacy,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Options
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    children: [
                      ...List.generate(options.length, (index) {
                        final isSelected = _selected == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = isSelected ? null : index;
                              _saveState = _SaveState.idle;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  options[index],
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.foundationBlack20,
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.glassWhite50
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.glassWhite50
                                          : AppColors.foundationBlack80,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      // Save button (visible when changes made or showing success)
                      if (_hasChanges || _saveState == _SaveState.success)
                        SizedBox(
                          width: double.infinity,
                          height: 58.h,
                          child: Stack(
                            children: [
                              // Border gradient
                              Positioned.fill(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    gradient: _saveState == _SaveState.success
                                        ? null
                                        : (_saveState == _SaveState.saving
                                              ? AppColors.ctaGradientDeactivated
                                              : AppColors.ctaBorderGradient),
                                    color: _saveState == _SaveState.success
                                        ? AppColors.foundationGreenNormal
                                        : null,
                                    borderRadius: BorderRadius.circular(48.r),
                                  ),
                                ),
                              ),
                              // Black inset
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.all(1.2.w),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      (48.r - 1.2.w).clamp(
                                        0.0,
                                        double.infinity,
                                      ),
                                    ),
                                    child: Container(color: Colors.black),
                                  ),
                                ),
                              ),
                              // Content
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: _onSave,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      gradient: _saveState == _SaveState.success
                                          ? null
                                          : (_saveState == _SaveState.saving
                                                ? AppColors
                                                      .ctaGradientDeactivated
                                                : AppColors.ctaGradient),
                                      color: _saveState == _SaveState.success
                                          ? AppColors.foundationGreenNormal
                                          : null,
                                      borderRadius: BorderRadius.circular(
                                        (48.r - 2.6.w).clamp(
                                          0.0,
                                          double.infinity,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: CustomText(
                                      _buttonLabel(),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.foundationBlack20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
}
