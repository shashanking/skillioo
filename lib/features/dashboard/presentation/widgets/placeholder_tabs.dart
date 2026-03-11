import 'package:flutter/material.dart';

import 'reels_page.dart';
import 'chat_page.dart';
import 'profiles_reels_page.dart';
import 'call_page.dart';

class ReelsTab extends StatelessWidget {
  final bool isActive;

  const ReelsTab({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return ReelsPage(isActive: isActive);
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
  final String initialRecipientId;

  const ChatTab({
    super.key,
    this.onChatStateChanged,
    this.initialRecipientId = '',
  });

  @override
  Widget build(BuildContext context) {
    return ChatPage(
      key: ValueKey('chat-page-$initialRecipientId'),
      onChatStateChanged: onChatStateChanged,
      initialRecipientId: initialRecipientId,
    );
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
