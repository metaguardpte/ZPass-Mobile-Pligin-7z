import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/src/utf8.dart';

typedef _nativeP7zipFunc = Int32 Function(Pointer<Int8>,Pointer<Int8>);
typedef _dartP7zipFunc = int Function(Pointer<Int8>, Pointer<Int8>);

const String soFile = "libplzma.so";
const String funcNativeCompressPath = "compressPath";
const String funcNativeDecompress = "decompress";
const String funcNativeCompressFiles = "compressFiles";

final DynamicLibrary p7zipLib = Platform.isAndroid
    ? DynamicLibrary.open(soFile)
    : DynamicLibrary.process();

/// files would be compressed to file(toZip)
Future<String?> compressFiles(List<String> fromFiles, String toZip) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_nativeCompressFiles, [receivePort.sendPort, fromFiles, toZip]);
  final result = await receivePort.first;
  return result == 0 ? toZip : null;
}

/// files in this directory(fromPath) would be compressed to file(toZip)
Future<String?> compressPath(String fromPath, String toZip) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_nativeCompressPath, [receivePort.sendPort, fromPath, toZip]);
  final result = await receivePort.first;
  return result == 0 ? toZip : null;
}

///zip file(fromZip) would be extracted to directory(toPath)
Future<String?> decompress(String fromZip, String toPath) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_nativeDecompress, [receivePort.sendPort, fromZip, toPath]);
  final result = await receivePort.first;
  return result == 0 ? toPath : null;
}

void _nativeCompressFiles(List argv) {
  final SendPort sendPort = argv[0];
  final List<String> files = argv[1];
  final String toZipFullPath = argv[2];

  // 文件列表转化为字符串
  String filesStr = "";
  files.forEach((element) {
    filesStr += " $element";
  });

  final _dartP7zipFunc plzma =
    p7zipLib.lookup<NativeFunction<_nativeP7zipFunc>>(funcNativeCompressFiles).asFunction();
  final result = plzma.call(filesStr.toNativeUtf8().cast<Int8>(), toZipFullPath.toNativeUtf8().cast<Int8>());
  Isolate.exit(sendPort, result);
}

void _nativeCompressPath(List argv) {
  final SendPort sendPort = argv[0];
  final String fromPath = argv[1];
  final String toZipFullPath = argv[2];

  final _dartP7zipFunc plzma = p7zipLib.lookup<NativeFunction<_nativeP7zipFunc>>(funcNativeCompressPath).asFunction();
  final result = plzma.call(fromPath.toNativeUtf8().cast<Int8>(), toZipFullPath.toNativeUtf8().cast<Int8>());
  Isolate.exit(sendPort, result);
}

void _nativeDecompress(List argv) {
  final SendPort sendPort = argv[0];
  final String fromZipPath = argv[1];
  final String toPath = argv[2];

  final _dartP7zipFunc plzma = p7zipLib.lookup<NativeFunction<_nativeP7zipFunc>>(funcNativeDecompress).asFunction();
  final result = plzma.call(fromZipPath.toNativeUtf8().cast<Int8>(), toPath.toNativeUtf8().cast<Int8>());
  Isolate.exit(sendPort, result);
}