import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../auth/auth_provider.dart';
import '../map/providers/map_providers.dart';
import 'scraping_overrides_provider.dart';

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
  bool _filtersExpanded = false;

  // Selecciones por tab (cada tab tiene su propio seleccionado)
  DatoPatente? _selPatente;
  DatoPermiso? _selPermiso;
  DatoTransito? _selTransito;
  DatoOrganizacion? _selOrg;

  static const _tabLabels = [
    'Patentes comerciales',
    'Permisos DOM',
    'Decretos de tránsito',
    'Organizaciones sociales',
  ];

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
            !p.direccion.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<DatoPermiso> get _permisos {
    return kPermisos.where((p) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.nPermiso.toLowerCase().contains(q) &&
            !p.direccion.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<DatoTransito> get _transito {
    return kTransito.where((t) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.nDecreto.toLowerCase().contains(q) &&
            !t.direccion.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<DatoOrganizacion> get _orgs {
    return kOrganizaciones.where((o) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!o.nombre.toLowerCase().contains(q) &&
            !o.representante.toLowerCase().contains(q)) {
          return false;
        }
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

  bool get _hasSelection => switch (_tab) {
        0 => _selPatente != null,
        1 => _selPermiso != null,
        2 => _selTransito != null,
        _ => _selOrg != null,
      };

  void _clearSelection() {
    setState(() {
      _selPatente = null;
      _selPermiso = null;
      _selTransito = null;
      _selOrg = null;
    });
  }

  void _showMobileDetailSheet() {
    if (!_hasSelection) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        void closeSheet() => Navigator.of(ctx).pop();
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D3D1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: _hasSelection
                    ? switch (_tab) {
                        0 => _DetallePatente(
                            patente: _selPatente!,
                            onClose: closeSheet,
                          ),
                        1 => _DetallePermiso(
                            permiso: _selPermiso!,
                            onClose: closeSheet,
                          ),
                        2 => _DetalleTransito(
                            transito: _selTransito!,
                            onClose: closeSheet,
                          ),
                        _ => _DetalleOrganizacion(
                            org: _selOrg!,
                            onClose: closeSheet,
                          ),
                      }
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) _clearSelection();
    });
  }

  void _syncProviders() {
    ref.read(scrapingTabIndexProvider.notifier).state = _tab;
    ref.read(scrapingFilteredPatenteProvider.notifier).state = _patentes;
    ref.read(scrapingFilteredPermisoProvider.notifier).state = _permisos;
    ref.read(scrapingFilteredTransitoProvider.notifier).state = _transito;
    ref.read(scrapingFilteredOrgProvider.notifier).state = _orgs;
  }

  // ── Scraper triggers ─────────────────────────────────────────────────────

  String get _currentSourceLabel => switch (_tab) {
        0 => 'patentes comerciales',
        1 => 'permisos DOM',
        2 => 'decretos de tránsito',
        _ => 'organizaciones sociales',
      };

  Future<void> _confirmScrapeRecent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Scrapear últimos 30 días',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se ejecutará el scraper sobre $_currentSourceLabel para los '
              'últimos 30 días desde lotatransparente.cl.',
              style: const TextStyle(fontSize: 13, color: AppTheme.stone700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.stone50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.stone200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: AppTheme.stone500),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Si un registro ya existe (mismo decreto/permiso/N°), '
                      'se actualiza con los datos más recientes. Las '
                      'correcciones manuales de ubicación se conservan.',
                      style: TextStyle(
                          fontSize: 11.5, color: AppTheme.stone700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Ejecutar scraper'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await _runScrape(dias: 30, all: false);
  }

  Future<void> _confirmScrapeAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.redDanger, size: 22),
          SizedBox(width: 8),
          Text(
            'Scrapear todo el histórico',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta operación traerá TODOS los registros históricos de '
              'lotatransparente.cl para las cuatro tablas: patentes, '
              'permisos DOM, decretos de tránsito y organizaciones sociales.',
              style: TextStyle(fontSize: 13, color: AppTheme.stone700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.timer_outlined,
                        size: 14, color: AppTheme.redDanger),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Puede tardar varios minutos.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.redDanger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.network_check,
                        size: 14, color: AppTheme.redDanger),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Consume cuota del geocoder (Nominatim, 1 req/s).',
                        style: TextStyle(
                            fontSize: 11.5, color: AppTheme.redDanger),
                      ),
                    ),
                  ]),
                  SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.update,
                        size: 14, color: AppTheme.redDanger),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los registros existentes se sobreescriben con los '
                        'datos más recientes; las correcciones de ubicación '
                        'manuales se conservan.',
                        style: TextStyle(
                            fontSize: 11.5, color: AppTheme.redDanger),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.cloud_download_outlined, size: 14),
            label: const Text('Sí, scrapear todo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await _runScrape(dias: null, all: true);
  }

  Future<void> _runScrape({required int? dias, required bool all}) async {
    // Snackbar de progreso (no bloqueante)
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Row(children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              all
                  ? 'Ejecutando scraper completo…'
                  : 'Scrapeando últimos ${dias ?? 30} días…',
            ),
          ),
        ]),
        duration: const Duration(seconds: 30),
      ),
    );

    // Llamada al backend (POST /api/scraper/run).
    // Si el endpoint no existe (backend down o no implementado), mostramos
    // un mensaje claro sin reventar la UI.
    try {
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}/api/scraper/run'
        '${all ? '?all=true' : '?dias=${dias ?? 30}'}',
      );
      // El endpoint es director-only → mandar el JWT actual.
      final token =
          await ref.read(secureStorageProvider).read(key: 'access_token');
      final resp = await _postScraperRun(uri, token);
      scaffold.hideCurrentSnackBar();
      if (resp == _ScraperResult.ok) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Scraper iniciado correctamente.'),
            duration: Duration(seconds: 3),
            backgroundColor: AppTheme.greenSuccess,
          ),
        );
      } else if (resp == _ScraperResult.unavailable) {
        scaffold.showSnackBar(
          SnackBar(
            content: const Text(
              'El servicio de scraper no está disponible. '
              'Verifica que el worker esté corriendo.',
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: scaffold.hideCurrentSnackBar,
            ),
          ),
        );
      } else {
        scaffold.showSnackBar(
          const SnackBar(
            content:
                Text('Error al iniciar el scraper. Revisa los logs.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text(
            'El servicio de scraper no está disponible. '
            'Verifica que el worker esté corriendo.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isCompact = constraints.maxWidth < 1100;
        final showDetailInline = !isCompact && _hasSelection;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 20,
            isMobile ? 10 : 14,
            isMobile ? 12 : 20,
            isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScrapingBanner(
                nPatentes: kPatentes.length,
                nPermisos: kPermisos.length,
                nTransito: kTransito.length,
                nOrgs: kOrganizaciones.length,
              ),
              const SizedBox(height: 10),

              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabLabels.length, (i) {
                    final isActive = _tab == i;
                    final count = [
                      kPatentes.length,
                      kPermisos.length,
                      kTransito.length,
                      kOrganizaciones.length
                    ][i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _tab = i;
                          _search = '';
                        });
                        _syncProviders();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive
                                  ? AppTheme.orange600
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tabLabels[i],
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppTheme.orange700
                                    : AppTheme.stone500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.orange100
                                    : AppTheme.stone100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppTheme.orange700
                                      : AppTheme.stone600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1, color: AppTheme.stone200),
              const SizedBox(height: 10),

              // Filtros — compact on mobile, full on desktop
              if (isMobile) ...[
                _MobileScrapingFilterBar(
                  search: _search,
                  currentCount: _currentCount,
                  totalCount: _totalCount,
                  expanded: _filtersExpanded,
                  hasActiveFilters: _tab == 0 &&
                      (_year != 'all' || _month != 'all' || _geo != 'all'),
                  onSearch: (v) {
                    setState(() => _search = v);
                    _syncProviders();
                  },
                  onToggle: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                ),
                if (_filtersExpanded) ...[
                  const SizedBox(height: 8),
                  _ScrapingFilters(
                    tab: _tab,
                    year: _year,
                    month: _month,
                    geo: _geo,
                    search: _search,
                    currentCount: _currentCount,
                    totalCount: _totalCount,
                    onYear: (v) { setState(() => _year = v); _syncProviders(); },
                    onMonth: (v) { setState(() => _month = v); _syncProviders(); },
                    onGeo: (v) { setState(() => _geo = v); _syncProviders(); },
                    onSearch: (v) { setState(() => _search = v); _syncProviders(); },
                    onScrapeRecent: _confirmScrapeRecent,
                    onScrapeAll: _confirmScrapeAll,
                  ),
                ],
              ] else
                _ScrapingFilters(
                  tab: _tab,
                  year: _year,
                  month: _month,
                  geo: _geo,
                  search: _search,
                  currentCount: _currentCount,
                  totalCount: _totalCount,
                  onYear: (v) { setState(() => _year = v); _syncProviders(); },
                  onMonth: (v) { setState(() => _month = v); _syncProviders(); },
                  onGeo: (v) { setState(() => _geo = v); _syncProviders(); },
                  onSearch: (v) { setState(() => _search = v); _syncProviders(); },
                  onScrapeRecent: _confirmScrapeRecent,
                  onScrapeAll: _confirmScrapeAll,
                ),
              const SizedBox(height: 10),

              // Contenido — cards on mobile, table+detail on desktop
              Expanded(
                child: isMobile
                    ? _buildMobileCardList()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildTabla(isMobile)),
                          if (showDetailInline) ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 360,
                              child: _buildDetailPanel(),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabla(bool isMobile) {
    return switch (_tab) {
      0 => _TablaPatentes(
          items: _patentes,
          selectedId: _selPatente?.nDecreto,
          onSelect: (p) {
            setState(() { _clearOtherSelections(); _selPatente = p; });
            if (isMobile) _showMobileDetailSheet();
          },
        ),
      1 => _TablaPermisos(
          items: _permisos,
          selectedId: _selPermiso?.nPermiso,
          onSelect: (p) {
            setState(() { _clearOtherSelections(); _selPermiso = p; });
            if (isMobile) _showMobileDetailSheet();
          },
        ),
      2 => _TablaTransito(
          items: _transito,
          selectedId: _selTransito?.nDecreto,
          onSelect: (t) {
            setState(() { _clearOtherSelections(); _selTransito = t; });
            if (isMobile) _showMobileDetailSheet();
          },
        ),
      _ => _TablaOrganizaciones(
          items: _orgs,
          selectedId: _selOrg?.nPersonalidad,
          onSelect: (o) {
            setState(() { _clearOtherSelections(); _selOrg = o; });
            if (isMobile) _showMobileDetailSheet();
          },
        ),
    };
  }

  void _clearOtherSelections() {
    _selPatente = null;
    _selPermiso = null;
    _selTransito = null;
    _selOrg = null;
  }

  Widget _buildDetailPanel() {
    return switch (_tab) {
      0 => _DetallePatente(
          patente: _selPatente!,
          onClose: _clearSelection,
        ),
      1 => _DetallePermiso(
          permiso: _selPermiso!,
          onClose: _clearSelection,
        ),
      2 => _DetalleTransito(
          transito: _selTransito!,
          onClose: _clearSelection,
        ),
      _ => _DetalleOrganizacion(
          org: _selOrg!,
          onClose: _clearSelection,
        ),
    };
  }

  Widget _buildMobileCardList() {
    if (_tab == 0) {
      final items = _patentes;
      if (items.isEmpty) return const _EmptyState();
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _MobilePatenteCard(
          item: items[i],
          onTap: () {
            setState(() { _clearOtherSelections(); _selPatente = items[i]; });
            _showMobileDetailSheet();
          },
        ),
      );
    }
    if (_tab == 1) {
      final items = _permisos;
      if (items.isEmpty) return const _EmptyState();
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _MobilePermisoCard(
          item: items[i],
          onTap: () {
            setState(() { _clearOtherSelections(); _selPermiso = items[i]; });
            _showMobileDetailSheet();
          },
        ),
      );
    }
    if (_tab == 2) {
      final items = _transito;
      if (items.isEmpty) return const _EmptyState();
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _MobileTransitoCard(
          item: items[i],
          onTap: () {
            setState(() { _clearOtherSelections(); _selTransito = items[i]; });
            _showMobileDetailSheet();
          },
        ),
      );
    }
    final items = _orgs;
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _MobileOrgCard(
        item: items[i],
        onTap: () {
          setState(() { _clearOtherSelections(); _selOrg = items[i]; });
          _showMobileDetailSheet();
        },
      ),
    );
  }
}

