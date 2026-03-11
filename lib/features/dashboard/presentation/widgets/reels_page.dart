import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../application/dashboard_providers.dart';
import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../chat/application/chat_providers.dart';

class ReelsPage extends ConsumerStatefulWidget {
  const ReelsPage({super.key, required this.isActive});

  final bool isActive;

  @override
  ConsumerState<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends ConsumerState<ReelsPage>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _preloadedControllers = {};
  List<_ReelItem> _cachedReels = [];
  Future<Map<String, DocumentInfo>> _documentsFuture = Future.value({});
  List<String> _lastDocIds = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postNotifierProvider.notifier)
          .fetchFeed(mediaType: 'reel', refresh: true);
      ref
          .read(profileListNotifierProvider.notifier)
          .loadProfiles(perPage: 50, refresh: false);
    });
  }

  Future<Map<String, DocumentInfo>> _fetchDocumentsByIds(
    List<String> ids,
  ) async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return <String, DocumentInfo>{};

    final service = DocumentService();
    final res = await service.getDocumentsByIds(ids: ids, accessToken: token);

    final success = res['success'] as bool?;
    if (success == false) return <String, DocumentInfo>{};

    final list = res['data'] as List<dynamic>? ?? const [];
    final map = <String, DocumentInfo>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final doc = DocumentInfo.fromJson(item);
          map[doc.id] = doc;
        } catch (_) {}
      }
    }
    return map;
  }

  bool _isVideoFromDoc(DocumentInfo doc) {
    final url = _normalizeMediaUrl(doc.url).toLowerCase();
    return doc.type == DocumentType.video ||
        url.endsWith('.mp4') ||
        url.contains('/video/upload/');
  }

  String _normalizeMediaUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
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
      _preloadedControllers[index]?.dispose();
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
    final media = postState.feedPosts
        .where((m) => m.mediaType == 'reel')
        .where((m) => m.documentId != null && m.documentId!.isNotEmpty)
        .toList();

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
                final firstId = (m.documentId ?? const []).isEmpty
                    ? null
                    : (m.documentId ?? const []).first;
                if (firstId == null) continue;
                final doc = docs[firstId];
                if (doc == null) continue;
                if (!_isVideoFromDoc(doc)) continue;
                final mediaUrl = _normalizeMediaUrl(doc.url);
                final userRef = (m.userReferenceId ?? '').trim();
                final profile = profileByUserRef[userRef];

                reels.add(
                  _ReelItem(
                    id: m.id ?? mediaUrl,
                    videoUrl: mediaUrl,
                    profileId: profile?.id ?? userRef,
                    profileName:
                        profile?.displayName ?? (m.userReferenceId ?? 'User'),
                    profilePhotoUrl: profile?.profilePhotoUrl,
                    proficiency: profile?.proficiency ?? 'PROFESSIONAL',
                    location: '',
                    reactionCount:
                        m.reach?.reactionCount?['total'] as int? ?? 0,
                  ),
                );
              }

              // Update cache and trigger initial preload
              if (reels.length != _cachedReels.length) {
                _cachedReels = reels;
                if (_cachedReels.isNotEmpty && _preloadedControllers.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _managePreloading(0);
                  });
                }
              }

              if (postState.feedStatus == PostStatus.loading &&
                  _cachedReels.isEmpty) {
                return const Center(
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
                onPageChanged: _onPageChanged,
                itemCount: _cachedReels.length,
                itemBuilder: (context, index) {
                  final preloadedController = _preloadedControllers[index];
                  final item = _cachedReels[index];
                  final isLiked = postState.likedPostIds.contains(item.id);

                  return _ReelVideoCard(
                    key: ValueKey(item.videoUrl),
                    item: item,
                    preloadedController: preloadedController,
                    isActive: widget.isActive && index == _currentIndex,
                    isLiked: isLiked,
                    onLikeTap: () {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Reels',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: Colors.white,
                  ),
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.search, color: Colors.white, size: 22.sp),
                  ),
                ],
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
  final int reactionCount;

  const _ReelItem({
    required this.id,
    required this.videoUrl,
    required this.profileId,
    required this.profileName,
    this.profilePhotoUrl,
    required this.proficiency,
    required this.location,
    this.reactionCount = 0,
  });
}

