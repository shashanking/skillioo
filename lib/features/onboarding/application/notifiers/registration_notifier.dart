import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/document_models.dart';
import '../../domain/document_service.dart';
import '../../domain/registration_service.dart';
import '../onboarding_data_provider.dart';
import '../states/registration_state.dart';

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
      // Upload as PROFILE_PHOTO for profileDocumentId
      final profileResponse = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.profilePhoto,
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

      // Upload same file as CONTENT for imageDocumentId
      final imageResponse = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.image,
      );

      String imageDocId = profileDocId;
      final imageSuccess = imageResponse['success'] as bool? ?? false;
      if (imageSuccess) {
        final imageData = imageResponse['data'] as Map<String, dynamic>?;
        final imageDoc = imageData?['document'] as Map<String, dynamic>? ?? {};
        imageDocId = imageDoc['id'] as String? ?? profileDocId;
      } else {
        debugPrint('uploadPhoto (IMAGE) failed: ${imageResponse['message']}');
      }

      state = state.copyWith(
        profilePhotoStatus: DocumentUploadStatus.uploaded,
        profileDocumentId: profileDocId,
        imageDocumentId: imageDocId,
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

  /// Upload video document
  Future<String?> uploadVideo(File file) async {
    state = state.copyWith(
      videoStatus: DocumentUploadStatus.uploading,
      errorMessage: '',
    );

    try {
      final response = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.video,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final doc = data?['document'] as Map<String, dynamic>? ?? {};
        final docId = doc['id'] as String? ?? '';

        state = state.copyWith(
          videoStatus: DocumentUploadStatus.uploaded,
          videoDocumentId: docId,
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
      final response = await _documentService.uploadDocument(
        file: file,
        type: DocumentType.event,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final doc = data?['document'] as Map<String, dynamic>? ?? {};
        final docId = doc['id'] as String? ?? '';

        state = state.copyWith(eventsDoneDocumentId: docId);
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
  Future<void> registerProfile(OnboardingData onboardingData) async {
    state = state.copyWith(
      status: RegistrationStatus.loading,
      errorMessage: '',
    );

    try {
      final profileData = onboardingData.toRegistrationJson();
      debugPrint('registerProfile body: $profileData');

      final response = await _registrationService.registerProfile(profileData);

      debugPrint('registerProfile response: $response');
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(status: RegistrationStatus.success);
      } else {
        final message = response['message'] as String? ?? 'Registration failed';
        final errors = response['errorSourse'] ?? response['errorSource'] ?? [];
        debugPrint('registerProfile errors: $errors');
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: message,
        );
      }
    } catch (e) {
      debugPrint('registerProfile error: $e');
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state
  void reset() {
    state = const RegistrationState();
  }
}
