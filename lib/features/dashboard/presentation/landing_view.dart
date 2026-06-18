import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/core/widgets/bottom_nav_bar.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/placeholder_tabs.dart';

import '../../call/application/call_providers.dart';
import '../../call/application/states/call_state.dart';
import '../../follow/application/follow_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/session_state_provider.dart';
import '../../online/application/online_providers.dart';
import 'dashboard_screen.dart';

class Landing extends ConsumerStatefulWidget {
  const Landing({super.key, this.initialTab = 0, this.initialRecipientId = ''});

  final int initialTab;
  final String initialRecipientId;

  @override
  ConsumerState<Landing> createState() => _LandingState();
}

class _LandingState extends ConsumerState<Landing> {
  late int _currentIndex;
  bool _showNavBar = false; // Hidden by default on Home tab
  bool _forceHideNavBar = false; // Force-hide during calls / chat compose
  dynamic _socketService;
  dynamic _onlineNotifier;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;

    // If we're navigating here while a call is already active, hide nav bar immediately
    final callState = ref.read(callNotifierProvider);
    final inCall = callState.status == CallStateStatus.calling ||
        callState.status == CallStateStatus.ringing ||
        callState.status == CallStateStatus.incomingCall ||
        (callState.status == CallStateStatus.success && callState.isInCall);
    if (inCall) {
      _forceHideNavBar = true;
      _currentIndex = 4;
    }

    debugPrint(
      'Landing: initState called - registering incoming call callback',
    );

    // Register incoming call callback for FCM notifications
    onIncomingCallCallback = (callId, callerId) {
      debugPrint('Landing: Incoming call callback received');
      debugPrint('  callId: $callId, callerId: $callerId');
      ref
          .read(callNotifierProvider.notifier)
          .handleIncomingCall(callId, callerId);
    };
    debugPrint('Landing: onIncomingCallCallback registered');

    // Re-register with Twilio whenever FCM rotates the token. Without this,
    // Twilio keeps pushing call invites to the old token and FCM rejects
    // them (error 52103) — recipient never sees the incoming call.
    onFcmTokenRefreshCallback = (_) {
      debugPrint('Landing: FCM token refreshed — re-registering with Twilio');
      ref.read(callNotifierProvider.notifier).registerWithTwilio();
    };

    // Twilio Voice push arrived: open the in-app incoming-call screen.
    // The socket event has already stashed caller metadata into state.
    onIncomingTwilioCallCallback = (twilioCallSid, from) {
      debugPrint(
        'Landing: Twilio Voice push — opening incoming-call screen '
        '(twilioCallSid=$twilioCallSid from=$from)',
      );
      ref
          .read(callNotifierProvider.notifier)
          .handleIncomingTwilioPush(twilioCallSid, from);
    };

    // Initialize socket connection and preload shared data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Landing: Post frame callback - initializing services');
      _socketService = ref.read(socketServiceProvider);
      _socketService.connect();

      // Update online notifier connection status
      _onlineNotifier = ref.read(onlineNotifierProvider.notifier);
      _onlineNotifier.setConnected(true);

      // Register with Twilio for VoIP calls
      ref.read(callNotifierProvider.notifier).registerWithTwilio();

      // Reconcile profileType from the backend — the login response
      // omits it, so this is how the app recognises a user who already
      // has a (hirer or creator) profile and shows the right top-bar UI.
      ref.read(sessionStateProvider.notifier).syncProfile();

