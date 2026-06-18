import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/instagram_scroll_physics.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../core/services/video_controller_registry.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/login_required_dialog.dart';
import '../../../core/utils/call_utils.dart';
import '../../../core/utils/hirer_gate.dart';
import '../../../core/widgets/hiring_rates_popup.dart';
import '../../follow/application/follow_providers.dart';
import '../../profile/presentation/user_profile.dart';
import '../application/post_providers.dart';
import 'widgets/share_post_bottom_sheet.dart';

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
  final String description;

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
    this.description = '',
  });
}

class FullPostViewScreen extends ConsumerStatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final bool fromProfileDetails;

  const FullPostViewScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.fromProfileDetails = false,
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
    String description = '',
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
          description: description,
        ),
      ],
      initialIndex: 0,
    );
  }

  @override
  ConsumerState<FullPostViewScreen> createState() => _FullPostViewScreenState();
}

class _FullPostViewScreenState extends ConsumerState<FullPostViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool get isAnonymous => ref.read(isAnonymousProvider);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadVideo(_currentIndex);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _slideController.forward();
      });
      // Ensure follow state is accurate for the initial item's profile.
      final initialItem = widget.mediaItems.isNotEmpty
          ? widget.mediaItems[widget.initialIndex]
          : null;
      if (initialItem != null && initialItem.recipientId.isNotEmpty) {
        ref
            .read(followNotifierProvider.notifier)
            .checkIfFollowing(initialItem.recipientId);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      VideoControllerRegistry.instance.unregister(controller);
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
    setState(() {
      _currentIndex = index;
    });
    _slideController.reset();
    _manageVideos(index);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideController.forward();
    });
    // Keep follow state accurate as the user swipes through profiles.
    if (index < widget.mediaItems.length) {
      final profileId = widget.mediaItems[index].recipientId;
      if (profileId.isNotEmpty) {
        ref.read(followNotifierProvider.notifier).checkIfFollowing(profileId);
      }
    }
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
      final c = _videoControllers[idx];
      if (c != null) {
        VideoControllerRegistry.instance.unregister(c);
        c.dispose();
      }
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
      VideoControllerRegistry.instance.register(controller);
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
    // Watch once at the top of build to subscribe; sub-methods use the field below.
    ref.watch(isAnonymousProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        physics: const InstagramPageScrollPhysics(),
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
              child: Center(
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
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/arrow-left.png',
                  color: Colors.white,
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
            ),
          ),
        ),

        // 4. Right Side Action Bar
        Positioned(
          right: 16.w,
          bottom: 0.27.sh,
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
                  final currentPost = item.mediaId == null
                      ? null
                      : postState.feedPosts
                            .where((p) => p.id == item.mediaId)
                            .firstOrNull;
                  final likeCount =
                      currentPost?.reach?.reactionCount?['total'] as int? ??
                      item.totalLikes ??
                      0;

                  return _buildRightSideAction(
                    assetPath: 'assets/images/like.png',
                    label: _formatCount(likeCount),
                    tintColor: isLiked ? Colors.red : Colors.white,
                    onTap: isAnonymous
                        ? () =>
                              showLoginRequiredDialog(context, feature: 'likes')
                        : () {
                            if (blockIfHirer(context, ref)) return;
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
              Consumer(
                builder: (context, ref, _) {
                  final postState = ref.watch(postNotifierProvider);
                  final commentCount =
                      item.mediaId != null &&
                          postState.commentsTargetId == item.mediaId
                      ? postState.comments.length
                      : item.totalComments ?? 0;

                  return GestureDetector(
                    onTap: isAnonymous
                        ? () => showLoginRequiredDialog(
                            context,
                            feature: 'comments',
                          )
                        : () => context.push(
                            '/comments',
                            extra: item.mediaId ?? '',
                          ),
                    child: _buildRightSideAction(
                      assetPath: 'assets/images/Comment.png',
                      label: _formatCount(commentCount),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: isAnonymous
                    ? () => showLoginRequiredDialog(
                        context,
                        feature: 'sending posts',
                      )
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                          ),
                          builder: (context) {
                            final String postUrl =
                                'https://skillioo.in/post/${item.mediaId}'
                                '?src=${Uri.encodeComponent(item.mediaUrl)}'
                                '&t=${item.isVideo ? 'video' : 'image'}'
                                '&uid=${Uri.encodeComponent(item.recipientId)}'
                                '&name=${Uri.encodeComponent(item.profileName)}'
                                '&avatar=${Uri.encodeComponent(item.profilePhotoUrl ?? '')}'
                                '&cat=${Uri.encodeComponent(item.category)}'
                                '&sub=${Uri.encodeComponent(item.subcategory)}'
                                '&pro=${Uri.encodeComponent(item.proficiency)}';
                            return SharePostBottomSheet(postUrl: postUrl);
                          },
                        );
                      },
                child: _buildRightSideAction(
                  assetPath: 'assets/images/Share.png',
                  label: 'Send',
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  // Platform share
                  final String postUrl =
                      'https://skillioo.in/post/${item.mediaId}'
                      '?src=${Uri.encodeComponent(item.mediaUrl)}'
                      '&t=${item.isVideo ? 'video' : 'image'}'
                      '&uid=${Uri.encodeComponent(item.recipientId)}'
                      '&name=${Uri.encodeComponent(item.profileName)}'
                      '&avatar=${Uri.encodeComponent(item.profilePhotoUrl ?? '')}'
                      '&cat=${Uri.encodeComponent(item.category)}'
                      '&sub=${Uri.encodeComponent(item.subcategory)}'
                      '&pro=${Uri.encodeComponent(item.proficiency)}';
                  Share.share(
                    'Check out this amazing post on Skillioo!\n\n$postUrl',
                    subject: 'Share Post',
                  );
                },
                child: _buildRightSideAction(
                  assetPath: 'assets/images/Whatsapp Share.png',
                  label: 'Share',
                ),
              ),
            ],
          ),
        ),

        // 5. Bottom Content Layer
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description — slides up after 0.5s
              if (item.description.isNotEmpty)
                SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: CustomText(
                        item.description,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

              if (item.description.isNotEmpty) SizedBox(height: 12.h),

              // Name and Views
              Row(
                children: [
                  GestureDetector(
                    onTap: (isAnonymous || widget.fromProfileDetails)
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(
                                  profileId: item.recipientId,
                                ),
                              ),
                            ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          item.profileName,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          '${_formatCount(item.totalViews ?? 0)} Views',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  if (!isAnonymous) _buildFollowButtonSmall(item.recipientId),
                ],
              ),

              SizedBox(height: 16.h),

              // Category, subcategory, and proficiency
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          item.category,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        if (item.subcategory.isNotEmpty)
                          CustomText(
                            item.subcategory,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),
                  _buildTag(item.proficiency),
                ],
              ),

              SizedBox(height: 12.h),

              // Buttons Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => showHiringRatesPopup(context, ref, item.recipientId),
                    child: _buildDropdownButton("Charges"),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      "Call",
                      'assets/icons/call.svg',
                      onTap: isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'calls',
                            )
                          : () => _handleCallTap(item),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      "Chat",
                      'assets/icons/message.svg',
                      onTap: isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'chat',
                            )
                          : () => _handleChatTap(item),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
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
        child: Center(
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

  Widget _buildRightSideAction({
    required String assetPath,
    required String label,
    VoidCallback? onTap,
    Color? tintColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            assetPath,
            width: 24.sp,
            height: 24.sp,
            color: tintColor,
            colorBlendMode: BlendMode.srcIn,
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: tintColor ?? Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowButtonSmall(String profileId) {
    return Consumer(
      builder: (context, ref, _) {
        final followState = ref.watch(followNotifierProvider);
        final isFollowing = followState.followingIds.contains(profileId);
        final isToggling = followState.togglingIds.contains(profileId);

        return GestureDetector(
          onTap: isToggling
              ? null
              : () {
                  if (blockIfHirer(context, ref)) return;
                  ref
                      .read(followNotifierProvider.notifier)
                      .toggleFollow(profileId);
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48.r),
              gradient: AppColors.ctaGradient,
            ),
            child: isToggling
                ? SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFollowing ? Icons.check : Icons.add,
                        color: const Color(0xFFF5F5F5),
                        size: 16.sp,
                      ),
                      SizedBox(width: 10.w),
                      CustomText(
                        isFollowing ? 'Following' : 'Follow',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                        color: const Color(0xFFF5F5F5),
                      ),
                    ],
                  ),
          ),
        );
      },
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
      height: 44.h,
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
    final success = await initiateCallWithSubscriptionCheck(
      context: context,
      ref: ref,
      recipientId: item.recipientId,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${item.recipientId}...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleChatTap(MediaItem item) async {
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

    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !mounted) return;

    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(recipientId)}',
    );
  }

  Widget _buildGradientOutlineButton(
    String text,
    String assetPath, {
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
              color: Colors.transparent,
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
                  SvgPicture.asset(
                    assetPath,
                    width: 16.w,
                    height: 16.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.ctaBorderGradient.createShader(bounds),
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
      ),
    );
  }
}
