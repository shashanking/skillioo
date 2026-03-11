import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/widgets/custom_text.dart';
import '../../chat/application/chat_providers.dart';
import '../application/post_providers.dart';

class MediaItem {
  final String mediaUrl;
  final bool isVideo;
  final String recipientId;
  final String profileName;
  final String? profilePhotoUrl;
  final String category;
  final String subcategory;
  final String proficiency;
  final String? mediaId;
  final int? totalComments;
  final int? totalLikes;
  final int? totalViews;

  const MediaItem({
    required this.mediaUrl,
    required this.isVideo,
    required this.recipientId,
    required this.profileName,
    this.profilePhotoUrl,
    required this.category,
    required this.subcategory,
    required this.proficiency,
    this.mediaId,
    this.totalComments,
    this.totalLikes,
    this.totalViews,
  });
}

class FullPostViewScreen extends ConsumerStatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const FullPostViewScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
  });

  // Convenience constructor for single item (backward compatibility)
  factory FullPostViewScreen.single({
    required String mediaUrl,
    required bool isVideo,
    required String recipientId,
    required String profileName,
    String? profilePhotoUrl,
    required String category,
    required String subcategory,
    required String proficiency,
    String? mediaId,
    int? totalComments,
    int? totalLikes,
    int? totalViews,
  }) {
    return FullPostViewScreen(
      mediaItems: [
        MediaItem(
          mediaUrl: mediaUrl,
          isVideo: isVideo,
          recipientId: recipientId,
          profileName: profileName,
          profilePhotoUrl: profilePhotoUrl,
          category: category,
          subcategory: subcategory,
          proficiency: proficiency,
          mediaId: mediaId,
          totalComments: totalComments,
          totalLikes: totalLikes,
          totalViews: totalViews,
        ),
      ],
      initialIndex: 0,
    );
  }

  @override
  ConsumerState<FullPostViewScreen> createState() => _FullPostViewScreenState();
}

class _FullPostViewScreenState extends ConsumerState<FullPostViewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadVideo(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _manageVideos(index);
  }

  Future<void> _manageVideos(int currentIndex) async {
    // Pause all videos
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }

    // Dispose videos that are far away
    final toRemove = <int>[];
    for (final idx in _videoControllers.keys) {
      if ((idx - currentIndex).abs() > 2) {
        toRemove.add(idx);
      }
    }
    for (final idx in toRemove) {
      _videoControllers[idx]?.dispose();
      _videoControllers.remove(idx);
    }

    // Preload current and adjacent
    await _preloadVideo(currentIndex);
    if (currentIndex > 0) _preloadVideo(currentIndex - 1);
    if (currentIndex < widget.mediaItems.length - 1) {
      _preloadVideo(currentIndex + 1);
    }

    // Play current
    final current = _videoControllers[currentIndex];
    if (current != null && current.value.isInitialized) {
      current.play();
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= widget.mediaItems.length) return;
    final item = widget.mediaItems[index];
    if (!item.isVideo) return;
    if (_videoControllers.containsKey(index)) return;

    try {
      final mediaUrl = item.mediaUrl.startsWith('http://')
          ? item.mediaUrl.replaceFirst('http://', 'https://')
          : item.mediaUrl;
      final controller = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
      _videoControllers[index] = controller;
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(1.0);
      if (mounted && index == _currentIndex) {
        setState(() {});
        controller.play();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          return _buildMediaPage(widget.mediaItems[index], index);
        },
      ),
    );
  }

  Widget _buildMediaPage(MediaItem item, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full Screen Media (Video or Image)
        if (item.isVideo)
          _buildVideoPlayer(index)
        else
          CachedNetworkImage(
            imageUrl: item.mediaUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black,
              child: const Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: 48,
              ),
            ),
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
          bottom: 120.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRightSideProfile(item),
              SizedBox(height: 24.h),
              Consumer(
                builder: (context, ref, _) {
                  final postState = ref.watch(postNotifierProvider);
                  final isLiked =
                      item.mediaId != null &&
                      postState.likedPostIds.contains(item.mediaId);

                  return _buildRightSideAction(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    _formatCount(item.totalLikes ?? 0),
                    color: isLiked ? Colors.red : Colors.white,
                    onTap: () {
                      if (item.mediaId != null) {
                        ref
                            .read(postNotifierProvider.notifier)
                            .toggleReaction(
                              targetId: item.mediaId!,
                              reactionType: 'like',
                            );
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () =>
                    context.push('/comments', extra: item.mediaId ?? ''),
                child: _buildRightSideAction(
                  Icons.chat_bubble_outline,
                  _formatCount(item.totalComments ?? 0),
                ),
              ),
              SizedBox(height: 20.h),
              _buildRightSideAction(Icons.send_outlined, ''),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () =>
                    context.push('/comments', extra: item.mediaId ?? ''),
                child: _buildRightSideAction(Icons.message, 'Send'),
              ),
              SizedBox(height: 20.h),
              _buildRightSideAction(Icons.bookmark_border, ""),
            ],
          ),
        ),

        // 5. Bottom Content Layer
        Positioned(
          left: 20.w,
          right: 80.w,
          bottom: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name and Views
              Row(
                children: [
                  CustomText(
                    item.profileName,
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
                '${_formatCount(item.totalViews ?? 0)} Views',
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
                        item.category,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      CustomText(
                        item.subcategory,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildTag(item.proficiency),

              SizedBox(height: 20.h),

              // Buttons Row
              Row(
                children: [
                  _buildDropdownButton("Charges"),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      "Call",
                      Icons.call,
                      onTap: () => _handleCallTap(item),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      "Chat",
                      Icons.chat_bubble_outline,
                      onTap: () => _handleChatTap(item),
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
    );
  }

  // --- Helper Widgets ---

  Widget _buildVideoPlayer(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

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

  Widget _buildRightSideProfile(MediaItem item) {
    final photoUrl = item.profilePhotoUrl;
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
        color: Colors.white24,
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? const Icon(Icons.person, color: Colors.white)
          : null,
    );
  }

  Widget _buildRightSideAction(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 30.sp),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.white,
            ),
          ],
        ],
      ),
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

  void _handleCallTap(MediaItem item) async {
    final recipientId = item.recipientId;
    final success = await ref
        .read(chatNotifierProvider.notifier)
        .initiateCall(recipientId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $recipientId...'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to initiate call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleChatTap(MediaItem item) {
    final recipientId = item.recipientId.trim();
    if (recipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open chat for this post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(recipientId)}',
    );
  }

  Widget _buildGradientOutlineButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
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
                  Icon(icon, color: Colors.white, size: 18.sp),
                ],
              ),
            ),
          ),
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF05DAF1).withValues(alpha: 0.6),
                  const Color(0xFFC00F8B).withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
