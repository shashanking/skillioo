package com.example.skillioo

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.twilio.voice.CallException
import com.twilio.voice.CallInvite
import com.twilio.voice.CancelledCallInvite
import com.twilio.voice.MessageListener
import com.twilio.voice.Voice

/**
 * Single FirebaseMessagingService that owns FCM delivery for this app.
 *
 * Android allows only ONE FirebaseMessagingService to win the
 * com.google.firebase.MESSAGING_EVENT intent. This service:
 *   1. Calls Voice.handleMessage(...) for Twilio voice pushes (returns true
 *      and fires MessageListener.onCallInvite, which we then store in
 *      ActiveCallInviteStore for MainActivity.answerCall to retrieve).
 *   2. Returns false for non-Twilio messages — the firebase_messaging
 *      plugin's separate BroadcastReceiver listening on
 *      com.google.android.c2dm.intent.RECEIVE will still surface those to
 *      Dart's FirebaseMessaging.onMessage handler.
 *
 * Pattern mirrors the official Twilio voice-quickstart-android
 * IncomingCallService.java.
 */
class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MyFCMService"
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val data = remoteMessage.data
        Log.d(TAG, "FCM received from=${remoteMessage.from} keys=${data.keys}")

        if (data.isEmpty()) {
            Log.d(TAG, "Empty data payload — nothing to do")
            return
        }

        val isTwilio = try {
            Voice.handleMessage(
                applicationContext,
                data,
                object : MessageListener {
                    override fun onCallInvite(callInvite: CallInvite) {
                        Log.d(
                            TAG,
                            "onCallInvite callSid=${callInvite.callSid} from=${callInvite.from}",
                        )
                        ActiveCallInviteStore.put(callInvite)
                    }

                    override fun onCancelledCallInvite(
                        cancelledCallInvite: CancelledCallInvite,
                        callException: CallException?,
                    ) {
                        Log.d(
                            TAG,
                            "onCancelledCallInvite callSid=${cancelledCallInvite.callSid} " +
                                "err=${callException?.message}",
                        )
                        ActiveCallInviteStore.remove(cancelledCallInvite.callSid)
                    }
                },
            )
        } catch (e: Exception) {
            Log.e(TAG, "Voice.handleMessage threw", e)
            false
        }

        if (!isTwilio) {
            Log.d(
                TAG,
                "Not a Twilio Voice payload — Dart will pick it up via the plugin receiver",
            )
        }
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "FCM token rotated (Dart handles re-register via firebase_messaging)")
    }
}
