import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../call/application/call_providers.dart';
import '../../../call/application/states/call_state.dart';
import '../../application/dashboard_providers.dart';

enum CallViewState { callLog, incomingCall, activeCall, callEnded }

enum CallType { missed, outgoing, incoming }

class CallPage extends ConsumerStatefulWidget {
  final Function(bool)? onCallStateChanged;

  const CallPage({super.key, this.onCallStateChanged});

  @override
  ConsumerState<CallPage> createState() => _CallPageState();
}

class _CallPageState extends ConsumerState<CallPage> {
  CallViewState _viewState = CallViewState.callLog;
  CallStateStatus? _lastCallStatus;
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _callSeconds = 0;
  Timer? _callTimer;
  Timer? _pulseTimer;
  bool _pulseOn = false;

  // Call history, grouped by date label (e.g. "Today").
  final Map<String, List<CallLog>> _groupedCallLogs = {};
  bool _isLoadingCalls = true;

  @override
  void initState() {
    super.initState();
    // Sync view state with any already-active call (e.g. navigated here after
    // initiating a call from a profile page).
    final callState = ref.read(callNotifierProvider);
    _lastCallStatus = callState.status;
    if (callState.status == CallStateStatus.calling ||
        callState.status == CallStateStatus.ringing ||
        callState.status == CallStateStatus.incomingCall) {
      _viewState = CallViewState.incomingCall;
      _startPulse();
      _updateNavBarVisibility();
    } else if (callState.status == CallStateStatus.success &&
        callState.isInCall) {
      _viewState = CallViewState.activeCall;
      _startCallTimer();
      _updateNavBarVisibility();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCallHistory());
  }

  /// Fetches the user's call history and groups it by date for display.
  Future<void> _loadCallHistory() async {
    final userId = await SessionPrefs.instance.getProfileId();
    final token = await SessionPrefs.instance.getAccessToken();
    if (userId.isEmpty || token.isEmpty) {
      if (mounted) setState(() => _isLoadingCalls = false);
      return;
    }

    try {
      final response = await ref
          .read(callServiceProvider)
          .getCalls(userId: userId, accessToken: token);

      final status = response['status'] as int?;
      final success = response['success'] as bool? ?? (status == 200);
      final data = response['data'];
      if ((!success && status != 200) || data is! List) {
        if (mounted) setState(() => _isLoadingCalls = false);
        return;
      }

      final profiles = ref.read(profileListNotifierProvider).profiles;

      // (startedAt, CallLog) so we can sort then group by date.
      final entries = <MapEntry<DateTime, CallLog>>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final callerId = item['callerId'] as String? ?? '';
        final recipientId = item['recipientId'] as String? ?? '';
        final isOutgoing = callerId == userId;
        final otherId = isOutgoing ? recipientId : callerId;
        final profile =
            profiles.where((p) => p.id == otherId).firstOrNull;
        final durationSecs =
            (item['duration'] as num?)?.toDouble() ?? 0;
        final startedAt =
            DateTime.tryParse(item['startedAt'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);

        final CallType type;
        if (isOutgoing) {
          type = CallType.outgoing;
        } else {
          type = durationSecs > 0 ? CallType.incoming : CallType.missed;
        }

        entries.add(
          MapEntry(
            startedAt,
            CallLog(
              id: item['id'] as String? ?? '',
              name: profile?.displayName ?? 'Unknown',
              avatar: profile?.profilePhotoUrl ??
                  AppAssets.professionalProfileJpg,
              time: _formatCallTime(startedAt),
              duration: _formatCallDuration(durationSecs),
              callType: type,
            ),
          ),
        );
      }

      // Most recent first, then bucket by date label.
      entries.sort((a, b) => b.key.compareTo(a.key));
      final grouped = <String, List<CallLog>>{};
      for (final e in entries) {
        grouped.putIfAbsent(_dateGroupLabel(e.key), () => []).add(e.value);
      }

      if (!mounted) return;
      setState(() {
        _groupedCallLogs
          ..clear()
          ..addAll(grouped);
        _isLoadingCalls = false;
      });
    } catch (e) {
      debugPrint('CallPage: failed to load call history: $e');
      if (mounted) setState(() => _isLoadingCalls = false);
    }
  }

  String _formatCallTime(DateTime dt) {
    final local = dt.toLocal();
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final min = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '$h12:$min $ampm';
  }

