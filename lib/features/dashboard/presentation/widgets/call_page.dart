import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';

enum CallViewState { callLog, incomingCall, activeCall, callEnded }

enum CallType { missed, outgoing, incoming }

class CallPage extends StatefulWidget {
  final Function(bool)? onCallStateChanged;

  const CallPage({super.key, this.onCallStateChanged});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  CallViewState _viewState = CallViewState.callLog;
  bool _isRecording = false;
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _callSeconds = 0;
  Timer? _callTimer;

  // Dummy caller for call screens
  final _caller = _CallerInfo(
    name: 'Sam Singer',
    phone: '91+ 942386436',
    avatar: AppAssets.professionalProfileJpg,
  );

  final Map<String, List<CallLog>> _groupedCallLogs = {
    AppStrings.today: [
      CallLog(
        id: '1',
        name: 'Lisa Dancer',
        avatar: AppAssets.professionalProfileJpg,
        time: '09:00 AM',
        duration: '',
        callType: CallType.missed,
      ),
      CallLog(
        id: '2',
        name: 'Samsing',
        avatar: AppAssets.skilledProfileJpg,
        time: '09:00 AM',
        duration: '1min 25secs',
        callType: CallType.outgoing,
      ),
      CallLog(
        id: '3',
        name: 'Samsing',
        avatar: AppAssets.profileImg1,
        time: '09:00 AM',
        duration: '1hr 20mins',
        callType: CallType.incoming,
      ),
    ],
    AppStrings.yesterday: [
      CallLog(
        id: '4',
        name: 'Lisa Dancer',
        avatar: AppAssets.professionalProfileJpg,
        time: '09:00 AM',
        duration: '',
        callType: CallType.missed,
      ),
      CallLog(
        id: '5',
        name: 'Samsing',
        avatar: AppAssets.skilledProfileJpg,
        time: '09:00 AM',
        duration: '12s',
        callType: CallType.outgoing,
      ),
      CallLog(
        id: '6',
        name: 'Samsing',
        avatar: AppAssets.profileImg1,
        time: '09:00 AM',
        duration: '12s',
        callType: CallType.incoming,
      ),
    ],
  };

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCallTimer() {
    _callSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callSeconds++;
      });
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  String get _formattedTime {
    final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTransitions.duration,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(_viewState),
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewState) {
      case CallViewState.callLog:
        return _buildCallLogScreen();
      case CallViewState.incomingCall:
        return _buildIncomingCallScreen();
      case CallViewState.activeCall:
        return _buildActiveCallScreen();
      case CallViewState.callEnded:
        return _buildCallEndedScreen();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Call Log Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCallLogScreen() {
    final groups = _groupedCallLogs.entries.toList();
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              CustomText(
                AppStrings.callsSection,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
            ],
          ),
        ),
        // Call log groups
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return _buildCallGroup(group.key, group.value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallGroup(String title, List<CallLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != _groupedCallLogs.keys.first) SizedBox(height: 24.h),
        CustomText(
          title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          fontStyle: FontStyle.italic,
        ),
        SizedBox(height: 24.h),
        // Grouped card
        ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            children: logs.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              final isFirst = index == 0;
              final isLast = index == logs.length - 1;
              return _buildCallLogTile(log, isFirst: isFirst, isLast: isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCallLogTile(
    CallLog log, {
    required bool isFirst,
    required bool isLast,
  }) {
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (log.callType) {
      case CallType.missed:
        typeColor = AppColors.foundationErrorActive;
        typeLabel = AppStrings.missedCall;
        typeIcon = Icons.phone_missed;
      case CallType.outgoing:
        typeColor = AppColors.foundationGreenNormal;
        typeLabel = AppStrings.outgoingCall;
        typeIcon = Icons.phone_forwarded;
      case CallType.incoming:
        typeColor = AppColors.foundationBlack100;
        typeLabel = AppStrings.incomingCall;
        typeIcon = Icons.phone_callback;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewState = CallViewState.incomingCall;
        });
        widget.onCallStateChanged?.call(true);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(24.r) : Radius.zero,
            bottom: isLast ? Radius.circular(24.r) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(log.avatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 24.w),
            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    log.name,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(typeIcon, color: typeColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      CustomText(
                        typeLabel,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: typeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time + duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  log.time,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack20,
                ),
                if (log.duration.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  CustomText(
                    log.duration,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.foundationBlack20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Incoming Call Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildIncomingCallScreen() {
    return Column(
      children: [
        SizedBox(height: 56.h),
        // Avatar
        Container(
          width: 148.w,
          height: 148.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(_caller.avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          _caller.name,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // Phone
        CustomText(
          _caller.phone,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // Chevron arrows (swipe up indicator)
        Column(
          children: [
            Icon(
              Icons.keyboard_arrow_up,
              color: AppColors.foundationBlack20,
              size: 24.sp,
            ),
            Icon(
              Icons.keyboard_arrow_up,
              color: AppColors.foundationBlack80,
              size: 24.sp,
            ),
            Icon(
              Icons.keyboard_arrow_up,
              color: AppColors.foundationBlack400,
              size: 24.sp,
            ),
          ],
        ),
        SizedBox(height: 24.h),
        // Action buttons: Message, Accept, Decline
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Message
              _buildCircleButton(
                icon: Icons.chat_bubble_outline,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  setState(() {
                    _viewState = CallViewState.callLog;
                  });
                  widget.onCallStateChanged?.call(false);
                },
              ),
              // Accept
              _buildCircleButton(
                icon: Icons.call,
                color: AppColors.foundationGreenNormal,
                iconColor: AppColors.foundationGreenLight,
                size: 72,
                onTap: () {
                  setState(() {
                    _viewState = CallViewState.activeCall;
                    _isRecording = false;
                    _isMuted = false;
                    _isSpeaker = false;
                  });
                  _startCallTimer();
                },
              ),
              // Decline
              _buildCircleButton(
                icon: Icons.call_end,
                color: AppColors.foundationErrorNormal,
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  setState(() {
                    _viewState = CallViewState.callLog;
                  });
                  widget.onCallStateChanged?.call(false);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Active Call Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildActiveCallScreen() {
    return Column(
      children: [
        SizedBox(height: 56.h),
        // Avatar
        Container(
          width: 148.w,
          height: 148.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(_caller.avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          _caller.name,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // Timer (with optional recording indicator)
        _isRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.foundationErrorDarkHover,
                      border: Border.all(
                        color: AppColors.foundationBlack20,
                        width: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    _formattedTime,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.foundationBlack20,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : CustomText(
                _formattedTime,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
                textAlign: TextAlign.center,
              ),
        const Spacer(),
        // Action buttons: Record, Speaker, Mute, End Call
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Record
              _buildCircleButton(
                icon: Icons.fiber_manual_record,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: _isRecording
                    ? AppColors.foundationErrorDark
                    : AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  setState(() {
                    _isRecording = !_isRecording;
                  });
                },
              ),
              // Speaker
              _buildCircleButton(
                icon: _isSpeaker ? Icons.volume_up : Icons.volume_up,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  setState(() {
                    _isSpeaker = !_isSpeaker;
                  });
                },
              ),
              // Mute
              _buildCircleButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic_off,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
              ),
              // End Call
              _buildCircleButton(
                icon: Icons.call_end,
                color: AppColors.foundationErrorNormal,
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  _stopCallTimer();
                  setState(() {
                    _viewState = CallViewState.callEnded;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Call Ended Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCallEndedScreen() {
    return Column(
      children: [
        SizedBox(height: 56.h),
        // Avatar
        Container(
          width: 148.w,
          height: 148.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(_caller.avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          _caller.name,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // "Call Ended"
        CustomText(
          AppStrings.callEnded,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // Action buttons (disabled state)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(
                icon: Icons.fiber_manual_record,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {},
              ),
              _buildCircleButton(
                icon: Icons.volume_up,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {},
              ),
              _buildCircleButton(
                icon: Icons.mic_off,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {},
              ),
              _buildCircleButton(
                icon: Icons.call_end,
                color: AppColors.foundationErrorNormal,
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () {
                  _stopCallTimer();
                  setState(() {
                    _isRecording = false;
                    _viewState = CallViewState.callLog;
                  });
                  widget.onCallStateChanged?.call(false);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Shared Widgets ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(
          child: Icon(icon, color: iconColor, size: 24.sp),
        ),
      ),
    );
  }
}

// ─── Data Models ───

class CallLog {
  final String id;
  final String name;
  final String avatar;
  final String time;
  final String duration;
  final CallType callType;

  CallLog({
    required this.id,
    required this.name,
    required this.avatar,
    required this.time,
    required this.duration,
    required this.callType,
  });
}

class _CallerInfo {
  final String name;
  final String phone;
  final String avatar;

  _CallerInfo({required this.name, required this.phone, required this.avatar});
}
