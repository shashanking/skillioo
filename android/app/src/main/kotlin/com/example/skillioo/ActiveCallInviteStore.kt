package com.example.skillioo

import com.twilio.voice.CallInvite

/**
 * Single source of truth for incoming Twilio CallInvites on the native side.
 *
 * MyFirebaseMessagingService.onCallInvite stores the invite here when an
 * FCM push arrives. MainActivity's MethodChannel handler reads from here
 * when the Flutter side calls answerCall / rejectCall.
 *
 * We do not rely on TwilioVoiceFlutterPlugin.activeCallInvite because that
 * field is only set as a side effect of the package's
 * IncomingCallNotificationService running, which is an extra link in the
 * chain that has been failing intermittently in this app's setup.
 */
object ActiveCallInviteStore {
    private val invites = mutableMapOf<String, CallInvite>()

    @Synchronized
    fun put(invite: CallInvite) {
        invites[invite.callSid] = invite
    }

    @Synchronized
    fun current(): CallInvite? = invites.values.lastOrNull()

    @Synchronized
    fun bySid(sid: String): CallInvite? = invites[sid]

    @Synchronized
    fun remove(sid: String) {
        invites.remove(sid)
    }

    @Synchronized
    fun clear() {
        invites.clear()
    }
}
