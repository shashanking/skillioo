import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/privacy_service.dart';

final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService(client: ref.watch(sharedHttpClientProvider));
});
