import 'package:flutter_test/flutter_test.dart';
import 'package:video_engine/video_engine.dart';
import 'package:video_engine/video_engine_platform_interface.dart';
import 'package:video_engine/video_engine_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoEnginePlatform
    with MockPlatformInterfaceMixin
    implements VideoEnginePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VideoEnginePlatform initialPlatform = VideoEnginePlatform.instance;

  test('$MethodChannelVideoEngine is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideoEngine>());
  });

  test('getPlatformVersion', () async {
    VideoEngine videoEnginePlugin = VideoEngine();
    MockVideoEnginePlatform fakePlatform = MockVideoEnginePlatform();
    VideoEnginePlatform.instance = fakePlatform;

    expect(await videoEnginePlugin.getPlatformVersion(), '42');
  });
}
