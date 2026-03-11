import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/features/posts/presentation/full_post_view.dart';
import 'package:video_player/video_player.dart';

import '../../dashboard/application/states/profile_list_state.dart';
import '../../../core/widgets/custom_text.dart';
import '../../chat/application/chat_providers.dart';
import '../application/post_providers.dart';

class _PostData {
  final String image;
  final String recipientId;
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
  final bool isVideo;
  final String? mediaId;

  const _PostData({
    required this.image,
    required this.recipientId,
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
    required this.isVideo,
    this.mediaId,
  });
}

class PostViewScreen extends ConsumerStatefulWidget {
  final ProfileItem? profile;
  final List<MediaItem>? mediaItems;
  final int initialIndex;

  const PostViewScreen({
    super.key,
    this.profile,
    this.mediaItems,
    this.initialIndex = 0,
  }) : assert(profile != null || mediaItems != null);

  @override
  ConsumerState<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends ConsumerState<PostViewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manageVideos(_currentIndex);
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

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _manageVideos(index);
  }

  Future<void> _manageVideos(int currentIndex) async {
    final posts = _posts;

    // Pause all videos
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }

    // Dispose videos that are far away
    final toRemove = <int>[];
    for (final index in _videoControllers.keys) {
      if ((index - currentIndex).abs() > 2) {
        toRemove.add(index);
      }
    }
    for (final index in toRemove) {
      _videoControllers[index]?.dispose();
      _videoControllers.remove(index);
    }

    // Preload current and next videos
    if (currentIndex < posts.length && posts[currentIndex].isVideo) {
      await _preloadVideo(currentIndex);
      _videoControllers[currentIndex]?.play();
    }
    if (currentIndex + 1 < posts.length && posts[currentIndex + 1].isVideo) {
      _preloadVideo(currentIndex + 1);
    }
  }

  Future<void> _preloadVideo(int index) async {
    final posts = _posts;
    if (index >= posts.length || !posts[index].isVideo) return;
    if (_videoControllers.containsKey(index)) return;

    try {
      final mediaUrl = posts[index].image.startsWith('http://')
          ? posts[index].image.replaceFirst('http://', 'https://')
          : posts[index].image;
      final controller = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
      _videoControllers[index] = controller;
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(1.0);
      if (mounted) setState(() {});
    } catch (e) {
      _videoControllers.remove(index);
    }
  }

  List<_PostData> get _posts {
    if (widget.mediaItems != null && widget.mediaItems!.isNotEmpty) {
      return widget.mediaItems!
          .map(
            (item) => _PostData(
              image: item.mediaUrl.startsWith('http://')
                  ? item.mediaUrl.replaceFirst('http://', 'https://')
                  : item.mediaUrl,
              recipientId: item.recipientId,
              name: item.profileName,
              views: '${item.totalViews ?? 0} Views',
              avatar: item.profilePhotoUrl ?? 'assets/images/profile-img-1.jpg',
              category: item.category,
              subcategory: item.subcategory,
              rating: '0',
              type: item.proficiency,
              events: '0',
              music: '',
              likes: '${item.totalLikes ?? 0}',
              comments: '${item.totalComments ?? 0}',
              shares: '0',
              isVideo: item.isVideo,
              mediaId: item.mediaId,
            ),
          )
          .toList();
    }

    final profile = widget.profile;
    if (profile == null) return const <_PostData>[];
    final List<_PostData> items = [];
    final avatarUrl =
        profile.profilePhotoUrl ?? 'assets/images/profile-img-1.jpg';
    final proficiencyType = profile.proficiency.isNotEmpty
        ? profile.proficiency
        : 'Professional';

    for (final video in profile.videos) {
      items.add(
        _PostData(
          image: video.normalizedUrl,
          recipientId: profile.id,
          name: profile.displayName,
          views: '0 Views',
          avatar: avatarUrl,
          category: 'Creator',
          subcategory: '${profile.city}, ${profile.country}',
          rating: '0 ',
          type: proficiencyType,
          events: '0',
          music: '',
          likes: '0',
          comments: '0',
          shares: '0',
          isVideo: true,
          mediaId: video.normalizedUrl,
        ),
      );
    }

    for (final image in profile.images) {
      items.add(
        _PostData(
          image: image.normalizedUrl,
          recipientId: profile.id,
          name: profile.displayName,
          views: '0 Views',
          avatar: avatarUrl,
          category: 'Creator',
          subcategory: '${profile.city}, ${profile.country}',
          rating: '0 ',
          type: proficiencyType,
          events: '0',
          music: '',
          likes: '0',
          comments: '0',
          shares: '0',
          isVideo: false,
          mediaId: image.normalizedUrl,
        ),
      );
    }

    return items;
  }

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
                child: _posts.isEmpty
                    ? Center(
                        child: CustomText(
                          'No posts available',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      )
                    : PageView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _posts.length,
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        allowImplicitScrolling: false,
                        itemBuilder: (context, index) {
                          return _buildPostCard(context, _posts[index], index);
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

  Widget _buildPostCard(BuildContext context, _PostData post, int index) {
    return GestureDetector(
      onTap: () {
        final mediaItems = _posts
            .map(
              (p) => MediaItem(
                mediaUrl: p.image,
                isVideo: p.isVideo,
                recipientId: p.recipientId,
                profileName: p.name,
                profilePhotoUrl: p.avatar,
                category: p.category,
                subcategory: p.subcategory,
                proficiency: p.type,
                mediaId: p.mediaId,
                totalComments: int.tryParse(p.comments) ?? 0,
                totalLikes: int.tryParse(p.likes) ?? 0,
                totalViews:
                    int.tryParse(p.views.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    0,
              ),
            )
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullPostViewScreen(mediaItems: mediaItems, initialIndex: index),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background video or image
              if (post.isVideo)
                _buildVideoPlayer(index)
              else
                post.image.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: post.image,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        memCacheHeight: 1200,
                        maxWidthDiskCache: 800,
                        maxHeightDiskCache: 1200,
                        placeholder: (context, url) => Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      )
                    : Image.asset(post.image, fit: BoxFit.cover),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
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
              ),
              // Content overlay
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: post.avatar.startsWith('http')
                              ? NetworkImage(post.avatar) as ImageProvider
                              : AssetImage(post.avatar),
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
                        Consumer(
                          builder: (context, ref, _) {
                            final postState = ref.watch(postNotifierProvider);
                            final isLiked =
                                post.mediaId != null &&
                                postState.likedPostIds.contains(post.mediaId);

                            return _buildIconAction(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              post.likes,
                              color: isLiked ? Colors.red : Colors.white,
                              onTap: () {
                                if (post.mediaId != null) {
                                  ref
                                      .read(postNotifierProvider.notifier)
                                      .toggleReaction(
                                        targetId: post.mediaId!,
                                        reactionType: 'like',
                                      );
                                }
                              },
                            );
                          },
                        ),
                        SizedBox(width: 20.w),
                        GestureDetector(
                          onTap: () => context.push(
                            '/comments',
                            extra: post.mediaId ?? '',
                          ),
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
                          child: _buildGradientOutlineButton(
                            "Call",
                            Icons.call,
                            onTap: () =>
                                _handleCallTap(post.recipientId, post.name),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildGradientOutlineButton(
                            "Chat",
                            Icons.chat_bubble_outline,
                            onTap: () => _handleChatTap(post.recipientId),
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
                        Icon(
                          Icons.music_note,
                          color: Colors.white70,
                          size: 16.sp,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildVideoPlayer(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

  Widget _buildIconAction(
    IconData icon,
    String count, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 24.sp),
          SizedBox(width: 6.w),
          CustomText(
            count,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: color ?? Colors.white,
          ),
        ],
      ),
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

  void _handleCallTap(String profileId, String profileName) async {
    final success = await ref
        .read(chatNotifierProvider.notifier)
        .initiateCall(profileId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $profileName...'),
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

  void _handleChatTap(String recipientId) {
    final resolvedRecipientId = recipientId.trim();
    if (resolvedRecipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open chat for this post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(resolvedRecipientId)}',
    );
  }

  Widget _buildGradientOutlineButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGradientButton(text, icon),
    );
  }

  Widget _buildGradientButton(String text, IconData icon) {
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
