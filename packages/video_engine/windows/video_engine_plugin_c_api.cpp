#include "include/video_engine/video_engine_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "video_engine_plugin.h"

void VideoEnginePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  video_engine::VideoEnginePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
