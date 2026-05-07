import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:uuid/uuid.dart';
import '../database/db_pool.dart';
import '../middleware/auth_middleware.dart';

Router buildCapasRouter(DatabaseService db) {
  final router = Router();
  const uuid = Uuid();

  // ─────────────────────────────────────────────────────────────────────────────
  // GET / — list all capas metadata (any authenticated role)
  // ─────────────────────────────────────────────────────────────────────────────
  router.get('/', (Request req) async {
    try {
      final rows = await db.db.execute(r'''
        SELECT id, nombre, descripcion, color, opacidad, visible, formato,
               subido_por, created_at
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

  // ─────────────────────────────────────────────────────────────────────────────
  // GET /<id>/geometrias — GeoJSON FeatureCollection for a capa
  // ─────────────────────────────────────────────────────────────────────────────
  router.get('/<id>/geometrias', (Request req, String id) async {
    try {
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

      // Fetch geometries as GeoJSON features
      final rows = await db.db.execute(
        Sql.named(r'''
          SELECT id, nombre, propiedades,
                 ST_AsGeoJSON(geom)::text AS geom_json
          FROM geometrias_capa
          WHERE capa_id = @capaId
        '''),
        parameters: {'capaId': id},
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
        body: jsonEncode({'error': 'Error al obtener geometrías: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // POST /upload — director only
  // Accepts multipart/form-data with fields: nombre, descripcion, color, archivo
  // Supported formats: geojson, kmz, shp (zip)
  // ─────────────────────────────────────────────────────────────────────────────
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
        final formato = _detectFormato(archivoNombre);
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
              (id, nombre, descripcion, color, opacidad, visible, formato, subido_por)
            VALUES
              (@id, @nombre, @descripcion, @color, 0.7, true, @formato, @subidoPor::uuid)
          '''),
          parameters: {
            'id': capaId,
            'nombre': nombre,
            'descripcion': descripcion,
            'color': color,
            'formato': formato,
            'subidoPor': userId,
          },
        );

        // Parse and insert geometries based on format
        int geomCount = 0;
        switch (formato) {
          case 'geojson':
            geomCount =
                await _insertGeoJson(db, uuid, capaId, utf8.decode(archivoBytes));
            break;
          case 'kmz':
            geomCount = await _insertKmz(db, uuid, capaId, archivoBytes);
            break;
          case 'shp':
            geomCount = await _insertShp(db, uuid, capaId, archivoBytes);
            break;
        }

        return Response(
          201,
          body: jsonEncode({
            'id': capaId,
            'nombre': nombre,
            'formato': formato,
            'geometriasInsertadas': geomCount,
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

  // ─────────────────────────────────────────────────────────────────────────────
  // PATCH /<id> — director only (update nombre, descripcion, color, opacidad, visible)
  // ─────────────────────────────────────────────────────────────────────────────
  router.patch(
    '/<id>',
    Pipeline()
        .addMiddleware(requireRole(['director']))
        .addHandler((Request req) async {
      // Extract id from URL — shelf_router does not pass params to inner Pipeline handlers
      final segments = req.url.pathSegments;
      final id = segments.isNotEmpty ? segments.last : null;

      if (id == null || id.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'ID inválido'}),
          headers: {'content-type': 'application/json'},
        );
      }

      try {
        final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;

        // Build dynamic SET clause from provided fields
        final allowed = ['nombre', 'descripcion', 'color', 'opacidad', 'visible'];
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
            body: jsonEncode({'error': 'No hay campos válidos para actualizar'}),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // DELETE /<id> — director only
  // ─────────────────────────────────────────────────────────────────────────────
  router.delete(
    '/<id>',
    Pipeline()
        .addMiddleware(requireRole(['director']))
        .addHandler((Request req) async {
      // Extract id from URL — shelf_router does not pass params to inner Pipeline handlers
      final segments = req.url.pathSegments;
      final id = segments.isNotEmpty ? segments.last : null;

      if (id == null || id.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'ID inválido'}),
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

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Detects the upload format from the file name extension.
String? _detectFormato(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.geojson') || lower.endsWith('.json')) return 'geojson';
  if (lower.endsWith('.kmz')) return 'kmz';
  if (lower.endsWith('.zip')) return 'shp'; // assume shapefile zip
  return null;
}

/// Minimal multipart/form-data parser that handles both text fields and a
/// single binary file part.  Returns a flat map where text fields are stored
/// as [String] values, and the binary file is stored under the keys
/// 'archivo_bytes' ([Uint8List]) and 'archivo_nombre' ([String]).
Map<String, dynamic> _parseMultipart(Uint8List body, String boundary) {
  final result = <String, dynamic>{};
  final delimBytes = utf8.encode('--$boundary');
  final crlf = [13, 10]; // \r\n

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

// ─────────────────────────────────────────────────────────────────────────────
// Format-specific geometry inserters
// ─────────────────────────────────────────────────────────────────────────────

/// Parses a GeoJSON FeatureCollection (or plain Feature/Geometry) and inserts
/// its geometries into [geometrias_capa].  Returns the count inserted.
Future<int> _insertGeoJson(
  DatabaseService db,
  Uuid uuid,
  String capaId,
  String geojsonText,
) async {
  final Map<String, dynamic> parsed;
  try {
    parsed = jsonDecode(geojsonText) as Map<String, dynamic>;
  } catch (_) {
    throw FormatException('El archivo no es JSON válido');
  }

  final features = <Map<String, dynamic>>[];
  final type = parsed['type'] as String?;

  if (type == 'FeatureCollection') {
    for (final f in (parsed['features'] as List)) {
      features.add(f as Map<String, dynamic>);
    }
  } else if (type == 'Feature') {
    features.add(parsed);
  } else if (type != null) {
    // Plain geometry — wrap in a Feature
    features.add({'type': 'Feature', 'geometry': parsed, 'properties': {}});
  }

  int count = 0;
  for (final feature in features) {
    final geom = feature['geometry'];
    if (geom == null) continue;
    final props = (feature['properties'] as Map<String, dynamic>?) ?? {};
    final nombre = props['name'] as String? ??
        props['nombre'] as String? ??
        props['Name'] as String?;

    await db.db.execute(
      Sql.named(r'''
        INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
        VALUES (
          @id::uuid, @capaId::uuid, @nombre,
          @props::jsonb,
          ST_SetSRID(ST_GeomFromGeoJSON(@geomJson), 4326)
        )
      '''),
      parameters: {
        'id': uuid.v4(),
        'capaId': capaId,
        'nombre': nombre,
        'props': jsonEncode(props),
        'geomJson': jsonEncode(geom),
      },
    );
    count++;
  }
  return count;
}

/// Extracts KML from a KMZ (zipped KML) archive and inserts its Placemark
/// geometries into [geometrias_capa].  Returns the count inserted.
Future<int> _insertKmz(
  DatabaseService db,
  Uuid uuid,
  String capaId,
  Uint8List kmzBytes,
) async {
  final archive = ZipDecoder().decodeBytes(kmzBytes);
  // Find the main KML file (usually doc.kml)
  final kmlFile = archive.firstWhere(
    (f) => f.isFile && f.name.toLowerCase().endsWith('.kml'),
    orElse: () => throw FormatException('No se encontró archivo .kml dentro del KMZ'),
  );

  final kmlText = utf8.decode(kmlFile.content as List<int>, allowMalformed: true);
  return await _insertKml(db, uuid, capaId, kmlText);
}

/// Parses a KML string and inserts Point/LineString/Polygon Placemarks into
/// [geometrias_capa].  Returns the count inserted.
Future<int> _insertKml(
  DatabaseService db,
  Uuid uuid,
  String capaId,
  String kmlText,
) async {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(kmlText);
  } catch (_) {
    throw FormatException('KML inválido o malformado');
  }

  final placemarks = doc.findAllElements('Placemark');
  int count = 0;

  for (final pm in placemarks) {
    final nombre = pm.findElements('name').firstOrNull?.innerText;

    // Try Point
    final pointEl = pm.findAllElements('Point').firstOrNull;
    if (pointEl != null) {
      final coords = _parseKmlCoords(
        pointEl.findElements('coordinates').firstOrNull?.innerText ?? '',
      );
      if (coords.isEmpty) continue;
      final lon = coords[0][0];
      final lat = coords[0][1];

      await db.db.execute(
        Sql.named(r'''
          INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
          VALUES (
            @id::uuid, @capaId::uuid, @nombre, '{}'::jsonb,
            ST_SetSRID(ST_MakePoint(@lon, @lat), 4326)
          )
        '''),
        parameters: {
          'id': uuid.v4(),
          'capaId': capaId,
          'nombre': nombre,
          'lon': lon,
          'lat': lat,
        },
      );
      count++;
      continue;
    }

    // Try LineString
    final lineEl = pm.findAllElements('LineString').firstOrNull;
    if (lineEl != null) {
      final rawCoords =
          lineEl.findElements('coordinates').firstOrNull?.innerText ?? '';
      final wkt = _kmlCoordsToLineStringWkt(rawCoords);
      if (wkt == null) continue;

      await db.db.execute(
        Sql.named(r'''
          INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
          VALUES (
            @id::uuid, @capaId::uuid, @nombre, '{}'::jsonb,
            ST_SetSRID(ST_GeomFromText(@wkt), 4326)
          )
        '''),
        parameters: {
          'id': uuid.v4(),
          'capaId': capaId,
          'nombre': nombre,
          'wkt': wkt,
        },
      );
      count++;
      continue;
    }

    // Try Polygon
    final polyEl = pm.findAllElements('Polygon').firstOrNull;
    if (polyEl != null) {
      final outerEl = polyEl.findAllElements('outerBoundaryIs').firstOrNull;
      final ringEl = outerEl?.findAllElements('LinearRing').firstOrNull;
      final rawCoords = ringEl?.findElements('coordinates').firstOrNull?.innerText ?? '';
      final wkt = _kmlCoordsToPolygonWkt(rawCoords);
      if (wkt == null) continue;

      await db.db.execute(
        Sql.named(r'''
          INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
          VALUES (
            @id::uuid, @capaId::uuid, @nombre, '{}'::jsonb,
            ST_SetSRID(ST_GeomFromText(@wkt), 4326)
          )
        '''),
        parameters: {
          'id': uuid.v4(),
          'capaId': capaId,
          'nombre': nombre,
          'wkt': wkt,
        },
      );
      count++;
    }
  }

  return count;
}

/// Uploads a shapefile ZIP to a temp directory and runs ogr2ogr to convert it
/// to GeoJSON, then delegates to [_insertGeoJson].
///
/// Requires `ogr2ogr` (gdal-bin) to be installed in the Docker container.
Future<int> _insertShp(
  DatabaseService db,
  Uuid uuid,
  String capaId,
  Uint8List zipBytes,
) async {
  final tmpDir = await Directory.systemTemp.createTemp('sigespu_shp_');
  try {
    // Write the zip to disk
    final zipFile = File('${tmpDir.path}/upload.zip');
    await zipFile.writeAsBytes(zipBytes);

    // Extract the zip
    final extractDir = Directory('${tmpDir.path}/extracted');
    await extractDir.create();
    final result = await Process.run('unzip', ['-q', zipFile.path, '-d', extractDir.path]);
    if (result.exitCode != 0) {
      throw Exception('No se pudo descomprimir el shapefile: ${result.stderr}');
    }

    // Find the .shp file
    final shpFiles = extractDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.shp'))
        .toList();

    if (shpFiles.isEmpty) {
      throw FormatException('No se encontró archivo .shp en el ZIP');
    }

    // Convert to GeoJSON using ogr2ogr
    final outputGeojson = '${tmpDir.path}/output.geojson';
    final ogrResult = await Process.run('ogr2ogr', [
      '-f', 'GeoJSON',
      '-t_srs', 'EPSG:4326',
      outputGeojson,
      shpFiles.first.path,
    ]);

    if (ogrResult.exitCode != 0) {
      throw Exception('ogr2ogr falló: ${ogrResult.stderr}');
    }

    final geojsonText = await File(outputGeojson).readAsString();
    return await _insertGeoJson(db, uuid, capaId, geojsonText);
  } finally {
    // Clean up temp files regardless of success/failure
    await tmpDir.delete(recursive: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KML coordinate helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Parses a KML coordinates string ("lon,lat,alt lon,lat,alt ...") into a list
/// of [lon, lat] pairs.
List<List<double>> _parseKmlCoords(String raw) {
  final result = <List<double>>[];
  for (final token in raw.trim().split(RegExp(r'\s+'))) {
    if (token.isEmpty) continue;
    final parts = token.split(',');
    if (parts.length < 2) continue;
    final lon = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lon != null && lat != null) result.add([lon, lat]);
  }
  return result;
}

String? _kmlCoordsToLineStringWkt(String raw) {
  final coords = _parseKmlCoords(raw);
  if (coords.length < 2) return null;
  final pts = coords.map((c) => '${c[0]} ${c[1]}').join(', ');
  return 'LINESTRING($pts)';
}

String? _kmlCoordsToPolygonWkt(String raw) {
  final coords = _parseKmlCoords(raw);
  if (coords.length < 3) return null;
  // Ensure ring is closed
  final ring = [...coords];
  if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
    ring.add(ring.first);
  }
  final pts = ring.map((c) => '${c[0]} ${c[1]}').join(', ');
  return 'POLYGON(($pts))';
}
