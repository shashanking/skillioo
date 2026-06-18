import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_voice_flutter/twilio_voice_flutter.dart';
import 'package:twilio_voice_flutter/model/event.dart';
import 'package:twilio_voice_flutter/model/status.dart';

/// Wrapper service for Twilio Voice Flutter SDK
/// Handles VoIP call functionality with Twilio using twilio_voice_flutter package
class TwilioVoiceService {
  static final TwilioVoiceService _instance = TwilioVoiceService._internal();
  factory TwilioVoiceService() => _instance;
  TwilioVoiceService._internal();

  static const _callManagerChannel = MethodChannel(
    'com.example.skillioo/call_manager',
  );

  bool _isRegistered = false;
  bool _isInitialized = false;
  String? _currentIdentity;
  StreamSubscription<TwilioVoiceFlutterEvent>? _eventSubscription;

  // Callbacks for call events
  Function(String callSid, String from)? onIncomingCall;
  Function(String callSid)? onCallConnected;
  Function(String callSid)? onCallDisconnected;
  Function(String callSid)? onCallRinging;
  Function(String callSid)? onCallConnecting;
  Function(String error)? onCallError;

  /// Initialize the Twilio SDK event stream — must be called once before any other operation
  void initSdk() {
    if (_isInitialized) return;
    _isInitialized = true;

    TwilioVoiceFlutter.init();
    debugPrint('TwilioVoiceService: SDK initialized');

    _eventSubscription = TwilioVoiceFlutter.onCallEvent.listen((event) {
      final callId = event.call?.id ?? '';
      final fromDisplayName = event.call?.fromDisplayName ?? '';
      debugPrint(
        'TwilioVoiceService: Event ${event.status} | callId=$callId from=$fromDisplayName',
      );

      switch (event.status) {
        case TwilioVoiceFlutterStatus.connecting:
          onCallConnecting?.call(callId);
          break;
        case TwilioVoiceFlutterStatus.ringing:
          onCallRinging?.call(callId);
          break;
        case TwilioVoiceFlutterStatus.connected:
          onCallConnected?.call(callId);
          break;
        case TwilioVoiceFlutterStatus.disconnected:
          onCallDisconnected?.call(callId);
          break;
        case TwilioVoiceFlutterStatus.reconnecting:
          debugPrint('TwilioVoiceService: Call reconnecting...');
          break;
        case TwilioVoiceFlutterStatus.reconnected:
          onCallConnected?.call(callId);
          break;
        case TwilioVoiceFlutterStatus.unknown:
          debugPrint('TwilioVoiceService: Unknown event');
          break;
      }
    });
  }

  /// Register device with Twilio Voice
  ///
  /// [identity] - User's unique identifier
  /// [accessToken] - Twilio access token from backend
  Future<bool> register({
    required String identity,
    required String accessToken,
  }) async {
    try {
      initSdk();

      String fcmToken = '';

      // Get FCM token for Android
      if (Platform.isAndroid) {
        debugPrint('TwilioVoiceService: Getting FCM token for Android...');
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
        if (fcmToken.isEmpty) {
          debugPrint('TwilioVoiceService: Failed to get FCM token');
          return false;
        }
        debugPrint('TwilioVoiceService: Got FCM token: $fcmToken');
      }

      debugPrint('TwilioVoiceService: Registering identity $identity...');
      await TwilioVoiceFlutter.register(
        identity: identity,
        accessToken: accessToken,
        fcmToken: fcmToken,
      );

      _isRegistered = true;
      _currentIdentity = identity;

      debugPrint(
        'TwilioVoiceService: Registered successfully with identity: $identity',
      );
      return true;
    } catch (e) {
      debugPrint('TwilioVoiceService: Registration error - $e');
      onCallError?.call(e.toString());
      return false;
    }
  }

  /// Unregister device from Twilio Voice
  Future<void> unregister() async {
    try {
      await TwilioVoiceFlutter.unregister();
      _isRegistered = false;
      _currentIdentity = null;
      debugPrint('TwilioVoiceService: Unregistered successfully');
    } catch (e) {
      debugPrint('TwilioVoiceService: Unregister error - $e');
    }
  }

  /// Make an outgoing call
  ///
  /// [to] - Recipient identifier (phone number or client identity)
  /// [extraParams] - Optional custom parameters for the call
  Future<bool> makeCall({
    required String to,
    Map<String, dynamic>? extraParams,
  }) async {
    if (!_isRegistered) {
      debugPrint('TwilioVoiceService: Cannot make call - not registered');
      return false;
    }

    // Check and request microphone and bluetooth permissions
    final micPermission = await Permission.microphone.status;
    if (!micPermission.isGranted) {
      debugPrint('TwilioVoiceService: Requesting microphone permission');
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        debugPrint('TwilioVoiceService: Microphone permission denied');
        if (onCallError != null) {
          onCallError!('Microphone permission is required for voice calls');
        }
        return false;
      }
    }

    if (Platform.isAndroid) {
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      if (!bluetoothConnect.isGranted) {
        debugPrint(
          'TwilioVoiceService: Requesting bluetoothConnect permission',
        );
        await Permission.bluetoothConnect.request();
      }
    }

