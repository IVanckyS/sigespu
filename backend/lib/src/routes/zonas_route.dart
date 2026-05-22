import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../http/responses.dart';
import '../http/validators.dart';

const _tiposRiesgo = {
  'drogas', 'robos', 'vivienda_ilegal', 'vandalismo', 'riña',
  'sin_iluminacion', 'accidentes', 'microbasural', 'otro',
};

Router buildZonasRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todas las zonas
  router.get('/', (Request req) => guard('listZonas', () async {
    final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 100;
    final offset = int.tryParse(req.url.queryParameters['offset'] ?? '') ?? 0;
    final safeLimit = limit.clamp(1, 500);
    final safeOffset = offset.clamp(0, 1000000);

    final rows = await db.db.execute(
      Sql.named(r'''
        SELECT id, nombre, ST_AsGeoJSON(geom), nivel_riesgo, tipo_riesgo,
               descripcion, created_at
        FROM zonas_peligro
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {'limit': safeLimit, 'offset': safeOffset},
    );

    final items = rows.map((r) => {
      'id': r[0].toString(),
      'nombre': r[1],
      'geojson': jsonDecode(r[2] as String),
      'nivelRiesgo': r[3],
      'tipoRiesgo': r[4],
      'descripcion': r[5],
      'createdAt': (r[6] as DateTime).toIso8601String(),
    }).toList();

    return ok(items);
  }));

  // ── POST / ── Crear una nueva zona
  router.post('/', (Request req) => guard('createZona', () async {
    final body = await readJsonObject(req);

    final id = requireString(body, 'id', maxLen: 64);
    final nombre = requireString(body, 'nombre', maxLen: 200);
    final nivel = requireDouble(body, 'nivel', min: 1, max: 5).toInt();
    final tipoPeligro = optionalString(body, 'tipoPeligro', maxLen: 50);
    if (tipoPeligro != null && !_tiposRiesgo.contains(tipoPeligro)) {
      return badRequest(
          'tipoPeligro inválido. Permitidos: ${_tiposRiesgo.join(", ")}');
    }
    final descripcion = optionalString(body, 'descripcion', maxLen: 5000);

    final rawPoints = body['puntos'];
    if (rawPoints is! List || rawPoints.length < 3) {
      return badRequest('Se requieren al menos 3 puntos en "puntos"');
    }

    // Convertir lista de {lat, lng} → coords GeoJSON [lng, lat] con validación.
    final polygonCoords = <List<double>>[];
    for (final p in rawPoints) {
      if (p is! Map) {
        return badRequest('Cada punto debe ser un objeto {lat, lng}');
      }
      final lat = p['lat'];
      final lng = p['lng'];
      if (lat is! num || lng is! num) {
        return badRequest('lat/lng deben ser numéricos en todos los puntos');
      }
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        return badRequest('lat/lng fuera de rango en algún punto');
      }
      polygonCoords.add([lng.toDouble(), lat.toDouble()]);
    }

    // Cerrar polígono si no viene cerrado
    if (polygonCoords.first[0] != polygonCoords.last[0] ||
        polygonCoords.first[1] != polygonCoords.last[1]) {
      polygonCoords.add(polygonCoords.first);
    }

    final geojson = {'type': 'Polygon', 'coordinates': [polygonCoords]};

    await db.db.execute(
      Sql.named(r'''
        INSERT INTO zonas_peligro (
          id, nombre, geom, nivel_riesgo, tipo_riesgo, descripcion
        ) VALUES (
          @id::uuid, @nombre, ST_GeomFromGeoJSON(@geom), @nivel, @tipoPeligro, @descripcion
        )
      '''),
      parameters: {
        'id': id,
        'nombre': nombre,
        'geom': jsonEncode(geojson),
        'nivel': nivel,
        'tipoPeligro': tipoPeligro,
        'descripcion': descripcion,
      },
    );

    return created({'status': 'ok', 'id': id});
  }));

  // ── PUT /<id> ── Actualizar zona (con conflict detection opcional)
  router.put('/<id>', (Request req, String id) => guard('updateZona', () async {
    final body = await readJsonObject(req);

    final nombre = requireString(body, 'nombre', maxLen: 200);
    final nivel = requireDouble(body, 'nivel', min: 1, max: 5).toInt();
    final tipoPeligro = optionalString(body, 'tipoPeligro', maxLen: 50);
    if (tipoPeligro != null && !_tiposRiesgo.contains(tipoPeligro)) {
      return badRequest(
          'tipoPeligro inválido. Permitidos: ${_tiposRiesgo.join(", ")}');
    }
    final descripcion = optionalString(body, 'descripcion', maxLen: 5000);
    final clientUpdatedAt = optionalString(body, 'client_updated_at', maxLen: 40);

    DateTime? clientTs;
    if (clientUpdatedAt != null) {
      clientTs = DateTime.tryParse(clientUpdatedAt);
      if (clientTs == null) {
        return badRequest('client_updated_at no es ISO-8601 válido');
      }
    }

    // Si vienen puntos nuevos los aceptamos; si no, dejamos la geometría intacta.
    final rawPoints = body['puntos'];
    String? geomJson;
    if (rawPoints is List) {
      if (rawPoints.length < 3) {
        return badRequest('Se requieren al menos 3 puntos en "puntos"');
      }
      final polygonCoords = <List<double>>[];
      for (final p in rawPoints) {
        if (p is! Map) {
          return badRequest('Cada punto debe ser un objeto {lat, lng}');
        }
        final lat = p['lat'];
        final lng = p['lng'];
        if (lat is! num || lng is! num) {
          return badRequest('lat/lng deben ser numéricos en todos los puntos');
        }
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          return badRequest('lat/lng fuera de rango en algún punto');
        }
        polygonCoords.add([lng.toDouble(), lat.toDouble()]);
      }
      if (polygonCoords.first[0] != polygonCoords.last[0] ||
          polygonCoords.first[1] != polygonCoords.last[1]) {
        polygonCoords.add(polygonCoords.first);
      }
      geomJson = jsonEncode({'type': 'Polygon', 'coordinates': [polygonCoords]});
    }

    return await db.db.runTx<Response>((tx) async {
      // UPDATE condicional: la query se construye en 2 ramas según si actualizamos
      // o no la geometría — postgres no soporta "COALESCE de geom" con parámetro
      // nullable de forma directa y limpia.
      final params = {
        'id': id,
        'nombre': nombre,
        'nivel': nivel,
        'tipoPeligro': tipoPeligro,
        'descripcion': descripcion,
        'clientTs': clientTs?.toUtc().toIso8601String(),
        if (geomJson != null) 'geom': geomJson,
      };

      final geomClause = geomJson != null ? 'geom = ST_GeomFromGeoJSON(@geom),' : '';
      final result = await tx.execute(
        Sql.named('''
          UPDATE zonas_peligro SET
            nombre = @nombre,
            nivel_riesgo = @nivel,
            tipo_riesgo = @tipoPeligro,
            descripcion = @descripcion,
            $geomClause
            updated_at = NOW()
          WHERE id = @id::uuid
            AND (
              @clientTs::timestamptz IS NULL
              OR updated_at IS NULL
              OR updated_at <= @clientTs::timestamptz
            )
          RETURNING id
        '''),
        parameters: params,
      );

      if (result.isNotEmpty) return ok({'status': 'updated'});

      // 0 filas → ¿no existe o conflicto?
      final current = await tx.execute(
        Sql.named(r'''
          SELECT id, nombre, ST_AsGeoJSON(geom), nivel_riesgo, tipo_riesgo,
                 descripcion, updated_at, created_at
          FROM zonas_peligro WHERE id = @id::uuid
        '''),
        parameters: {'id': id},
      );
      if (current.isEmpty) return notFound('Zona no encontrada');

      final row = current.first;
      return conflict('La zona fue modificada por otra sesión más recientemente').change(
        body: jsonEncode({
          'error': 'CONFLICT',
          'message': 'La zona fue modificada por otra sesión más recientemente',
          'server_state': {
            'id': row[0].toString(),
            'nombre': row[1],
            'geojson': jsonDecode(row[2] as String),
            'nivelRiesgo': row[3],
            'tipoRiesgo': row[4],
            'descripcion': row[5],
            'updated_at': (row[6] as DateTime?)?.toIso8601String(),
            'created_at': (row[7] as DateTime).toIso8601String(),
          },
        }),
      );
    });
  }));

  // ── DELETE /<id> ── Eliminar zona
  router.delete('/<id>', (Request req, String id) => guard('deleteZona', () async {
    final result = await db.db.execute(
      Sql.named('DELETE FROM zonas_peligro WHERE id = @id::uuid RETURNING id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return notFound('Zona no encontrada');
    return ok({'status': 'deleted'});
  }));

  return router;
}
