import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:skillioo/features/profile/presentation/widgets/shared_widgets.dart';

import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../../dashboard/application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../posts/presentation/full_post_view.dart';
import '../../../posts/presentation/post_screen.dart';
import '../../../../core/services/session_prefs.dart';

class PostsTab extends ConsumerStatefulWidget {
  final ProfileItem profile;

  const PostsTab({super.key, required this.profile});

  @override
  ConsumerState<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<PostsTab> {
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.contains('/video/upload/');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRef = widget.profile.nickName.isNotEmpty
          ? widget.profile.nickName
          : widget.profile.id;
      ref
          .read(postNotifierProvider.notifier)
          .fetchUserPostsPostsAndReels(userReferenceId: userRef, refresh: true);
    });
  }

  @override
  void didUpdateWidget(covariant PostsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _documentsFuture = null;
      _lastDocIds = const [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userRef = widget.profile.nickName.isNotEmpty
            ? widget.profile.nickName
            : widget.profile.id;
        ref
            .read(postNotifierProvider.notifier)
            .fetchUserPostsPostsAndReels(
              userReferenceId: userRef,
              refresh: true,
            );
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final media = postState.userPosts
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: FutureBuilder<Map<String, DocumentInfo>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          final docs = snapshot.data ?? <String, DocumentInfo>{};

          // If Post MS is loading and we have nothing to show yet
          if (postState.userPostsStatus == PostStatus.loading &&
              media.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final postMsItems =
              <
                ({
                  GalleryItem item,
                  String? mediaId,
                  int totalComments,
                  int totalLikes,
                  int totalViews,
                })
              >[];
          for (final m in media) {
            final firstDocId = (m.documentId ?? const []).isEmpty
                ? null
                : (m.documentId ?? const []).first;
            if (firstDocId == null) continue;
            final doc = docs[firstDocId];
            if (doc == null) {
              postMsItems.add((
                item: GalleryItem(imagePath: '', type: 'video'),
                mediaId: m.id,
                totalComments: m.reach?.totalComments ?? 0,
                totalLikes:
                    ((m.reach?.reactionsCount?['like'] as num?)?.toInt() ??
                    (m.reach?.reactionCount?['like'] as num?)?.toInt() ??
                    0),
                totalViews: m.reach?.totalViews ?? 0,
              ));
              continue;
            }
            final mediaUrl = doc.url.startsWith('http://')
                ? doc.url.replaceFirst('http://', 'https://')
                : doc.url;
            final isVideo =
                doc.type == DocumentType.video || _isVideoUrl(mediaUrl);
            postMsItems.add((
              item: GalleryItem(
                imagePath: mediaUrl,
                type: isVideo ? 'video' : 'image',
              ),
              mediaId: m.id,
              totalComments: m.reach?.totalComments ?? 0,
              totalLikes:
                  ((m.reach?.reactionsCount?['like'] as num?)?.toInt() ??
                  (m.reach?.reactionCount?['like'] as num?)?.toInt() ??
                  0),
              totalViews: m.reach?.totalViews ?? 0,
            ));
          }

          if (postMsItems.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
              child: Center(
                child: Text(
                  'No posts available',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            // Important for nested scrolling
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.w,
              childAspectRatio: 1.0,
            ),
            itemCount: postMsItems.length,
            itemBuilder: (context, index) {
              final postItem = postMsItems[index];
              final item = postItem.item;
              final isVideo =
                  item.type == 'video' || _isVideoUrl(item.imagePath);

              return GalleryCard(
                item: item,
                isVideo: isVideo,
                onTap: () {
                  if (item.imagePath.isEmpty) return;
                  final mediaItems = postMsItems
                      .map(
                        (p) => MediaItem(
                          mediaUrl: p.item.imagePath,
                          isVideo:
                              p.item.type == 'video' ||
                              _isVideoUrl(p.item.imagePath),
                          recipientId: widget.profile.id,
                          profileName: widget.profile.displayName,
                          profilePhotoUrl: widget.profile.profilePhotoUrl,
                          category: 'Creator',
                          subcategory:
                              '${widget.profile.city}, ${widget.profile.country}',
                          proficiency: widget.profile.proficiency,
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
              );
            },
          );
        },
      ),
    );
  }
}

class GalleryCard extends StatelessWidget {
  final GalleryItem item;
  final bool isVideo;
  final VoidCallback onTap;

  const GalleryCard({
    super.key,
    required this.item,
    required this.isVideo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfessional = item.type == 'Professional';
    final borderColor = isProfessional
        ? const Color(0xFF8F39B2).withValues(alpha: 0.6)
        : const Color(0xFF2F208E).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.5.w),
          image: !isVideo
              ? DecorationImage(
                  image: NetworkImage(item.imagePath),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isVideo)
              Positioned.fill(
                child: _VideoTilePreview(
                  key: ValueKey(item.imagePath),
                  url: item.imagePath,
                ),
              ),
            if (isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 40,
                  color: Colors.white,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),

            // Positioned(
            //   top: 6.w,
            //   left: 6.w,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(6.r),
            //     child: BackdropFilter(
            //       filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            //       child: Container(
            //         padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            //         decoration: BoxDecoration(
            //           color: isProfessional
            //               ? const Color(0xFF8F39B2).withValues(alpha: 0.5)
            //               : const Color(0xFF2F208E).withValues(alpha: 0.5),
            //           borderRadius: BorderRadius.circular(6.r),
            //         ),
            //         child: Text(
            //           item.type,
            //           style: TextStyle(
            //             fontFamily: 'Outfit',
            //             fontSize: 8.sp,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.white,
            //             fontStyle: FontStyle.italic,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _VideoTilePreview extends StatefulWidget {
  const _VideoTilePreview({super.key, required this.url});

  final String url;

  @override
  State<_VideoTilePreview> createState() => _VideoTilePreviewState();
}

class _VideoTilePreviewState extends State<_VideoTilePreview> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _VideoTilePreview oldWidget) {
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
      // Fallback to blank container
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
