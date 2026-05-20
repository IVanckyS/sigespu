import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../http/responses.dart';
import '../http/validators.dart';

const _tiposActividad = {'reunion', 'operativo', 'evento', 'capacitacion'};
const _estadosActividad = {'planificado', 'enCurso', 'completado', 'archivado'};

Router buildActividadesRouter(DatabaseService db) {
  final router = Router();

  // ── GET / ── Listar todas las actividades
  router.get('/', (Request req) => guard('listActividades', () async {
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

    return ok(items);
  }));

  // ── POST / ── Crear nueva actividad
  router.post('/', (Request req) => guard('createActividad', () async {
    final body = await readJsonObject(req);

    final id = requireString(body, 'id', maxLen: 64);
    final tipo = requireEnum(body, 'tipo', _tiposActividad);
    final estado = requireEnum(body, 'estado', _estadosActividad);
    final titulo = requireString(body, 'titulo', maxLen: 300);
    final descripcion = optionalString(body, 'descripcion', maxLen: 5000);
    final fechaInicio = requireString(body, 'fechaInicio', maxLen: 40);
    final fechaFin = optionalString(body, 'fechaFin', maxLen: 40);

    // Si hay ambas fechas, valida orden lógico.
    if (fechaFin != null) {
      final ini = DateTime.tryParse(fechaInicio);
      final fin = DateTime.tryParse(fechaFin);
      if (ini == null || fin == null) {
        return badRequest('Fechas con formato inválido (usa ISO-8601)');
      }
      if (fin.isBefore(ini)) {
        return badRequest('fechaFin no puede ser anterior a fechaInicio');
      }
    }

    final lat = optionalDouble(body, 'lat', min: -90, max: 90);
    final lng = optionalDouble(body, 'lng', min: -180, max: 180);
    final presupuesto =
        optionalDouble(body, 'presupuestoEstimado', min: 0, max: 1e12);

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
        'id': id,
        'tipo': tipo,
        'estado': estado,
        'titulo': titulo,
        'descripcion': descripcion,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'participanteIds': body['participanteIds'] ?? [],
        'lat': lat,
        'lng': lng,
        'direccion': optionalString(body, 'direccion', maxLen: 300),
        'sector': optionalString(body, 'sector', maxLen: 100),
        'direccionMunicipal':
            optionalString(body, 'direccionMunicipal', maxLen: 200),
        'presupuestoEstimado': presupuesto,
        'acta': jsonEncode(body['acta'] ?? {}),
        'creadoPor': optionalString(body, 'creadoPor', maxLen: 100),
      },
    );

    return created({'status': 'ok', 'id': id});
  }));

  // ── PUT /<id> ── Actualizar actividad (con conflict detection opcional)
  router.put('/<id>', (Request req, String id) => guard('updateActividad', () async {
    final body = await readJsonObject(req);

    final tipo = requireEnum(body, 'tipo', _tiposActividad);
    final estado = requireEnum(body, 'estado', _estadosActividad);
    final titulo = requireString(body, 'titulo', maxLen: 300);
    final fechaInicio = requireString(body, 'fechaInicio', maxLen: 40);
    final fechaFin = optionalString(body, 'fechaFin', maxLen: 40);
    final clientUpdatedAt = optionalString(body, 'client_updated_at', maxLen: 40);

    if (fechaFin != null) {
      final ini = DateTime.tryParse(fechaInicio);
      final fin = DateTime.tryParse(fechaFin);
      if (ini == null || fin == null) {
        return badRequest('Fechas con formato inválido (usa ISO-8601)');
      }
      if (fin.isBefore(ini)) {
        return badRequest('fechaFin no puede ser anterior a fechaInicio');
      }
    }

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
            AND (
              @clientTs::timestamptz IS NULL
              OR actualizado_en IS NULL
              OR actualizado_en <= @clientTs::timestamptz
            )
          RETURNING id
        '''),
        parameters: {
          'id': id,
          'tipo': tipo,
          'estado': estado,
          'titulo': titulo,
          'descripcion': optionalString(body, 'descripcion', maxLen: 5000),
          'fechaInicio': fechaInicio,
          'fechaFin': fechaFin,
          'participanteIds': body['participanteIds'] ?? [],
          'lat': optionalDouble(body, 'lat', min: -90, max: 90),
          'lng': optionalDouble(body, 'lng', min: -180, max: 180),
          'direccion': optionalString(body, 'direccion', maxLen: 300),
          'sector': optionalString(body, 'sector', maxLen: 100),
          'direccionMunicipal':
              optionalString(body, 'direccionMunicipal', maxLen: 200),
          'presupuestoEstimado':
              optionalDouble(body, 'presupuestoEstimado', min: 0, max: 1e12),
          'acta': jsonEncode(body['acta'] ?? {}),
          'clientTs': clientTs?.toUtc().toIso8601String(),
        },
      );

      if (result.isNotEmpty) return ok({'status': 'updated'});

      final current = await tx.execute(
        Sql.named(r'''
          SELECT id, tipo, estado, titulo, descripcion,
                 fecha_inicio, fecha_fin, lat, lng,
                 direccion, sector, direccion_municipal,
                 presupuesto_estimado, actualizado_en, creado_en
          FROM actividades_municipales WHERE id = @id::uuid
        '''),
        parameters: {'id': id},
      );
      if (current.isEmpty) return notFound('Actividad no encontrada');

      final row = current.first;
      return conflict('La actividad fue modificada por otra sesión más recientemente').change(
        body: jsonEncode({
          'error': 'CONFLICT',
          'message': 'La actividad fue modificada por otra sesión más recientemente',
          'server_state': {
            'id': row[0].toString(),
            'tipo': row[1],
            'estado': row[2],
            'titulo': row[3],
            'descripcion': row[4],
            'fechaInicio': (row[5] as DateTime).toIso8601String(),
            'fechaFin': (row[6] as DateTime?)?.toIso8601String(),
            'lat': row[7],
            'lng': row[8],
            'direccion': row[9],
            'sector': row[10],
            'direccionMunicipal': row[11],
            'presupuestoEstimado': row[12],
            'actualizado_en': (row[13] as DateTime?)?.toIso8601String(),
            'creado_en': (row[14] as DateTime).toIso8601String(),
          },
        }),
      );
    });
  }));

  // ── DELETE /<id> ── Eliminar actividad
  router.delete('/<id>', (Request req, String id) => guard('deleteActividad', () async {
    final result = await db.db.execute(
      Sql.named(
          'DELETE FROM actividades_municipales WHERE id = @id::uuid RETURNING id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return notFound('Actividad no encontrada');
    return ok({'status': 'deleted'});
  }));

  return router;
}
