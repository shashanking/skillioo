import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/document_models.dart';
import '../../domain/document_service.dart';
import '../../domain/registration_service.dart';
import '../../../../core/services/session_prefs.dart';
import '../onboarding_data_provider.dart';
import '../states/registration_state.dart';

const _kLastPhoneNumberKey = 'last_phone_number';
const _kLastPhoneVerificationIdKey = 'last_phone_verification_id';

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegistrationService _registrationService;
  final DocumentService _documentService;

  RegistrationNotifier(this._registrationService, this._documentService)
    : super(const RegistrationState());

  // ── Document Uploads ──

  /// Upload profile photo document.
  /// Also uploads the same file as IMAGE to populate imageDocumentId,
  /// since the backend validates each document ID against its upload type.
  Future<String?> uploadProfilePhoto(File file) async {
    state = state.copyWith(
      profilePhotoStatus: DocumentUploadStatus.uploading,
      errorMessage: '',
    );

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final accessToken = token.isNotEmpty ? token : null;

      // Upload as PROFILE_PHOTO for profileDocumentId
      final profileResponse = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.profilePhoto,
        accessToken: accessToken,
      );

      final profileSuccess = profileResponse['success'] as bool? ?? false;
      if (!profileSuccess) {
        final message =
            profileResponse['message'] as String? ?? 'Upload failed';
        state = state.copyWith(
          profilePhotoStatus: DocumentUploadStatus.error,
          errorMessage: message,
        );
        return null;
      }

      final profileData = profileResponse['data'] as Map<String, dynamic>?;
      final profileDoc =
          profileData?['document'] as Map<String, dynamic>? ?? {};
      final profileDocId = profileDoc['id'] as String? ?? '';

      // Cache the URL immediately so the profile screen can show the photo
      // without waiting for syncProfile to run after registration completes.
      final rawDocUrl = (profileDoc['url'] as String? ?? '').trim();
      if (rawDocUrl.isNotEmpty) {
        final normalizedUrl = rawDocUrl.startsWith('http://')
            ? rawDocUrl.replaceFirst('http://', 'https://')
            : rawDocUrl;
        await SessionPrefs.instance.mergeProfile({
          'profilePhotoUrl': normalizedUrl,
          'profilePictureId': profileDocId,
        });
      } else if (profileDocId.isNotEmpty) {
        // URL not in upload response — at least cache the ID so
        // _resolveProfilePhotoIfNeeded / currentProfileProvider can fetch it.
        await SessionPrefs.instance.mergeProfile({
          'profilePictureId': profileDocId,
        });
      }

      state = state.copyWith(
        profilePhotoStatus: DocumentUploadStatus.uploaded,
        profileDocumentId: profileDocId,
      );
      return profileDocId;
    } catch (e) {
      debugPrint('uploadProfilePhoto error: $e');
      state = state.copyWith(
        profilePhotoStatus: DocumentUploadStatus.error,
        errorMessage: e.toString(),
      );
    }
    return null;
  }

  /// Upload image document
  Future<String?> uploadImage(File file) async {
    state = state.copyWith(
      imageStatus: DocumentUploadStatus.uploading,
      errorMessage: '',
    );

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final response = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.image,
        accessToken: token.isNotEmpty ? token : null,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final doc = data?['document'] as Map<String, dynamic>? ?? {};
        final docId = doc['id'] as String? ?? '';

        final updatedImageIds = [...state.imageDocumentIds];
        if (docId.isNotEmpty && !updatedImageIds.contains(docId)) {
          updatedImageIds.add(docId);
        }

        state = state.copyWith(
          imageStatus: DocumentUploadStatus.uploaded,
          imageDocumentIds: updatedImageIds,
        );
        return docId;
      } else {
        final message = response['message'] as String? ?? 'Upload failed';
        state = state.copyWith(
          imageStatus: DocumentUploadStatus.error,
          errorMessage: message,
        );
      }
    } catch (e) {
      debugPrint('uploadImage error: $e');
      state = state.copyWith(
        imageStatus: DocumentUploadStatus.error,
        errorMessage: e.toString(),
      );
    }
    return null;
  }

  /// Upload video document
  Future<String?> uploadVideo(File file) async {
    state = state.copyWith(
      videoStatus: DocumentUploadStatus.uploading,
      errorMessage: '',
    );

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final response = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.video,
        accessToken: token.isNotEmpty ? token : null,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final doc = data?['document'] as Map<String, dynamic>? ?? {};
        final docId = doc['id'] as String? ?? '';

        // Append to videoDocumentIds array
        final updatedVideoIds = [...state.videoDocumentIds];
        if (docId.isNotEmpty && !updatedVideoIds.contains(docId)) {
          updatedVideoIds.add(docId);
        }

        state = state.copyWith(
          videoStatus: DocumentUploadStatus.uploaded,
          videoDocumentIds: updatedVideoIds,
        );
        return docId;
      } else {
        final message = response['message'] as String? ?? 'Upload failed';
        state = state.copyWith(
          videoStatus: DocumentUploadStatus.error,
          errorMessage: message,
        );
      }
    } catch (e) {
      debugPrint('uploadVideo error: $e');
      state = state.copyWith(
        videoStatus: DocumentUploadStatus.error,
        errorMessage: e.toString(),
      );
    }
    return null;
  }

  /// Upload event document
  Future<String?> uploadEvent(File file) async {
    state = state.copyWith(errorMessage: '');

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final response = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.event,
        accessToken: token.isNotEmpty ? token : null,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final doc = data?['document'] as Map<String, dynamic>? ?? {};
        final docId = doc['id'] as String? ?? '';

        // Append to eventsDoneDocumentIds array
        final updatedEventIds = [...state.eventsDoneDocumentIds];
        if (docId.isNotEmpty && !updatedEventIds.contains(docId)) {
          updatedEventIds.add(docId);
        }

        state = state.copyWith(eventsDoneDocumentIds: updatedEventIds);
        return docId;
      } else {
        final message = response['message'] as String? ?? 'Upload failed';
        state = state.copyWith(errorMessage: message);
      }
    } catch (e) {
      debugPrint('uploadEvent error: $e');
      state = state.copyWith(errorMessage: e.toString());
    }
    return null;
  }

  // ── Registration ──

  /// Register profile using the accumulated OnboardingData.
  ///
  /// `POST /v1/profile` is a one-shot upsert on the OTP-created account.
  /// A second call against a fully-onboarded user returns
  /// HTTP 500 "External API error", so we short-circuit if the cached
  /// profile already has `isCreator: true`.
  Future<void> registerProfile(OnboardingData onboardingData) async {
    state = state.copyWith(
      status: RegistrationStatus.loading,
      errorMessage: '',
    );

    final cachedProfile = await SessionPrefs.instance.getProfile();
    final alreadyCreator = cachedProfile?['isCreator'] as bool? ?? false;
    if (alreadyCreator) {
      debugPrint(
        'registerProfile: skipped — profile is already isCreator:true',
      );
      state = state.copyWith(status: RegistrationStatus.success);
      return;
    }

    final accessToken = await SessionPrefs.instance.getAccessToken();
    if (accessToken.isEmpty) {
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Session expired. Please sign in again.',
      );
      return;
    }

    // When the user reaches this notifier from the dashboard
    // (instead of the fresh OTP→PIN flow), onboardingData is created
    // empty and phoneNumber / phoneVerificationId are never set.
    // Hydrate from secure storage so the returning user's existing
    // phone + verificationId + profileId travel into the request body.
    final hydratedData = await _hydrateContactsFromStorage(onboardingData);

    try {
      final profileData = hydratedData.toRegistrationJson();
      debugPrint('registerProfile body: $profileData');

      final response = await _registrationService.registerProfile(
        profileData,
        accessToken: accessToken,
      );

      debugPrint('registerProfile response: $response');
      final success = response['success'] as bool? ?? false;
      if (success) {
        await SessionPrefs.instance.setProfileCreated(true);
        // Pre-populate all profile fields so the profile screen has real
        // data on first load without waiting for syncProfile (fire-and-forget).
        await SessionPrefs.instance.mergeProfile({
          'isCreator': true,
          'isOnboarded': true,
          'profileType': hydratedData.profileType,
          if (hydratedData.firstName.isNotEmpty)
            'firstName': hydratedData.firstName,
          if (hydratedData.lastName.isNotEmpty)
            'lastName': hydratedData.lastName,
          if (hydratedData.groupName.isNotEmpty)
            'groupName': hydratedData.groupName,
          if (hydratedData.nickName.isNotEmpty)
            'nickName': hydratedData.nickName,
          if (hydratedData.bio.isNotEmpty) 'bio': hydratedData.bio,
          if (hydratedData.city.isNotEmpty) 'city': hydratedData.city,
          if (hydratedData.country.isNotEmpty) 'country': hydratedData.country,
          if (hydratedData.category.isNotEmpty)
            'category': hydratedData.category,
          if (hydratedData.subCategory.isNotEmpty)
            'subCategory': hydratedData.subCategory,
          if (hydratedData.proficiency.isNotEmpty)
            'proficiency': hydratedData.proficiency,
        });
        state = state.copyWith(status: RegistrationStatus.success);
      } else {
        final message = response['message'] as String? ?? 'Registration failed';
        final errors = response['errorSourse'] ?? response['errorSource'] ?? [];
        debugPrint('registerProfile errors: $errors');

        // Build detailed error from backend validation errors if available
        String detailedError = message;
        if (errors is List && errors.isNotEmpty) {
          final errorMessages = errors
              .map((e) {
                if (e is Map) {
                  return e['message'] as String? ?? e.toString();
                }
                return e.toString();
              })
              .toList();
          detailedError = errorMessages.join('. ');
        }

        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: detailedError,
        );
      }
    } catch (e) {
      debugPrint('registerProfile error: $e');
      // Don't try to interpret 5xx — could be "Authentication failed",
      // "External API error" (already exists), or a transient backend
      // crash. The pre-check above handles the duplicate case via cached
      // isCreator. Anything else surfaces as a retryable error.
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Could not save your profile. Please try again.',
      );
    }
  }

  Future<OnboardingData> _hydrateContactsFromStorage(
    OnboardingData data,
  ) async {
    const storage = FlutterSecureStorage();
    final storedPhone = data.phoneNumber.isNotEmpty
        ? data.phoneNumber
        : (await storage.read(key: _kLastPhoneNumberKey) ?? '');
    final storedVerificationId = data.phoneVerificationId.isNotEmpty
        ? data.phoneVerificationId
        : (await storage.read(key: _kLastPhoneVerificationIdKey) ?? '');
    final storedProfileId = data.profileId.isNotEmpty
        ? data.profileId
        : await SessionPrefs.instance.getProfileId();
    return data.copyWith(
      phoneNumber: storedPhone,
      phoneVerificationId: storedVerificationId,
      profileId: storedProfileId,
    );
  }

  /// Remove event document ID at index
  void removeEventDocument(int index) {
    if (index < 0 || index >= state.eventsDoneDocumentIds.length) return;
    final updatedEventIds = [...state.eventsDoneDocumentIds];
    updatedEventIds.removeAt(index);
    state = state.copyWith(eventsDoneDocumentIds: updatedEventIds);
  }

  /// Reset state
  void reset() {
    state = const RegistrationState();
  }
}