      // Preload follow data (used pervasively, low risk).
      // Profile list + post feed are fetched by their consuming tabs on mount;
      // preloading them here used to race with the tabs' own gating and could
      // leave the UI empty on first load if Landing's call failed.
      ref.read(followNotifierProvider.notifier).fetchFollowing(perPage: 100);
      ref.read(followNotifierProvider.notifier).fetchFollowCount();
    });
  }

  @override
  void dispose() {
    // Clear the global FCM callbacks so a stale closure capturing this
    // disposed State's ref can't fire and crash a later notification.
    onIncomingCallCallback = null;
    onFcmTokenRefreshCallback = null;
    onIncomingTwilioCallCallback = null;
    // Disconnect socket when leaving app
    // Note: refs are cached in initState's post-frame callback;
    // we must NOT call ref.read() here as the widget is already disposed.
    _socketService?.disconnect();
    _onlineNotifier?.setConnected(false);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Landing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab ||
        widget.initialRecipientId != oldWidget.initialRecipientId) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  void _onNavBarStateChanged(bool hideNavBar) {
    setState(() {
      _forceHideNavBar = hideNavBar;
    });
  }

  void _onDashboardScrollChanged(bool shouldShow) {
    if (_showNavBar != shouldShow) {
      setState(() {
        _showNavBar = shouldShow;
      });
    }
  }

  void _showExitDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit App',
          style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Colors.white70, fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'Outfit')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.redAccent, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Returns whether the nav bar should be visible for the current tab.
  /// Only the Home tab (0) uses scroll-based visibility; all others always show.
  bool get _effectiveShowNavBar {
    if (_currentIndex == 0) return _showNavBar;
    if (_forceHideNavBar) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Auto-switch to call tab when calling or receiving a call
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      if (!mounted) return;
      final inCall = next.status == CallStateStatus.calling ||
          next.status == CallStateStatus.ringing ||
          next.status == CallStateStatus.incomingCall ||
          (next.status == CallStateStatus.success && next.isInCall);
      if (inCall) {
        setState(() {
          if (_currentIndex != 4) _currentIndex = 4;
          _forceHideNavBar = true;
        });
      }
      // Restore nav bar when call fails or resets to idle before connecting
      if (!inCall && _forceHideNavBar && previous != null) {
        final wasInCall = previous.status == CallStateStatus.calling ||
            previous.status == CallStateStatus.ringing;
        if (wasInCall) {
          setState(() {
            _forceHideNavBar = false;
          });
        }
      }
    });

    final showNav = _effectiveShowNavBar;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        _showExitDialog();
      },
      child: Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: !showNav,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Content Layer
          IndexedStack(
            index: _currentIndex,
            children: [
              RepaintBoundary(
                child: DashboardScreen(
                  key: _dashboardKey,
                  onScrollChanged: _onDashboardScrollChanged,
                ),
              ),
              RepaintBoundary(
                child: ReelsTab(isActive: _currentIndex == 1),
              ),
              const RepaintBoundary(child: ProfileMainTab()),
              RepaintBoundary(
                child: ChatTab(
                  key: ValueKey('chat-tab-${widget.initialRecipientId}'),
                  onChatStateChanged: (hide) {
                    if (_currentIndex == 3) _onNavBarStateChanged(hide);
                  },
                  initialRecipientId: widget.initialRecipientId,
                ),
              ),
              RepaintBoundary(
                child: CallTab(onCallStateChanged: (hide) {
                  if (_currentIndex == 4) _onNavBarStateChanged(hide);
                }),
              ),
            ],
          ),

          // 3. The Floating Glassy Nav Bar Layer — animated slide
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            bottom: showNav ? 20.h : -80.h,
            left: 20.w,
            right: 20.w,
            child: IgnorePointer(
              ignoring: !showNav,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: showNav ? 1.0 : 0.0,
                child: BottomNavBar(
                  selectedIndex: _currentIndex,
                  onItemSelected: (index) {
                    if (index == _currentIndex) {
                      // Tapped the already-selected tab. On Home, scroll
                      // back to the top and drop any active focus.
                      if (index == 0) {
                        _dashboardKey.currentState?.scrollToTopAndUnfocus();
                      }
                      return;
                    }
                    // Reset dashboard scroll/state on tab change so the
                    // user comes back to a clean home screen instead of
                    // a stale scroll position with old search/filters.
                    _dashboardKey.currentState?.resetForTabChange();
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
