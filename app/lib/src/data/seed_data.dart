import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ElementoMapa {
  final String id;
  final String tipo;
  final String nombre;
  final String direccion;
  final String sector;
  final double lat;
  final double lng;
  final String estado;
  final String fecha;
  final String by;
  final String notas;
  // Campos opcionales según tipo
  final int? capacidad;
  final String? rut;
  final String? giro;
  final String? tipoPeligro;
  final int? nivel;
  final String? horario;
  final String? vigenciaHasta;
  final String? rubro; // Agregado para edición
  final String? tipoAmenaza; // Agregado para edición

  const ElementoMapa({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.direccion,
    required this.sector,
    required this.lat,
    required this.lng,
    required this.estado,
    required this.fecha,
    required this.by,
    required this.notas,
    this.capacidad,
    this.rut,
    this.giro,
    this.tipoPeligro,
    this.nivel,
    this.horario,
    this.vigenciaHasta,
    this.rubro,
    this.tipoAmenaza,
  });

  LatLng get coordenadas => LatLng(lat, lng);
  LatLng get latLng => LatLng(lat, lng);

  String get layerKey => tipo;

  ElementoMapa copyWith({
    String? id,
    String? tipo,
    String? nombre,
    String? direccion,
    String? sector,
    double? lat,
    double? lng,
    String? estado,
    String? fecha,
    String? by,
    String? notas,
    int? capacidad,
    String? rut,
    String? giro,
    String? tipoPeligro,
    int? nivel,
    String? horario,
    String? vigenciaHasta,
    String? rubro,
    String? tipoAmenaza,
  }) {
    return ElementoMapa(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      sector: sector ?? this.sector,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      by: by ?? this.by,
      notas: notas ?? this.notas,
      capacidad: capacidad ?? this.capacidad,
      rut: rut ?? this.rut,
      giro: giro ?? this.giro,
      tipoPeligro: tipoPeligro ?? this.tipoPeligro,
      nivel: nivel ?? this.nivel,
      horario: horario ?? this.horario,
      vigenciaHasta: vigenciaHasta ?? this.vigenciaHasta,
      rubro: rubro ?? this.rubro,
      tipoAmenaza: tipoAmenaza ?? this.tipoAmenaza,
    );
  }
}


class DatoPatente {
  final int nDecreto;
  final String fechaDecreto;
  final String tipo;
  final String rut;
  final String razonSocial;
  final String giro;
  final String direccion;
  final double lat;
  final double lng;
  final String confianza; // high | med | low | failed
  final String url;
  final String scrapedAt;

  const DatoPatente({
    required this.nDecreto,
    required this.fechaDecreto,
    required this.tipo,
    required this.rut,
    required this.razonSocial,
    required this.giro,
    required this.direccion,
    required this.lat,
    required this.lng,
    required this.confianza,
    required this.url,
    required this.scrapedAt,
  });
}

class DatoPermiso {
  final String nPermiso;
  final String tipo;
  final String direccion;
  final String sector;
  final double lat;
  final double lng;
  final String descripcion;
  final String fecha;
  final String estado;
  final String confianza;
  final String url;

  const DatoPermiso({
    required this.nPermiso,
    required this.tipo,
    required this.direccion,
    required this.sector,
    required this.lat,
    required this.lng,
    required this.descripcion,
    required this.fecha,
    required this.estado,
    required this.confianza,
    required this.url,
  });
}

class DatoTransito {
  final String nDecreto;
  final String tipo;
  final String direccion;
  final String motivo;
  final String fechaInicio;
  final String fechaFin;
  final String estado;
  final String url;

  const DatoTransito({
    required this.nDecreto,
    required this.tipo,
    required this.direccion,
    required this.motivo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.url,
  });
}

class DatoOrganizacion {
  final String nPersonalidad;
  final String tipo;
  final String nombre;
  final String direccion;
  final String representante;
  final String rutRep;
  final String vigencia;
  final String sector;
  final String url;

  const DatoOrganizacion({
    required this.nPersonalidad,
    required this.tipo,
    required this.nombre,
    required this.direccion,
    required this.representante,
    required this.rutRep,
    required this.vigencia,
    required this.sector,
    required this.url,
  });
}

// ── Helpers de UI ──────────────────────────────────────────────────────────────

