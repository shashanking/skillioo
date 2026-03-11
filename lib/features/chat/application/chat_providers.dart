import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_service.dart';
import 'notifiers/chat_notifier.dart';
import 'states/chat_state.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((
  ref,
) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service);
});
