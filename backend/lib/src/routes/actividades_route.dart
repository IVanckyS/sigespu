import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';

Router buildActividadesRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todas las actividades
  router.get('/', (Request req) async {
    try {
      final rows = await db.db.execute(r'''
        SELECT id, tipo, estado, titulo, descripcion, 
               fecha_inicio, fecha_fin, participante_ids,
               lat, lng, direccion, sector, direccion_municipal,
               presupuesto_estimado, acta, creado_por, creado_en, actualizado_en
        FROM actividades_municipales
        ORDER BY fecha_inicio DESC
      ''');

      final items = rows.map((r) => {
        'id': r[0].toString(),
        'tipo': r[1],
        'estado': r[2],
        'titulo': r[3],
        'descripcion': r[4],
        'fechaInicio': (r[5] as DateTime).toIso8601String(),
        'fechaFin': (r[6] as DateTime?)?.toIso8601String(),
        'participanteIds': r[7],
        'lat': r[8],
        'lng': r[9],
        'direccion': r[10],
        'sector': r[11],
        'direccionMunicipal': r[12],
        'presupuestoEstimado': r[13],
        'acta': r[14],
        'creadoPor': r[15],
        'creadoEn': (r[16] as DateTime).toIso8601String(),
        'actualizadoEn': (r[17] as DateTime?)?.toIso8601String(),
      }).toList();

      return Response.ok(jsonEncode(items), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── POST / ── Crear nueva actividad
  router.post('/', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      
      await db.db.execute(
        Sql.named(r'''
          INSERT INTO actividades_municipales (
            id, tipo, estado, titulo, descripcion, 
            fecha_inicio, fecha_fin, participante_ids,
            lat, lng, direccion, sector, direccion_municipal,
            presupuesto_estimado, acta, creado_por
          ) VALUES (
            @id::uuid, @tipo, @estado, @titulo, @descripcion,
            @fechaInicio::timestamptz, @fechaFin::timestamptz, @participanteIds::text[],
            @lat, @lng, @direccion, @sector, @direccionMunicipal,
            @presupuestoEstimado, @acta::jsonb, @creadoPor
          )
        '''),
        parameters: {
          'id': body['id'],
          'tipo': body['tipo'],
          'estado': body['estado'],
          'titulo': body['titulo'],
          'descripcion': body['descripcion'],
          'fechaInicio': body['fechaInicio'],
          'fechaFin': body['fechaFin'],
          'participanteIds': body['participanteIds'] ?? [],
          'lat': body['lat'],
          'lng': body['lng'],
          'direccion': body['direccion'],
          'sector': body['sector'],
          'direccionMunicipal': body['direccionMunicipal'],
          'presupuestoEstimado': body['presupuestoEstimado'],
          'acta': jsonEncode(body['acta'] ?? {}),
          'creadoPor': body['creadoPor'],
        },
      );

      return Response(201, body: jsonEncode({'status': 'ok'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── PUT /<id> ── Actualizar actividad
  router.put('/<id>', (Request req, String id) async {
    try {
      final body = jsonDecode(await req.readAsString());
      
      await db.db.execute(
        Sql.named(r'''
          UPDATE actividades_municipales SET
            tipo = @tipo,
            estado = @estado,
            titulo = @titulo,
            descripcion = @descripcion,
            fecha_inicio = @fechaInicio::timestamptz,
            fecha_fin = @fechaFin::timestamptz,
            participante_ids = @participanteIds::text[],
            lat = @lat,
            lng = @lng,
            direccion = @direccion,
            sector = @sector,
            direccion_municipal = @direccionMunicipal,
            presupuesto_estimado = @presupuestoEstimado,
            acta = @acta::jsonb,
            actualizado_en = NOW()
          WHERE id = @id::uuid
        '''),
        parameters: {
          'id': id,
          'tipo': body['tipo'],
          'estado': body['estado'],
          'titulo': body['titulo'],
          'descripcion': body['descripcion'],
          'fechaInicio': body['fechaInicio'],
          'fechaFin': body['fechaFin'],
          'participanteIds': body['participanteIds'] ?? [],
          'lat': body['lat'],
          'lng': body['lng'],
          'direccion': body['direccion'],
          'sector': body['sector'],
          'direccionMunicipal': body['direccionMunicipal'],
          'presupuestoEstimado': body['presupuestoEstimado'],
          'acta': jsonEncode(body['acta'] ?? {}),
        },
      );

      return Response.ok(jsonEncode({'status': 'updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // ── DELETE /<id> ── Eliminar actividad
  router.delete('/<id>', (Request req, String id) async {
    try {
      await db.db.execute(
        Sql.named('DELETE FROM actividades_municipales WHERE id = @id::uuid'),
        parameters: {'id': id},
      );
      return Response.ok(jsonEncode({'status': 'deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
