// Helper multiplataforma para guardar un archivo Excel.
// En web dispara una descarga del navegador, en móvil/desktop usa path_provider.
// TODO(sprint-4): implementar variante web con dart:html download.

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

/// Guarda los bytes como archivo .xlsx y retorna la ruta resultante.
/// En web retorna solo el filename (la descarga la dispara el browser).
Future<String> platformSaveExcel(List<int> bytes, String filename) async {
  if (kIsWeb) {
    // TODO(sprint-4): disparar download via dart:html anchor con blob.
    return filename;
  }
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}${Platform.pathSeparator}$filename';
  await File(path).writeAsBytes(bytes);
  return path;
}
