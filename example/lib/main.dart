import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:zip_plugin/p7zip.dart';

void main() async {
  runApp(const MyApp());
  final dir = await getTemporaryDirectory();
  final cachePath = dir.path;
  print("demo start~~~~~~~~~~~~~~~~~");
  await MyApp.copyBundleToCache("test_files", "linkfox.png");
  await compressPath(cachePath, cachePath + "/abc.7z");
  MyApp.showDirectoryFiles(cachePath);
  print("compressPath end~~~~~~~~~~~~~~~~~");

  await MyApp.copyBundleToCache("test_files", "db.7z");
  await decompress(cachePath + "/db.7z", cachePath + "/db");
  MyApp.showDirectoryFiles(cachePath + "/db");

  print("demo end~~~~~~~~~~~~~~~~~");
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
      if (FileSystemEntity.isDirectorySync(f.path)) {
        showDirectoryFiles(f.path);
      } else {
        print(File(f.path).lengthSync());
      }

    }
  }

  static Future copyBundleToCache(String bundlePath, String fileName) async{
    final dir = await getTemporaryDirectory();
    final libFile = File(dir.path + "/" + fileName);

    // 从rootBundle加载出assets资源
    final data = await rootBundle.load(bundlePath + "/" + fileName);

    final createFile = await libFile.create();
    final writeFile = await createFile.open(mode: FileMode.write);
    await writeFile.writeFrom(Uint8List.view(data.buffer));
  }

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

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
      platformVersion = 'Unknown platform version';
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
