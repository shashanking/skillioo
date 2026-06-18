import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../features/onboarding/domain/document_service.dart';
import '../../dashboard/application/states/profile_list_state.dart';

final currentProfileProvider = FutureProvider<ProfileItem?>((ref) async {
  // Re-run whenever the session state changes (e.g. after syncProfile writes
  // the full profile data back to SessionPrefs on first launch post-onboarding).
  ref.watch(sessionStateProvider);
  final profileJson = await SessionPrefs.instance.getProfile();
  if (profileJson == null || profileJson.isEmpty) return null;

  final nestedProfile = profileJson['profile'] as Map<String, dynamic>?;
  final portfolio = profileJson['portfolio'] as Map<String, dynamic>?;
  final online = profileJson['online'] as Map<String, dynamic>?;
  final source = <String, dynamic>{
    ...profileJson,
    if (nestedProfile != null) ...nestedProfile,
  };

  final id = await SessionPrefs.instance.getProfileId();
  final resolvedId = id.trim().isNotEmpty
      ? id.trim()
      : (source['id'] as String? ?? '').trim();

  final address = source['address'] as Map<String, dynamic>?;

  String readString(dynamic value) => value?.toString().trim() ?? '';

  final documents = <DocumentItem>[];
  final rawDocuments =
      source['document'] ??
      source['documents'] ??
      portfolio?['document'] ??
      portfolio?['documents'];
  if (rawDocuments is List) {
    for (final item in rawDocuments) {
      if (item is Map<String, dynamic>) {
        try {
          documents.add(DocumentItem.fromJson(item));
        } catch (_) {}
      }
    }
  }

  final follows = <SocialMediaFollow>[];
  final rawFollows =
      source['follows'] ??
      source['socialMediaFollow'] ??
      source['socialMediaFollows'] ??
      portfolio?['socialMediaFollow'] ??
      portfolio?['socialMediaFollows'];
  if (rawFollows is List) {
    for (final item in rawFollows) {
      if (item is Map<String, dynamic>) {
        try {
          follows.add(SocialMediaFollow.fromJson(item));
        } catch (_) {}
      }
    }
  }

  final rawEventsDone =
      source['eventsDone'] ??
      source['totalEvents'] ??
      portfolio?['totalEvents'] ??
      nestedProfile?['totalEvents'];
  final eventsDone = rawEventsDone is int
      ? rawEventsDone
      : rawEventsDone is double
      ? rawEventsDone.toInt()
      : int.tryParse(rawEventsDone?.toString() ?? '') ?? 0;

  // Resolve profile photo URL — prefer cached direct URL, then fallback to
  // resolving from profilePictureId if no URL is stored yet.
  String rawPhotoUrl = readString(source['profilePhotoUrl']).isNotEmpty
      ? readString(source['profilePhotoUrl'])
      : readString(source['profilePictureUrl']).isNotEmpty
      ? readString(source['profilePictureUrl'])
      : readString(nestedProfile?['profilePhotoUrl']).isNotEmpty
      ? readString(nestedProfile?['profilePhotoUrl'])
      : readString(portfolio?['profilePhotoUrl']);

  if (rawPhotoUrl.isEmpty) {
    // No URL cached — try to resolve from profilePictureId inline so the
    // profile screen doesn't rely solely on syncProfile having completed.
    final rawPic =
        source['profilePictureId'] ??
        nestedProfile?['profilePictureId'] ??
        portfolio?['profilePictureId'];
    String picId = '';
    if (rawPic is Map) {
      // Some backends embed {id, url} — extract URL directly if present.
      final embedded = (rawPic['url'] as String? ?? '').trim();
      if (embedded.isNotEmpty) {
        rawPhotoUrl = embedded.startsWith('http://')
            ? embedded.replaceFirst('http://', 'https://')
            : embedded;
      }
      picId = (rawPic['id'] as String? ?? '').trim();
    } else if (rawPic is String) {
      picId = rawPic.trim();
    }

    if (rawPhotoUrl.isEmpty && picId.isNotEmpty) {
      try {
        final accessToken = await SessionPrefs.instance.getAccessToken();
        if (accessToken.isNotEmpty) {
          final docService = DocumentService();
          final res = await docService.getDocumentsByIds(
            ids: [picId],
            accessToken: accessToken,
          );
          final list = res['data'];
          if (list is List) {
            final doc = list
                .whereType<Map<String, dynamic>>()
                .firstWhere(
                  (e) => e['id'] == picId,
                  orElse: () => <String, dynamic>{},
                );
            final url = (doc['url'] as String? ?? '').trim();
            if (url.isNotEmpty) {
              rawPhotoUrl = url.startsWith('http://')
                  ? url.replaceFirst('http://', 'https://')
                  : url;
              // Cache the resolved URL so subsequent loads are instant.
              await SessionPrefs.instance.mergeProfile({
                'profilePhotoUrl': rawPhotoUrl,
              });
            }
          }
        }
      } catch (_) {}
    }
  }

  // Resolve first/last name — fall back to splitting 'name' if needed
  String resolvedFirstName = (source['firstName'] as String? ?? '').trim();
  String resolvedLastName = (source['lastName'] as String? ?? '').trim();
  if (resolvedFirstName.isEmpty && resolvedLastName.isEmpty) {
    final fullName = (source['name'] as String? ?? '').trim();
    if (fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      resolvedFirstName = parts.first;
      if (parts.length > 1) {
        resolvedLastName = parts.sublist(1).join(' ');
      }
    }
  }

  return ProfileItem(
    id: resolvedId,
    profilePhotoUrlDirect: rawPhotoUrl.isNotEmpty ? rawPhotoUrl : null,
    nickName: source['nickName'] as String? ?? '',
    firstName: resolvedFirstName,
    lastName: resolvedLastName,
    groupName: source['groupName'] as String? ?? '',
    profileType: source['profileType'] as String? ?? '',
    status: source['status'] as String? ?? 'APPROVED',
    bio: readString(source['bio']).isNotEmpty
        ? readString(source['bio'])
        : readString(portfolio?['bio']),
    city: readString(source['city']).isNotEmpty
        ? readString(source['city'])
        : readString(address?['city']).isNotEmpty
        ? readString(address?['city'])
        : readString(nestedProfile?['city']),
    country: readString(source['country']).isNotEmpty
        ? readString(source['country'])
        : readString(address?['country']).isNotEmpty
        ? readString(address?['country'])
        : readString(nestedProfile?['country']),
    proficiency: readString(source['proficiency']).isNotEmpty
        ? readString(source['proficiency'])
        : readString(portfolio?['proficiency']).isNotEmpty
        ? readString(portfolio?['proficiency'])
        : readString(nestedProfile?['proficiency']),
    category: readString(source['category']).isNotEmpty
        ? readString(source['category'])
        : readString(portfolio?['category']).isNotEmpty
        ? readString(portfolio?['category'])
        : readString(nestedProfile?['category']),
    portfolioId: readString(source['portfolioId']).isNotEmpty
        ? readString(source['portfolioId'])
        : readString(portfolio?['portfolioId']).isNotEmpty
        ? readString(portfolio?['portfolioId'])
        : readString(nestedProfile?['portfolioId']),
    email: (source['email'] as List<dynamic>?)?.cast<String>() ?? const [],
    phoneNumber:
        (source['phoneNumber'] as List<dynamic>?)?.cast<String>() ?? const [],
    documents: documents,
    follows: follows,
    eventsDone: eventsDone,
    onlineStatus:
        online?['status'] as String? ??
        source['onlineStatus'] as String? ??
        'OFFLINE',
  );
});
