import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../config/constants.dart';
import '../../data/remote/cached_api.dart';
import '../../data/sync/sync_provider.dart';
import '../auth/auth_provider.dart';

final _log = Logger('Actividades');

const _uuid = Uuid();

// ── Seed data (14 actividades, fiel al diseño de Claude Design) ───────────────

List<ActividadMunicipal> _buildSeedActividades() {
  return [
    // PLANIFICADO
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440001',
      tipo: TipoActividad.reunion,
      estado: EstadoActividad.planificado,
      titulo: 'Mesa territorial Lota Bajo · Comerciantes Pedro Aguirre Cerda',
      descripcion: 'Coordinación con junta de comerciantes para revisión de horarios de patrullaje en sector comercial centro tras incidentes recientes.',
      fechaInicio: DateTime(2026, 5, 18, 9, 0),
      fechaFin: DateTime(2026, 5, 18, 11, 0),
      participanteIds: const [],
      lat: -37.0891,
      lng: -73.1592,
      direccion: 'Pedro Aguirre Cerda 302, Lota Bajo',
      sector: 'S-2',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 0,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 10),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440002',
      tipo: TipoActividad.capacitacion,
      estado: EstadoActividad.planificado,
      titulo: 'Capacitación inspectores · Uso de SIGESPU móvil',
      descripcion: 'Capacitación operativa para inspectores municipales sobre uso del módulo móvil de SIGESPU para reporte en terreno.',
      fechaInicio: DateTime(2026, 5, 20, 10, 0),
      fechaFin: DateTime(2026, 5, 20, 13, 0),
      participanteIds: const [],
      direccion: 'Edificio Consistorial · Sala Cuncos',
      sector: 'S-3',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 180000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 10),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440003',
      tipo: TipoActividad.operativo,
      estado: EstadoActividad.planificado,
      titulo: 'Operativo conjunto Carabineros · Sector Plaza de Armas',
      descripcion: 'Operativo nocturno en respuesta a denuncias de microtráfico en sector céntrico. Coordinado con 4ta Comisaría.',
      fechaInicio: DateTime(2026, 5, 22, 22, 0),
      fechaFin: DateTime(2026, 5, 23, 2, 0),
      participanteIds: const [],
      direccion: 'Sin ubicación',
      sector: 'S-4',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 450000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 11),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440004',
      tipo: TipoActividad.evento,
      estado: EstadoActividad.planificado,
      titulo: 'Feria del Adulto Mayor · Plaza Matías Cousiño',
      descripcion: 'Feria pública para adultos mayores con stands de salud, recreación y entrega de beneficios sociales.',
      fechaInicio: DateTime(2026, 6, 2, 10, 0),
      fechaFin: DateTime(2026, 6, 2, 18, 0),
      participanteIds: const [],
      lat: -37.0888,
      lng: -73.1561,
      direccion: 'Plaza Matías Cousiño, Lota Alto',
      sector: 'Centro',
      direccionMunicipal: 'DIDECO',
      presupuestoEstimado: 1200000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 11),
    ),

    // EN CURSO
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440005',
      tipo: TipoActividad.operativo,
      estado: EstadoActividad.enCurso,
      titulo: 'Patrullaje preventivo · Sector estación de servicio Copec',
      descripcion: 'Rondas vehiculares nocturnas durante 5 días en sector de comercio nocturno.',
      fechaInicio: DateTime(2026, 5, 10, 20, 0),
      fechaFin: DateTime(2026, 5, 15, 6, 0),
      participanteIds: const [],
      lat: -37.0902,
      lng: -73.1601,
      direccion: 'Av. Carlos Cousiño 1820, Lota Bajo',
      sector: 'S-2',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 320000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 9),
      acta: ActaActividad(
        asistentes: [
          const AsistenteActa(nombre: 'Rodrigo Sandoval Pérez', cargo: 'Coord. Seg. Pública', rut: '15.842.119-3', asistio: true),
          const AsistenteActa(nombre: 'Daniela Salgado Muñoz', cargo: 'Dirección de Tránsito', rut: '12.487.661-9', asistio: true),
          const AsistenteActa(nombre: 'Luis Henríquez Castro', cargo: 'Dirección de Obras', rut: '16.998.241-K', asistio: false),
        ],
        acuerdos: [
          AcuerdoActa(
            id: 'ac-1',
            descripcion: 'Coordinar con Tránsito el cierre de Pedro Aguirre Cerda 200-400 entre 22:00 y 02:00',
            responsable: 'Sra. Daniela Salgado · Tránsito',
            fechaLimite: DateTime(2026, 5, 12),
            completado: false,
          ),
          AcuerdoActa(
            id: 'ac-2',
            descripcion: 'Solicitar a Obras 4 luminarias nuevas en pasaje El Cobre',
            responsable: 'Sr. Luis Henríquez · Obras',
            fechaLimite: DateTime(2026, 5, 14),
            completado: false,
          ),
        ],
      ),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440006',
      tipo: TipoActividad.reunion,
      estado: EstadoActividad.enCurso,
      titulo: 'Comité Sectorial S-3 · Junta de Vecinos La Cima',
      descripcion: 'Reunión mensual con dirigentes para seguimiento de acuerdos territoriales del sector La Cima.',
      fechaInicio: DateTime(2026, 5, 12, 19, 0),
      fechaFin: DateTime(2026, 5, 12, 21, 0),
      participanteIds: const [],
      lat: -37.0873,
      lng: -73.1544,
      direccion: 'Sede social calle Galvarino 412',
      sector: 'S-3',
      direccionMunicipal: 'DIDECO',
      presupuestoEstimado: 0,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 8),
      acta: ActaActividad(
        contenido: '1. Apertura. Se inicia la reunión a las 19:08 hrs con la asistencia indicada en el listado. Preside Rodrigo Sandoval (Seg. Pública), tomando acta Paula Riffo.\n\n2. Tabla. Seguimiento acuerdos abril, revisión sectores críticos S-3 (calles Galvarino y El Cobre) y coordinación con Tránsito para cierres parciales nocturnos.\n\n3. Acuerdos. Se levantan 4 acuerdos con responsables y plazos. Próxima reunión fijada para el 12 de junio a las 19:00 hrs en la misma sede.',
        asistentes: [
          const AsistenteActa(nombre: 'Rodrigo Sandoval Pérez', cargo: 'Coord. Seg. Pública', rut: '15.842.119-3', asistio: true),
          const AsistenteActa(nombre: 'Daniela Salgado Muñoz', cargo: 'Dirección de Tránsito', rut: '12.487.661-9', asistio: true),
          const AsistenteActa(nombre: 'Luis Henríquez Castro', cargo: 'Dirección de Obras', rut: '16.998.241-K', asistio: false),
          const AsistenteActa(nombre: 'Paula Riffo Valencia', cargo: 'Inspectora Seg. Pública', rut: '18.221.554-2', asistio: true),
          const AsistenteActa(nombre: 'María José Cerda', cargo: 'Pdta. JJVV La Cima', rut: '11.334.090-1', asistio: true),
          const AsistenteActa(nombre: 'Carlos Vergara Solís', cargo: 'Dirigente social S-3', rut: '10.118.443-6', asistio: true),
          const AsistenteActa(nombre: 'Ximena Toro Aravena', cargo: 'DIDECO · Adulto Mayor', rut: '13.776.220-4', asistio: false),
        ],
        acuerdos: [
          AcuerdoActa(
            id: 'ac-3',
            descripcion: 'Reenviar minuta de reunión a junta de vecinos vía correo',
            responsable: 'Sra. Paula Riffo · Seg. Pública',
            fechaLimite: DateTime(2026, 5, 11),
            completado: true,
          ),
          AcuerdoActa(
            id: 'ac-4',
            descripcion: 'Agendar visita en terreno con dirigentes para validar puntos críticos',
            responsable: 'Sr. Rodrigo Sandoval · Seg. Pública',
            fechaLimite: DateTime(2026, 5, 20),
            completado: false,
          ),
        ],
      ),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440007',
      tipo: TipoActividad.evento,
      estado: EstadoActividad.enCurso,
      titulo: 'Semana de la Seguridad Comunitaria · Talleres en juntas de vecinos',
      descripcion: 'Ciclo de talleres en 6 sedes vecinales durante la semana sobre autocuidado, denuncia y uso del 1409.',
      fechaInicio: DateTime(2026, 5, 11, 18, 0),
      fechaFin: DateTime(2026, 5, 17, 21, 0),
      participanteIds: const [],
      direccion: 'Múltiples sedes · 6 sectores',
      sector: 'Centro',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 850000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 5, 7),
    ),

    // COMPLETADO
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440008',
      tipo: TipoActividad.reunion,
      estado: EstadoActividad.completado,
      titulo: 'Reunión con Director DIDECO · Plan Calle Segura 2026',
      descripcion: 'Definición de prioridades y presupuesto para plan Calle Segura del segundo semestre.',
      fechaInicio: DateTime(2026, 4, 28, 11, 0),
      fechaFin: DateTime(2026, 4, 28, 12, 30),
      participanteIds: const [],
      lat: -37.0896,
      lng: -73.1584,
      direccion: 'Alcaldía · Sala de Directorio',
      sector: 'S-1',
      direccionMunicipal: 'DIDECO',
      presupuestoEstimado: 0,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 4, 25),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440009',
      tipo: TipoActividad.capacitacion,
      estado: EstadoActividad.completado,
      titulo: 'Capacitación Defensa Civil · Primeros auxilios',
      descripcion: 'Jornada de capacitación cerrada para equipo de Defensa Civil municipal.',
      fechaInicio: DateTime(2026, 4, 22, 9, 0),
      fechaFin: DateTime(2026, 4, 22, 17, 0),
      participanteIds: const [],
      lat: -37.0912,
      lng: -73.1571,
      direccion: 'Bomberos 2ª Compañía Lota',
      sector: 'Centro',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 420000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 4, 18),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440010',
      tipo: TipoActividad.operativo,
      estado: EstadoActividad.completado,
      titulo: 'Operativo fiscalización patentes alcoholes · Sector Lota Alto',
      descripcion: 'Operativo conjunto Carabineros, Tránsito e Inspectores en locales con patente.',
      fechaInicio: DateTime(2026, 4, 18, 20, 0),
      fechaFin: DateTime(2026, 4, 19, 3, 0),
      participanteIds: const [],
      lat: -37.0851,
      lng: -73.1522,
      direccion: 'Av. Pedro Aguirre Cerda · S-5',
      sector: 'S-5',
      direccionMunicipal: 'Tránsito',
      presupuestoEstimado: 240000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2026, 4, 15),
    ),

    // ARCHIVADO
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440011',
      tipo: TipoActividad.evento,
      estado: EstadoActividad.archivado,
      titulo: 'Aniversario 145 años · Acto cívico Plaza de Armas',
      descripcion: 'Acto oficial conmemorativo del aniversario de la comuna.',
      fechaInicio: DateTime(2026, 1, 5, 11, 0),
      fechaFin: DateTime(2026, 1, 5, 13, 0),
      participanteIds: const [],
      lat: -37.0896,
      lng: -73.1584,
      direccion: 'Plaza de Armas Lota',
      sector: 'Centro',
      direccionMunicipal: 'SECPLA',
      presupuestoEstimado: 3500000,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2025, 12, 20),
    ),
    ActividadMunicipal(
      id: '550e8400-e29b-41d4-a716-446655440012',
      tipo: TipoActividad.reunion,
      estado: EstadoActividad.archivado,
      titulo: 'Mesa Barrio Seguro · Diciembre',
      descripcion: 'Reunión cierre de año Mesa Barrio Seguro S-6.',
      fechaInicio: DateTime(2025, 12, 18, 18, 0),
      fechaFin: DateTime(2025, 12, 18, 20, 0),
      participanteIds: const [],
      direccion: 'Sede J.V. Lota Verde Sur',
      sector: 'S-6',
      direccionMunicipal: 'Seg. Pública',
      presupuestoEstimado: 0,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime(2025, 12, 15),
    ),
  ];
}

