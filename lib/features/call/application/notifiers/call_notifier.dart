import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/video_controller_registry.dart';
import '../../domain/call_models.dart';
import '../../domain/call_service.dart';
import '../../domain/twilio_voice_service.dart';
import '../states/call_state.dart';

class CallNotifier extends StateNotifier<CallState> {
  final CallService _callService;
  final TwilioVoiceService _twilioVoice = TwilioVoiceService();
  String? _currentCallId;
  String? _recipientId;

  CallNotifier(this._callService) : super(const CallState()) {
    _setupTwilioCallbacks();
    _setupSocketCallbacks();
  }

  void _setupTwilioCallbacks() {
    _twilioVoice.initSdk();

    _twilioVoice.onCallConnecting = (callSid) {
      debugPrint('CallNotifier: Call connecting - $callSid');
      state = state.copyWith(status: CallStateStatus.ringing);
    };

    _twilioVoice.onCallConnected = (callSid) {
      debugPrint('CallNotifier: Call connected - $callSid');
      state = state.copyWith(status: CallStateStatus.success, isInCall: true);
    };

    _twilioVoice.onCallDisconnected = (callSid) {
      debugPrint('CallNotifier: Call disconnected - $callSid');
      state = state.copyWith(
        status: CallStateStatus.idle,
        isInCall: false,
        currentCall: null,
      );
      _currentCallId = null;
      _recipientId = null;
    };

    _twilioVoice.onCallRinging = (callSid) {
      debugPrint('CallNotifier: Call ringing - $callSid');
    };

    _twilioVoice.onCallError = (error) {
      debugPrint('CallNotifier: Call error - $error');
      state = state.copyWith(
        status: CallStateStatus.error,
        errorMessage: error,
        isInCall: false,
      );
    };

    _twilioVoice.onIncomingCall = (callSid, from) {
      debugPrint('CallNotifier: Incoming call from $from - $callSid');
      _currentCallId = callSid;
      state = state.copyWith(
        status: CallStateStatus.incomingCall,
        isInCall: false,
      );
    };
  }

  void _setupSocketCallbacks() {
    final socketService = SocketService();

    socketService.onIncomingCall = (data) {
      debugPrint('CallNotifier: socket incomingCall event: $data');
      final callId = data['callId']?.toString() ?? '';
      final callerId = data['callerId']?.toString() ?? '';
      final callerName = data['callerName']?.toString() ?? '';
      final callerAvatar = data['callerAvatar']?.toString() ?? '';

      // Capture caller metadata so it's available by the time the Twilio
      // CallInvite (delivered via FCM) drives the incoming-call screen,
      // but do NOT trigger the screen from socket — only push notifications
      // should open the incoming-call UI. The socket is unreliable when the
      // app is backgrounded/killed; FCM/Twilio is the authoritative path.
      if (callId.isNotEmpty) {
        _currentCallId = callId;
      }
      state = state.copyWith(
        callerId: callerId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      );
    };

    socketService.onAnswer = (data) {
      debugPrint('CallNotifier: socket answer event: $data');
      final callId = data['callId']?.toString() ?? _currentCallId;
      if (callId != null && callId.isNotEmpty) {
        _currentCallId = callId;
      }
      state = state.copyWith(status: CallStateStatus.success, isInCall: true);
    };

    socketService.onCallRejected = (data) {
      debugPrint('CallNotifier: socket callRejected event: $data');
      state = state.copyWith(
        status: CallStateStatus.idle,
        isInCall: false,
        currentCall: null,
      );
      _currentCallId = null;
      _recipientId = null;
    };

    socketService.onEndCall = (data) {
      debugPrint('CallNotifier: socket endCall event: $data');
      state = state.copyWith(
        status: CallStateStatus.idle,
        isInCall: false,
        currentCall: null,
      );
      _currentCallId = null;
      _recipientId = null;
    };
  }

  String? get currentCallId => _currentCallId;
  String? get recipientId => _recipientId;

