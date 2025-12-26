import 'package:audioplayers/audioplayers.dart';

enum LoopState { none, all, one }

class MyAudioHandler {
  static final MyAudioHandler _instance = MyAudioHandler._internal();
  factory MyAudioHandler() => _instance;
  MyAudioHandler._internal();

  final AudioPlayer player = AudioPlayer();
  Map<String, String>? currentSong;
  bool isPlaying = false;
  LoopState loopState = LoopState.all;

  Function? onSongComplete;

  void init() {
    player.onPlayerComplete.listen((event) {
      if (loopState == LoopState.one) {
        // ReleaseMode.loopにより自動で繰り返されます
      } else if (onSongComplete != null) {
        onSongComplete!();
      }
    });
  }

  Future<void> playNewSong(Map<String, String> song) async {
    currentSong = song;
    await player.stop();
    _updateLoopMode();
    String? path = song['music'] ?? song['path'];
    if (path != null) {
      await player.play(AssetSource(path));
      isPlaying = true;
    }
  }

  void _updateLoopMode() {
    if (loopState == LoopState.one) {
      player.setReleaseMode(ReleaseMode.loop);
    } else {
      player.setReleaseMode(ReleaseMode.release);
    }
  }

  Future<void> toggleLoop() async {
    if (loopState == LoopState.none) loopState = LoopState.all;
    else if (loopState == LoopState.all) loopState = LoopState.one;
    else loopState = LoopState.none;
    _updateLoopMode();
  }

  Future<void> toggle() async {
    if (isPlaying) {
      await player.pause();
      isPlaying = false;
    } else {
      if (currentSong != null) {
        await player.resume();
        isPlaying = true;
      }
    }
  }
}