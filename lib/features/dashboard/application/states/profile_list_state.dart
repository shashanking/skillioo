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
  final String portfolioId;
  final List<String> email;
  final List<String> phoneNumber;
  final List<DocumentItem> documents;

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
    required this.portfolioId,
    required this.email,
    required this.phoneNumber,
    required this.documents,
  });

  factory ProfileItem.fromJson(Map<String, dynamic> json) {
    final docList = json['document'] as List<dynamic>? ?? [];
    final documents = docList
        .whereType<Map<String, dynamic>>()
        .map((d) => DocumentItem.fromJson(d))
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
      portfolioId: json['portfolioId'] as String? ?? '',
      email: (json['email'] as List<dynamic>?)?.cast<String>() ?? [],
      phoneNumber: (json['phoneNumber'] as List<dynamic>?)?.cast<String>() ?? [],
      documents: documents,
    );
  }

  String get displayName {
    if (profileType == 'GROUP' && groupName.isNotEmpty) return groupName;
    final parts = [firstName, lastName].where((e) => e.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : nickName;
  }

  String? get profilePhotoUrl {
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
