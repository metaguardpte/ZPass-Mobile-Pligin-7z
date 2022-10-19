import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:zip_plugin/zip_plugin.dart';

void main() async {
  runApp(const MyApp());

  final dir = await getTemporaryDirectory();
  List<String> files = [];
  files.add(dir.path + "/*");

  await compress(files, "/data/user/0/com.example.zip_plugin_example/cache/abc.7z");
  MyApp.showDirectoryFiles(dir.path);

  //await deCompress("/data/user/0/com.example.zip_plugin_example/cache/abc.7z", "/data/user/0/com.example.zip_plugin_example/cache/abc");
  //MyApp.showDirectoryFiles("/data/user/0/com.example.zip_plugin_example/cache/abc");

}

class MyApp extends StatefulWidget {

  static void showDirectoryFiles(String directoryPath){
    var directory = Directory(directoryPath);
    List<FileSystemEntity> fileList = directory.listSync();
    var dirSize = fileList.length;
    print("dir:$directoryPath has files: $dirSize");

    for(FileSystemEntity f in fileList){
      print("---------");
      print("path:" + f.path);
      print(f.existsSync());
      if (FileSystemEntity.isDirectorySync(f.path)) {
        showDirectoryFiles(f.path);
      } else {
        print("length:");print(File(f.path).lengthSync());
      }

    }
  }

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _zipPlugin = ZipPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _zipPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
