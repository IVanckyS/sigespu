import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';

Router buildZonasRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todas las zonas
  router.get('/', (Request req) async {
    try {
      final rows = await db.db.execute(r'''
        SELECT id, nombre, ST_AsGeoJSON(geom), nivel_riesgo, tipo_riesgo, 
               descripcion, created_at
        FROM zonas_peligro
        ORDER BY created_at DESC
      ''');

      final items = rows.map((r) => {
        'id': r[0].toString(),
        'nombre': r[1],
        'geojson': jsonDecode(r[2] as String),
        'nivelRiesgo': r[3],
        'tipoRiesgo': r[4],
        'descripcion': r[5],
        'createdAt': (r[6] as DateTime).toIso8601String(),
      }).toList();

      return Response.ok(jsonEncode(items), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── POST / ── Crear una nueva zona
  router.post('/', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      
      // Convertir lista de LatLng a GeoJSON Polygon
      final List<dynamic> points = body['puntos'];
      final polygonCoords = points.map((p) => [p['lng'], p['lat']]).toList();
      // Asegurar que el polígono esté cerrado
      if (polygonCoords.first[0] != polygonCoords.last[0] || polygonCoords.first[1] != polygonCoords.last[1]) {
        polygonCoords.add(polygonCoords.first);
      }
      
      final geojson = {
        'type': 'Polygon',
        'coordinates': [polygonCoords]
      };

      await db.db.execute(
        Sql.named(r'''
          INSERT INTO zonas_peligro (
            id, nombre, geom, nivel_riesgo, tipo_riesgo, descripcion
          ) VALUES (
            @id::uuid, @nombre, ST_GeomFromGeoJSON(@geom), @nivel, @tipoPeligro, @descripcion
          )
        '''),
        parameters: {
          'id': body['id'],
          'nombre': body['nombre'],
          'geom': jsonEncode(geojson),
          'nivel': body['nivel'],
          'tipoPeligro': body['tipoPeligro'],
          'descripcion': body['descripcion'],
        },
      );

      return Response(201, body: jsonEncode({'status': 'ok'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── DELETE /<id> ── Eliminar zona
  router.delete('/<id>', (Request req, String id) async {
    try {
      await db.db.execute(
        Sql.named('DELETE FROM zonas_peligro WHERE id = @id::uuid'),
        parameters: {'id': id},
      );
      return Response.ok(jsonEncode({'status': 'deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
