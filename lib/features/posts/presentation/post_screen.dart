import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/features/posts/presentation/full_post_view.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../dashboard/application/states/profile_list_state.dart';
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
  final String description;

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
    this.description = '',
  });
}

class PostViewScreen extends ConsumerStatefulWidget {
  final ProfileItem? profile;
  final List<MediaItem>? mediaItems;
  final int initialIndex;
  final bool fromProfileDetails;

  const PostViewScreen({
    super.key,
    this.profile,
    this.mediaItems,
    this.initialIndex = 0,
    this.fromProfileDetails = false,
  }) : assert(profile != null || mediaItems != null);

  @override
  ConsumerState<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends ConsumerState<PostViewScreen> {
  late ScrollController _scrollController;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Set<int> _visibleIndices = {};

  bool get isAnonymous => ref.read(isAnonymousProvider);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll to the initial item
      if (widget.initialIndex > 0) {
        final offset = widget.initialIndex * (460.h + 20.w);
        _scrollController.jumpTo(offset);
      }
      // Preload first few videos
      final posts = _posts;
      for (var i = widget.initialIndex;
          i < (widget.initialIndex + 3).clamp(0, posts.length);
          i++) {
        if (posts[i].isVideo) _preloadVideo(i);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _videoControllers.values) {
      VideoControllerRegistry.instance.unregister(controller);
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  void _onVisibilityChanged(int index, VisibilityInfo info) {
    final fraction = info.visibleFraction;
    final controller = _videoControllers[index];

    if (fraction > 0.5) {
      _visibleIndices.add(index);
      // Play and unmute when more than half visible
      if (controller != null && controller.value.isInitialized) {
        if (!controller.value.isPlaying) controller.play();
        controller.setVolume(1.0);
      } else {
        _preloadVideo(index);
      }
      // Preload next video
      final posts = _posts;
      if (index + 1 < posts.length && posts[index + 1].isVideo) {
        _preloadVideo(index + 1);
      }
    } else {
      _visibleIndices.remove(index);
      // Pause and mute when less than half visible
      if (controller != null && controller.value.isInitialized) {
        if (controller.value.isPlaying) controller.pause();
        controller.setVolume(0.0);
      }
    }

    // Dispose controllers far from any visible item
    final toRemove = <int>[];
    final anchor = _visibleIndices.isEmpty
        ? index
        : _visibleIndices.first;
    for (final idx in _videoControllers.keys) {
      if ((idx - anchor).abs() > 3) {
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
      VideoControllerRegistry.instance.register(controller);
      await controller.initialize();
      controller.setLooping(true);
      // Start muted — visibility callback will unmute if on screen
      controller.setVolume(0.0);
      if (mounted) {
        setState(() {});
        // If this video is already visible, play it
        if (_visibleIndices.contains(index)) {
          controller.play();
          controller.setVolume(1.0);
        }
      }
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
              description: item.description,
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
    final categoryLabel = profile.category.isNotEmpty
        ? profile.category.toUpperCase()
        : 'CATEGORY';

    for (final video in profile.videos) {
      items.add(
        _PostData(
          image: video.normalizedUrl,
          recipientId: profile.id,
          name: profile.displayName,
          views: '0 Views',
          avatar: avatarUrl,
          category: categoryLabel,
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
          category: categoryLabel,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
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
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: _posts.length,
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
    return VisibilityDetector(
      key: Key('post-card-$index'),
      onVisibilityChanged: post.isVideo
          ? (info) => _onVisibilityChanged(index, info)
          : null,
      child: GestureDetector(
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
                description: p.description,
              ),
            )
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPostViewScreen(
              mediaItems: mediaItems,
              initialIndex: index,
              fromProfileDetails: widget.fromProfileDetails,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Media card with glassy header overlay ---
            SizedBox(
              height: 460.h,
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
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white),
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
                    // Top glassy overlay for profile info
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: post.avatar.startsWith('http')
                                  ? NetworkImage(post.avatar) as ImageProvider
                                  : AssetImage(post.avatar),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: (isAnonymous ||
                                        widget.fromProfileDetails)
                                    ? null
                                    : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserProfileScreen(
                                              profileId: post.recipientId,
                                            ),
                                          ),
                                        ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      post.name,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    CustomText(
                                      post.views,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isAnonymous)
                              _buildFollowButton(post.recipientId),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // --- Action icons row (below the media card) ---
            Row(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final postState = ref.watch(postNotifierProvider);
                    final isLiked =
                        post.mediaId != null &&
                        postState.likedPostIds.contains(post.mediaId);
                    final currentPost = post.mediaId == null
                        ? null
                        : postState.feedPosts
                              .where((p) => p.id == post.mediaId)
                              .firstOrNull;
                    final likeCount =
                        currentPost?.reach?.reactionCount?['total'] as int? ??
                        post.likes;

                    return _buildIconAction(
                      assetPath: 'assets/images/like.png',
                      count: likeCount.toString(),
                      color: isLiked ? Colors.red : Colors.white,
                      onTap: isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'likes',
                            )
                          : () {
                              if (blockIfHirer(context, ref)) return;
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
                Consumer(
                  builder: (context, ref, _) {
                    final postState = ref.watch(postNotifierProvider);
                    final commentCount =
                        post.mediaId != null &&
                            postState.commentsTargetId == post.mediaId
                        ? postState.comments.length
                        : post.comments;

                    return GestureDetector(
                      onTap: isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'comments',
                            )
                          : () => context.push(
                              '/comments',
                              extra: post.mediaId ?? '',
                            ),
                      child: _buildIconAction(
                        assetPath: 'assets/images/Comment.png',
                        count: commentCount.toString(),
                      ),
                    );
                  },
                ),
                SizedBox(width: 20.w),
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
                                  'https://skillioo.in/post/${post.mediaId}'
                                  '?src=${Uri.encodeComponent(post.image)}'
                                  '&t=${post.isVideo ? 'video' : 'image'}'
                                  '&uid=${Uri.encodeComponent(post.recipientId)}'
                                  '&name=${Uri.encodeComponent(post.name)}'
                                  '&avatar=${Uri.encodeComponent(post.avatar)}'
                                  '&cat=${Uri.encodeComponent(post.category)}'
                                  '&sub=${Uri.encodeComponent(post.subcategory)}'
                                  '&pro=${Uri.encodeComponent(post.type)}';
                              return SharePostBottomSheet(postUrl: postUrl);
                            },
                          );
                        },
                  child: _buildIconAction(
                    assetPath: 'assets/images/Share.png',
                    count: '',
                  ),
                ),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () {
                    final String postUrl =
                        'https://skillioo.in/post/${post.mediaId}'
                        '?src=${Uri.encodeComponent(post.image)}'
                        '&t=${post.isVideo ? 'video' : 'image'}'
                        '&uid=${Uri.encodeComponent(post.recipientId)}'
                        '&name=${Uri.encodeComponent(post.name)}'
                        '&avatar=${Uri.encodeComponent(post.avatar)}'
                        '&cat=${Uri.encodeComponent(post.category)}'
                        '&sub=${Uri.encodeComponent(post.subcategory)}'
                        '&pro=${Uri.encodeComponent(post.type)}';
                    Share.share(
                      'Check out this amazing post on Skillioo!\n\n$postUrl',
                      subject: 'Share Post',
                    );
                  },
                  child: _buildIconAction(
                    assetPath: 'assets/images/Whatsapp Share.png',
                    count: '',
                  ),
                ),
                const Spacer(),
              ],
            ),

            SizedBox(height: 12.h),

            // --- Category & tags ---
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

                SizedBox(width: 8.w),
                _buildTag(post.type),
              ],
            ),

