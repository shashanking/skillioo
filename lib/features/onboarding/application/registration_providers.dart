import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/document_service.dart';
import '../domain/registration_service.dart';
import 'notifiers/registration_notifier.dart';
import 'states/registration_state.dart';

/// Service provider for DocumentService
final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService(client: ref.watch(sharedHttpClientProvider));
});

/// Service provider for RegistrationService
final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(client: ref.watch(sharedHttpClientProvider));
});

/// StateNotifier provider for registration flow
final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final registrationService = ref.watch(registrationServiceProvider);
  final documentService = ref.watch(documentServiceProvider);
  return RegistrationNotifier(registrationService, documentService);
});
