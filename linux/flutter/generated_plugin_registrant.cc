//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_gstreamer_player/flutter_gstreamer_player_plugin.h>
#include <quick_usb/quick_usb_plugin.h>
#include <yaru/yaru_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) flutter_gstreamer_player_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterGstreamerPlayerPlugin");
  flutter_gstreamer_player_plugin_register_with_registrar(flutter_gstreamer_player_registrar);
  g_autoptr(FlPluginRegistrar) quick_usb_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "QuickUsbPlugin");
  quick_usb_plugin_register_with_registrar(quick_usb_registrar);
  g_autoptr(FlPluginRegistrar) yaru_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "YaruPlugin");
  yaru_plugin_register_with_registrar(yaru_registrar);
}