// ── Filtros ───────────────────────────────────────────────────────────────────

class _ScrapingFilters extends StatelessWidget {
  final int tab;
  final String year;
  final String month;
  final String geo;
  final String search;
  final int currentCount;
  final int totalCount;
  final ValueChanged<String> onYear;
  final ValueChanged<String> onMonth;
  final ValueChanged<String> onGeo;
  final ValueChanged<String> onSearch;
  final VoidCallback onScrapeRecent;
  final VoidCallback onScrapeAll;

  const _ScrapingFilters({
    required this.tab,
    required this.year,
    required this.month,
    required this.geo,
    required this.search,
    required this.currentCount,
    required this.totalCount,
    required this.onYear,
    required this.onMonth,
    required this.onGeo,
    required this.onSearch,
    required this.onScrapeRecent,
    required this.onScrapeAll,
  });

  static const _years = <(String, String)>[
    ('all', 'Todos'),
    ('2026', '2026'),
    ('2025', '2025'),
    ('2024', '2024'),
  ];

  static const _months = <(String, String)>[
    ('all', 'Todos'),
    ('1', 'Enero'),
    ('2', 'Febrero'),
    ('3', 'Marzo'),
    ('4', 'Abril'),
    ('5', 'Mayo'),
    ('6', 'Junio'),
    ('7', 'Julio'),
    ('8', 'Agosto'),
    ('9', 'Septiembre'),
    ('10', 'Octubre'),
    ('11', 'Noviembre'),
    ('12', 'Diciembre'),
  ];

