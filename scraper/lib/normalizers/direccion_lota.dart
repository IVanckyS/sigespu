String? normalizarDireccionLota(String raw) {
  var dir = raw.trim();
  if (dir.isEmpty) return null;
  
  final lower = dir.toLowerCase();
  
  // Casos sin geocoding posible (van a bandeja)
  if (lower.contains('pabellón') || lower.contains('pabellon')) return null;
  if (RegExp(r'^s-\d').hasMatch(lower) && !lower.contains('calle')) return null;

  // Reemplazos locales
  dir = dir.replaceAll(RegExp(r'\bP\.A\. Cerda\b', caseSensitive: false), 'Pedro Aguirre Cerda');
  dir = dir.replaceAll(RegExp(r'\bP\.A\.C\.\b', caseSensitive: false), 'Pedro Aguirre Cerda');
  dir = dir.replaceAll(RegExp(r'\bPob\. G\. Mistral\b', caseSensitive: false), 'Población Gabriela Mistral');
  dir = dir.replaceAll(RegExp(r'\bMon\. Fuenzalida\b', caseSensitive: false), 'Monseñor Fuenzalida');
  
  // Agregar sufijos
  if (!lower.contains('lota')) {
    dir = '$dir, Lota, Chile';
  }
  
  return dir;
}
