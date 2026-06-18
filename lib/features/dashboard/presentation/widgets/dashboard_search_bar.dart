import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../constants/app_constants.dart';

class DashboardSearchBar extends StatefulWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onSearchChanged;

  /// Fires once per voice session with the FINAL recognized transcript.
  /// Use this to do voice-only side-effects (e.g. auto-select a chip).
  /// `onSearchChanged` is also fired with the same text — instantly,
  /// without waiting on the debounce.
  final ValueChanged<String>? onVoiceResult;

  const DashboardSearchBar({
    super.key,
    this.onTap,
    this.onSearchChanged,
    this.onVoiceResult,
  });

  @override
  State<DashboardSearchBar> createState() => DashboardSearchBarState();
}

class DashboardSearchBarState extends State<DashboardSearchBar> {
  bool _interactive = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  int _currentWordIndex = 0;
  // Talent/role nouns cycled in the "Are you looking for …" hint.
  // Person nouns (not the backend's field-style category names like
  // "Music"/"Cooking", which read wrong after "looking for a …").
  final List<String> _animatedWords = [
    'Singer',
    'Dancer',
    'Musician',
    'Actor',
    'Photographer',
    'Painter',
    'Chef',
    'Comedian',
    'Writer',
    'Model',
    'Magician',
    'Gamer',
    'Speaker',
    'Cricketer',
    'Trainer',
    'Choreographer',
    'DJ',
    'Anchor',
    'Guitarist',
    'Drummer',
    'Makeup Artist',
    'Designer',
    'Coach',
    'Mentor',
    'Host',
    'Videographer',
    'Artist',
    'Influencer',
  ];
  Timer? _timer;
  Timer? _debounce;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  Timer? _micAutoStopTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && !_interactive) {
        setState(() {
          _currentWordIndex = (_currentWordIndex + 1) % _animatedWords.length;
        });
      }
    });
  }

  void _onTextChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged?.call(_controller.text.trim());
    });
  }

  void _onFocusChanged() {
    // Auto-stop mic when user taps into the text field
    if (_focusNode.hasFocus && _isListening) {
      _stopListening();
    }
    setState(() {});
  }

  void _stopListening() {
    _micAutoStopTimer?.cancel();
    _micAutoStopTimer = null;
    _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      _stopListening();
      return;
    }

    // Activate interactive mode and unfocus keyboard
    if (!_interactive) {
      setState(() => _interactive = true);
    }
    _focusNode.unfocus();

    setState(() => _isListening = true);

    // Safety net: auto-stop after 12 seconds even if callbacks don't fire
    _micAutoStopTimer?.cancel();
    _micAutoStopTimer = Timer(const Duration(seconds: 12), () {
      if (_isListening) _stopListening();
    });

    await _speech.listen(
      onResult: (result) {
        // Stream partial transcripts into the field so the user sees text
        // appear live as they speak.
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );

        // On the FINAL transcript, bypass the 300ms text debounce so search
        // results appear instantly, and tell the parent so it can do
        // voice-only follow-ups (chip auto-select).
        if (result.finalResult) {
          final text = result.recognizedWords.trim();
          _debounce?.cancel();
          if (text.isNotEmpty) {
            widget.onSearchChanged?.call(text);
            widget.onVoiceResult?.call(text);
          }
          _stopListening();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.search,
        partialResults: true,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    _micAutoStopTimer?.cancel();
    _speech.stop();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  /// Switch to interactive mode without opening the keyboard.
  void setInteractive() {
    if (!_interactive) {
      setState(() => _interactive = true);
    }
  }

  void requestFocus() {
    setInteractive();
    _focusNode.requestFocus();
  }

  void reset() {
    if (_interactive || _controller.text.isNotEmpty) {
      _controller.clear();
      widget.onSearchChanged?.call('');
      setState(() {
        _interactive = false;
      });
    }
    if (_isListening) {
      _stopListening();
    }
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: !_interactive ? widget.onTap : null,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 24.w),
              Image.asset(AppAssets.searchPng, width: 20.w, height: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // The actual TextField
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      readOnly: !_interactive,
                      onTap: () {
                        if (!_interactive) {
                          FocusScope.of(context).unfocus();
                          widget.onTap?.call();
                        }
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                    // Animated hint text when not focused and no text
                    if (!_focusNode.hasFocus && !_interactive && !hasText)
                      IgnorePointer(
                        child: Row(
                          children: [
                            Text(
                              'Are you looking for ',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              // Left-align the swapped words. The default
                              // centered layout re-centres each word in a
                              // Stack sized to the widest child, so a
                              // width change between words (e.g. "Coach" →
                              // "Creator") shifts the text sideways
                              // mid-transition — that was the visible jerk.
                              layoutBuilder:
                                  (currentChild, previousChildren) {
                                    return Stack(
                                      alignment: Alignment.centerLeft,
                                      children: <Widget>[
                                        ...previousChildren,
                                        if (currentChild != null)
                                          currentChild,
                                      ],
                                    );
                                  },
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.2),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                              child: Text(
                                _animatedWords[_currentWordIndex],
                                key: ValueKey<int>(_currentWordIndex),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              if (hasText)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onSearchChanged?.call('');
                    _focusNode.unfocus();
                    setState(() {
                      _interactive = false;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20.w,
                  ),
                )
              else
                GestureDetector(
                  onTap: _toggleListening,
                  child: _isListening
                      ? Icon(
                          Icons.mic,
                          color: const Color(0xFF05DAF1),
                          size: 20.w,
                        )
                      : Image.asset(
                          AppAssets.micPng,
                          width: 20.w,
                          height: 20.w,
                        ),
                ),
              SizedBox(width: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}
