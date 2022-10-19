
import 'zip_plugin_platform_interface.dart';
export 'src/p7zip.dart';

class ZipPlugin {
  Future<String?> getPlatformVersion() {
    return ZipPluginPlatform.instance.getPlatformVersion();
  }
}
