import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<ReelPost> _reels = [
    ReelPost(
      id: '1',
      imagePath: 'assets/images/professional-profile.jpg',
      creatorName: 'Alex Johnson',
      creatorRole: 'UI/UX Designer',
      creatorImage: 'assets/images/professional-profile.jpg',
      likes: '2.5K',
      comments: '342',
      shares: '128',
      description: 'Just finished an amazing design project! Check it out 🎨',
      isLiked: false,
    ),
    ReelPost(
      id: '2',
      imagePath: 'assets/images/skilled-profile.jpg',
      creatorName: 'Sarah Williams',
      creatorRole: 'Photographer',
      creatorImage: 'assets/images/skilled-profile.jpg',
      likes: '1.8K',
      comments: '256',
      shares: '95',
      description: 'Golden hour photography is the best! 📸✨',
      isLiked: false,
    ),
    ReelPost(
      id: '3',
      imagePath: 'assets/images/profile-img-1.jpg',
      creatorName: 'Mike Chen',
      creatorRole: 'Video Editor',
      creatorImage: 'assets/images/profile-img-1.jpg',
      likes: '3.2K',
      comments: '512',
      shares: '234',
      description: 'New video editing tutorial coming soon! 🎬',
      isLiked: false,
    ),
    ReelPost(
      id: '4',
      imagePath: 'assets/images/professional-profile.jpg',
      creatorName: 'Emma Davis',
      creatorRole: 'Content Creator',
      creatorImage: 'assets/images/professional-profile.jpg',
      likes: '4.1K',
      comments: '678',
      shares: '312',
      description: 'Behind the scenes of my latest content shoot 🎥',
      isLiked: false,
    ),
    ReelPost(
      id: '5',
      imagePath: 'assets/images/skilled-profile.jpg',
      creatorName: 'James Wilson',
      creatorRole: 'Brand Designer',
      creatorImage: 'assets/images/skilled-profile.jpg',
      likes: '2.9K',
      comments: '445',
      shares: '167',
      description: 'Brand identity design process explained 🎨💡',
      isLiked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _reels.length,
              itemBuilder: (context, index) {
                return ReelCard(
                  reel: _reels[index],
                  onLikeTap: () {
                    setState(() {
                      _reels[index].isLiked = !_reels[index].isLiked;
                    });
                  },
                );
              },
            ),
            Positioned(
              top: 16.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Reels',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.w,
              top: 50.h,
              bottom: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    label: _reels[_currentIndex].likes,
                    onTap: () {
                      setState(() {
                        _reels[_currentIndex].isLiked =
                            !_reels[_currentIndex].isLiked;
                      });
                    },
                    isActive: _reels[_currentIndex].isLiked,
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: _reels[_currentIndex].comments,
                    onTap: () => context.push('/comments'),
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: _reels[_currentIndex].shares,
                    onTap: () {},
                  ),
                  SizedBox(height: 24.h),
                  _buildActionButton(
                    icon: Icons.bookmark_outline,
                    label: '',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.red : Colors.white,
              size: 22.sp,
            ),
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 6.h),
            CustomText(
              label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class ReelCard extends StatelessWidget {
  final ReelPost reel;
  final VoidCallback onLikeTap;

  const ReelCard({super.key, required this.reel, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(reel.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                        image: DecorationImage(
                          image: AssetImage(reel.creatorImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            reel.creatorName,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          CustomText(
                            reel.creatorRole,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D9FF), Color(0xFF8F39B2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        'Follow',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomText(
                  reel.description,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReelPost {
  final String id;
  final String imagePath;
  final String creatorName;
  final String creatorRole;
  final String creatorImage;
  final String likes;
  final String comments;
  final String shares;
  final String description;
  bool isLiked;

  ReelPost({
    required this.id,
    required this.imagePath,
    required this.creatorName,
    required this.creatorRole,
    required this.creatorImage,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.description,
    required this.isLiked,
  });
}
