import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/src/utf8.dart';

typedef _NativeP7zipShell = Int32 Function(Pointer<Int8>);
typedef _DartP7zipShell = int Function(Pointer<Int8>);

const String soFile = "lib7zr.so";
const String zipFunctionName = "p7zipShell";

final DynamicLibrary p7zipLib = Platform.isAndroid
    ? DynamicLibrary.open(soFile)
    : DynamicLibrary.process();

void _shell(List argv) {
  // 传递进来的参数列表转化
  final SendPort sendPort = argv[0];
  final String cmd = argv[1];

  // 获得native中的p7zipShell函数
  final _DartP7zipShell p7zipShell = p7zipLib.lookup<NativeFunction<_NativeP7zipShell>>(zipFunctionName).asFunction();

  // 把dart的String转化为c++中的char *
  final cstr = cmd.toNativeUtf8().cast<Int8>();
  print("cmd:$cmd");
  final result = p7zipShell.call(cstr);

  // 通知主线程任务执行结果
  sendPort.send(result);
}

///传入须要压缩的文件列表，以及压缩文件的路径
Future<String?> compress(List<String> files, String zipFilePath) async {
  // 文件列表转化为字符串
  String filesStr = "";
  files.forEach((element) {
  filesStr += " $element";
  });

  // 执行isolate任务
  final receivePort = ReceivePort();
  await Isolate.spawn(_shell, [ receivePort.sendPort, "7zr a $zipFilePath $filesStr" ]);
  // 等待任务完成，获得执行结果，0表示执行成功
  final result = await receivePort.first;
  return result == 0 ? zipFilePath : null;
}

///fromZipFile: 传入需要解压缩的7zip文件
///toPath: 解压缩到哪个路径
Future<String?> deCompress(String fromZipFile, String toPath) async {
  // 执行isolate任务
  final receivePort = ReceivePort();
  await Isolate.spawn(_shell, [ receivePort.sendPort, "7zr x $fromZipFile -o$toPath" ]);
  // 等待任务完成，获得执行结果，0表示执行成功
  final result = await receivePort.first;
  return result == 0 ? toPath : null;
}