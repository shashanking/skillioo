import '../../../onboarding/domain/document_models.dart';

DocumentInfo? resolvePreferredDocument(
  List<String>? documentIds,
  Map<String, DocumentInfo> docs, {
  bool preferVideo = false,
}) {
  if (documentIds == null || documentIds.isEmpty) return null;

  DocumentInfo? firstKnown;
  for (final rawId in documentIds) {
    final id = rawId.trim();
    if (id.isEmpty) continue;

    final doc = docs[id];
    if (doc == null) continue;

    firstKnown ??= doc;
    if (!preferVideo) return doc;
    if (isVideoDocument(doc)) return doc;
  }

  return firstKnown;
}

bool isVideoDocument(DocumentInfo doc) {
  final url = doc.url.toLowerCase();
  return doc.type == DocumentType.video ||
      url.endsWith('.mp4') ||
      url.endsWith('.mov') ||
      url.endsWith('.webm') ||
      url.contains('/video/upload/');
}
