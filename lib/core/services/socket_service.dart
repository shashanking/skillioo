import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';
import 'session_prefs.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  String? _currentProfileId;

  // Retry logic
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const int _baseRetryDelay = 1000; // 1 second
  bool _isRetrying = false;

  // Callbacks for status changes
  final List<Function(String userId, bool isOnline)> _statusChangeListeners =
      [];

  // Call event listeners
  Function(Map<String, dynamic> data)? onIncomingCall;
  Function(Map<String, dynamic> data)? onAnswer;
  Function(Map<String, dynamic> data)? onCallRejected;
  Function(Map<String, dynamic> data)? onEndCall;

  // Chat event listeners
  Function(Map<String, dynamic> data)? onNewMessage;
  Function(Map<String, dynamic> data)? onConversationUpdated;

  bool get isConnected => _isConnected;
  int get retryCount => _retryCount;

  void addStatusChangeListener(
    Function(String userId, bool isOnline) listener,
  ) {
    _statusChangeListeners.add(listener);
  }

  void removeStatusChangeListener(
    Function(String userId, bool isOnline) listener,
  ) {
    _statusChangeListeners.remove(listener);
  }

  Future<void> connect() async {
    if (_socket != null) {
      try {
        _socket!.disconnect();
        _socket!.dispose();
      } catch (_) {}
      _socket = null;
      _isConnected = false;
    }

    try {
      final profileId = await SessionPrefs.instance.getProfileId();
      if (profileId.isEmpty) {
        if (kDebugMode) {
          debugPrint('SocketService: No profileId, skipping connection');
        }
        return;
      }

      _currentProfileId = profileId;

      // Derive socket origin from the customer REST base URL so the socket
      // always points at the same host the rest of the app talks to.
      final restUri = Uri.parse(ApiConfig.customerBaseUrl);
      final socketUrl = '${restUri.scheme}://${restUri.host}';
      const socketPath = '/customer/socket.io';

      // Match the backend team's verified working config:
      // websocket-first with polling fallback, no disableAutoConnect.
      // We still attach listeners synchronously below before the socket
      // actually completes its handshake, so onConnect/onError will fire.
      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setPath(socketPath)
            .build(),
      );

      if (kDebugMode) {
        debugPrint(
          'SocketService: connecting url=$socketUrl path=$socketPath profileId=$profileId',
        );
      }

      _socket!.onConnect((_) {
        _isConnected = true;
        _retryCount = 0; // Reset retry count on successful connection
        _isRetrying = false;
        if (kDebugMode) debugPrint('SocketService: Connected to server');

        // Register user as online
        if (_currentProfileId != null) {
          _socket!.emit('register', {'profileId': _currentProfileId});
          if (kDebugMode) {
            debugPrint(
              'SocketService: Registered profileId: $_currentProfileId',
            );
          }
        }
      });

      _socket!.on('incomingCall', (data) {
        if (kDebugMode) debugPrint('SocketService: incomingCall event: $data');
        if (data is Map) {
          onIncomingCall?.call(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('answer', (data) {
        if (kDebugMode) debugPrint('SocketService: answer event: $data');
        if (data is Map) {
          onAnswer?.call(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('callRejected', (data) {
        if (kDebugMode) debugPrint('SocketService: callRejected event: $data');
        if (data is Map) {
          onCallRejected?.call(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('endCall', (data) {
        if (kDebugMode) debugPrint('SocketService: endCall event: $data');
        if (data is Map) {
          onEndCall?.call(Map<String, dynamic>.from(data));
        }
      });

      // Chat events — backend emits these when a message is sent to this user
      _socket!.on('newMessage', (data) {
        if (kDebugMode) debugPrint('SocketService: newMessage event: $data');
        if (data is Map) {
          onNewMessage?.call(Map<String, dynamic>.from(data));
        }
      });
      // Some backends use 'receiveMessage' — listen to both
      _socket!.on('receiveMessage', (data) {
        if (kDebugMode) debugPrint('SocketService: receiveMessage event: $data');
        if (data is Map) {
          onNewMessage?.call(Map<String, dynamic>.from(data));
        }
      });
      _socket!.on('conversationUpdated', (data) {
        if (kDebugMode) debugPrint('SocketService: conversationUpdated event: $data');
        if (data is Map) {
          onConversationUpdated?.call(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('userStatusChanged', (data) {
        if (kDebugMode) debugPrint('SocketService: User status changed: $data');

        if (data is Map) {
          // Backend emits { profileId, isOnline } — not userId.
          final profileId = data['profileId'] as String?;
          final isOnline = data['isOnline'] as bool?;

          if (profileId != null && isOnline != null) {
            for (final listener in _statusChangeListeners) {
              listener(profileId, isOnline);
            }
          }
        }
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        if (kDebugMode) {
          debugPrint('SocketService: Disconnected from server');
        }

        // Attempt reconnection with exponential backoff
        _attemptReconnect();
      });

      _socket!.onError((error) {
        if (kDebugMode) {
          debugPrint('SocketService: Error: $error');
        }
      });

      _socket!.onConnectError((err) {
        if (kDebugMode) {
          debugPrint('SocketService: Connect error: $err');
        }
      });

      // Socket auto-connects (no disableAutoConnect). Listeners attached
      // above will receive events as they fire.
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SocketService: Connection error: $e');
      }
    }
  }

  void _attemptReconnect() async {
    if (_isRetrying || _retryCount >= _maxRetries) {
      if (_retryCount >= _maxRetries) {
        if (kDebugMode) {
          debugPrint('SocketService: Max retries reached, giving up');
        }
      }
      return;
    }

    _isRetrying = true;
    _retryCount++;

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    final delay = _baseRetryDelay * (1 << (_retryCount - 1));
    if (kDebugMode) {
      debugPrint(
        'SocketService: Reconnecting in ${delay}ms (attempt $_retryCount/$_maxRetries)',
      );
    }

    await Future.delayed(Duration(milliseconds: delay));

    if (_socket != null && !_isConnected) {
      try {
        _socket!.connect();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SocketService: Reconnection attempt failed: $e');
        }
        _isRetrying = false;
      }
    } else {
      _isRetrying = false;
    }
  }

  void disconnect() {
    _retryCount = _maxRetries; // Prevent reconnection attempts
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _currentProfileId = null;
      if (kDebugMode) debugPrint('SocketService: Disconnected and disposed');
    }
  }

  void emitUserOnline(String profileId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('userOnline', profileId);
      if (kDebugMode) {
        debugPrint('SocketService: Emitted userOnline for $profileId');
      }
    }
  }

  void emitUserOffline(String profileId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('userOffline', profileId);
      if (kDebugMode) {
        debugPrint('SocketService: Emitted userOffline for $profileId');
      }
    }
  }

  /// Fires all registered status-change listeners manually.
  /// Used to mark a user as online when we receive a message from them
  /// (they're clearly active, even if no socket status event fired).
  void notifyStatusChange(String userId, bool isOnline) {
    for (final listener in _statusChangeListeners) {
      listener(userId, isOnline);
    }
  }

  /// Emits a request to the backend to push current online status for the
  /// given user IDs. The backend responds with `userStatusChanged` per user.
  void requestUsersStatus(List<String> userIds) {
    if (_socket == null || !_isConnected || userIds.isEmpty) return;
    _socket!.emit('getStatus', {'userIds': userIds});
    if (kDebugMode) {
      debugPrint('SocketService: requested status for ${userIds.length} users');
    }
  }

  void emitAnswer(Map<String, dynamic> payload) {
    if (_socket != null && _isConnected) {
      _socket!.emit('answer', payload);
      if (kDebugMode) debugPrint('SocketService: Emitted answer $payload');
    }
  }

  void emitEndCall(Map<String, dynamic> payload) {
    if (_socket != null && _isConnected) {
      _socket!.emit('endCall', payload);
      if (kDebugMode) debugPrint('SocketService: Emitted endCall $payload');
    }
  }
}
