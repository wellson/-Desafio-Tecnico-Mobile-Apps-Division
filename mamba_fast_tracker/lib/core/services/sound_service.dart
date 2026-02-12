import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // Preload sounds to avoid delay
  Future<void> initialize() async {
    // Optional: Preloading is generally handled by the player on first play or cache
    // But setting the mode to low latency helps
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playFastStarted() async {
    try {
      print('SoundService: Attempting to play start sound...');
      // Ensure player is stopped before playing to allow replay
      await _player.stop();
      await _player.setSource(AssetSource('sounds/start.mp3'));
      await _player.resume();
      print('SoundService: Start sound played.');
    } catch (e) {
      print('SoundService Error playing start sound: $e');
    }
  }

  Future<void> playFastEnded() async {
    try {
      print('SoundService: Attempting to play end sound...');
      await _player.stop();
      await _player.setSource(AssetSource('sounds/end.mp3'));
      await _player.resume();
      print('SoundService: End sound played.');
    } catch (e) {
      print('SoundService Error playing end sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
