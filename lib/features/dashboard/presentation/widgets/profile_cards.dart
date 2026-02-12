import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/profile/presentation/user_profile.dart';

import '../../../../core/widgets/custom_text.dart';
import 'custom_follow_snackbar.dart';

class ProfileCard extends StatefulWidget {
  final String name;
  final String role;
  final String imagePath;
  final String followers;
  final String following;
  final String views;
  final String posts;
  final String socialFollowers;
  final double rating;
  final bool isOnline;
  final bool isProfessional;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onViewCharges;
  final VoidCallback? onBioTap;
  final VoidCallback? onAdd;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.followers,
    required this.following,
    required this.views,
    required this.posts,
    required this.socialFollowers,
    this.rating = 4.5,
    this.isOnline = false,
    this.isProfessional = true,
    this.onCall,
    this.onChat,
    this.onViewCharges,
    this.onBioTap,
    this.onAdd,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => UserProfileScreen()));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: const Color(0xFF1F1F1F),
          border: Border.all(color: const Color(0xFF2F2F2F), width: 1.w),
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
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.w,
                  ),
                  image: DecorationImage(
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
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: widget.isOnline
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  CustomText(
                                    widget.isOnline ? 'Online' : 'Offline',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isOnline
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ],
                              ),
                            ),

                            // Events button
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFF00D9FF),
                                  width: 1.w,
                                ),
                              ),
                              child: CustomText(
                                'Events',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom row with rating and action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  CustomText(
                                    widget.rating.toString(),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.star,
                                    color: const Color(0xFFFFB800),
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),

                            // Like and Add buttons in one container
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Row(
                                children: [
                                  // Like button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    },
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  // Add button
                                  GestureDetector(
                                    onTap: () {
                                      widget.onAdd?.call();
                                      // Show custom snackbar
                                      CustomFollowSnackbar.show(
                                        context,
                                        name: widget.name,
                                        imagePath: widget.imagePath,
                                      );
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              widget.role,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),

                      // Bio button with gradient border
                      GestureDetector(
                        onTap: widget.onBioTap,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D9FF), Color(0xFF8F39B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(18.r),
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
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(value: widget.followers, label: 'Followers'),
                        _StatItem(value: widget.following, label: 'Following'),
                        _StatItem(value: widget.views, label: 'Views'),
                        _SocialStatItem(
                          icon: Icons.facebook,
                          value: widget.posts,
                        ),
                        _SocialStatItem(
                          icon: Icons.camera_alt,
                          value: widget.socialFollowers,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Call and Chat buttons
                  Row(
                    children: [
                      // Call button with gradient background and opacity
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onCall,
                          child: Container(
                            height: 52.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF00D9FF,
                                  ).withValues(alpha: 0.6),
                                  const Color(
                                    0xFF8F39B2,
                                  ).withValues(alpha: 0.6),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(26.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                CustomText(
                                  'Call',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Chat button with gradient border only
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onChat,
                          child: Container(
                            height: 52.h,
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8F39B2), Color(0xFF00D9FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(26.r),
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
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ],
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

                  SizedBox(height: 16.h),

                  // View Charges button
                  GestureDetector(
                    onTap: widget.onViewCharges,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          'View Charges',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
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
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _SocialStatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _SocialStatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(height: 4.h),
        CustomText(
          value,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class ProfileCardData {
  final String name;
  final String role;
  final String imagePath;
  final String followers;
  final String following;
  final String views;
  final String posts;
  final String socialFollowers;
  final double rating;
  final bool isOnline;
  final bool isProfessional;

  ProfileCardData({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.followers,
    required this.following,
    required this.views,
    required this.posts,
    required this.socialFollowers,
    this.rating = 4.5,
    this.isOnline = false,
    required this.isProfessional,
  });
}

class ProfileCardGrid extends StatelessWidget {
  final List<ProfileCardData> cards;

  const ProfileCardGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final card = cards[index];
          return ProfileCard(
            name: card.name,
            role: card.role,
            imagePath: card.imagePath,
            followers: card.followers,
            following: card.following,
            views: card.views,
            posts: card.posts,
            socialFollowers: card.socialFollowers,
            rating: card.rating,
            isOnline: card.isOnline,
            isProfessional: card.isProfessional,
          );
        },
      ),
    );
  }
}
