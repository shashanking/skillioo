import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/profile/presentation/widgets/shared_widgets.dart';

import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../../dashboard/application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../posts/presentation/full_post_view.dart';
import '../../../posts/presentation/post_screen.dart';
import '../../../../core/services/session_prefs.dart';
import '../../domain/profile_service.dart';

class PostsTab extends ConsumerStatefulWidget {
  final ProfileItem profile;

  const PostsTab({super.key, required this.profile});

  @override
  ConsumerState<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<PostsTab> {
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];

  // Portfolio docs uploaded during onboarding (VIDEO + IMAGE, no PROFILE_PHOTO)
  List<DocumentInfo> _portfolioDocs = [];
  bool _portfolioLoaded = false;

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.contains('/video/upload/');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRef = widget.profile.id;
      ref
          .read(postNotifierProvider.notifier)
          .fetchUserPostsPostsAndReels(userReferenceId: userRef, refresh: true);
      _loadPortfolioDocs(widget.profile.id);
    });
  }

  @override
  void didUpdateWidget(covariant PostsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _documentsFuture = null;
      _lastDocIds = const [];
      _portfolioDocs = [];
      _portfolioLoaded = false;
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
        _loadPortfolioDocs(widget.profile.id);
      });
    }
  }

  Future<void> _loadPortfolioDocs(String profileId) async {
    if (_portfolioLoaded || profileId.isEmpty) return;
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return;

    try {
      final docs = <DocumentInfo>[];
      final seenUrls = <String>{};

      // Pre-seed the dedup set with the profile photo URL so that the
      // IMAGE-type copy of the profile photo (uploaded alongside the
      // PROFILE_PHOTO doc during onboarding) is never shown in the grid.
      final sessionProfile = await SessionPrefs.instance.getProfile();
      final rawPhotoUrl =
          sessionProfile?['profilePhotoUrl'] as String? ?? '';
      if (rawPhotoUrl.isNotEmpty) {
        final normalized = rawPhotoUrl.startsWith('http://')
            ? rawPhotoUrl.replaceFirst('http://', 'https://')
            : rawPhotoUrl;
        seenUrls.add(normalized);
      }

      // Fetch imageDocumentId + videoDocumentId from the profile API directly.
      // We cannot rely on the session cache because _loadPortfolioDocs may run
      // before syncProfile has finished merging the fresh profile data.
      final sessionId = (await SessionPrefs.instance.getProfileId()).trim();
      if (sessionId == profileId) {
        List<String> onboardingIds = const [];
        try {
          final profileRes = await ProfileService().getProfile(
            profileId: profileId,
            accessToken: token,
          );
          final data = profileRes['data'] as Map<String, dynamic>?;
          if (data != null) {
            // Resolve profilePictureId → URLs and add to seenUrls so that
            // any IMAGE document with the same URL (same file uploaded
            // twice during old onboarding flows) is deduped out of posts.
            final profilePicIds = (data['profilePictureId'] as List<dynamic>?)
                    ?.whereType<String>()
                    .where((id) => id.isNotEmpty)
                    .toList() ??
                const [];
            if (profilePicIds.isNotEmpty) {
              try {
                final picRes = await DocumentService().getDocumentsByIds(
                  ids: profilePicIds,
                  accessToken: token,
                );
                final picList =
                    picRes['data'] as List<dynamic>? ?? const [];
                for (final item in picList) {
                  if (item is Map<String, dynamic>) {
                    final url = (item['url'] as String? ?? '').trim();
                    if (url.isNotEmpty) {
                      seenUrls.add(
                        url.startsWith('http://')
                            ? url.replaceFirst('http://', 'https://')
                            : url,
                      );
                    }
                  }
                }
              } catch (_) {}
            }

            final imageIds = (data['imageDocumentId'] as List<dynamic>?)
                    ?.whereType<String>()
                    .where((id) => id.isNotEmpty)
                    .toList() ??
                const [];
            final videoIds = (data['videoDocumentId'] as List<dynamic>?)
                    ?.whereType<String>()
                    .where((id) => id.isNotEmpty)
                    .toList() ??
                const [];
            onboardingIds = [...imageIds, ...videoIds];
          }
        } catch (e) {
          debugPrint('_loadPortfolioDocs getProfile error: $e');
        }

        if (onboardingIds.isNotEmpty) {
          try {
            final res = await DocumentService().getDocumentsByIds(
              ids: onboardingIds,
              accessToken: token,
            );
            final list = res['data'] as List<dynamic>? ?? const [];
            debugPrint(
              '_loadPortfolioDocs: onboardingIds=${onboardingIds.length} resolved=${list.length}',
            );
            for (final item in list) {
              if (item is Map<String, dynamic>) {
                try {
                  final doc = DocumentInfo.fromJson(item);
                  if (doc.url.isNotEmpty && seenUrls.add(doc.url)) {
                    docs.add(doc);
                  }
                } catch (_) {}
              }
            }
          } catch (e) {
            debugPrint('_loadPortfolioDocs getDocumentsByIds error: $e');
          }
        }
      }

      // Also load any other portfolio docs (e.g. event/certificate docs),
      // deduplicating against what was already added above.
      try {
        final res = await DocumentService().getDocumentsForProfile(
          profileId: profileId,
          accessToken: token,
        );
        final list = res['data'] as List<dynamic>? ?? const [];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              final doc = DocumentInfo.fromJson(item);
              if (doc.type != DocumentType.profilePhoto &&
                  doc.url.isNotEmpty &&
                  seenUrls.add(doc.url)) {
                docs.add(doc);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      debugPrint(
        '_loadPortfolioDocs: profileId=$profileId total docs=${docs.length}',
      );
      if (!mounted) return;
      setState(() {
        _portfolioDocs = docs;
        _portfolioLoaded = true;
      });
    } catch (e) {
      debugPrint('_loadPortfolioDocs error: $e');
      if (!mounted) return;
      setState(() => _portfolioLoaded = true);
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

    debugPrint(
      'PostsTab: profileId=${widget.profile.id} totalUserPosts=${postState.userPosts.length} mediaWithDocuments=${media.length} userPostsStatus=${postState.userPostsStatus}',
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
                  String description,
                })
              >[];
          for (final m in media) {
            final firstDocId = (m.documentId ?? const []).isEmpty
                ? null
                : (m.documentId ?? const []).first;
            if (firstDocId == null) continue;
            final doc = docs[firstDocId];
            // Skip items with missing documents to avoid ExoPlayer errors
            if (doc == null || doc.url.trim().isEmpty) {
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
              description: m.description ?? '',
            ));
          }

          debugPrint(
            'PostsTab: profileId=${widget.profile.id} docIds=${docIdsList.length} renderableMedia=${postMsItems.length}',
          );

          // Portfolio items (onboarding uploads) — shown first
          final portfolioItems =
              <
                ({
                  GalleryItem item,
                  String? mediaId,
                  int totalComments,
                  int totalLikes,
                  int totalViews,
                  String description,
                })
              >[];
          for (final doc in _portfolioDocs) {
            final url = doc.url.startsWith('http://')
                ? doc.url.replaceFirst('http://', 'https://')
                : doc.url;
            final isVideo =
                doc.type == DocumentType.video || _isVideoUrl(url);
            portfolioItems.add((
              item: GalleryItem(
                imagePath: url,
                type: isVideo ? 'video' : 'image',
              ),
              mediaId: null,
              totalComments: 0,
              totalLikes: 0,
              totalViews: 0,
              description: '',
            ));
          }

          final allItems = [...portfolioItems, ...postMsItems];

          if (allItems.isEmpty) {
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
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final postItem = allItems[index];
              final item = postItem.item;
              final isVideo =
                  item.type == 'video' || _isVideoUrl(item.imagePath);

              return GalleryCard(
                item: item,
                isVideo: isVideo,
                onTap: () {
                  if (item.imagePath.isEmpty) return;
                  final mediaItems = allItems
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
                          description: p.description,
                        ),
                      )
                      .toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostViewScreen(
                        mediaItems: mediaItems,
                        initialIndex: index,
                        fromProfileDetails: true,
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
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 57, 24, 188), Color(0xFFD370EF)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
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
  String _thumbnailUrl(String url) {
    var resolved = url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;

    if (resolved.contains('/video/upload/')) {
      if (!resolved.contains('/video/upload/so_')) {
        resolved = resolved.replaceFirst(
          '/video/upload/',
          '/video/upload/so_0,w_400,h_400,c_fill/',
        );
      }
      final dot = resolved.lastIndexOf('.');
      if (dot != -1) {
        resolved = '${resolved.substring(0, dot)}.jpg';
      }
    }
    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _thumbnailUrl(widget.url),
      fit: BoxFit.cover,
      memCacheWidth: 400,
      memCacheHeight: 400,
      placeholder: (context, url) =>
          Container(color: Colors.black.withValues(alpha: 0.15)),
      errorWidget: (context, url, error) =>
          Container(color: Colors.black.withValues(alpha: 0.15)),
    );
  }
}
