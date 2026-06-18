import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/core/services/session_prefs.dart';
import 'package:skillioo/core/services/session_state_provider.dart';
import 'package:skillioo/core/widgets/icon_button.dart';
import 'package:skillioo/features/auth/application/auth_providers.dart';
import 'package:skillioo/features/onboarding/application/onboarding_data_provider.dart';
import 'package:skillioo/features/follow/application/follow_providers.dart';
import 'package:skillioo/features/subscription/application/states/subscription_state.dart';
import 'package:skillioo/features/subscription/application/subscription_providers.dart';
import 'package:skillioo/features/subscription/presentation/subscription.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../../core/widgets/common_background.dart';
import 'my_profile.dart';

class ProfileSectionScreen extends ConsumerStatefulWidget {
  final String name;
  final String role;
  final String avatarAssetPath;
  final String avatarUrl;
  final String bio;

  /// Whether tapping the profile image/name opens the full profile-detail
  /// screen. Disabled for hirer-type users — they have no portfolio page.
  final bool allowProfileDetails;

  const ProfileSectionScreen({
    super.key,
    required this.name,
    required this.role,
    required this.avatarAssetPath,
    this.avatarUrl = '',
    this.bio = '',
    this.allowProfileDetails = true,
  });

  @override
  ConsumerState<ProfileSectionScreen> createState() =>
      _ProfileSectionScreenState();
}