  static const _geos = <(String, String)>[
    ('all', 'Todos'),
    ('high', 'Confianza alta'),
    ('med', 'Confianza media'),
    ('low', 'Confianza baja'),
    ('failed', 'Fallo'),
  ];

  String get _searchHint => switch (tab) {
        0 => 'Razón social, RUT, dirección…',
        3 => 'Nombre, representante…',
        _ => 'Decreto, dirección…',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (tab == 0) ...[
            _FilterField(
              label: 'Año',
              child: _FilterDropdown(
                value: year,
                items: _years,
                onChanged: onYear,
                width: 130,
              ),
            ),
            _FilterField(
              label: 'Mes',
              child: _FilterDropdown(
                value: month,
                items: _months,
                onChanged: onMonth,
                width: 140,
              ),
            ),
            _FilterField(
              label: 'Geocoding',
              child: _FilterDropdown(
                value: geo,
                items: _geos,
                onChanged: onGeo,
                width: 170,
              ),
            ),
          ],
          _FilterField(
            label: 'Buscar',
            child: SizedBox(
              width: 280,
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  hintText: _searchHint,
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.stone400,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      size: 16, color: AppTheme.stone400),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.stone200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.stone200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppTheme.orange600, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 12.5),
                onChanged: onSearch,
              ),
            ),
          ),
          _FilterField(
            label: 'Resultados',
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.orange50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Center(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$currentCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.orange700,
                        fontSize: 13,
                      ),
                    ),
                    const TextSpan(
                      text: ' de ',
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.stone600),
                    ),
                    TextSpan(
                      text: '$totalCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.orange700,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          _FilterField(
            label: 'Scraper',
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                onPressed: onScrapeRecent,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  'Scrapear ahora',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: onScrapeAll,
                icon: const Icon(Icons.cloud_download_outlined, size: 14),
                label: const Text(
                  'Scrapear todo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.redDanger,
                  side: const BorderSide(color: AppTheme.redDanger),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FilterField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.stone500,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  final double width;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.expand_more,
              size: 16, color: AppTheme.stone500),
          style: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
          borderRadius: BorderRadius.circular(8),
          items: items.map((item) {
            final (val, label) = item;
            return DropdownMenuItem(
              value: val,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Tabla genérica (header + filas) ───────────────────────────────────────────

class _TablaShell extends StatelessWidget {
  final Widget header;
  final Widget body;
  const _TablaShell({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [header, Expanded(child: body)]),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<({String label, int flex})> cols;
  const _HeaderRow({required this.cols});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.stone50,
        border: Border(bottom: BorderSide(color: AppTheme.stone200)),
      ),
      child: Row(
        children: cols.map((c) {
          return Expanded(
            flex: c.flex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Text(
                c.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stone600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RowShell extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;
  final List<Widget> cells;
  final List<int> flex;
  const _RowShell({
    required this.selected,
    required this.onTap,
    required this.cells,
    required this.flex,
  });

  @override
  State<_RowShell> createState() => _RowShellState();
}

class _RowShellState extends State<_RowShell> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppTheme.orange50
        : _hover
            ? const Color(0xFFFAFAF9)
            : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              left: BorderSide(
                color: widget.selected ? AppTheme.orange600 : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: AppTheme.stone100),
            ),
          ),
          child: Row(
            children: List.generate(widget.cells.length, (i) {
              return Expanded(
                flex: widget.flex[i],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: widget.cells[i],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text(
          'No se encontraron registros',
          style: TextStyle(color: AppTheme.stone500, fontSize: 13),
        ),
      );
}

// ── Tablas por tab ────────────────────────────────────────────────────────────

class _TablaPatentes extends StatelessWidget {
  final List<DatoPatente> items;
  final int? selectedId;
  final ValueChanged<DatoPatente> onSelect;
  const _TablaPatentes({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  static const _flex = [2, 2, 2, 3, 4, 3, 4, 2];

  @override
  Widget build(BuildContext context) {
    return _TablaShell(
      header: const _HeaderRow(cols: [
        (label: 'N° Decreto', flex: 2),
        (label: 'Fecha', flex: 2),
        (label: 'Tipo', flex: 2),
        (label: 'RUT', flex: 3),
        (label: 'Razón Social', flex: 4),
        (label: 'Giro', flex: 3),
        (label: 'Dirección', flex: 4),
        (label: 'Geocoding', flex: 2),
      ]),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final p = items[i];
                return _RowShell(
                  selected: selectedId == p.nDecreto,
                  onTap: () => onSelect(p),
                  flex: _flex,
                  cells: [
                    Text(
                      '#${p.nDecreto}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.blue800,
                      ),
                    ),
                    Text(p.fechaDecreto,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone500)),
                    Text(p.tipo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(p.rut,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        )),
                    Text(p.razonSocial,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w500)),
                    Text(p.giro,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone600)),
                    Text(p.direccion,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone600)),
                    _ConfianzaBadge(confianza: p.confianza),
                  ],
                );
              },
            ),
    );
  }
}

class _TablaPermisos extends StatelessWidget {
  final List<DatoPermiso> items;
  final String? selectedId;
  final ValueChanged<DatoPermiso> onSelect;
  const _TablaPermisos({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  static const _flex = [2, 2, 4, 4, 1, 2, 2, 2];

  @override
  Widget build(BuildContext context) {
    return _TablaShell(
      header: const _HeaderRow(cols: [
        (label: 'N° Permiso', flex: 2),
        (label: 'Tipo', flex: 2),
        (label: 'Descripción', flex: 4),
        (label: 'Dirección', flex: 4),
        (label: 'Sector', flex: 1),
        (label: 'Fecha', flex: 2),
        (label: 'Estado', flex: 2),
        (label: 'Geocoding', flex: 2),
      ]),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final p = items[i];
                return _RowShell(
                  selected: selectedId == p.nPermiso,
                  onTap: () => onSelect(p),
                  flex: _flex,
                  cells: [
                    Text(p.nPermiso,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue800,
                        )),
                    Text(p.tipo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(p.descripcion,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(p.direccion,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone600)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.stone100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(p.sector,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.stone700,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(p.fecha,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone500)),
                    _EstadoBadge(estado: p.estado),
                    _ConfianzaBadge(confianza: p.confianza),
                  ],
                );
              },
            ),
    );
  }
}

class _TablaTransito extends StatelessWidget {
  final List<DatoTransito> items;
  final String? selectedId;
  final ValueChanged<DatoTransito> onSelect;
  const _TablaTransito({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  static const _flex = [2, 2, 4, 4, 2, 2, 2];

  @override
  Widget build(BuildContext context) {
    return _TablaShell(
      header: const _HeaderRow(cols: [
        (label: 'N° Decreto', flex: 2),
        (label: 'Tipo', flex: 2),
        (label: 'Dirección afectada', flex: 4),
        (label: 'Motivo', flex: 4),
        (label: 'Desde', flex: 2),
        (label: 'Hasta', flex: 2),
        (label: 'Estado', flex: 2),
      ]),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final t = items[i];
                return _RowShell(
                  selected: selectedId == t.nDecreto,
                  onTap: () => onSelect(t),
                  flex: _flex,
                  cells: [
                    Text(t.nDecreto,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue800,
                        )),
                    Text(t.tipo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(t.direccion,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(t.motivo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone600)),
                    Text(t.fechaInicio,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone500)),
                    Text(t.fechaFin,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone500)),
                    _EstadoBadge(estado: t.estado),
                  ],
                );
              },
            ),
    );
  }
}

class _TablaOrganizaciones extends StatelessWidget {
  final List<DatoOrganizacion> items;
  final String? selectedId;
  final ValueChanged<DatoOrganizacion> onSelect;
  const _TablaOrganizaciones({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  static const _flex = [2, 2, 4, 4, 2, 1, 3];

  @override
  Widget build(BuildContext context) {
    return _TablaShell(
      header: const _HeaderRow(cols: [
        (label: 'N° Personalidad', flex: 2),
        (label: 'Tipo', flex: 2),
        (label: 'Nombre', flex: 4),
        (label: 'Representante', flex: 4),
        (label: 'RUT Rep.', flex: 2),
        (label: 'Sector', flex: 1),
        (label: 'Vigencia', flex: 3),
      ]),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final o = items[i];
                return _RowShell(
                  selected: selectedId == o.nPersonalidad,
                  onTap: () => onSelect(o),
                  flex: _flex,
                  cells: [
                    Text(o.nPersonalidad,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue800,
                        )),
                    Text(o.tipo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5)),
                    Text(o.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w500)),
                    Text(o.representante,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.stone600)),
                    Text(o.rutRep,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.stone100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(o.sector,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.stone700,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(o.vigencia,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.stone500)),
                  ],
                );
              },
            ),
    );
  }
}

