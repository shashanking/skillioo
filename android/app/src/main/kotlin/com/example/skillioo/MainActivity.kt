package com.example.skillioo

import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.twilio.voice.CallInvite
import com.twilio.voice.flutter.TwilioVoiceFlutterPlugin

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.skillioo/call_manager"
    private val TAG = "CallManager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "answerCall" -> {
                        // Prefer our own store (populated synchronously by
                        // MyFirebaseMessagingService.onCallInvite). Fall back
                        // to the package's static field for safety in case
                        // the invite ever lands via the package path (e.g.
                        // notification tap from background).
                        val invite: CallInvite? =
                            ActiveCallInviteStore.current()
                                ?: TwilioVoiceFlutterPlugin.activeCallInvite
                        if (invite != null) {
                            Log.d(TAG, "answerCall accepting callSid=${invite.callSid}")
                            invite.accept(this, TwilioVoiceFlutterPlugin.callListener)
                            ActiveCallInviteStore.remove(invite.callSid)
                            TwilioVoiceFlutterPlugin.activeCallInvite = null
                            result.success(true)
                        } else {
                            Log.w(TAG, "answerCall: no CallInvite available")
                            result.error("NO_INVITE", "No active CallInvite to accept", null)
                        }
                    }
                    "rejectCall" -> {
                        val invite: CallInvite? =
                            ActiveCallInviteStore.current()
                                ?: TwilioVoiceFlutterPlugin.activeCallInvite
                        if (invite != null) {
                            Log.d(TAG, "rejectCall rejecting callSid=${invite.callSid}")
                            invite.reject(this)
                            ActiveCallInviteStore.remove(invite.callSid)
                            TwilioVoiceFlutterPlugin.activeCallInvite = null
                            result.success(true)
                        } else {
                            Log.w(TAG, "rejectCall: no CallInvite available")
                            result.error("NO_INVITE", "No active CallInvite to reject", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
