
import 'zip_plugin_platform_interface.dart';

class ZipPlugin {
  Future<String?> getPlatformVersion() {
    return ZipPluginPlatform.instance.getPlatformVersion();
  }
}
