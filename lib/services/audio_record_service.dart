import 'package:flutter_sound/flutter_sound.dart';

class AudioRecordService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  Future<void> init() async {
    await _recorder.openRecorder();
  }

  Future<void> startRecording(String path) async {
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      sampleRate: 44100,
      bitRate: 64000,
    );
  }

  Future<String?> stopRecording() async {
    return await _recorder.stopRecorder();
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