Color colorParaTipo(String tipo) {
  switch (tipo) {
    case 'centro_acopio': return const Color(0xFFEA580C);
    case 'sede_comunitaria': return const Color(0xFF16A34A);
    case 'infraestructura': return const Color(0xFF1E3A8A);
    case 'reporte_robo': return const Color(0xFFB91C1C);
    case 'reporte_vandalismo': return const Color(0xFFA855F7);
    case 'reporte_accidente': return const Color(0xFFF97316);
    case 'zona_peligro': return const Color(0xFFB91C1C);
    case 'patente': return const Color(0xFFD97706);
    case 'luminaria': return const Color(0xFFEAB308);
    case 'camara':
    case 'camara_cctv': return const Color(0xFF8B5CF6);
    case 'arbol_caido': return const Color(0xFF65A30D);
    case 'poste_caido': return const Color(0xFFEA580C);
    case 'sector_sin_luz': return const Color(0xFF1E293B);
    case 'cable_colgando': return const Color(0xFFF97316);
    case 'semaforo_dañado': return const Color(0xFFDC2626);
    case 'socavon': return const Color(0xFF78350F);
    case 'fuga_agua': return const Color(0xFF0284C7);
    case 'microbasural': return const Color(0xFF92400E);
    default: return const Color(0xFF78716C);
  }
}

String nombreParaTipo(String tipo) {
  const nombres = {
    'centro_acopio': 'Centro de acopio',
    'sede_comunitaria': 'Sede comunitaria',
    'infraestructura': 'Infraestructura pública',
    'reporte_robo': 'Robo',
    'reporte_vandalismo': 'Vandalismo',
    'reporte_accidente': 'Accidente',
    'zona_peligro': 'Zona de peligro',
    'patente': 'Patente comercial',
    'luminaria': 'Luminaria',
    'camara': 'Cámara CCTV',
    'camara_cctv': 'Cámara CCTV',
    'arbol_caido': 'Árbol caído',
    'poste_caido': 'Poste caído',
    'sector_sin_luz': 'Sector sin luz',
    'cable_colgando': 'Cable colgando',
    'semaforo_dañado': 'Semáforo dañado',
    'socavon': 'Socavón / Hoyo',
    'fuga_agua': 'Fuga de agua',
    'microbasural': 'Microbasural',
  };
  return nombres[tipo] ?? tipo;
}

String categoriaParaTipo(String tipo) {
  const cat1 = {'centro_acopio', 'sede_comunitaria', 'infraestructura'};
  const cat2 = {'zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente'};
  const cat3 = {'arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando', 'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural'};
  const cat4 = {'patente', 'luminaria', 'camara', 'camara_cctv'};

  if (cat1.contains(tipo)) return 'infraestructura';
  if (cat2.contains(tipo)) return 'seguridad';
  if (cat3.contains(tipo)) return 'incidente';
  if (cat4.contains(tipo)) return 'fiscalizacion';
  return 'otra';
}



Color colorParaConfianza(String confianza) {
  switch (confianza) {
    case 'high': return const Color(0xFF15803D);
    case 'med': return const Color(0xFFCA8A04);
    case 'low': return const Color(0xFFB91C1C);
    default: return const Color(0xFF78716C);
  }
}

String labelParaConfianza(String confianza) {
  switch (confianza) {
    case 'high': return 'Alta';
    case 'med': return 'Media';
    case 'low': return 'Baja';
    default: return 'Fallo';
  }
}

Color bgParaConfianza(String confianza) {
  switch (confianza) {
    case 'high': return const Color(0xFFDCFCE7);
    case 'med': return const Color(0xFFFEF3C7);
    case 'low': return const Color(0xFFFEE2E2);
    default: return const Color(0xFFE7E5E4);
  }
}

Color colorParaEstado(String estado) {
  switch (estado) {
    case 'activo':
    case 'vigente':
    case 'ejecutado': return const Color(0xFF15803D);
    case 'en_revision': return const Color(0xFFCA8A04);
    case 'cerrado':
    case 'finalizado': return const Color(0xFF78716C);
    case 'vencido': return const Color(0xFFB91C1C);
    default: return const Color(0xFF78716C);
  }
}

Color bgParaEstado(String estado) {
  switch (estado) {
    case 'activo':
    case 'vigente':
    case 'ejecutado': return const Color(0xFFDCFCE7);
    case 'en_revision': return const Color(0xFFFEF3C7);
    case 'cerrado':
    case 'finalizado': return const Color(0xFFE7E5E4);
    case 'vencido': return const Color(0xFFFEE2E2);
    default: return const Color(0xFFE7E5E4);
  }
}

