import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../map/providers/map_providers.dart';

class ScrapingScreen extends ConsumerStatefulWidget {
  const ScrapingScreen({super.key});

  @override
  ConsumerState<ScrapingScreen> createState() => _ScrapingScreenState();
}

class _ScrapingScreenState extends ConsumerState<ScrapingScreen> {
  int _tab = 0; // 0=patentes, 1=permisos, 2=transito, 3=orgs
  String _year = 'all';
  String _month = 'all';
  String _geo = 'all';
  String _search = '';

  static const _tabLabels = ['Patentes comerciales', 'Permisos DOM', 'Decretos de tránsito', 'Organizaciones sociales'];

  List<DatoPatente> get _patentes {
    return kPatentes.where((p) {
      if (_year != 'all' && !p.fechaDecreto.startsWith(_year)) return false;
      if (_month != 'all') {
        final parts = p.fechaDecreto.split('-');
        if (parts.length >= 2 && parts[1] != _month.padLeft(2, '0')) return false;
      }
      if (_geo != 'all' && p.confianza != _geo) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.razonSocial.toLowerCase().contains(q) &&
            !p.rut.toLowerCase().contains(q) &&
            !p.direccion.toLowerCase().contains(q)) { return false; }
      }
      return true;
    }).toList();
  }

  List<DatoPermiso> get _permisos {
    return kPermisos.where((p) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.nPermiso.toLowerCase().contains(q) && !p.direccion.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<DatoTransito> get _transito {
    return kTransito.where((t) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.nDecreto.toLowerCase().contains(q) && !t.direccion.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<DatoOrganizacion> get _orgs {
    return kOrganizaciones.where((o) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!o.nombre.toLowerCase().contains(q) && !o.representante.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  int get _currentCount => switch (_tab) {
    0 => _patentes.length,
    1 => _permisos.length,
    2 => _transito.length,
    _ => _orgs.length,
  };

  int get _totalCount => switch (_tab) {
    0 => kPatentes.length,
    1 => kPermisos.length,
    2 => kTransito.length,
    _ => kOrganizaciones.length,
  };

  void _syncProviders() {
    ref.read(scrapingTabIndexProvider.notifier).state = _tab;
    ref.read(scrapingFilteredPatenteProvider.notifier).state = _patentes;
    ref.read(scrapingFilteredPermisoProvider.notifier).state = _permisos;
    ref.read(scrapingFilteredTransitoProvider.notifier).state = _transito;
    ref.read(scrapingFilteredOrgProvider.notifier).state = _orgs;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── View banner ──────────────────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _ScrapingBanner(
              nPatentes: kPatentes.length,
              nPermisos: kPermisos.length,
              nTransito: kTransito.length,
              nOrgs: kOrganizaciones.length,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // ── Scraper status ───────────────────────────────────────────────────
        Align(alignment: Alignment.centerRight, child: _ScraperStatus()),
        const SizedBox(height: 4),

        // ── Tabs ─────────────────────────────────────────────────────────────
        Row(children: List.generate(_tabLabels.length, (i) {
          final isActive = _tab == i;
          final count = [kPatentes.length, kPermisos.length, kTransito.length, kOrganizaciones.length][i];
          return GestureDetector(
            onTap: () { setState(() { _tab = i; _search = ''; }); _syncProviders(); },
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: isActive ? AppTheme.orange600 : Colors.transparent,
                  width: 2,
                )),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_tabLabels[i], style: TextStyle(
                  fontSize: 12.5, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppTheme.orange700 : AppTheme.stone500,
                )),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.orange100 : AppTheme.stone100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$count', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.orange700 : AppTheme.stone600,
                  )),
                ),
              ]),
            ),
          );
        })),
        const Divider(height: 1, color: AppTheme.stone200),
        const SizedBox(height: 10),

        // ── Meta bar ─────────────────────────────────────────────────────────
        _MetaBar(tab: _tab),
        const SizedBox(height: 10),

        // ── Filtros ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.stone200),
          ),
          child: Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            if (_tab == 0) ...[
              const _FLabel('Año'),
              _FSelect(value: _year, items: const [('all','Todos'),('2026','2026'),('2025','2025'),('2024','2024')], onChanged: (v) { setState(() => _year = v); _syncProviders(); }),
              const _FLabel('Mes'),
              _FSelect(value: _month, items: const [
                ('all','Todos'),('1','Enero'),('2','Febrero'),('3','Marzo'),('4','Abril'),
                ('5','Mayo'),('6','Junio'),('7','Julio'),('8','Agosto'),
                ('9','Septiembre'),('10','Octubre'),('11','Noviembre'),('12','Diciembre'),
              ], onChanged: (v) { setState(() => _month = v); _syncProviders(); }),
              const _FLabel('Geocoding'),
              _FSelect(value: _geo, items: const [
                ('all','Todos'),('high','Confianza alta'),('med','Confianza media'),
                ('low','Confianza baja'),('failed','Fallo'),
              ], onChanged: (v) { setState(() => _geo = v); _syncProviders(); }),
            ],
            SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  hintText: _tab == 0
                      ? 'Buscar por razón social, RUT, dirección…'
                      : _tab == 3 ? 'Buscar por nombre, representante…' : 'Buscar por decreto, dirección…',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.stone400),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
                ),
                style: const TextStyle(fontSize: 12.5),
                onChanged: (v) { setState(() => _search = v); _syncProviders(); },
              ),
            ),
            Text.rich(TextSpan(children: [
              const TextSpan(text: 'Mostrando ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
              TextSpan(text: '$_currentCount', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
              const TextSpan(text: ' de ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
              TextSpan(text: '$_totalCount', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
            ])),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Tabla ────────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: switch (_tab) {
                    0 => _TablaPatentes(items: _patentes),
                    1 => _TablaPermisos(items: _permisos),
                    2 => _TablaTransito(items: _transito),
                    _ => _TablaOrganizaciones(items: _orgs),
                  },
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Scraper status ────────────────────────────────────────────────────────────

class _ScraperStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.greenSuccess, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Scraper activo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppTheme.stone700)),
          Text('Última ejecución: hoy 03:00 AM', style: TextStyle(fontSize: 11, color: AppTheme.stone500)),
        ]),
      ]),
    );
  }
}

