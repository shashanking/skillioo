import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../constants/app_constants.dart';

/// Mic button that streams speech-to-text into [controller]. Same wiring
/// as the dashboard search bar — extracted so the location and messages
/// search fields can drop the same behaviour in.
///
/// - Tap to start listening; partial transcripts stream into the
///   controller as the user speaks so they see the words appear live.
/// - On the final result, [onFinalResult] fires once with the trimmed
///   transcript (handy for triggering a search without waiting on a
///   text-change debounce).
class VoiceSearchMicButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onFinalResult;

  /// Unfocused when the mic starts so the soft-keyboard doesn't cover
  /// suggestions while the user is talking.
  final FocusNode? textFocusNode;

  /// Mic icon size in design pixels (gets `.w` scaled internally).
  final double size;

  /// Optional tint applied to the mic asset when idle. `null` keeps the
  /// asset's original colours.
  final Color? iconColor;

  /// Tint used while actively listening (defaults to the brand cyan).
  final Color listeningColor;

  const VoiceSearchMicButton({
    super.key,
    required this.controller,
    this.onFinalResult,
    this.textFocusNode,
    this.size = 20,
    this.iconColor,
    this.listeningColor = const Color(0xFF05DAF1),
  });

  @override
  State<VoiceSearchMicButton> createState() => _VoiceSearchMicButtonState();
}

class _VoiceSearchMicButtonState extends State<VoiceSearchMicButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  Timer? _autoStopTimer;

  @override
  void initState() {
    super.initState();
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

  void _stopListening() {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;
    if (_isListening) {
      _stopListening();
      return;
    }

    widget.textFocusNode?.unfocus();
    setState(() => _isListening = true);

    // Safety net: auto-stop after 12 seconds even if callbacks don't fire.
    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(const Duration(seconds: 12), () {
      if (_isListening) _stopListening();
    });

    await _speech.listen(
      onResult: (result) {
        widget.controller.text = result.recognizedWords;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
        if (result.finalResult) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) widget.onFinalResult?.call(text);
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
    _autoStopTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: _isListening
            ? Icon(Icons.mic, color: widget.listeningColor, size: widget.size.w)
            : Image.asset(
                AppAssets.micPng,
                width: widget.size.w,
                height: widget.size.w,
                color: widget.iconColor,
              ),
      ),
    );
  }
}
