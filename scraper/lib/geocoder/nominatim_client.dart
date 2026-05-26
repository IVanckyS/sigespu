import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class NominatimClient {
  final String _userAgent = 'SigespuLota/1.0 (+contacto@munilota.cl)';
  DateTime _lastRequest = DateTime.now().subtract(Duration(seconds: 2));

  Future<Map<String, dynamic>?> geocode(String query) async {
    final now = DateTime.now();
    final diff = now.difference(_lastRequest);
    // Rate limiting: 1 req/s Nominatim
    if (diff.inMilliseconds < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - diff.inMilliseconds));
    }
    
    _lastRequest = DateTime.now();
    
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'cl',
    });

    try {
      final response = await http.get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
            'confidence': 'alta', 
          };
        }
      }
    } catch (e) {
      print('Nominatim Error: $e');
    }
    return null;
  }
}
