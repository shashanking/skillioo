import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
  final Set<String> _feedFetchInFlight = <String>{};
  // In-session cache: targetId → reactionId.
  final Map<String, String> _myReactionIds = <String, String>{};
  // Tracks which post IDs have had their liked-status verified via getMyReactions
  // this session, so we don't issue redundant network calls.
  final Set<String> _checkedPostIds = <String>{};
  String? _canonicalUserRefId;
  static const int _defaultMediaLimit = 1000;

  PostNotifier(this._postService, this._documentService)
    : super(const PostState());

  void clearFeedCache() {
    _feedPageByType.clear();
    _feedHasMoreByType.clear();
    _checkedPostIds.clear();
    state = state.copyWith(
      feedPosts: [],
      feedPage: 1,
      feedHasMore: false,
      feedStatus: PostStatus.initial,
    );
  }

  // Check whether the current user has reacted to [targetId] and update
  // likedPostIds accordingly. Called in the background after feed loads.
  Future<void> _checkMyReaction(String targetId) async {
    if (_checkedPostIds.contains(targetId)) return;
    _checkedPostIds.add(targetId);
    try {
      final response = await _postService.getMyReactions(targetId, limit: 1, page: 1);
      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final rawList = _extractListFromData(response['data']);
        final isLiked = rawList.isNotEmpty;
        final currentlyLiked = state.likedPostIds.contains(targetId);
        if (isLiked == currentlyLiked) return;
        final updated = Set<String>.from(state.likedPostIds);
        if (isLiked) {
          updated.add(targetId);
          // Cache the reaction ID for later reference.
          if (rawList.first is Map) {
            try {
              final reaction = ReactionResponse.fromJson(
                Map<String, dynamic>.from(rawList.first as Map),
              );
              if (reaction.id != null) _myReactionIds[targetId] = reaction.id!;
            } catch (_) {}
          }
        } else {
          updated.remove(targetId);
        }
        state = state.copyWith(likedPostIds: updated);
      }
    } catch (e) {
      // Allow retry on next interaction by un-marking this post.
      _checkedPostIds.remove(targetId);
      if (kDebugMode) debugPrint('_checkMyReaction error ($targetId): $e');
    }
  }

  // Fire-and-forget background preload of liked status for a list of posts.
  void _preloadLikedStatuses(List<String> targetIds) {
    Future(() async {
      for (final id in targetIds) {
        await _checkMyReaction(id);
      }
    });
  }

  Future<bool> _ensurePostAuth({bool required = true}) async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) {
      if (required) return false;
      return true;
    }
    _postService.setAuthToken(token);
    return true;
  }

  /// Ensures a shortUser record exists in the Post MS for this user.
  /// Creates one if it doesn't exist (404 from getShortUser).
  Future<void> _ensureShortUserExists(String referenceId) async {
    try {
      final profile = await SessionPrefs.instance.getProfile();
      final nickName = profile?['nickName'] as String? ?? '';
      final photoUrl = profile?['profilePhotoUrl'] as String? ?? '';

      // Try to get existing shortUser — if it exists, we're done
      try {
        final existing = await _postService.getShortUser(nickName: nickName);
        final status = existing['status'] as int? ?? 0;
        if (status == 200) return;
      } catch (_) {
        // Not found or error — proceed to create
      }

      // Create shortUser
      await _postService.createShortUser({
        'nickName': nickName,
        'profilePictureUrl': photoUrl,
        'referenceId': referenceId,
      });
      debugPrint('PostMS: Created shortUser for $referenceId');
    } catch (e) {
      debugPrint('PostMS: _ensureShortUserExists error: $e');
      // Non-fatal — createMedia might still work if shortUser already exists
    }
  }

  Future<String> _resolveCity() async {
    try {
      final profile = await SessionPrefs.instance.getProfile();
      if (profile != null) {
        // Only use the top-level city if present
        final city = profile['city']?.toString().trim() ?? '';
        if (city.isNotEmpty) return city;
      }
    } catch (_) {}

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('PostMS: Location services disabled');
        return '';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('PostMS: Location permission denied');
        return '';
      }

      // 1. Try last known position first (very fast)
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (e) {
        debugPrint('PostMS: getLastKnownPosition error: $e');
      }

      // 2. If no last known, try current position with a shorter timeout
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (e) {
          debugPrint('PostMS: getCurrentPosition error: $e');
          position = null;
        }
      }

      if (position == null) {
        debugPrint('PostMS: Could not resolve position');
        return '';
      }

      // 3. Reverse geocode with a timeout
      final placemarks =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('PostMS: placemarkFromCoordinates timed out');
              return [];
            },
          );

      if (placemarks.isEmpty) return '';

      final placemark = placemarks.first;
      // Try to find a city name in common fields
      final city =
          placemark.locality?.trim() ??
          placemark.subLocality?.trim() ??
          placemark.administrativeArea?.trim() ??
          '';

      if (city.isNotEmpty) {
        debugPrint('PostMS: Resolved city: $city');
        return city;
      }
    } catch (e) {
      debugPrint('PostMS resolve city error: $e');
    }

    return '';
  }

  List<dynamic> _extractListFromData(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      // Try common wrapper keys in priority order
      for (final key in const [
        'media',
        'items',
        'data',
        'posts',
        'reels',
        'results',
        'records',
        'rows',
        'documents',
        'content',
      ]) {
        final val = data[key];
        if (val is List) return val;
      }
      // If we don't know the key, just find the first list
      for (final key in data.keys) {
        if (data[key] is List) {
          debugPrint('PostMS _extractListFromData: found list in key: $key');
          return data[key] as List;
        }
      }
      debugPrint(
        'PostMS _extractListFromData: no list found in Map keys=${data.keys.toList()}',
      );
    }
    if (data != null) {
      debugPrint(
        'PostMS _extractListFromData: unexpected data type=${data.runtimeType}',
      );
    }
    return const [];
  }

  MediaReach? _parseMediaReach(dynamic raw) {
    if (raw is! Map) return null;

    // Handle reactionCount being a stringified JSON (e.g. "{}")
    Map<String, dynamic>? parseMapField(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is String) {
        try {
          final decoded = json.decode(value);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return null;
    }

    return MediaReach(
      totalComments: (raw['totalComments'] as num?)?.toInt(),
      reactionsCount: parseMapField(raw['reactionsCount']),
      reactionCount: parseMapField(raw['reactionCount']),
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
      final mediaUrl =
          (raw['mediaUrl'] ?? raw['url'] ?? raw['videoUrl'] ?? raw['fileUrl'])
              ?.toString();
      final createdAtRaw =
          raw['createdAt'] ?? raw['created_at'] ?? raw['updatedAt'];
      DateTime? createdAt;
      if (createdAtRaw is DateTime) {
        createdAt = createdAtRaw;
      } else if (createdAtRaw != null) {
        createdAt = DateTime.tryParse(createdAtRaw.toString());
      }

      // Parse shortUser if present (backend now embeds profile info)
      MediaShortUser? shortUser;
      final shortUserRaw = raw['shortUser'];
      if (shortUserRaw is Map) {
        try {
          shortUser = MediaShortUser(
            nickName: shortUserRaw['nickName']?.toString(),
            name: shortUserRaw['name']?.toString(),
            profilePictureUrl: shortUserRaw['profilePictureUrl']?.toString(),
            userReferenceId: shortUserRaw['userReferenceId']?.toString(),
            category: shortUserRaw['category']?.toString(),
            subCategory: shortUserRaw['subCategory']?.toString(),
          );
        } catch (_) {}
      }

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
        mediaType:
            raw['mediaType']?.toString().toLowerCase() ??
            fallbackMediaType?.toLowerCase(),
        userReferenceId: raw['userReferenceId']?.toString(),
        mediaUrl: mediaUrl,
        createdAt: createdAt,
        shortUser: shortUser,
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
      final token = await SessionPrefs.instance.getAccessToken();
      final uploadResponse = await _documentService.uploadDocument(
        file: mediaFile,
        type: docType,
        accessToken: token.isNotEmpty ? token : null,
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

      // 2. Get user reference ID for Post MS and ensure shortUser exists
      final userReferenceId = await SessionPrefs.instance.getProfileId();
      if (userReferenceId.isEmpty) {
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage: 'User not logged in',
        );
        return false;
      }

      // Ensure the user has a shortUser record in Post MS
      await _ensureShortUserExists(userReferenceId);

      // 3. Create the media post
      state = state.copyWith(createStatus: PostCreateStatus.creatingPost);

      String city = await _resolveCity();
      if (city.isEmpty) {
        // Fallback: Check if we have city in address object in profile
        try {
          final profile = await SessionPrefs.instance.getProfile();
          city = profile?['address']?['city']?.toString().trim() ?? '';
        } catch (_) {}
      }

      if (city.isEmpty) {
        state = state.copyWith(
          createStatus: PostCreateStatus.error,
          errorMessage:
              'City is mandatory. Please enable location or update your profile.',
        );
        return false;
      }

      final request = CreateMediaRequest(
        description: description,
        documentId: [documentId],
        mentions: mentions ?? const <String>[],
        userReferenceId: userReferenceId,
        mediaType: effectiveMediaType,
        city: city,
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
        // Fetch both posts and reels together to ensure profile tab shows all content
        fetchUserPostsPostsAndReels(
          userReferenceId: userReferenceId,
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
      // Don't clear userPosts here - we'll replace it after successful fetch
    );

    try {
      final postResponse = await _postService.getMediaByUser(
        userReferenceId,
        service: 'media',
        mediaType: 'post',
        limit: _defaultMediaLimit,
        page: page,
      );

      final reelResponse = await _postService.getMediaByUser(
        userReferenceId,
        service: 'media',
        mediaType: 'reel',
        limit: _defaultMediaLimit,
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

      // When refreshing, replace all content with fresh data from server
      // When paginating, append to existing items
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
        userPostsHasMore:
            posts.length >= _defaultMediaLimit ||
            reels.length >= _defaultMediaLimit,
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
    String? city,
  }) async {
    final hasAuth = await _ensurePostAuth(required: false);
    if (!hasAuth) {
      state = state.copyWith(
        feedStatus: PostStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    // Prevent concurrent fetches for the same mediaType
    if (_feedFetchInFlight.contains(mediaType)) return;

    final page = refresh ? 1 : (_feedPageByType[mediaType] ?? 1);
    final hasMoreForType = _feedHasMoreByType[mediaType] ?? true;
    if (!refresh && !hasMoreForType && page > 1) return;

    _feedFetchInFlight.add(mediaType);
    state = state.copyWith(feedStatus: PostStatus.loading, errorMessage: '');

    try {
      final response = await _postService.getMedia(
        mediaType: mediaType,
        limit: _defaultMediaLimit,
        page: page,
        city: city,
      );

      // Always log response shape to help diagnose structure changes
      final rawData = response['data'];
      debugPrint(
        'PostMS getMedia: mediaType=$mediaType page=$page '
        'status=${response['status']} '
        'message=${response['message']} '
        'dataType=${rawData.runtimeType} '
        'dataIsMap=${rawData is Map} '
        'dataIsList=${rawData is List} '
        '${rawData is List ? 'listLen=${rawData.length}' : ''}'
        '${rawData is Map ? 'mapKeys=${(rawData).keys.toList()}' : ''}',
      );

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final dataList = _extractListFromData(rawData);
        final posts = _parseMediaList(dataList, mediaType);
        debugPrint(
          'PostMS fetchFeed: extracted ${dataList.length} raw items, '
          'parsed ${posts.length} valid models '
          '(mediaType=$mediaType)',
        );
        if (dataList.isNotEmpty) {
          final sample = dataList.first;
          debugPrint(
            'PostMS fetchFeed: first raw item type=${sample.runtimeType} '
            '${sample is Map ? 'keys=${sample.keys.toList()}' : 'value=$sample'}',
          );
        }

        final typeKey = mediaType;
        final currentOtherTypes = state.feedPosts
            .where((m) => m.mediaType != typeKey)
            .toList();

        List<MediaResponse> nextSameType;
        if (refresh) {
          nextSameType = posts;
        } else {
          final currentSameType = state.feedPosts
              .where((m) => m.mediaType == typeKey)
              .toList();
          nextSameType = [...currentSameType, ...posts];
        }

        // Deduplicate by ID to prevent duplicates from concurrent fetches
        final seen = <String>{};
        final deduped = <MediaResponse>[];
        for (final post in [...currentOtherTypes, ...nextSameType]) {
          final id = post.id ?? '';
          if (id.isEmpty || seen.add(id)) {
            deduped.add(post);
          }
        }

        final nextPage = page + 1;
        final hasMore = posts.length >= _defaultMediaLimit;
        _feedPageByType[mediaType] = nextPage;
        _feedHasMoreByType[mediaType] = hasMore;

        state = state.copyWith(
          feedStatus: PostStatus.success,
          feedPosts: deduped,
          feedPage: nextPage,
          feedHasMore: hasMore,
        );

        // Preload liked status for newly fetched posts in the background so
        // the like button shows the correct state before the user interacts.
        _preloadLikedStatuses(
          posts
              .map((p) => p.id)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList(),
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
    } finally {
      _feedFetchInFlight.remove(mediaType);
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
        limit: _defaultMediaLimit,
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
        if (kDebugMode) {
          debugPrint(
            'PostMS fetchFeed: extracted ${dataList.length} raw items, parsed ${posts.length} valid models. rawData keys: ${response['data'] is Map ? (response['data'] as Map).keys : "List"}',
          );
        }

        final typeKey = mediaType;
        final currentSameType = typeKey == null
            ? state.userPosts
            : state.userPosts.where((m) => m.mediaType == typeKey).toList();
        final currentOtherTypes = typeKey == null
            ? <MediaResponse>[]
            : state.userPosts.where((m) => m.mediaType != typeKey).toList();

        // When refreshing, prepend new posts to show latest first
        // This ensures newly created posts appear at top without losing existing ones
        final nextSameType = refresh
            ? [...posts, ...currentSameType]
            : [...currentSameType, ...posts];

        state = state.copyWith(
          userPostsStatus: PostStatus.success,
          // Keep other media types in cache so other tabs don't go empty
          userPosts: typeKey == null
              ? nextSameType
              : [...currentOtherTypes, ...nextSameType],
          userPostsPage: page + 1,
          userPostsHasMore: posts.length >= _defaultMediaLimit,
        );

        _preloadLikedStatuses(
          posts
              .map((p) => p.id)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList(),
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
    if (_canonicalUserRefId != null) return _canonicalUserRefId!;

    final profileId = (await SessionPrefs.instance.getProfileId()).trim();

    // Post MS normalises userReferenceId to the User entity's referenceId
    // (e.g. "user_12346"), not the profile UUID stored in SessionPrefs.
    // Fetch the canonical reference lazily via shortUser and cache it.
    try {
      final nickName = (await SessionPrefs.instance.getNickName()).trim();
      if (nickName.isNotEmpty) {
        final res = await _postService.getShortUser(nickName: nickName);
        final status = res['status'] as int? ?? 0;
        if (status == 200 && res['data'] is Map) {
          final shortUser = ShortUserResponse.fromJson(
            Map<String, dynamic>.from(res['data'] as Map),
          );
          if (kDebugMode) {
            debugPrint(
              'resolveInteractionUserRefId: shortUser.referenceId=${shortUser.referenceId} profileId=$profileId',
            );
          }
          final ref = shortUser.referenceId?.trim() ?? '';
          if (ref.isNotEmpty) {
            _canonicalUserRefId = ref;
            return ref;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('resolveInteractionUserRefId shortUser error: $e');
    }

    // Fallback: use profile id (UUID); mismatch with reactions is logged
    // downstream so we can confirm the field name when shortUser is unavailable.
    return profileId.isNotEmpty
        ? profileId
        : (await SessionPrefs.instance.getNickName()).trim();
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
        if (kDebugMode) {
          debugPrint('=== fetchComments response (${rawList.length} items) ===');
          for (int i = 0; i < rawList.length; i++) {
            final item = rawList[i] is Map ? Map<String, dynamic>.from(rawList[i] as Map) : null;
            debugPrint('Comment[$i] keys: ${item?.keys.toList()}');
            debugPrint('Comment[$i] shortUser: ${item?['shortUser']}');
          }
          debugPrint('=== end fetchComments ===');
        }
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
    CommentShortUser? currentUserShort,
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
        shortUser: currentUserShort ??
            CommentShortUser(userReferenceId: userRefId),
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
              shortUser: currentUserShort ??
                  CommentShortUser(userReferenceId: userRefId),
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

  // ── Replies ──

  Future<void> fetchReplies({required String commentId}) async {
    if (!_isValidPostTargetId(commentId)) return;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return;

    // Mark loading for this comment's replies
    final newStatusMap = Map<String, PostStatus>.from(state.commentRepliesStatus);
    newStatusMap[commentId] = PostStatus.loading;
    state = state.copyWith(commentRepliesStatus: newStatusMap);

    try {
      final response = await _postService.getComments(
        commentId,
        limit: 50,
        page: 1,
      );

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final rawList = _extractListFromData(response['data']);
        final replies = <CommentResponse>[];
        for (final item in rawList) {
          if (item is Map) {
            try {
              replies.add(
                CommentResponse.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (e) {
              if (kDebugMode) debugPrint('PostNotifier parse reply: $e');
            }
          }
        }

        final newRepliesMap =
            Map<String, List<CommentResponse>>.from(state.commentReplies);
        newRepliesMap[commentId] = replies;
        final newStatus =
            Map<String, PostStatus>.from(state.commentRepliesStatus);
        newStatus[commentId] = PostStatus.success;

        state = state.copyWith(
          commentReplies: newRepliesMap,
          commentRepliesStatus: newStatus,
        );
      } else {
        final newStatus =
            Map<String, PostStatus>.from(state.commentRepliesStatus);
        newStatus[commentId] = PostStatus.error;
        state = state.copyWith(commentRepliesStatus: newStatus);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchReplies error: $e');
      final newStatus =
          Map<String, PostStatus>.from(state.commentRepliesStatus);
      newStatus[commentId] = PostStatus.error;
      state = state.copyWith(commentRepliesStatus: newStatus);
    }
  }

  Future<bool> createReply({
    required String commentId,
    required String text,
    CommentShortUser? currentUserShort,
  }) async {
    if (!_isValidPostTargetId(commentId)) return false;
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return false;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return false;

    try {
      final userRefId = await _resolveInteractionUserReferenceId();
      if (userRefId.isEmpty) return false;

      // Optimistic insert
      final optimisticReply = CommentResponse(
        id: 'temp_reply_${DateTime.now().microsecondsSinceEpoch}',
        userReferenceId: userRefId,
        type: 'reply',
        content: CommentContent(text: trimmedText, mentions: const []),
        reach: null,
        shortUser: currentUserShort ??
            CommentShortUser(userReferenceId: userRefId),
      );

      final newRepliesMap =
          Map<String, List<CommentResponse>>.from(state.commentReplies);
      final existing = newRepliesMap[commentId] ?? [];
      newRepliesMap[commentId] = [...existing, optimisticReply];
      state = state.copyWith(commentReplies: newRepliesMap);

      final response = await _postService.createComment({
        'targetId': commentId,
        'userReferenceId': userRefId,
        'type': 'reply',
        'content': {'text': trimmedText, 'mentions': <String>[]},
      });

      final status = response['status'] as int? ?? 0;
      if (status == 201 || status == 200) {
        // Refetch replies from server for consistency
        fetchReplies(commentId: commentId);
        return true;
      }

      // Rollback optimistic insert on failure
      final rollbackMap =
          Map<String, List<CommentResponse>>.from(state.commentReplies);
      rollbackMap[commentId] = (rollbackMap[commentId] ?? [])
          .where((r) => r.id != optimisticReply.id)
          .toList();
      state = state.copyWith(commentReplies: rollbackMap);
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('createReply error: $e');
      return false;
    }
  }

  Future<bool> toggleCommentLike({
    required String commentId,
    String reactionType = 'like',
  }) async {
    if (!_isValidPostTargetId(commentId)) return false;
    final hasAuth = await _ensurePostAuth();
    if (!hasAuth) return false;

    try {
      final userRefId = await _resolveInteractionUserReferenceId();
      if (userRefId.isEmpty) return false;

      final isCurrentlyLiked = state.likedCommentIds.contains(commentId);

      // Optimistic UI update
      final newLikedCommentIds = Set<String>.from(state.likedCommentIds);
      if (isCurrentlyLiked) {
        newLikedCommentIds.remove(commentId);
      } else {
        newLikedCommentIds.add(commentId);
      }

      // Update like count in comments list
      final updatedComments = state.comments.map((c) {
        if (c.id == commentId) {
          return _updateCommentReachCount(c, reactionType, !isCurrentlyLiked);
        }
        return c;
      }).toList();

      // Also update in replies maps
      final updatedReplies =
          Map<String, List<CommentResponse>>.from(state.commentReplies);
      for (final entry in updatedReplies.entries) {
        updatedReplies[entry.key] = entry.value.map((c) {
          if (c.id == commentId) {
            return _updateCommentReachCount(c, reactionType, !isCurrentlyLiked);
          }
          return c;
        }).toList();
      }

      state = state.copyWith(
        likedCommentIds: newLikedCommentIds,
        comments: updatedComments,
        commentReplies: updatedReplies,
      );

      // DELETE /v1/reaction?userReferenceId=<uuid>&targetId=<commentId>
      bool success = false;
      if (isCurrentlyLiked) {
        // Unlike
        try {
          final response = await _postService.deleteReaction(
            targetId: commentId,
            userReferenceId: userRefId,
          );
          final status = response['status'] as int? ?? 0;
          success = status == 200;
        } catch (e) {
          if (kDebugMode) debugPrint('toggleCommentLike deleteReaction error: $e');
        }
      } else {
        // Like
        try {
          final response = await _postService.createReaction({
            'targetId': commentId,
            'userReferenceId': userRefId,
            'reactionType': reactionType,
          });
          final status = response['status'] as int? ?? 0;
          success = status == 201 || status == 200;
        } catch (e) {
          if (kDebugMode) debugPrint('toggleCommentLike createReaction error: $e');
        }
      }

      if (!success) {
        // Rollback optimistic update on failure
        final rollbackLiked = Set<String>.from(state.likedCommentIds);
        if (isCurrentlyLiked) {
          rollbackLiked.add(commentId);
        } else {
          rollbackLiked.remove(commentId);
        }

        final rollbackComments = state.comments.map((c) {
          if (c.id == commentId) {
            return _updateCommentReachCount(
                c, reactionType, isCurrentlyLiked);
          }
          return c;
        }).toList();

        final rollbackReplies =
            Map<String, List<CommentResponse>>.from(state.commentReplies);
        for (final entry in rollbackReplies.entries) {
          rollbackReplies[entry.key] = entry.value.map((c) {
            if (c.id == commentId) {
              return _updateCommentReachCount(
                  c, reactionType, isCurrentlyLiked);
            }
            return c;
          }).toList();
        }

        state = state.copyWith(
          likedCommentIds: rollbackLiked,
          comments: rollbackComments,
          commentReplies: rollbackReplies,
        );
      }

      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('toggleCommentLike error: $e');
      return false;
    }
  }

  CommentResponse _updateCommentReachCount(
    CommentResponse comment,
    String reactionType,
    bool isAdd,
  ) {
    final reach = comment.reach;

    Map<String, dynamic> newReactionsCount = {};
    if (reach?.reactionsCount != null) {
      newReactionsCount = Map<String, dynamic>.from(reach!.reactionsCount!);
    }
    final currentTypeCount =
        (newReactionsCount[reactionType] as num?)?.toInt() ?? 0;
    newReactionsCount[reactionType] = isAdd
        ? currentTypeCount + 1
        : (currentTypeCount > 0 ? currentTypeCount - 1 : 0);

    Map<String, dynamic> newReactionCount = {};
    if (reach?.reactionCount != null) {
      newReactionCount = Map<String, dynamic>.from(reach!.reactionCount!);
    }
    final currentTotal = (newReactionCount['total'] as num?)?.toInt() ?? 0;
    newReactionCount['total'] = isAdd
        ? currentTotal + 1
        : (currentTotal > 0 ? currentTotal - 1 : 0);

    final newReach = MediaReach(
      totalComments: reach?.totalComments,
      totalViews: reach?.totalViews,
      reactionsCount: newReactionsCount,
      reactionCount: newReactionCount,
    );

    return CommentResponse(
      id: comment.id,
      userReferenceId: comment.userReferenceId,
      type: comment.type,
      content: comment.content,
      reach: newReach,
      shortUser: comment.shortUser,
    );
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

    // Direction is driven entirely by likedPostIds (session state), NOT by
    // whether we can find an existing reaction on the server. This avoids the
    // userReferenceId format-mismatch problem where getReactions returns entries
    // we can't match to the current user, making isAdd always true.
    final isAdd = !state.likedPostIds.contains(targetId);

    bool success = false;
    // true when server returns 500 "duplicate" on create — reaction already
    // exists, so we mark liked but skip adjusting the count (it's already correct).
    bool alreadyExisted = false;

    // Resolve user ref ID once — needed for both paths.
    final userRefId = await _resolveInteractionUserReferenceId();
    if (userRefId.isEmpty) return false;

    if (!isAdd) {
      // ── Remove (unlike) ──
      // DELETE /v1/reaction?userReferenceId=<uuid>&targetId=<postId>
      // The server accepts the UUID directly — no reaction _id needed.
      try {
        final response = await _postService.deleteReaction(
          targetId: targetId,
          userReferenceId: userRefId,
        );
        final status = response['status'] as int? ?? 0;
        if (status == 200) {
          _myReactionIds.remove(targetId);
          success = true;
        } else {
          if (kDebugMode) {
            debugPrint('toggleReaction deleteReaction status=$status');
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('toggleReaction deleteReaction error: $e');
      }
    } else {
      // ── Add (like) ──
      try {
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
              if (reaction.id != null) {
                _myReactionIds[targetId] = reaction.id!;
              }
              if (reaction.userReferenceId?.isNotEmpty == true) {
                _canonicalUserRefId ??= reaction.userReferenceId;
              }
              state = state.copyWith(reactions: [...state.reactions, reaction]);
            } catch (_) {}
          }
          success = true;
        } else {
          if (kDebugMode) {
            debugPrint('toggleReaction createReaction status=$status');
          }
        }
      } catch (e) {
        // Server returns 500 on duplicate reactions instead of 409.
        // Treat as "already liked" — mark success so the icon stays filled,
        // but skip count adjustment because the server count is already correct.
        if (kDebugMode) {
          debugPrint(
            'toggleReaction createReaction error: $e — treating as already-liked',
          );
        }
        success = true;
        alreadyExisted = true;
      }
    }

    if (success) {
      final newLikedPostIds = Set<String>.from(state.likedPostIds);
      if (isAdd) {
        newLikedPostIds.add(targetId);
      } else {
        newLikedPostIds.remove(targetId);
      }

      if (alreadyExisted) {
        // Reaction already existed on the server; count is correct — only
        // update likedPostIds so the UI reflects the true liked state.
        state = state.copyWith(likedPostIds: newLikedPostIds);
      } else {
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
    }

    return success;
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

    // Compute the current total reaction count from whichever field is available.
    // Server may send reactionCount as {like:4} (no 'total') or reactionsCount
    // as {like:4} — check all sources and take the largest non-zero value.
    int currentTotalCount = 0;
    if (reach.reactionCount != null && reach.reactionCount!['total'] != null) {
      currentTotalCount = (reach.reactionCount!['total'] as num).toInt();
    }
    if (currentTotalCount == 0 && reach.reactionsCount != null) {
      final fromTypeCounts = reach.reactionsCount!.values.fold<int>(
        0,
        (sum, val) => sum + ((val as num?)?.toInt() ?? 0),
      );
      if (fromTypeCounts > currentTotalCount) currentTotalCount = fromTypeCounts;
    }
    if (currentTotalCount == 0 && reach.reactionCount != null) {
      // Sum all values in reactionCount (e.g. {like:4} without a 'total' key)
      final fromReactionMap = reach.reactionCount!.values.fold<int>(
        0,
        (sum, val) => sum + ((val as num?)?.toInt() ?? 0),
      );
      if (fromReactionMap > currentTotalCount) currentTotalCount = fromReactionMap;
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
      mediaUrl: post.mediaUrl,
      createdAt: post.createdAt,
      shortUser: post.shortUser,
    );
  }

  void resetCreateStatus() {
    state = state.copyWith(
      createStatus: PostCreateStatus.initial,
      errorMessage: '',
    );
  }
}
