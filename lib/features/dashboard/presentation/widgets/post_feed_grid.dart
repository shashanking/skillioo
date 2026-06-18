import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/session_prefs.dart';
import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../../posts/presentation/full_post_view.dart';
import 'media_document_resolver.dart';

class PostFeedGrid extends ConsumerStatefulWidget {
  const PostFeedGrid({super.key});

  @override
  ConsumerState<PostFeedGrid> createState() => _PostFeedGridState();
}

class _PostFeedGridState extends ConsumerState<PostFeedGrid> {
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];
  final Map<String, DocumentInfo> _cachedDocuments = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Feed is preloaded by Landing — only fetch if missing
      final state = ref.read(postNotifierProvider);
      if (state.feedPosts.isEmpty && state.feedStatus != PostStatus.loading) {
        ref
            .read(postNotifierProvider.notifier)
            .fetchFeed(mediaType: 'post', refresh: true);
      }
    });
  }

  Future<Map<String, DocumentInfo>> _fetchDocumentsByIds(
    List<String> ids,
  ) async {
    // Only fetch IDs we haven't cached yet
    final missingIds = ids.where((id) => !_cachedDocuments.containsKey(id)).toList();
    if (missingIds.isEmpty) return _cachedDocuments;

    final token = await SessionPrefs.instance.getAccessToken();

    final service = DocumentService();
    final res = await service.getDocumentsByIds(
      ids: missingIds,
      accessToken: token.isNotEmpty ? token : null,
    );

    final success = res['success'] as bool?;
    if (success == false) return _cachedDocuments;

    final list = res['data'] as List<dynamic>? ?? const [];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final doc = DocumentInfo.fromJson(item);
          _cachedDocuments[doc.id] = doc;
        } catch (_) {}
      }
    }
    return _cachedDocuments;
  }

  bool _isVideoFromDoc(DocumentInfo doc) {
    return doc.type == DocumentType.video ||
        doc.url.toLowerCase().endsWith('.mp4') ||
        doc.url.toLowerCase().contains('/video/upload/');
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final media = postState.feedPosts
        .where((m) => m.mediaType?.toLowerCase() == 'post')
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

    if (postState.feedStatus == PostStatus.loading && media.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<Map<String, DocumentInfo>>(
      future: _documentsFuture,
      builder: (context, snapshot) {
        final docs = snapshot.data ?? <String, DocumentInfo>{};

        final items =
            <
              ({
                String url,
                bool isVideo,
                String author,
                String? mediaId,
                int totalComments,
                int totalLikes,
                int totalViews,
                String description,
              })
            >[];
        for (final m in media) {
          final doc = resolvePreferredDocument(m.documentId, docs);
          final mediaUrl = doc != null
              ? (doc.url.startsWith('http://')
                    ? doc.url.replaceFirst('http://', 'https://')
                    : doc.url)
              : 'https://placehold.co/400x400/1e1e1e/FFFFFF/png?text=Media+Missing';

          if (doc == null) {
            debugPrint(
              'PostFeedGrid: Document lookup failed for media ${m.id}. Defaulting to placeholder url.',
            );
          }
          final reach = m.reach;
          final likesMap = reach?.reactionsCount ?? reach?.reactionCount ?? {};
          final totalLikes = (likesMap['like'] as num?)?.toInt() ?? 0;
          items.add((
            url: mediaUrl,
            isVideo: doc != null ? _isVideoFromDoc(doc) : false,
            author: 'User',
            mediaId: m.id,
            totalComments: reach?.totalComments ?? 0,
            totalLikes: totalLikes,
            totalViews: reach?.totalViews ?? 0,
            description: m.description ?? '',
          ));
        }

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Text(
                'No posts available',
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
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  final mediaItems = items
                      .map(
                        (i) => MediaItem(
                          mediaUrl: i.url,
                          isVideo: i.isVideo,
                          recipientId: i.author,
                          profileName: i.author,
                          profilePhotoUrl: null,
                          category: 'Creator',
                          subcategory: '',
                          proficiency: 'PROFESSIONAL',
                          mediaId: i.mediaId,
                          totalComments: i.totalComments,
                          totalLikes: i.totalLikes,
                          totalViews: i.totalViews,
                          description: i.description,
                        ),
                      )
                      .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPostViewScreen(
                        mediaItems: mediaItems,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
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
                        Container(
                          color: Colors.black.withValues(alpha: 0.2),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
