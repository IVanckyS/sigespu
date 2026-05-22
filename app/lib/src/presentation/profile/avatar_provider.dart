// Stub mínimo: el recovery del 19-may esperaba un provider con bytes de avatar
// del usuario. Aquí devolvemos null hasta que se implemente upload de avatar.
// TODO(sprint-4): persistir avatar en backend + flutter_secure_storage.

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final avatarBytesProvider = FutureProvider<Uint8List?>((ref) async {
  return null;
});
