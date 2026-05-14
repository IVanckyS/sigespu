import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../middleware/auth_middleware.dart';

Router buildElementosRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todos los puntos de interés
  router.get('/', (Request req) async {
    try {
      final rows = await db.db.execute(r'''
        SELECT id, tipo, nombre, descripcion, direccion, 
               ST_X(geom) as lng, ST_Y(geom) as lat,
               metadata, estado, origen, fuente_origen, created_by, created_at
        FROM puntos_interes
        ORDER BY created_at DESC
      ''');

      final items = rows.map((r) => {
        'id': r[0].toString(),
        'tipo': r[1],
        'nombre': r[2],
        'descripcion': r[3],
        'direccion': r[4],
        'lng': r[5],
        'lat': r[6],
        'metadata': r[7],
        'estado': r[8],
        'origen': r[9],
        'fuenteOrigen': r[10],
        'createdBy': r[11]?.toString(),
        'createdAt': (r[12] as DateTime).toIso8601String(),
      }).toList();

      return Response.ok(jsonEncode(items), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── POST / ── Crear un nuevo punto
  router.post('/', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final userId = req.context['user_id'] as String?;

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
          'id': body['id'],
          'tipo': body['tipo'],
          'nombre': body['nombre'],
          'descripcion': body['descripcion'],
          'direccion': body['direccion'],
          'lat': body['lat'],
          'lng': body['lng'],
          'metadata': jsonEncode(body['metadata'] ?? {}),
          'estado': body['estado'] ?? 'activo',
          'origen': body['origen'] ?? 'manual',
          'createdBy': userId,
        },
      );

      return Response(201, body: jsonEncode({'status': 'ok'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── PUT /<id> ── Actualizar punto
  router.put('/<id>', (Request req, String id) async {
    try {
      final body = jsonDecode(await req.readAsString());
      
      await db.db.execute(
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
        '''),
        parameters: {
          'id': id,
          'nombre': body['nombre'],
          'descripcion': body['descripcion'],
          'direccion': body['direccion'],
          'lat': body['lat'],
          'lng': body['lng'],
          'estado': body['estado'],
          'metadata': jsonEncode(body['metadata'] ?? {}),
        },
      );

      return Response.ok(jsonEncode({'status': 'updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── DELETE /<id> ── Eliminar punto
  router.delete('/<id>', (Request req, String id) async {
    try {
      await db.db.execute(
        Sql.named('DELETE FROM puntos_interes WHERE id = @id::uuid'),
        parameters: {'id': id},
      );
      return Response.ok(jsonEncode({'status': 'deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
