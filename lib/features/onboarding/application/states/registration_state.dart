import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_state.freezed.dart';

enum RegistrationStatus { initial, loading, success, error }

enum DocumentUploadStatus { initial, uploading, uploaded, error }

@freezed
class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default(RegistrationStatus.initial) RegistrationStatus status,
    @Default(DocumentUploadStatus.initial)
    DocumentUploadStatus profilePhotoStatus,
    @Default(DocumentUploadStatus.initial) DocumentUploadStatus videoStatus,
    @Default(DocumentUploadStatus.initial) DocumentUploadStatus imageStatus,
    @Default('') String profileDocumentId,
    @Default([]) List<String> videoDocumentIds,
    @Default([]) List<String> imageDocumentIds,
    @Default([]) List<String> eventsDoneDocumentIds,
    @Default('') String errorMessage,
  }) = _RegistrationState;
}