class _ProfileSectionScreenState extends ConsumerState<ProfileSectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subscriptionNotifierProvider.notifier)
          .fetchPlanAggregatorAndSync();
      ref.read(followNotifierProvider.notifier).fetchFollowCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListView(
              children: [
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        'Profile Section',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Neue',
                        color: Colors.white,
                      ),
                    ),
                    IconCircleButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.allowProfileDetails
                            ? () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MyProfileScreen(
                                      isOwnProfile: true,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1.w,
                                ),
                              ),
                              child: ClipOval(
                                child: widget.avatarUrl.isNotEmpty
                                    ? Image.network(
                                        widget.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                widget.avatarAssetPath,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                      )
                                    : Image.asset(
                                        widget.avatarAssetPath,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    widget.name,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Neue',
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    widget.role.isNotEmpty
                                        ? widget.role
                                        : widget.bio,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Outfit',
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSubscriptionButton(),
                  ],
                ),
                SizedBox(height: 22.h),

                // Followers / Following counts
                Consumer(
                  builder: (context, ref, _) {
                    final followState = ref.watch(followNotifierProvider);
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCountItem(
                            '${followState.followerCount}',
                            'Followers',
                          ),
                          Container(
                            width: 1,
                            height: 30.h,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _buildCountItem(
                            '${followState.followingCount}',
                            'Following',
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Subscription Limits
                Consumer(
                  builder: (context, ref, _) {
                    final subState = ref.watch(subscriptionNotifierProvider);
                    final subscription = subState.activeSubscription;
                    final aggregator = subState.aggregator;

                    // Show only when BOTH conditions hold:
                    // 1. activeSubscription.status is ACTIVE/SUCCESS (local state).
                    // 2. aggregator.activePlans > 0 (server-side truth from payment
                    //    history). This catches cases where a cached subscription ID
                    //    restored an ACTIVE status after the plan had already expired
                    //    on the backend.
                    final subStatus = (subscription?.status ?? '').toUpperCase();
                    final hasActiveStatus =
                        subStatus == 'ACTIVE' || subStatus == 'SUCCESS';
                    final hasActivePlans = (aggregator?.activePlans ?? 0) > 0;
                    if (!hasActiveStatus || !hasActivePlans) {
                      return const SizedBox.shrink();
                    }

                    final callLimits = aggregator?.callLimits ?? 0;
                    final chatLimits = aggregator?.chatLimits ?? 0;
                    final validity = subscription?.planDetails?.validity ?? 0;

                    return Column(
                      children: [
                        SizedBox(height: 22.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCountItem('$callLimits', 'Call Limits'),
                              Container(
                                width: 1,
                                height: 30.h,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              _buildCountItem('$chatLimits', 'Chat Limits'),
                              Container(
                                width: 1,
                                height: 30.h,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              _buildCountItem('$validity days', 'Validity'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 22.h),
                CustomText(
                  'Social',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                _MenuGroup(
                  items: const [
                    _MenuItemData(icon: Icons.phone_outlined, label: 'Call'),
                    _MenuItemData(
                      assetPath: 'assets/images/Comment.png',
                      label: 'Messages',
                    ),
                  ],
                  onItemTap: (item) {
                    if (item.label == 'Call') {
                      Navigator.of(context).pop();
                      context.go('/landing?tab=4');
                    } else if (item.label == 'Messages') {
                      Navigator.of(context).pop();
                      context.go('/landing?tab=3');
                    }
                  },
                ),
                SizedBox(height: 22.h),
                CustomText(
                  'General',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                _MenuGroup(
                  items: const [
                    _MenuItemData(
                      assetPath: 'assets/images/notification-01.png',
                      label: 'Notifications',
                    ),
                    _MenuItemData(
                      assetPath: 'assets/images/security-check.png',
                      label: 'Privacy',
                    ),
                  ],
                  onItemTap: (item) {
                    Navigator.of(context).pop();
                    if (item.label == 'Notifications') {
                      context.push('/profile-notifications');
                    } else if (item.label == 'Privacy') {
                      context.push('/profile-privacy');
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      await SessionPrefs.instance.clear();
                      await ref.read(sessionStateProvider.notifier).refresh();
                      await ref.read(authNotifierProvider.notifier).reset();
                      ref.read(onboardingDataProvider.notifier).state =
                          const OnboardingData();
                      if (!context.mounted) return;
                      context.go('/start');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF990000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48.r),
                      ),
                      elevation: 0,
                    ),
                    child: CustomText(
                      'Logout',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountItem(String count, String label) {
    return Column(
      children: [
        CustomText(
          count,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: Colors.white,
        ),
        SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Outfit',
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  Widget _buildSubscriptionButton() {
    final subState = ref.watch(subscriptionNotifierProvider);
    final subscription = subState.activeSubscription;

    if (subState.subscriptionStatus == SubscriptionStatus.loading &&
        subscription == null) {
      return SizedBox(
        height: 36.h,
        child: _GradientPillButton(label: '', onTap: () {}, showLoading: true),
      );
    }

    // If subscription exists, show plan name
    if (subscription != null && subscription.planCode != null) {
      final planName = subscription.planCode!;
      final status = subscription.status ?? '';

      // Determine button label based on status
      String label;
      if (status == 'ACTIVE' || status == 'SUCCESS') {
        label = planName;
      } else if (status == 'INITIATED' || status == 'PENDING') {
        label = 'Complete Payment';
      } else if (status == 'FAILED') {
        label = '$planName (Failed)';
      } else {
        label = planName;
      }

      return _GradientPillButton(
        label: label,
        backgroundImage: 'assets/images/plan-bg.png',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          );
        },
      );
    }

    // No subscription - show Upgrade button
    return _GradientPillButton(
      label: 'Upgrade',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
        );
      },
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool showLoading;
  final String? backgroundImage;

  const _GradientPillButton({
    required this.label,
    required this.onTap,
    this.showLoading = false,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: 80.w, minHeight: 36.h),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: backgroundImage == null ? AppColors.ctaGradient : null,
          image: backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: showLoading
            ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomText(
                  label,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;
  final ValueChanged<_MenuItemData> onItemTap;

  const _MenuGroup({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++)
                _MenuItem(
                  data: items[i],
                  showDivider: false,
                  onTap: () => onItemTap(items[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData? icon;
  final String? assetPath;
  final String label;

  const _MenuItemData({this.icon, this.assetPath, required this.label})
    : assert(icon != null || assetPath != null);
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuItem({
    required this.data,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                SizedBox(
                  width: 24.w,
                  child: data.assetPath != null
                      ? Image.asset(
                          data.assetPath!,
                          width: 20.sp,
                          height: 20.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        )
                      : Icon(
                          data.icon,
                          size: 20.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    data.label,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              color: Colors.white.withValues(alpha: 0.08),
            ),
        ],
      ),
    );
  }
}
