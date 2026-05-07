import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';

/// Lógica de negocio para capas personalizadas.
/// Maneja parseo de formatos (GeoJSON, KMZ, SHP) e inserts en geometrias_capa.
class CapasService {
  final DatabaseService db;
  final Uuid _uuid;

  CapasService(this.db) : _uuid = const Uuid();

  // ── Detección de formato ──────────────────────────────────────────────────────

  static String? detectFormato(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.geojson') || lower.endsWith('.json')) return 'geojson';
    if (lower.endsWith('.kmz')) return 'kmz';
    if (lower.endsWith('.zip')) return 'shp';
    return null;
  }

  // ── Inserción por formato ─────────────────────────────────────────────────────

  Future<int> insertByFormat(
    String formato,
    String capaId,
    Uint8List bytes,
    String filename,
  ) {
    switch (formato) {
      case 'geojson':
        return insertGeoJson(capaId, utf8.decode(bytes));
      case 'kmz':
        return insertKmz(capaId, bytes);
      case 'shp':
        return insertShp(capaId, bytes);
      default:
        throw ArgumentError('Formato no soportado: $formato');
    }
  }

  // ── GeoJSON ───────────────────────────────────────────────────────────────────

  Future<int> insertGeoJson(String capaId, String geojsonText) async {
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
          'id': _uuid.v4(),
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

  // ── KMZ ───────────────────────────────────────────────────────────────────────

  Future<int> insertKmz(String capaId, Uint8List kmzBytes) async {
    final archive = ZipDecoder().decodeBytes(kmzBytes);
    final kmlFile = archive.firstWhere(
      (f) => f.isFile && f.name.toLowerCase().endsWith('.kml'),
      orElse: () =>
          throw FormatException('No se encontró archivo .kml dentro del KMZ'),
    );
    final kmlText =
        utf8.decode(kmlFile.content as List<int>, allowMalformed: true);
    return _insertKml(capaId, kmlText);
  }

  Future<int> _insertKml(String capaId, String kmlText) async {
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

      final props = <String, dynamic>{};
      final styleUrl = pm.findElements('styleUrl').firstOrNull?.innerText;
      if (styleUrl != null) props['styleUrl'] = styleUrl;

      final colorEl = pm.findAllElements('color').firstOrNull;
      if (colorEl != null) props['kml_color'] = colorEl.innerText;

      final extData = pm.findElements('ExtendedData').firstOrNull;
      if (extData != null) {
        for (final data in extData.findElements('Data')) {
          final name = data.getAttribute('name');
          final value = data.findElements('value').firstOrNull?.innerText;
          if (name != null && value != null) props[name] = value;
        }
        for (final sData in extData.findElements('SimpleData')) {
          final name = sData.getAttribute('name');
          final value = sData.innerText;
          if (name != null) props[name] = value;
        }
      }

      final propsJson = jsonEncode(props);

      final pointEl = pm.findAllElements('Point').firstOrNull;
      if (pointEl != null) {
        final coords = _parseKmlCoords(
          pointEl.findElements('coordinates').firstOrNull?.innerText ?? '',
        );
        if (coords.isEmpty) continue;
        await db.db.execute(
          Sql.named(r'''
            INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
            VALUES (
              @id::uuid, @capaId::uuid, @nombre, @props::jsonb,
              ST_SetSRID(ST_MakePoint(@lon, @lat), 4326)
            )
          '''),
          parameters: {
            'id': _uuid.v4(),
            'capaId': capaId,
            'nombre': nombre,
            'props': propsJson,
            'lon': coords[0][0],
            'lat': coords[0][1],
          },
        );
        count++;
        continue;
      }

      final lineEl = pm.findAllElements('LineString').firstOrNull;
      if (lineEl != null) {
        final wkt = _kmlCoordsToLineStringWkt(
          lineEl.findElements('coordinates').firstOrNull?.innerText ?? '',
        );
        if (wkt == null) continue;
        await _insertWkt(capaId, nombre, propsJson, wkt);
        count++;
        continue;
      }

      final polyEl = pm.findAllElements('Polygon').firstOrNull;
      if (polyEl != null) {
        final outerEl = polyEl.findAllElements('outerBoundaryIs').firstOrNull;
        final ringEl = outerEl?.findAllElements('LinearRing').firstOrNull;
        final rawCoords =
            ringEl?.findElements('coordinates').firstOrNull?.innerText ?? '';
        final wkt = _kmlCoordsToPolygonWkt(rawCoords);
        if (wkt == null) continue;
        await _insertWkt(capaId, nombre, propsJson, wkt);
        count++;
      }
    }
    return count;
  }

  Future<void> _insertWkt(
    String capaId,
    String? nombre,
    String propsJson,
    String wkt,
  ) async {
    await db.db.execute(
      Sql.named(r'''
        INSERT INTO geometrias_capa (id, capa_id, nombre, propiedades, geom)
        VALUES (
          @id::uuid, @capaId::uuid, @nombre, @props::jsonb,
          ST_SetSRID(ST_GeomFromText(@wkt), 4326)
        )
      '''),
      parameters: {
        'id': _uuid.v4(),
        'capaId': capaId,
        'nombre': nombre,
        'props': propsJson,
        'wkt': wkt,
      },
    );
  }

  // ── SHP ───────────────────────────────────────────────────────────────────────

  Future<int> insertShp(String capaId, Uint8List zipBytes) async {
    final tmpDir = await Directory.systemTemp.createTemp('sigespu_shp_');
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      final extractDir = Directory('${tmpDir.path}/extracted');
      await extractDir.create();
      for (final file in archive.files) {
        if (file.isFile) {
          final outFile = File('${extractDir.path}/${file.name}');
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      final shpEntry = archive.files.firstWhere(
        (f) => f.isFile && f.name.toLowerCase().endsWith('.shp'),
        orElse: () =>
            throw FormatException('No se encontró archivo .shp en el ZIP'),
      );

      final shpPath = '${extractDir.path}/${shpEntry.name}';
      final outputGeojson = '${tmpDir.path}/output.geojson';
      final ogrResult = await Process.run('ogr2ogr', [
        '-f', 'GeoJSON',
        '-t_srs', 'EPSG:4326',
        outputGeojson,
        shpPath,
      ]);

      if (ogrResult.exitCode != 0) {
        throw Exception('ogr2ogr falló: ${ogrResult.stderr}');
      }

      final geojsonText = await File(outputGeojson).readAsString();
      return await insertGeoJson(capaId, geojsonText);
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }

  // ── Helpers KML ───────────────────────────────────────────────────────────────

  static List<List<double>> _parseKmlCoords(String raw) {
    return raw.trim().split(RegExp(r'\s+')).map((token) {
      final parts = token.split(',');
      if (parts.length < 2) return <double>[];
      final lon = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      if (lon == null || lat == null) return <double>[];
      return [lon, lat];
    }).where((c) => c.length == 2).toList();
  }

  static String? _kmlCoordsToLineStringWkt(String raw) {
    final coords = _parseKmlCoords(raw);
    if (coords.length < 2) return null;
    final pts = coords.map((c) => '${c[0]} ${c[1]}').join(', ');
    return 'LINESTRING($pts)';
  }

  static String? _kmlCoordsToPolygonWkt(String raw) {
    final coords = _parseKmlCoords(raw);
    if (coords.length < 3) return null;
    final pts = coords.map((c) => '${c[0]} ${c[1]}').join(', ');
    return 'POLYGON(($pts))';
  }
}