            SizedBox(height: 12.h),

            // --- Charges / Call / Chat ---
            Row(
              children: [
                GestureDetector(
                  onTap: () => showHiringRatesPopup(context, ref, post.recipientId),
                  child: _buildDropdownButton("Charges"),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildGradientOutlineButton(
                    "Call",
                    'assets/icons/call.svg',
                    onTap: isAnonymous
                        ? () =>
                              showLoginRequiredDialog(context, feature: 'calls')
                        : () => _handleCallTap(post.recipientId, post.name),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildGradientOutlineButton(
                    "Chat",
                    'assets/icons/message.svg',
                    onTap: isAnonymous
                        ? () =>
                              showLoginRequiredDialog(context, feature: 'chat')
                        : () => _handleChatTap(post.recipientId),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // --- Events & Music footer ---
            //   Row(
            //     children: [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           CustomText(
            //             post.events,
            //             fontSize: 16.sp,
            //             fontWeight: FontWeight.w700,
            //             color: Colors.white,
            //           ),
            //           CustomText(
            //             'Events',
            //             fontSize: 12.sp,
            //             fontWeight: FontWeight.w400,
            //             color: Colors.white70,
            //           ),
            //         ],
            //       ),
            //       const Spacer(),
            //       Icon(Icons.music_note, color: Colors.white70, size: 16.sp),
            //       SizedBox(width: 4.w),
            //       CustomText(
            //         post.music,
            //         fontSize: 12.sp,
            //         fontWeight: FontWeight.w400,
            //         color: Colors.white,
            //       ),
            //     ],
            //   ),
            //
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


  Widget _buildFollowButton(String profileId) {
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

  Widget _buildIconAction({
    required String assetPath,
    required String count,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 24.sp,
            height: 24.sp,
            color: color ?? Colors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
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
      height: 44.h,
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
    final success = await initiateCallWithSubscriptionCheck(
      context: context,
      ref: ref,
      recipientId: profileId,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $profileName...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleChatTap(String recipientId) async {
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

    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !mounted) return;

    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(resolvedRecipientId)}',
    );
  }

  Widget _buildGradientOutlineButton(
    String text,
    String assetPath, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGradientButton(text, assetPath),
    );
  }

  Widget _buildGradientButton(String text, String assetPath) {
    return Stack(
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
    );
  }
}
