import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/features/profile/presentation/user_profile.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/hiring_rates_popup.dart';
import '../../../../core/widgets/online_indicator.dart';
import '../../../../core/utils/hirer_gate.dart';
import '../../../follow/application/follow_providers.dart';
import '../../../online/application/online_providers.dart';
import '../../application/states/profile_list_state.dart';
import 'custom_follow_snackbar.dart';

class ProfileCard extends ConsumerStatefulWidget {
  final String profileId;
  final String name;
  final String role;
  final String imagePath;
  final String followers;
  final String following;
  final String views;
  final String posts;
  final String socialFollowers;
  final bool isOnline;
  final bool isProfessional;
  final List<SocialMediaFollow> socialMediaFollows;
  final int eventsDone;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onViewCharges;
  final VoidCallback? onBioTap;
  final VoidCallback? onAdd;

  const ProfileCard({
    super.key,
    required this.profileId,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.followers,
    required this.following,
    required this.views,
    required this.posts,
    required this.socialFollowers,
    this.isOnline = false,
    this.isProfessional = true,
    this.socialMediaFollows = const [],
    this.eventsDone = 0,
    this.onCall,
    this.onChat,
    this.onViewCharges,
    this.onBioTap,
    this.onAdd,
  });

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                UserProfileScreen(profileId: widget.profileId),
          ),
        );
      },
      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: Colors.white.withAlpha(12),
          border: Border.all(width: 1.w),
        ),
        child: Column(
          children: [
            // Header with image container
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                height: 160.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withAlpha(78),
                    width: 1.w,
                  ),
                  image: widget.imagePath.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(widget.imagePath),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage(widget.imagePath),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with online status and events button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Online status
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Builder(builder: (context) {
                                final onlineState =
                                    ref.watch(onlineNotifierProvider);
                                final isOnline = onlineState.userStatuses
                                        .containsKey(widget.profileId)
                                    ? onlineState
                                        .userStatuses[widget.profileId]!
                                    : widget.isOnline;
                                return Row(
                                  children: [
                                    OnlineIndicator(
                                      userId: widget.profileId,
                                      size: 10,
                                      initialIsOnline: widget.isOnline,
                                      showBorder: false,
                                      onlineColor: Colors.green,
                                      offlineColor: Colors.red,
                                    ),
                                    SizedBox(width: 6.w),
                                    CustomText(
                                      isOnline ? 'Online' : 'Offline',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                );
                              }),
                            ),

                            // Events button with count
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                gradient: AppColors.ctaBorderGradient,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    CustomText(
                                      '${widget.eventsDone}',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00D9FF),
                                    ),
                                    SizedBox(width: 4.w),
                                    CustomText(
                                      'Events',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom row with action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Like and Add buttons in one container
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Row(
                                children: [
                                  // Like button

                                  // Follow button
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final followState = ref.watch(
                                        followNotifierProvider,
                                      );
                                      final isFollowing = followState
                                          .followingIds
                                          .contains(widget.profileId);
                                      final isToggling = followState.togglingIds
                                          .contains(widget.profileId);

                                      return GestureDetector(
                                        onTap: isToggling
                                            ? null
                                            : () {
                                                if (blockIfHirer(
                                                  context,
                                                  ref,
                                                )) {
                                                  return;
                                                }
                                                ref
                                                    .read(
                                                      followNotifierProvider
                                                          .notifier,
                                                    )
                                                    .toggleFollow(
                                                      widget.profileId,
                                                    );
                                                if (!isFollowing) {
                                                  CustomFollowSnackbar.show(
                                                    context,
                                                    name: widget.name,
                                                    imagePath: widget.imagePath,
                                                  );
                                                }
                                              },
                                        child: isToggling
                                            ? SizedBox(
                                                width: 18.sp,
                                                height: 18.sp,
                                                child:
                                                    const CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Image.asset(
                                                isFollowing
                                                    ? 'assets/images/Follow.png'
                                                    : 'assets/images/Follow.png',
                                                width: 24.w,
                                                height: 24.w,
                                                color: isFollowing
                                                    ? Colors.red
                                                    : Colors.white,
                                                colorBlendMode: BlendMode.srcIn,
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
              child: Column(
                children: [
                  // Name, role and bio button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Name and role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              widget.name,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              widget.role.toUpperCase(),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),

                      // Bio button with gradient border — opens a sheet
                      // with the full bio and the profile's hiring rates.
                      GestureDetector(
                        onTap: widget.onBioTap ??
                            () => showBioAndRatesPopup(
                                  context,
                                  ref,
                                  widget.profileId,
                                ),
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            gradient: AppColors.ctaBorderGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                CustomText(
                                  'Bio',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Stats section (without vertical dividers)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withAlpha(22)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(value: widget.followers, label: 'Followers'),
                        _StatItem(value: widget.following, label: 'Following'),
                        _StatItem(value: widget.views, label: 'Views'),
                        ...widget.socialMediaFollows.take(2).map((follow) {
                          Widget iconWidget;
                          switch (follow.socialMedia.toUpperCase()) {
                            case 'FACEBOOK':
                              iconWidget = Image.asset(
                                'assets/images/facebook.png',
                                width: 20.w,
                                height: 20.w,
                                color: Colors.white,
                              );
                              break;
                            case 'INSTAGRAM':
                              iconWidget = Image.asset(
                                'assets/images/instagram.png',
                                width: 20.w,
                                height: 20.w,
                                color: Colors.white,
                              );
                              break;
                            case 'TWITTER':
                            case 'X':
                              iconWidget = Icon(
                                Icons.tag,
                                color: Colors.white,
                                size: 16.sp,
                              );
                              break;
                            case 'YOUTUBE':
                              iconWidget = Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 16.sp,
                              );
                              break;
                            default:
                              iconWidget = Icon(
                                Icons.public,
                                color: Colors.white,
                                size: 16.sp,
                              );
                          }
                          return _SocialStatItem(
                            icon: iconWidget,
                            value: follow.formattedFollowers,
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Call and Chat buttons
                  Row(
                    children: [
                      Expanded(
                        child: GradientCtaButton(
                          label: 'Call',
                          width: double.infinity,
                          height: 52,
                          onPressed: widget.onCall,
                          leading: Image.asset(
                            'assets/images/call (1).png',
                            width: 20.w,
                            height: 20.w,
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onChat,
                          child: Container(
                            height: 52.h,
                            decoration: BoxDecoration(
                              gradient: AppColors.ctaBorderGradient,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(1.w),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF05DAF1),
                                      Color(0xFFC00F8B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1F1F),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        'Chat',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.w),
                                      Image.asset(
                                        'assets/images/Comment.png',
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Divider
                  Container(
                    height: 1.h,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),

                  SizedBox(height: 24.h),

                  // View Charges button
                  GestureDetector(
                    onTap: widget.onViewCharges,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          'View Details',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Image.asset(
                          'assets/images/down-arrow.png',
                          width: 18.w,
                          height: 18.w,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          value,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        // SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _SocialStatItem extends StatelessWidget {
  final Widget icon;
  final String value;

  const _SocialStatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(child: icon),
        SizedBox(height: 2.h),
        CustomText(
          value,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class ProfileCardData {
  final String profileId;
  final String name;
  final String role;
  final String imagePath;
  final String followers;
  final String following;
  final String views;
  final String posts;
  final String socialFollowers;
  final List<SocialMediaFollow> socialMediaFollows;
  final int eventsDone;
  final bool isOnline;
  final double rating;
  final bool isProfessional;

  ProfileCardData({
    required this.profileId,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.followers,
    required this.following,
    required this.views,
    required this.posts,
    required this.socialFollowers,
    this.socialMediaFollows = const [],
    this.eventsDone = 0,
    this.isOnline = false,
    this.rating = 4.5,
    this.isProfessional = true,
  });
}

class ProfileCardGrid extends StatelessWidget {
  final List<ProfileCardData> cards;

  final bool showLoadMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final void Function(ProfileCardData card)? onCall;
  final void Function(ProfileCardData card)? onChat;

  const ProfileCardGrid({
    super.key,
    required this.cards,
    this.showLoadMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onCall,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length + (showLoadMore ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (showLoadMore && index == cards.length) {
            if (isLoadingMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 54.h,
              child: TextButton(
                onPressed: onLoadMore,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48.r),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    'Load more',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              ),
            );
          }

          final card = cards[index];
          return ProfileCard(
            profileId: card.profileId,
            name: card.name,
            role: card.role,
            imagePath: card.imagePath,
            followers: card.followers,
            following: card.following,
            views: card.views,
            posts: card.posts,
            socialFollowers: card.socialFollowers,
            socialMediaFollows: card.socialMediaFollows,
            eventsDone: card.eventsDone,
            isOnline: card.isOnline,
            isProfessional: card.isProfessional,
            onCall: onCall == null ? null : () => onCall!(card),
            onChat: onChat == null ? null : () => onChat!(card),
          );
        },
      ),
    );
  }
}
