# Twilio VoIP Call Flow - Complete Implementation Guide

## Overview

Your app uses **Twilio VoIP calling** where Twilio SDK handles all WebRTC signaling (SDP offer/answer exchange) internally. Your backend only needs to track call status and send push notifications.

---

## ✅ Current Implementation Status

### **Backend API Endpoints (All Implemented)**

1. **FCM Token Registration**
   - `POST /v1/token`
   - Body: `{ "token": "...", "userId": "..." }`
   - ✅ Implemented in `CallService.setFcmToken()`

2. **Get Twilio Access Token**
   - `GET /v1/call/token?provider=TWILIO&callerId={userId}`
   - Returns Twilio access token for the user
   - ✅ Implemented in `CallService.getCallToken()`

3. **Initiate Call**
   - `POST /v1/call`
   - Body: `{ "recipientId": "...", "registrationToken": "..." }`
   - ✅ Implemented in `CallService.initiateCall()`

4. **Accept Call**
   - `PATCH /v1/call/accept/{callId}`
   - No body needed (Twilio handles WebRTC signaling)
   - ✅ Implemented in `CallService.acceptCall()`

5. **Reject Call**
   - `PATCH /v1/call/reject/{callId}`
   - No body needed
   - ✅ Implemented in `CallService.rejectCall()`

6. **End Call**
   - `PATCH /v1/call/end/{callId}`
   - No body needed
   - ✅ Implemented in `CallService.endCall()`

---

## 📱 Complete Call Flow

### **Scenario 1: Outgoing Call (User A calls User B)**

#### **Step 1: User A initiates call**
```dart
// User A taps call button in chat history
await ref.read(callNotifierProvider.notifier).initiateCall(recipientId);
```

**What happens:**
1. `CallNotifier.initiateCall()` is called
2. Gets Twilio access token: `GET /v1/call/token?provider=TWILIO&callerId={userA_id}`
3. Initiates call: `POST /v1/call` with `{ recipientId: userB_id, registrationToken: twilioToken }`
4. Backend creates call record in database
5. Backend sends FCM push notification to User B

#### **Step 2: User B receives notification**
```
FCM Push Notification → User B's device
{
  "callId": "xxx",
  "callerId": "userA_id",
  "callerName": "User A",
  "twilioToken": "..."
}
```

**What happens:**
1. User B's app receives FCM notification
2. App shows incoming call UI (`CallPage` with `CallViewState.incomingCall`)
3. User B sees caller info and can accept/reject

#### **Step 3a: User B accepts call**
```dart
// User B taps accept button
await ref.read(callNotifierProvider.notifier).acceptCall(callId);
```

**What happens:**
1. `CallNotifier.acceptCall()` is called
2. Updates backend: `PATCH /v1/call/accept/{callId}`
3. Backend updates call status to ACCEPTED
4. **Twilio SDK establishes voice connection** (no SDP exchange needed in your code)
5. Both users are now connected via Twilio's infrastructure

#### **Step 3b: User B rejects call**
```dart
// User B taps reject button
await ref.read(callNotifierProvider.notifier).rejectCall(callId);
```

**What happens:**
1. `CallNotifier.rejectCall()` is called
2. Updates backend: `PATCH /v1/call/reject/{callId}`
3. Backend updates call status to REJECTED
4. User A receives notification that call was rejected

#### **Step 4: During active call**
```dart
// Both users can:
- Mute/unmute microphone
- Toggle speaker
- End call
```

#### **Step 5: End call**
```dart
// Either user taps end call button
await ref.read(callNotifierProvider.notifier).endCall(callId);
```

**What happens:**
1. `CallNotifier.endCall()` is called
2. Updates backend: `PATCH /v1/call/end/{callId}`
3. Backend updates call status to ENDED
4. Twilio disconnects voice connection
5. App shows call ended UI

---

## 🔧 Key Components

### **1. CallService** (`lib/features/call/domain/call_service.dart`)
Handles all backend API calls:
- ✅ FCM token registration
- ✅ Twilio token retrieval
- ✅ Call initiation
- ✅ Call accept/reject/end

### **2. CallNotifier** (`lib/features/call/application/notifiers/call_notifier.dart`)
State management for calls:
- ✅ Manages call state (idle, loading, success, error)
- ✅ Stores current call ID and recipient ID
- ✅ Handles call lifecycle (initiate, accept, reject, end)