// ─── Reel video card ─────────────────────────────────────────────────────────

class _ReelVideoCard extends ConsumerStatefulWidget {
  const _ReelVideoCard({
    super.key,
    required this.item,
    required this.isLiked,
    required this.onLikeTap,
    required this.preloadedController,
    required this.isActive,
  });

  final _ReelItem item;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VideoPlayerController? preloadedController;
  final bool isActive;

  @override
  ConsumerState<_ReelVideoCard> createState() => _ReelVideoCardState();
}

class _ReelVideoCardState extends ConsumerState<_ReelVideoCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Use preloaded controller if available
    if (widget.preloadedController != null &&
        widget.preloadedController!.value.isInitialized) {
      _controller = widget.preloadedController;
      _initialized = true;
      if (mounted) setState(() {});
      if (widget.isActive) _controller!.play();
      return;
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
      await controller.initialize();
      controller.setVolume(1.0);
      controller.setLooping(true);
      if (!mounted) return;
      setState(() => _initialized = true);
      if (widget.isActive) controller.play();
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant _ReelVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final c = _controller;
    if (c == null || !_initialized) return;
    if (widget.isActive && !c.value.isPlaying) {
      c.play();
    } else if (!widget.isActive && c.value.isPlaying) {
      c.pause();
    }
  }

  @override
  void dispose() {
    // Only dispose if not using preloaded controller (parent manages those)
    if (_controller != null && _controller != widget.preloadedController) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / placeholder background ──────────────────────
        if (c != null && _initialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
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
          bottom: 120.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile photo
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
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
              SizedBox(height: 24.h),
              _ActionBtn(
                icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? Colors.red : Colors.white,
                label: '${widget.item.reactionCount}',
                onTap: () {
                  widget.onLikeTap();
                  // Call the toggleReaction API
                  ref
                      .read(postNotifierProvider.notifier)
                      .toggleReaction(
                        targetId: widget.item.id,
                        reactionType: 'like',
                      );
                },
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                icon: Icons.chat_bubble_outline,
                label: '5K',
                onTap: () => context.go(
                  '/landing?tab=3&recipientId=${Uri.encodeComponent(widget.item.profileId)}',
                ),
              ),
              SizedBox(height: 20.h),
              _ActionBtn(icon: Icons.send_outlined, label: '2K', onTap: () {}),
              SizedBox(height: 20.h),
              _ActionBtn(
                icon: Icons.message,
                label: 'Send',
                onTap: () => context.go(
                  '/landing?tab=3&recipientId=${Uri.encodeComponent(widget.item.profileId)}',
                ),
              ),
              SizedBox(height: 20.h),
              _ActionBtn(icon: Icons.bookmark_border, label: '', onTap: () {}),
            ],
          ),
        ),

        // ── Bottom info overlay ─────────────────────────────────
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
                    widget.item.profileName,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
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
                  ),
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
              // Category and location
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Creator',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      if (widget.item.location.isNotEmpty)
                        CustomText(
                          widget.item.location,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Tags
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
              SizedBox(height: 20.h),
              // Buttons Row
              Row(
                children: [
                  Container(
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
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      'Call',
                      Icons.call,
                      onTap: () => _handleCallTap(
                        widget.item.profileId,
                        widget.item.profileName,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGradientOutlineButton(
                      'Chat',
                      Icons.chat_bubble_outline,
                      onTap: () => context.go(
                        '/landing?tab=3&recipientId=${Uri.encodeComponent(widget.item.profileId)}',
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
      ),
    );
  }
}

// ─── Side action button ───────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 22.sp),
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
    );
  }
}