// ── Meta bar ──────────────────────────────────────────────────────────────────

class _MetaBar extends StatelessWidget {
  final int tab;
  const _MetaBar({required this.tab});

  static const _metas = [
    [('Fuente', 'lotatransparente.cl'), ('ig', '164'), ('Registros totales', '15'), ('Última extracción', '2026-04-24 03:02')],
    [('Fuente', 'lotatransparente.cl'), ('ig', '172'), ('Registros totales', '8'), ('Última extracción', '2026-04-24 03:10')],
    [('Fuente', 'lotatransparente.cl'), ('ig', '269'), ('Registros totales', '6'), ('Última extracción', '2026-04-24 03:20')],
    [('Fuente', 'lotatransparente.cl'), ('ig', '351'), ('Registros totales', '8'), ('Última extracción', '2026-04-24 04:00')],
  ];

  @override
  Widget build(BuildContext context) {
    final items = _metas[tab];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Wrap(spacing: 20, runSpacing: 6, children: items.map((item) {
        final (key, value) = item;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$key: ', style: const TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.stone900, fontFeatures: [FontFeature.tabularFigures()])),
        ]);
      }).toList()),
    );
  }
}

// ── Tablas por tab ────────────────────────────────────────────────────────────

class _TablaPatentes extends StatelessWidget {
  final List<DatoPatente> items;
  const _TablaPatentes({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return DataTable(
      headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
      headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
      dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
      columnSpacing: 14,
      horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('N° Decreto')),
        DataColumn(label: Text('Fecha')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('RUT')),
        DataColumn(label: Text('Razón Social')),
        DataColumn(label: Text('Giro')),
        DataColumn(label: Text('Dirección')),
        DataColumn(label: Text('Geocoding')),
      ],
      rows: items.map((p) => DataRow(cells: [
        DataCell(Text('#${p.nDecreto}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.blue800))),
        DataCell(Text(p.fechaDecreto, style: const TextStyle(color: AppTheme.stone500))),
        DataCell(Text(p.tipo)),
        DataCell(Text(p.rut, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]))),
        DataCell(SizedBox(width: 180, child: Text(p.razonSocial, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 160, child: Text(p.giro, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone600)))),
        DataCell(SizedBox(width: 140, child: Text(p.direccion, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone600)))),
        DataCell(_ConfianzaBadge(confianza: p.confianza)),
      ])).toList(),
    );
  }
}

class _TablaPermisos extends StatelessWidget {
  final List<DatoPermiso> items;
  const _TablaPermisos({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return DataTable(
      headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
      headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
      dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
      columnSpacing: 14, horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('N° Permiso')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Descripción')),
        DataColumn(label: Text('Dirección')),
        DataColumn(label: Text('Sector')),
        DataColumn(label: Text('Fecha')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Geocoding')),
      ],
      rows: items.map((p) => DataRow(cells: [
        DataCell(Text(p.nPermiso, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.blue800))),
        DataCell(Text(p.tipo)),
        DataCell(SizedBox(width: 160, child: Text(p.descripcion, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 140, child: Text(p.direccion, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone600)))),
        DataCell(Text(p.sector)),
        DataCell(Text(p.fecha, style: const TextStyle(color: AppTheme.stone500))),
        DataCell(_EstadoBadge(estado: p.estado)),
        DataCell(_ConfianzaBadge(confianza: p.confianza)),
      ])).toList(),
    );
  }
}

