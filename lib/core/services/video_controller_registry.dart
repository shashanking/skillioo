import 'package:video_player/video_player.dart';

/// Global registry of active VideoPlayerController instances.
///
/// Twilio's native VoIP SDK uses select() which can't handle file descriptors
/// above 1024. ExoPlayer instances consume many FDs each (codec, network,
/// buffers). Before initiating a call we dispose every registered controller
/// to free FDs and avoid the SIGABRT crash.
class VideoControllerRegistry {
  VideoControllerRegistry._();
  static final instance = VideoControllerRegistry._();

  final Set<VideoPlayerController> _controllers = <VideoPlayerController>{};
  final Map<VideoPlayerController, Set<void Function()>> _disposalListeners =
      <VideoPlayerController, Set<void Function()>>{};

  void register(VideoPlayerController controller) {
    _controllers.add(controller);
  }

  void unregister(VideoPlayerController controller) {
    _controllers.remove(controller);
    _disposalListeners.remove(controller);
  }

  bool contains(VideoPlayerController controller) =>
      _controllers.contains(controller);

  /// Subscribe to a disposal-via-registry event for [controller]. Fires once
  /// when [disposeAll] tears down [controller], letting mounted widgets drop
  /// their reference before the next rebuild hits the disposed controller.
  void addDisposalListener(
    VideoPlayerController controller,
    void Function() listener,
  ) {
    _disposalListeners.putIfAbsent(controller, () => <void Function()>{}).add(
      listener,
    );
  }

  void removeDisposalListener(
    VideoPlayerController controller,
    void Function() listener,
  ) {
    _disposalListeners[controller]?.remove(listener);
  }

  /// Pause and dispose every registered controller. Call before starting
  /// a Twilio call to release file descriptors.
  Future<void> disposeAll() async {
    final snapshot = _controllers.toList();
    _controllers.clear();
    // Fire disposal listeners synchronously so any mounted widgets can clear
    // their references before we begin the (awaited) tear-down.
    for (final c in snapshot) {
      final listeners = _disposalListeners.remove(c);
      if (listeners != null) {
        for (final l in listeners) {
          try {
            l();
          } catch (_) {}
        }
      }
    }
    for (final c in snapshot) {
      try {
        if (c.value.isInitialized) {
          await c.pause();
        }
        await c.dispose();
      } catch (_) {}
    }
  }

  int get count => _controllers.length;
}
