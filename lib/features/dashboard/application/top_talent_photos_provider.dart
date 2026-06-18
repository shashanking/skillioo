import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../posts/application/post_providers.dart';
import '../../posts/domain/post_models.dart';
import '../data/trending_talent_model.dart';

/// Carousel slot templates — these define the timer / fallback image / tint
/// for each of the 3 slots. Real user data (name, photo, likes, post count)
/// is overlaid by [topTalentsProvider] once the feed is loaded.
final _templates = [
  TrendingTalent(
    name: 'Top Artist',
    views: '—',
    likes: '—',
    timer: '1:25',
    imagePath: AppAssets.welcomeCardLeft,
    tintColor: const Color(0xFF8F39B2),
  ),
  TrendingTalent(
    name: 'Top Talent',
    views: '—',
    likes: '—',
    timer: '2:10',
    imagePath: AppAssets.welcomeCardCenter,
    tintColor: const Color(0xFF1A7F8F),
  ),
  TrendingTalent(
    name: 'Top Creator',
    views: '—',
    likes: '—',
    timer: '0:55',
    imagePath: AppAssets.welcomeCardRight,
    tintColor: const Color(0xFF2F208E),
  ),
];

/// Returns up to 3 [TrendingTalent] objects ranked by cumulative engagement.
/// Each entry carries the real user's name, profile photo, cumulative likes,
/// and total post count. Falls back to the static template when not enough
/// real data is available.
final topTalentsProvider = Provider<List<TrendingTalent>>((ref) {
  final feedPosts = ref.watch(
    postNotifierProvider.select((s) => s.feedPosts),
  );

  if (feedPosts.isEmpty) return _templates;

  final scores = <String, _UserScore>{};
  for (final post in feedPosts) {
    final userId =
        post.userReferenceId ?? post.shortUser?.userReferenceId ?? '';
    if (userId.isEmpty) continue;

    final score = scores.putIfAbsent(userId, () => _UserScore());
    final likes = _likesOf(post.reach);
    score.likes += likes;
    score.postCount++;
    score.engagementTotal += likes + (post.reach?.totalComments ?? 0);
    score.profileId = userId;

    if (score.url.isEmpty) {
      final raw = post.shortUser?.profilePictureUrl ?? '';
      if (raw.isNotEmpty) score.url = _normalizeUrl(raw);
    }
    if (score.name.isEmpty) {
      score.name =
          (post.shortUser?.name ?? post.shortUser?.nickName ?? '').trim();
    }
    // Feed is ordered latest-first; store the first post seen per user.
    score.latestPost ??= post;
  }

  final ranked = scores.values
      .where((s) => s.url.isNotEmpty)
      .toList()
    ..sort((a, b) => b.engagementTotal.compareTo(a.engagementTotal));

  return List.generate(_templates.length, (i) {
    final template = _templates[i];
    if (i >= ranked.length) return template;
    final s = ranked[i];
    return template.copyWith(
      name: s.name.isNotEmpty ? s.name : template.name,
      views: '${_fmt(s.postCount)} Media',
      likes: '${_fmt(s.likes)} Likes',
      profilePhotoUrl: s.url,
      profileId: s.profileId,
      latestPost: s.latestPost != null ? _toTrendingPost(s.latestPost!) : null,
    );
  });
});

// ── helpers ──────────────────────────────────────────────────────────────────

int _likesOf(MediaReach? reach) {
  if (reach == null) return 0;
  final rc = reach.reactionCount ?? reach.reactionsCount;
  if (rc == null) return 0;
  final total = rc['total'];
  if (total is num) return total.toInt();
  var sum = 0;
  for (final v in rc.values) {
    if (v is num) sum += v.toInt();
  }
  return sum;
}

String _normalizeUrl(String raw) =>
    raw.startsWith('http://') ? raw.replaceFirst('http://', 'https://') : raw;

String _fmt(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)}K';
  }
  return '$n';
}

TrendingPost _toTrendingPost(MediaResponse post) {
  final isVideo = (post.mediaType ?? '').toLowerCase() == 'reel';
  return TrendingPost(
    mediaUrl: post.mediaUrl,
    documentIds: post.documentId ?? const [],
    isVideo: isVideo,
    category: post.shortUser?.category ?? '',
    subCategory: post.shortUser?.subCategory ?? '',
    proficiency: 'PROFESSIONAL',
    description: post.description ?? '',
    mediaId: post.id,
    totalLikes: _likesOf(post.reach),
    totalComments: post.reach?.totalComments ?? 0,
    totalViews: post.reach?.totalViews ?? 0,
  );
}

class _UserScore {
  String url = '';
  String name = '';
  int likes = 0;
  int postCount = 0;
  int engagementTotal = 0;
  String profileId = '';
  MediaResponse? latestPost;
}
