import 'package:flutter/material.dart';

import 'reels_page.dart';
import 'chat_page.dart';
import 'profiles_reels_page.dart';
import 'call_page.dart';

class ReelsTab extends StatelessWidget {
  const ReelsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const ReelsPage();
  }
}

class ProfileMainTab extends StatelessWidget {
  const ProfileMainTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfilesReelsPage();
  }
}

class ChatTab extends StatelessWidget {
  final Function(bool)? onChatStateChanged;

  const ChatTab({super.key, this.onChatStateChanged});

  @override
  Widget build(BuildContext context) {
    return ChatPage(onChatStateChanged: onChatStateChanged);
  }
}

class CallTab extends StatelessWidget {
  final Function(bool)? onCallStateChanged;

  const CallTab({super.key, this.onCallStateChanged});

  @override
  Widget build(BuildContext context) {
    return CallPage(onCallStateChanged: onCallStateChanged);
  }
}