// ── Detail panel (genérico) ───────────────────────────────────────────────────

class _DetailPanelShell extends ConsumerStatefulWidget {
  final String topLabel;
  final Color topColor;
  final String title;
  final Widget? badge;
  final double? lat;
  final double? lng;
  final List<({IconData icon, String label, String value})> rows;
  final String? notas;
  final String? sourceUrl;
  final VoidCallback onClose;
  // Identidad del registro para asociar overrides de coords (opcional).
  final String? entityTipo;
  final String? entityId;

  const _DetailPanelShell({
    required this.topLabel,
    required this.topColor,
    required this.title,
    required this.rows,
    required this.onClose,
    this.badge,
    this.lat,
    this.lng,
    this.notas,
    this.sourceUrl,
    this.entityTipo,
    this.entityId,
  });

  @override
  ConsumerState<_DetailPanelShell> createState() =>
      _DetailPanelShellState();
}

class _DetailPanelShellState extends ConsumerState<_DetailPanelShell> {
  bool _editing = false;
  // Punto temporal mientras el usuario edita (antes de guardar).
  double? _draftLat;
  double? _draftLng;

  @override
  Widget build(BuildContext context) {
    final overrides = ref.watch(coordOverridesProvider);

    // Resolver coords: override > original
    double? lat = widget.lat;
    double? lng = widget.lng;
    bool isOverride = false;
    if (widget.entityTipo != null && widget.entityId != null) {
      final ov = overrides['${widget.entityTipo}:${widget.entityId}'];
      if (ov != null) {
        lat = ov.lat;
        lng = ov.lng;
        isOverride = true;
      }
    }

    final hasCoords = lat != null && lng != null && (lat != 0 || lng != 0);
    final canEdit = widget.entityTipo != null && widget.entityId != null;

    // Centro inicial del mapa: si no hay coords, usa centro de Lota.
    final mapLat = _draftLat ?? lat ?? -37.0896;
    final mapLng = _draftLng ?? lng ?? -73.1584;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.stone100)),
            ),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.topColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.topLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.topColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, size: 18),
                splashRadius: 18,
                color: AppTheme.stone500,
                tooltip: 'Cerrar',
              ),
            ]),
          ),

          // Mini-map (siempre presente si el registro permite override)
          Stack(
            children: [
              SizedBox(
                height: 200,
                child: (hasCoords || _editing)
                    ? _MiniMapa(
                        lat: mapLat,
                        lng: mapLng,
                        color: widget.topColor,
                        interactive: _editing,
                        onTap: _editing
                            ? (newLat, newLng) {
                                setState(() {
                                  _draftLat = newLat;
                                  _draftLng = newLng;
                                });
                              }
                            : null,
                      )
                    : Container(
                        color: AppTheme.stone50,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_outlined,
                                size: 24, color: AppTheme.stone400),
                            SizedBox(height: 6),
                            Text(
                              'Sin coordenadas',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.stone500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Badge "Corregido manualmente" si hay override y no estamos editando
              if (isOverride && !_editing)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.orange600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_location_alt,
                            size: 11, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Corregido manualmente',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Banner instructivo en modo edición
              if (_editing)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    color: AppTheme.orange600.withValues(alpha: 0.92),
                    child: const Row(
                      children: [
                        Icon(Icons.touch_app_outlined,
                            size: 13, color: Colors.white),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Toca el mapa para colocar el punto correcto',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Acciones (editar / guardar / cancelar / quitar)
              if (canEdit)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _MapaAcciones(
                    editing: _editing,
                    canSave: _draftLat != null && _draftLng != null,
                    hasOverride: isOverride,
                    onEdit: () => setState(() {
                      _editing = true;
                      _draftLat = lat;
                      _draftLng = lng;
                    }),
                    onCancel: () => setState(() {
                      _editing = false;
                      _draftLat = null;
                      _draftLng = null;
                    }),
                    onSave: () {
                      ref.read(coordOverridesProvider.notifier).set(
                            widget.entityTipo!,
                            widget.entityId!,
                            _draftLat!,
                            _draftLng!,
                          );
                      setState(() {
                        _editing = false;
                        _draftLat = null;
                        _draftLng = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ubicación corregida y guardada'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onRemove: () {
                      ref.read(coordOverridesProvider.notifier).remove(
                            widget.entityTipo!,
                            widget.entityId!,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Corrección eliminada (usando origen)'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stone900,
                    height: 1.25,
                  ),
                ),
                if (widget.badge != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [widget.badge!]),
                ],
                if (isOverride) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Coords: ${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)} (corregido)',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.orange700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...widget.rows.map((r) => _DetailRow(
                      icon: r.icon,
                      label: r.label,
                      value: r.value,
                    )),
                if (widget.notas != null && widget.notas!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'NOTAS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.notas!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.stone700,
                      height: 1.4,
                    ),
                  ),
                ],
                if (widget.sourceUrl != null &&
                    widget.sourceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse(widget.sourceUrl!)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.stone50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.stone200),
                      ),
                      child: Row(children: [
                        const Icon(Icons.open_in_new,
                            size: 13, color: AppTheme.stone600),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ver fuente original',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.stone700,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppTheme.stone500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stone500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.stone800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapa extends StatefulWidget {
  final double lat;
  final double lng;
  final Color color;
  final bool interactive;
  final void Function(double lat, double lng)? onTap;

  const _MiniMapa({
    required this.lat,
    required this.lng,
    required this.color,
    this.interactive = false,
    this.onTap,
  });

  @override
  State<_MiniMapa> createState() => _MiniMapaState();
}

class _MiniMapaState extends State<_MiniMapa> {
  final MapController _controller = MapController();

  // Si el lat/lng cambia desde afuera (ej. usuario tap durante edición),
  // recentramos el mapa.
  @override
  void didUpdateWidget(_MiniMapa old) {
    super.didUpdateWidget(old);
    if (old.lat != widget.lat || old.lng != widget.lng) {
      // Mantener el zoom actual cuando se desplaza el punto al tap.
      _controller.move(LatLng(widget.lat, widget.lng), _controller.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      point: LatLng(widget.lat, widget.lng),
      width: 32,
      height: 32,
      child: Container(
        decoration: BoxDecoration(
          color: widget.interactive ? AppTheme.orange600 : widget.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.place, size: 14, color: Colors.white),
      ),
    );

    return RepaintBoundary(
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: LatLng(widget.lat, widget.lng),
          initialZoom: 16,
          interactionOptions: InteractionOptions(
            // En modo edición permitimos pan y zoom para colocar el punto.
            flags: widget.interactive
                ? InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.scrollWheelZoom |
                    InteractiveFlag.doubleTapZoom
                : InteractiveFlag.none,
          ),
          onTap: widget.interactive && widget.onTap != null
              ? (_, point) => widget.onTap!(point.latitude, point.longitude)
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.mapTileUrl,
            subdomains: AppConstants.mapSubdomains,
            userAgentPackageName: 'cl.lota.sigespu',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(markers: [marker]),
        ],
      ),
    );
  }
}

// ── Acciones del mini-mapa (editar / guardar / cancelar) ─────────────────────

class _MapaAcciones extends StatelessWidget {
  final bool editing;
  final bool canSave;
  final bool hasOverride;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  const _MapaAcciones({
    required this.editing,
    required this.canSave,
    required this.hasOverride,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapaBtn(
            icon: Icons.close,
            label: 'Cancelar',
            color: Colors.white,
            fg: AppTheme.stone700,
            onTap: onCancel,
          ),
          const SizedBox(width: 6),
          _MapaBtn(
            icon: Icons.check,
            label: 'Guardar',
            color: canSave ? AppTheme.orange600 : AppTheme.stone300,
            fg: Colors.white,
            onTap: canSave ? onSave : null,
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasOverride) ...[
          _MapaBtn(
            icon: Icons.restore,
            label: 'Quitar corrección',
            color: Colors.white,
            fg: AppTheme.redDanger,
            onTap: onRemove,
          ),
          const SizedBox(width: 6),
        ],
        _MapaBtn(
          icon: Icons.edit_location_alt_outlined,
          label: 'Editar ubicación',
          color: Colors.white,
          fg: AppTheme.stone800,
          onTap: onEdit,
        ),
      ],
    );
  }
}

class _MapaBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color fg;
  final VoidCallback? onTap;

  const _MapaBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 13, color: enabled ? fg : fg.withValues(alpha: 0.5)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? fg : fg.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detalles por tipo ─────────────────────────────────────────────────────────

class _DetallePatente extends StatelessWidget {
  final DatoPatente patente;
  final VoidCallback onClose;
  const _DetallePatente({required this.patente, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaConfianza(patente.confianza);
    final bg = bgParaConfianza(patente.confianza);
    final label = labelParaConfianza(patente.confianza);
    return _DetailPanelShell(
      topLabel: 'Patente comercial',
      topColor: AppTheme.amberWarning,
      title: patente.razonSocial,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text('Geocoding: $label',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: fg,
              )),
        ]),
      ),
      lat: patente.lat,
      lng: patente.lng,
      entityTipo: 'patente',
      entityId: '${patente.nDecreto}',
      onClose: onClose,
      sourceUrl: patente.url,
      rows: [
        (
          icon: Icons.numbers,
          label: 'Decreto',
          value: '#${patente.nDecreto}'
        ),
        (
          icon: Icons.calendar_today_outlined,
          label: 'Fecha decreto',
          value: patente.fechaDecreto,
        ),
        (icon: Icons.category_outlined, label: 'Tipo', value: patente.tipo),
        (icon: Icons.badge_outlined, label: 'RUT', value: patente.rut),
        (
          icon: Icons.storefront_outlined,
          label: 'Giro',
          value: patente.giro,
        ),
        (
          icon: Icons.place_outlined,
          label: 'Dirección',
          value: patente.direccion.isEmpty ? '—' : patente.direccion,
        ),
        if (patente.lat != 0 || patente.lng != 0)
          (
            icon: Icons.my_location_outlined,
            label: 'Coordenadas',
            value:
                '${patente.lat.toStringAsFixed(5)}, ${patente.lng.toStringAsFixed(5)}',
          ),
        (
          icon: Icons.download_for_offline_outlined,
          label: 'Extraído',
          value: patente.scrapedAt,
        ),
      ],
    );
  }
}

