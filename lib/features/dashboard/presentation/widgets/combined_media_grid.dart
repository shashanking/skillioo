import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/custom_trending_carousel_components.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/services/session_state_provider.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../onboarding/domain/document_models.dart';
import 'media_document_resolver.dart';
import '../../../posts/application/post_providers.dart';
import '../../../posts/application/states/post_state.dart';
import '../../../posts/presentation/full_post_view.dart';
import '../../../posts/presentation/post_screen.dart';

class CombinedMediaGrid extends ConsumerStatefulWidget {
  const CombinedMediaGrid({super.key, this.cityFilter, this.searchQuery = ''});

  final String? cityFilter;
  final String searchQuery;

  @override
  ConsumerState<CombinedMediaGrid> createState() => CombinedMediaGridState();
}

class CombinedMediaGridState extends ConsumerState<CombinedMediaGrid> {
  String? _activeCityFilter;
  String? _activeCategory;
  Future<Map<String, DocumentInfo>>? _documentsFuture;
  List<String> _lastDocIds = const [];
  Map<String, DocumentInfo> _cachedDocuments = {};
  bool _didAutoRetry = false;

  Future<void> _refreshFeedPostsAndReels({String? city}) async {
    _activeCityFilter = city?.trim().isNotEmpty == true ? city!.trim() : null;
    // debugPrint(
    //   'CombinedMediaGrid: Refreshing feed with city=${_activeCityFilter}',
    // );
    final notifier = ref.read(postNotifierProvider.notifier);
    await notifier.fetchFeed(
      mediaType: 'post',
      refresh: true,
      city: _activeCityFilter,
    );
    await notifier.fetchFeed(
      mediaType: 'reel',
      refresh: true,
      city: _activeCityFilter,
    );
    ref.read(postNotifierProvider);
    // debugPrint(
    //   'CombinedMediaGrid: After refresh, feedPosts count=${postState.feedPosts.length} status=${postState.feedStatus}',
    // );
  }

