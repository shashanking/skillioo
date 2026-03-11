import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/document_service.dart';
import '../domain/post_service.dart';
import 'notifiers/post_notifier.dart';
import 'states/post_state.dart';

final postServiceProvider = Provider<PostService>((ref) => PostService());

final postDocumentServiceProvider = Provider<DocumentService>(
  (ref) => DocumentService(),
);

final postNotifierProvider = StateNotifierProvider<PostNotifier, PostState>((
  ref,
) {
  final postService = ref.watch(postServiceProvider);
  final documentService = ref.watch(postDocumentServiceProvider);
  return PostNotifier(postService, documentService);
});
