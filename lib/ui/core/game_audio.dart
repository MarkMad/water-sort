import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

Future<void> playGameSound(String asset) async {
  try {
    await FlameAudio.play(asset);
  } catch (error) {
    debugPrint('Could not play $asset: $error');
  }
}
