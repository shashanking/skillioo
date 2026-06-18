# Twilio VoIP Calling Setup Guide

This document provides comprehensive instructions for setting up and testing Twilio VoIP calling in the Skillioo app.

## Overview

The Twilio VoIP integration enables voice calling functionality with the following features:
- Outgoing calls to other users
- Incoming call notifications
- Call accept/reject/end functionality
- Mute and speaker controls
- Call history tracking
- FCM push notifications for calls

## Architecture

### Backend Integration
- **FCM Token Management**: `/v1/token` endpoint for registering device tokens
- **Twilio Token**: `/v1/call/token` endpoint for getting Twilio access tokens
- **Call Management**: `/v1/call` endpoints for initiating, accepting, rejecting, and ending calls

### Frontend Components
1. **CallService** (`lib/features/call/domain/call_service.dart`): Handles all backend API calls
2. **CallNotifier** (`lib/features/call/application/notifiers/call_notifier.dart`): State management for calls
3. **CallPage** (`lib/features/dashboard/presentation/widgets/call_page.dart`): UI for incoming, active, and ended calls
4. **TwilioVoiceService** (`lib/features/call/domain/twilio_voice_service.dart`): Wrapper for Twilio Voice SDK (placeholder)

## Native Platform Configuration

### iOS Configuration

#### 1. Info.plist Permissions
Already configured in `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
    <string>remote-notification</string>
</array>

<key>NSMicrophoneUsageDescription</key>
<string>Skillioo needs access to your microphone to record videos and make voice/video calls.</string>
```

#### 2. CallKit Integration (Required for iOS)
You need to add CallKit support in your iOS native code:

**File: `ios/Runner/AppDelegate.swift`**
```swift
import UIKit
import Flutter
import CallKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    let callKitProvider = CXProvider(configuration: CXProviderConfiguration(localizedName: "Skillioo"))
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Configure CallKit
        callKitProvider.setDelegate(self, queue: nil)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Handle answer call
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Handle end call
        action.fulfill()
    }
}
```

#### 3. VoIP Push Notifications
Enable VoIP push notifications in your Apple Developer account:
1. Go to Certificates, Identifiers & Profiles
2. Select your App ID
3. Enable "Push Notifications" capability
4. Create VoIP Services Certificate
5. Download and configure in your Twilio console

### Android Configuration

#### 1. Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- VoIP call permissions -->
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Foreground service for calls -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
```

#### 2. FCM Configuration
Firebase Cloud Messaging is already configured for push notifications. Ensure:
1. `google-services.json` is in `android/app/`
2. FCM is enabled in Firebase Console
3. Server key is configured in Twilio Console

## Backend Setup Requirements

### 1. Twilio Account Setup
1. Create a Twilio account at https://www.twilio.com
2. Get your Account SID and Auth Token
3. Create a TwiML App for voice calling
4. Configure your backend to generate access tokens

### 2. Backend API Implementation
Your backend should implement:

**GET `/v1/call/token`**
- Query params: `provider=TWILIO`, `callerId={userId}`
- Returns: Twilio access token for the user
- Token should include:
  - Identity: user's profile ID
  - Grants: voice incoming/outgoing permissions
  - TwiML App SID

**POST `/v1/call`**
- Body: `{ recipientId, registrationToken }`
- Creates call record in database
- Sends push notification to recipient
- Returns: Call data with call ID

**PATCH `/v1/call/accept/{callId}`**
- Updates call status to ACCEPTED
- Returns: Updated call data

**PATCH `/v1/call/reject/{callId}`**
- Updates call status to REJECTED
- Returns: Updated call data

**PATCH `/v1/call/end/{callId}`**
- Updates call status to ENDED
- Returns: Updated call data

### 3. TwiML Configuration
Create a TwiML Bin or endpoint that handles incoming calls:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Dial callerId="{your_twilio_number}">
        <Client>{recipientId}</Client>
    </Dial>
</Response>
```