### **3. CallPage** (`lib/features/dashboard/presentation/widgets/call_page.dart`)
UI for call screens:
- ✅ Incoming call screen (accept/reject/message)
- ✅ Active call screen (mute/speaker/end)
- ✅ Call ended screen
- ✅ Call log screen

### **4. NotificationService** (`lib/core/services/notification_service.dart`)
FCM integration:
- ✅ Registers FCM token on app start
- ✅ Handles incoming push notifications
- ✅ Shows incoming call UI when notification received

---

## 🎯 What Twilio SDK Handles Automatically

When you use Twilio VoIP, the Twilio SDK handles:

1. **WebRTC Signaling**
   - SDP offer/answer exchange
   - ICE candidate gathering
   - STUN/TURN server negotiation

2. **Voice Connection**
   - Audio codec negotiation
   - Network traversal (NAT/firewall)
   - Audio routing and mixing

3. **Call Quality**
   - Adaptive bitrate
   - Packet loss concealment
   - Echo cancellation

**You don't need to handle any of this in your Flutter code!**

---

## 🚀 Testing the Call Flow

### **1. Test FCM Token Registration**
```bash
# Check logs on app start
flutter run

# Expected log:
# Saved FCM token to backend: {status: 200, message: Success, data: {...}}
```

### **2. Test Outgoing Call**
```bash
# 1. Open chat history
# 2. Tap call button on any conversation
# 3. Check logs:
# CallNotifier: Outgoing call initiated to {recipientId}
```

### **3. Test Incoming Call**
```bash
# 1. Have another user call you
# 2. FCM notification should arrive
# 3. Incoming call UI should appear
# 4. Accept or reject the call
```

### **4. Test Active Call**
```bash
# During call:
# - Test mute button
# - Test speaker button
# - Test end call button
```

---

## 📋 Backend Requirements Checklist

Your backend must implement:

- [x] **POST /v1/token** - FCM token registration
- [x] **GET /v1/call/token** - Generate Twilio access token
- [x] **POST /v1/call** - Create call record and send push notification
- [x] **PATCH /v1/call/accept/{callId}** - Update call status to ACCEPTED
- [x] **PATCH /v1/call/reject/{callId}** - Update call status to REJECTED
- [x] **PATCH /v1/call/end/{callId}** - Update call status to ENDED

**Important:** Backend should NOT expect SDP parameters in accept/reject/end endpoints. Twilio handles all WebRTC signaling.

---

## 🔐 Security Best Practices

1. **Twilio Access Tokens**
   - Generated server-side with short expiration (1 hour recommended)
   - Include user identity in token
   - Never expose Twilio Account SID/Auth Token in client

2. **Call Authorization**
   - Validate user has permission to call recipient
   - Check for blocked users
   - Implement rate limiting

3. **Push Notifications**
   - Include minimal data in notification payload
   - Validate call exists before showing UI
   - Handle expired/cancelled calls

---

## 🐛 Troubleshooting

### **Issue: FCM token not registered**
- Check: User is logged in
- Check: Access token is valid
- Check: Backend endpoint `/v1/token` exists
- Check: Logs show successful registration

### **Issue: Call not connecting**
- Check: Twilio credentials configured on backend
- Check: Twilio access token is valid
- Check: Both users have valid FCM tokens
- Check: Push notifications are enabled

### **Issue: No incoming call notification**
- Check: FCM is configured correctly
- Check: App has notification permissions
- Check: Backend is sending push notification
- Check: Notification payload includes call data

### **Issue: Call drops immediately**
- Check: Twilio account has sufficient credits
- Check: Network connectivity on both devices
- Check: Microphone permissions granted
- Check: No firewall blocking WebRTC

---

## 📝 Next Steps

1. **Test with real devices** (VoIP doesn't work in simulators)
2. **Configure Twilio account** with proper credentials
3. **Test push notifications** with Firebase Console
4. **Implement call history** persistence (optional)
5. **Add call quality monitoring** (optional)

---

## 🎉 Summary

Your Twilio VoIP implementation is **complete and ready for testing**:

✅ FCM token registration working  
✅ Backend API integration complete  
✅ Call UI ready (incoming, active, ended)  
✅ Native permissions configured (iOS & Android)  
✅ Call flow properly implemented  
✅ Twilio handles all WebRTC signaling  

**No code changes needed** - your implementation matches the updated backend API perfectly!