  /// Register this device with Twilio so it can RECEIVE incoming calls.
  /// Should be called on app start after user is logged in.
  Future<void> registerWithTwilio() async {
    try {
      final userId = await SessionPrefs.instance.getUserId();
      final accessToken = await SessionPrefs.instance.getAccessToken();

      if (userId.isEmpty || accessToken.isEmpty) {
        debugPrint(
          'CallNotifier: Cannot register Twilio - missing credentials',
        );
        return;
      }

      final twilioToken = await _fetchTwilioToken(userId, accessToken);
      if (twilioToken == null) return;

      await _twilioVoice.register(identity: userId, accessToken: twilioToken);
      debugPrint('CallNotifier: Registered with Twilio for incoming calls');
    } catch (e) {
      debugPrint('CallNotifier: Error registering with Twilio: $e');
    }
  }

  /// Internal helper to fetch Twilio token without mutating state
  Future<String?> _fetchTwilioToken(String userId, String accessToken) async {
    try {
      final response = await _callService.getCallToken(
        provider: CallProvider.twilio,
        callerId: userId,
        accessToken: accessToken,
      );
      final success =
          response['status'] == 200 ||
          response['status'] == 201 ||
          response['success'] == true;
      if (!success) return null;

      final rawData = response['data'];
      if (rawData is String) return rawData;
      if (rawData is Map && rawData.containsKey('token')) {
        return rawData['token'].toString();
      }
      return rawData?.toString();
    } catch (e) {
      debugPrint('CallNotifier: Error fetching Twilio token: $e');
      return null;
    }
  }

  Future<void> registerFcmToken(String fcmToken) async {
    try {
      final userId = await SessionPrefs.instance.getUserId();
      final accessToken = await SessionPrefs.instance.getAccessToken();

      if (userId.isEmpty || accessToken.isEmpty) {
        debugPrint('CallNotifier: Missing userId or accessToken');
        return;
      }

      final response = await _callService.setFcmToken(
        token: fcmToken,
        userId: userId,
        accessToken: accessToken,
      );

      debugPrint('CallNotifier: FCM token registered: $response');
    } catch (e) {
      debugPrint('CallNotifier: Error registering FCM token: $e');
    }
  }

  Future<String?> getTwilioToken() async {
    try {
      debugPrint('CallNotifier: Getting Twilio token...');
      state = state.copyWith(status: CallStateStatus.loading);

      final userId = await SessionPrefs.instance.getUserId();
      final accessToken = await SessionPrefs.instance.getAccessToken();

      if (userId.isEmpty || accessToken.isEmpty) {
        debugPrint(
          'CallNotifier: Missing userId or accessToken for Twilio token',
        );
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: 'Missing userId or accessToken',
        );
        return null;
      }

      final response = await _callService.getCallToken(
        provider: CallProvider.twilio,
        callerId: userId,
        accessToken: accessToken,
      );

      debugPrint('CallNotifier: getCallToken response: $response');
      final success =
          response['status'] == 200 ||
          response['status'] == 201 ||
          response['success'] == true;
      if (!success) {
        debugPrint('CallNotifier: getCallToken backend error');
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: response['message'] ?? 'Failed to get call token',
        );
        return null;
      }

