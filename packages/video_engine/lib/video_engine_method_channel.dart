import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_engine_platform_interface.dart';

/// An implementation of [VideoEnginePlatform] that uses method channels.
class MethodChannelVideoEngine extends VideoEnginePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_engine');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
