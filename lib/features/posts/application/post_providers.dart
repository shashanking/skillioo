import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../../onboarding/domain/document_service.dart';
import '../domain/post_service.dart';
import 'notifiers/post_notifier.dart';
import 'states/post_state.dart';

final postServiceProvider = Provider<PostService>(
  (ref) => PostService(client: ref.watch(sharedHttpClientProvider)),
);

final postDocumentServiceProvider = Provider<DocumentService>(
  (ref) => DocumentService(client: ref.watch(sharedHttpClientProvider)),
);

final postNotifierProvider = StateNotifierProvider<PostNotifier, PostState>((
  ref,
) {
  final postService = ref.watch(postServiceProvider);
  final documentService = ref.watch(postDocumentServiceProvider);
  return PostNotifier(postService, documentService);
});

// Persists liked profile IDs for the session so the like button stays filled
// after navigating away and back.
final likedProfileIdsProvider = StateProvider<Set<String>>((ref) => {});