      var twilioToken = '';
      final rawData = response['data'];
      if (rawData is String) {
        twilioToken = rawData;
      } else if (rawData is Map && rawData.containsKey('token')) {
        twilioToken = rawData['token'].toString();
      } else if (rawData == null) {
        debugPrint('CallNotifier: getCallToken returned null data');
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: 'Server returned no token data',
        );
        return null;
      } else {
        // Fallback to string representation if it's something else
        twilioToken = rawData.toString();
      }

      debugPrint('CallNotifier: Got Twilio token successfully');
      state = state.copyWith(
        status: CallStateStatus.success,
        twilioToken: twilioToken,
      );

      return twilioToken;
    } catch (e) {
      debugPrint('CallNotifier: Error getting Twilio token: $e');
      state = state.copyWith(
        status: CallStateStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> initiateCall(String recipientId) async {
    try {
      final trimmedRecipientId = recipientId.trim();
      if (trimmedRecipientId.isEmpty) {
        debugPrint('CallNotifier: recipientId is empty');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Invalid recipient',
        );
        return false;
      }

      debugPrint('CallNotifier: Initiating call to $trimmedRecipientId');

      // Free file descriptors held by video players — Twilio's native SDK
      // crashes if FDs exceed 1024 (FD_SET_chk).
      debugPrint(
        'CallNotifier: disposing ${VideoControllerRegistry.instance.count} video controllers',
      );
      await VideoControllerRegistry.instance.disposeAll();

      state = state.copyWith(status: CallStateStatus.calling);
      _recipientId = trimmedRecipientId;

      final userId = await SessionPrefs.instance.getUserId();
      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty || userId.isEmpty) {
        debugPrint('CallNotifier: Missing accessToken or userId');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Missing accessToken or userId',
        );
        return false;
      }

      // Get Twilio token first (use internal helper to avoid mutating state)
      debugPrint('CallNotifier: Getting Twilio token...');
      final twilioToken = await _fetchTwilioToken(userId, accessToken);
      if (twilioToken == null) {
        debugPrint('CallNotifier: Failed to get Twilio token');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Failed to get call token',
        );
        return false;
      }

      // Register with Twilio Voice SDK
      debugPrint('CallNotifier: Registering with Twilio Voice SDK...');
      final registered = await _twilioVoice.register(
        identity: userId,
        accessToken: twilioToken,
      );

      if (!registered) {
        debugPrint('CallNotifier: Failed to register with Twilio');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Failed to register with Twilio',
        );
        return false;
      }

      // Initiate the call on backend
      debugPrint('CallNotifier: Calling backend initiateCall...');
      final response = await _callService.initiateCall(
        recipientId: recipientId,
        // required other person's fcm token
        // registrationToken: twilioToken,
        accessToken: accessToken,
      );

      debugPrint('CallNotifier: Backend response: $response');
      final responseData = response['data'];
      // Backend might return success as a boolean or status as 200/201. Also check for existence of data.
      final success =
          (response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == 201 ||
          (response['status'] == null &&
              response['success'] == null &&
              responseData != null));

      if (!success) {
        debugPrint(
          'CallNotifier: Backend initiation failed or missing data. Data: $responseData',
        );
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage:
              response['message'] ??
              (responseData == null
                  ? 'Server returned no data'
                  : 'Failed to initiate call'),
        );
        return false;
      }

      CallData callData;
      try {
        callData = CallData.fromJson(responseData as Map<String, dynamic>);
      } catch (e) {
        debugPrint('CallNotifier: Error parsing CallData: $e');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Error parsing server response',
        );
        return false;
      }
      _currentCallId = callData.id;

      // Make actual VoIP call via Twilio SDK
      debugPrint('CallNotifier: Making Twilio VoIP call...');
      final callMade = await _twilioVoice.makeCall(to: recipientId);
      if (!callMade) {
        debugPrint('CallNotifier: Failed to make Twilio call');
        state = state.copyWith(
          status: CallStateStatus.idle,
          errorMessage: 'Failed to make Twilio call',
        );
        return false;
      }

      debugPrint('CallNotifier: Call initiated successfully');
      state = state.copyWith(
        status: CallStateStatus.ringing,
        currentCall: callData,
        isInCall: false,
        twilioToken: twilioToken,
        callerId: callData.callerId,
        recipientId: callData.recipientId,
      );

      return true;
    } catch (e) {
      debugPrint('CallNotifier: Error initiating call: $e');
      state = state.copyWith(
        status: CallStateStatus.idle,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> acceptCall(String callId) async {
    try {
      state = state.copyWith(status: CallStateStatus.loading);
      _currentCallId = callId;

      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: 'Missing accessToken',
        );
        return false;
      }

      // Update backend
      final response = await _callService.acceptCall(
        callId: callId,
        accessToken: accessToken,
      );
      debugPrint('CallNotifier: acceptCall backend response: $response');

      final responseData = response['data'];
      final success =
          response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == 201 ||
          (response['status'] == null &&
              response['success'] == null &&
              responseData != null);
      if (!success) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: response['message'] ?? 'Failed to accept call',
        );
        return false;
      }

      // Accept call via Twilio SDK after backend confirms
      await _twilioVoice.acceptCall();

      state = state.copyWith(status: CallStateStatus.success, isInCall: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        status: CallStateStatus.error,
        errorMessage: e.toString(),
      );
      debugPrint('CallNotifier: Error accepting call: $e');
      return false;
    }
  }

  Future<bool> rejectCall(String callId) async {
    try {
      state = state.copyWith(status: CallStateStatus.loading);

      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: 'Missing accessToken',
        );
        return false;
      }

      // Update backend
      final response = await _callService.rejectCall(
        callId: callId,
        accessToken: accessToken,
      );
      debugPrint('CallNotifier: rejectCall backend response: $response');

      final responseData = response['data'];
      final success =
          response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == 201 ||
          (response['status'] == null &&
              response['success'] == null &&
              responseData != null);
      if (!success) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: response['message'] ?? 'Failed to reject call',
        );
        return false;
      }

      // Reject call via Twilio SDK after backend confirms
      await _twilioVoice.rejectCall();

      state = state.copyWith(
        status: CallStateStatus.idle,
        isInCall: false,
        currentCall: null,
      );
      _currentCallId = null;
      _recipientId = null;

      return true;
    } catch (e) {
      state = state.copyWith(
        status: CallStateStatus.error,
        errorMessage: e.toString(),
      );
      debugPrint('CallNotifier: Error rejecting call: $e');
      return false;
    }
  }

  Future<bool> endCall(String callId) async {
    try {
      state = state.copyWith(status: CallStateStatus.loading);

      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: 'Missing accessToken',
        );
        return false;
      }

      // Update backend
      final response = await _callService.endCall(
        callId: callId,
        accessToken: accessToken,
      );
      debugPrint('CallNotifier: endCall backend response: $response');

      final responseData = response['data'];
      final success =
          response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == 201 ||
          (response['status'] == null &&
              response['success'] == null &&
              responseData != null);
      if (!success) {
        state = state.copyWith(
          status: CallStateStatus.error,
          errorMessage: response['message'] ?? 'Failed to end call',
        );
        return false;
      }

      // End the local Twilio call too
      await _twilioVoice.hangUp();

      state = state.copyWith(
        status: CallStateStatus.idle,
        isInCall: false,
        currentCall: null,
      );

      _currentCallId = null;
      _recipientId = null;

      return true;
    } catch (e) {
      state = state.copyWith(
        status: CallStateStatus.error,
        errorMessage: e.toString(),
      );
      debugPrint('CallNotifier: Error ending call: $e');
      return false;
    }
  }

  // Helper methods for call controls
  Future<void> toggleMute() async {
    await _twilioVoice.toggleMute();
  }

  Future<bool> isMuted() async {
    return await _twilioVoice.isMuted();
  }

  Future<void> toggleSpeaker() async {
    await _twilioVoice.toggleSpeaker();
  }

  Future<bool> isSpeaker() async {
    return await _twilioVoice.isSpeaker();
  }

  @override
  void dispose() {
    _twilioVoice.dispose();
    super.dispose();
  }

  void reset() {
    state = const CallState();
  }

  /// Handle incoming call from FCM notification (called by NotificationService)
  void handleIncomingCall(String callId, String callerId) {
    debugPrint('CallNotifier: Handling incoming call from notification');
    debugPrint('  callId: $callId, callerId: $callerId');
    _currentCallId = callId;
    _recipientId = callerId;
    state = state.copyWith(
      status: CallStateStatus.incomingCall,
      isInCall: false,
    );
  }

  /// Handle Twilio Voice CallInvite push arriving in foreground.
  /// The Twilio package doesn't surface incoming CallInvites to Dart, so
  /// the FCM payload itself is the trigger for opening our in-app screen.
  ///
  /// Caller metadata (name/avatar/our-backend callId) was stashed earlier
  /// by the socket 'incomingCall' event handler; we only need the Twilio
  /// call SID and caller identity from the push itself.
  void handleIncomingTwilioPush(String twilioCallSid, String from) {
    debugPrint(
      'CallNotifier: Twilio push received — opening incoming call screen '
      '(twilioCallSid=$twilioCallSid from=$from)',
    );
    // 'from' is typically "client:<profileId>" — strip the prefix to match
    // what the socket event captured.
    final fromProfileId = from.startsWith('client:')
        ? from.substring('client:'.length)
        : from;
    state = state.copyWith(
      status: CallStateStatus.incomingCall,
      callerId: state.callerId.isNotEmpty ? state.callerId : fromProfileId,
      isInCall: false,
    );
  }
}