  String _formatCallDuration(double seconds) {
    final s = seconds.round();
    if (s <= 0) return '';
    final m = s ~/ 60;
    final rem = s % 60;
    return m > 0 ? '${m}m ${rem}s' : '${rem}s';
  }

  String _dateGroupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _startPulse() {
    _pulseTimer?.cancel();
    _pulseOn = false;
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      setState(() {
        _pulseOn = !_pulseOn;
      });
    });
  }

  void _stopPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _pulseOn = false;
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

  void _updateNavBarVisibility() {
    final shouldHide = _viewState != CallViewState.callLog;
    widget.onCallStateChanged?.call(shouldHide);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to call state changes
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      final statusChanged = _lastCallStatus != next.status;
      _lastCallStatus = next.status;

      // Show ringing screen while the call is dialing / waiting to connect
      if (next.status == CallStateStatus.calling ||
          next.status == CallStateStatus.ringing) {
        if (_viewState != CallViewState.incomingCall) {
          setState(() {
            _viewState = CallViewState.incomingCall;
            _startPulse();
          });
          _updateNavBarVisibility();
          if (statusChanged) {
            HapticFeedback.mediumImpact();
          }
        }
      }
      // Show incoming call screen when receiving a call
      else if (next.status == CallStateStatus.incomingCall) {
        if (_viewState != CallViewState.incomingCall) {
          setState(() {
            _viewState = CallViewState.incomingCall;
            _startPulse();
          });
          _updateNavBarVisibility();
          if (statusChanged) {
            HapticFeedback.vibrate();
          }
        }
      }
      // Show active call screen when connected
      else if (next.status == CallStateStatus.success && next.isInCall) {
        if (_viewState != CallViewState.activeCall) {
          setState(() {
            _viewState = CallViewState.activeCall;
            _stopPulse();
            _startCallTimer();
          });
          _updateNavBarVisibility();
        }
      }
      // Return to log when call ends after being connected
      else if (next.status == CallStateStatus.idle &&
          !next.isInCall &&
          previous?.isInCall == true) {
        setState(() {
          _viewState = CallViewState.callEnded;
          _stopCallTimer();
          _stopPulse();
        });
        _updateNavBarVisibility();

        // Return to log after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _viewState = CallViewState.callLog;
            });
            _updateNavBarVisibility();
          }
        });
      }
      // Return to log when call fails before connecting
      else if ((next.status == CallStateStatus.idle ||
              next.status == CallStateStatus.error) &&
          !next.isInCall &&
          _viewState == CallViewState.incomingCall) {
        setState(() {
          _viewState = CallViewState.callLog;
          _stopPulse();
        });
        _updateNavBarVisibility();
      }
    });

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
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/landing?tab=0');
                  }
                },
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
                ref.tr.callsSection,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
            ],
          ),
        ),
        // Call log groups, loader, or empty state
        Expanded(
          child: _isLoadingCalls
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 64.w,
                        color: AppColors.foundationBlack80,
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        'No call history',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foundationBlack80,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        'Your call history will appear here',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.foundationBlack80,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
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
        typeLabel = ref.tr.missedCall;
        typeIcon = Icons.phone_missed;
      case CallType.outgoing:
        typeColor = AppColors.foundationGreenNormal;
        typeLabel = ref.tr.outgoingCall;
        typeIcon = Icons.phone_forwarded;
      case CallType.incoming:
        typeColor = AppColors.foundationBlack100;
        typeLabel = ref.tr.incomingCall;
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
                  image: log.avatar.startsWith('http')
                      ? NetworkImage(log.avatar)
                      : AssetImage(log.avatar) as ImageProvider,
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
    final callState = ref.watch(callNotifierProvider);
    final callerName = callState.callerName.isNotEmpty
        ? callState.callerName
        : 'Unknown';
    final callerPhone = callState.callerId.isNotEmpty
        ? '${callState.callerId.substring(0, min(8, callState.callerId.length))}...'
        : '';
    final isRingingOutgoing =
        callState.status == CallStateStatus.calling ||
        callState.status == CallStateStatus.ringing;
    final showAccept = !isRingingOutgoing;
    final statusLabel = isRingingOutgoing ? 'Calling...' : 'Incoming call';

    return Column(
      children: [
        SizedBox(height: 56.h),
        // Avatar
        AnimatedScale(
          scale: _pulseOn ? 1.04 : 0.96,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Container(
            width: 148.w,
            height: 148.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: callState.callerAvatar.isNotEmpty
                    ? NetworkImage(callState.callerAvatar)
                    : AssetImage(AppAssets.professionalProfileJpg)
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: _pulseOn ? 28 : 16,
                  spreadRadius: _pulseOn ? 3 : 0,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          callerName,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // Phone/ID
        CustomText(
          statusLabel,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        if (callerPhone.isNotEmpty && !isRingingOutgoing) ...[
          SizedBox(height: 4.h),
          CustomText(
            callerPhone,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        AnimatedOpacity(
          opacity: _pulseOn ? 1 : 0.6,
          duration: const Duration(milliseconds: 600),
          child: Column(
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
        ),
        SizedBox(height: 24.h),
        // Action buttons: Message, Accept/Cancel, Decline
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
                  _stopPulse();
                  _updateNavBarVisibility();
                },
              ),
              if (showAccept)
                _buildCircleButton(
                  icon: Icons.call,
                  color: AppColors.foundationGreenNormal,
                  iconColor: AppColors.foundationGreenLight,
                  size: 72,
                  onTap: () async {
                    final callId = ref
                        .read(callNotifierProvider.notifier)
                        .currentCallId;
                    if (callId != null) {
                      await ref
                          .read(callNotifierProvider.notifier)
                          .acceptCall(callId);
                    }
                  },
                )
              else
                _buildCircleButton(
                  icon: Icons.call_end,
                  color: AppColors.foundationErrorNormal,
                  iconColor: AppColors.foundationBlack20,
                  size: 72,
                  onTap: () async {
                    final callId = ref
                        .read(callNotifierProvider.notifier)
                        .currentCallId;
                    if (callId != null) {
                      await ref
                          .read(callNotifierProvider.notifier)
                          .endCall(callId);
                    }
                    _stopPulse();
                    setState(() {
                      _viewState = CallViewState.callLog;
                    });
                    _updateNavBarVisibility();
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
    final callState = ref.watch(callNotifierProvider);
    final callerName = callState.callerName.isNotEmpty
        ? callState.callerName
        : 'Unknown';

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
              image: callState.callerAvatar.isNotEmpty
                  ? NetworkImage(callState.callerAvatar)
                  : AssetImage(AppAssets.professionalProfileJpg)
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          callerName,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // Timer
        CustomText(
          _formattedTime,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // Action buttons: Speaker, Mute, End Call
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speaker
              _buildCircleButton(
                icon: _isSpeaker ? Icons.volume_up : Icons.volume_up,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () async {
                  await ref.read(callNotifierProvider.notifier).toggleSpeaker();
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
                onTap: () async {
                  await ref.read(callNotifierProvider.notifier).toggleMute();
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
                onTap: () async {
                  // End call via API
                  final callId = ref
                      .read(callNotifierProvider.notifier)
                      .currentCallId;
                  if (callId != null) {
                    await ref
                        .read(callNotifierProvider.notifier)
                        .endCall(callId);
                  }
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
    final callState = ref.watch(callNotifierProvider);
    final callerName = callState.callerName.isNotEmpty
        ? callState.callerName
        : 'Unknown';

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
              image: callState.callerAvatar.isNotEmpty
                  ? NetworkImage(callState.callerAvatar)
                  : AssetImage(AppAssets.professionalProfileJpg)
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Name
        CustomText(
          callerName,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        // "Call Ended"
        CustomText(
          ref.tr.callEnded,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircleButton(
                icon: Icons.volume_up,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () async {
                  await ref.read(callNotifierProvider.notifier).toggleSpeaker();
                },
              ),
              _buildCircleButton(
                icon: Icons.mic_off,
                color: Colors.white.withValues(alpha: 0.12),
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () async {
                  await ref.read(callNotifierProvider.notifier).toggleMute();
                },
              ),
              _buildCircleButton(
                icon: Icons.call_end,
                color: AppColors.foundationErrorNormal,
                iconColor: AppColors.foundationBlack20,
                size: 72,
                onTap: () async {
                  _stopCallTimer();
                  final callId = ref
                      .read(callNotifierProvider.notifier)
                      .currentCallId;
                  if (callId != null) {
                    await ref
                        .read(callNotifierProvider.notifier)
                        .endCall(callId);
                  }
                  setState(() {
                    _viewState = CallViewState.callLog;
                  });
                  _updateNavBarVisibility();
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
