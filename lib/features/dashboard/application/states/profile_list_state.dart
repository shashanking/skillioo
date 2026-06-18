import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_list_state.freezed.dart';

@freezed
class ProfileListState with _$ProfileListState {
  const factory ProfileListState({
    @Default([]) List<ProfileItem> profiles,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default(1) int currentPage,
    @Default(false) bool hasMore,
  }) = _ProfileListState;
}

class ProfileItem {
  final String id;
  final String nickName;
  final String firstName;
  final String lastName;
  final String groupName;
  final String profileType;
  final String status;
  final String city;
  final String country;
  final String proficiency;
  final String category;
  final String subCategory;
  final String bio;
  final String portfolioId;
  final List<String> email;
  final List<String> phoneNumber;
  final List<DocumentItem> documents;
  final List<SocialMediaFollow> follows;
  final int eventsDone;
  final String onlineStatus;
  final int followerCount;
  final int followingCount;
  final int totalViews;
  final String? _profilePhotoUrlDirect;

  ProfileItem({
    required this.id,
    required this.nickName,
    required this.firstName,
    required this.lastName,
    required this.groupName,
    required this.profileType,
    required this.status,
    required this.city,
    required this.country,
    required this.proficiency,
    this.category = '',
    this.subCategory = '',
    this.bio = '',
    required this.portfolioId,
    required this.email,
    required this.phoneNumber,
    required this.documents,
    this.follows = const [],
    this.eventsDone = 0,
    this.onlineStatus = 'OFFLINE',
    this.followerCount = 0,
    this.followingCount = 0,
    this.totalViews = 0,
    String? profilePhotoUrlDirect,
  }) : _profilePhotoUrlDirect = profilePhotoUrlDirect;

  factory ProfileItem.fromJson(Map<String, dynamic> json) {
    final docList = json['document'] as List<dynamic>? ?? [];
    final documents = docList
        .whereType<Map<String, dynamic>>()
        .map((d) => DocumentItem.fromJson(d))
        .toList();

    final followsList = json['follows'] as List<dynamic>? ?? [];
    final follows = followsList
        .whereType<Map<String, dynamic>>()
        .map((f) => SocialMediaFollow.fromJson(f))
        .toList();

    return ProfileItem(
      id: json['id'] as String? ?? '',
      nickName: json['nickName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      groupName: json['groupName'] as String? ?? '',
      profileType: json['profileType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      proficiency: json['proficiency'] as String? ?? '',
      category: json['category'] as String? ?? '',
      // Optional — backend may include these on the listing payload, but
      // doesn't always. Defaults are empty so search just skips them.
      subCategory: (json['subCategory'] as String?) ??
          (json['portfolio'] is Map
              ? (json['portfolio'] as Map)['subCategory'] as String? ?? ''
              : ''),
      bio: (json['bio'] as String?) ??
          (json['portfolio'] is Map
              ? (json['portfolio'] as Map)['bio'] as String? ?? ''
              : ''),
      portfolioId: json['portfolioId'] as String? ?? '',
      email: (json['email'] as List<dynamic>?)?.cast<String>() ?? [],
      phoneNumber:
          (json['phoneNumber'] as List<dynamic>?)?.cast<String>() ?? [],
      documents: documents,
      follows: follows,
      eventsDone: json['eventsDone'] as int? ?? 0,
      onlineStatus: json['onlineStatus'] as String? ?? 'OFFLINE',
      followerCount: _reachInt(json, 'followerCount'),
      followingCount: _reachInt(json, 'followingCount'),
      totalViews: _reachInt(json, 'viewsCount'),
    );
  }

  String get displayName {
    if (profileType == 'GROUP' && groupName.isNotEmpty) return groupName;
    final parts = [firstName, lastName].where((e) => e.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : nickName;
  }

  String? get profilePhotoUrl {
    // Prefer directly stored URL (from session/API profilePhotoUrl field)
    if (_profilePhotoUrlDirect != null && _profilePhotoUrlDirect.isNotEmpty) {
      return _profilePhotoUrlDirect.startsWith('http://')
          ? _profilePhotoUrlDirect.replaceFirst('http://', 'https://')
          : _profilePhotoUrlDirect;
    }
    // Fallback to documents list
    final photo = documents.firstWhere(
      (d) => d.type == 'PROFILE_PHOTO',
      orElse: () => DocumentItem(url: '', type: ''),
    );
    if (photo.url.isEmpty) return null;
    return photo.url.startsWith('http://')
        ? photo.url.replaceFirst('http://', 'https://')
        : photo.url;
  }

  List<DocumentItem> get videos =>
      documents.where((d) => d.type == 'VIDEO').toList();

  List<DocumentItem> get images =>
      documents.where((d) => d.type == 'IMAGE').toList();
}

class DocumentItem {
  final String url;
  final String type;

  DocumentItem({required this.url, required this.type});

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  String get normalizedUrl {
    return url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;
  }
}

class SocialMediaFollow {
  final String socialMedia;
  final String link;
  final int followers;
  final int following;

  SocialMediaFollow({
    required this.socialMedia,
    required this.link,
    required this.followers,
    required this.following,
  });

  factory SocialMediaFollow.fromJson(Map<String, dynamic> json) {
    return SocialMediaFollow(
      socialMedia: json['socialMedia'] as String? ?? '',
      link: json['link'] as String? ?? '',
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }

  String get platformIcon {
    switch (socialMedia.toUpperCase()) {
      case 'FACEBOOK':
        return '📘';
      case 'INSTAGRAM':
        return '📷';
      case 'TWITTER':
      case 'X':
        return '🐦';
      case 'YOUTUBE':
        return '▶️';
      case 'LINKEDIN':
        return '💼';
      case 'TIKTOK':
        return '🎵';
      default:
        return '🌐';
    }
  }

  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}

// Reads a count from userReach nested object, falling back to top-level key.
int _reachInt(Map<String, dynamic> json, String key) {
  final reach = json['userReach'] as Map<String, dynamic>?;
  return (reach?[key] as num?)?.toInt() ??
      (json[key] as num?)?.toInt() ??
      0;
}
