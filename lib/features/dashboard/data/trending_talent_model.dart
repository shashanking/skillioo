import 'package:flutter/material.dart';

/// Minimal post data needed to open the full post view for a trending talent.
class TrendingPost {
  final String? mediaUrl;
  final List<String> documentIds;
  final bool isVideo;
  final String category;
  final String subCategory;
  final String proficiency;
  final String description;
  final String? mediaId;
  final int totalLikes;
  final int totalComments;
  final int totalViews;

  const TrendingPost({
    this.mediaUrl,
    required this.documentIds,
    required this.isVideo,
    required this.category,
    required this.subCategory,
    required this.proficiency,
    required this.description,
    this.mediaId,
    required this.totalLikes,
    required this.totalComments,
    required this.totalViews,
  });
}

class TrendingTalent {
  final String name;
  final String views;
  final String likes;
  final String timer;
  final String imagePath;
  final Color tintColor;
  final Duration initialDuration;

  /// Real user's profile photo URL. When set, the card swaps the inner
  /// [imagePath] asset for this network image — same size, position,
  /// border, styling. When null/empty, the asset is used as a fallback.
  final String? profilePhotoUrl;

  /// The real user's profile ID — used to navigate to their profile.
  final String profileId;

  /// Metadata for the user's most recent post in the feed.
  /// Used when tapping the card image to open the full post view.
  final TrendingPost? latestPost;

  const TrendingTalent({
    required this.name,
    required this.views,
    required this.likes,
    required this.timer,
    required this.imagePath,
    required this.tintColor,
    Duration? initialDuration,
    this.profilePhotoUrl,
    this.profileId = '',
    this.latestPost,
  }) : initialDuration = initialDuration ?? const Duration(seconds: 85);

  TrendingTalent copyWith({
    String? name,
    String? views,
    String? likes,
    String? profilePhotoUrl,
    String? profileId,
    TrendingPost? latestPost,
  }) {
    return TrendingTalent(
      name: name ?? this.name,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      timer: timer,
      imagePath: imagePath,
      tintColor: tintColor,
      initialDuration: initialDuration,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profileId: profileId ?? this.profileId,
      latestPost: latestPost ?? this.latestPost,
    );
  }
}