// ── Datos seed ─────────────────────────────────────────────────────────────────

const List<ElementoMapa> kElementosSeed = [
  // Centros de acopio
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440001', tipo: 'centro_acopio', nombre: 'Gimnasio Municipal Lota', direccion: 'Carlos Cousiño 135, Lota', sector: 'Centro',
    lat: -37.0999, lng: -73.1559, capacidad: 200, estado: 'activo', fecha: '2024-08-12',
    by: 'Dirección Seguridad Pública', notas: 'Capacidad 200 personas. Cuenta con baños, duchas y bodega.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440002', tipo: 'centro_acopio', nombre: 'Escuela Carlos Cousiño', direccion: 'Pedro A. Cerda 701, Lota', sector: 'Centro',
    lat: -37.0935, lng: -73.1548, capacidad: 350, estado: 'activo', fecha: '2024-09-20',
    by: 'Dirección Seguridad Pública', notas: 'Centro educacional habilitado para emergencias. Generador propio.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440003', tipo: 'centro_acopio', nombre: 'Liceo Juan Antonio Ríos', direccion: 'Monseñor Fuenzalida 1050', sector: 'S-5',
    lat: -37.0735, lng: -73.1630, capacidad: 180, estado: 'activo', fecha: '2025-02-10',
    by: 'Dirección Seguridad Pública', notas: 'Gimnasio techado, cocina industrial.'),

  // Sedes comunitarias
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440004', tipo: 'sede_comunitaria', nombre: 'JJ.VV. Los Aromos', direccion: 'Los Aromos 245', sector: 'S-2',
    lat: -37.0845, lng: -73.1640, estado: 'activo', fecha: '2023-05-15',
    by: 'DIDECO', notas: 'Presidenta: María Hernández. Reuniones viernes 19:00.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440005', tipo: 'sede_comunitaria', nombre: 'Junta Vecinal El Esfuerzo', direccion: 'Pabellón 4, Lota Alto', sector: 'Centro',
    lat: -37.0910, lng: -73.1515, estado: 'activo', fecha: '2023-11-03',
    by: 'DIDECO', notas: 'Sede con 45 familias asociadas.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440006', tipo: 'sede_comunitaria', nombre: 'Centro de Madres Nueva Vida', direccion: 'Vista Hermosa 890', sector: 'S-3',
    lat: -37.0805, lng: -73.1635, estado: 'activo', fecha: '2024-01-22',
    by: 'DIDECO', notas: 'Talleres de costura y repostería.'),

  // Patentes
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440007', tipo: 'patente', nombre: 'COMERCIAL TRINUM SPA', direccion: 'Vista Hermosa 1199, Lota', sector: 'S-3',
    lat: -37.0810, lng: -73.1622, rut: '77.173.367-0', giro: 'Bodega venta al por menor',
    estado: 'activo', fecha: '2026-03-30', by: 'Scraping Transparencia', notas: 'Patente otorgada marzo 2026.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440008', tipo: 'patente', nombre: 'ALMACÉN DOÑA CLARA', direccion: 'P. A. Cerda 808 Local B, Lota', sector: 'Centro',
    lat: -37.0960, lng: -73.1555, rut: '9.876.543-2', giro: 'Almacén de abarrotes',
    estado: 'activo', fecha: '2025-11-15', by: 'Scraping Transparencia', notas: 'Funcionamiento de lunes a domingo.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440009', tipo: 'patente', nombre: 'FERRETERÍA LOS AROMOS', direccion: 'Los Aromos 412', sector: 'S-2',
    lat: -37.0840, lng: -73.1655, rut: '76.543.210-1', giro: 'Venta ferretería y materiales',
    estado: 'en_revision', fecha: '2024-06-01', by: 'Scraping Transparencia', notas: 'Patente próxima a vencer.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440010', tipo: 'patente', nombre: 'PANADERÍA EL BUEN PAN', direccion: 'Matta 1205', sector: 'Centro',
    lat: -37.0965, lng: -73.1578, rut: '8.123.456-7', giro: 'Elaboración y venta de pan',
    estado: 'activo', fecha: '2026-01-15', by: 'Scraping Transparencia', notas: 'Producción artesanal diaria.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440011', tipo: 'patente', nombre: 'MINIMARKET LOTA ALTO', direccion: 'Caupolicán 560', sector: 'Centro',
    lat: -37.0920, lng: -73.1510, rut: '77.889.910-K', giro: 'Minimarket con venta alcoholes',
    estado: 'activo', fecha: '2025-09-01', by: 'Scraping Transparencia', notas: 'Patente alcohol restringida a viernes y sábados.'),

  // Zonas de peligro
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440012', tipo: 'zona_peligro', nombre: 'Esquina Los Aromos / Vista Hermosa', direccion: 'Intersección Los Aromos / Vista Hermosa', sector: 'S-2',
    lat: -37.0820, lng: -73.1645, tipoPeligro: 'drogas', nivel: 4, estado: 'activo',
    fecha: '2026-04-15', by: 'R. Sepúlveda · Funcionario', notas: 'Presencia habitual de microtráfico en horario nocturno (22:00-04:00).',
    vigenciaHasta: '2026-07-15', horario: 'Nocturno (22:00-04:00)'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440013', tipo: 'zona_peligro', nombre: 'Pasaje sin nombre sector norte', direccion: 'Pasaje interior S-5', sector: 'S-5',
    lat: -37.0730, lng: -73.1625, tipoPeligro: 'vivienda_ilegal', nivel: 5, estado: 'activo',
    fecha: '2026-04-10', by: 'Dir. Seguridad Pública', notas: 'Campamento con 8 viviendas sin autorización. Terreno municipal.',
    horario: '24/7'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440014', tipo: 'zona_peligro', nombre: 'Plaza Centro – robos a transeúntes', direccion: 'Plaza de Armas Lota', sector: 'Centro',
    lat: -37.0985, lng: -73.1555, tipoPeligro: 'robos', nivel: 3, estado: 'activo',
    fecha: '2026-04-05', by: 'C. Muñoz · Funcionario', notas: 'Registro de 7 robos en las últimas 3 semanas.',
    vigenciaHasta: '2026-05-30', horario: 'Tarde/Noche'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440015', tipo: 'zona_peligro', nombre: 'Sector calle peatonal', direccion: 'Calle peatonal Lota Alto', sector: 'Centro',
    lat: -37.0915, lng: -73.1525, tipoPeligro: 'vandalismo', nivel: 2, estado: 'activo',
    fecha: '2026-03-28', by: 'P. Castro · Funcionario', notas: 'Rayados frecuentes en fachadas patrimoniales.',
    horario: 'Fines de semana'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440016', tipo: 'zona_peligro', nombre: 'Salida Liceo JA Ríos', direccion: 'Monseñor Fuenzalida esquina', sector: 'S-5',
    lat: -37.0738, lng: -73.1625, tipoPeligro: 'riña', nivel: 3, estado: 'activo',
    fecha: '2026-04-18', by: 'R. Sepúlveda · Funcionario', notas: 'Riñas entre escolares a la salida del liceo.',
    vigenciaHasta: '2026-06-30', horario: '13:00-17:00 días hábiles'),

  // Reportes
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440017', tipo: 'reporte_robo', nombre: 'Robo con intimidación', direccion: 'Carlos Cousiño 340', sector: 'Centro',
    lat: -37.0995, lng: -73.1570, estado: 'activo', fecha: '2026-04-22', by: 'R. Sepúlveda', notas: 'Víctima denunció robo de celular. Derivado a Carabineros.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440018', tipo: 'reporte_vandalismo', nombre: 'Rayado en fachada municipal', direccion: 'Plaza de Armas Lota', sector: 'Centro',
    lat: -37.0988, lng: -73.1555, estado: 'cerrado', fecha: '2026-04-19', by: 'P. Castro', notas: 'Limpieza realizada por cuadrilla municipal el 21 de abril.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440019', tipo: 'reporte_accidente', nombre: 'Colisión vehicular', direccion: 'Av. Pedro Aguirre Cerda 850', sector: 'Centro',
    lat: -37.0945, lng: -73.1542, estado: 'cerrado', fecha: '2026-04-20', by: 'C. Muñoz', notas: 'Colisión sin lesionados. Vehículos retirados por grúa municipal.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440020', tipo: 'reporte_robo', nombre: 'Robo en vivienda', direccion: 'Los Aromos 512', sector: 'S-2',
    lat: -37.0844, lng: -73.1648, estado: 'en_revision', fecha: '2026-04-21', by: 'R. Sepúlveda', notas: 'Presunto ingreso por patio trasero. Denuncia en curso.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440021', tipo: 'reporte_vandalismo', nombre: 'Daño paradero', direccion: 'Vista Hermosa 1050', sector: 'S-3',
    lat: -37.0810, lng: -73.1625, estado: 'activo', fecha: '2026-04-23', by: 'P. Castro', notas: 'Paradero con vidrios rotos. Requiere reparación por DOM.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440022', tipo: 'reporte_robo', nombre: 'Hurto en comercio', direccion: 'Matta 1105', sector: 'Centro',
    lat: -37.0960, lng: -73.1572, estado: 'activo', fecha: '2026-04-15', by: 'C. Muñoz', notas: 'Comerciante reporta pérdida de mercadería. Revisan cámaras CCTV.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440023', tipo: 'reporte_accidente', nombre: 'Caída de árbol', direccion: 'Monseñor Fuenzalida 980', sector: 'S-5',
    lat: -37.0740, lng: -73.1620, estado: 'cerrado', fecha: '2026-04-17', by: 'R. Sepúlveda', notas: 'Árbol caído por viento. Retirado por emergencia municipal.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440024', tipo: 'reporte_robo', nombre: 'Robo en local comercial', direccion: 'P. A. Cerda 702', sector: 'Centro',
    lat: -37.0940, lng: -73.1548, estado: 'activo', fecha: '2026-04-11', by: 'P. Castro', notas: 'Forzamiento de cortinas metálicas durante la madrugada.'),

  // Infraestructura
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440025', tipo: 'infraestructura', nombre: 'I. Municipalidad de Lota', direccion: 'Pedro Aguirre Cerda 302', sector: 'Centro',
    lat: -37.0961, lng: -73.1562, estado: 'activo', fecha: '1960-01-01', by: 'Registro histórico', notas: 'Edificio principal del municipio.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440026', tipo: 'infraestructura', nombre: 'Hospital Lota', direccion: 'Aníbal Pinto 1170', sector: 'Centro',
    lat: -37.0929, lng: -73.1570, estado: 'activo', fecha: '1990-01-01', by: 'Registro histórico', notas: 'Hospital de baja complejidad, atención 24h.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440027', tipo: 'infraestructura', nombre: '1ª Compañía Bomberos Lota', direccion: 'Galvarino 580', sector: 'Centro',
    lat: -37.0975, lng: -73.1540, estado: 'activo', fecha: '1915-01-01', by: 'Registro histórico', notas: 'Cuartel de Bomberos.'),

  // Incidentes urbanos
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440028', tipo: 'arbol_caido', nombre: 'Árbol caído sobre calzada', direccion: 'Los Aromos 380', sector: 'S-2',
    lat: -37.0846, lng: -73.1652, estado: 'activo', fecha: '2026-04-23', by: 'R. Sepúlveda', notas: 'Árbol de eucalipto caído por viento. Bloquea parcialmente el tránsito.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440029', tipo: 'poste_caido', nombre: 'Poste eléctrico inclinado', direccion: 'Monseñor Fuenzalida 1020', sector: 'S-5',
    lat: -37.0738, lng: -73.1628, estado: 'activo', fecha: '2026-04-22', by: 'C. Muñoz', notas: 'Poste con inclinación peligrosa tras temporal. Derivado a CGE. URGENTE.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440030', tipo: 'sector_sin_luz', nombre: 'Sector nororiente sin luminarias', direccion: 'Sector completo Vista Hermosa alto', sector: 'S-3',
    lat: -37.0800, lng: -73.1620, estado: 'activo', fecha: '2026-04-20', by: 'P. Castro', notas: '8 luminarias consecutivas apagadas en 3 cuadras.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440031', tipo: 'cable_colgando', nombre: 'Cable telefónico colgando', direccion: 'Matta esq. Caupolicán', sector: 'Centro',
    lat: -37.0960, lng: -73.1565, estado: 'activo', fecha: '2026-04-21', by: 'R. Sepúlveda', notas: 'Cable a baja altura, riesgo para vehículos de carga. Reportado a Movistar.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440032', tipo: 'socavon', nombre: 'Socavón en calzada', direccion: 'Pedro Aguirre Cerda 450', sector: 'Centro',
    lat: -37.0955, lng: -73.1553, estado: 'activo', fecha: '2026-04-19', by: 'C. Muñoz', notas: 'Hoyo de aprox. 80cm de diámetro. Señalizado con conos.'),
  ElementoMapa(id: '770e8400-e29b-41d4-a716-446655440033', tipo: 'fuga_agua', nombre: 'Filtración desde matriz', direccion: 'Vista Hermosa 1240', sector: 'S-3',
    lat: -37.0812, lng: -73.1618, estado: 'en_revision', fecha: '2026-04-17', by: 'P. Castro', notas: 'Agua aflorando desde la calzada. Derivado a ESSBIO.'),
];

