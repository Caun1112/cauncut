#ifndef FLUTTER_PLUGIN_VIDEO_ENGINE_PLUGIN_H_
#define FLUTTER_PLUGIN_VIDEO_ENGINE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace video_engine {

class VideoEnginePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  VideoEnginePlugin();

  virtual ~VideoEnginePlugin();

  // Disallow copy and assign.
  VideoEnginePlugin(const VideoEnginePlugin&) = delete;
  VideoEnginePlugin& operator=(const VideoEnginePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace video_engine

#endif  // FLUTTER_PLUGIN_VIDEO_ENGINE_PLUGIN_H_
