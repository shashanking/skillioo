import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/call/domain/call_service.dart';
import 'session_prefs.dart';

/// Top-level background message handler (must be top-level or static)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  // Note: Background handler cannot update UI directly.
  // The app will process this when resumed via onMessageOpenedApp or onMessage.
}

/// Callback for handling incoming calls - set this in your app initialization
/// Format: onIncomingCall(callId, callerId)
Function(String callId, String callerId)? onIncomingCallCallback;

/// Callback fired when FCM rotates the device token. Set this in app
/// initialization (Landing) so the app can re-register with Twilio Voice
/// using the new token — otherwise Twilio keeps pushing to the stale
/// token and FCM rejects it (Twilio error 52103).
Function(String newToken)? onFcmTokenRefreshCallback;

/// Callback fired when a Twilio Voice CallInvite push arrives in the
/// foreground. The Twilio Voice Flutter package does not surface incoming
/// CallInvites to Dart on its own (its native side only shows a system
/// notification), so we use the FCM payload itself as the trigger to open
/// our in-app incoming-call screen.
///
/// Arguments are extracted from the Twilio FCM payload:
/// - [twilioCallSid] — Twilio's call SID (twi_call_sid)
/// - [from] — caller identity passed by Twilio (twi_from), typically of the
///   form "client:profileId"
Function(String twilioCallSid, String from)?
    onIncomingTwilioCallCallback;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Set up background message handler FIRST (before any other FCM operations)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permissions (required for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true, // For call notifications on iOS
    );

    if (kDebugMode) {
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }

    // 3. Get FCM token and save to backend
    await _generateAndSaveToken();

    // 4. Listen for token refreshes
    _fcm.onTokenRefresh
        .listen((newToken) {
          if (kDebugMode) {
            debugPrint('NotificationService: FCM token refreshed');
          }
          _saveTokenToBackend(newToken);
          // Re-register with Twilio so it pushes call invites to the new
          // token. Without this, Twilio keeps pushing to the old token,
          // FCM rejects it, and Twilio disables the token (error 52103).
          onFcmTokenRefreshCallback?.call(newToken);
        })
        .onError((err) {
          if (kDebugMode) debugPrint('FCM Token refresh error: $err');
        });

    // 5. Handle foreground messages (call invites)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Handle notification taps when app was in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 7. Check if app was opened from a notification (terminated state)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Returns true if the message is a Twilio Voice CallInvite push
  /// (delivered to the native Twilio SDK, not handled in Dart).
  bool _isTwilioVoicePush(Map<String, dynamic> data) {
    return data['twi_message_type'] == 'twilio.voice.call' ||
        data.containsKey('twi_call_sid') ||
        data.containsKey('twi_bridge_token');
  }

  /// Handle foreground messages - this is where we trigger incoming call UI
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: FOREGROUND MESSAGE RECEIVED');
    debugPrint('  Message ID: ${message.messageId}');
    debugPrint('  Notification: ${message.notification}');
    debugPrint('  From: ${message.from}');

    final data = message.data;

    // Twilio Voice CallInvite pushes: the Twilio SDK natively consumes
    // these via Voice.handleMessage(...) to create a CallInvite. The Dart
    // package does NOT expose an incoming-call event, so we use the FCM
    // arrival itself as the signal to open our in-app incoming-call
    // screen.
    if (_isTwilioVoicePush(data)) {
      final twilioCallSid = data['twi_call_sid']?.toString() ?? '';
      final from = data['twi_from']?.toString() ?? '';
      debugPrint(
        'NotificationService: Twilio Voice push received '
        '(call_sid=$twilioCallSid from=$from) — opening incoming call UI',
      );
      onIncomingTwilioCallCallback?.call(twilioCallSid, from);
      return;
    }

    debugPrint('  Data: $data');

    // Check if this is our backend's app-level call signal
    final callId = data['callId'] ?? data['call_id'] ?? data['id'];
    final callerId = data['callerId'] ?? data['caller_id'] ?? data['from'];

    debugPrint(
      'NotificationService: Parsed callId=$callId, callerId=$callerId',
    );

    if (callId != null && callerId != null) {
      debugPrint('NotificationService: Call invite detected - triggering UI');
      _triggerIncomingCall(callId.toString(), callerId.toString());
    } else {
      debugPrint(
        'NotificationService: Not a call invite (missing callId or callerId)',
      );
    }
  }

  /// Handle notification tap when app was in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('NotificationService: APP OPENED FROM BACKGROUND/TERMINATED');
    debugPrint('  Message ID: ${message.messageId}');

    final data = message.data;

    // Twilio Voice pushes are consumed natively — see _handleForegroundMessage.
    if (_isTwilioVoicePush(data)) {
      debugPrint(
        'NotificationService: Twilio Voice push (background) '
        'call_sid=${data['twi_call_sid']} — handled natively, skipping',
      );
      return;
    }

    debugPrint('  Data: $data');
    final callId = data['callId'] ?? data['call_id'] ?? data['id'];
    final callerId = data['callerId'] ?? data['caller_id'] ?? data['from'];

    debugPrint(
      'NotificationService: Parsed callId=$callId, callerId=$callerId',
    );

    if (callId != null && callerId != null) {
      debugPrint('NotificationService: Call invite detected - triggering UI');
      _triggerIncomingCall(callId.toString(), callerId.toString());
    } else {
      debugPrint(
        'NotificationService: Not a call invite (missing callId or callerId)',
      );
    }
  }

  /// Trigger incoming call UI via static callback
  Future<void> _triggerIncomingCall(String callId, String callerId) async {
    debugPrint('NotificationService: _triggerIncomingCall called');
    debugPrint('  callId: $callId, callerId: $callerId');

    // The backend fans out the "call started" FCM to both parties.
    // When the caller's own device receives it, the callerId matches
    // their profileId — drop it so we don't show the incoming-call
    // screen to the person who just placed the call.
    final selfProfileId = await SessionPrefs.instance.getProfileId();
    if (selfProfileId.isNotEmpty && callerId == selfProfileId) {
      debugPrint(
        'NotificationService: callerId matches own profileId — ignoring self-call FCM',
      );
      return;
    }

    debugPrint(
      '  onIncomingCallCallback is ${onIncomingCallCallback != null ? "SET" : "NULL"}',
    );
    if (onIncomingCallCallback != null) {
      debugPrint('NotificationService: Triggering incoming call callback');
      onIncomingCallCallback!(callId, callerId);
    } else {
      debugPrint(
        'NotificationService: No incoming call callback registered - CALL WILL NOT SHOW',
      );
    }
  }

  Future<void> _generateAndSaveToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        if (kDebugMode) debugPrint('FCM Token: $token');
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get FCM token: $e');
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      final isLoggedIn = await SessionPrefs.instance.isLoggedIn();
      if (!isLoggedIn) return;

      final userId = await SessionPrefs.instance.getUserId();
      final accessToken = await SessionPrefs.instance.getAccessToken();

      if (userId.isEmpty || accessToken.isEmpty) return;

      final service = CallService();
      final res = await service.setFcmToken(
        token: token,
        userId: userId,
        accessToken: accessToken,
      );

      if (kDebugMode) {
        debugPrint('Saved FCM token to backend: $res');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save FCM token to backend: $e');
      }
    }
  }
}