// ── Provider ──────────────────────────────────────────────────────────────────

class ActividadesNotifier extends Notifier<List<ActividadMunicipal>> {
  static const _storageKey = 'sigespu_actividades_v1';

  @override
  List<ActividadMunicipal> build() {
    _loadLocal().then((_) => _loadFromBackend());
    return _buildSeedActividades();
  }

  // ── Persistencia local (SharedPreferences — fiable en web y nativo) ──────────

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return;
      final List list = jsonDecode(jsonStr) as List;
      final saved = list
          .map((j) => ActividadMunicipal.fromJson(j as Map<String, dynamic>))
          .toList();
      if (saved.isEmpty) return;
      // Actividades guardadas (modificadas o nuevas) reemplazan al seed;
      // semillas sin tocar se conservan en el frente.
      final savedIds = saved.map((a) => a.id).toSet();
      final unmodifiedSeed =
          _buildSeedActividades().where((a) => !savedIds.contains(a.id));
      state = [...unmodifiedSeed, ...saved];
    } catch (e) {
      _log.warning('Error cargando locales', e);
    }
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      _log.warning('Error guardando locales', e);
    }
  }

  // ── Backend sync (best-effort) ─────────────────────────────────────────────

  Future<void> _loadFromBackend() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      const apiBase = AppConstants.apiBaseUrl;
      final api = ref.read(cachedApiProvider);

      final resp = await api.get(
        Uri.parse('$apiBase/api/actividades'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        cacheKey: 'api:/api/actividades',
      );

      if (!resp.hasData) return;

      try {
        final List list = jsonDecode(resp.body!);
        final backendItems = list
            .map((j) => ActividadMunicipal.fromJson(j as Map<String, dynamic>))
            .toList();
        if (backendItems.isNotEmpty) {
          state = backendItems;
          // Solo persistimos en SharedPreferences cuando viene fresco del backend.
          // El caché de Drift ya tiene la copia desde CachedApi.
          if (resp.isFresh) _saveLocal();
        }
      } catch (e) {
        _log.fine('Actividad mal formada del backend: $e');
      }
    } catch (e) {
      _log.warning('_loadFromBackend falló', e);
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  void add(ActividadMunicipal a) {
    state = [...state, a];
    _saveLocal();
    try {
      ref.read(syncServiceProvider).queueForSync(
        entidad: 'actividad_municipal',
        accion: 'create',
        entidadId: a.id,
        payload: a.toJson(),
      );
    } catch (_) {}
  }

  void update(ActividadMunicipal a) {
    state = state.map((e) => e.id == a.id ? a : e).toList();
    _saveLocal();
    try {
      ref.read(syncServiceProvider).queueForSync(
        entidad: 'actividad_municipal',
        accion: 'update',
        entidadId: a.id,
        payload: a.toJson(),
      );
    } catch (_) {}
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _saveLocal();
    try {
      ref.read(syncServiceProvider).queueForSync(
        entidad: 'actividad_municipal',
        accion: 'delete',
        entidadId: id,
        payload: {},
      );
    } catch (_) {}
  }

  void updateEstado(String id, EstadoActividad nuevoEstado) {
    final a = state.firstWhere((e) => e.id == id);
    final updated = a.copyWith(estado: nuevoEstado, actualizadoEn: DateTime.now());
    update(updated);
  }

  void updateActa(String id, ActaActividad acta) {
    final a = state.firstWhere((e) => e.id == id);
    final updated = a.copyWith(acta: acta, actualizadoEn: DateTime.now());
    update(updated);
  }

  void clearArchivados() {
    state = state.where((a) => a.estado != EstadoActividad.archivado).toList();
    _saveLocal();
  }

  String exportTrelloJson() {
    final colMap = {
      EstadoActividad.planificado: 'planificado',
      EstadoActividad.enCurso: 'en_curso',
      EstadoActividad.completado: 'completado',
      EstadoActividad.archivado: 'archivado',
    };
    final board = {
      'name': 'Actividades Municipales - SIGESPU Lota',
      'lists': [
        {'id': 'planificado', 'name': 'Planificado', 'closed': false},
        {'id': 'en_curso', 'name': 'En curso', 'closed': false},
        {'id': 'completado', 'name': 'Completado', 'closed': false},
        {'id': 'archivado', 'name': 'Archivado', 'closed': true},
      ],
      'cards': state.map((a) => {
        'id': a.id,
        'name': a.titulo,
        'desc': '${a.descripcion}\n\n---\nTipo: ${a.tipo.name}\nDirección Municipal: ${a.direccionMunicipal ?? ""}\nSector: ${a.sector ?? ""}\nPresupuesto: \$${a.presupuestoEstimado?.toInt() ?? 0}',
        'due': a.fechaFin?.toIso8601String(),
        'idList': colMap[a.estado],
        'labels': [
          {'name': a.tipo.name, 'color': 'purple'},
        ],
        'closed': a.estado == EstadoActividad.archivado,
      }).toList(),
    };
    return jsonEncode(board);
  }

  void importFromTrelloJson(String jsonStr) {
    final listMap = {
      'planificado': EstadoActividad.planificado,
      'en_curso': EstadoActividad.enCurso,
      'completado': EstadoActividad.completado,
      'archivado': EstadoActividad.archivado,
    };
    final tipoMap = {
      'reunion': TipoActividad.reunion,
      'operativo': TipoActividad.operativo,
      'evento': TipoActividad.evento,
      'capacitacion': TipoActividad.capacitacion,
    };

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final cards = (data['cards'] as List?) ?? [];
    final nuevas = <ActividadMunicipal>[];

    for (final card in cards) {
      final idList = card['idList'] as String? ?? 'planificado';
      final labels = (card['labels'] as List?) ?? [];
      final tipoStr = labels.isNotEmpty ? labels[0]['name'] as String? : null;
      final estado = listMap[idList] ?? EstadoActividad.planificado;
      final tipo = tipoMap[tipoStr] ?? TipoActividad.reunion;

      nuevas.add(ActividadMunicipal(
        id: card['id'] as String? ?? _uuid.v4(),
        tipo: tipo,
        estado: estado,
        titulo: card['name'] as String? ?? 'Sin título',
        descripcion: (card['desc'] as String? ?? '').split('\n\n---\n').first,
        fechaInicio: DateTime.now(),
        fechaFin: card['due'] != null ? DateTime.tryParse(card['due'] as String) : null,
        creadoPor: 'importado',
        creadoEn: DateTime.now(),
      ));
    }

    state = [...state, ...nuevas];
  }
}

