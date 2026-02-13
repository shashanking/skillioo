import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/posts/presentation/full_post_view.dart';

import '../../../../core/widgets/custom_text.dart';

class PostViewScreen extends StatelessWidget {
  const PostViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Purple top glow
              Color(0xFF121212), // Dark middle
              Color(0xFF000000), // Black bottom
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(
                      Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    Image.asset('assets/logo_text.png', height: 70.h),
                    SizedBox(width: 34.w),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // 2. Main Post Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullPostViewScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/post-img.jpg',
                        ), // Placeholder for the singer image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Header inside Card
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage: const AssetImage(
                                    'assets/images/professional-profile.jpg',
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'Silent Sings',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    CustomText(
                                      '1M Views',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                _buildFollowButton(),
                              ],
                            ),

                            const Spacer(),

                            // Interaction Row
                            Row(
                              children: [
                                _buildIconAction(Icons.favorite_border, "10K"),
                                SizedBox(width: 20.w),
                                _buildIconAction(
                                  Icons.chat_bubble_outline,
                                  "5K",
                                ),
                                SizedBox(width: 20.w),
                                _buildIconAction(Icons.send_outlined, "2K"),
                                const Spacer(),
                                Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Post Details
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'Singer',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    CustomText(
                                      'Classical Singer',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                _buildTag("4.5 ⭐"),
                                SizedBox(width: 8.w),
                                _buildTag("Professional"),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Action Buttons (Charges, Call, Chat)
                            Row(
                              children: [
                                _buildDropdownButton("Charges"),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildGradientOutlineButton(
                                    "Call",
                                    Icons.call,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildGradientOutlineButton(
                                    "Chat",
                                    Icons.chat_bubble_outline,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Bottom Info
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      '25',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    CustomText(
                                      'Events',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.music_note,
                                  color: Colors.white70,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                CustomText(
                                  'Alan Walker - Faded',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05DAF1).withValues(alpha: 0.3),
            const Color(0xFFC00F8B).withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.add, color: Colors.white, size: 16.sp),
          SizedBox(width: 4.w),
          CustomText(
            'Follow',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        SizedBox(width: 6.w),
        CustomText(
          count,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CustomText(
        text,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDropdownButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CustomText(
            text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildGradientOutlineButton(String text, IconData icon) {
    return Stack(
      children: [
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                SizedBox(width: 8.w),
                Icon(icon, color: Colors.white, size: 16.sp),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
