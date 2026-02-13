import 'package:flutter/material.dart';

import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';

class ReelsTab extends StatelessWidget {
  const ReelsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const CommonBackground(
      child: Center(child: CustomText("Reels Tab", color: Colors.white)),
    );
  }
}

class ProfileMainTab extends StatelessWidget {
  const ProfileMainTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const CommonBackground(
      child: Center(child: CustomText("Profile Tab", color: Colors.white)),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const CommonBackground(
      child: Center(child: CustomText("Chat Tab", color: Colors.white)),
    );
  }
}

class CallTab extends StatelessWidget {
  const CallTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const CommonBackground(
      child: Center(child: CustomText("Call Tab", color: Colors.white)),
    );
  }
}
