import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zip_plugin_method_channel.dart';

abstract class ZipPluginPlatform extends PlatformInterface {
  /// Constructs a ZipPluginPlatform.
  ZipPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZipPluginPlatform _instance = MethodChannelZipPlugin();

  /// The default instance of [ZipPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelZipPlugin].
  static ZipPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZipPluginPlatform] when
  /// they register themselves.
  static set instance(ZipPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
