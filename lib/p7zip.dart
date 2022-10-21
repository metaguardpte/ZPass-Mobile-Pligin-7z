import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/src/utf8.dart';

typedef _nativeP7zipFunc = Int32 Function(Pointer<Int8>,Pointer<Int8>);
typedef _dartP7zipFunc = int Function(Pointer<Int8>, Pointer<Int8>);

const String soFile = "libplzma.so";
const String nativeCompressPath = "compressPath";
const String nativeDecompress = "decompress";

final DynamicLibrary p7zipLib = Platform.isAndroid
    ? DynamicLibrary.open(soFile)
    : DynamicLibrary.process();

void _nativeCompressPath(List argv) {
  final SendPort sendPort = argv[0];
  final String fromPath = argv[1];
  final String toZipFullPath = argv[2];

  final _dartP7zipFunc plzma = p7zipLib.lookup<NativeFunction<_nativeP7zipFunc>>(nativeCompressPath).asFunction();
  final result = plzma.call(fromPath.toNativeUtf8().cast<Int8>(), toZipFullPath.toNativeUtf8().cast<Int8>());
  Isolate.exit(sendPort, result);
}

void _nativeDecompress(List argv) {
  final SendPort sendPort = argv[0];
  final String fromZipPath = argv[1];
  final String toPath = argv[2];

  final _dartP7zipFunc plzma = p7zipLib.lookup<NativeFunction<_nativeP7zipFunc>>(nativeDecompress).asFunction();
  final result = plzma.call(fromZipPath.toNativeUtf8().cast<Int8>(), toPath.toNativeUtf8().cast<Int8>());
  Isolate.exit(sendPort, result);
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