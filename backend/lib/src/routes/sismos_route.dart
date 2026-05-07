import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';

Router buildSismosRouter(DatabaseService db) {
  final router = Router();

  router.get('/', (Request req) async {
    final params = req.url.queryParameters;
    final dias = (int.tryParse(params['dias'] ?? '7') ?? 7).clamp(1, 30);
    final minMag = double.tryParse(params['minmagnitude'] ?? '3.0') ?? 3.0;
    final maxRadius = double.tryParse(params['maxradiuskm'] ?? '500') ?? 500.0;

    // Check if cache is fresh (any row fetched in last 5 minutes)
    final cacheCheck = await db.db.execute(
      "SELECT COUNT(*) FROM sismos_cache WHERE fetched_at > NOW() - INTERVAL '5 minutes'",
    );
    final cacheCount = (cacheCheck.first[0] as int? ?? 0);

    if (cacheCount > 0) {
      return _returnFromCache(db, dias, minMag);
    }

    // Fetch from USGS
    final startTime = DateTime.now().toUtc().subtract(Duration(days: dias)).toIso8601String().substring(0, 10);
    final endTime = DateTime.now().toUtc().toIso8601String().substring(0, 10);

    final usgsUrl = Uri.parse(
      'https://earthquake.usgs.gov/fdsnws/event/1/query'
      '?format=geojson'
      '&starttime=$startTime'
      '&endtime=$endTime'
      '&minmagnitude=$minMag'
      '&latitude=-37.0894'
      '&longitude=-73.1580'
      '&maxradiuskm=$maxRadius'
      '&orderby=time'
      '&limit=200',
    );

    try {
      final usgsResp = await http.get(usgsUrl).timeout(const Duration(seconds: 10));
      if (usgsResp.statusCode != 200) {
        return _returnStaleOrError(db, dias, minMag);
      }

      final geoJson = jsonDecode(usgsResp.body) as Map<String, dynamic>;
      final features = (geoJson['features'] as List).cast<Map<String, dynamic>>();

      for (final f in features) {
        final props = f['properties'] as Map<String, dynamic>;
        final coords = (f['geometry']['coordinates'] as List);
        final lon = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        final depthKm = coords.length > 2 ? (coords[2] as num).toDouble() : null;
        final timeMs = (props['time'] as num).toInt();
        final timeUtc = DateTime.fromMillisecondsSinceEpoch(timeMs, isUtc: true);
        final tsunamiRaw = props['tsunami'];
        final tsunamiBool = tsunamiRaw != null && (tsunamiRaw as num).toInt() == 1;

        await db.db.execute(
          Sql.named(r'''
          INSERT INTO sismos_cache (usgs_id, magnitude, mag_type, place, time_utc, depth_km, alert, tsunami, url_usgs, geom, fetched_at)
          VALUES (@usgsId, @magnitude, @magType, @place, @timeUtc, @depthKm, @alert, @tsunami, @urlUsgs, ST_SetSRID(ST_MakePoint(@lon, @lat), 4326), NOW())
          ON CONFLICT (usgs_id) DO UPDATE SET
            magnitude = EXCLUDED.magnitude,
            place = EXCLUDED.place,
            time_utc = EXCLUDED.time_utc,
            depth_km = EXCLUDED.depth_km,
            alert = EXCLUDED.alert,
            tsunami = EXCLUDED.tsunami,
            fetched_at = NOW()
          '''),
          parameters: {
            'usgsId': f['id'],
            'magnitude': (props['mag'] as num?)?.toDouble() ?? 0.0,
            'magType': props['magType'],
            'place': props['place'],
            'timeUtc': timeUtc.toIso8601String(),
            'depthKm': depthKm,
            'alert': props['alert'],
            'tsunami': tsunamiBool,
            'urlUsgs': props['url'],
            'lon': lon,
            'lat': lat,
          },
        );
      }

      return _returnFromCache(db, dias, minMag);
    } catch (_) {
      return _returnStaleOrError(db, dias, minMag);
    }
  });

  return router;
}

Future<Response> _returnFromCache(DatabaseService db, int dias, double minMag) async {
  final since = DateTime.now().toUtc().subtract(Duration(days: dias)).toIso8601String();
  final rows = await db.db.execute(
    Sql.named(r'''
    SELECT usgs_id, magnitude, mag_type, place, time_utc, depth_km,
           ST_Y(geom::geometry) AS lat, ST_X(geom::geometry) AS lon,
           alert, tsunami, url_usgs
    FROM sismos_cache
    WHERE time_utc >= @since AND magnitude >= @minMag
    ORDER BY time_utc DESC
    '''),
    parameters: {'since': since, 'minMag': minMag},
  );

  final sismos = rows.map((r) => {
    'id': r[0],
    'magnitude': r[1],
    'magType': r[2],
    'place': r[3],
    'timeUtc': (r[4] as DateTime).toIso8601String(),
    'depthKm': r[5],
    'latitude': r[6],
    'longitude': r[7],
    'alert': r[8],
    'tsunami': (r[9] as bool?) == true ? 1 : 0,
    'urlUsgs': r[10],
  }).toList();

  return Response.ok(
    jsonEncode({
      'sismos': sismos,
      'total': sismos.length,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'stale': false,
    }),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _returnStaleOrError(DatabaseService db, int dias, double minMag) async {
  final since = DateTime.now().toUtc().subtract(Duration(days: dias)).toIso8601String();
  final rows = await db.db.execute(
    Sql.named(r'''
    SELECT usgs_id, magnitude, mag_type, place, time_utc, depth_km,
           ST_Y(geom::geometry) AS lat, ST_X(geom::geometry) AS lon,
           alert, tsunami, url_usgs
    FROM sismos_cache
    WHERE time_utc >= @since AND magnitude >= @minMag
    ORDER BY time_utc DESC
    '''),
    parameters: {'since': since, 'minMag': minMag},
  );

  if (rows.isEmpty) {
    return Response(
      503,
      body: jsonEncode({'error': 'USGS no disponible y sin cache local'}),
      headers: {'content-type': 'application/json'},
    );
  }

  final sismos = rows.map((r) => {
    'id': r[0],
    'magnitude': r[1],
    'magType': r[2],
    'place': r[3],
    'timeUtc': (r[4] as DateTime).toIso8601String(),
    'depthKm': r[5],
    'latitude': r[6],
    'longitude': r[7],
    'alert': r[8],
    'tsunami': (r[9] as bool?) == true ? 1 : 0,
    'urlUsgs': r[10],
  }).toList();

  return Response.ok(
    jsonEncode({
      'sismos': sismos,
      'total': sismos.length,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'stale': true,
    }),
    headers: {'content-type': 'application/json'},
  );
}