    try {
      debugPrint(
        'TwilioVoiceService: Calling TwilioVoiceFlutter.makeCall to $to...',
      );

      final call = await TwilioVoiceFlutter.makeCall(
        to: to,
        data: extraParams ?? {},
      );
      debugPrint(
        'TwilioVoiceService: Outgoing call initiated to $to - Call ID: ${call.id}',
      );
      return true;
    } catch (e) {
      debugPrint('TwilioVoiceService: makeCall error: $e');
      if (onCallError != null) {
        onCallError!(e.toString());
      }
      return false;
    }
  }

  /// Accept incoming call via native Twilio CallInvite
  Future<void> acceptCall() async {
    try {
      // The accepting side also needs the microphone to transmit audio.
      // makeCall() already requests this; acceptCall() must too, otherwise
      // the call connects with no usable audio path.
      final micPermission = await Permission.microphone.status;
      if (!micPermission.isGranted) {
        debugPrint('TwilioVoiceService: Requesting microphone permission');
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          debugPrint('TwilioVoiceService: Microphone permission denied');
          onCallError?.call(
            'Microphone permission is required for voice calls',
          );
          return;
        }
      }

      if (Platform.isAndroid) {
        final bluetoothConnect = await Permission.bluetoothConnect.status;
        if (!bluetoothConnect.isGranted) {
          await Permission.bluetoothConnect.request();
        }
      }

      debugPrint('TwilioVoiceService: Accepting call via native channel...');
      final result = await _callManagerChannel.invokeMethod('answerCall');
      debugPrint('TwilioVoiceService: answerCall result: $result');
      // The Twilio SDK callListener will fire onCallConnected automatically
    } catch (e) {
      debugPrint('TwilioVoiceService: Accept call error - $e');
      // Fallback: fire connected callback so UI still transitions
      onCallConnected?.call('active-call');
      if (onCallError != null) {
        onCallError!(e.toString());
      }
    }
  }

  /// Reject incoming call via native Twilio CallInvite
  Future<void> rejectCall() async {
    try {
      debugPrint('TwilioVoiceService: Rejecting call via native channel...');
      await _callManagerChannel.invokeMethod('rejectCall');
      debugPrint('TwilioVoiceService: Call rejected via native');
      onCallDisconnected?.call('call-rejected');
    } catch (e) {
      debugPrint(
        'TwilioVoiceService: Native reject failed, falling back to hangUp - $e',
      );
      await hangUp();
    }
  }

  /// End active call
  Future<void> hangUp() async {
    try {
      await TwilioVoiceFlutter.hangUp();
      debugPrint('TwilioVoiceService: Call ended');
      if (onCallDisconnected != null) {
        onCallDisconnected!('call-ended');
      }
    } catch (e) {
      debugPrint('TwilioVoiceService: Hang up error - $e');
      if (onCallError != null) {
        onCallError!(e.toString());
      }
    }
  }

  /// Toggle mute status
  Future<void> toggleMute() async {
    try {
      await TwilioVoiceFlutter.toggleMute();
      final isMuted = await TwilioVoiceFlutter.isMuted();
      debugPrint('TwilioVoiceService: Mute toggled to $isMuted');
    } catch (e) {
      debugPrint('TwilioVoiceService: Toggle mute error - $e');
    }
  }

  /// Check if call is muted
  Future<bool> isMuted() async {
    try {
      return await TwilioVoiceFlutter.isMuted();
    } catch (e) {
      debugPrint('TwilioVoiceService: Is muted error - $e');
      return false;
    }
  }

  /// Toggle speaker mode
  Future<void> toggleSpeaker() async {
    try {
      await TwilioVoiceFlutter.toggleSpeaker();
      final isSpeaker = await TwilioVoiceFlutter.isSpeaker();
      debugPrint('TwilioVoiceService: Speaker toggled to $isSpeaker');
    } catch (e) {
      debugPrint('TwilioVoiceService: Toggle speaker error - $e');
    }
  }

  /// Check if speaker is enabled
  Future<bool> isSpeaker() async {
    try {
      return await TwilioVoiceFlutter.isSpeaker();
    } catch (e) {
      debugPrint('TwilioVoiceService: Is speaker error - $e');
      return false;
    }
  }

  /// Send DTMF digits during active call
  Future<void> sendDigits(String digits) async {
    try {
      await TwilioVoiceFlutter.sendDigits(digits);
      debugPrint('TwilioVoiceService: Sent DTMF digits: $digits');
    } catch (e) {
      debugPrint('TwilioVoiceService: Send digits error - $e');
    }
  }

  /// Check if registered
  bool get isRegistered => _isRegistered;

  /// Get current identity
  String? get currentIdentity => _currentIdentity;

  /// Dispose and cleanup
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    unregister();
    onIncomingCall = null;
    onCallConnected = null;
    onCallDisconnected = null;
    onCallRinging = null;
    onCallConnecting = null;
    onCallError = null;
  }
}