class _TablaTransito extends StatelessWidget {
  final List<DatoTransito> items;
  const _TablaTransito({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return DataTable(
      headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
      headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
      dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
      columnSpacing: 14, horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('N° Decreto')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Dirección afectada')),
        DataColumn(label: Text('Motivo')),
        DataColumn(label: Text('Desde')),
        DataColumn(label: Text('Hasta')),
        DataColumn(label: Text('Estado')),
      ],
      rows: items.map((t) => DataRow(cells: [
        DataCell(Text(t.nDecreto, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.blue800))),
        DataCell(Text(t.tipo)),
        DataCell(SizedBox(width: 180, child: Text(t.direccion, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 160, child: Text(t.motivo, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone600)))),
        DataCell(Text(t.fechaInicio, style: const TextStyle(color: AppTheme.stone500))),
        DataCell(Text(t.fechaFin, style: const TextStyle(color: AppTheme.stone500))),
        DataCell(_EstadoBadge(estado: t.estado)),
      ])).toList(),
    );
  }
}

class _TablaOrganizaciones extends StatelessWidget {
  final List<DatoOrganizacion> items;
  const _TablaOrganizaciones({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return DataTable(
      headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
      headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
      dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
      columnSpacing: 14, horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('N° Personalidad')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Representante')),
        DataColumn(label: Text('RUT Rep.')),
        DataColumn(label: Text('Sector')),
        DataColumn(label: Text('Vigencia')),
      ],
      rows: items.map((o) => DataRow(cells: [
        DataCell(Text(o.nPersonalidad, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.blue800))),
        DataCell(Text(o.tipo)),
        DataCell(SizedBox(width: 180, child: Text(o.nombre, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(width: 160, child: Text(o.representante, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone600)))),
        DataCell(Text(o.rutRep)),
        DataCell(Text(o.sector)),
        DataCell(SizedBox(width: 160, child: Text(o.vigencia, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.stone500)))),
      ])).toList(),
    );
  }
}

// ── Badges y helpers ──────────────────────────────────────────────────────────

class _ConfianzaBadge extends StatelessWidget {
  final String confianza;
  const _ConfianzaBadge({required this.confianza});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaConfianza(confianza);
    final bg = bgParaConfianza(confianza);
    final label = labelParaConfianza(confianza);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg, letterSpacing: 0.03)),
      ]),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaEstado(estado);
    final bg = bgParaEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(_label(estado), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  String _label(String e) {
    const m = {'vigente': 'Vigente', 'finalizado': 'Finalizado', 'activo': 'Activo', 'vencido': 'Vencido', 'ejecutado': 'Ejecutado'};
    return m[e] ?? e;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: Text('No se encontraron registros', style: TextStyle(color: AppTheme.stone500))),
  );
}

class _FLabel extends StatelessWidget {
  final String text;
  const _FLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
  );
}

class _FSelect extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  const _FSelect({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
        borderRadius: BorderRadius.circular(8),
        items: items.map((item) {
          final (val, label) = item;
          return DropdownMenuItem(value: val, child: Text(label));
        }).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

// ── View banner ───────────────────────────────────────────────────────────────

class _ScrapingBanner extends StatelessWidget {
  final int nPatentes, nPermisos, nTransito, nOrgs;
  const _ScrapingBanner({
    required this.nPatentes,
    required this.nPermisos,
    required this.nTransito,
    required this.nOrgs,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF7C3AED)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(Icons.work_outline, size: 100, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 140, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.download_for_offline_outlined, size: 12, color: Color(0x99FFFFFF)),
                    const SizedBox(width: 6),
                    const Text(
                      'Datos · lotatransparente.cl · Ley 20.285',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0x99FFFFFF), letterSpacing: 0.9),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Datos de Transparencia Pública',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.44,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Patentes, permisos DOM, decretos de tránsito y organizaciones sociales extraídos automáticamente.',
                    style: TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    _ScrapingStat(value: '$nPatentes', label: 'Patentes'),
                    const SizedBox(width: 16),
                    _ScrapingStat(value: '$nPermisos', label: 'Permisos DOM'),
                    const SizedBox(width: 16),
                    _ScrapingStat(value: '$nTransito', label: 'Decretos tránsito'),
                    const SizedBox(width: 16),
                    _ScrapingStat(value: '$nOrgs', label: 'Organizaciones'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrapingStat extends StatelessWidget {
  final String value;
  final String label;
  const _ScrapingStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF))),
      ],
    );
  }
}
