import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool isMuted = false;

  static Future<void> _play(String file) async {
    if (isMuted) return;
    await _player.stop(); // prevent overlap
    await _player.play(AssetSource('sounds/$file'));
  }

  static void click() => _play('click.mp3');
  static void tap() => _play('tap.mp3');
  static void pop() => _play('pop.mp3');
  static void notify() => _play('notification.mp3');
  static void gameStart() => _play('game.mp3');
  static void win() => _play('win.mp3');
}
