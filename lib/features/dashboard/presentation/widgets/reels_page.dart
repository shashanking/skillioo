import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/instagram_scroll_physics.dart';
import '../../../../core/services/session_state_provider.dart';
import '../../../../core/services/video_controller_registry.dart';
import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../follow/application/follow_providers.dart';
import '../../application/dashboard_providers.dart';
import '../../../posts/application/post_providers.dart';
import '../../../posts/domain/post_models.dart';
import '../../../posts/application/states/post_state.dart';
import '../../application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/utils/call_utils.dart';
import '../../../../core/utils/hirer_gate.dart';
import '../../../../core/widgets/hiring_rates_popup.dart';
import '../../../posts/presentation/comments_view.dart';
import '../../../posts/presentation/widgets/share_post_bottom_sheet.dart';
import '../../../../core/widgets/login_required_dialog.dart';
import '../../../profile/presentation/user_profile.dart';
import 'media_document_resolver.dart';

class ReelsPage extends ConsumerStatefulWidget {
  const ReelsPage({super.key, required this.isActive});

  final bool isActive;

  @override
  ConsumerState<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends ConsumerState<ReelsPage>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isInitialLoad = true;
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];
  final Map<String, DocumentInfo> _cachedDocuments = {};
  List<_ReelItem> _cachedReels = const [];
  final Map<int, VideoPlayerController> _preloadedControllers = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialLoad) return;
      _isInitialLoad = false;

      // Feed and follow data are preloaded by Landing — only fetch if missing
      final postState = ref.read(postNotifierProvider);
      if (postState.feedPosts.isEmpty &&
          postState.feedStatus != PostStatus.loading) {
        ref
            .read(postNotifierProvider.notifier)
            .fetchFeed(mediaType: 'reel', refresh: true);
      }
      // Profiles preloaded by Landing; load with higher perPage only if needed
      final profileState = ref.read(profileListNotifierProvider);
      if (profileState.profiles.isEmpty && !profileState.isLoading) {
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(perPage: 50, refresh: false);
      }
      // Follow data is preloaded by Landing — no duplicate calls needed
    });
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Map<String, DocumentInfo>> _fetchDocumentsByIds(
    List<String> ids,
  ) async {
    // Filter out non-UUID ids that would cause the batch request to fail
    final validIds = ids
        .where((id) => id.trim().isNotEmpty && _uuidRegex.hasMatch(id.trim()))
        .toList();
    // Check cache first
    final missingIds = validIds
        .where((id) => !_cachedDocuments.containsKey(id))
        .toList();

    if (missingIds.isEmpty) {
      return Map.fromEntries(
        validIds
            .where((id) => _cachedDocuments.containsKey(id))
            .map((id) => MapEntry(id, _cachedDocuments[id]!)),
      );
    }

    final token = await SessionPrefs.instance.getAccessToken();

    // Use the provider'd service so requests go through the shared
    // RetryHttpClient (502/503/504 + network errors).
    final service = ref.read(postDocumentServiceProvider);

    Future<Map<String, dynamic>> attempt() async {
      try {
        return await service.getDocumentsByIds(
          ids: missingIds,
          accessToken: token.isNotEmpty ? token : null,
        );
      } catch (e) {
        return {'success': false, 'message': e.toString(), 'data': const []};
      }
    }

    Map<String, dynamic> res = await attempt();
    final firstOk = res['success'] == true &&
        res['data'] is List &&
        (res['data'] as List).isNotEmpty;
    if (!firstOk) {
      await Future.delayed(const Duration(milliseconds: 800));
      res = await attempt();
    }

    if (res['success'] == false) {
      return _cachedDocuments;
    }

    final list = res['data'] as List<dynamic>? ?? const [];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final doc = DocumentInfo.fromJson(item);
          _cachedDocuments[doc.id] = doc;
        } catch (_) {}
      }
    }

    // Return all requested documents (cached + newly fetched)
    return Map.fromEntries(
      validIds
          .where((id) => _cachedDocuments.containsKey(id))
          .map((id) => MapEntry(id, _cachedDocuments[id]!)),
    );
  }

  String _normalizeMediaUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  String? _resolveReelUrl(MediaResponse media, Map<String, DocumentInfo> docs) {
    final directUrl = (media.mediaUrl ?? '').trim();
    if (directUrl.isNotEmpty) {
      return _normalizeMediaUrl(directUrl);
    }

    final doc = resolvePreferredDocument(
      media.documentId,
      docs,
      preferVideo: true,
    );
    if (doc == null) return null;
    if (!isVideoDocument(doc)) return null;
    return _normalizeMediaUrl(doc.url);
  }

  @override
  void deactivate() {
    _pauseAllVideos();
    super.deactivate();
  }

  @override
  void didUpdateWidget(covariant ReelsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive) {
      _pauseAllVideos();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _preloadedControllers.values) {
      VideoControllerRegistry.instance.unregister(controller);
      controller.dispose();
    }
    _preloadedControllers.clear();
    super.dispose();
  }

  void _pauseAllVideos() {
    for (final controller in _preloadedControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _managePreloading(index);
  }

  Future<void> _managePreloading(int currentIndex) async {
    if (_cachedReels.isEmpty) return;

    // Determine which indices to keep preloaded (current + next 2)
    final indicesToKeep = <int>{};
    for (
      int i = currentIndex;
      i < currentIndex + 3 && i < _cachedReels.length;
      i++
    ) {
      indicesToKeep.add(i);
    }

    // Dispose controllers that are no longer needed
    final toRemove = <int>[];
    for (final index in _preloadedControllers.keys) {
      if (!indicesToKeep.contains(index)) {
        toRemove.add(index);
      }
    }
    for (final index in toRemove) {
      final c = _preloadedControllers[index];
      if (c != null) {
        VideoControllerRegistry.instance.unregister(c);
        c.dispose();
      }
      _preloadedControllers.remove(index);
    }

    // Preload upcoming videos
    for (final index in indicesToKeep) {
      if (!_preloadedControllers.containsKey(index)) {
        _preloadController(index);
      }
    }
  }

  Future<void> _preloadController(int index) async {
    if (index >= _cachedReels.length) return;
    try {
      final resolvedUrl = _normalizeMediaUrl(_cachedReels[index].videoUrl);
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(resolvedUrl),
      );
      _preloadedControllers[index] = controller;
      VideoControllerRegistry.instance.register(controller);
      await controller.initialize();
      controller.setVolume(1.0);
      controller.setLooping(true);
    } catch (_) {
      _preloadedControllers.remove(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final postState = ref.watch(postNotifierProvider);
    final profileState = ref.watch(profileListNotifierProvider);
    final profileByUserRef = <String, ProfileItem>{};
    for (final profile in profileState.profiles) {
      final idKey = profile.id.trim();
      if (idKey.isNotEmpty) {
        profileByUserRef[idKey] = profile;
      }
      final nickKey = profile.nickName.trim();
      if (nickKey.isNotEmpty) {
        profileByUserRef[nickKey] = profile;
      }
    }
    final media =
        postState.feedPosts
            .where((m) => (m.mediaType ?? '').toLowerCase() == 'reel')
            .toList()
          ..sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

    final allDocIds = <String>{};
    for (final m in media) {
      allDocIds.addAll(m.documentId ?? const []);
    }
    final docIdsList = allDocIds.where((e) => e.trim().isNotEmpty).toList();
    docIdsList.sort();

    if (docIdsList.join(',') != _lastDocIds.join(',')) {
      _lastDocIds = docIdsList;
      _documentsFuture = docIdsList.isEmpty
          ? Future.value(<String, DocumentInfo>{})
          : _fetchDocumentsByIds(docIdsList);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<Map<String, DocumentInfo>>(
            future: _documentsFuture,
            builder: (context, snapshot) {
              final docs = snapshot.data ?? <String, DocumentInfo>{};

              final reels = <_ReelItem>[];
              for (final m in media) {
                final mediaUrl = _resolveReelUrl(m, docs);
                if (mediaUrl == null || mediaUrl.isEmpty) {
                  continue;
                }
                final userRef = (m.userReferenceId ?? '').trim();
                final profile = profileByUserRef[userRef];
                final shortUser = m.shortUser;

                // Use shortUser from API as primary source, fall back to profile list
                final displayName =
                    profile?.displayName ??
                    shortUser?.name ??
                    shortUser?.nickName ??
                    'User';
                String? photoUrl = profile?.profilePhotoUrl;
                if (photoUrl == null && shortUser?.profilePictureUrl != null) {
                  final raw = shortUser!.profilePictureUrl!;
                  photoUrl = raw.startsWith('http://')
                      ? raw.replaceFirst('http://', 'https://')
                      : raw;
                }

                reels.add(
                  _ReelItem(
                    id: m.id ?? mediaUrl,
                    videoUrl: mediaUrl,
                    profileId: profile?.id ?? userRef,
                    profileName: displayName,
                    profilePhotoUrl: photoUrl,
                    proficiency: profile?.proficiency ?? 'PROFESSIONAL',
                    location: '',
                    category: profile?.category ?? shortUser?.category ?? '',
                    subCategory: shortUser?.subCategory ?? '',
                    reactionCount:
                        (m.reach?.reactionCount?['like'] as num?)?.toInt() ??
                        (m.reach?.reactionCount?['total'] as num?)?.toInt() ??
                        0,
                    commentCount: m.reach?.totalComments ?? 0,
                    description: m.description ?? '',
                  ),
                );
              }

              // Update cache to reflect any like/comment count changes
              _cachedReels = reels;
              if (_cachedReels.isNotEmpty && _preloadedControllers.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _managePreloading(0);
                });
              }

              if (postState.feedStatus == PostStatus.loading &&
                  _cachedReels.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (_cachedReels.isEmpty) {
                return Center(
                  child: CustomText(
                    'No reels available',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const InstagramPageScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemCount: _cachedReels.length,
                itemBuilder: (context, index) {
                  final preloadedController = _preloadedControllers[index];
                  final item = _cachedReels[index];
                  final isLiked = postState.likedPostIds.contains(item.id);
                  final liveItem = postState.feedPosts
                      .where((post) => post.id == item.id)
                      .firstOrNull;
                  final reactionCount =
                      liveItem?.reach?.reactionCount?['total'] as int? ??
                      item.reactionCount;

                  return _ReelVideoCard(
                    key: ValueKey(item.videoUrl),
                    item: item,
                    preloadedController: preloadedController,
                    onAdoptPreloaded: (VideoPlayerController adopted) {
                      // Transfer ownership to the child so the parent won't
                      // dispose a controller the child is still rendering.
                      _preloadedControllers.removeWhere(
                        (_, c) => identical(c, adopted),
                      );
                    },
                    isActive: widget.isActive && index == _currentIndex,
                    isLiked: isLiked,
                    reactionCount: reactionCount,
                    onLikeTap: () {
                      if (blockIfHirer(context, ref)) return;
                      ref
                          .read(postNotifierProvider.notifier)
                          .toggleReaction(
                            targetId: item.id,
                            reactionType: 'like',
                          );
                    },
                  );
                },
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: CustomText(
                'Reels',
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ─────────────────────────────────────────────────────────────

class _ReelItem {
  final String id;
  final String videoUrl;
  final String profileId;
  final String profileName;
  final String? profilePhotoUrl;
  final String proficiency;
  final String location;
  final String category;
  final String subCategory;
  final int reactionCount;
  final int commentCount;
  final String description;

  const _ReelItem({
    required this.id,
    required this.videoUrl,
    required this.profileId,
    required this.profileName,
    this.profilePhotoUrl,
    required this.proficiency,
    required this.location,
    this.category = '',
    this.subCategory = '',
    this.reactionCount = 0,
    this.commentCount = 0,
    this.description = '',
  });
}

// ─── Reel video card ─────────────────────────────────────────────────────────

class _ReelVideoCard extends ConsumerStatefulWidget {
  const _ReelVideoCard({
    super.key,
    required this.item,
    required this.isLiked,
    required this.reactionCount,
    required this.onLikeTap,
    required this.preloadedController,
    required this.onAdoptPreloaded,
    required this.isActive,
  });

  final _ReelItem item;
  final bool isLiked;
  final int reactionCount;
  final VoidCallback onLikeTap;
  final VideoPlayerController? preloadedController;
  final void Function(VideoPlayerController adopted) onAdoptPreloaded;
  final bool isActive;

  @override
  ConsumerState<_ReelVideoCard> createState() => _ReelVideoCardState();
}

class _ReelVideoCardState extends ConsumerState<_ReelVideoCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _initialized = false;
  void Function()? _disposalListener;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool get _isAnonymous => ref.read(isAnonymousProvider);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    if (widget.item.description.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _slideController.forward();
      });
    }

    _init();
  }

  void _attachDisposalListener(VideoPlayerController controller) {
    _detachDisposalListener();
    Null listener() {
      // Controller was disposed externally (e.g. before a Twilio call).
      // Drop the reference synchronously so the next rebuild falls back to
      // the placeholder instead of rendering a dead VideoPlayer.
      if (!mounted) return;
      setState(() {
        _controller = null;
        _initialized = false;
      });
    }

    _disposalListener = listener;
    VideoControllerRegistry.instance.addDisposalListener(controller, listener);
  }

  void _detachDisposalListener() {
    final c = _controller;
    final l = _disposalListener;
    if (c != null && l != null) {
      VideoControllerRegistry.instance.removeDisposalListener(c, l);
    }
    _disposalListener = null;
  }

  Future<void> _init() async {
    // Adopt parent's preloaded controller if available — take ownership so the
    // parent no longer disposes it out from under us.
    final preloaded = widget.preloadedController;
    try {
      if (preloaded != null && preloaded.value.isInitialized) {
        _controller = preloaded;
        _initialized = true;
        widget.onAdoptPreloaded(preloaded);
        _attachDisposalListener(preloaded);
        if (mounted) setState(() {});
        if (widget.isActive) preloaded.play();
        return;
      }
    } catch (_) {
      // Preloaded controller was disposed between PageView.build and our
      // initState — fall through to create a fresh one.
    }

    // Otherwise initialize new controller
    try {
      final resolvedUrl = widget.item.videoUrl.startsWith('http://')
          ? widget.item.videoUrl.replaceFirst('http://', 'https://')
          : widget.item.videoUrl;
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(resolvedUrl),
      );
      _controller = controller;
      VideoControllerRegistry.instance.register(controller);
      _attachDisposalListener(controller);
      await controller.initialize();
      controller.setVolume(1.0);
      controller.setLooping(true);
      if (!mounted) {
        VideoControllerRegistry.instance.unregister(controller);
        controller.dispose();
        return;
      }
      setState(() => _initialized = true);
      if (widget.isActive) controller.play();
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant _ReelVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final c = _controller;
    if (c == null || !_initialized) return;
    try {
      if (widget.isActive && !c.value.isPlaying) {
        c.play();
      } else if (!widget.isActive && c.value.isPlaying) {
        c.pause();
      }
    } catch (_) {
      // Controller was disposed elsewhere — drop the reference so build falls
      // back to the placeholder instead of rendering a dead VideoPlayer.
      _controller = null;
      _initialized = false;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    // The child owns _controller (either it created it, or it adopted a
    // preloaded one from the parent). Always dispose it here.
    _detachDisposalListener();
    if (_controller != null) {
      VideoControllerRegistry.instance.unregister(_controller!);
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    Size? videoSize;
    bool controllerDead = false;
    if (c != null && _initialized) {
      try {
        videoSize = c.value.isInitialized ? c.value.size : null;
      } catch (_) {
        videoSize = null;
        controllerDead = true;
      }
    }
    if (controllerDead) {
      // Clear the dead reference after this frame so a subsequent build (or
      // scroll) can create a fresh controller instead of staying on the
      // placeholder forever.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller != null) {
          setState(() {
            _controller = null;
            _initialized = false;
          });
        }
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / placeholder background ──────────────────────
        if (c != null && videoSize != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(c),
            ),
          )
        else
          Container(color: Colors.black),

        // ── Gradient overlay ────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.4, 0.65, 1.0],
            ),
          ),
        ),

        // ── Right action buttons ────────────────────────────────
        Positioned(
          right: 16.w,
          bottom: 0.25.sh,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile photo
              _buildProfile(),

              _ActionBtn(
                assetPath: 'assets/images/like.png',
                color: widget.isLiked ? Colors.red : Colors.white,
                label: '${widget.reactionCount}',
                onTap: _isAnonymous
                    ? () => showLoginRequiredDialog(context, feature: 'likes')
                    : () {
                        widget.onLikeTap();
                      },
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                assetPath: 'assets/images/Comment.png',
                label: '${widget.item.commentCount}',
                onTap: _isAnonymous
                    ? () =>
                          showLoginRequiredDialog(context, feature: 'comments')
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
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                  child: CommentsScreen(
                                    targetId: widget.item.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                assetPath: 'assets/images/Share.png',
                label: 'Send',
                onTap: _isAnonymous
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
                                'https://skillioo.in/post/${widget.item.id}'
                                '?src=${Uri.encodeComponent(widget.item.videoUrl)}'
                                '&t=video'
                                '&uid=${Uri.encodeComponent(widget.item.profileId)}'
                                '&name=${Uri.encodeComponent(widget.item.profileName)}'
                                '&avatar=${Uri.encodeComponent(widget.item.profilePhotoUrl ?? '')}'
                                '&cat=${Uri.encodeComponent(widget.item.category)}'
                                '&sub=${Uri.encodeComponent(widget.item.subCategory)}'
                                '&pro=${Uri.encodeComponent(widget.item.proficiency)}';
                            return SharePostBottomSheet(postUrl: postUrl);
                          },
                        );
                      },
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                assetPath: 'assets/images/Whatsapp Share.png',
                label: 'Share',
                onTap: () {
                  final String postUrl =
                      'https://skillioo.in/post/${widget.item.id}'
                      '?src=${Uri.encodeComponent(widget.item.videoUrl)}'
                      '&t=video'
                      '&uid=${Uri.encodeComponent(widget.item.profileId)}'
                      '&name=${Uri.encodeComponent(widget.item.profileName)}'
                      '&avatar=${Uri.encodeComponent(widget.item.profilePhotoUrl ?? '')}'
                      '&cat=${Uri.encodeComponent(widget.item.category)}'
                      '&sub=${Uri.encodeComponent(widget.item.subCategory)}'
                      '&pro=${Uri.encodeComponent(widget.item.proficiency)}';
                  Share.share(
                    'Check out this amazing reel on Skillioo!\n\n$postUrl',
                    subject: 'Share Reel',
                  );
                },
              ),
            ],
          ),
        ),

        // ── Bottom info overlay ─────────────────────────────────
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description — slides up after 0.5s
              if (widget.item.description.isNotEmpty) ...[
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
                        widget.item.description,
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
                SizedBox(height: 12.h),
              ],

              // Name and Views
              Row(
                children: [
                  GestureDetector(
                    onTap: _isAnonymous
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(
                                  profileId: widget.item.profileId,
                                ),
                              ),
                            ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          widget.item.profileName,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          '1M Views',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _buildFollowButton(widget.item.profileId),
                ],
              ),

              SizedBox(height: 16.h),
              // Category, subCategory, and proficiency
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          widget.item.category.isNotEmpty
                              ? widget.item.category
                              : 'Creator',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        if (widget.item.subCategory.isNotEmpty)
                          CustomText(
                            widget.item.subCategory,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CustomText(
                      widget.item.proficiency,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // Buttons Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => showHiringRatesPopup(
                      context,
                      ref,
                      widget.item.profileId,
                    ),
                    child: Container(
                      height: 44.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          CustomText(
                            'Charges',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      'Call',
                      'assets/icons/call.svg',
                      onTap: _isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'calls',
                            )
                          : () => _handleCallTap(
                              widget.item.profileId,
                              widget.item.profileName,
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      'Chat',
                      'assets/icons/message.svg',
                      onTap: _isAnonymous
                          ? () => showLoginRequiredDialog(
                              context,
                              feature: 'chat',
                            )
                          : () => _handleChatTap(
                              widget.item.profileId,
                              widget.item.profileName,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Footer
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(String profileId) {
    final followState = ref.watch(followNotifierProvider);
    final isFollowing = followState.followingIds.contains(profileId);
    final isToggling = followState.togglingIds.contains(profileId);

    return GestureDetector(
      onTap: isToggling
          ? null
          : () {
              if (blockIfHirer(context, ref)) return;
              ref.read(followNotifierProvider.notifier).toggleFollow(profileId);
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
  }

  Widget _buildProfile() {
    final followState = ref.watch(followNotifierProvider);
    final isFollowing = followState.followingIds.contains(
      widget.item.profileId,
    );
    followState.togglingIds.contains(widget.item.profileId);

    return SizedBox(
      width: 60.w,
      height: 96.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Profile photo
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isFollowing ? const Color(0xFF00D9FF) : Colors.white,
                width: 2.w,
              ),
              color: Colors.white24,
              image: widget.item.profilePhotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.item.profilePhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.item.profilePhotoUrl == null
                ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                : null,
          ),
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

  void _handleChatTap(String profileId, String profileName) async {
    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !mounted) return;

    if (profileId.isNotEmpty) {
      Navigator.of(context).pushNamed(
        '/chat',
        arguments: {'recipientId': profileId, 'recipientName': profileName},
      );
    }
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
      ),
    );
  }
}

// ─── Side action button ───────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final String assetPath;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 22.sp,
              height: 22.sp,
              color: color,
              colorBlendMode: BlendMode.srcIn,
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: 5.h),
              CustomText(
                label,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