## App Flow

### Outgoing Call Flow
1. User taps call button in chat history
2. `CallNotifier.initiateCall(recipientId)` is called
3. Backend fetches Twilio token (GET `/v1/call/token`)
4. Backend initiates call (POST `/v1/call`)
5. Push notification sent to recipient
6. Caller sees "calling" state in UI
7. When recipient accepts, call connects via Twilio

### Incoming Call Flow
1. Backend sends FCM push notification with call data
2. App receives notification and shows incoming call UI
3. User can accept or reject
4. Accept: `CallNotifier.acceptCall(callId)` → PATCH `/v1/call/accept/{callId}`
5. Reject: `CallNotifier.rejectCall(callId)` → PATCH `/v1/call/reject/{callId}`
6. Call connects via Twilio Voice SDK

### Active Call Flow
1. Call is connected via Twilio
2. User can:
   - Mute/unmute microphone
   - Toggle speaker
   - End call
3. End call: `CallNotifier.endCall(callId)` → PATCH `/v1/call/end/{callId}`

## Testing

### 1. FCM Token Registration
Check logs on app start:
```
CallNotifier: FCM token registered: {response}
```

### 2. Initiate Call
1. Open chat history
2. Tap call button on any conversation
3. Check logs:
```
CallNotifier: Outgoing call initiated to {recipientId}
```

### 3. Backend Testing
Use Postman to test endpoints:

**Get Twilio Token:**
```
GET https://skillioo.in/customer/api/v1/call/token?provider=TWILIO&callerId={userId}
Authorization: Bearer {accessToken}
```

**Initiate Call:**
```
POST https://skillioo.in/customer/api/v1/call
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "recipientId": "{recipientProfileId}",
  "registrationToken": "{twilioToken}"
}
```

## Twilio Voice SDK Integration

**Note:** The `twilio_voice` package (v0.1.3) has limited API support. For full VoIP functionality, you may need to:

1. **Upgrade to latest twilio_voice package** (if compatible with dependencies)
2. **Implement native platform channels** for advanced Twilio features
3. **Use Twilio Programmable Voice REST API** for basic call functionality

Current implementation uses backend APIs for call management, which provides:
- ✅ Call initiation
- ✅ Call accept/reject/end
- ✅ Call state tracking
- ✅ Push notifications
- ⚠️ Limited native Twilio SDK integration (requires manual setup)

## Troubleshooting

### Issue: Calls not connecting
- Verify Twilio credentials in backend
- Check TwiML App configuration
- Ensure access tokens are valid
- Verify push notifications are working

### Issue: No incoming call notifications
- Check FCM token registration
- Verify Firebase configuration
- Check backend push notification implementation
- Test FCM manually with Firebase Console

### Issue: Audio not working
- Check microphone permissions
- Verify audio session configuration (iOS)
- Test with different devices
- Check Twilio Voice SDK logs

## Security Considerations

1. **Never expose Twilio credentials** in client code
2. **Generate access tokens server-side** with short expiration
3. **Validate user identity** before generating tokens
4. **Use HTTPS** for all API calls
5. **Implement rate limiting** on call endpoints
6. **Validate recipient IDs** to prevent unauthorized calls

## Next Steps

1. ✅ FCM token registration implemented
2. ✅ Backend API integration complete
3. ✅ Call UI ready (incoming, active, ended)
4. ✅ Native permissions configured
5. ⏳ Implement CallKit for iOS (native code required)
6. ⏳ Test with real Twilio credentials
7. ⏳ Implement push notification handling for incoming calls
8. ⏳ Add call history persistence
9. ⏳ Implement call quality monitoring

## Resources

- [Twilio Voice SDK Documentation](https://www.twilio.com/docs/voice)
- [Twilio Flutter Package](https://pub.dev/packages/twilio_voice)
- [CallKit Documentation](https://developer.apple.com/documentation/callkit)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
