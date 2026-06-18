import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/chat_models.dart';
import '../../domain/chat_service.dart';
import '../states/chat_state.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;

  ChatNotifier(this._chatService) : super(const ChatState()) {
    _setupSocketCallbacks();
  }

  void _setupSocketCallbacks() {
    final socket = SocketService();

    socket.onNewMessage = (data) {
      if (kDebugMode) debugPrint('ChatNotifier: socket newMessage: $data');
      _handleSocketMessage(data);
    };

    socket.onConversationUpdated = (data) {
      if (kDebugMode) debugPrint('ChatNotifier: socket conversationUpdated');
      // Silently refresh the conversation list
      fetchConversations(refresh: true);
    };
  }

  void _handleSocketMessage(Map<String, dynamic> data) {
    try {
      final msg = MessageResponse.fromJson(data);
      final incomingConvId = (data['conversationId'] as String? ?? '').trim();

      // If the message belongs to the currently open conversation, prepend it
      // (avoid duplicate if we sent it ourselves — sendMessage already adds it)
      final alreadyExists = state.messages.any((m) => m.id == msg.id);
      if (!alreadyExists &&
          incomingConvId.isNotEmpty &&
          incomingConvId == state.activeConversationId) {
        state = state.copyWith(messages: [msg, ...state.messages]);
      }

      // The sender is clearly online — they just sent a message.
      final senderId = (msg.senderId ?? '').trim();
      if (senderId.isNotEmpty) {
        SocketService().notifyStatusChange(senderId, true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('ChatNotifier: socket message parse error: $e');
    }

    // Silently refresh conversations so the last-message preview updates
    silentRefresh();
  }

  /// Refreshes conversations (and active messages if open) without touching
  /// any status fields, so the UI doesn't flash or show a loading indicator.
  Future<void> silentRefresh() async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    // ── Conversations ──
    try {
      final response = await _chatService.getConversations(page: 1, limit: 20);
      final success = response['success'] as bool? ?? false;
      if (success) {
        final rawList =
            response['data'] is List ? response['data'] as List : const [];
        final conversations = <ConversationResponse>[];
        for (final item in rawList) {
          if (item is Map) {
            try {
              conversations.add(
                ConversationResponse.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (_) {}
          }
        }
        // Only update if something actually changed to avoid unnecessary rebuilds
        if (_conversationsChanged(conversations)) {
          state = state.copyWith(
            conversations: conversations,
            conversationsPage: 2,
            conversationsHasMore: conversations.length >= 20,
          );
          for (final conv in conversations) {
            if (conv.latestMessage?.senderId == conv.participantId) {
              _markSenderOnline(conv.participantId);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('silentRefresh conversations error: $e');
    }

    // ── Active messages ──
    final convId = state.activeConversationId.trim();
    final recipientId = state.activeRecipientId.trim();
    if (convId.isEmpty || recipientId.isEmpty) return;

    try {
      final response =
          await _chatService.getMessages(conversationId: convId, limit: 30);
      final success = response['success'] as bool? ?? false;
      if (success) {
        final rawList =
            response['data'] is List ? response['data'] as List : const [];
        final messages = <MessageResponse>[];
        for (final item in rawList) {
          if (item is Map) {
            try {
              messages.add(
                MessageResponse.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (_) {}
          }
        }
        if (_messagesChanged(messages)) {
          state = state.copyWith(messages: messages);
          if (messages.isNotEmpty) _markSenderOnline(messages.first.senderId);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('silentRefresh messages error: $e');
    }
  }

  bool _conversationsChanged(List<ConversationResponse> fresh) {
    if (fresh.length != state.conversations.length) return true;
    for (int i = 0; i < fresh.length; i++) {
      if (fresh[i].conversationId != state.conversations[i].conversationId ||
          fresh[i].latestMessage?.id != state.conversations[i].latestMessage?.id) {
        return true;
      }
    }
    return false;
  }

  bool _messagesChanged(List<MessageResponse> fresh) {
    if (fresh.length != state.messages.length) return true;
    if (fresh.isNotEmpty && state.messages.isNotEmpty) {
      return fresh.first.id != state.messages.first.id;
    }
    return false;
  }

  void _markSenderOnline(String? senderId) {
    final id = (senderId ?? '').trim();
    if (id.isNotEmpty) {
      SocketService().notifyStatusChange(id, true);
    }
  }

  Future<bool> _ensureAuth() async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return false;
    _chatService.setAuthToken(token);
    return true;
  }

  // ── View State Management ──

  void setViewMode(ChatViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setPendingRecipient(String recipientId) {
    state = state.copyWith(pendingRecipientId: recipientId);
  }

  /// Opens a chat with a specific recipient. Clears old state and sets up new chat.
  Future<void> openChatWithRecipient(String recipientId) async {
    if (recipientId.isEmpty) return;

    // Find existing conversation for this recipient FIRST
    String? existingConversationId;
    for (final conversation in state.conversations) {
      if (conversation.participantId == recipientId) {
        existingConversationId = conversation.conversationId;
        break;
      }
    }

    // Set the new recipient immediately so UI can show name/avatar
    // Clear messages and set new activeRecipientId
    state = state.copyWith(
      messagesStatus: ChatStatus.loading,
      messages: const [],
      activeRecipientId: recipientId,
      activeConversationId: existingConversationId ?? '',
      viewMode: ChatViewMode.chat,
      pendingRecipientId: '',
    );

    // Fetch messages with forceRefresh to bypass isNewTarget check
    await _fetchMessagesInternal(
      recipientId: recipientId,
      conversationId: existingConversationId ?? '',
    );
  }

  /// Selects a conversation from the list by index
  void selectConversation(int index) {
    if (index < 0 || index >= state.conversations.length) return;

    final conversation = state.conversations[index];
    final recipientId = conversation.participantId ?? '';
    final conversationId = conversation.conversationId ?? '';

    // Set the new recipient immediately so UI can show name/avatar
    state = state.copyWith(
      messagesStatus: ChatStatus.loading,
      messages: const [],
      activeRecipientId: recipientId,
      activeConversationId: conversationId,
      viewMode: ChatViewMode.chat,
      pendingRecipientId: '',
    );

    // Fetch messages for this conversation
    if (recipientId.isNotEmpty) {
      _fetchMessagesInternal(
        recipientId: recipientId,
        conversationId: conversationId,
      );
    }
  }

  void exitChat() {
    state = state.copyWith(
      viewMode: ChatViewMode.messages,
      messagesStatus: ChatStatus.initial,
      messages: const [],
      activeRecipientId: '',
      activeConversationId: '',
      pendingRecipientId: '',
    );
  }

  // ── Conversations ──

  Future<void> fetchConversations({bool refresh = false}) async {
    if (state.conversationsStatus == ChatStatus.loading) return;

    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      state = state.copyWith(
        conversationsStatus: ChatStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    final page = refresh ? 1 : state.conversationsPage;
    if (!refresh && !state.conversationsHasMore && page > 1) return;

    state = state.copyWith(
      conversationsStatus: ChatStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _chatService.getConversations(
        page: page,
        limit: 10,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        state = state.copyWith(
          conversationsStatus: ChatStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final rawList = response['data'] is List
          ? response['data'] as List
          : const [];

      final conversations = <ConversationResponse>[];
      for (final item in rawList) {
        if (item is Map) {
          try {
            conversations.add(
              ConversationResponse.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('ChatNotifier parse conversation: $e');
          }
        }
      }

      final merged = refresh
          ? conversations
          : [...state.conversations, ...conversations];

      state = state.copyWith(
        conversationsStatus: ChatStatus.success,
        conversations: merged,
        conversationsPage: page + 1,
        conversationsHasMore: conversations.length >= 10,
      );
      for (final conv in conversations) {
        if (conv.latestMessage?.senderId == conv.participantId) {
          _markSenderOnline(conv.participantId);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchConversations error: $e');
      state = state.copyWith(
        conversationsStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Messages ──

  /// Internal method to fetch messages - assumes state is already set up by caller
  Future<void> _fetchMessagesInternal({
    required String recipientId,
    required String conversationId,
  }) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      state = state.copyWith(
        messagesStatus: ChatStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    final normalizedConversationId = conversationId.trim();

    // No conversation yet - just mark as success with empty messages
    if (normalizedConversationId.isEmpty) {
      state = state.copyWith(
        messagesStatus: ChatStatus.success,
        messages: const [],
        messagesHasMore: false,
        errorMessage: '',
      );
      return;
    }

    try {
      final response = await _chatService.getMessages(
        conversationId: normalizedConversationId,
        limit: 30,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        state = state.copyWith(
          messagesStatus: ChatStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final rawList = response['data'] is List
          ? response['data'] as List
          : const [];

      final messages = <MessageResponse>[];
      for (final item in rawList) {
        if (item is Map) {
          try {
            messages.add(
              MessageResponse.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('ChatNotifier parse message: $e');
          }
        }
      }

      state = state.copyWith(
        messagesStatus: ChatStatus.success,
        messages: messages,
        messagesHasMore: messages.length >= 30,
        errorMessage: '',
      );
      if (messages.isNotEmpty) _markSenderOnline(messages.first.senderId);
    } catch (e) {
      if (kDebugMode) debugPrint('_fetchMessagesInternal error: $e');
      state = state.copyWith(
        messagesStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchMessages({
    required String recipientId,
    String conversationId = '',
    bool refresh = false,
  }) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      state = state.copyWith(
        messagesStatus: ChatStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    final normalizedConversationId = conversationId.trim();
    final isNewTarget =
        refresh ||
        normalizedConversationId != state.activeConversationId ||
        recipientId != state.activeRecipientId;

    if (normalizedConversationId.isEmpty) {
      state = state.copyWith(
        messagesStatus: ChatStatus.success,
        activeRecipientId: recipientId,
        activeConversationId: '',
        messages: const [],
        messagesHasMore: false,
        errorMessage: '',
      );
      return;
    }

    if (isNewTarget) {
      state = state.copyWith(
        messagesStatus: ChatStatus.loading,
        activeRecipientId: recipientId,
        activeConversationId: normalizedConversationId,
        messages: const [],
        messagesHasMore: true,
        errorMessage: '',
      );
    } else {
      if (!state.messagesHasMore) return;
      state = state.copyWith(
        messagesStatus: ChatStatus.loading,
        errorMessage: '',
      );
    }

    try {
      final response = await _chatService.getMessages(
        conversationId: normalizedConversationId,
        limit: 30,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        state = state.copyWith(
          messagesStatus: ChatStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final rawList = response['data'] is List
          ? response['data'] as List
          : const [];

      final messages = <MessageResponse>[];
      for (final item in rawList) {
        if (item is Map) {
          try {
            messages.add(
              MessageResponse.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('ChatNotifier parse message: $e');
          }
        }
      }

      final merged = isNewTarget ? messages : [...state.messages, ...messages];

      state = state.copyWith(
        messagesStatus: ChatStatus.success,
        messages: merged,
        activeRecipientId: recipientId,
        activeConversationId: normalizedConversationId,
        messagesHasMore: messages.length >= 30,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('fetchMessages error: $e');
      state = state.copyWith(
        messagesStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    state = state.copyWith(sendStatus: ChatStatus.loading);

    try {
      final response = await _chatService.sendMessage({
        'recipientId': recipientId,
        'content': {'text': text},
      });

      final success = response['success'] as bool? ?? false;
      if (success) {
        // Optimistically add message to list
        final data = response['data'];
        if (data is Map) {
          try {
            final dataMap = Map<String, dynamic>.from(data);
            final msg = MessageResponse.fromJson(dataMap);
            // Get the conversation ID from the raw response data
            final newConversationId = dataMap['conversationId'] as String?;
            state = state.copyWith(
              sendStatus: ChatStatus.success,
              messages: [msg, ...state.messages],
              // Update activeConversationId if this was a new conversation
              activeConversationId:
                  newConversationId ?? state.activeConversationId,
            );
          } catch (_) {
            state = state.copyWith(sendStatus: ChatStatus.success);
          }
        } else {
          state = state.copyWith(sendStatus: ChatStatus.success);
        }
        await fetchConversations(refresh: true);
        return true;
      }

      state = state.copyWith(
        sendStatus: ChatStatus.error,
        errorMessage: response['message'] as String? ?? 'Send failed',
      );
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('sendMessage error: $e');
      state = state.copyWith(
        sendStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _chatService.softDeleteMessage(messageId);
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(
          messages: state.messages.where((m) => m.id != messageId).toList(),
        );
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('deleteMessage error: $e');
      return false;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _chatService.softDeleteConversation(
        conversationId,
      );
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(
          conversations: state.conversations
              .where((c) => c.conversationId != conversationId)
              .toList(),
        );
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('deleteConversation error: $e');
      return false;
    }
  }

  // ── Calls ──

  Future<bool> initiateCall(String recipientId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    state = state.copyWith(callStatus: ChatStatus.loading);

    try {
      final response = await _chatService.initiateCall({
        'recipientId': recipientId,
      });

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'];
        CallResponse? call;
        if (data is Map) {
          try {
            call = CallResponse.fromJson(Map<String, dynamic>.from(data));
          } catch (_) {}
        }
        state = state.copyWith(
          callStatus: ChatStatus.success,
          activeCall: call,
        );
        return true;
      }

      state = state.copyWith(
        callStatus: ChatStatus.error,
        errorMessage: response['message'] as String? ?? 'Call failed',
      );
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('initiateCall error: $e');
      state = state.copyWith(
        callStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> acceptCall(String callId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _chatService.acceptCall({'callId': callId});
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(callStatus: ChatStatus.success);
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('acceptCall error: $e');
      return false;
    }
  }

  Future<bool> rejectCall(String callId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _chatService.rejectCall({'callId': callId});
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(
          callStatus: ChatStatus.initial,
          activeCall: null,
        );
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('rejectCall error: $e');
      return false;
    }
  }

  Future<bool> endCall(String callId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _chatService.endCall({'callId': callId});
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(
          callStatus: ChatStatus.initial,
          activeCall: null,
        );
      }
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('endCall error: $e');
      return false;
    }
  }

  // ── Notifications ──

  Future<void> fetchNotifications() async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      state = state.copyWith(
        notificationsStatus: ChatStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(
      notificationsStatus: ChatStatus.loading,
      errorMessage: '',
    );

    try {
      final profileId = await SessionPrefs.instance.getProfileId();
      if (profileId.isEmpty) {
        state = state.copyWith(
          notificationsStatus: ChatStatus.error,
          errorMessage: 'No profile ID',
        );
        return;
      }

      final response = await _chatService.getNotifications(
        profileId: profileId,
      );

      final success = response['message'] == 'Success';
      final status = response['status'] as int?;
      if (!success && status != 200) {
        state = state.copyWith(
          notificationsStatus: ChatStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final dataField = response['data'];
      final itemsList = dataField is Map
          ? (dataField['items'] as List? ?? [])
          : dataField is List
          ? dataField
          : [];
      final rawList = itemsList
          .whereType<Map<String, dynamic>>()
          .toList();

      state = state.copyWith(
        notificationsStatus: ChatStatus.success,
        notifications: rawList,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('fetchNotifications error: $e');
      state = state.copyWith(
        notificationsStatus: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearActiveChat() {
    state = state.copyWith(
      messagesStatus: ChatStatus.initial,
      messages: const [],
      activeRecipientId: '',
      activeConversationId: '',
      pendingRecipientId: '',
    );
  }
}
