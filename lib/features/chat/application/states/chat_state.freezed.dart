// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  // View state - controls which screen is shown
  ChatViewMode get viewMode =>
      throw _privateConstructorUsedError; // Pending recipient - set when navigating to chat from external source
  String get pendingRecipientId =>
      throw _privateConstructorUsedError; // Conversations
  ChatStatus get conversationsStatus => throw _privateConstructorUsedError;
  List<ConversationResponse> get conversations =>
      throw _privateConstructorUsedError;
  int get conversationsPage => throw _privateConstructorUsedError;
  bool get conversationsHasMore =>
      throw _privateConstructorUsedError; // Messages (active chat)
  ChatStatus get messagesStatus => throw _privateConstructorUsedError;
  List<MessageResponse> get messages => throw _privateConstructorUsedError;
  String get activeConversationId => throw _privateConstructorUsedError;
  String get activeRecipientId => throw _privateConstructorUsedError;
  bool get messagesHasMore =>
      throw _privateConstructorUsedError; // Send message
  ChatStatus get sendStatus => throw _privateConstructorUsedError; // Call
  ChatStatus get callStatus => throw _privateConstructorUsedError;
  CallResponse? get activeCall =>
      throw _privateConstructorUsedError; // Notifications
  ChatStatus get notificationsStatus => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get notifications =>
      throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({
    ChatViewMode viewMode,
    String pendingRecipientId,
    ChatStatus conversationsStatus,
    List<ConversationResponse> conversations,
    int conversationsPage,
    bool conversationsHasMore,
    ChatStatus messagesStatus,
    List<MessageResponse> messages,
    String activeConversationId,
    String activeRecipientId,
    bool messagesHasMore,
    ChatStatus sendStatus,
    ChatStatus callStatus,
    CallResponse? activeCall,
    ChatStatus notificationsStatus,
    List<Map<String, dynamic>> notifications,
    String errorMessage,
  });
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewMode = null,
    Object? pendingRecipientId = null,
    Object? conversationsStatus = null,
    Object? conversations = null,
    Object? conversationsPage = null,
    Object? conversationsHasMore = null,
    Object? messagesStatus = null,
    Object? messages = null,
    Object? activeConversationId = null,
    Object? activeRecipientId = null,
    Object? messagesHasMore = null,
    Object? sendStatus = null,
    Object? callStatus = null,
    Object? activeCall = freezed,
    Object? notificationsStatus = null,
    Object? notifications = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            viewMode: null == viewMode
                ? _value.viewMode
                : viewMode // ignore: cast_nullable_to_non_nullable
                      as ChatViewMode,
            pendingRecipientId: null == pendingRecipientId
                ? _value.pendingRecipientId
                : pendingRecipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationsStatus: null == conversationsStatus
                ? _value.conversationsStatus
                : conversationsStatus // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            conversations: null == conversations
                ? _value.conversations
                : conversations // ignore: cast_nullable_to_non_nullable
                      as List<ConversationResponse>,
            conversationsPage: null == conversationsPage
                ? _value.conversationsPage
                : conversationsPage // ignore: cast_nullable_to_non_nullable
                      as int,
            conversationsHasMore: null == conversationsHasMore
                ? _value.conversationsHasMore
                : conversationsHasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            messagesStatus: null == messagesStatus
                ? _value.messagesStatus
                : messagesStatus // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<MessageResponse>,
            activeConversationId: null == activeConversationId
                ? _value.activeConversationId
                : activeConversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            activeRecipientId: null == activeRecipientId
                ? _value.activeRecipientId
                : activeRecipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            messagesHasMore: null == messagesHasMore
                ? _value.messagesHasMore
                : messagesHasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            sendStatus: null == sendStatus
                ? _value.sendStatus
                : sendStatus // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            callStatus: null == callStatus
                ? _value.callStatus
                : callStatus // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            activeCall: freezed == activeCall
                ? _value.activeCall
                : activeCall // ignore: cast_nullable_to_non_nullable
                      as CallResponse?,
            notificationsStatus: null == notificationsStatus
                ? _value.notificationsStatus
                : notificationsStatus // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            notifications: null == notifications
                ? _value.notifications
                : notifications // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
    _$ChatStateImpl value,
    $Res Function(_$ChatStateImpl) then,
  ) = __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ChatViewMode viewMode,
    String pendingRecipientId,
    ChatStatus conversationsStatus,
    List<ConversationResponse> conversations,
    int conversationsPage,
    bool conversationsHasMore,
    ChatStatus messagesStatus,
    List<MessageResponse> messages,
    String activeConversationId,
    String activeRecipientId,
    bool messagesHasMore,
    ChatStatus sendStatus,
    ChatStatus callStatus,
    CallResponse? activeCall,
    ChatStatus notificationsStatus,
    List<Map<String, dynamic>> notifications,
    String errorMessage,
  });
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
    _$ChatStateImpl _value,
    $Res Function(_$ChatStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewMode = null,
    Object? pendingRecipientId = null,
    Object? conversationsStatus = null,
    Object? conversations = null,
    Object? conversationsPage = null,
    Object? conversationsHasMore = null,
    Object? messagesStatus = null,
    Object? messages = null,
    Object? activeConversationId = null,
    Object? activeRecipientId = null,
    Object? messagesHasMore = null,
    Object? sendStatus = null,
    Object? callStatus = null,
    Object? activeCall = freezed,
    Object? notificationsStatus = null,
    Object? notifications = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$ChatStateImpl(
        viewMode: null == viewMode
            ? _value.viewMode
            : viewMode // ignore: cast_nullable_to_non_nullable
                  as ChatViewMode,
        pendingRecipientId: null == pendingRecipientId
            ? _value.pendingRecipientId
            : pendingRecipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationsStatus: null == conversationsStatus
            ? _value.conversationsStatus
            : conversationsStatus // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        conversations: null == conversations
            ? _value._conversations
            : conversations // ignore: cast_nullable_to_non_nullable
                  as List<ConversationResponse>,
        conversationsPage: null == conversationsPage
            ? _value.conversationsPage
            : conversationsPage // ignore: cast_nullable_to_non_nullable
                  as int,
        conversationsHasMore: null == conversationsHasMore
            ? _value.conversationsHasMore
            : conversationsHasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        messagesStatus: null == messagesStatus
            ? _value.messagesStatus
            : messagesStatus // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<MessageResponse>,
        activeConversationId: null == activeConversationId
            ? _value.activeConversationId
            : activeConversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        activeRecipientId: null == activeRecipientId
            ? _value.activeRecipientId
            : activeRecipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        messagesHasMore: null == messagesHasMore
            ? _value.messagesHasMore
            : messagesHasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        sendStatus: null == sendStatus
            ? _value.sendStatus
            : sendStatus // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        callStatus: null == callStatus
            ? _value.callStatus
            : callStatus // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        activeCall: freezed == activeCall
            ? _value.activeCall
            : activeCall // ignore: cast_nullable_to_non_nullable
                  as CallResponse?,
        notificationsStatus: null == notificationsStatus
            ? _value.notificationsStatus
            : notificationsStatus // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        notifications: null == notifications
            ? _value._notifications
            : notifications // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl implements _ChatState {
  const _$ChatStateImpl({
    this.viewMode = ChatViewMode.messages,
    this.pendingRecipientId = '',
    this.conversationsStatus = ChatStatus.initial,
    final List<ConversationResponse> conversations = const [],
    this.conversationsPage = 1,
    this.conversationsHasMore = false,
    this.messagesStatus = ChatStatus.initial,
    final List<MessageResponse> messages = const [],
    this.activeConversationId = '',
    this.activeRecipientId = '',
    this.messagesHasMore = false,
    this.sendStatus = ChatStatus.initial,
    this.callStatus = ChatStatus.initial,
    this.activeCall = null,
    this.notificationsStatus = ChatStatus.initial,
    final List<Map<String, dynamic>> notifications = const [],
    this.errorMessage = '',
  }) : _conversations = conversations,
       _messages = messages,
       _notifications = notifications;

  // View state - controls which screen is shown
  @override
  @JsonKey()
  final ChatViewMode viewMode;
  // Pending recipient - set when navigating to chat from external source
  @override
  @JsonKey()
  final String pendingRecipientId;
  // Conversations
  @override
  @JsonKey()
  final ChatStatus conversationsStatus;
  final List<ConversationResponse> _conversations;
  @override
  @JsonKey()
  List<ConversationResponse> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  @override
  @JsonKey()
  final int conversationsPage;
  @override
  @JsonKey()
  final bool conversationsHasMore;
  // Messages (active chat)
  @override
  @JsonKey()
  final ChatStatus messagesStatus;
  final List<MessageResponse> _messages;
  @override
  @JsonKey()
  List<MessageResponse> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final String activeConversationId;
  @override
  @JsonKey()
  final String activeRecipientId;
  @override
  @JsonKey()
  final bool messagesHasMore;
  // Send message
  @override
  @JsonKey()
  final ChatStatus sendStatus;
  // Call
  @override
  @JsonKey()
  final ChatStatus callStatus;
  @override
  @JsonKey()
  final CallResponse? activeCall;
  // Notifications
  @override
  @JsonKey()
  final ChatStatus notificationsStatus;
  final List<Map<String, dynamic>> _notifications;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'ChatState(viewMode: $viewMode, pendingRecipientId: $pendingRecipientId, conversationsStatus: $conversationsStatus, conversations: $conversations, conversationsPage: $conversationsPage, conversationsHasMore: $conversationsHasMore, messagesStatus: $messagesStatus, messages: $messages, activeConversationId: $activeConversationId, activeRecipientId: $activeRecipientId, messagesHasMore: $messagesHasMore, sendStatus: $sendStatus, callStatus: $callStatus, activeCall: $activeCall, notificationsStatus: $notificationsStatus, notifications: $notifications, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.pendingRecipientId, pendingRecipientId) ||
                other.pendingRecipientId == pendingRecipientId) &&
            (identical(other.conversationsStatus, conversationsStatus) ||
                other.conversationsStatus == conversationsStatus) &&
            const DeepCollectionEquality().equals(
              other._conversations,
              _conversations,
            ) &&
            (identical(other.conversationsPage, conversationsPage) ||
                other.conversationsPage == conversationsPage) &&
            (identical(other.conversationsHasMore, conversationsHasMore) ||
                other.conversationsHasMore == conversationsHasMore) &&
            (identical(other.messagesStatus, messagesStatus) ||
                other.messagesStatus == messagesStatus) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.activeConversationId, activeConversationId) ||
                other.activeConversationId == activeConversationId) &&
            (identical(other.activeRecipientId, activeRecipientId) ||
                other.activeRecipientId == activeRecipientId) &&
            (identical(other.messagesHasMore, messagesHasMore) ||
                other.messagesHasMore == messagesHasMore) &&
            (identical(other.sendStatus, sendStatus) ||
                other.sendStatus == sendStatus) &&
            (identical(other.callStatus, callStatus) ||
                other.callStatus == callStatus) &&
            (identical(other.activeCall, activeCall) ||
                other.activeCall == activeCall) &&
            (identical(other.notificationsStatus, notificationsStatus) ||
                other.notificationsStatus == notificationsStatus) &&
            const DeepCollectionEquality().equals(
              other._notifications,
              _notifications,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    viewMode,
    pendingRecipientId,
    conversationsStatus,
    const DeepCollectionEquality().hash(_conversations),
    conversationsPage,
    conversationsHasMore,
    messagesStatus,
    const DeepCollectionEquality().hash(_messages),
    activeConversationId,
    activeRecipientId,
    messagesHasMore,
    sendStatus,
    callStatus,
    activeCall,
    notificationsStatus,
    const DeepCollectionEquality().hash(_notifications),
    errorMessage,
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState implements ChatState {
  const factory _ChatState({
    final ChatViewMode viewMode,
    final String pendingRecipientId,
    final ChatStatus conversationsStatus,
    final List<ConversationResponse> conversations,
    final int conversationsPage,
    final bool conversationsHasMore,
    final ChatStatus messagesStatus,
    final List<MessageResponse> messages,
    final String activeConversationId,
    final String activeRecipientId,
    final bool messagesHasMore,
    final ChatStatus sendStatus,
    final ChatStatus callStatus,
    final CallResponse? activeCall,
    final ChatStatus notificationsStatus,
    final List<Map<String, dynamic>> notifications,
    final String errorMessage,
  }) = _$ChatStateImpl;

  // View state - controls which screen is shown
  @override
  ChatViewMode get viewMode; // Pending recipient - set when navigating to chat from external source
  @override
  String get pendingRecipientId; // Conversations
  @override
  ChatStatus get conversationsStatus;
  @override
  List<ConversationResponse> get conversations;
  @override
  int get conversationsPage;
  @override
  bool get conversationsHasMore; // Messages (active chat)
  @override
  ChatStatus get messagesStatus;
  @override
  List<MessageResponse> get messages;
  @override
  String get activeConversationId;
  @override
  String get activeRecipientId;
  @override
  bool get messagesHasMore; // Send message
  @override
  ChatStatus get sendStatus; // Call
  @override
  ChatStatus get callStatus;
  @override
  CallResponse? get activeCall; // Notifications
  @override
  ChatStatus get notificationsStatus;
  @override
  List<Map<String, dynamic>> get notifications;
  @override
  String get errorMessage;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
