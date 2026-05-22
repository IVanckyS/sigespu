import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> platformSaveExcel(List<int> bytes, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}${Platform.pathSeparator}$filename';
  await File(path).writeAsBytes(bytes);
  return path;
}
