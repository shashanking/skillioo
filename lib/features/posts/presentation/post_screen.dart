import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/features/posts/presentation/full_post_view.dart';

import '../../../../core/widgets/custom_text.dart';

class _PostData {
  final String image;
  final String name;
  final String views;
  final String avatar;
  final String category;
  final String subcategory;
  final String rating;
  final String type;
  final String events;
  final String music;
  final String likes;
  final String comments;
  final String shares;

  const _PostData({
    required this.image,
    required this.name,
    required this.views,
    required this.avatar,
    required this.category,
    required this.subcategory,
    required this.rating,
    required this.type,
    required this.events,
    required this.music,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

class PostViewScreen extends StatelessWidget {
  const PostViewScreen({super.key});

  static const List<_PostData> _posts = [
    _PostData(
      image: 'assets/images/post-img.jpg',
      name: 'Silent Sings',
      views: '1M Views',
      avatar: 'assets/images/professional-profile.jpg',
      category: 'Singer',
      subcategory: 'Classical Singer',
      rating: '4.5 ⭐',
      type: 'Professional',
      events: '25',
      music: 'Alan Walker - Faded',
      likes: '10K',
      comments: '5K',
      shares: '2K',
    ),
    _PostData(
      image: 'assets/images/skilled-profile.jpg',
      name: 'Sam Basketer',
      views: '500K Views',
      avatar: 'assets/images/skilled-profile.jpg',
      category: 'Dancer',
      subcategory: 'Hip Hop Dancer',
      rating: '4.8 ⭐',
      type: 'Skilled',
      events: '12',
      music: 'Ed Sheeran - Shape of You',
      likes: '8K',
      comments: '3K',
      shares: '1.5K',
    ),
    _PostData(
      image: 'assets/images/profile-img-1.jpg',
      name: 'Lisa Dancer',
      views: '2M Views',
      avatar: 'assets/images/profile-img-1.jpg',
      category: 'Photographer',
      subcategory: 'Portrait Photographer',
      rating: '4.9 ⭐',
      type: 'Professional',
      events: '40',
      music: 'Imagine Dragons - Believer',
      likes: '15K',
      comments: '7K',
      shares: '4K',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF121212), Color(0xFF000000)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(context, _posts[index]);
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, _PostData post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FullPostViewScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          image: DecorationImage(
            image: AssetImage(post.image),
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: AssetImage(post.avatar),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          post.name,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        CustomText(
                          post.views,
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
                Row(
                  children: [
                    _buildIconAction(Icons.favorite_border, post.likes),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () => context.push('/comments'),
                      child: _buildIconAction(
                        Icons.chat_bubble_outline,
                        post.comments,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    _buildIconAction(Icons.send_outlined, post.shares),
                    const Spacer(),
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          post.category,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        CustomText(
                          post.subcategory,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildTag(post.rating),
                    SizedBox(width: 8.w),
                    _buildTag(post.type),
                  ],
                ),
                SizedBox(height: 20.h),
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
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          post.events,
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
                      post.music,
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