  @override
  void didUpdateWidget(covariant CombinedMediaGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityFilter != widget.cityFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(postNotifierProvider.notifier).clearFeedCache();
        _refreshFeedPostsAndReels(city: widget.cityFilter);
        loadProfilesWithCategory(_activeCategory, city: widget.cityFilter);
      });
    }
  }

  Future<void> loadMorePosts() async {
    final postState = ref.read(postNotifierProvider);
    if (postState.feedStatus == PostStatus.loading) {
      return;
    }
    final notifier = ref.read(postNotifierProvider.notifier);
    await notifier.fetchFeed(mediaType: 'post', city: _activeCityFilter);
    await notifier.fetchFeed(mediaType: 'reel', city: _activeCityFilter);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only fetch if data isn't already loaded (Landing preloads shared data)
      final postState = ref.read(postNotifierProvider);
      if (postState.feedPosts.isEmpty &&
          postState.feedStatus != PostStatus.loading) {
        _refreshFeedPostsAndReels(city: widget.cityFilter);
      }
      final profileState = ref.read(profileListNotifierProvider);
      if (profileState.profiles.isEmpty && !profileState.isLoading) {
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(perPage: 50, refresh: true, city: widget.cityFilter);
      }
    });
  }

  void loadProfilesWithCategory(String? category, {String? city}) {
    setState(() {
      _activeCategory = category;
      _activeCityFilter = city?.trim().isNotEmpty == true ? city!.trim() : null;
    });
  }

  String _normalizeMediaUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Map<String, DocumentInfo>> _fetchDocumentsByIds(
    List<String> ids,
  ) async {
    final uniqueIds = ids
        .where((id) => id.trim().isNotEmpty && _uuidRegex.hasMatch(id.trim()))
        .toSet()
        .toList();
    final missingIds = uniqueIds
        .where((id) => !_cachedDocuments.containsKey(id))
        .toList();

    if (missingIds.isEmpty) {
      return Map.fromEntries(
        uniqueIds.map((id) => MapEntry(id, _cachedDocuments[id]!)),
      );
    }

    final token = await SessionPrefs.instance.getAccessToken();

    // Use the provider'd service so it goes through the shared retrying
    // HTTP client (auto-retries on 502/503/504/network errors).
    final service = ref.read(postDocumentServiceProvider);

    // Retry once on transient failures (Customer MS sometimes 502s at startup
    // and DocumentService swallows the error returning {success:false}).
    // Without this, every media item gets skipped at the build step
    // (mediaUrl ends up empty) and the grid renders empty even though the
    // feed itself loaded fine.
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
    bool firstSuccess = res['success'] == true;
    List<dynamic> firstData = res['data'] is List ? res['data'] as List : const [];
    debugPrint(
      'CombinedMediaGrid: docService attempt1 '
      'success=$firstSuccess returned=${firstData.length}/${missingIds.length} '
      'message=${res['message']}',
    );
    if (!firstSuccess || firstData.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      res = await attempt();
      final retrySuccess = res['success'] == true;
      final retryData = res['data'] is List ? res['data'] as List : const [];
      debugPrint(
        'CombinedMediaGrid: docService attempt2 '
        'success=$retrySuccess returned=${retryData.length}/${missingIds.length} '
        'message=${res['message']}',
      );
    }

    final success = res['success'] as bool?;
    if (success == false) {
      return Map.fromEntries(
        uniqueIds
            .where((id) => _cachedDocuments.containsKey(id))
            .map((id) => MapEntry(id, _cachedDocuments[id]!)),
      );
    }

    final list = res['data'] as List<dynamic>? ?? const [];
    // debugPrint('CombinedMediaGrid: docService returned ${list.length} documents');
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          final doc = DocumentInfo.fromJson(item);
          _cachedDocuments[doc.id] = doc;
        } catch (e) {
          // debugPrint('CombinedMediaGrid: doc parse error: $e item=$item');
        }
      }
    }

    final resolved = uniqueIds
        .where((id) => _cachedDocuments.containsKey(id))
        .toList();
    // debugPrint(
    //   'CombinedMediaGrid: resolved ${resolved.length}/${uniqueIds.length} documents',
    // );

    return Map.fromEntries(
      resolved.map((id) => MapEntry(id, _cachedDocuments[id]!)),
    );
  }

  int _objectIdEpochSeconds(String? id) {
    final value = (id ?? '').trim();
    if (value.length < 8) return 0;
    final hex = value.substring(0, 8);
    return int.tryParse(hex, radix: 16) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Auto-retry once if the first fetch transitions to error with empty data.
    // Handles transient cold-start failures (DNS, timeout, 502) so the UI
    // self-heals instead of stranding the user on an empty grid.
    ref.listen<PostState>(postNotifierProvider, (prev, next) {
      final wasLoading = prev?.feedStatus == PostStatus.loading;
      final nowError = next.feedStatus == PostStatus.error;
      if (wasLoading &&
          nowError &&
          next.feedPosts.isEmpty &&
          !_didAutoRetry) {
        _didAutoRetry = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          _refreshFeedPostsAndReels(city: widget.cityFilter);
        });
      }
    });

    final postState = ref.watch(postNotifierProvider);
    final profileState = ref.watch(profileListNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

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
        .where(
          (m) =>
              m.mediaType?.toLowerCase() == 'post' ||
              m.mediaType?.toLowerCase() == 'reel',
        )
        .toList();

    // debugPrint(
    //   'CombinedMediaGrid: Total feedPosts=${postState.feedPosts.length}, after mediaType filters=${feedMedia.length}, currentUserId=$currentUserId city=${_activeCityFilter}',
    // );

    final media =
        [...feedMedia].where((m) {
          final ownerId = (m.userReferenceId ?? '').trim();
          if (currentUserId.isNotEmpty && ownerId == currentUserId) {
            return false;
          }
          // Client-side category filter
          if (_activeCategory != null && _activeCategory!.isNotEmpty) {
            final profile = profileByUserRef[ownerId];
            final postCategory = profile?.category ?? m.shortUser?.category ?? '';
            if (!postCategory.toLowerCase().contains(_activeCategory!.toLowerCase())) {
              return false;
            }
          }
          return true;
        }).toList()..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeCompare = bTime.compareTo(aTime);
          if (timeCompare != 0) return timeCompare;
          return _objectIdEpochSeconds(
            b.id,
          ).compareTo(_objectIdEpochSeconds(a.id));
        });

    if (media.isNotEmpty && media.length <= 5) {
      // debugPrint(
      //   'CombinedMediaGrid: First ${media.length} feed items after sort: ${media.map((m) => 'feedId=${m.id} mediaType=${m.mediaType} documentIds=${m.documentId}').join(' | ')}',
      // );
    }

    final documentIds = media
        .expand((m) => m.documentId ?? const <String>[])
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();
    if (!listEquals(_lastDocIds, documentIds)) {
      _lastDocIds = documentIds;
      _documentsFuture = documentIds.isEmpty
          ? Future.value(<String, DocumentInfo>{})
          : _fetchDocumentsByIds(documentIds);
    }

    // debugPrint(
    //   'CombinedMediaGrid: feedStatus=${postState.feedStatus} '
    //   'feedPosts=${postState.feedPosts.length} '
    //   'afterFilter=${media.length} '
    //   'docIds=${documentIds.length} '
    //   'currentUserId=$currentUserId',
    // );

    if (postState.feedStatus == PostStatus.loading && media.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (postState.feedStatus == PostStatus.error &&
        postState.feedPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                postState.errorMessage.isNotEmpty
                    ? postState.errorMessage
                    : "We couldn't load the feed right now.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 44.h,
                child: TextButton(
                  onPressed: () =>
                      _refreshFeedPostsAndReels(city: widget.cityFilter),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, DocumentInfo>>(
      future: _documentsFuture ?? Future.value(<String, DocumentInfo>{}),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? <String, DocumentInfo>{};
        // debugPrint(
        //   'CombinedMediaGrid: docs snapshot=${snapshot.connectionState} '
        //   'docsLoaded=${docs.length} '
        //   'requestedDocIds=${documentIds.length} '
        //   'mediaCount=${media.length}',
        // );
        if (documentIds.isNotEmpty &&
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final postUrls =
            <
              ({
                String url,
                bool isVideo,
                String recipientId,
                String profileName,
                String? profilePhotoUrl,
                String proficiency,
                String category,
                String subCategory,
                String? mediaId,
                int totalComments,
                int totalLikes,
                int totalViews,
                String description,
                String nickName,
              })
            >[];

        for (final m in media) {
          final directUrl = (m.mediaUrl ?? '').trim();
          final userRef = (m.userReferenceId ?? '').trim();
          final profile = profileByUserRef[userRef];
          final shortUser = m.shortUser;
          final doc = resolvePreferredDocument(
            m.documentId,
            docs,
            preferVideo: (m.mediaType ?? '').toLowerCase() == 'reel',
          );
          final mediaUrl = directUrl.isNotEmpty
              ? _normalizeMediaUrl(directUrl)
              : doc != null
              ? _normalizeMediaUrl(doc.url)
              : '';

          if (mediaUrl.isEmpty) {
            // debugPrint(
            //   'CombinedMediaGrid: SKIP id=${m.id} '
            //   'mediaType=${m.mediaType} '
            //   'docIds=${m.documentId} '
            //   'directUrl=$directUrl '
            //   'docResolved=${doc != null}',
            // );
            continue;
          }

          final isVideo = (m.mediaType ?? '').toLowerCase() == 'reel'
              ? true
              : doc != null
              ? doc.type == DocumentType.video
              : false;

          // Use shortUser from API as primary source, fall back to profile list
          final displayName =
              profile?.displayName ??
              shortUser?.name ??
              shortUser?.nickName ??
              'User';
          final photoUrl =
              profile?.profilePhotoUrl ??
              (shortUser?.profilePictureUrl != null
                  ? _normalizeMediaUrl(shortUser!.profilePictureUrl!)
                  : null);
          final proficiency = profile?.proficiency ?? 'PROFESSIONAL';
          final category = profile?.category ?? shortUser?.category ?? '';
          final subCategory = shortUser?.subCategory ?? '';
          final nickName = profile?.nickName ?? shortUser?.nickName ?? '';

          postUrls.add((
            url: mediaUrl,
            isVideo: isVideo,
            recipientId: profile?.id ?? userRef,
            profileName: displayName,
            profilePhotoUrl: photoUrl,
            proficiency: proficiency,
            category: category,
            subCategory: subCategory,
            mediaId: m.id,
            totalComments: m.reach?.totalComments ?? 0,
            totalLikes:
                ((m.reach?.reactionsCount?['like'] as num?)?.toInt() ??
                (m.reach?.reactionCount?['like'] as num?)?.toInt() ??
                0),
            totalViews: m.reach?.totalViews ?? 0,
            description: m.description ?? '',
            nickName: nickName,
          ));
        }

        // Client-side search filter — match across every meaningful field
        // we have on the media item: name, nick, category/subcategory,
        // proficiency, and description.
        final query = widget.searchQuery.toLowerCase().trim();
        if (query.isNotEmpty) {
          bool matches(String s) =>
              s.isNotEmpty && s.toLowerCase().contains(query);
          postUrls.removeWhere((item) {
            return !(matches(item.profileName) ||
                matches(item.nickName) ||
                matches(item.category) ||
                matches(item.subCategory) ||
                matches(item.proficiency) ||
                matches(item.description));
          });
        }

        if (postUrls.isEmpty) {
          // debugPrint(
          //   'CombinedMediaGrid: no renderable media after document resolution. feedMedia=${feedMedia.length} documentIds=${documentIds.length}',
          // );
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
                              category: p.category.isNotEmpty
                                  ? p.category
                                  : 'Creator',
                              subcategory: p.subCategory,
                              proficiency: p.proficiency,
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
                                      Color.fromARGB(255, 57, 24, 188),
                                      Color(0xFFD370EF),
                                    ],
                                  ),
                                  borderRadius: 24.r,
                                  strokeWidth: 2.w,
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
                                color: Colors.white.withValues(alpha: 0.48),
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
  String _thumbnailUrl(String url) {
    // For Cloudinary videos, transform to a thumbnail by replacing
    // /video/upload/ → /video/upload/so_0/ and the extension with .jpg
    var resolved = url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;

    if (resolved.contains('/video/upload/')) {
      // Insert thumbnail transformation if not present
      if (!resolved.contains('/video/upload/so_')) {
        resolved = resolved.replaceFirst(
          '/video/upload/',
          '/video/upload/so_0,w_400,h_400,c_fill/',
        );
      }
      // Swap extension to .jpg
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
