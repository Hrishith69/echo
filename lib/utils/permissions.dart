import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureMicrophonePermission() async {
  final status = await Permission.microphone.status;
  if (status.isGranted) return true;
  final result = await Permission.microphone.request();
  return result.isGranted;
}
