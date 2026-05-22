// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PuntosInteresTableTable extends PuntosInteresTable
    with TableInfo<$PuntosInteresTableTable, PuntoInteresLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuntosInteresTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('activo'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tipo, nombre, descripcion, direccion, lat, lng, estado, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puntos_interes_table';
  @override
  VerificationContext validateIntegrity(Insertable<PuntoInteresLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PuntoInteresLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuntoInteresLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre']),
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $PuntosInteresTableTable createAlias(String alias) {
    return $PuntosInteresTableTable(attachedDatabase, alias);
  }
}

class PuntoInteresLocal extends DataClass
    implements Insertable<PuntoInteresLocal> {
  final String id;
  final String tipo;
  final String? nombre;
  final String? descripcion;
  final String? direccion;
  final double lat;
  final double lng;
  final String estado;
  final DateTime? updatedAt;
  const PuntoInteresLocal(
      {required this.id,
      required this.tipo,
      this.nombre,
      this.descripcion,
      this.direccion,
      required this.lat,
      required this.lng,
      required this.estado,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  PuntosInteresTableCompanion toCompanion(bool nullToAbsent) {
    return PuntosInteresTableCompanion(
      id: Value(id),
      tipo: Value(tipo),
      nombre:
          nombre == null && nullToAbsent ? const Value.absent() : Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      lat: Value(lat),
      lng: Value(lng),
      estado: Value(estado),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory PuntoInteresLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuntoInteresLocal(
      id: serializer.fromJson<String>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      estado: serializer.fromJson<String>(json['estado']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipo': serializer.toJson<String>(tipo),
      'nombre': serializer.toJson<String?>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'direccion': serializer.toJson<String?>(direccion),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'estado': serializer.toJson<String>(estado),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  PuntoInteresLocal copyWith(
          {String? id,
          String? tipo,
          Value<String?> nombre = const Value.absent(),
          Value<String?> descripcion = const Value.absent(),
          Value<String?> direccion = const Value.absent(),
          double? lat,
          double? lng,
          String? estado,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      PuntoInteresLocal(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        nombre: nombre.present ? nombre.value : this.nombre,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        direccion: direccion.present ? direccion.value : this.direccion,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        estado: estado ?? this.estado,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  PuntoInteresLocal copyWithCompanion(PuntosInteresTableCompanion data) {
    return PuntoInteresLocal(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      estado: data.estado.present ? data.estado.value : this.estado,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuntoInteresLocal(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('direccion: $direccion, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, tipo, nombre, descripcion, direccion, lat, lng, estado, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuntoInteresLocal &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.direccion == this.direccion &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.estado == this.estado &&
          other.updatedAt == this.updatedAt);
}

class PuntosInteresTableCompanion extends UpdateCompanion<PuntoInteresLocal> {
  final Value<String> id;
  final Value<String> tipo;
  final Value<String?> nombre;
  final Value<String?> descripcion;
  final Value<String?> direccion;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> estado;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const PuntosInteresTableCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.direccion = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PuntosInteresTableCompanion.insert({
    required String id,
    required String tipo,
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.direccion = const Value.absent(),
    required double lat,
    required double lng,
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tipo = Value(tipo),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<PuntoInteresLocal> custom({
    Expression<String>? id,
    Expression<String>? tipo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<String>? direccion,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? estado,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (direccion != null) 'direccion': direccion,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (estado != null) 'estado': estado,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PuntosInteresTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tipo,
      Value<String?>? nombre,
      Value<String?>? descripcion,
      Value<String?>? direccion,
      Value<double>? lat,
      Value<double>? lng,
      Value<String>? estado,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return PuntosInteresTableCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      estado: estado ?? this.estado,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuntosInteresTableCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('direccion: $direccion, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZonasPeligroTableTable extends ZonasPeligroTable
    with TableInfo<$ZonasPeligroTableTable, ZonaPeligroLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonasPeligroTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _polygonCoordsJsonMeta =
      const VerificationMeta('polygonCoordsJson');
  @override
  late final GeneratedColumn<String> polygonCoordsJson =
      GeneratedColumn<String>('polygon_coords_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nivelRiesgoMeta =
      const VerificationMeta('nivelRiesgo');
  @override
  late final GeneratedColumn<int> nivelRiesgo = GeneratedColumn<int>(
      'nivel_riesgo', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tipoRiesgoMeta =
      const VerificationMeta('tipoRiesgo');
  @override
  late final GeneratedColumn<String> tipoRiesgo = GeneratedColumn<String>(
      'tipo_riesgo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _horarioCriticoMeta =
      const VerificationMeta('horarioCritico');
  @override
  late final GeneratedColumn<String> horarioCritico = GeneratedColumn<String>(
      'horario_critico', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vigenteDesdeMeta =
      const VerificationMeta('vigenteDesde');
  @override
  late final GeneratedColumn<DateTime> vigenteDesde = GeneratedColumn<DateTime>(
      'vigente_desde', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _vigenteHastaMeta =
      const VerificationMeta('vigenteHasta');
  @override
  late final GeneratedColumn<DateTime> vigenteHasta = GeneratedColumn<DateTime>(
      'vigente_hasta', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombre,
        polygonCoordsJson,
        nivelRiesgo,
        tipoRiesgo,
        descripcion,
        horarioCritico,
        vigenteDesde,
        vigenteHasta,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zonas_peligro_table';
  @override
  VerificationContext validateIntegrity(Insertable<ZonaPeligroLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    }
    if (data.containsKey('polygon_coords_json')) {
      context.handle(
          _polygonCoordsJsonMeta,
          polygonCoordsJson.isAcceptableOrUnknown(
              data['polygon_coords_json']!, _polygonCoordsJsonMeta));
    } else if (isInserting) {
      context.missing(_polygonCoordsJsonMeta);
    }
    if (data.containsKey('nivel_riesgo')) {
      context.handle(
          _nivelRiesgoMeta,
          nivelRiesgo.isAcceptableOrUnknown(
              data['nivel_riesgo']!, _nivelRiesgoMeta));
    }
    if (data.containsKey('tipo_riesgo')) {
      context.handle(
          _tipoRiesgoMeta,
          tipoRiesgo.isAcceptableOrUnknown(
              data['tipo_riesgo']!, _tipoRiesgoMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('horario_critico')) {
      context.handle(
          _horarioCriticoMeta,
          horarioCritico.isAcceptableOrUnknown(
              data['horario_critico']!, _horarioCriticoMeta));
    }
    if (data.containsKey('vigente_desde')) {
      context.handle(
          _vigenteDesdeMeta,
          vigenteDesde.isAcceptableOrUnknown(
              data['vigente_desde']!, _vigenteDesdeMeta));
    }
    if (data.containsKey('vigente_hasta')) {
      context.handle(
          _vigenteHastaMeta,
          vigenteHasta.isAcceptableOrUnknown(
              data['vigente_hasta']!, _vigenteHastaMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZonaPeligroLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZonaPeligroLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre']),
      polygonCoordsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}polygon_coords_json'])!,
      nivelRiesgo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nivel_riesgo']),
      tipoRiesgo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_riesgo']),
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      horarioCritico: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}horario_critico']),
      vigenteDesde: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}vigente_desde']),
      vigenteHasta: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}vigente_hasta']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ZonasPeligroTableTable createAlias(String alias) {
    return $ZonasPeligroTableTable(attachedDatabase, alias);
  }
}

class ZonaPeligroLocal extends DataClass
    implements Insertable<ZonaPeligroLocal> {
  final String id;
  final String? nombre;
  final String polygonCoordsJson;
  final int? nivelRiesgo;
  final String? tipoRiesgo;
  final String? descripcion;
  final String? horarioCritico;
  final DateTime? vigenteDesde;
  final DateTime? vigenteHasta;
  final DateTime? updatedAt;
  const ZonaPeligroLocal(
      {required this.id,
      this.nombre,
      required this.polygonCoordsJson,
      this.nivelRiesgo,
      this.tipoRiesgo,
      this.descripcion,
      this.horarioCritico,
      this.vigenteDesde,
      this.vigenteHasta,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    map['polygon_coords_json'] = Variable<String>(polygonCoordsJson);
    if (!nullToAbsent || nivelRiesgo != null) {
      map['nivel_riesgo'] = Variable<int>(nivelRiesgo);
    }
    if (!nullToAbsent || tipoRiesgo != null) {
      map['tipo_riesgo'] = Variable<String>(tipoRiesgo);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || horarioCritico != null) {
      map['horario_critico'] = Variable<String>(horarioCritico);
    }
    if (!nullToAbsent || vigenteDesde != null) {
      map['vigente_desde'] = Variable<DateTime>(vigenteDesde);
    }
    if (!nullToAbsent || vigenteHasta != null) {
      map['vigente_hasta'] = Variable<DateTime>(vigenteHasta);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ZonasPeligroTableCompanion toCompanion(bool nullToAbsent) {
    return ZonasPeligroTableCompanion(
      id: Value(id),
      nombre:
          nombre == null && nullToAbsent ? const Value.absent() : Value(nombre),
      polygonCoordsJson: Value(polygonCoordsJson),
      nivelRiesgo: nivelRiesgo == null && nullToAbsent
          ? const Value.absent()
          : Value(nivelRiesgo),
      tipoRiesgo: tipoRiesgo == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoRiesgo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      horarioCritico: horarioCritico == null && nullToAbsent
          ? const Value.absent()
          : Value(horarioCritico),
      vigenteDesde: vigenteDesde == null && nullToAbsent
          ? const Value.absent()
          : Value(vigenteDesde),
      vigenteHasta: vigenteHasta == null && nullToAbsent
          ? const Value.absent()
          : Value(vigenteHasta),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ZonaPeligroLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZonaPeligroLocal(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      polygonCoordsJson: serializer.fromJson<String>(json['polygonCoordsJson']),
      nivelRiesgo: serializer.fromJson<int?>(json['nivelRiesgo']),
      tipoRiesgo: serializer.fromJson<String?>(json['tipoRiesgo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      horarioCritico: serializer.fromJson<String?>(json['horarioCritico']),
      vigenteDesde: serializer.fromJson<DateTime?>(json['vigenteDesde']),
      vigenteHasta: serializer.fromJson<DateTime?>(json['vigenteHasta']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String?>(nombre),
      'polygonCoordsJson': serializer.toJson<String>(polygonCoordsJson),
      'nivelRiesgo': serializer.toJson<int?>(nivelRiesgo),
      'tipoRiesgo': serializer.toJson<String?>(tipoRiesgo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'horarioCritico': serializer.toJson<String?>(horarioCritico),
      'vigenteDesde': serializer.toJson<DateTime?>(vigenteDesde),
      'vigenteHasta': serializer.toJson<DateTime?>(vigenteHasta),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ZonaPeligroLocal copyWith(
          {String? id,
          Value<String?> nombre = const Value.absent(),
          String? polygonCoordsJson,
          Value<int?> nivelRiesgo = const Value.absent(),
          Value<String?> tipoRiesgo = const Value.absent(),
          Value<String?> descripcion = const Value.absent(),
          Value<String?> horarioCritico = const Value.absent(),
          Value<DateTime?> vigenteDesde = const Value.absent(),
          Value<DateTime?> vigenteHasta = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ZonaPeligroLocal(
        id: id ?? this.id,
        nombre: nombre.present ? nombre.value : this.nombre,
        polygonCoordsJson: polygonCoordsJson ?? this.polygonCoordsJson,
        nivelRiesgo: nivelRiesgo.present ? nivelRiesgo.value : this.nivelRiesgo,
        tipoRiesgo: tipoRiesgo.present ? tipoRiesgo.value : this.tipoRiesgo,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        horarioCritico:
            horarioCritico.present ? horarioCritico.value : this.horarioCritico,
        vigenteDesde:
            vigenteDesde.present ? vigenteDesde.value : this.vigenteDesde,
        vigenteHasta:
            vigenteHasta.present ? vigenteHasta.value : this.vigenteHasta,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ZonaPeligroLocal copyWithCompanion(ZonasPeligroTableCompanion data) {
    return ZonaPeligroLocal(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      polygonCoordsJson: data.polygonCoordsJson.present
          ? data.polygonCoordsJson.value
          : this.polygonCoordsJson,
      nivelRiesgo:
          data.nivelRiesgo.present ? data.nivelRiesgo.value : this.nivelRiesgo,
      tipoRiesgo:
          data.tipoRiesgo.present ? data.tipoRiesgo.value : this.tipoRiesgo,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      horarioCritico: data.horarioCritico.present
          ? data.horarioCritico.value
          : this.horarioCritico,
      vigenteDesde: data.vigenteDesde.present
          ? data.vigenteDesde.value
          : this.vigenteDesde,
      vigenteHasta: data.vigenteHasta.present
          ? data.vigenteHasta.value
          : this.vigenteHasta,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZonaPeligroLocal(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('polygonCoordsJson: $polygonCoordsJson, ')
          ..write('nivelRiesgo: $nivelRiesgo, ')
          ..write('tipoRiesgo: $tipoRiesgo, ')
          ..write('descripcion: $descripcion, ')
          ..write('horarioCritico: $horarioCritico, ')
          ..write('vigenteDesde: $vigenteDesde, ')
          ..write('vigenteHasta: $vigenteHasta, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nombre,
      polygonCoordsJson,
      nivelRiesgo,
      tipoRiesgo,
      descripcion,
      horarioCritico,
      vigenteDesde,
      vigenteHasta,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZonaPeligroLocal &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.polygonCoordsJson == this.polygonCoordsJson &&
          other.nivelRiesgo == this.nivelRiesgo &&
          other.tipoRiesgo == this.tipoRiesgo &&
          other.descripcion == this.descripcion &&
          other.horarioCritico == this.horarioCritico &&
          other.vigenteDesde == this.vigenteDesde &&
          other.vigenteHasta == this.vigenteHasta &&
          other.updatedAt == this.updatedAt);
}

class ZonasPeligroTableCompanion extends UpdateCompanion<ZonaPeligroLocal> {
  final Value<String> id;
  final Value<String?> nombre;
  final Value<String> polygonCoordsJson;
  final Value<int?> nivelRiesgo;
  final Value<String?> tipoRiesgo;
  final Value<String?> descripcion;
  final Value<String?> horarioCritico;
  final Value<DateTime?> vigenteDesde;
  final Value<DateTime?> vigenteHasta;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ZonasPeligroTableCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.polygonCoordsJson = const Value.absent(),
    this.nivelRiesgo = const Value.absent(),
    this.tipoRiesgo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.horarioCritico = const Value.absent(),
    this.vigenteDesde = const Value.absent(),
    this.vigenteHasta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZonasPeligroTableCompanion.insert({
    required String id,
    this.nombre = const Value.absent(),
    required String polygonCoordsJson,
    this.nivelRiesgo = const Value.absent(),
    this.tipoRiesgo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.horarioCritico = const Value.absent(),
    this.vigenteDesde = const Value.absent(),
    this.vigenteHasta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        polygonCoordsJson = Value(polygonCoordsJson);
  static Insertable<ZonaPeligroLocal> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? polygonCoordsJson,
    Expression<int>? nivelRiesgo,
    Expression<String>? tipoRiesgo,
    Expression<String>? descripcion,
    Expression<String>? horarioCritico,
    Expression<DateTime>? vigenteDesde,
    Expression<DateTime>? vigenteHasta,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (polygonCoordsJson != null) 'polygon_coords_json': polygonCoordsJson,
      if (nivelRiesgo != null) 'nivel_riesgo': nivelRiesgo,
      if (tipoRiesgo != null) 'tipo_riesgo': tipoRiesgo,
      if (descripcion != null) 'descripcion': descripcion,
      if (horarioCritico != null) 'horario_critico': horarioCritico,
      if (vigenteDesde != null) 'vigente_desde': vigenteDesde,
      if (vigenteHasta != null) 'vigente_hasta': vigenteHasta,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZonasPeligroTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? nombre,
      Value<String>? polygonCoordsJson,
      Value<int?>? nivelRiesgo,
      Value<String?>? tipoRiesgo,
      Value<String?>? descripcion,
      Value<String?>? horarioCritico,
      Value<DateTime?>? vigenteDesde,
      Value<DateTime?>? vigenteHasta,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return ZonasPeligroTableCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      polygonCoordsJson: polygonCoordsJson ?? this.polygonCoordsJson,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      tipoRiesgo: tipoRiesgo ?? this.tipoRiesgo,
      descripcion: descripcion ?? this.descripcion,
      horarioCritico: horarioCritico ?? this.horarioCritico,
      vigenteDesde: vigenteDesde ?? this.vigenteDesde,
      vigenteHasta: vigenteHasta ?? this.vigenteHasta,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (polygonCoordsJson.present) {
      map['polygon_coords_json'] = Variable<String>(polygonCoordsJson.value);
    }
    if (nivelRiesgo.present) {
      map['nivel_riesgo'] = Variable<int>(nivelRiesgo.value);
    }
    if (tipoRiesgo.present) {
      map['tipo_riesgo'] = Variable<String>(tipoRiesgo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (horarioCritico.present) {
      map['horario_critico'] = Variable<String>(horarioCritico.value);
    }
    if (vigenteDesde.present) {
      map['vigente_desde'] = Variable<DateTime>(vigenteDesde.value);
    }
    if (vigenteHasta.present) {
      map['vigente_hasta'] = Variable<DateTime>(vigenteHasta.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonasPeligroTableCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('polygonCoordsJson: $polygonCoordsJson, ')
          ..write('nivelRiesgo: $nivelRiesgo, ')
          ..write('tipoRiesgo: $tipoRiesgo, ')
          ..write('descripcion: $descripcion, ')
          ..write('horarioCritico: $horarioCritico, ')
          ..write('vigenteDesde: $vigenteDesde, ')
          ..write('vigenteHasta: $vigenteHasta, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportesSeguridadTableTable extends ReportesSeguridadTable
    with TableInfo<$ReportesSeguridadTableTable, ReporteSeguridadLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportesSeguridadTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _severidadMeta =
      const VerificationMeta('severidad');
  @override
  late final GeneratedColumn<int> severidad = GeneratedColumn<int>(
      'severidad', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fechaEventoMeta =
      const VerificationMeta('fechaEvento');
  @override
  late final GeneratedColumn<DateTime> fechaEvento = GeneratedColumn<DateTime>(
      'fecha_evento', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('reportado'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tipo,
        lat,
        lng,
        direccion,
        descripcion,
        severidad,
        fechaEvento,
        estado,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reportes_seguridad_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReporteSeguridadLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('severidad')) {
      context.handle(_severidadMeta,
          severidad.isAcceptableOrUnknown(data['severidad']!, _severidadMeta));
    }
    if (data.containsKey('fecha_evento')) {
      context.handle(
          _fechaEventoMeta,
          fechaEvento.isAcceptableOrUnknown(
              data['fecha_evento']!, _fechaEventoMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReporteSeguridadLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReporteSeguridadLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      severidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}severidad']),
      fechaEvento: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_evento']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ReportesSeguridadTableTable createAlias(String alias) {
    return $ReportesSeguridadTableTable(attachedDatabase, alias);
  }
}

class ReporteSeguridadLocal extends DataClass
    implements Insertable<ReporteSeguridadLocal> {
  final String id;
  final String tipo;
  final double lat;
  final double lng;
  final String? direccion;
  final String? descripcion;
  final int? severidad;
  final DateTime? fechaEvento;
  final String estado;
  final DateTime? updatedAt;
  const ReporteSeguridadLocal(
      {required this.id,
      required this.tipo,
      required this.lat,
      required this.lng,
      this.direccion,
      this.descripcion,
      this.severidad,
      this.fechaEvento,
      required this.estado,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tipo'] = Variable<String>(tipo);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || severidad != null) {
      map['severidad'] = Variable<int>(severidad);
    }
    if (!nullToAbsent || fechaEvento != null) {
      map['fecha_evento'] = Variable<DateTime>(fechaEvento);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ReportesSeguridadTableCompanion toCompanion(bool nullToAbsent) {
    return ReportesSeguridadTableCompanion(
      id: Value(id),
      tipo: Value(tipo),
      lat: Value(lat),
      lng: Value(lng),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      severidad: severidad == null && nullToAbsent
          ? const Value.absent()
          : Value(severidad),
      fechaEvento: fechaEvento == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaEvento),
      estado: Value(estado),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ReporteSeguridadLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReporteSeguridadLocal(
      id: serializer.fromJson<String>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      severidad: serializer.fromJson<int?>(json['severidad']),
      fechaEvento: serializer.fromJson<DateTime?>(json['fechaEvento']),
      estado: serializer.fromJson<String>(json['estado']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipo': serializer.toJson<String>(tipo),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'direccion': serializer.toJson<String?>(direccion),
      'descripcion': serializer.toJson<String?>(descripcion),
      'severidad': serializer.toJson<int?>(severidad),
      'fechaEvento': serializer.toJson<DateTime?>(fechaEvento),
      'estado': serializer.toJson<String>(estado),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ReporteSeguridadLocal copyWith(
          {String? id,
          String? tipo,
          double? lat,
          double? lng,
          Value<String?> direccion = const Value.absent(),
          Value<String?> descripcion = const Value.absent(),
          Value<int?> severidad = const Value.absent(),
          Value<DateTime?> fechaEvento = const Value.absent(),
          String? estado,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ReporteSeguridadLocal(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        direccion: direccion.present ? direccion.value : this.direccion,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        severidad: severidad.present ? severidad.value : this.severidad,
        fechaEvento: fechaEvento.present ? fechaEvento.value : this.fechaEvento,
        estado: estado ?? this.estado,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ReporteSeguridadLocal copyWithCompanion(
      ReportesSeguridadTableCompanion data) {
    return ReporteSeguridadLocal(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      severidad: data.severidad.present ? data.severidad.value : this.severidad,
      fechaEvento:
          data.fechaEvento.present ? data.fechaEvento.value : this.fechaEvento,
      estado: data.estado.present ? data.estado.value : this.estado,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReporteSeguridadLocal(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('direccion: $direccion, ')
          ..write('descripcion: $descripcion, ')
          ..write('severidad: $severidad, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipo, lat, lng, direccion, descripcion,
      severidad, fechaEvento, estado, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReporteSeguridadLocal &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.direccion == this.direccion &&
          other.descripcion == this.descripcion &&
          other.severidad == this.severidad &&
          other.fechaEvento == this.fechaEvento &&
          other.estado == this.estado &&
          other.updatedAt == this.updatedAt);
}

class ReportesSeguridadTableCompanion
    extends UpdateCompanion<ReporteSeguridadLocal> {
  final Value<String> id;
  final Value<String> tipo;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> direccion;
  final Value<String?> descripcion;
  final Value<int?> severidad;
  final Value<DateTime?> fechaEvento;
  final Value<String> estado;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ReportesSeguridadTableCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.direccion = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.severidad = const Value.absent(),
    this.fechaEvento = const Value.absent(),
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportesSeguridadTableCompanion.insert({
    required String id,
    required String tipo,
    required double lat,
    required double lng,
    this.direccion = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.severidad = const Value.absent(),
    this.fechaEvento = const Value.absent(),
    this.estado = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tipo = Value(tipo),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<ReporteSeguridadLocal> custom({
    Expression<String>? id,
    Expression<String>? tipo,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? direccion,
    Expression<String>? descripcion,
    Expression<int>? severidad,
    Expression<DateTime>? fechaEvento,
    Expression<String>? estado,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (direccion != null) 'direccion': direccion,
      if (descripcion != null) 'descripcion': descripcion,
      if (severidad != null) 'severidad': severidad,
      if (fechaEvento != null) 'fecha_evento': fechaEvento,
      if (estado != null) 'estado': estado,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportesSeguridadTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tipo,
      Value<double>? lat,
      Value<double>? lng,
      Value<String?>? direccion,
      Value<String?>? descripcion,
      Value<int?>? severidad,
      Value<DateTime?>? fechaEvento,
      Value<String>? estado,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return ReportesSeguridadTableCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      severidad: severidad ?? this.severidad,
      fechaEvento: fechaEvento ?? this.fechaEvento,
      estado: estado ?? this.estado,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (severidad.present) {
      map['severidad'] = Variable<int>(severidad.value);
    }
    if (fechaEvento.present) {
      map['fecha_evento'] = Variable<DateTime>(fechaEvento.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportesSeguridadTableCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('direccion: $direccion, ')
          ..write('descripcion: $descripcion, ')
          ..write('severidad: $severidad, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('estado: $estado, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatentesComercialesTableTable extends PatentesComercialesTable
    with TableInfo<$PatentesComercialesTableTable, PatenteComercialLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatentesComercialesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoPatenteMeta =
      const VerificationMeta('tipoPatente');
  @override
  late final GeneratedColumn<String> tipoPatente = GeneratedColumn<String>(
      'tipo_patente', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rutMeta = const VerificationMeta('rut');
  @override
  late final GeneratedColumn<String> rut = GeneratedColumn<String>(
      'rut', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _razonSocialMeta =
      const VerificationMeta('razonSocial');
  @override
  late final GeneratedColumn<String> razonSocial = GeneratedColumn<String>(
      'razon_social', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _giroMeta = const VerificationMeta('giro');
  @override
  late final GeneratedColumn<String> giro = GeneratedColumn<String>(
      'giro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _direccionNormalizadaMeta =
      const VerificationMeta('direccionNormalizada');
  @override
  late final GeneratedColumn<String> direccionNormalizada =
      GeneratedColumn<String>('direccion_normalizada', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _estadoInferidoMeta =
      const VerificationMeta('estadoInferido');
  @override
  late final GeneratedColumn<String> estadoInferido = GeneratedColumn<String>(
      'estado_inferido', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('vigente_esperado'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tipoPatente,
        rut,
        razonSocial,
        giro,
        direccionNormalizada,
        lat,
        lng,
        estadoInferido,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patentes_comerciales_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<PatenteComercialLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipo_patente')) {
      context.handle(
          _tipoPatenteMeta,
          tipoPatente.isAcceptableOrUnknown(
              data['tipo_patente']!, _tipoPatenteMeta));
    }
    if (data.containsKey('rut')) {
      context.handle(
          _rutMeta, rut.isAcceptableOrUnknown(data['rut']!, _rutMeta));
    }
    if (data.containsKey('razon_social')) {
      context.handle(
          _razonSocialMeta,
          razonSocial.isAcceptableOrUnknown(
              data['razon_social']!, _razonSocialMeta));
    }
    if (data.containsKey('giro')) {
      context.handle(
          _giroMeta, giro.isAcceptableOrUnknown(data['giro']!, _giroMeta));
    }
    if (data.containsKey('direccion_normalizada')) {
      context.handle(
          _direccionNormalizadaMeta,
          direccionNormalizada.isAcceptableOrUnknown(
              data['direccion_normalizada']!, _direccionNormalizadaMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('estado_inferido')) {
      context.handle(
          _estadoInferidoMeta,
          estadoInferido.isAcceptableOrUnknown(
              data['estado_inferido']!, _estadoInferidoMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatenteComercialLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatenteComercialLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tipoPatente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_patente']),
      rut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rut']),
      razonSocial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}razon_social']),
      giro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}giro']),
      direccionNormalizada: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}direccion_normalizada']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      estadoInferido: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}estado_inferido'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $PatentesComercialesTableTable createAlias(String alias) {
    return $PatentesComercialesTableTable(attachedDatabase, alias);
  }
}

class PatenteComercialLocal extends DataClass
    implements Insertable<PatenteComercialLocal> {
  final String id;
  final String? tipoPatente;
  final String? rut;
  final String? razonSocial;
  final String? giro;
  final String? direccionNormalizada;
  final double lat;
  final double lng;
  final String estadoInferido;
  final DateTime? updatedAt;
  const PatenteComercialLocal(
      {required this.id,
      this.tipoPatente,
      this.rut,
      this.razonSocial,
      this.giro,
      this.direccionNormalizada,
      required this.lat,
      required this.lng,
      required this.estadoInferido,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tipoPatente != null) {
      map['tipo_patente'] = Variable<String>(tipoPatente);
    }
    if (!nullToAbsent || rut != null) {
      map['rut'] = Variable<String>(rut);
    }
    if (!nullToAbsent || razonSocial != null) {
      map['razon_social'] = Variable<String>(razonSocial);
    }
    if (!nullToAbsent || giro != null) {
      map['giro'] = Variable<String>(giro);
    }
    if (!nullToAbsent || direccionNormalizada != null) {
      map['direccion_normalizada'] = Variable<String>(direccionNormalizada);
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['estado_inferido'] = Variable<String>(estadoInferido);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  PatentesComercialesTableCompanion toCompanion(bool nullToAbsent) {
    return PatentesComercialesTableCompanion(
      id: Value(id),
      tipoPatente: tipoPatente == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoPatente),
      rut: rut == null && nullToAbsent ? const Value.absent() : Value(rut),
      razonSocial: razonSocial == null && nullToAbsent
          ? const Value.absent()
          : Value(razonSocial),
      giro: giro == null && nullToAbsent ? const Value.absent() : Value(giro),
      direccionNormalizada: direccionNormalizada == null && nullToAbsent
          ? const Value.absent()
          : Value(direccionNormalizada),
      lat: Value(lat),
      lng: Value(lng),
      estadoInferido: Value(estadoInferido),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory PatenteComercialLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatenteComercialLocal(
      id: serializer.fromJson<String>(json['id']),
      tipoPatente: serializer.fromJson<String?>(json['tipoPatente']),
      rut: serializer.fromJson<String?>(json['rut']),
      razonSocial: serializer.fromJson<String?>(json['razonSocial']),
      giro: serializer.fromJson<String?>(json['giro']),
      direccionNormalizada:
          serializer.fromJson<String?>(json['direccionNormalizada']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      estadoInferido: serializer.fromJson<String>(json['estadoInferido']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipoPatente': serializer.toJson<String?>(tipoPatente),
      'rut': serializer.toJson<String?>(rut),
      'razonSocial': serializer.toJson<String?>(razonSocial),
      'giro': serializer.toJson<String?>(giro),
      'direccionNormalizada': serializer.toJson<String?>(direccionNormalizada),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'estadoInferido': serializer.toJson<String>(estadoInferido),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  PatenteComercialLocal copyWith(
          {String? id,
          Value<String?> tipoPatente = const Value.absent(),
          Value<String?> rut = const Value.absent(),
          Value<String?> razonSocial = const Value.absent(),
          Value<String?> giro = const Value.absent(),
          Value<String?> direccionNormalizada = const Value.absent(),
          double? lat,
          double? lng,
          String? estadoInferido,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      PatenteComercialLocal(
        id: id ?? this.id,
        tipoPatente: tipoPatente.present ? tipoPatente.value : this.tipoPatente,
        rut: rut.present ? rut.value : this.rut,
        razonSocial: razonSocial.present ? razonSocial.value : this.razonSocial,
        giro: giro.present ? giro.value : this.giro,
        direccionNormalizada: direccionNormalizada.present
            ? direccionNormalizada.value
            : this.direccionNormalizada,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        estadoInferido: estadoInferido ?? this.estadoInferido,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  PatenteComercialLocal copyWithCompanion(
      PatentesComercialesTableCompanion data) {
    return PatenteComercialLocal(
      id: data.id.present ? data.id.value : this.id,
      tipoPatente:
          data.tipoPatente.present ? data.tipoPatente.value : this.tipoPatente,
      rut: data.rut.present ? data.rut.value : this.rut,
      razonSocial:
          data.razonSocial.present ? data.razonSocial.value : this.razonSocial,
      giro: data.giro.present ? data.giro.value : this.giro,
      direccionNormalizada: data.direccionNormalizada.present
          ? data.direccionNormalizada.value
          : this.direccionNormalizada,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      estadoInferido: data.estadoInferido.present
          ? data.estadoInferido.value
          : this.estadoInferido,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatenteComercialLocal(')
          ..write('id: $id, ')
          ..write('tipoPatente: $tipoPatente, ')
          ..write('rut: $rut, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('giro: $giro, ')
          ..write('direccionNormalizada: $direccionNormalizada, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('estadoInferido: $estadoInferido, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipoPatente, rut, razonSocial, giro,
      direccionNormalizada, lat, lng, estadoInferido, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatenteComercialLocal &&
          other.id == this.id &&
          other.tipoPatente == this.tipoPatente &&
          other.rut == this.rut &&
          other.razonSocial == this.razonSocial &&
          other.giro == this.giro &&
          other.direccionNormalizada == this.direccionNormalizada &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.estadoInferido == this.estadoInferido &&
          other.updatedAt == this.updatedAt);
}

class PatentesComercialesTableCompanion
    extends UpdateCompanion<PatenteComercialLocal> {
  final Value<String> id;
  final Value<String?> tipoPatente;
  final Value<String?> rut;
  final Value<String?> razonSocial;
  final Value<String?> giro;
  final Value<String?> direccionNormalizada;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> estadoInferido;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const PatentesComercialesTableCompanion({
    this.id = const Value.absent(),
    this.tipoPatente = const Value.absent(),
    this.rut = const Value.absent(),
    this.razonSocial = const Value.absent(),
    this.giro = const Value.absent(),
    this.direccionNormalizada = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.estadoInferido = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatentesComercialesTableCompanion.insert({
    required String id,
    this.tipoPatente = const Value.absent(),
    this.rut = const Value.absent(),
    this.razonSocial = const Value.absent(),
    this.giro = const Value.absent(),
    this.direccionNormalizada = const Value.absent(),
    required double lat,
    required double lng,
    this.estadoInferido = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<PatenteComercialLocal> custom({
    Expression<String>? id,
    Expression<String>? tipoPatente,
    Expression<String>? rut,
    Expression<String>? razonSocial,
    Expression<String>? giro,
    Expression<String>? direccionNormalizada,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? estadoInferido,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoPatente != null) 'tipo_patente': tipoPatente,
      if (rut != null) 'rut': rut,
      if (razonSocial != null) 'razon_social': razonSocial,
      if (giro != null) 'giro': giro,
      if (direccionNormalizada != null)
        'direccion_normalizada': direccionNormalizada,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (estadoInferido != null) 'estado_inferido': estadoInferido,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatentesComercialesTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? tipoPatente,
      Value<String?>? rut,
      Value<String?>? razonSocial,
      Value<String?>? giro,
      Value<String?>? direccionNormalizada,
      Value<double>? lat,
      Value<double>? lng,
      Value<String>? estadoInferido,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return PatentesComercialesTableCompanion(
      id: id ?? this.id,
      tipoPatente: tipoPatente ?? this.tipoPatente,
      rut: rut ?? this.rut,
      razonSocial: razonSocial ?? this.razonSocial,
      giro: giro ?? this.giro,
      direccionNormalizada: direccionNormalizada ?? this.direccionNormalizada,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      estadoInferido: estadoInferido ?? this.estadoInferido,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipoPatente.present) {
      map['tipo_patente'] = Variable<String>(tipoPatente.value);
    }
    if (rut.present) {
      map['rut'] = Variable<String>(rut.value);
    }
    if (razonSocial.present) {
      map['razon_social'] = Variable<String>(razonSocial.value);
    }
    if (giro.present) {
      map['giro'] = Variable<String>(giro.value);
    }
    if (direccionNormalizada.present) {
      map['direccion_normalizada'] =
          Variable<String>(direccionNormalizada.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (estadoInferido.present) {
      map['estado_inferido'] = Variable<String>(estadoInferido.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatentesComercialesTableCompanion(')
          ..write('id: $id, ')
          ..write('tipoPatente: $tipoPatente, ')
          ..write('rut: $rut, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('giro: $giro, ')
          ..write('direccionNormalizada: $direccionNormalizada, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('estadoInferido: $estadoInferido, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entidadMeta =
      const VerificationMeta('entidad');
  @override
  late final GeneratedColumn<String> entidad = GeneratedColumn<String>(
      'entidad', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
      'accion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entidadIdMeta =
      const VerificationMeta('entidadId');
  @override
  late final GeneratedColumn<String> entidadId = GeneratedColumn<String>(
      'entidad_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMsgMeta =
      const VerificationMeta('errorMsg');
  @override
  late final GeneratedColumn<String> errorMsg = GeneratedColumn<String>(
      'error_msg', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entidad,
        accion,
        entidadId,
        payloadJson,
        createdAt,
        retryCount,
        errorMsg
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entidad')) {
      context.handle(_entidadMeta,
          entidad.isAcceptableOrUnknown(data['entidad']!, _entidadMeta));
    } else if (isInserting) {
      context.missing(_entidadMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(_accionMeta,
          accion.isAcceptableOrUnknown(data['accion']!, _accionMeta));
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('entidad_id')) {
      context.handle(_entidadIdMeta,
          entidadId.isAcceptableOrUnknown(data['entidad_id']!, _entidadIdMeta));
    } else if (isInserting) {
      context.missing(_entidadIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_msg')) {
      context.handle(_errorMsgMeta,
          errorMsg.isAcceptableOrUnknown(data['error_msg']!, _errorMsgMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entidad: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entidad'])!,
      accion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accion'])!,
      entidadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entidad_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMsg: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_msg']),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;
  final String entidad;
  final String accion;
  final String entidadId;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final String? errorMsg;
  const SyncQueueItem(
      {required this.id,
      required this.entidad,
      required this.accion,
      required this.entidadId,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount,
      this.errorMsg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entidad'] = Variable<String>(entidad);
    map['accion'] = Variable<String>(accion);
    map['entidad_id'] = Variable<String>(entidadId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMsg != null) {
      map['error_msg'] = Variable<String>(errorMsg);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entidad: Value(entidad),
      accion: Value(accion),
      entidadId: Value(entidadId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      errorMsg: errorMsg == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMsg),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      entidad: serializer.fromJson<String>(json['entidad']),
      accion: serializer.fromJson<String>(json['accion']),
      entidadId: serializer.fromJson<String>(json['entidadId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMsg: serializer.fromJson<String?>(json['errorMsg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entidad': serializer.toJson<String>(entidad),
      'accion': serializer.toJson<String>(accion),
      'entidadId': serializer.toJson<String>(entidadId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMsg': serializer.toJson<String?>(errorMsg),
    };
  }

  SyncQueueItem copyWith(
          {int? id,
          String? entidad,
          String? accion,
          String? entidadId,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> errorMsg = const Value.absent()}) =>
      SyncQueueItem(
        id: id ?? this.id,
        entidad: entidad ?? this.entidad,
        accion: accion ?? this.accion,
        entidadId: entidadId ?? this.entidadId,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        errorMsg: errorMsg.present ? errorMsg.value : this.errorMsg,
      );
  SyncQueueItem copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      entidad: data.entidad.present ? data.entidad.value : this.entidad,
      accion: data.accion.present ? data.accion.value : this.accion,
      entidadId: data.entidadId.present ? data.entidadId.value : this.entidadId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMsg: data.errorMsg.present ? data.errorMsg.value : this.errorMsg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('entidad: $entidad, ')
          ..write('accion: $accion, ')
          ..write('entidadId: $entidadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMsg: $errorMsg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entidad, accion, entidadId, payloadJson,
      createdAt, retryCount, errorMsg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.entidad == this.entidad &&
          other.accion == this.accion &&
          other.entidadId == this.entidadId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.errorMsg == this.errorMsg);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> entidad;
  final Value<String> accion;
  final Value<String> entidadId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> errorMsg;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entidad = const Value.absent(),
    this.accion = const Value.absent(),
    this.entidadId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMsg = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String entidad,
    required String accion,
    required String entidadId,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMsg = const Value.absent(),
  })  : entidad = Value(entidad),
        accion = Value(accion),
        entidadId = Value(entidadId),
        payloadJson = Value(payloadJson);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? entidad,
    Expression<String>? accion,
    Expression<String>? entidadId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? errorMsg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entidad != null) 'entidad': entidad,
      if (accion != null) 'accion': accion,
      if (entidadId != null) 'entidad_id': entidadId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMsg != null) 'error_msg': errorMsg,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entidad,
      Value<String>? accion,
      Value<String>? entidadId,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? errorMsg}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entidad: entidad ?? this.entidad,
      accion: accion ?? this.accion,
      entidadId: entidadId ?? this.entidadId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entidad.present) {
      map['entidad'] = Variable<String>(entidad.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (entidadId.present) {
      map['entidad_id'] = Variable<String>(entidadId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMsg.present) {
      map['error_msg'] = Variable<String>(errorMsg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entidad: $entidad, ')
          ..write('accion: $accion, ')
          ..write('entidadId: $entidadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMsg: $errorMsg')
          ..write(')'))
        .toString();
  }
}

class $JsonCacheTableTable extends JsonCacheTable
    with TableInfo<$JsonCacheTableTable, JsonCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JsonCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, payload, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'json_cache_table';
  @override
  VerificationContext validateIntegrity(Insertable<JsonCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  JsonCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JsonCacheEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $JsonCacheTableTable createAlias(String alias) {
    return $JsonCacheTableTable(attachedDatabase, alias);
  }
}

class JsonCacheEntry extends DataClass implements Insertable<JsonCacheEntry> {
  final String key;
  final String payload;
  final DateTime cachedAt;
  const JsonCacheEntry(
      {required this.key, required this.payload, required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  JsonCacheTableCompanion toCompanion(bool nullToAbsent) {
    return JsonCacheTableCompanion(
      key: Value(key),
      payload: Value(payload),
      cachedAt: Value(cachedAt),
    );
  }

  factory JsonCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JsonCacheEntry(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  JsonCacheEntry copyWith({String? key, String? payload, DateTime? cachedAt}) =>
      JsonCacheEntry(
        key: key ?? this.key,
        payload: payload ?? this.payload,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  JsonCacheEntry copyWithCompanion(JsonCacheTableCompanion data) {
    return JsonCacheEntry(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JsonCacheEntry(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonCacheEntry &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.cachedAt == this.cachedAt);
}

class JsonCacheTableCompanion extends UpdateCompanion<JsonCacheEntry> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const JsonCacheTableCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JsonCacheTableCompanion.insert({
    required String key,
    required String payload,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        payload = Value(payload);
  static Insertable<JsonCacheEntry> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JsonCacheTableCompanion copyWith(
      {Value<String>? key,
      Value<String>? payload,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return JsonCacheTableCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JsonCacheTableCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PuntosInteresTableTable puntosInteresTable =
      $PuntosInteresTableTable(this);
  late final $ZonasPeligroTableTable zonasPeligroTable =
      $ZonasPeligroTableTable(this);
  late final $ReportesSeguridadTableTable reportesSeguridadTable =
      $ReportesSeguridadTableTable(this);
  late final $PatentesComercialesTableTable patentesComercialesTable =
      $PatentesComercialesTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $JsonCacheTableTable jsonCacheTable = $JsonCacheTableTable(this);
  late final ReportesDao reportesDao = ReportesDao(this as AppDatabase);
  late final ZonasDao zonasDao = ZonasDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        puntosInteresTable,
        zonasPeligroTable,
        reportesSeguridadTable,
        patentesComercialesTable,
        syncQueueTable,
        jsonCacheTable
      ];
}

typedef $$PuntosInteresTableTableCreateCompanionBuilder
    = PuntosInteresTableCompanion Function({
  required String id,
  required String tipo,
  Value<String?> nombre,
  Value<String?> descripcion,
  Value<String?> direccion,
  required double lat,
  required double lng,
  Value<String> estado,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$PuntosInteresTableTableUpdateCompanionBuilder
    = PuntosInteresTableCompanion Function({
  Value<String> id,
  Value<String> tipo,
  Value<String?> nombre,
  Value<String?> descripcion,
  Value<String?> direccion,
  Value<double> lat,
  Value<double> lng,
  Value<String> estado,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$PuntosInteresTableTableFilterComposer
    extends Composer<_$AppDatabase, $PuntosInteresTableTable> {
  $$PuntosInteresTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PuntosInteresTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PuntosInteresTableTable> {
  $$PuntosInteresTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PuntosInteresTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuntosInteresTableTable> {
  $$PuntosInteresTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PuntosInteresTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PuntosInteresTableTable,
    PuntoInteresLocal,
    $$PuntosInteresTableTableFilterComposer,
    $$PuntosInteresTableTableOrderingComposer,
    $$PuntosInteresTableTableAnnotationComposer,
    $$PuntosInteresTableTableCreateCompanionBuilder,
    $$PuntosInteresTableTableUpdateCompanionBuilder,
    (
      PuntoInteresLocal,
      BaseReferences<_$AppDatabase, $PuntosInteresTableTable, PuntoInteresLocal>
    ),
    PuntoInteresLocal,
    PrefetchHooks Function()> {
  $$PuntosInteresTableTableTableManager(
      _$AppDatabase db, $PuntosInteresTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuntosInteresTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuntosInteresTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuntosInteresTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String?> nombre = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PuntosInteresTableCompanion(
            id: id,
            tipo: tipo,
            nombre: nombre,
            descripcion: descripcion,
            direccion: direccion,
            lat: lat,
            lng: lng,
            estado: estado,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tipo,
            Value<String?> nombre = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            required double lat,
            required double lng,
            Value<String> estado = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PuntosInteresTableCompanion.insert(
            id: id,
            tipo: tipo,
            nombre: nombre,
            descripcion: descripcion,
            direccion: direccion,
            lat: lat,
            lng: lng,
            estado: estado,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PuntosInteresTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PuntosInteresTableTable,
    PuntoInteresLocal,
    $$PuntosInteresTableTableFilterComposer,
    $$PuntosInteresTableTableOrderingComposer,
    $$PuntosInteresTableTableAnnotationComposer,
    $$PuntosInteresTableTableCreateCompanionBuilder,
    $$PuntosInteresTableTableUpdateCompanionBuilder,
    (
      PuntoInteresLocal,
      BaseReferences<_$AppDatabase, $PuntosInteresTableTable, PuntoInteresLocal>
    ),
    PuntoInteresLocal,
    PrefetchHooks Function()>;
typedef $$ZonasPeligroTableTableCreateCompanionBuilder
    = ZonasPeligroTableCompanion Function({
  required String id,
  Value<String?> nombre,
  required String polygonCoordsJson,
  Value<int?> nivelRiesgo,
  Value<String?> tipoRiesgo,
  Value<String?> descripcion,
  Value<String?> horarioCritico,
  Value<DateTime?> vigenteDesde,
  Value<DateTime?> vigenteHasta,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$ZonasPeligroTableTableUpdateCompanionBuilder
    = ZonasPeligroTableCompanion Function({
  Value<String> id,
  Value<String?> nombre,
  Value<String> polygonCoordsJson,
  Value<int?> nivelRiesgo,
  Value<String?> tipoRiesgo,
  Value<String?> descripcion,
  Value<String?> horarioCritico,
  Value<DateTime?> vigenteDesde,
  Value<DateTime?> vigenteHasta,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$ZonasPeligroTableTableFilterComposer
    extends Composer<_$AppDatabase, $ZonasPeligroTableTable> {
  $$ZonasPeligroTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get polygonCoordsJson => $composableBuilder(
      column: $table.polygonCoordsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nivelRiesgo => $composableBuilder(
      column: $table.nivelRiesgo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoRiesgo => $composableBuilder(
      column: $table.tipoRiesgo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horarioCritico => $composableBuilder(
      column: $table.horarioCritico,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get vigenteDesde => $composableBuilder(
      column: $table.vigenteDesde, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get vigenteHasta => $composableBuilder(
      column: $table.vigenteHasta, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ZonasPeligroTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ZonasPeligroTableTable> {
  $$ZonasPeligroTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get polygonCoordsJson => $composableBuilder(
      column: $table.polygonCoordsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nivelRiesgo => $composableBuilder(
      column: $table.nivelRiesgo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoRiesgo => $composableBuilder(
      column: $table.tipoRiesgo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horarioCritico => $composableBuilder(
      column: $table.horarioCritico,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get vigenteDesde => $composableBuilder(
      column: $table.vigenteDesde,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get vigenteHasta => $composableBuilder(
      column: $table.vigenteHasta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ZonasPeligroTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZonasPeligroTableTable> {
  $$ZonasPeligroTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get polygonCoordsJson => $composableBuilder(
      column: $table.polygonCoordsJson, builder: (column) => column);

  GeneratedColumn<int> get nivelRiesgo => $composableBuilder(
      column: $table.nivelRiesgo, builder: (column) => column);

  GeneratedColumn<String> get tipoRiesgo => $composableBuilder(
      column: $table.tipoRiesgo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get horarioCritico => $composableBuilder(
      column: $table.horarioCritico, builder: (column) => column);

  GeneratedColumn<DateTime> get vigenteDesde => $composableBuilder(
      column: $table.vigenteDesde, builder: (column) => column);

  GeneratedColumn<DateTime> get vigenteHasta => $composableBuilder(
      column: $table.vigenteHasta, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ZonasPeligroTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ZonasPeligroTableTable,
    ZonaPeligroLocal,
    $$ZonasPeligroTableTableFilterComposer,
    $$ZonasPeligroTableTableOrderingComposer,
    $$ZonasPeligroTableTableAnnotationComposer,
    $$ZonasPeligroTableTableCreateCompanionBuilder,
    $$ZonasPeligroTableTableUpdateCompanionBuilder,
    (
      ZonaPeligroLocal,
      BaseReferences<_$AppDatabase, $ZonasPeligroTableTable, ZonaPeligroLocal>
    ),
    ZonaPeligroLocal,
    PrefetchHooks Function()> {
  $$ZonasPeligroTableTableTableManager(
      _$AppDatabase db, $ZonasPeligroTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonasPeligroTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonasPeligroTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonasPeligroTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> nombre = const Value.absent(),
            Value<String> polygonCoordsJson = const Value.absent(),
            Value<int?> nivelRiesgo = const Value.absent(),
            Value<String?> tipoRiesgo = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> horarioCritico = const Value.absent(),
            Value<DateTime?> vigenteDesde = const Value.absent(),
            Value<DateTime?> vigenteHasta = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ZonasPeligroTableCompanion(
            id: id,
            nombre: nombre,
            polygonCoordsJson: polygonCoordsJson,
            nivelRiesgo: nivelRiesgo,
            tipoRiesgo: tipoRiesgo,
            descripcion: descripcion,
            horarioCritico: horarioCritico,
            vigenteDesde: vigenteDesde,
            vigenteHasta: vigenteHasta,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> nombre = const Value.absent(),
            required String polygonCoordsJson,
            Value<int?> nivelRiesgo = const Value.absent(),
            Value<String?> tipoRiesgo = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> horarioCritico = const Value.absent(),
            Value<DateTime?> vigenteDesde = const Value.absent(),
            Value<DateTime?> vigenteHasta = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ZonasPeligroTableCompanion.insert(
            id: id,
            nombre: nombre,
            polygonCoordsJson: polygonCoordsJson,
            nivelRiesgo: nivelRiesgo,
            tipoRiesgo: tipoRiesgo,
            descripcion: descripcion,
            horarioCritico: horarioCritico,
            vigenteDesde: vigenteDesde,
            vigenteHasta: vigenteHasta,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ZonasPeligroTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ZonasPeligroTableTable,
    ZonaPeligroLocal,
    $$ZonasPeligroTableTableFilterComposer,
    $$ZonasPeligroTableTableOrderingComposer,
    $$ZonasPeligroTableTableAnnotationComposer,
    $$ZonasPeligroTableTableCreateCompanionBuilder,
    $$ZonasPeligroTableTableUpdateCompanionBuilder,
    (
      ZonaPeligroLocal,
      BaseReferences<_$AppDatabase, $ZonasPeligroTableTable, ZonaPeligroLocal>
    ),
    ZonaPeligroLocal,
    PrefetchHooks Function()>;
typedef $$ReportesSeguridadTableTableCreateCompanionBuilder
    = ReportesSeguridadTableCompanion Function({
  required String id,
  required String tipo,
  required double lat,
  required double lng,
  Value<String?> direccion,
  Value<String?> descripcion,
  Value<int?> severidad,
  Value<DateTime?> fechaEvento,
  Value<String> estado,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$ReportesSeguridadTableTableUpdateCompanionBuilder
    = ReportesSeguridadTableCompanion Function({
  Value<String> id,
  Value<String> tipo,
  Value<double> lat,
  Value<double> lng,
  Value<String?> direccion,
  Value<String?> descripcion,
  Value<int?> severidad,
  Value<DateTime?> fechaEvento,
  Value<String> estado,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$ReportesSeguridadTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReportesSeguridadTableTable> {
  $$ReportesSeguridadTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get severidad => $composableBuilder(
      column: $table.severidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReportesSeguridadTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportesSeguridadTableTable> {
  $$ReportesSeguridadTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severidad => $composableBuilder(
      column: $table.severidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReportesSeguridadTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportesSeguridadTableTable> {
  $$ReportesSeguridadTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<int> get severidad =>
      $composableBuilder(column: $table.severidad, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReportesSeguridadTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportesSeguridadTableTable,
    ReporteSeguridadLocal,
    $$ReportesSeguridadTableTableFilterComposer,
    $$ReportesSeguridadTableTableOrderingComposer,
    $$ReportesSeguridadTableTableAnnotationComposer,
    $$ReportesSeguridadTableTableCreateCompanionBuilder,
    $$ReportesSeguridadTableTableUpdateCompanionBuilder,
    (
      ReporteSeguridadLocal,
      BaseReferences<_$AppDatabase, $ReportesSeguridadTableTable,
          ReporteSeguridadLocal>
    ),
    ReporteSeguridadLocal,
    PrefetchHooks Function()> {
  $$ReportesSeguridadTableTableTableManager(
      _$AppDatabase db, $ReportesSeguridadTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportesSeguridadTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportesSeguridadTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportesSeguridadTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<int?> severidad = const Value.absent(),
            Value<DateTime?> fechaEvento = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportesSeguridadTableCompanion(
            id: id,
            tipo: tipo,
            lat: lat,
            lng: lng,
            direccion: direccion,
            descripcion: descripcion,
            severidad: severidad,
            fechaEvento: fechaEvento,
            estado: estado,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tipo,
            required double lat,
            required double lng,
            Value<String?> direccion = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<int?> severidad = const Value.absent(),
            Value<DateTime?> fechaEvento = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportesSeguridadTableCompanion.insert(
            id: id,
            tipo: tipo,
            lat: lat,
            lng: lng,
            direccion: direccion,
            descripcion: descripcion,
            severidad: severidad,
            fechaEvento: fechaEvento,
            estado: estado,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportesSeguridadTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReportesSeguridadTableTable,
        ReporteSeguridadLocal,
        $$ReportesSeguridadTableTableFilterComposer,
        $$ReportesSeguridadTableTableOrderingComposer,
        $$ReportesSeguridadTableTableAnnotationComposer,
        $$ReportesSeguridadTableTableCreateCompanionBuilder,
        $$ReportesSeguridadTableTableUpdateCompanionBuilder,
        (
          ReporteSeguridadLocal,
          BaseReferences<_$AppDatabase, $ReportesSeguridadTableTable,
              ReporteSeguridadLocal>
        ),
        ReporteSeguridadLocal,
        PrefetchHooks Function()>;
typedef $$PatentesComercialesTableTableCreateCompanionBuilder
    = PatentesComercialesTableCompanion Function({
  required String id,
  Value<String?> tipoPatente,
  Value<String?> rut,
  Value<String?> razonSocial,
  Value<String?> giro,
  Value<String?> direccionNormalizada,
  required double lat,
  required double lng,
  Value<String> estadoInferido,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$PatentesComercialesTableTableUpdateCompanionBuilder
    = PatentesComercialesTableCompanion Function({
  Value<String> id,
  Value<String?> tipoPatente,
  Value<String?> rut,
  Value<String?> razonSocial,
  Value<String?> giro,
  Value<String?> direccionNormalizada,
  Value<double> lat,
  Value<double> lng,
  Value<String> estadoInferido,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$PatentesComercialesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PatentesComercialesTableTable> {
  $$PatentesComercialesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoPatente => $composableBuilder(
      column: $table.tipoPatente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rut => $composableBuilder(
      column: $table.rut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get razonSocial => $composableBuilder(
      column: $table.razonSocial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get giro => $composableBuilder(
      column: $table.giro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccionNormalizada => $composableBuilder(
      column: $table.direccionNormalizada,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estadoInferido => $composableBuilder(
      column: $table.estadoInferido,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PatentesComercialesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PatentesComercialesTableTable> {
  $$PatentesComercialesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoPatente => $composableBuilder(
      column: $table.tipoPatente, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rut => $composableBuilder(
      column: $table.rut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get razonSocial => $composableBuilder(
      column: $table.razonSocial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get giro => $composableBuilder(
      column: $table.giro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccionNormalizada => $composableBuilder(
      column: $table.direccionNormalizada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estadoInferido => $composableBuilder(
      column: $table.estadoInferido,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PatentesComercialesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatentesComercialesTableTable> {
  $$PatentesComercialesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoPatente => $composableBuilder(
      column: $table.tipoPatente, builder: (column) => column);

  GeneratedColumn<String> get rut =>
      $composableBuilder(column: $table.rut, builder: (column) => column);

  GeneratedColumn<String> get razonSocial => $composableBuilder(
      column: $table.razonSocial, builder: (column) => column);

  GeneratedColumn<String> get giro =>
      $composableBuilder(column: $table.giro, builder: (column) => column);

  GeneratedColumn<String> get direccionNormalizada => $composableBuilder(
      column: $table.direccionNormalizada, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get estadoInferido => $composableBuilder(
      column: $table.estadoInferido, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatentesComercialesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatentesComercialesTableTable,
    PatenteComercialLocal,
    $$PatentesComercialesTableTableFilterComposer,
    $$PatentesComercialesTableTableOrderingComposer,
    $$PatentesComercialesTableTableAnnotationComposer,
    $$PatentesComercialesTableTableCreateCompanionBuilder,
    $$PatentesComercialesTableTableUpdateCompanionBuilder,
    (
      PatenteComercialLocal,
      BaseReferences<_$AppDatabase, $PatentesComercialesTableTable,
          PatenteComercialLocal>
    ),
    PatenteComercialLocal,
    PrefetchHooks Function()> {
  $$PatentesComercialesTableTableTableManager(
      _$AppDatabase db, $PatentesComercialesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatentesComercialesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PatentesComercialesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatentesComercialesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> tipoPatente = const Value.absent(),
            Value<String?> rut = const Value.absent(),
            Value<String?> razonSocial = const Value.absent(),
            Value<String?> giro = const Value.absent(),
            Value<String?> direccionNormalizada = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String> estadoInferido = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatentesComercialesTableCompanion(
            id: id,
            tipoPatente: tipoPatente,
            rut: rut,
            razonSocial: razonSocial,
            giro: giro,
            direccionNormalizada: direccionNormalizada,
            lat: lat,
            lng: lng,
            estadoInferido: estadoInferido,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> tipoPatente = const Value.absent(),
            Value<String?> rut = const Value.absent(),
            Value<String?> razonSocial = const Value.absent(),
            Value<String?> giro = const Value.absent(),
            Value<String?> direccionNormalizada = const Value.absent(),
            required double lat,
            required double lng,
            Value<String> estadoInferido = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatentesComercialesTableCompanion.insert(
            id: id,
            tipoPatente: tipoPatente,
            rut: rut,
            razonSocial: razonSocial,
            giro: giro,
            direccionNormalizada: direccionNormalizada,
            lat: lat,
            lng: lng,
            estadoInferido: estadoInferido,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatentesComercialesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PatentesComercialesTableTable,
        PatenteComercialLocal,
        $$PatentesComercialesTableTableFilterComposer,
        $$PatentesComercialesTableTableOrderingComposer,
        $$PatentesComercialesTableTableAnnotationComposer,
        $$PatentesComercialesTableTableCreateCompanionBuilder,
        $$PatentesComercialesTableTableUpdateCompanionBuilder,
        (
          PatenteComercialLocal,
          BaseReferences<_$AppDatabase, $PatentesComercialesTableTable,
              PatenteComercialLocal>
        ),
        PatenteComercialLocal,
        PrefetchHooks Function()>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  required String entidad,
  required String accion,
  required String entidadId,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> errorMsg,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  Value<String> entidad,
  Value<String> accion,
  Value<String> entidadId,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> errorMsg,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entidad => $composableBuilder(
      column: $table.entidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accion => $composableBuilder(
      column: $table.accion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entidadId => $composableBuilder(
      column: $table.entidadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMsg => $composableBuilder(
      column: $table.errorMsg, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entidad => $composableBuilder(
      column: $table.entidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accion => $composableBuilder(
      column: $table.accion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entidadId => $composableBuilder(
      column: $table.entidadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMsg => $composableBuilder(
      column: $table.errorMsg, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entidad =>
      $composableBuilder(column: $table.entidad, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get entidadId =>
      $composableBuilder(column: $table.entidadId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMsg =>
      $composableBuilder(column: $table.errorMsg, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueItem,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entidad = const Value.absent(),
            Value<String> accion = const Value.absent(),
            Value<String> entidadId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMsg = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            entidad: entidad,
            accion: accion,
            entidadId: entidadId,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMsg: errorMsg,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entidad,
            required String accion,
            required String entidadId,
            required String payloadJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMsg = const Value.absent(),
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            entidad: entidad,
            accion: accion,
            entidadId: entidadId,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMsg: errorMsg,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueItem,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$JsonCacheTableTableCreateCompanionBuilder = JsonCacheTableCompanion
    Function({
  required String key,
  required String payload,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$JsonCacheTableTableUpdateCompanionBuilder = JsonCacheTableCompanion
    Function({
  Value<String> key,
  Value<String> payload,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$JsonCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $JsonCacheTableTable> {
  $$JsonCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$JsonCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $JsonCacheTableTable> {
  $$JsonCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$JsonCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $JsonCacheTableTable> {
  $$JsonCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$JsonCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JsonCacheTableTable,
    JsonCacheEntry,
    $$JsonCacheTableTableFilterComposer,
    $$JsonCacheTableTableOrderingComposer,
    $$JsonCacheTableTableAnnotationComposer,
    $$JsonCacheTableTableCreateCompanionBuilder,
    $$JsonCacheTableTableUpdateCompanionBuilder,
    (
      JsonCacheEntry,
      BaseReferences<_$AppDatabase, $JsonCacheTableTable, JsonCacheEntry>
    ),
    JsonCacheEntry,
    PrefetchHooks Function()> {
  $$JsonCacheTableTableTableManager(
      _$AppDatabase db, $JsonCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JsonCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JsonCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JsonCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JsonCacheTableCompanion(
            key: key,
            payload: payload,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String payload,
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JsonCacheTableCompanion.insert(
            key: key,
            payload: payload,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JsonCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JsonCacheTableTable,
    JsonCacheEntry,
    $$JsonCacheTableTableFilterComposer,
    $$JsonCacheTableTableOrderingComposer,
    $$JsonCacheTableTableAnnotationComposer,
    $$JsonCacheTableTableCreateCompanionBuilder,
    $$JsonCacheTableTableUpdateCompanionBuilder,
    (
      JsonCacheEntry,
      BaseReferences<_$AppDatabase, $JsonCacheTableTable, JsonCacheEntry>
    ),
    JsonCacheEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PuntosInteresTableTableTableManager get puntosInteresTable =>
      $$PuntosInteresTableTableTableManager(_db, _db.puntosInteresTable);
  $$ZonasPeligroTableTableTableManager get zonasPeligroTable =>
      $$ZonasPeligroTableTableTableManager(_db, _db.zonasPeligroTable);
  $$ReportesSeguridadTableTableTableManager get reportesSeguridadTable =>
      $$ReportesSeguridadTableTableTableManager(
          _db, _db.reportesSeguridadTable);
  $$PatentesComercialesTableTableTableManager get patentesComercialesTable =>
      $$PatentesComercialesTableTableTableManager(
          _db, _db.patentesComercialesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$JsonCacheTableTableTableManager get jsonCacheTable =>
      $$JsonCacheTableTableTableManager(_db, _db.jsonCacheTable);
}