final actividadesProvider =
    NotifierProvider<ActividadesNotifier, List<ActividadMunicipal>>(
  ActividadesNotifier.new,
);

// ── Derived providers ─────────────────────────────────────────────────────────

// ── Usuarios del sistema (mock para pruebas) ──────────────────────────────────

class UsuarioSistema {
  final String id;
  final String nombre;
  final String cargo;
  final String email;
  final String rut;
  const UsuarioSistema({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.email,
    required this.rut,
  });
}

const _mockUsuarios = <UsuarioSistema>[
  UsuarioSistema(id: 'u-001', nombre: 'Director Seguridad Pública',  cargo: 'Director · Seg. Pública',       email: 'director@lota.cl',   rut: '8.765.432-1'),
  UsuarioSistema(id: 'u-002', nombre: 'Rodrigo Sandoval Pérez',      cargo: 'Coord. Seg. Pública',           email: 'rsandoval@lota.cl',  rut: '15.842.119-3'),
  UsuarioSistema(id: 'u-003', nombre: 'Daniela Salgado Muñoz',       cargo: 'Dir. de Tránsito',             email: 'dsalgado@lota.cl',   rut: '12.487.661-9'),
  UsuarioSistema(id: 'u-004', nombre: 'Luis Henríquez Castro',        cargo: 'Dir. de Obras Municipales',    email: 'lhenriquez@lota.cl', rut: '16.998.241-K'),
  UsuarioSistema(id: 'u-005', nombre: 'Paula Riffo Valencia',         cargo: 'Inspectora Seg. Pública',      email: 'priffo@lota.cl',     rut: '18.221.554-2'),
  UsuarioSistema(id: 'u-006', nombre: 'María José Cerda Ríos',        cargo: 'Administrativo · DIDECO',      email: 'mjcerda@lota.cl',    rut: '14.556.083-7'),
  UsuarioSistema(id: 'u-007', nombre: 'Carlos Vergara Solís',         cargo: 'Inspector Municipal',          email: 'cvergara@lota.cl',   rut: '10.118.443-6'),
  UsuarioSistema(id: 'u-008', nombre: 'Ximena Toro Aravena',          cargo: 'DIDECO · Adulto Mayor',        email: 'xtoro@munilota.cl',  rut: '13.776.220-4'),
  UsuarioSistema(id: 'u-009', nombre: 'Francisco Muñoz Pedreros',     cargo: 'Jefe Operaciones · Tránsito',  email: 'fmunoz@lota.cl',     rut: '11.432.887-5'),
  UsuarioSistema(id: 'u-010', nombre: 'Ana García Leiva',             cargo: 'Secretaria SECPLA',            email: 'agarcia@munilota.cl', rut: '17.654.321-8'),
];

