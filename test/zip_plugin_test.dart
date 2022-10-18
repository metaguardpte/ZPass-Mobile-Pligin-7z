import 'package:flutter_test/flutter_test.dart';
import 'package:zip_plugin/zip_plugin.dart';
import 'package:zip_plugin/zip_plugin_platform_interface.dart';
import 'package:zip_plugin/zip_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZipPluginPlatform
    with MockPlatformInterfaceMixin
    implements ZipPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZipPluginPlatform initialPlatform = ZipPluginPlatform.instance;

  test('$MethodChannelZipPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZipPlugin>());
  });

  test('getPlatformVersion', () async {
    ZipPlugin zipPlugin = ZipPlugin();
    MockZipPluginPlatform fakePlatform = MockZipPluginPlatform();
    ZipPluginPlatform.instance = fakePlatform;

    expect(await zipPlugin.getPlatformVersion(), '42');
  });
}