// ── Datos scraping ──────────────────────────────────────────────────────────────

const List<DatoPatente> kPatentes = [
  DatoPatente(nDecreto: 1852, fechaDecreto: '2026-03-30', tipo: 'Comercial definitiva', rut: '77.173.367-0', razonSocial: 'COMERCIAL Y SERVICIOS TRINUM SPA', giro: 'Bodega venta al por menor no especificada', direccion: 'Vista Hermosa 1199', lat: -37.0810, lng: -73.1622, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=3&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1837, fechaDecreto: '2026-03-22', tipo: 'MEF', rut: '19.876.543-2', razonSocial: 'MARÍA FERNANDA SOTO ÁLVAREZ', giro: 'Servicios de peluquería', direccion: 'P.A. Cerda 1204', lat: -37.0952, lng: -73.1542, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=3&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1819, fechaDecreto: '2026-03-15', tipo: 'Alcoholes', rut: '77.889.910-K', razonSocial: 'MINIMARKET LOTA ALTO LIMITADA', giro: 'Minimarket con expendio de alcoholes', direccion: 'Caupolicán 560', lat: -37.0920, lng: -73.1510, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=3&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1798, fechaDecreto: '2026-02-28', tipo: 'Profesional', rut: '13.456.789-1', razonSocial: 'JUAN PABLO CONTRERAS LÓPEZ', giro: 'Contador auditor', direccion: 'Serrano 485 of. 301', lat: -37.0968, lng: -73.1560, confianza: 'med', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=2&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1776, fechaDecreto: '2026-02-18', tipo: 'Comercial definitiva', rut: '9.876.543-2', razonSocial: 'SOCIEDAD COMERCIAL DOÑA CLARA LTDA.', giro: 'Almacén de abarrotes y productos varios', direccion: 'P. A. Cerda 808 Local B', lat: -37.0960, lng: -73.1555, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=2&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1754, fechaDecreto: '2026-02-10', tipo: 'Comercial definitiva', rut: '76.111.222-3', razonSocial: 'DISTRIBUIDORA Y COMERCIAL LOS AROMOS EIRL', giro: 'Venta de frutas y verduras', direccion: 'Los Aromos 290', lat: -37.0842, lng: -73.1650, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=2&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1732, fechaDecreto: '2026-01-22', tipo: 'MEF', rut: '20.123.456-7', razonSocial: 'RODRIGO IGNACIO PÉREZ SEPÚLVEDA', giro: 'Taller mecánico automotriz', direccion: 'Aníbal Pinto 1020', lat: -37.0930, lng: -73.1568, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=1&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1718, fechaDecreto: '2026-01-15', tipo: 'Alcoholes', rut: '8.123.456-7', razonSocial: 'PANADERÍA EL BUEN PAN LTDA.', giro: 'Elaboración y venta de pan con cerveza de botellería', direccion: 'Matta 1205', lat: -37.0965, lng: -73.1578, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=1&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1701, fechaDecreto: '2026-01-08', tipo: 'Comercial definitiva', rut: '76.543.210-1', razonSocial: 'FERRETERÍA LOS AROMOS LTDA.', giro: 'Venta ferretería y materiales de construcción', direccion: 'Los Aromos 412', lat: -37.0840, lng: -73.1655, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=1&a=2026', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1695, fechaDecreto: '2025-12-28', tipo: 'Profesional', rut: '15.678.901-K', razonSocial: 'CAROLINA MUÑOZ ESPINOZA', giro: 'Psicóloga clínica', direccion: 'Galvarino 712', lat: -37.0978, lng: -73.1543, confianza: 'med', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=12&a=2025', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1672, fechaDecreto: '2025-12-15', tipo: 'Comercial definitiva', rut: '77.234.567-8', razonSocial: 'INVERSIONES CHICO SPA', giro: 'Restaurant con expendio de alcoholes', direccion: 'Aníbal Pinto 580', lat: -37.0933, lng: -73.1565, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=12&a=2025', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1654, fechaDecreto: '2025-11-20', tipo: 'MEF', rut: '18.345.678-9', razonSocial: 'ANDREA SOLEDAD CASTRO ROJAS', giro: 'Manicure y servicios de belleza a domicilio', direccion: 'Pabellón 7 S/N Lota Alto', lat: -37.0905, lng: -73.1520, confianza: 'low', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=11&a=2025', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1621, fechaDecreto: '2025-10-30', tipo: 'Comercial definitiva', rut: '76.999.888-2', razonSocial: 'SOCIEDAD COMERCIAL EL ESFUERZO LTDA.', giro: 'Botillería', direccion: 'Pabellón 4, Lota Alto', lat: 0, lng: 0, confianza: 'failed', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=10&a=2025', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1599, fechaDecreto: '2025-10-15', tipo: 'Alcoholes', rut: '77.678.901-K', razonSocial: 'BAR RESTAURANT EL MINERO LTDA.', giro: 'Restaurant con expendio de alcoholes', direccion: 'Carlos Cousiño 280', lat: -37.0992, lng: -73.1570, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=10&a=2025', scrapedAt: '2026-04-24 03:02'),
  DatoPatente(nDecreto: 1577, fechaDecreto: '2025-09-25', tipo: 'Comercial definitiva', rut: '76.555.444-3', razonSocial: 'BAZAR LIBRERÍA LUNA LTDA.', giro: 'Bazar y librería escolar', direccion: 'Matta 980', lat: -37.0962, lng: -73.1572, confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=164&m=9&a=2025', scrapedAt: '2026-04-24 03:02'),
];

const List<DatoPermiso> kPermisos = [
  DatoPermiso(nPermiso: 'PE-2026-042', tipo: 'Edificación nueva', direccion: 'Los Aromos 512', sector: 'S-2', lat: -37.0844, lng: -73.1648, descripcion: 'Ampliación vivienda 45m²', fecha: '2026-04-10', estado: 'activo', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=4&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-041', tipo: 'Demolición', direccion: 'Serrano 345', sector: 'Centro', lat: -37.0970, lng: -73.1562, descripcion: 'Demolición estructura en mal estado', fecha: '2026-04-08', estado: 'activo', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=4&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-038', tipo: 'Cambio de uso', direccion: 'P.A. Cerda 820', sector: 'Centro', lat: -37.0956, lng: -73.1550, descripcion: 'Cambio uso habitacional a comercial', fecha: '2026-04-03', estado: 'activo', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=4&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-035', tipo: 'Edificación nueva', direccion: 'Vista Hermosa 1250', sector: 'S-3', lat: -37.0815, lng: -73.1620, descripcion: 'Construcción vivienda 78m²', fecha: '2026-03-28', estado: 'activo', confianza: 'med', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=3&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-030', tipo: 'Ampliación', direccion: 'Caupolicán 605', sector: 'Centro', lat: -37.0922, lng: -73.1515, descripcion: 'Ampliación local comercial 25m²', fecha: '2026-03-20', estado: 'vencido', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=3&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-025', tipo: 'Regularización', direccion: 'Monseñor Fuenzalida 1080', sector: 'S-5', lat: -37.0735, lng: -73.1625, descripcion: 'Regularización construcción existente', fecha: '2026-03-10', estado: 'activo', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=3&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-020', tipo: 'Edificación nueva', direccion: 'Los Aromos 245', sector: 'S-2', lat: -37.0845, lng: -73.1640, descripcion: 'Construcción galpón 120m²', fecha: '2026-02-25', estado: 'ejecutado', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=2&a=2026'),
  DatoPermiso(nPermiso: 'PE-2026-015', tipo: 'Demolición', direccion: 'Aníbal Pinto 990', sector: 'Centro', lat: -37.0935, lng: -73.1568, descripcion: 'Demolición parcial, conserva fachada patrimonial', fecha: '2026-02-12', estado: 'activo', confianza: 'high', url: 'https://www.lotatransparente.cl/index.php?ig=172&m=2&a=2026'),
];

const List<DatoTransito> kTransito = [
  DatoTransito(nDecreto: 'DT-2026-018', tipo: 'Corte de calle', direccion: 'Carlos Cousiño (entre Galvarino y Matta)', motivo: 'Obras de pavimentación', fechaInicio: '2026-04-22', fechaFin: '2026-05-15', estado: 'vigente', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=4&a=2026'),
  DatoTransito(nDecreto: 'DT-2026-017', tipo: 'Sentido único transitorio', direccion: 'Matta (tramo norte)', motivo: 'Obras de alcantarillado', fechaInicio: '2026-04-15', fechaFin: '2026-05-10', estado: 'vigente', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=4&a=2026'),
  DatoTransito(nDecreto: 'DT-2026-015', tipo: 'Zona estacionamiento prohibido', direccion: 'Galvarino (frente Bomberos)', motivo: 'Operación cuartel', fechaInicio: '2026-04-01', fechaFin: 'indefinido', estado: 'vigente', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=4&a=2026'),
  DatoTransito(nDecreto: 'DT-2026-010', tipo: 'Corte total fin de semana', direccion: 'Plaza de Armas y calles aledañas', motivo: 'Feria costumbrista', fechaInicio: '2026-03-21', fechaFin: '2026-03-22', estado: 'finalizado', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=3&a=2026'),
  DatoTransito(nDecreto: 'DT-2026-008', tipo: 'Restricción vehículos pesados', direccion: 'Aníbal Pinto (todo su trazado)', motivo: 'Protección pavimento', fechaInicio: '2026-03-01', fechaFin: 'indefinido', estado: 'vigente', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=3&a=2026'),
  DatoTransito(nDecreto: 'DT-2026-003', tipo: 'Paradero transitorio', direccion: 'Los Aromos 380', motivo: 'Obras paradero permanente', fechaInicio: '2026-02-10', fechaFin: '2026-03-30', estado: 'finalizado', url: 'https://www.lotatransparente.cl/index.php?ig=269&m=2&a=2026'),
];

const List<DatoOrganizacion> kOrganizaciones = [
  DatoOrganizacion(nPersonalidad: '3421', tipo: 'Junta de Vecinos', nombre: 'JJ.VV. Los Aromos', direccion: 'Los Aromos 245', representante: 'María Hernández Parra', rutRep: '12.345.678-9', vigencia: 'Vigente hasta 2027-05-30', sector: 'S-2', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '3398', tipo: 'Junta de Vecinos', nombre: 'Junta Vecinal El Esfuerzo', direccion: 'Pabellón 4, Lota Alto', representante: 'Carlos Sanhueza Vera', rutRep: '10.987.654-3', vigencia: 'Vigente hasta 2026-11-20', sector: 'Centro', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '3287', tipo: 'Centro de Madres', nombre: 'Centro de Madres Nueva Vida', direccion: 'Vista Hermosa 890', representante: 'Alejandra Roa Mella', rutRep: '14.567.890-2', vigencia: 'Vigente hasta 2027-01-15', sector: 'S-3', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '3145', tipo: 'Club Deportivo', nombre: 'Club Deportivo Minero', direccion: 'Cancha Los Aromos', representante: 'Pedro Cifuentes Luna', rutRep: '11.222.333-4', vigencia: 'Vigente hasta 2026-08-30', sector: 'S-2', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '3098', tipo: 'Junta de Vecinos', nombre: 'JJ.VV. Vista Hermosa', direccion: 'Vista Hermosa 1150', representante: 'Rosa Mardones Gutierrez', rutRep: '13.444.555-6', vigencia: 'Vigente hasta 2026-12-10', sector: 'S-3', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '2987', tipo: 'Adulto Mayor', nombre: 'Club Adulto Mayor Los Pioneros', direccion: 'Sede Carlos Cousiño 320', representante: 'Juan Espinoza Vega', rutRep: '6.789.012-3', vigencia: 'Vigente hasta 2027-03-20', sector: 'Centro', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '2876', tipo: 'Comité', nombre: 'Comité de Allegados La Esperanza', direccion: 'Sector Lota Alto Norte', representante: 'Patricia Bravo Núñez', rutRep: '15.678.901-2', vigencia: 'Vigente hasta 2026-07-15', sector: 'S-5', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
  DatoOrganizacion(nPersonalidad: '2754', tipo: 'Junta de Vecinos', nombre: 'JJ.VV. Los Mineros', direccion: 'Pabellón 7, Lota Alto', representante: 'Sergio Aravena Pino', rutRep: '9.123.456-K', vigencia: 'Vigente hasta 2027-02-28', sector: 'Centro', url: 'https://www.lotatransparente.cl/index.php?ig=351'),
];
