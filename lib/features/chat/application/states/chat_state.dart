import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/chat_models.dart';

part 'chat_state.freezed.dart';

enum ChatStatus { initial, loading, success, error }

enum ChatViewMode { messages, search, searchResults, chat }

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    // View state - controls which screen is shown
    @Default(ChatViewMode.messages) ChatViewMode viewMode,

    // Pending recipient - set when navigating to chat from external source
    @Default('') String pendingRecipientId,

    // Conversations
    @Default(ChatStatus.initial) ChatStatus conversationsStatus,
    @Default([]) List<ConversationResponse> conversations,
    @Default(1) int conversationsPage,
    @Default(false) bool conversationsHasMore,

    // Messages (active chat)
    @Default(ChatStatus.initial) ChatStatus messagesStatus,
    @Default([]) List<MessageResponse> messages,
    @Default('') String activeConversationId,
    @Default('') String activeRecipientId,
    @Default(false) bool messagesHasMore,

    // Send message
    @Default(ChatStatus.initial) ChatStatus sendStatus,

    // Call
    @Default(ChatStatus.initial) ChatStatus callStatus,
    @Default(null) CallResponse? activeCall,

    // Notifications
    @Default(ChatStatus.initial) ChatStatus notificationsStatus,
    @Default([]) List<Map<String, dynamic>> notifications,

    @Default('') String errorMessage,
  }) = _ChatState;
}