class _DetallePermiso extends StatelessWidget {
  final DatoPermiso permiso;
  final VoidCallback onClose;
  const _DetallePermiso({required this.permiso, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _DetailPanelShell(
      topLabel: 'Permiso DOM',
      topColor: AppTheme.blue800,
      title: permiso.descripcion.isEmpty ? permiso.nPermiso : permiso.descripcion,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgParaEstado(permiso.estado),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          permiso.estado,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: colorParaEstado(permiso.estado),
          ),
        ),
      ),
      lat: permiso.lat,
      lng: permiso.lng,
      entityTipo: 'permiso',
      entityId: permiso.nPermiso,
      onClose: onClose,
      sourceUrl: permiso.url,
      rows: [
        (
          icon: Icons.numbers,
          label: 'N° Permiso',
          value: permiso.nPermiso
        ),
        (
          icon: Icons.category_outlined,
          label: 'Tipo',
          value: permiso.tipo,
        ),
        (
          icon: Icons.place_outlined,
          label: 'Dirección',
          value: permiso.direccion.isEmpty ? '—' : permiso.direccion,
        ),
        (
          icon: Icons.layers_outlined,
          label: 'Sector',
          value: permiso.sector
        ),
        (
          icon: Icons.calendar_today_outlined,
          label: 'Fecha',
          value: permiso.fecha
        ),
        if (permiso.lat != 0 || permiso.lng != 0)
          (
            icon: Icons.my_location_outlined,
            label: 'Coordenadas',
            value:
                '${permiso.lat.toStringAsFixed(5)}, ${permiso.lng.toStringAsFixed(5)}',
          ),
      ],
    );
  }
}

