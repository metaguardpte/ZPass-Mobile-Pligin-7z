import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zip_plugin/zip_plugin_method_channel.dart';

void main() {
  MethodChannelZipPlugin platform = MethodChannelZipPlugin();
  const MethodChannel channel = MethodChannel('zip_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