final usuariosSistemaProvider = Provider<List<UsuarioSistema>>((_) => _mockUsuarios);

// ── Filter state ──────────────────────────────────────────────────────────────

final actividadesSearchProvider   = StateProvider<String>((ref) => '');
final actividadesTipoFilterProvider = StateProvider<TipoActividad?>((ref) => null);
final actividadesDeptFilterProvider = StateProvider<String?>((ref) => null);
final actividadesDateFromProvider   = StateProvider<DateTime?>((ref) => null);
final actividadesDateToProvider     = StateProvider<DateTime?>((ref) => null);

// ── Filtered + sorted actividades ─────────────────────────────────────────────

final actividadesFiltadasProvider = Provider<List<ActividadMunicipal>>((ref) {
  final all      = ref.watch(actividadesProvider);
  final query    = ref.watch(actividadesSearchProvider).toLowerCase();
  final tipo     = ref.watch(actividadesTipoFilterProvider);
  final dept     = ref.watch(actividadesDeptFilterProvider);
  final dateFrom = ref.watch(actividadesDateFromProvider);
  final dateTo   = ref.watch(actividadesDateToProvider);

  final filtered = all.where((a) {
    if (tipo != null && a.tipo != tipo) return false;
    if (dept != null && a.direccionMunicipal != dept) return false;
    if (dateFrom != null && a.fechaInicio.isBefore(dateFrom)) return false;
    if (dateTo != null) {
      final endOfDay = DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);
      if (a.fechaInicio.isAfter(endOfDay)) return false;
    }
    if (query.isNotEmpty &&
        !a.titulo.toLowerCase().contains(query) &&
        !a.descripcion.toLowerCase().contains(query)) {
      return false;
    }
    return true;
  }).toList();

  filtered.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
  return filtered;
});

/// Alias for actividadesFiltadasProvider — used by PDF export and map panel.
final filteredActividadesProvider = Provider<List<ActividadMunicipal>>((ref) {
  return ref.watch(actividadesFiltadasProvider);
});

/// Filtered + grouped por estado.
///
/// Cada columna del kanban observa solo SU estado: cuando un drag mueve una
/// tarjeta de "Planificado" a "En curso" solo se reconstruyen esas dos
/// columnas, no las cuatro.
final actividadesFiltradasPorEstadoProvider =
    Provider.family<List<ActividadMunicipal>, EstadoActividad>((ref, estado) {
  return ref
      .watch(actividadesFiltadasProvider)
      .where((a) => a.estado == estado)
      .toList(growable: false);
});