class _DetalleTransito extends StatelessWidget {
  final DatoTransito transito;
  final VoidCallback onClose;
  const _DetalleTransito({required this.transito, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _DetailPanelShell(
      topLabel: 'Decreto de tránsito',
      topColor: const Color(0xFF7C3AED),
      title: transito.motivo.isEmpty ? transito.nDecreto : transito.motivo,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgParaEstado(transito.estado),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          transito.estado,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: colorParaEstado(transito.estado),
          ),
        ),
      ),
      // Sin coords iniciales — el operativo puede ubicar el punto.
      entityTipo: 'transito',
      entityId: transito.nDecreto,
      onClose: onClose,
      sourceUrl: transito.url,
      rows: [
        (
          icon: Icons.numbers,
          label: 'N° Decreto',
          value: transito.nDecreto
        ),
        (
          icon: Icons.category_outlined,
          label: 'Tipo',
          value: transito.tipo,
        ),
        (
          icon: Icons.place_outlined,
          label: 'Dirección afectada',
          value: transito.direccion.isEmpty ? '—' : transito.direccion,
        ),
        (
          icon: Icons.schedule_outlined,
          label: 'Desde',
          value: transito.fechaInicio
        ),
        (
          icon: Icons.schedule_outlined,
          label: 'Hasta',
          value: transito.fechaFin
        ),
      ],
      notas: transito.motivo,
    );
  }
}

