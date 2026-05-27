import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../http/responses.dart';
import '../http/validators.dart';

// ignore: unused_import
import '../middleware/auth_middleware.dart'; // re-exported by callers

/// Tipos válidos de puntos de interés (alineado con CLAUDE.md §5).
const _tiposValidos = {
  'centro_acopio', 'sede_comunitaria', 'infraestructura',
  'luminaria', 'camara_cctv',
  'arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando',
  'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural', 'otro',
  'reporte_robo', 'reporte_vandalismo', 'reporte_accidente',
  'reporte_violencia', 'reporte_drogas', 'reporte_riña',
  'reporte_emergencia_medica', 'reporte_incendio', 'reporte_otro',
};

Router buildElementosRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todos los puntos de interés
  router.get('/', (Request req) => guard('listElementos', () async {
    final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 100;
    final offset = int.tryParse(req.url.queryParameters['offset'] ?? '') ?? 0;
    final safeLimit = limit.clamp(1, 500);
    final safeOffset = offset.clamp(0, 1000000);

    final rows = await db.db.execute(
      Sql.named(r'''
        SELECT id, tipo, nombre, descripcion, direccion,
               ST_X(geom) as lng, ST_Y(geom) as lat,
               metadata, estado, origen, fuente_origen, created_by, created_at
        FROM puntos_interes
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {'limit': safeLimit, 'offset': safeOffset},
    );

    final items = rows.map((r) => {
      'id': r[0].toString(),
      'tipo': r[1],
      'nombre': r[2],
      'descripcion': r[3],
      'direccion': r[4],
      'lng': r[5],
      'lat': r[6],
      'metadata': r[7] is String ? jsonDecode(r[7] as String) : r[7],
      'estado': r[8],
      'origen': r[9],
      'fuente_origen': r[10],
      'created_by': r[11]?.toString(),
      'created_at': (r[12] as DateTime?)?.toIso8601String(),
    }).toList();

    return ok(items);
  }));

  // ── POST / ── Crear un nuevo punto (con validación de tipo, lat/lng, longitudes)
  router.post('/', (Request req) => guard('createElemento', () async {
    final body = await readJsonObject(req);
    final userId = req.context['user_id'] as String?;

    final id = requireString(body, 'id', maxLen: 64);
    final tipo = requireEnum(body, 'tipo', _tiposValidos);
    final nombre = requireString(body, 'nombre', maxLen: 200);
    final descripcion = optionalString(body, 'descripcion', maxLen: 2000);
    final direccion = optionalString(body, 'direccion', maxLen: 300);
    final lat = requireLat(body);
    final lng = requireLng(body);
    final estado = optionalString(body, 'estado', maxLen: 30) ?? 'activo';
    final origen = optionalString(body, 'origen', maxLen: 30) ?? 'manual';

    await db.db.execute(
      Sql.named(r'''
        INSERT INTO puntos_interes (
          id, tipo, nombre, descripcion, direccion, geom,
          metadata, estado, origen, created_by
        ) VALUES (
          @id::uuid, @tipo, @nombre, @descripcion, @direccion,
          ST_SetSRID(ST_MakePoint(@lng, @lat), 4326),
          @metadata::jsonb, @estado, @origen, @createdBy::uuid
        )
      '''),
      parameters: {
        'id': id,
        'tipo': tipo,
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'lat': lat,
        'lng': lng,
        'metadata': jsonEncode(body['metadata'] ?? {}),
        'estado': estado,
        'origen': origen,
        'createdBy': userId,
      },
    );

    return created({'status': 'ok', 'id': id});
  }));

  // ── PUT /<id> ── Actualizar punto (con conflict detection opcional)
  //
  // Si el body incluye `client_updated_at` (ISO-8601), el UPDATE se condiciona
  // a que el `updated_at` del server sea <= a ese valor. Esto previene que dos
  // usuarios editando offline pisen los cambios uno del otro al sincronizar.
  // Si el servidor tiene una versión más nueva → 409 + el estado actual.
  // Si el body NO trae el campo → comportamiento original (last-write-wins).
  router.put('/<id>', (Request req, String id) => guard('updateElemento', () async {
    final body = await readJsonObject(req);
    final nombre = requireString(body, 'nombre', maxLen: 200);
    final descripcion = optionalString(body, 'descripcion', maxLen: 2000);
    final direccion = optionalString(body, 'direccion', maxLen: 300);
    final lat = requireLat(body);
    final lng = requireLng(body);
    final estado = optionalString(body, 'estado', maxLen: 30) ?? 'activo';
    final clientUpdatedAt = optionalString(body, 'client_updated_at', maxLen: 40);

    // Validamos el ISO-8601 si vino para evitar 500 desde Postgres con texto inválido.
    DateTime? clientTs;
    if (clientUpdatedAt != null) {
      clientTs = DateTime.tryParse(clientUpdatedAt);
      if (clientTs == null) {
        return badRequest('client_updated_at no es ISO-8601 válido');
      }
    }

    return await db.db.runTx<Response>((tx) async {
      final result = await tx.execute(
        Sql.named(r'''
          UPDATE puntos_interes SET
            nombre = @nombre,
            descripcion = @descripcion,
            direccion = @direccion,
            geom = ST_SetSRID(ST_MakePoint(@lng, @lat), 4326),
            estado = @estado,
            metadata = @metadata::jsonb,
            updated_at = NOW()
          WHERE id = @id::uuid
            AND (
              @clientTs::timestamptz IS NULL
              OR updated_at IS NULL
              OR updated_at <= @clientTs::timestamptz
            )
          RETURNING id
        '''),
        parameters: {
          'id': id,
          'nombre': nombre,
          'descripcion': descripcion,
          'direccion': direccion,
          'lat': lat,
          'lng': lng,
          'estado': estado,
          'metadata': jsonEncode(body['metadata'] ?? {}),
          'clientTs': clientTs?.toUtc().toIso8601String(),
        },
      );

      if (result.isNotEmpty) return ok({'status': 'updated'});

      // 0 filas afectadas → ¿no existe el id o hay conflicto?
      final current = await tx.execute(
        Sql.named(r'''
          SELECT id, nombre, descripcion, direccion,
                 ST_X(geom), ST_Y(geom), estado, metadata,
                 updated_at, created_at
          FROM puntos_interes WHERE id = @id::uuid
        '''),
        parameters: {'id': id},
      );
      if (current.isEmpty) return notFound('Elemento no encontrado');

      final row = current.first;
      return conflict('El elemento fue modificado por otra sesión más recientemente').change(
        body: jsonEncode({
          'error': 'CONFLICT',
          'message': 'El elemento fue modificado por otra sesión más recientemente',
          'server_state': {
            'id': row[0].toString(),
            'nombre': row[1],
            'descripcion': row[2],
            'direccion': row[3],
            'lng': row[4],
            'lat': row[5],
            'estado': row[6],
            'metadata': row[7],
            'updated_at': (row[8] as DateTime?)?.toIso8601String(),
            'created_at': (row[9] as DateTime).toIso8601String(),
          },
        }),
      );
    });
  }));

  // ── DELETE /<id> ── Eliminar punto
  router.delete('/<id>', (Request req, String id) => guard('deleteElemento', () async {
    final result = await db.db.execute(
      Sql.named('DELETE FROM puntos_interes WHERE id = @id::uuid RETURNING id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return notFound('Elemento no encontrado');
    return ok({'status': 'deleted'});
  }));

  return router;
}
