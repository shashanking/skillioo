import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/posts/presentation/comments_view.dart';

import '../../../../core/widgets/custom_text.dart';

class FullPostViewScreen extends StatelessWidget {
  const FullPostViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Image
          Image.asset(
            'assets/images/post-img.jpg', // Replace with your singer image
            fit: BoxFit.cover,
          ),

          // 2. Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 3. Top Back Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: _buildCircleButton(
              Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // 4. Right Side Action Bar
          Positioned(
            right: 16.w,
            bottom: 120.h, // Adjusted to sit above the bottom content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRightSideProfile(),
                SizedBox(height: 24.h),
                _buildRightSideAction(Icons.favorite_border, "10K"),
                SizedBox(height: 20.h),
                _buildRightSideAction(Icons.chat_bubble_outline, "5K"),
                SizedBox(height: 20.h),
                _buildRightSideAction(Icons.send_outlined, "2K"),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CommentsScreen(),
                      ),
                    );
                  },
                  child: _buildRightSideAction(Icons.message, "Send"),
                ),
                SizedBox(height: 20.h),
                _buildRightSideAction(Icons.bookmark_border, ""),
              ],
            ),
          ),

          // 5. Bottom Content Layer
          Positioned(
            left: 20.w,
            right: 80.w, // Leave space for right actions
            bottom: 40.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name and Views
                Row(
                  children: [
                    CustomText(
                      'Silent Sings',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12.w),
                    _buildFollowButtonSmall(),
                  ],
                ),
                SizedBox(height: 4.h),
                CustomText(
                  '1M Views',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),

                SizedBox(height: 16.h),

                // Title and Tags
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
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildTag("4.5 ⭐"),
                    SizedBox(width: 8.w),
                    _buildTag("Professional"),
                  ],
                ),

                SizedBox(height: 20.h),

                // Buttons Row
                Row(
                  children: [
                    _buildDropdownButton("Charges"),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildGradientOutlineButton("Call", Icons.call),
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

                // Footer
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
                    Icon(Icons.music_note, color: Colors.white70, size: 16.sp),
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
        ],
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
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildRightSideProfile() {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/images/professional-profile.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRightSideAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30.sp),
        if (label.isNotEmpty) ...[
          SizedBox(height: 4.h),
          CustomText(
            label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildFollowButtonSmall() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
          Icon(Icons.add, color: Colors.white, size: 14.sp),
          SizedBox(width: 4.w),
          CustomText(
            'Follow',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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
        color: Colors.white.withValues(alpha: 0.2),
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
