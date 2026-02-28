import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
