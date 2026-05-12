import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_engine_method_channel.dart';

abstract class VideoEnginePlatform extends PlatformInterface {
  /// Constructs a VideoEnginePlatform.
  VideoEnginePlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoEnginePlatform _instance = MethodChannelVideoEngine();

  /// The default instance of [VideoEnginePlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoEngine].
  static VideoEnginePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoEnginePlatform] when
  /// they register themselves.
  static set instance(VideoEnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
