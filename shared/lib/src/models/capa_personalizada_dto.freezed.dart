// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capa_personalizada_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CapaPersonalizadaDto {
  String get id;
  String get nombre;
  String? get descripcion;
  String get color;
  double get opacidad;
  bool get visible;
  String get formato;
  String get categoria;
  DateTime get createdAt;

  /// Create a copy of CapaPersonalizadaDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CapaPersonalizadaDtoCopyWith<CapaPersonalizadaDto> get copyWith =>
      _$CapaPersonalizadaDtoCopyWithImpl<CapaPersonalizadaDto>(
          this as CapaPersonalizadaDto, _$identity);

  /// Serializes this CapaPersonalizadaDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CapaPersonalizadaDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.opacidad, opacidad) ||
                other.opacidad == opacidad) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.formato, formato) || other.formato == formato) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, descripcion, color,
      opacidad, visible, formato, categoria, createdAt);

  @override
  String toString() {
    return 'CapaPersonalizadaDto(id: $id, nombre: $nombre, descripcion: $descripcion, color: $color, opacidad: $opacidad, visible: $visible, formato: $formato, categoria: $categoria, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $CapaPersonalizadaDtoCopyWith<$Res> {
  factory $CapaPersonalizadaDtoCopyWith(CapaPersonalizadaDto value,
          $Res Function(CapaPersonalizadaDto) _then) =
      _$CapaPersonalizadaDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String nombre,
      String? descripcion,
      String color,
      double opacidad,
      bool visible,
      String formato,
      String categoria,
      DateTime createdAt});
}

/// @nodoc
class _$CapaPersonalizadaDtoCopyWithImpl<$Res>
    implements $CapaPersonalizadaDtoCopyWith<$Res> {
  _$CapaPersonalizadaDtoCopyWithImpl(this._self, this._then);

  final CapaPersonalizadaDto _self;
  final $Res Function(CapaPersonalizadaDto) _then;

  /// Create a copy of CapaPersonalizadaDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? color = null,
    Object? opacidad = null,
    Object? visible = null,
    Object? formato = null,
    Object? categoria = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      opacidad: null == opacidad
          ? _self.opacidad
          : opacidad // ignore: cast_nullable_to_non_nullable
              as double,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      formato: null == formato
          ? _self.formato
          : formato // ignore: cast_nullable_to_non_nullable
              as String,
      categoria: null == categoria
          ? _self.categoria
          : categoria // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [CapaPersonalizadaDto].
extension CapaPersonalizadaDtoPatterns on CapaPersonalizadaDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CapaPersonalizadaDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CapaPersonalizadaDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CapaPersonalizadaDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String nombre,
            String? descripcion,
            String color,
            double opacidad,
            bool visible,
            String formato,
            String categoria,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto() when $default != null:
        return $default(
            _that.id,
            _that.nombre,
            _that.descripcion,
            _that.color,
            _that.opacidad,
            _that.visible,
            _that.formato,
            _that.categoria,
            _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String nombre,
            String? descripcion,
            String color,
            double opacidad,
            bool visible,
            String formato,
            String categoria,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto():
        return $default(
            _that.id,
            _that.nombre,
            _that.descripcion,
            _that.color,
            _that.opacidad,
            _that.visible,
            _that.formato,
            _that.categoria,
            _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String nombre,
            String? descripcion,
            String color,
            double opacidad,
            bool visible,
            String formato,
            String categoria,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CapaPersonalizadaDto() when $default != null:
        return $default(
            _that.id,
            _that.nombre,
            _that.descripcion,
            _that.color,
            _that.opacidad,
            _that.visible,
            _that.formato,
            _that.categoria,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CapaPersonalizadaDto implements CapaPersonalizadaDto {
  const _CapaPersonalizadaDto(
      {required this.id,
      required this.nombre,
      this.descripcion,
      required this.color,
      required this.opacidad,
      required this.visible,
      required this.formato,
      required this.categoria,
      required this.createdAt});
  factory _CapaPersonalizadaDto.fromJson(Map<String, dynamic> json) =>
      _$CapaPersonalizadaDtoFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String? descripcion;
  @override
  final String color;
  @override
  final double opacidad;
  @override
  final bool visible;
  @override
  final String formato;
  @override
  final String categoria;
  @override
  final DateTime createdAt;

  /// Create a copy of CapaPersonalizadaDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CapaPersonalizadaDtoCopyWith<_CapaPersonalizadaDto> get copyWith =>
      __$CapaPersonalizadaDtoCopyWithImpl<_CapaPersonalizadaDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CapaPersonalizadaDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CapaPersonalizadaDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.opacidad, opacidad) ||
                other.opacidad == opacidad) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.formato, formato) || other.formato == formato) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, descripcion, color,
      opacidad, visible, formato, categoria, createdAt);

  @override
  String toString() {
    return 'CapaPersonalizadaDto(id: $id, nombre: $nombre, descripcion: $descripcion, color: $color, opacidad: $opacidad, visible: $visible, formato: $formato, categoria: $categoria, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$CapaPersonalizadaDtoCopyWith<$Res>
    implements $CapaPersonalizadaDtoCopyWith<$Res> {
  factory _$CapaPersonalizadaDtoCopyWith(_CapaPersonalizadaDto value,
          $Res Function(_CapaPersonalizadaDto) _then) =
      __$CapaPersonalizadaDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String nombre,
      String? descripcion,
      String color,
      double opacidad,
      bool visible,
      String formato,
      String categoria,
      DateTime createdAt});
}

/// @nodoc
class __$CapaPersonalizadaDtoCopyWithImpl<$Res>
    implements _$CapaPersonalizadaDtoCopyWith<$Res> {
  __$CapaPersonalizadaDtoCopyWithImpl(this._self, this._then);

  final _CapaPersonalizadaDto _self;
  final $Res Function(_CapaPersonalizadaDto) _then;

  /// Create a copy of CapaPersonalizadaDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? color = null,
    Object? opacidad = null,
    Object? visible = null,
    Object? formato = null,
    Object? categoria = null,
    Object? createdAt = null,
  }) {
    return _then(_CapaPersonalizadaDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      opacidad: null == opacidad
          ? _self.opacidad
          : opacidad // ignore: cast_nullable_to_non_nullable
              as double,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
      formato: null == formato
          ? _self.formato
          : formato // ignore: cast_nullable_to_non_nullable
              as String,
      categoria: null == categoria
          ? _self.categoria
          : categoria // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
