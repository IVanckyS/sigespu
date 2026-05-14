import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../database/db_pool.dart';
import '../middleware/auth_middleware.dart';
import '../services/capas_service.dart';

Router buildCapasRouter(DatabaseService db) {
  final router = Router();
  final service = CapasService(db);
  const uuid = Uuid();

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // GET / â€” list all capas metadata (any authenticated role)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  router.get('/', (Request req) async {
    try {
      final rows = await db.db.execute(r'''
        SELECT id, nombre, descripcion, color, opacidad, visible, formato,
               subido_por, created_at, categoria, tipo_sistema
        FROM capas_personalizadas
        ORDER BY created_at DESC
      ''');

      final capas = rows.map((r) => {
        'id': r[0].toString(),
        'nombre': r[1],
        'descripcion': r[2],
        'color': r[3],
        'opacidad': r[4],
        'visible': r[5],
        'formato': r[6],
        'subidoPor': r[7]?.toString(),
        'createdAt': (r[8] as DateTime).toIso8601String(),
        'categoria': r[9],
        'tipoSistema': r[10],
      }).toList();

      return Response.ok(
        jsonEncode({'capas': capas, 'total': capas.length}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Error al listar capas: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // GET /<id>/geometrias â€” GeoJSON FeatureCollection for a capa
  // Optional query param: bbox=xmin,ymin,xmax,ymax
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // ── GET /sistema/<tipo> ── GeoJSON unificado de capas base del sistema ────────
  router.get('/sistema/<tipo>', (Request req, String tipo) async {
    const validTipos = ['zona_tsunami', 'zona_incendio_forestal'];
    if (!validTipos.contains(tipo)) {
      return Response(
        400,
        body: jsonEncode({'error': 'tipo_sistema inválido'}),
        headers: {'content-type': 'application/json'},
      );
    }
    try {
      final rows = await db.db.execute(
        Sql.named(r'''
          SELECT gc.id, gc.nombre, gc.propiedades,
                 ST_AsGeoJSON(gc.geom)::text AS geom_json
          FROM geometrias_capa gc
          JOIN capas_personalizadas cp ON cp.id = gc.capa_id
          WHERE cp.tipo_sistema = @tipo
        '''),
        parameters: {'tipo': tipo},
      );

      final features = rows.map((r) {
        final props = (r[2] as Map<String, dynamic>? ?? {});
        props['nombre'] = r[1];
        props['geometria_id'] = r[0].toString();
        return {
          'type': 'Feature',
          'id': r[0].toString(),
          'geometry': jsonDecode(r[3] as String),
          'properties': props,
        };
      }).toList();

      return Response.ok(
        jsonEncode({'type': 'FeatureCollection', 'features': features}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Error al obtener capa sistema: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  router.get('/<id>/geometrias', (Request req, String id) async {
    try {
      final bbox = req.url.queryParameters['bbox'];

      // Verify the capa exists
      final capaRows = await db.db.execute(
        Sql.named(r'''
          SELECT id, nombre, color, opacidad, visible
          FROM capas_personalizadas
          WHERE id = @id
        '''),
        parameters: {'id': id},
      );

      if (capaRows.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Capa no encontrada'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Build query with optional spatial filter
      String query = r'''
        SELECT id, nombre, propiedades,
               ST_AsGeoJSON(geom)::text AS geom_json
        FROM geometrias_capa
        WHERE capa_id = @capaId
      ''';

      final params = <String, dynamic>{'capaId': id};

      if (bbox != null) {
        final parts = bbox.split(',').map(double.tryParse).toList();
        if (parts.length == 4 && parts.every((p) => p != null)) {
          query += r'''
            AND geom && ST_MakeEnvelope(@xmin, @ymin, @xmax, @ymax, 4326)
          ''';
          params['xmin'] = parts[0];
          params['ymin'] = parts[1];
          params['xmax'] = parts[2];
          params['ymax'] = parts[3];
        }
      }

      final rows = await db.db.execute(
        Sql.named(query),
        parameters: params,
      );

      final features = rows.map((r) {
        final props = (r[2] as Map<String, dynamic>? ?? {});
        props['nombre'] = r[1];
        props['geometria_id'] = r[0].toString();
        return {
          'type': 'Feature',
          'id': r[0].toString(),
          'geometry': jsonDecode(r[3] as String),
          'properties': props,
        };
      }).toList();

      return Response.ok(
        jsonEncode({
          'type': 'FeatureCollection',
          'features': features,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Error al obtener geometrÃ­as: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // GET /<id>/export â€” Export as GeoJSON file for download
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  router.get('/<id>/export', (Request req, String id) async {
    try {
      final capaRows = await db.db.execute(
        Sql.named('SELECT nombre FROM capas_personalizadas WHERE id = @id'),
        parameters: {'id': id},
      );

      if (capaRows.isEmpty) return Response.notFound('Capa no encontrada');

      final nombre = capaRows.first[0] as String;
      final fileName = '${nombre.replaceAll(RegExp(r'[^\w]'), '_')}.geojson';

      final rows = await db.db.execute(
        Sql.named(r'''
          SELECT nombre, propiedades, ST_AsGeoJSON(geom)::text 
          FROM geometrias_capa 
          WHERE capa_id = @capaId
        '''),
        parameters: {'capaId': id},
      );

      final features = rows.map((r) => {
            'type': 'Feature',
            'geometry': jsonDecode(r[2] as String),
            'properties': {...(r[1] as Map<String, dynamic>), 'nombre': r[0]},
          }).toList();

      final geojson = jsonEncode({
        'type': 'FeatureCollection',
        'features': features,
      });

      return Response.ok(
        geojson,
        headers: {
          'content-type': 'application/json',
          'content-disposition': 'attachment; filename="$fileName"',
        },
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error al exportar: $e');
    }
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // POST /upload â€” director only
  // Accepts multipart/form-data with fields: nombre, descripcion, color, archivo
  // Supported formats: geojson, kmz, shp (zip)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  router.post(
    '/upload',
    Pipeline()
        .addMiddleware(requireRole(['director']))
        .addHandler((Request req) async {
      try {
        final contentType = req.headers['content-type'] ?? '';
        if (!contentType.contains('multipart/form-data')) {
          return Response(
            400,
            body: jsonEncode({'error': 'Se requiere multipart/form-data'}),
            headers: {'content-type': 'application/json'},
          );
        }

        // Extract boundary from content-type header
        final boundaryMatch =
            RegExp(r'boundary=([^\s;]+)').firstMatch(contentType);
        if (boundaryMatch == null) {
          return Response(
            400,
            body: jsonEncode({'error': 'Boundary no encontrado en Content-Type'}),
            headers: {'content-type': 'application/json'},
          );
        }
        final boundary = boundaryMatch.group(1)!;

        final bodyBytes = await req.read().expand((chunk) => chunk).toList();
        final parsed = _parseMultipart(Uint8List.fromList(bodyBytes), boundary);

        final nombre = parsed['nombre'];
        final descripcion = parsed['descripcion'] ?? '';
        final color = parsed['color'] ?? '#FF5722';
        final categoria = parsed['categoria'] ?? 'Personalizadas';
        final tipoSistemaRaw = parsed['tipo_sistema']?.toString();
        final tipoSistema = (tipoSistemaRaw == null || tipoSistemaRaw.isEmpty)
            ? null
            : tipoSistemaRaw;
        const validTipos = ['zona_tsunami', 'zona_incendio_forestal'];
        if (tipoSistema != null && !validTipos.contains(tipoSistema)) {
          return Response(
            400,
            body: jsonEncode({'error': 'tipo_sistema inválido'}),
            headers: {'content-type': 'application/json'},
          );
        }
        final archivoBytes = parsed['archivo_bytes'] as Uint8List?;
        final archivoNombre = parsed['archivo_nombre'] as String? ?? '';

        if (nombre == null || nombre.isEmpty) {
          return Response(
            400,
            body: jsonEncode({'error': 'El campo nombre es obligatorio'}),
            headers: {'content-type': 'application/json'},
          );
        }
        if (archivoBytes == null) {
          return Response(
            400,
            body: jsonEncode({'error': 'El campo archivo es obligatorio'}),
            headers: {'content-type': 'application/json'},
          );
        }

        // Determine format from filename
        final formato = CapasService.detectFormato(archivoNombre);
        if (formato == null) {
          return Response(
            400,
            body: jsonEncode({
              'error': 'Formato no soportado. Use .geojson, .kmz o .zip (shapefile)'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final userId = req.context['user_id'] as String?;
        final capaId = uuid.v4();

        // Insert the capa metadata
        await db.db.execute(
          Sql.named(r'''
            INSERT INTO capas_personalizadas
              (id, nombre, descripcion, color, opacidad, visible, formato,
               subido_por, categoria, tipo_sistema)
            VALUES
              (@id, @nombre, @descripcion, @color, 0.7, true, @formato,
               @subidoPor::uuid, @categoria, @tipoSistema)
          '''),
          parameters: {
            'id': capaId,
            'nombre': nombre,
            'descripcion': descripcion,
            'color': color,
            'formato': formato,
            'subidoPor': userId,
            'categoria': categoria,
            'tipoSistema': tipoSistema,
          },
        );

        // Parse and insert geometries via service
        final geomCount = await service.insertByFormat(
          formato, capaId, archivoBytes, archivoNombre,
        );

        return Response(
          201,
          body: jsonEncode({
            'id': capaId,
            'nombre': nombre,
            'formato': formato,
            'totalGeometrias': geomCount,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error al procesar upload: $e'}),
          headers: {'content-type': 'application/json'},
        );
      }
    }),
  );

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // PATCH /<id> â€” director only (update nombre, descripcion, color, opacidad, visible)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  router.patch(
    '/<id>',
    Pipeline()
        .addMiddleware(requireRole(['director']))
        .addHandler((Request req) async {
      // Extract id from URL â€” shelf_router does not pass params to inner Pipeline handlers
      final segments = req.url.pathSegments;
      final id = segments.isNotEmpty ? segments.last : null;

      if (id == null || id.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'ID invÃ¡lido'}),
          headers: {'content-type': 'application/json'},
        );
      }

      try {
        final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;

        // Build dynamic SET clause from provided fields
        final allowed = ['nombre', 'descripcion', 'color', 'opacidad', 'visible', 'categoria'];
        final setClauses = <String>[];
        final params = <String, dynamic>{'id': id};

        for (final field in allowed) {
          if (body.containsKey(field)) {
            setClauses.add('$field = @$field');
            params[field] = body[field];
          }
        }

        if (setClauses.isEmpty) {
          return Response(
            400,
            body: jsonEncode({'error': 'No hay campos vÃ¡lidos para actualizar'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final setClause = setClauses.join(', ');
        final result = await db.db.execute(
          Sql.named('UPDATE capas_personalizadas SET $setClause WHERE id = @id::uuid RETURNING id'),
          parameters: params,
        );

        if (result.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Capa no encontrada'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({'id': id, 'updated': true}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error al actualizar capa: $e'}),
          headers: {'content-type': 'application/json'},
        );
      }
    }),
  );

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // DELETE /<id> â€” director only
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  router.delete(
    '/<id>',
    Pipeline()
        .addMiddleware(requireRole(['director']))
        .addHandler((Request req) async {
      // Extract id from URL â€” shelf_router does not pass params to inner Pipeline handlers
      final segments = req.url.pathSegments;
      final id = segments.isNotEmpty ? segments.last : null;

      if (id == null || id.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'ID invÃ¡lido'}),
          headers: {'content-type': 'application/json'},
        );
      }

      try {
        final result = await db.db.execute(
          Sql.named(
            'DELETE FROM capas_personalizadas WHERE id = @id::uuid RETURNING id',
          ),
          parameters: {'id': id},
        );

        if (result.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Capa no encontrada'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({'id': id, 'deleted': true}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error al eliminar capa: $e'}),
          headers: {'content-type': 'application/json'},
        );
      }
    }),
  );

  return router;
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Multipart parser (HTTP layer â€” permanece en el route)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Minimal multipart/form-data parser that handles both text fields and a
/// single binary file part.  Returns a flat map where text fields are stored
/// as [String] values, and the binary file is stored under the keys
/// 'archivo_bytes' ([Uint8List]) and 'archivo_nombre' ([String]).
Map<String, dynamic> _parseMultipart(Uint8List body, String boundary) {
  final result = <String, dynamic>{};
  final delimBytes = utf8.encode('--$boundary');

  // Split body on boundary markers
  final parts = _splitBytes(body, delimBytes);

  for (final part in parts) {
    // Each part: \r\n<headers>\r\n\r\n<body>\r\n
    // Skip empty or terminal parts
    if (part.length < 4) continue;

    // Find the double CRLF that separates headers from body
    final headerEnd = _indexOfSeq(part, [13, 10, 13, 10]);
    if (headerEnd < 0) continue;

    final headerSection = utf8.decode(
      part.sublist(0, headerEnd),
      allowMalformed: true,
    );
    // Body starts after \r\n\r\n, ends before trailing \r\n
    var partBody = part.sublist(headerEnd + 4);
    // Strip trailing \r\n if present
    if (partBody.length >= 2 &&
        partBody[partBody.length - 2] == 13 &&
        partBody[partBody.length - 1] == 10) {
      partBody = partBody.sublist(0, partBody.length - 2);
    }

    // Parse Content-Disposition header
    final dispositionMatch = RegExp(
      r'Content-Disposition:\s*form-data;([^\r\n]*)',
      caseSensitive: false,
    ).firstMatch(headerSection);
    if (dispositionMatch == null) continue;

    final dispositionParams = dispositionMatch.group(1)!;
    final nameMatch = RegExp(r'name="([^"]*)"').firstMatch(dispositionParams);
    if (nameMatch == null) continue;
    final fieldName = nameMatch.group(1)!;

    final filenameMatch =
        RegExp(r'filename="([^"]*)"').firstMatch(dispositionParams);

    if (filenameMatch != null) {
      // File part
      result['archivo_bytes'] = Uint8List.fromList(partBody);
      result['archivo_nombre'] = filenameMatch.group(1)!;
    } else {
      // Text field
      result[fieldName] = utf8.decode(partBody, allowMalformed: true);
    }
  }

  return result;
}

/// Splits [data] on each occurrence of [delimiter], returning the segments
/// between delimiters (not including the delimiter itself).
List<Uint8List> _splitBytes(Uint8List data, List<int> delimiter) {
  final parts = <Uint8List>[];
  int start = 0;

  while (start < data.length) {
    final idx = _indexOfSeq(data, delimiter, start);
    if (idx < 0) {
      parts.add(data.sublist(start));
      break;
    }
    parts.add(data.sublist(start, idx));
    start = idx + delimiter.length;
  }

  return parts;
}

/// Returns the index of the first occurrence of [seq] in [data] starting at
/// [offset], or -1 if not found.
int _indexOfSeq(List<int> data, List<int> seq, [int offset = 0]) {
  final limit = data.length - seq.length;
  outer:
  for (int i = offset; i <= limit; i++) {
    for (int j = 0; j < seq.length; j++) {
      if (data[i + j] != seq[j]) continue outer;
    }
    return i;
  }
  return -1;
}
