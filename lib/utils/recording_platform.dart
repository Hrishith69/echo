import 'package:flutter/foundation.dart';

/// Voice recording via flutter_sound is only supported on mobile targets.
bool get isVoiceRecordingSupported {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
