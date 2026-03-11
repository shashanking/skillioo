import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/custom_trending_carousel_components.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/session_prefs.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../../posts/presentation/full_post_view.dart';
import '../../../posts/presentation/post_screen.dart';

class CombinedMediaGrid extends ConsumerStatefulWidget {
  const CombinedMediaGrid({super.key});

  @override
  ConsumerState<CombinedMediaGrid> createState() => CombinedMediaGridState();
}

class CombinedMediaGridState extends ConsumerState<CombinedMediaGrid> {
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];

  Future<void> _refreshFeedPostsAndReels() async {
    final notifier = ref.read(postNotifierProvider.notifier);
    await notifier.fetchFeed(mediaType: 'post', refresh: true);
    await notifier.fetchFeed(mediaType: 'reel', refresh: true);
  }

  Future<void> loadMorePosts() async {
    final postState = ref.read(postNotifierProvider);
    if (postState.feedStatus == PostStatus.loading) {
      return;
    }
    final notifier = ref.read(postNotifierProvider.notifier);
    await notifier.fetchFeed(mediaType: 'post');
    await notifier.fetchFeed(mediaType: 'reel');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFeedPostsAndReels();
      ref
          .read(profileListNotifierProvider.notifier)
          .loadProfiles(perPage: 50, refresh: true);
    });
  }

  void loadProfilesWithCategory(String? category) {
    _refreshFeedPostsAndReels();
    ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(perPage: 50, refresh: true, category: category);
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

  bool _isVideoFromDocUrl(String url, {String? type}) {
    if (type == DocumentType.video) return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.contains('/video/upload/');
  }

  int _objectIdEpochSeconds(String? id) {
    final value = (id ?? '').trim();
    if (value.length < 8) return 0;
    final hex = value.substring(0, 8);
    return int.tryParse(hex, radix: 16) ?? 0;
  }

  String _normalizeMediaUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
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

    final feedMedia = postState.feedPosts
        .where((m) => m.mediaType == 'post' || m.mediaType == 'reel')
        .where((m) => m.documentId != null && m.documentId!.isNotEmpty)
        .toList();

    final media = [...feedMedia]
      ..sort(
        (a, b) =>
            _objectIdEpochSeconds(b.id).compareTo(_objectIdEpochSeconds(a.id)),
      );

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

    if (postState.feedStatus == PostStatus.loading && media.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: CircularProgressIndicator(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, DocumentInfo>>(
      future: _documentsFuture,
      builder: (context, snapshot) {
        final docs = snapshot.data ?? <String, DocumentInfo>{};

        final postUrls =
            <
              ({
                String url,
                bool isVideo,
                String recipientId,
                String profileName,
                String? profilePhotoUrl,
                String proficiency,
                String? mediaId,
                int totalComments,
                int totalLikes,
                int totalViews,
              })
            >[];
        for (final m in media) {
          final firstId = (m.documentId ?? const []).isEmpty
              ? null
              : (m.documentId ?? const []).first;
          if (firstId == null) continue;
          final doc = docs[firstId];
          if (doc == null) continue;
          final mediaUrl = _normalizeMediaUrl(doc.url);
          final isVideo = _isVideoFromDocUrl(mediaUrl, type: doc.type);
          final userRef = (m.userReferenceId ?? '').trim();
          final profile = profileByUserRef[userRef];
          postUrls.add((
            url: mediaUrl,
            isVideo: isVideo,
            recipientId: profile?.id ?? userRef,
            profileName: profile?.displayName ?? (m.userReferenceId ?? 'User'),
            profilePhotoUrl: profile?.profilePhotoUrl,
            proficiency: profile?.proficiency ?? 'PROFESSIONAL',
            mediaId: m.id,
            totalComments: m.reach?.totalComments ?? 0,
            totalLikes:
                ((m.reach?.reactionsCount?['like'] as num?)?.toInt() ??
                (m.reach?.reactionCount?['like'] as num?)?.toInt() ??
                0),
            totalViews: m.reach?.totalViews ?? 0,
          ));
        }

        if (postUrls.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Text(
                'No media available',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: postUrls.length,
                itemBuilder: (context, index) {
                  final item = postUrls[index];
                  return GestureDetector(
                    onTap: () {
                      final mediaItems = postUrls
                          .map(
                            (p) => MediaItem(
                              mediaUrl: p.url,
                              isVideo: p.isVideo,
                              recipientId: p.recipientId,
                              profileName: p.profileName,
                              profilePhotoUrl: p.profilePhotoUrl,
                              category: 'Creator',
                              subcategory: '',
                              proficiency: p.proficiency,
                              mediaId: p.mediaId,
                              totalComments: p.totalComments,
                              totalLikes: p.totalLikes,
                              totalViews: p.totalViews,
                            ),
                          )
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostViewScreen(
                            mediaItems: mediaItems,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (!item.isVideo)
                            CachedNetworkImage(
                              imageUrl: item.url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          else
                            _VideoPreview(
                              key: ValueKey(item.url),
                              url: item.url,
                            ),
                          Stack(
                            children: [
                              CustomPaint(
                                size: Size(170.w, 170.w),
                                painter: TrendingTalentGradientBorderPainter(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFC00F8B),
                                      Color(0xFF05DAF1),
                                    ],
                                  ),
                                  borderRadius: 24.r,
                                  strokeWidth: 1.w,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 10.h,
                            left: 10.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Text(
                                item.proficiency == 'PROFESSIONAL'
                                    ? 'Professional'
                                    : 'Skilled',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFF5F5F5),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          if (item.isVideo)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (postState.feedStatus == PostStatus.loading &&
                  postUrls.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({super.key, required this.url});

  final String url;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeController();
      _initialized = false;
      _init();
    }
  }

  Future<void> _init() async {
    final resolvedUrl = widget.url.startsWith('http://')
        ? widget.url.replaceFirst('http://', 'https://')
        : widget.url;
    final controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.pause();
      if (!mounted) return;
      setState(() {
        _initialized = true;
      });
    } catch (_) {
      // Fall back to placeholder below
    }
  }

  void _disposeController() {
    final c = _controller;
    _controller = null;
    if (c != null) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !_initialized) {
      return Container(color: Colors.black.withValues(alpha: 0.15));
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }
}
