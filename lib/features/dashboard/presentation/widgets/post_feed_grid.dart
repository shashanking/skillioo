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

class PostFeedGrid extends ConsumerStatefulWidget {
  const PostFeedGrid({super.key});

  @override
  ConsumerState<PostFeedGrid> createState() => _PostFeedGridState();
}

class _PostFeedGridState extends ConsumerState<PostFeedGrid> {
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(postNotifierProvider.notifier)
          .fetchFeed(mediaType: 'post', refresh: true);
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
    return doc.type == DocumentType.video ||
        doc.url.toLowerCase().endsWith('.mp4') ||
        doc.url.toLowerCase().contains('/video/upload/');
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final media = postState.feedPosts
        .where((m) => m.mediaType == 'post')
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
              })
            >[];
        for (final m in media) {
          final firstId = (m.documentId ?? const []).isEmpty
              ? null
              : (m.documentId ?? const []).first;
          if (firstId == null) continue;
          final doc = docs[firstId];
          if (doc == null) continue;
          final reach = m.reach;
          final likesMap = reach?.reactionsCount ?? reach?.reactionCount ?? {};
          final totalLikes = (likesMap['like'] as num?)?.toInt() ?? 0;
          items.add((
            url: doc.url,
            isVideo: _isVideoFromDoc(doc),
            author: m.userReferenceId ?? 'User',
            mediaId: m.id,
            totalComments: reach?.totalComments ?? 0,
            totalLikes: totalLikes,
            totalViews: reach?.totalViews ?? 0,
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