class _DetalleOrganizacion extends StatelessWidget {
  final DatoOrganizacion org;
  final VoidCallback onClose;
  const _DetalleOrganizacion({required this.org, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _DetailPanelShell(
      topLabel: 'Organización social',
      topColor: AppTheme.greenSuccess,
      title: org.nombre,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.stone100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          org.tipo,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.stone700,
          ),
        ),
      ),
      entityTipo: 'organizacion',
      entityId: org.nPersonalidad,
      onClose: onClose,
      sourceUrl: org.url,
      rows: [
        (
          icon: Icons.numbers,
          label: 'N° Personalidad',
          value: org.nPersonalidad,
        ),
        (
          icon: Icons.person_outline,
          label: 'Representante',
          value: org.representante.isEmpty ? '—' : org.representante,
        ),
        (
          icon: Icons.badge_outlined,
          label: 'RUT representante',
          value: org.rutRep.isEmpty ? '—' : org.rutRep,
        ),
        (
          icon: Icons.place_outlined,
          label: 'Dirección',
          value: org.direccion.isEmpty ? '—' : org.direccion,
        ),
        (
          icon: Icons.layers_outlined,
          label: 'Sector',
          value: org.sector.isEmpty ? '—' : org.sector,
        ),
        (
          icon: Icons.event_available_outlined,
          label: 'Vigencia',
          value: org.vigencia,
        ),
      ],
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: 0.03,
          ),
        ),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        _label(estado),
        style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String _label(String e) {
    const m = {
      'vigente': 'Vigente',
      'finalizado': 'Finalizado',
      'activo': 'Activo',
      'vencido': 'Vencido',
      'ejecutado': 'Ejecutado',
    };
    return m[e] ?? e;
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFFC2410C)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: LayoutBuilder(builder: (context, bc) {
          final wide = bc.maxWidth > 720;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_for_offline_outlined,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Datos de Transparencia Pública',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'lotatransparente.cl · Ley 20.285',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xBFFFFFFF),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _BannerStatInline(value: '$nPatentes', label: 'Patentes'),
                      const _BannerDivider(),
                      _BannerStatInline(value: '$nPermisos', label: 'Permisos'),
                      const _BannerDivider(),
                      _BannerStatInline(
                          value: '$nTransito', label: 'Tránsito'),
                      const _BannerDivider(),
                      _BannerStatInline(value: '$nOrgs', label: 'Orgs.'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.download_for_offline_outlined,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Datos de Transparencia Pública',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _BannerStatInline(
                              value: '$nPatentes', label: 'Patentes'),
                          const SizedBox(width: 14),
                          _BannerStatInline(
                              value: '$nPermisos', label: 'Permisos'),
                          const SizedBox(width: 14),
                          _BannerStatInline(
                              value: '$nTransito', label: 'Tránsito'),
                          const SizedBox(width: 14),
                          _BannerStatInline(value: '$nOrgs', label: 'Orgs.'),
                        ]),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }
}

