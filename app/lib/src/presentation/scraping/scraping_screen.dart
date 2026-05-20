import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../map/providers/map_providers.dart';
import 'scraping_provider.dart';

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
  bool _last30Days = false;
  int _page = 0;
  static const int _pageSize = 20;

  List<T> _paginate<T>(List<T> items) {
    if (items.isEmpty) return const [];
    final start = _page * _pageSize;
    if (start >= items.length) return const [];
    final end = (start + _pageSize) > items.length ? items.length : (start + _pageSize);
    return items.sublist(start, end);
  }

  void _resetPage() => _page = 0;

  // Fuentes cacheadas en build() para no rebajar la respuesta de los providers
  // entre helpers (filtros) que se llaman varias veces en el mismo frame.
  List<DatoPatente> _srcPatentes = const [];
  List<DatoPermiso> _srcPermisos = const [];
  List<DatoTransito> _srcTransito = const [];
  List<DatoOrganizacion> _srcOrgs = const [];

  static const _tabLabels = ['Patentes comerciales', 'Permisos DOM', 'Decretos de tránsito', 'Organizaciones sociales'];

  String get _cutoffDate {
    final c = DateTime.now().subtract(const Duration(days: 30));
    return '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}';
  }

  List<DatoPatente> _filteredPatentes() {
    return _srcPatentes.where((p) {
      if (_last30Days && p.fechaDecreto.compareTo(_cutoffDate) < 0) return false;
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

  List<DatoPermiso> _filteredPermisos() {
    return _srcPermisos.where((p) {
      if (_last30Days && p.fecha.compareTo(_cutoffDate) < 0) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.nPermiso.toLowerCase().contains(q) && !p.direccion.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<DatoTransito> _filteredTransito() {
    return _srcTransito.where((t) {
      if (_last30Days && t.fechaInicio.compareTo(_cutoffDate) < 0) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.nDecreto.toLowerCase().contains(q) && !t.direccion.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<DatoOrganizacion> _filteredOrgs() {
    return _srcOrgs.where((o) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!o.nombre.toLowerCase().contains(q) && !o.representante.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  void _syncProviders(List<DatoPatente> p, List<DatoPermiso> pe,
      List<DatoTransito> t, List<DatoOrganizacion> o) {
    ref.read(scrapingTabIndexProvider.notifier).state = _tab;
    ref.read(scrapingFilteredPatenteProvider.notifier).state = p;
    ref.read(scrapingFilteredPermisoProvider.notifier).state = pe;
    ref.read(scrapingFilteredTransitoProvider.notifier).state = t;
    ref.read(scrapingFilteredOrgProvider.notifier).state = o;
  }

  @override
  Widget build(BuildContext context) {
    // Cargar datos reales desde el backend.
    final patentesAsync = ref.watch(scrapingPatentesProvider);
    final permisosAsync = ref.watch(scrapingPermisosProvider);
    final transitoAsync = ref.watch(scrapingTransitoProvider);
    final orgsAsync = ref.watch(scrapingOrganizacionesProvider);
    final statusAsync = ref.watch(scrapingStatusProvider);

    _srcPatentes = patentesAsync.value ?? const [];
    _srcPermisos = permisosAsync.value ?? const [];
    _srcTransito = transitoAsync.value ?? const [];
    _srcOrgs = orgsAsync.value ?? const [];

    final patentes = _filteredPatentes();
    final permisos = _filteredPermisos();
    final transito = _filteredTransito();
    final orgs = _filteredOrgs();

    // Mantener providers compartidos en sync (los usa el mapa para puntos).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncProviders(patentes, permisos, transito, orgs);
    });

    // Slice paginado solo para la vista de tabla (no afecta al mapa).
    final patentesPage = _paginate(patentes);
    final permisosPage = _paginate(permisos);
    final transitoPage = _paginate(transito);
    final orgsPage = _paginate(orgs);

    // Cuando termina un scraping, refresca las listas para reflejar lo nuevo.
    ref.listen<AsyncValue<ScrapingStatus>>(scrapingStatusProvider, (prev, next) {
      final wasRunning = prev?.value?.running ?? false;
      final isRunning = next.value?.running ?? false;
      if (wasRunning && !isRunning) {
        ref.read(scrapingControllerProvider).refreshAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scraping completado.')),
          );
        }
      }
    });

    final status = statusAsync.value ?? ScrapingStatus.idle();
    final isScraping = status.running;

    final currentCount = switch (_tab) {
      0 => patentes.length,
      1 => permisos.length,
      2 => transito.length,
      _ => orgs.length,
    };
    final totalCount = switch (_tab) {
      0 => _srcPatentes.length,
      1 => _srcPermisos.length,
      2 => _srcTransito.length,
      _ => _srcOrgs.length,
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── View banner ──────────────────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _ScrapingBanner(
              nPatentes: _srcPatentes.length,
              nPermisos: _srcPermisos.length,
              nTransito: _srcTransito.length,
              nOrgs: _srcOrgs.length,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // ── Scraper status + acciones ────────────────────────────────────────
        Row(children: [
          _ScraperStatus(),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: isScraping ? null : _scrapeNow,
            icon: const Icon(Icons.refresh_outlined, size: 14),
            label: const Text('Scrappear ahora', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.stone700,
              side: const BorderSide(color: AppTheme.stone300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: isScraping ? null : _scrapeHistorico,
            icon: const Icon(Icons.history_outlined, size: 14),
            label: const Text('Scrappear histórico', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.stone700,
              side: const BorderSide(color: AppTheme.stone300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Actualización automática diaria a las 03:00 AM desde lotatransparente.cl (Ley 20.285). "Scrappear histórico" puede demorar varios minutos.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
            )),
          ]),
        ),
        if (isScraping) ...[
          const SizedBox(height: 8),
          _ScrapingProgress(
            progress: status.progress,
            label: status.fuenteLabel.isEmpty ? 'Iniciando…' : 'Extrayendo: ${status.fuenteLabel}',
          ),
        ],
        const SizedBox(height: 4),

        // ── Tabs ─────────────────────────────────────────────────────────────
        Row(children: List.generate(_tabLabels.length, (i) {
          final isActive = _tab == i;
          final count = [_srcPatentes.length, _srcPermisos.length, _srcTransito.length, _srcOrgs.length][i];
          return GestureDetector(
            onTap: () { setState(() { _tab = i; _search = ''; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); },
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
            FilterChip(
              label: const Text('Últimos 30 días', style: TextStyle(fontSize: 12)),
              selected: _last30Days,
              onSelected: (v) { setState(() { _last30Days = v; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); },
              selectedColor: AppTheme.orange100,
              checkmarkColor: AppTheme.orange700,
              labelStyle: TextStyle(color: _last30Days ? AppTheme.orange700 : AppTheme.stone600, fontSize: 12),
              side: BorderSide(color: _last30Days ? AppTheme.orange600 : AppTheme.stone200),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
            if (_tab == 0) ...[
              const _FLabel('Año'),
              _FSelect(value: _year, items: const [('all','Todos'),('2026','2026'),('2025','2025'),('2024','2024')], onChanged: (v) { setState(() { _year = v; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); }),
              const _FLabel('Mes'),
              _FSelect(value: _month, items: const [
                ('all','Todos'),('1','Enero'),('2','Febrero'),('3','Marzo'),('4','Abril'),
                ('5','Mayo'),('6','Junio'),('7','Julio'),('8','Agosto'),
                ('9','Septiembre'),('10','Octubre'),('11','Noviembre'),('12','Diciembre'),
              ], onChanged: (v) { setState(() { _month = v; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); }),
              const _FLabel('Geocoding'),
              _FSelect(value: _geo, items: const [
                ('all','Todos'),('high','Confianza alta'),('med','Confianza media'),
                ('low','Confianza baja'),('failed','Fallo'),
              ], onChanged: (v) { setState(() { _geo = v; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); }),
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
                onChanged: (v) { setState(() { _search = v; _resetPage(); }); _syncProviders(patentes, permisos, transito, orgs); },
              ),
            ),
            Text.rich(TextSpan(children: [
              const TextSpan(text: 'Mostrando ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
              TextSpan(text: '$currentCount', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
              const TextSpan(text: ' de ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
              TextSpan(text: '$totalCount', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
            ])),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Tabla ────────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _isLoading(patentesAsync, permisosAsync, transitoAsync, orgsAsync)
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _hasError(patentesAsync, permisosAsync, transitoAsync, orgsAsync)
                            ? const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(child: Text(
                                  'Error al cargar datos del servidor',
                                  style: TextStyle(color: AppTheme.stone500),
                                )),
                              )
                            : switch (_tab) {
                                0 => _TablaPatentes(items: patentesPage),
                                1 => _TablaPermisos(items: permisosPage),
                                2 => _TablaTransito(items: transitoPage),
                                _ => _TablaOrganizaciones(items: orgsPage),
                              },
                  ),
                ),
              ),
              if (currentCount > _pageSize) ...[
                const Divider(height: 1, color: AppTheme.stone200),
                _Pager(
                  currentPage: _page,
                  totalItems: currentCount,
                  pageSize: _pageSize,
                  onPageChange: (p) => setState(() => _page = p),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  bool _isLoading(AsyncValue a, AsyncValue b, AsyncValue c, AsyncValue d) =>
      a.isLoading || b.isLoading || c.isLoading || d.isLoading;

  bool _hasError(AsyncValue a, AsyncValue b, AsyncValue c, AsyncValue d) =>
      a.hasError || b.hasError || c.hasError || d.hasError;

  Future<void> _scrapeNow() async {
    final confirm = await _confirmDialog(
      title: 'Scrappear ahora',
      message:
          'Se iniciará la extracción de datos recientes desde lotatransparente.cl. '
          'La operación puede demorar entre 1 y 3 minutos y consumirá ancho de banda.\n\n'
          '¿Deseas continuar?',
    );
    if (confirm != true || !mounted) return;
    final res = await ref.read(scrapingControllerProvider).runActual();
    if (!mounted) return;
    if (!res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'No se pudo iniciar el scraping')),
      );
    }
  }

  Future<void> _scrapeHistorico() async {
    final confirm = await _confirmDialog(
      title: 'Scrappear histórico',
      message:
          'Esta operación descargará datos de múltiples años desde lotatransparente.cl '
          'y puede demorar varios minutos. Se aplicará un rate-limit de 2 req/s para '
          'respetar al servidor.\n\n¿Deseas continuar?',
    );
    if (confirm != true || !mounted) return;
    final res = await ref.read(scrapingControllerProvider).runHistorico();
    if (!mounted) return;
    if (!res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'No se pudo iniciar el scraping')),
      );
    }
  }

  Future<bool?> _confirmDialog({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.45)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ScrapingProgress extends StatelessWidget {
  final double progress;
  final String label;
  const _ScrapingProgress({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.orange50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.orange100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.orange600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.orange700,
            )),
          ),
          Text('$pct%', style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange700,
            fontFeatures: [FontFeature.tabularFigures()],
          )),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.orange100,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.orange600),
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
            colors: [Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFFC2410C)],
            stops: [0.0, 0.5, 1.0],
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

// ── Pager ─────────────────────────────────────────────────────────────────────

class _Pager extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChange;

  const _Pager({
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();
    final lastPage = ((totalItems - 1) ~/ pageSize);
    final page = currentPage.clamp(0, lastPage);
    final start = page * pageSize + 1;
    final end = ((page + 1) * pageSize) > totalItems ? totalItems : ((page + 1) * pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppTheme.stone50,
      child: Row(children: [
        Text(
          'Mostrando $start–$end de $totalItems',
          style: const TextStyle(fontSize: 11.5, color: AppTheme.stone600),
        ),
        const Spacer(),
        _PagerButton(
          icon: Icons.chevron_left,
          enabled: page > 0,
          onTap: () => onPageChange(page - 1),
        ),
        const SizedBox(width: 6),
        ..._buildPageNumbers(page, lastPage).map((p) {
          if (p == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('…', style: TextStyle(color: AppTheme.stone400, fontSize: 12)),
            );
          }
          final active = p == page;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => onPageChange(p),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(minWidth: 28),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? AppTheme.orange600 : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: active ? AppTheme.orange600 : AppTheme.stone200),
                ),
                child: Text(
                  '${p + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppTheme.stone700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 6),
        _PagerButton(
          icon: Icons.chevron_right,
          enabled: page < lastPage,
          onTap: () => onPageChange(page + 1),
        ),
      ]),
    );
  }

  List<int> _buildPageNumbers(int current, int lastPage) {
    final pages = <int>{0, lastPage};
    for (var i = current - 1; i <= current + 1; i++) {
      if (i >= 0 && i <= lastPage) pages.add(i);
    }
    final sorted = pages.toList()..sort();
    final result = <int>[];
    for (var i = 0; i < sorted.length; i++) {
      result.add(sorted[i]);
      if (i < sorted.length - 1 && sorted[i + 1] - sorted[i] > 1) {
        result.add(-1);
      }
    }
    return result;
  }
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PagerButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppTheme.stone100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Icon(icon, size: 16, color: enabled ? AppTheme.stone700 : AppTheme.stone300),
      ),
    );
  }
}
