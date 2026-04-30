import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';

Future<void> scrapePatentes(Connection db, Command redis, NominatimClient geocoder) async {
  print('Iniciando scraping de patentes (ig=164)...');
  final url = 'https://www.lotatransparente.cl/index.php?ig=164';
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'SigespuLota/1.0 (+contacto@munilota.cl)'}
    );
    
    if (response.statusCode != 200) {
      print('Error: HTTP \${response.statusCode}');
      return;
    }
    
    final document = parser.parse(response.body);
    final rows = document.querySelectorAll('table tbody tr');
    
    for (var row in rows) {
      final cols = row.querySelectorAll('td');
      if (cols.length < 6) continue;
      
      final rawDireccion = cols[5].text.trim(); // Simulado
      if (rawDireccion.isEmpty) continue;
      
      final normalizada = normalizarDireccionLota(rawDireccion);
      double? lat, lng;
      
      if (normalizada != null) {
        final geo = await geocoder.geocode(normalizada);
        if (geo != null) {
          lat = geo['lat'];
          lng = geo['lon'];
        }
      }
      
      // Aquí iría el cache con redis para evitar duplicados, y el insert a postgres...
      // Para evitar warnings de linter:
      if (lat != null && lng != null) {
        print('Direccion geocodificada: \$normalizada, \$lat, \$lng');
      }
    }
    print('Scraping de patentes completado.');
  } catch (e) {
    print('Error scraping patentes: \$e');
  }
}

