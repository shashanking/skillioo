import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/domain/document_models.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../../../core/services/session_prefs.dart';
import '../../domain/post_models.dart';
import '../../domain/post_service.dart';
import '../states/post_state.dart';

class PostNotifier extends StateNotifier<PostState> {
  final PostService _postService;
  final DocumentService _documentService;
  final Map<String, int> _feedPageByType = <String, int>{};
  final Map<String, bool> _feedHasMoreByType = <String, bool>{};

  PostNotifier(this._postService, this._documentService)
    : super(const PostState());

  Future<bool> _ensurePostAuth() async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) {
      return false;
    }
    _postService.setAuthToken(token);
    return true;
  }

  List<dynamic> _extractListFromData(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final media = data['media'];
      if (media is List) return media;
      final items = data['items'];
      if (items is List) return items;
      final list = data['data'];
      if (list is List) return list;
    }
    return const [];
  }

  MediaReach? _parseMediaReach(dynamic raw) {
    if (raw is! Map) return null;

    return MediaReach(
      totalComments: (raw['totalComments'] as num?)?.toInt(),
      reactionsCount: raw['reactionsCount'] is Map
          ? Map<String, dynamic>.from(raw['reactionsCount'] as Map)
          : null,
      reactionCount: raw['reactionCount'] is Map
          ? Map<String, dynamic>.from(raw['reactionCount'] as Map)
          : null,
      totalViews: (raw['totalViews'] as num?)?.toInt(),
    );
  }

  MediaResponse? _parseMediaItem(
    Map<dynamic, dynamic> raw,
    String? fallbackMediaType,
  ) {
    try {
      final documentIds = raw['documentId'];
      final mentions = raw['mentions'];

      return MediaResponse(
        id: raw['_id']?.toString() ?? raw['id']?.toString(),
        description: raw['description']?.toString(),
        documentId: documentIds is List
            ? documentIds.map((e) => e.toString()).toList()
            : const <String>[],
        reach: _parseMediaReach(raw['reach']),
        mentions: mentions is List
            ? mentions.map((e) => e.toString()).toList()
            : const <String>[],
        mediaType: raw['mediaType']?.toString() ?? fallbackMediaType,
        userReferenceId: raw['userReferenceId']?.toString(),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('PostMS _parseMediaItem error: $error raw=$raw');
      }
      return null;
    }
  }

  List<MediaResponse> _parseMediaList(
    List<dynamic> raw,
    String? fallbackMediaType,
  ) {
    final out = <MediaResponse>[];
    for (final e in raw) {
      if (e is Map) {
        final parsed = _parseMediaItem(e, fallbackMediaType);
        if (parsed != null) {
          out.add(parsed);
        }
        continue;
      }
      if (e is String) {
        // Some endpoints may return just IDs.
        out.add(
          MediaResponse(
            id: e,
            mediaType: fallbackMediaType,
            documentId: const [],
          ),
        );
      }
    }
    return out;
  }

  bool _isVideoFile(File file) {
    final lower = file.path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv');
  }

  // ── Create Post ──

  /// Upload media file(s) and create a post/reel.
  Future<bool> createPost({
    required File mediaFile,
    required String mediaType,
    String? description,
    List<String>? mentions,
  }) async {
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) {
      state = state.copyWith(
        createStatus: PostCreateStatus.error,
        errorMessage: 'Not authenticated',
      );
      return false;
    }

    state = state.copyWith(
      createStatus: PostCreateStatus.uploadingMedia,
      errorMessage: '',
    );

    try {
      // 1. Upload the document
      final isVideo = _isVideoFile(mediaFile);
      final effectiveMediaType = isVideo ? 'reel' : mediaType;
      final docType = isVideo ? DocumentType.video : DocumentType.image;
      final uploadResponse = await _documentService.uploadDocument(
        file: mediaFile,
        type: docType,
      );

      final uploadSuccess = uploadResponse['success'] as bool? ?? false;
      if (!uploadSuccess) {
        final message = uploadResponse['message'] as String? ?? 'Upload failed';
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage: message,
        );
        return false;
      }

      final docData = uploadResponse['data'] as Map<String, dynamic>?;
      final docInfo = docData?['document'] as Map<String, dynamic>? ?? {};
      final documentId = docInfo['id'] as String? ?? '';

      if (documentId.isEmpty) {
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage: 'Failed to get document ID',
        );
        return false;
      }

      // 2. Get user reference ID for Post MS
      // Post MS identifies users by a reference string (commonly a nickname or referenceId),
      // not the internal customer profile id.
      final userReferenceId = await SessionPrefs.instance.getNickName();
      if (userReferenceId.isEmpty) {
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage: 'User not logged in',
        );
        return false;
      }

      // 3. Create the media post
      state = state.copyWith(createStatus: PostCreateStatus.creatingPost);

      final request = CreateMediaRequest(
        description: description,
        documentId: [documentId],
        mentions: mentions ?? const <String>[],
        userReferenceId: userReferenceId,
        mediaType: effectiveMediaType,
      );

      final response = await _postService.createMedia(request.toJson());
      if (kDebugMode) {
        debugPrint(
          'PostMS createMedia: userReferenceId=$userReferenceId mediaType=$mediaType status=${response['status']} message=${response['message']}',
        );
      }
      final status = response['status'] as int? ?? 0;

      if (status == 201 || status == 200) {
        // Optimistically insert into cached lists (if API returned media data)
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          try {
            final created = MediaResponse.fromJson(data);

            // Update userPosts cache
            final nextUserPosts = <MediaResponse>[
              created,
              ...state.userPosts,
            ].where((m) => m.id != null).toList();

            // Update feed cache (keep other media types)
            final others = state.feedPosts
                .where((m) => m.mediaType != created.mediaType)
                .toList();
            final sameType = state.feedPosts
                .where((m) => m.mediaType == created.mediaType)
                .toList();
            final nextFeed = <MediaResponse>[
              created,
              ...sameType,
              ...others,
            ].where((m) => m.id != null).toList();

            state = state.copyWith(
              userPosts: nextUserPosts,
              feedPosts: nextFeed,
            );
          } catch (_) {}
        }

        state = state.copyWith(createStatus: PostCreateStatus.success);

        // Refresh relevant lists so UI gets the canonical server state
        // (fire-and-forget)
        fetchFeed(mediaType: effectiveMediaType, refresh: true);
        fetchUserPosts(
          userReferenceId: userReferenceId,
          mediaType: effectiveMediaType,
          refresh: true,
        );
        return true;
      } else {
        final message =
            response['message'] as String? ?? 'Failed to create post';
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage: message,
        );
        return false;
      }
    } catch (e) {
      debugPrint('createPost error: $e');
      state = state.copyWith(
        createStatus: PostCreateStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> fetchUserPostsPostsAndReels({
    required String userReferenceId,
    bool refresh = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'PostMS fetchUserPostsPostsAndReels: start userReferenceId=$userReferenceId refresh=$refresh',
      );
    }

    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) {
      state = state.copyWith(
        userPostsStatus: PostStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    // Keep pagination simple for now: fetch the same page for both types.
    final page = refresh ? 1 : state.userPostsPage;
    if (!refresh && !state.userPostsHasMore && page > 1) return;

    state = state.copyWith(
      userPostsStatus: PostStatus.loading,
      errorMessage: '',
    );

    try {
      final postResponse = await _postService.getMediaByUser(
        userReferenceId,
        service: 'media',
        mediaType: 'post',
        limit: 20,
        page: page,
      );

      final reelResponse = await _postService.getMediaByUser(
        userReferenceId,
        service: 'media',
        mediaType: 'reel',
        limit: 20,
        page: page,
      );

      final postStatus = postResponse['status'] as int? ?? 0;
      final reelStatus = reelResponse['status'] as int? ?? 0;

      if (kDebugMode) {
        final postCount = postStatus == 200
            ? _extractListFromData(postResponse['data']).length
            : -1;
        final reelCount = reelStatus == 200
            ? _extractListFromData(reelResponse['data']).length
            : -1;
        debugPrint(
          'PostMS fetchUserPostsPostsAndReels: userReferenceId=$userReferenceId page=$page postStatus=$postStatus postItems=$postCount reelStatus=$reelStatus reelItems=$reelCount',
        );
      }

      if (postStatus != 200 && reelStatus != 200) {
        state = state.copyWith(
          userPostsStatus: PostStatus.error,
          errorMessage:
              (postResponse['message'] as String?) ??
              (reelResponse['message'] as String?) ??
              'Failed to fetch',
        );
        return;
      }

      final postList = postStatus == 200
          ? _extractListFromData(postResponse['data'])
          : const <dynamic>[];
      final reelList = reelStatus == 200
          ? _extractListFromData(reelResponse['data'])
          : const <dynamic>[];

      if (kDebugMode) {
        if (postList.isNotEmpty) {
          debugPrint(
            'PostMS fetchUserPostsPostsAndReels: firstPostRawType=${postList.first.runtimeType} firstPostRaw=${postList.first}',
          );
        }
        if (reelList.isNotEmpty) {
          debugPrint(
            'PostMS fetchUserPostsPostsAndReels: firstReelRawType=${reelList.first.runtimeType} firstReelRaw=${reelList.first}',
          );
        }
      }

      final posts = _parseMediaList(postList, 'post');
      final reels = _parseMediaList(reelList, 'reel');

      // Merge and de-dupe by id (keep first occurrence)
      final merged = <MediaResponse>[];
      final seen = <String>{};
      void addAll(List<MediaResponse> items) {
        for (final m in items) {
          final id = m.id ?? '';
          if (id.isEmpty) {
            merged.add(m);
            continue;
          }
          if (seen.add(id)) merged.add(m);
        }
      }

      if (refresh) {
        addAll(posts);
        addAll(reels);
      } else {
        addAll(state.userPosts);
        addAll(posts);
        addAll(reels);
      }

      state = state.copyWith(
        userPostsStatus: PostStatus.success,
        userPosts: merged,
        userPostsPage: page + 1,
        userPostsHasMore: posts.length >= 20 || reels.length >= 20,
      );

      if (kDebugMode) {
        debugPrint(
          'PostMS fetchUserPostsPostsAndReels: mergedItems=${merged.length} posts=${posts.length} reels=${reels.length}',
        );
      }
    } catch (e) {
      debugPrint('fetchUserPostsPostsAndReels error: $e');
      state = state.copyWith(
        userPostsStatus: PostStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Feed (all posts) ──

  Future<void> fetchFeed({
    required String mediaType,
    bool refresh = false,
  }) async {
    if (state.feedStatus == PostStatus.loading) return;

    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) {
      state = state.copyWith(
        feedStatus: PostStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    final page = refresh ? 1 : (_feedPageByType[mediaType] ?? 1);
    final hasMoreForType = _feedHasMoreByType[mediaType] ?? true;
    if (!refresh && !hasMoreForType && page > 1) return;

    state = state.copyWith(feedStatus: PostStatus.loading, errorMessage: '');

    try {
      final response = await _postService.getMedia(
        mediaType: mediaType,
        limit: 20,
        page: page,
      );

      if (kDebugMode) {
        final dataLen = (response['data'] is List)
            ? (response['data'] as List).length
            : -1;
        debugPrint(
          'PostMS getMedia: mediaType=$mediaType page=$page status=${response['status']} items=$dataLen message=${response['message']}',
        );
      }

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final dataList = _extractListFromData(response['data']);
        final posts = _parseMediaList(dataList, mediaType);

        final typeKey = mediaType;
        final currentSameType = state.feedPosts
            .where((m) => m.mediaType == typeKey)
            .toList();
        final currentOtherTypes = state.feedPosts
            .where((m) => m.mediaType != typeKey)
            .toList();

        final nextSameType = refresh ? posts : [...currentSameType, ...posts];
        final nextPage = page + 1;
        final hasMore = posts.length >= 20;
        _feedPageByType[mediaType] = nextPage;
        _feedHasMoreByType[mediaType] = hasMore;

        state = state.copyWith(
          feedStatus: PostStatus.success,
          // Keep other media types in cache so other screens don't go empty
          feedPosts: [...currentOtherTypes, ...nextSameType],
          feedPage: nextPage,
          feedHasMore: hasMore,
        );
      } else {
        state = state.copyWith(
          feedStatus: PostStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      debugPrint('fetchFeed error: $e');
      state = state.copyWith(
        feedStatus: PostStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── User Posts ──

  Future<void> fetchUserPosts({
    required String userReferenceId,
    String? mediaType,
    bool refresh = false,
  }) async {
    if (state.userPostsStatus == PostStatus.loading) return;

    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) {
      state = state.copyWith(
        userPostsStatus: PostStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    final page = refresh ? 1 : state.userPostsPage;
    if (!refresh && !state.userPostsHasMore && page > 1) return;

    state = state.copyWith(
      userPostsStatus: PostStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _postService.getMediaByUser(
        userReferenceId,
        service: 'media',
        mediaType: mediaType,
        limit: 20,
        page: page,
      );

      if (kDebugMode) {
        final dataLen = _extractListFromData(response['data']).length;
        debugPrint(
          'PostMS getMediaByUser: userReferenceId=$userReferenceId mediaType=$mediaType page=$page status=${response['status']} items=$dataLen message=${response['message']}',
        );
      }

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final dataList = _extractListFromData(response['data']);
        final posts = _parseMediaList(dataList, mediaType);

        final typeKey = mediaType;
        final currentSameType = typeKey == null
            ? state.userPosts
            : state.userPosts.where((m) => m.mediaType == typeKey).toList();
        final currentOtherTypes = typeKey == null
            ? <MediaResponse>[]
            : state.userPosts.where((m) => m.mediaType != typeKey).toList();

        final nextSameType = refresh ? posts : [...currentSameType, ...posts];

        state = state.copyWith(
          userPostsStatus: PostStatus.success,
          // Keep other media types in cache so other tabs don't go empty
          userPosts: typeKey == null
              ? nextSameType
              : [...currentOtherTypes, ...nextSameType],
          userPostsPage: page + 1,
          userPostsHasMore: posts.length >= 20,
        );
      } else {
        state = state.copyWith(
          userPostsStatus: PostStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      debugPrint('fetchUserPosts error: $e');
      state = state.copyWith(
        userPostsStatus: PostStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Delete Post ──

  Future<bool> deletePost(String mediaId) async {
    try {
      final hasAuth = await _ensurePostAuth();
      if (!hasAuth) {
        return false;
      }
      final response = await _postService.deleteMedia(mediaId);
      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        state = state.copyWith(
          feedPosts: state.feedPosts.where((p) => p.id != mediaId).toList(),
          userPosts: state.userPosts.where((p) => p.id != mediaId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('deletePost error: $e');
      return false;
    }
  }

  // ── Comments ──

  bool _isValidPostTargetId(String targetId) {
    final value = targetId.trim();
    if (value.isEmpty) return false;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return false;
    }
    return true;
  }

  Future<String> _resolveInteractionUserReferenceId() async {
    final profileId = (await SessionPrefs.instance.getProfileId()).trim();
    if (profileId.isNotEmpty) {
      return profileId;
    }
    return (await SessionPrefs.instance.getNickName()).trim();
  }

  Future<void> fetchComments({
    required String targetId,
    bool refresh = true,
  }) async {
    if (!_isValidPostTargetId(targetId)) {
      state = state.copyWith(
        commentsStatus: PostStatus.error,
        errorMessage: 'Invalid media target',
      );
      return;
    }
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) {
      state = state.copyWith(
        commentsStatus: PostStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    if (refresh || targetId != state.commentsTargetId) {
      final shouldResetComments = targetId != state.commentsTargetId;
      state = state.copyWith(
        commentsStatus: PostStatus.loading,
        commentsTargetId: targetId,
        comments: shouldResetComments ? const [] : state.comments,
        commentsPage: 1,
        commentsHasMore: true,
        errorMessage: '',
      );
    } else {
      if (!state.commentsHasMore) return;
      state = state.copyWith(
        commentsStatus: PostStatus.loading,
        errorMessage: '',
      );
    }

    try {
      final page = refresh ? 1 : state.commentsPage;
      final response = await _postService.getComments(
        targetId,
        limit: 20,
        page: page,
      );

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final rawList = _extractListFromData(response['data']);
        final comments = <CommentResponse>[];
        for (final item in rawList) {
          if (item is Map) {
            try {
              comments.add(
                CommentResponse.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (e) {
              if (kDebugMode) debugPrint('PostNotifier parse comment: $e');
            }
          }
        }

        final merged = refresh ? comments : [...state.comments, ...comments];

        state = state.copyWith(
          commentsStatus: PostStatus.success,
          comments: merged,
          commentsPage: page + 1,
          commentsHasMore: comments.length >= 20,
        );
      } else {
        state = state.copyWith(
          commentsStatus: PostStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchComments error: $e');
      state = state.copyWith(
        commentsStatus: PostStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createComment({
    required String targetId,
    required String text,
  }) async {
    if (!_isValidPostTargetId(targetId)) return false;
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return false;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return false;

    try {
      final userRefId = await _resolveInteractionUserReferenceId();
      if (userRefId.isEmpty) return false;
      final optimisticComment = CommentResponse(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
        userReferenceId: userRefId,
        type: 'comment',
        content: CommentContent(text: trimmedText, mentions: const []),
        reach: null,
      );
      state = state.copyWith(comments: [optimisticComment, ...state.comments]);

      final response = await _postService.createComment({
        'targetId': targetId,
        'userReferenceId': userRefId,
        'type': 'comment',
        'content': {'text': trimmedText, 'mentions': <String>[]},
      });

      final status = response['status'] as int? ?? 0;
      if (status == 201 || status == 200) {
        final data = response['data'];
        final createdComment =
            _parseCreatedComment(data) ??
            CommentResponse(
              id: null,
              userReferenceId: userRefId,
              type: 'comment',
              content: CommentContent(text: trimmedText, mentions: const []),
              reach: null,
            );
        state = state.copyWith(
          comments: [
            createdComment,
            ...state.comments.where((c) => c.id != optimisticComment.id),
          ],
        );
        fetchComments(targetId: targetId, refresh: true);
        return true;
      }
      state = state.copyWith(
        comments: state.comments
            .where((c) => c.id != optimisticComment.id)
            .toList(),
      );
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('createComment error: $e');
      fetchComments(targetId: targetId, refresh: true);
      return false;
    }
  }

  CommentResponse? _parseCreatedComment(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      try {
        return CommentResponse.fromJson(map);
      } catch (_) {}
      final nested = map['comment'];
      if (nested is Map) {
        try {
          return CommentResponse.fromJson(Map<String, dynamic>.from(nested));
        } catch (_) {}
      }
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      try {
        return CommentResponse.fromJson(Map<String, dynamic>.from(data.first));
      } catch (_) {}
    }
    return null;
  }

  Future<bool> deleteComment(String commentId) async {
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return false;

    try {
      final response = await _postService.deleteComment(commentId);
      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        state = state.copyWith(
          comments: state.comments.where((c) => c.id != commentId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('deleteComment error: $e');
      return false;
    }
  }

  // ── Reactions ──

  Future<void> fetchReactions({required String targetId}) async {
    if (!_isValidPostTargetId(targetId)) return;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return;

    state = state.copyWith(
      reactionsStatus: PostStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _postService.getReactions(targetId, limit: 50);
      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final rawList = _extractListFromData(response['data']);
        final reactions = <ReactionResponse>[];
        for (final item in rawList) {
          if (item is Map) {
            try {
              reactions.add(
                ReactionResponse.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (e) {
              if (kDebugMode) debugPrint('PostNotifier parse reaction: $e');
            }
          }
        }
        state = state.copyWith(
          reactionsStatus: PostStatus.success,
          reactions: reactions,
        );
      } else {
        state = state.copyWith(
          reactionsStatus: PostStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchReactions error: $e');
      state = state.copyWith(
        reactionsStatus: PostStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> toggleReaction({
    required String targetId,
    String reactionType = 'like',
  }) async {
    if (!_isValidPostTargetId(targetId)) return false;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return false;

    try {
      final userRefId = await _resolveInteractionUserReferenceId();
      if (userRefId.isEmpty) return false;

      ReactionResponse? existingReaction;
      final existingRes = await _postService.getReactions(
        targetId,
        limit: 100,
        page: 1,
      );
      final existingStatus = existingRes['status'] as int? ?? 0;
      if (existingStatus == 200) {
        final rawList = _extractListFromData(existingRes['data']);
        for (final item in rawList) {
          if (item is Map) {
            try {
              final reaction = ReactionResponse.fromJson(
                Map<String, dynamic>.from(item),
              );
              if (reaction.userReferenceId == userRefId &&
                  reaction.reactionType == reactionType) {
                existingReaction = reaction;
                break;
              }
            } catch (_) {}
          }
        }
      }

      final isAdd = existingReaction == null;
      bool success = false;

      if (!isAdd) {
        // Remove reaction
        final reactionId = existingReaction.id;
        if (reactionId != null) {
          final response = await _postService.deleteReaction(reactionId);
          final status = response['status'] as int? ?? 0;
          if (status == 200) {
            state = state.copyWith(
              reactions: state.reactions
                  .where((r) => r.id != reactionId)
                  .toList(),
            );
            success = true;
          }
        }
      } else {
        // Add reaction
        final response = await _postService.createReaction({
          'targetId': targetId,
          'userReferenceId': userRefId,
          'reactionType': reactionType,
        });

        final status = response['status'] as int? ?? 0;
        if (status == 201 || status == 200) {
          final data = response['data'];
          if (data is Map) {
            try {
              final reaction = ReactionResponse.fromJson(
                Map<String, dynamic>.from(data),
              );
              state = state.copyWith(reactions: [...state.reactions, reaction]);
            } catch (_) {}
          }
          success = true;
        }
      }

      if (success) {
        // Update liked target IDs in state
        final newLikedPostIds = Set<String>.from(state.likedPostIds);
        if (isAdd) {
          newLikedPostIds.add(targetId);
        } else {
          newLikedPostIds.remove(targetId);
        }

        // Optimistically update counts in feed and user posts
        final updatedFeed = state.feedPosts.map((post) {
          if (post.id == targetId) {
            return _updatePostReachCount(post, reactionType, isAdd);
          }
          return post;
        }).toList();

        final updatedUserPosts = state.userPosts.map((post) {
          if (post.id == targetId) {
            return _updatePostReachCount(post, reactionType, isAdd);
          }
          return post;
        }).toList();

        state = state.copyWith(
          feedPosts: updatedFeed,
          userPosts: updatedUserPosts,
          likedPostIds: newLikedPostIds,
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('toggleReaction error: $e');
      return false;
    }
  }

  MediaResponse _updatePostReachCount(
    MediaResponse post,
    String reactionType,
    bool isAdd,
  ) {
    if (post.reach == null) return post;

    final reach = post.reach!;

    // We try to update both reactionCount (total number) and reactionsCount (map by type)
    Map<String, dynamic> newReactionsCount = {};
    if (reach.reactionsCount != null) {
      newReactionsCount = Map<String, dynamic>.from(reach.reactionsCount!);
      final currentTypeCount =
          (newReactionsCount[reactionType] as num?)?.toInt() ?? 0;
      newReactionsCount[reactionType] = isAdd
          ? currentTypeCount + 1
          : (currentTypeCount > 0 ? currentTypeCount - 1 : 0);
    } else if (isAdd) {
      newReactionsCount[reactionType] = 1;
    }

    // Attempt to update total reaction count if it exists
    int currentTotalCount = 0;
    if (reach.reactionCount != null && reach.reactionCount!['total'] != null) {
      currentTotalCount = (reach.reactionCount!['total'] as num).toInt();
    } else {
      // Estimate total from reactionsCount map if it existed
      if (reach.reactionsCount != null) {
        currentTotalCount = reach.reactionsCount!.values.fold(
          0,
          (sum, val) => sum + ((val as num?)?.toInt() ?? 0),
        );
      }
    }

    final newTotalCount = isAdd
        ? currentTotalCount + 1
        : (currentTotalCount > 0 ? currentTotalCount - 1 : 0);
    Map<String, dynamic> newReactionCount = reach.reactionCount != null
        ? Map<String, dynamic>.from(reach.reactionCount!)
        : {};
    newReactionCount['total'] = newTotalCount;

    final newReach = MediaReach(
      totalComments: reach.totalComments,
      totalViews: reach.totalViews,
      reactionsCount: newReactionsCount,
      reactionCount: newReactionCount,
    );

    return MediaResponse(
      id: post.id,
      description: post.description,
      documentId: post.documentId,
      reach: newReach,
      mentions: post.mentions,
      mediaType: post.mediaType,
      userReferenceId: post.userReferenceId,
    );
  }

  void resetCreateStatus() {
    state = state.copyWith(
      createStatus: PostCreateStatus.initial,
      errorMessage: '',
    );
  }
}