class _BannerStatInline extends StatelessWidget {
  final String value;
  final String label;
  const _BannerStatInline({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xBFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  const _BannerDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0x33FFFFFF),
    );
  }
}

// ── Mobile filter bar ────────────────────────────────────────────────────────

class _MobileScrapingFilterBar extends StatefulWidget {
  final String search;
  final int currentCount;
  final int totalCount;
  final bool expanded;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearch;
  final VoidCallback onToggle;

  const _MobileScrapingFilterBar({
    required this.search,
    required this.currentCount,
    required this.totalCount,
    required this.expanded,
    required this.hasActiveFilters,
    required this.onSearch,
    required this.onToggle,
  });

  @override
  State<_MobileScrapingFilterBar> createState() =>
      _MobileScrapingFilterBarState();
}

class _MobileScrapingFilterBarState extends State<_MobileScrapingFilterBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.search);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = widget.hasActiveFilters;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onSearch,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'Buscar…',
                hintStyle:
                    const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
                prefixIcon:
                    const Icon(Icons.search, size: 16, color: AppTheme.stone400),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.stone200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.stone200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppTheme.orange600, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.orange50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Text.rich(TextSpan(children: [
            TextSpan(
              text: '${widget.currentCount}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.orange700,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: '/${widget.totalCount}',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.stone500),
            ),
          ])),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: widget.expanded
                  ? AppTheme.orange600
                  : hasFilters
                      ? AppTheme.orange50
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.expanded
                    ? AppTheme.orange600
                    : hasFilters
                        ? AppTheme.orange600
                        : AppTheme.stone200,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.tune,
                  size: 14,
                  color: widget.expanded
                      ? Colors.white
                      : hasFilters
                          ? AppTheme.orange600
                          : AppTheme.stone600),
              const SizedBox(width: 4),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.expanded
                      ? Colors.white
                      : hasFilters
                          ? AppTheme.orange600
                          : AppTheme.stone600,
                ),
              ),
              if (hasFilters && !widget.expanded) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.orange600,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Mobile cards por tipo ─────────────────────────────────────────────────────

class _MobilePatenteCard extends StatelessWidget {
  final DatoPatente item;
  final VoidCallback onTap;
  const _MobilePatenteCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaConfianza(item.confianza);
    final bg = bgParaConfianza(item.confianza);
    final label = labelParaConfianza(item.confianza);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(
                        '#${item.nDecreto} · ${item.fechaDecreto}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.blue800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                color: fg, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: fg)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item.razonSocial,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stone900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.giro.isEmpty ? item.tipo : item.giro,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.stone500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.direccion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 12, color: AppTheme.stone400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.direccion,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppTheme.stone500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.stone400),
        ]),
      ),
    );
  }
}

class _MobilePermisoCard extends StatelessWidget {
  final DatoPermiso item;
  final VoidCallback onTap;
  const _MobilePermisoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaEstado(item.estado);
    final bg = bgParaEstado(item.estado);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.blue800.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.nPermiso,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.blue800)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(item.estado,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: fg)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item.descripcion.isEmpty ? item.tipo : item.descripcion,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stone900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.direccion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 12, color: AppTheme.stone400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.direccion,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppTheme.stone500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 2),
                  Text('${item.tipo} · ${item.fecha}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.stone400)),
                ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.stone400),
        ]),
      ),
    );
  }
}

class _MobileTransitoCard extends StatelessWidget {
  final DatoTransito item;
  final VoidCallback onTap;
  const _MobileTransitoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = colorParaEstado(item.estado);
    final bg = bgParaEstado(item.estado);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.nDecreto,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7C3AED))),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(item.estado,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: fg)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item.motivo.isEmpty ? item.tipo : item.motivo,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stone900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.direccion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 12, color: AppTheme.stone400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.direccion,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppTheme.stone500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 2),
                  Text('${item.fechaInicio} — ${item.fechaFin}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.stone400)),
                ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.stone400),
        ]),
      ),
    );
  }
}

class _MobileOrgCard extends StatelessWidget {
  final DatoOrganizacion item;
  final VoidCallback onTap;
  const _MobileOrgCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.greenSuccess.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.tipo,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.greenSuccess)),
                    ),
                    const Spacer(),
                    if (item.sector.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.stone100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.sector,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.stone600)),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item.nombre,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stone900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.representante.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.representante,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.stone500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  if (item.vigencia.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Vigencia: ${item.vigencia}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.stone400)),
                  ],
                ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.stone400),
        ]),
      ),
    );
  }
}

// ── Scraper trigger backend ──────────────────────────────────────────────────

enum _ScraperResult { ok, unavailable, error }

/// POST /api/scraper/run sin acoplar al cliente cacheado (esto NO es GET).
///
/// El endpoint aún no existe en el backend de referencia; mientras tanto,
/// detectamos 404/network y retornamos `unavailable` para que la UI dé un
/// mensaje claro. Cuando el endpoint exista, este wrapper sigue funcionando
/// sin tocar el llamador.
Future<_ScraperResult> _postScraperRun(Uri url, String? token) async {
  try {
    final resp = await http
        .post(
          url,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return _ScraperResult.ok;
    }
    if (resp.statusCode == 404 ||
        resp.statusCode == 501 ||
        resp.statusCode == 503) {
      return _ScraperResult.unavailable;
    }
    return _ScraperResult.error;
  } catch (_) {
    return _ScraperResult.unavailable;
  }
}
