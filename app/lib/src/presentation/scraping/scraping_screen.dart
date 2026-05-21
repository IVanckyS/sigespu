// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/seed_data.dart';
import '../map/providers/map_providers.dart';
import 'scraping_provider.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
// Mirror del tokens.css del handoff. Las que coinciden con AppTheme se referencian
// directamente; las nuevas (or5, or3) se definen aquí.
class _T {
  static const or1 = Color(0xFFFFF7ED);
  static const or2 = Color(0xFFFFEDD5);
  static const or3 = Color(0xFFFED7AA);
  static const or5 = Color(0xFFF97316);
  static const or6 = Color(0xFFEA580C);
  static const or7 = Color(0xFFC2410C);

  static const s50  = Color(0xFFFAFAF9);
  static const s100 = Color(0xFFF5F5F4);
  static const s200 = Color(0xFFE7E5E4);
  static const s300 = Color(0xFFD6D3D1);
  static const s400 = Color(0xFFA8A29E);
  static const s500 = Color(0xFF78716C);
  static const s600 = Color(0xFF57534E);
  static const s700 = Color(0xFF44403C);
  static const s800 = Color(0xFF292524);
  static const s900 = Color(0xFF1C1917);

  static const successBg  = Color(0xFFDCFCE7);
  static const successFg  = Color(0xFF15803D);
  static const successDot = Color(0xFF16A34A);
  static const warningBg  = Color(0xFFFEF3C7);
  static const warningFg  = Color(0xFF92400E);
  static const warningDot = Color(0xFFCA8A04);
  static const dangerBg   = Color(0xFFFEE2E2);
  static const dangerFg   = Color(0xFFB91C1C);
}

// ── Source metadata ──────────────────────────────────────────────────────────
class _SourceMeta {
  final String id;
  final String label;
  final String short;
  final String ig;
  final String lastTime;
  const _SourceMeta({
    required this.id,
    required this.label,
    required this.short,
    required this.ig,
    required this.lastTime,
  });
}

const _sources = [
  _SourceMeta(id: 'patentes',       label: 'Patentes comerciales',  short: 'Patentes', ig: '164', lastTime: '03:02'),
  _SourceMeta(id: 'permisos',       label: 'Permisos DOM',          short: 'DOM',      ig: '172', lastTime: '03:10'),
  _SourceMeta(id: 'transito',       label: 'Decretos de tránsito',  short: 'Decretos', ig: '269', lastTime: '03:20'),
  _SourceMeta(id: 'organizaciones', label: 'Organizaciones sociales', short: 'Org.',   ig: '351', lastTime: '04:00'),
];

class ScrapingScreen extends ConsumerStatefulWidget {
  const ScrapingScreen({super.key});

  @override
  ConsumerState<ScrapingScreen> createState() => _ScrapingScreenState();
}

class _ScrapingScreenState extends ConsumerState<ScrapingScreen> {
  String _activeSource = 'patentes';
  String _year = 'all';
  String _month = 'all';
  String _geo = 'all';
  String _search = '';
  bool _last30Days = false;
  int _page = 0;
  static const int _pageSize = 20;

  // Fila seleccionada — habilita el panel de mapa lateral en desktop.
  DatoPatente? _focusedPatente;

  // Cache de listas por frame.
  List<DatoPatente> _srcPatentes = const [];
  List<DatoPermiso> _srcPermisos = const [];
  List<DatoTransito> _srcTransito = const [];
  List<DatoOrganizacion> _srcOrgs = const [];

  String get _cutoffDate {
    final c = DateTime.now().subtract(const Duration(days: 30));
    return '${c.year.toString().padLeft(4, '0')}-${c.month.toString().padLeft(2, '0')}-${c.day.toString().padLeft(2, '0')}';
  }

  void _resetPage() => _page = 0;

  List<T> _paginate<T>(List<T> items) {
    if (items.isEmpty) return const [];
    final start = _page * _pageSize;
    if (start >= items.length) return const [];
    final end = (start + _pageSize) > items.length ? items.length : (start + _pageSize);
    return items.sublist(start, end);
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
            !p.direccion.toLowerCase().contains(q)) return false;
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
    final tabIdx = switch (_activeSource) {
      'patentes' => 0,
      'permisos' => 1,
      'transito' => 2,
      _ => 3,
    };
    ref.read(scrapingTabIndexProvider.notifier).state = tabIdx;
    ref.read(scrapingFilteredPatenteProvider.notifier).state = p;
    ref.read(scrapingFilteredPermisoProvider.notifier).state = pe;
    ref.read(scrapingFilteredTransitoProvider.notifier).state = t;
    ref.read(scrapingFilteredOrgProvider.notifier).state = o;
  }

  void _setSource(String id) {
    setState(() {
      _activeSource = id;
      _search = '';
      _focusedPatente = null;
      _resetPage();
    });
  }

  // ── Mutadores públicos (invocados desde child widgets) ─────────────────────
  void setFocusedPatente(DatoPatente? p) => setState(() => _focusedPatente = p);
  void setPage(int p) => setState(() => _page = p);
  void toggleLast30Days() => setState(() {
        _last30Days = !_last30Days;
        _resetPage();
      });
  void setYear(String v) => setState(() { _year = v; _resetPage(); });
  void setMonth(String v) => setState(() { _month = v; _resetPage(); });
  void setGeo(String v) => setState(() { _geo = v; _resetPage(); });
  void setSearch(String v) => setState(() { _search = v; _resetPage(); });

  int get _activeCount => switch (_activeSource) {
        'patentes' => _srcPatentes.length,
        'permisos' => _srcPermisos.length,
        'transito' => _srcTransito.length,
        _ => _srcOrgs.length,
      };

  @override
  Widget build(BuildContext context) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncProviders(patentes, permisos, transito, orgs);
    });

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
    final loading = patentesAsync.isLoading || permisosAsync.isLoading ||
        transitoAsync.isLoading || orgsAsync.isLoading;
    final hasError = patentesAsync.hasError || permisosAsync.hasError ||
        transitoAsync.hasError || orgsAsync.hasError;

    return LayoutBuilder(builder: (context, c) {
      final isMobile = c.maxWidth < 768;
      return isMobile
          ? _MobileLayout(state: this, status: status, patentes: patentes,
              permisos: permisos, transito: transito, orgs: orgs,
              loading: loading, hasError: hasError)
          : _DesktopLayout(state: this, status: status, patentes: patentes,
              permisos: permisos, transito: transito, orgs: orgs,
              loading: loading, hasError: hasError);
    });
  }

  Future<void> _scrapeNow() async {
    final confirm = await _confirmDialog(
      title: 'Scrappear ahora',
      message:
          'Se iniciará la extracción de datos recientes desde lotatransparente.cl. '
          'La operación puede demorar entre 1 y 3 minutos.\n\n¿Continuar?',
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
          'Descargará datos de múltiples años. Rate-limit de 2 req/s.\n\n¿Continuar?',
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

  Future<void> _stopScraping() async {
    final confirm = await _confirmDialog(
      title: 'Detener scraping',
      message:
          'Se cancelará la extracción en curso. Los datos ya insertados se mantienen.\n\n¿Continuar?',
    );
    if (confirm != true || !mounted) return;
    final res = await ref.read(scrapingControllerProvider).stop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        res.ok ? 'Solicitud de detención enviada' : (res.error ?? 'No se pudo detener'),
      )),
    );
  }

  Future<bool?> _confirmDialog({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: _T.warningDot, size: 22),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.45)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _T.or6, foregroundColor: Colors.white),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DESKTOP LAYOUT — Sub-header + Progress strip + Sidebar + Main + MapPanel
// ════════════════════════════════════════════════════════════════════════════

class _DesktopLayout extends StatelessWidget {
  final _ScrapingScreenState state;
  final ScrapingStatus status;
  final List<DatoPatente> patentes;
  final List<DatoPermiso> permisos;
  final List<DatoTransito> transito;
  final List<DatoOrganizacion> orgs;
  final bool loading;
  final bool hasError;

  const _DesktopLayout({
    required this.state, required this.status,
    required this.patentes, required this.permisos,
    required this.transito, required this.orgs,
    required this.loading, required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final activeMeta = _sources.firstWhere((s) => s.id == state._activeSource);

    return Container(
      color: _T.s100,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _SubHeader(state: state, status: status, activeLabel: activeMeta.label, totalRegs: state._activeCount),
        if (status.running) _ProgressStrip(status: status, onCancel: state._stopScraping),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _Sidebar(state: state),
            Expanded(
              child: _MainPane(
                state: state, activeMeta: activeMeta,
                patentes: patentes, permisos: permisos,
                transito: transito, orgs: orgs,
                loading: loading, hasError: hasError,
              ),
            ),
            if (state._focusedPatente != null)
              _MapDetailPanel(
                rec: state._focusedPatente!,
                onClose: () => state.setFocusedPatente(null),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final _ScrapingScreenState state;
  final ScrapingStatus status;
  final String activeLabel;
  final int totalRegs;
  const _SubHeader({required this.state, required this.status, required this.activeLabel, required this.totalRegs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.s200)),
      ),
      child: Row(children: [
        const Icon(LucideIcons.briefcase, size: 18, color: _T.or6),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Transparencia pública',
              style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.17, height: 1, color: _T.s900)),
          const SizedBox(height: 3),
          Text('Ley 20.285 · lotatransparente.cl · $totalRegs registros sincronizados',
              style: const TextStyle(fontSize: 10.5, color: _T.s500, letterSpacing: 0.2)),
        ]),
        const Spacer(),
        if (status.running)
          _LiveScrapingPill(step: status.step, total: status.totalSteps)
        else
          _SubHeaderBtn(icon: LucideIcons.refreshCw, label: 'Scrappear', primary: true, onTap: state._scrapeNow),
        const SizedBox(width: 8),
        _SubHeaderBtn(icon: LucideIcons.clock, label: 'Histórico', onTap: state._scrapeHistorico),
      ]),
    );
  }
}

class _LiveScrapingPill extends StatefulWidget {
  final int step;
  final int total;
  const _LiveScrapingPill({required this.step, required this.total});

  @override
  State<_LiveScrapingPill> createState() => _LiveScrapingPillState();
}

class _LiveScrapingPillState extends State<_LiveScrapingPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _T.or1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _T.or3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.3).animate(_ac),
          child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: _T.or6, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 6),
        Text('Scrappeando · ${widget.step}/${widget.total}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _T.or7)),
      ]),
    );
  }
}

class _SubHeaderBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _SubHeaderBtn({required this.icon, required this.label, this.primary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? _T.or6 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary ? _T.or6 : _T.s200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: primary ? Colors.white : _T.s600),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: primary ? Colors.white : _T.s800,
          )),
        ]),
      ),
    );
  }
}

class _ProgressStrip extends StatefulWidget {
  final ScrapingStatus status;
  final VoidCallback onCancel;
  const _ProgressStrip({required this.status, required this.onCancel});

  @override
  State<_ProgressStrip> createState() => _ProgressStripState();
}

class _ProgressStripState extends State<_ProgressStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _spin.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.status.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final label = widget.status.fuenteLabel.isEmpty ? 'Iniciando…' : widget.status.fuenteLabel;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 9, 28, 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.s200)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          RotationTransition(
            turns: _spin,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _T.or2, width: 2),
              ),
              child: CustomPaint(painter: _SpinnerArcPainter()),
            ),
          ),
          const SizedBox(width: 10),
          Text.rich(TextSpan(children: [
            const TextSpan(text: 'Scrappeando ',
                style: TextStyle(fontWeight: FontWeight.w700, color: _T.s900, fontSize: 11.5)),
            TextSpan(text: label, style: const TextStyle(color: _T.s700, fontSize: 11.5)),
          ])),
          const SizedBox(width: 10),
          const Text('·', style: TextStyle(color: _T.s400)),
          const SizedBox(width: 10),
          Text('${widget.status.step}/${widget.status.totalSteps}',
              style: GoogleFonts.jetBrainsMono(color: _T.s900, fontWeight: FontWeight.w600, fontSize: 11.5)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(color: _T.or2, borderRadius: BorderRadius.circular(999)),
            child: Text('$pct%',
                style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.s600,
              side: const BorderSide(color: _T.s200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: Stack(children: [
              Container(color: _T.s100),
              FractionallySizedBox(
                widthFactor: widget.status.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_T.or5, _T.or6]),
                    boxShadow: [BoxShadow(color: _T.or6.withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SpinnerArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _T.or6
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final r = (size.width - 2) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: r),
      -1.57, 1.4, false, paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Sidebar extends StatelessWidget {
  final _ScrapingScreenState state;
  const _Sidebar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: _T.s50,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: _T.s200)),
      ),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _SidebarCaption('Fuentes'),
          const SizedBox(height: 8),
          ..._sources.map((s) {
            final count = switch (s.id) {
              'patentes' => state._srcPatentes.length,
              'permisos' => state._srcPermisos.length,
              'transito' => state._srcTransito.length,
              _ => state._srcOrgs.length,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SidebarSourceCard(
                meta: s,
                count: count,
                active: state._activeSource == s.id,
                onTap: () => state._setSource(s.id),
              ),
            );
          }),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _T.s200),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _SidebarCaption('Filtros'),
              const SizedBox(height: 8),
              _SidebarFilterRow(
                label: 'Rango temporal',
                value: state._last30Days ? 'Últimos 30 días' : 'Todos',
                active: state._last30Days,
                onTap: state.toggleLast30Days,
              ),
              const SizedBox(height: 8),
              _SidebarFilterRow(
                label: 'Año',
                value: state._year == 'all' ? 'Todos' : state._year,
                onTap: () => _pickFromList(context, state, 'year',
                    const [('all','Todos'),('2026','2026'),('2025','2025'),('2024','2024')]),
              ),
              const SizedBox(height: 8),
              _SidebarFilterRow(
                label: 'Mes',
                value: _monthLabel(state._month),
                onTap: () => _pickFromList(context, state, 'month',
                    const [('all','Todos'),('1','Enero'),('2','Febrero'),('3','Marzo'),('4','Abril'),
                           ('5','Mayo'),('6','Junio'),('7','Julio'),('8','Agosto'),
                           ('9','Septiembre'),('10','Octubre'),('11','Noviembre'),('12','Diciembre')]),
              ),
              const SizedBox(height: 8),
              _SidebarFilterRow(
                label: 'Geocoding',
                value: _geoLabel(state._geo),
                onTap: () => _pickFromList(context, state, 'geo',
                    const [('all','Todos'),('high','Confianza alta'),('med','Confianza media'),
                           ('low','Confianza baja'),('failed','Fallo')]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _T.s300, style: BorderStyle.solid),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _T.s300),
            ),
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sobre el scraping',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _T.s900, fontSize: 12)),
              SizedBox(height: 4),
              Text.rich(TextSpan(
                style: TextStyle(fontSize: 11.2, color: _T.s600, height: 1.45),
                children: [
                  TextSpan(text: 'Datos extraídos diariamente a las '),
                  TextSpan(text: '03:00 AM', style: TextStyle(fontWeight: FontWeight.w700, color: _T.s800)),
                  TextSpan(text: ' desde lotatransparente.cl (Ley 20.285). "Scrappear histórico" puede tardar varios minutos.'),
                ],
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  String _monthLabel(String m) {
    const months = {'all':'Todos','1':'Enero','2':'Febrero','3':'Marzo','4':'Abril',
      '5':'Mayo','6':'Junio','7':'Julio','8':'Agosto',
      '9':'Septiembre','10':'Octubre','11':'Noviembre','12':'Diciembre'};
    return months[m] ?? 'Todos';
  }

  String _geoLabel(String g) {
    const labels = {'all':'Todos','high':'Confianza alta','med':'Confianza media',
      'low':'Confianza baja','failed':'Fallo'};
    return labels[g] ?? 'Todos';
  }

  void _pickFromList(BuildContext context, _ScrapingScreenState state,
      String field, List<(String, String)> items) async {
    final picked = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(280, 200, 0, 0),
      items: items.map((e) => PopupMenuItem(value: e.$1, child: Text(e.$2, style: const TextStyle(fontSize: 13)))).toList(),
    );
    if (picked == null) return;
    if (field == 'year') state.setYear(picked);
    if (field == 'month') state.setMonth(picked);
    if (field == 'geo') state.setGeo(picked);
  }
}

class _SidebarCaption extends StatelessWidget {
  final String text;
  const _SidebarCaption(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _T.s500, letterSpacing: 0.9),
      );
}

class _SidebarSourceCard extends StatelessWidget {
  final _SourceMeta meta;
  final int count;
  final bool active;
  final VoidCallback onTap;
  const _SidebarSourceCard({required this.meta, required this.count, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: active ? _T.or1 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            top: BorderSide(color: active ? _T.or3 : _T.s200),
            right: BorderSide(color: active ? _T.or3 : _T.s200),
            bottom: BorderSide(color: active ? _T.or3 : _T.s200),
            left: BorderSide(color: active ? _T.or6 : _T.s300, width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(meta.label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
                    color: active ? _T.or7 : _T.s800))),
            Text('$count', style: GoogleFonts.spaceGrotesk(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: active ? _T.or7 : _T.s400)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 5, height: 5, decoration: BoxDecoration(
                color: active ? _T.successDot : _T.s400, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('ig ${meta.ig}',
                style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: _T.s500)),
            const SizedBox(width: 4),
            const Text('·', style: TextStyle(color: _T.s300, fontSize: 11)),
            const SizedBox(width: 4),
            Text(meta.lastTime,
                style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: _T.s500)),
          ]),
        ]),
      ),
    );
  }
}

class _SidebarFilterRow extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;
  const _SidebarFilterRow({required this.label, required this.value, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _T.or1 : _T.s50,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: active ? _T.or3 : _T.s200),
        ),
        child: Row(children: [
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 10.5, color: _T.s500, fontWeight: FontWeight.w600))),
          Text(value, style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600,
              color: active ? _T.or7 : _T.s900)),
          const SizedBox(width: 5),
          Icon(LucideIcons.chevronDown, size: 10, color: active ? _T.or7 : _T.s400),
        ]),
      ),
    );
  }
}

class _MainPane extends StatelessWidget {
  final _ScrapingScreenState state;
  final _SourceMeta activeMeta;
  final List<DatoPatente> patentes;
  final List<DatoPermiso> permisos;
  final List<DatoTransito> transito;
  final List<DatoOrganizacion> orgs;
  final bool loading;
  final bool hasError;
  const _MainPane({required this.state, required this.activeMeta,
    required this.patentes, required this.permisos,
    required this.transito, required this.orgs,
    required this.loading, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final filteredCount = switch (state._activeSource) {
      'patentes' => patentes.length,
      'permisos' => permisos.length,
      'transito' => transito.length,
      _ => orgs.length,
    };
    final totalCount = state._activeCount;
    final highCount = state._srcPatentes.where((p) => p.confianza == 'high').length;
    final failCount = state._srcPatentes.where((p) => p.confianza == 'failed').length;
    final pctHigh = totalCount == 0 ? 0 : (highCount * 100 / totalCount).round();

    return Container(
      color: _T.s100,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header inline
          _MainHeaderInline(state: state, activeMeta: activeMeta, totalCount: totalCount),
          const SizedBox(height: 14),
          // KPI strip
          Row(children: [
            Expanded(child: _KpiCard(
              label: 'MOSTRANDO', value: '$filteredCount', sub: 'de $totalCount registros',
              bg: _T.or1, valueColor: _T.or7,
            )),
            const SizedBox(width: 10),
            Expanded(child: _KpiCard(
              label: 'GEOCODING ALTO', value: '$highCount', sub: '$pctHigh % del total',
              bg: const Color(0xFFF0FDF4), valueColor: _T.successFg,
            )),
            const SizedBox(width: 10),
            Expanded(child: _KpiCard(
              label: 'FALLOS GEOCODING', value: '$failCount', sub: 'requieren revisión',
              bg: const Color(0xFFFEFCE8), valueColor: _T.warningFg,
            )),
          ]),
          const SizedBox(height: 14),
          // Tabla
          _PatentesTable(
            state: state,
            items: state._activeSource == 'patentes' ? state._paginate(patentes) : const [],
            loading: loading, hasError: hasError,
            activeSource: state._activeSource,
            permisos: state._activeSource == 'permisos' ? state._paginate(permisos) : const [],
            transito: state._activeSource == 'transito' ? state._paginate(transito) : const [],
            orgs: state._activeSource == 'organizaciones' ? state._paginate(orgs) : const [],
          ),
          const SizedBox(height: 14),
          // Paginación
          _DesktopPagination(
            currentPage: state._page,
            totalItems: filteredCount,
            pageSize: _ScrapingScreenState._pageSize,
            onPageChange: state.setPage,
          ),
        ]),
      ),
    );
  }
}

class _MainHeaderInline extends StatelessWidget {
  final _ScrapingScreenState state;
  final _SourceMeta activeMeta;
  final int totalCount;
  const _MainHeaderInline({required this.state, required this.activeMeta, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(activeMeta.label,
              style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.33, color: _T.s900)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _T.or2, borderRadius: BorderRadius.circular(999)),
            child: Text('$totalCount', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _T.or7)),
          ),
        ]),
        const SizedBox(height: 4),
        Wrap(spacing: 14, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('Fuente ', style: TextStyle(fontSize: 11, color: _T.s400)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(color: _T.or1, borderRadius: BorderRadius.circular(5)),
              child: const Text('lotatransparente.cl ↗',
                  style: TextStyle(fontSize: 10.5, color: _T.or7, fontWeight: FontWeight.w600)),
            ),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('ig ', style: TextStyle(fontSize: 11, color: _T.s400)),
            Text(activeMeta.ig,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: _T.s800, fontWeight: FontWeight.w700)),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('Última extracción ', style: TextStyle(fontSize: 11, color: _T.s400)),
            Text('2026-04-24 · ${activeMeta.lastTime}',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: _T.s800, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ])),
      // Buscador
      SizedBox(
        width: 220,
        height: 33,
        child: TextField(
          onChanged: state.setSearch,
          decoration: InputDecoration(
            hintText: state._activeSource == 'patentes'
                ? 'Buscar razón social, RUT…'
                : 'Buscar...',
            hintStyle: const TextStyle(fontSize: 12, color: _T.s400),
            prefixIcon: const Icon(LucideIcons.search, size: 13, color: _T.s400),
            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _T.s200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _T.s200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _T.or6)),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      const SizedBox(width: 8),
      _SubHeaderBtn(icon: LucideIcons.download, label: 'CSV', onTap: () {}),
    ]);
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color bg;
  final Color valueColor;
  const _KpiCard({required this.label, required this.value, required this.sub, required this.bg, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.s200),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: _T.s500)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, height: 1.1, color: valueColor)),
        const SizedBox(height: 1),
        Text(sub, style: const TextStyle(fontSize: 10.5, color: _T.s500)),
      ]),
    );
  }
}

class _PatentesTable extends StatelessWidget {
  final _ScrapingScreenState state;
  final List<DatoPatente> items;
  final List<DatoPermiso> permisos;
  final List<DatoTransito> transito;
  final List<DatoOrganizacion> orgs;
  final bool loading;
  final bool hasError;
  final String activeSource;
  const _PatentesTable({
    required this.state, required this.items,
    required this.permisos, required this.transito, required this.orgs,
    required this.loading, required this.hasError, required this.activeSource,
  });

  @override
  Widget build(BuildContext context) {
    final hasMapPanel = state._focusedPatente != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.s200),
      ),
      clipBehavior: Clip.antiAlias,
      child: loading
          ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          : hasError
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text(
                  'Error al cargar datos del servidor', style: TextStyle(color: _T.s500))))
              : switch (activeSource) {
                  'patentes' => _patentesTable(hasMapPanel: hasMapPanel),
                  'permisos' => _permisosTable(),
                  'transito' => _transitoTable(),
                  _ => _orgsTable(),
                },
    );
  }

  Widget _patentesTable({required bool hasMapPanel}) {
    if (items.isEmpty) return const _EmptyState();
    return Column(children: [
      // Header
      Container(
        color: _T.s50,
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
        child: const Row(children: [
          Expanded(flex: 75, child: _ThText('N° decreto')),
          Expanded(flex: 90, child: _ThText('Fecha')),
          Expanded(flex: 110, child: _ThText('Tipo')),
          Expanded(flex: 185, child: _ThText('Razón social')),
          Expanded(flex: 140, child: _ThText('Dirección')),
          Expanded(flex: 70, child: _ThText('Geocoding')),
          SizedBox(width: 40),
        ]),
      ),
      // Rows
      ...items.asMap().entries.map((e) {
        final p = e.value;
        final on = state._focusedPatente?.nDecreto == p.nDecreto;
        return InkWell(
          onTap: () => state.setFocusedPatente(on ? null : p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: on ? _T.or1 : Colors.transparent,
            padding: EdgeInsets.fromLTRB(on ? 13 : 16, 12, 16, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: e.key < items.length - 1 ? const BorderSide(color: _T.s100) : BorderSide.none,
                left: BorderSide(color: on ? _T.or6 : Colors.transparent, width: 3),
              ),
            ),
            child: Row(children: [
              Expanded(flex: 75, child: Text('#${p.nDecreto}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: _T.or7))),
              Expanded(flex: 90, child: Text(p.fechaDecreto,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s700))),
              Expanded(flex: 110, child: _TipoBadge(tipo: _shortTipo(p.tipo), cls: 'Datos sensibles')),
              Expanded(flex: 185, child: Text(p.razonSocial,
                  overflow: TextOverflow.ellipsis, maxLines: 1,
                  style: TextStyle(fontSize: 12, color: _T.s900,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500))),
              Expanded(flex: 140, child: Row(children: [
                const Icon(LucideIcons.mapPin, size: 11, color: _T.s400),
                const SizedBox(width: 5),
                Expanded(child: Text(p.direccion,
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                    style: const TextStyle(fontSize: 11.5, color: _T.s800))),
              ])),
              Expanded(flex: 70, child: _GeoBadge(confianza: p.confianza)),
              SizedBox(width: 40, child: Center(child: on
                  ? const Icon(LucideIcons.chevronRight, size: 14, color: _T.or6)
                  : const Icon(LucideIcons.moreHorizontal, size: 13, color: _T.s500))),
            ]),
          ),
        );
      }),
    ]);
  }

  String _shortTipo(String tipo) {
    if (tipo.isEmpty) return 'COMER';
    final up = tipo.toUpperCase();
    if (up.length <= 8) return up;
    return up.substring(0, 5);
  }

  Widget _permisosTable() {
    if (permisos.isEmpty) return const _EmptyState();
    return Column(children: [
      Container(
        color: _T.s50,
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
        child: const Row(children: [
          Expanded(flex: 100, child: _ThText('N° Permiso')),
          Expanded(flex: 110, child: _ThText('Tipo')),
          Expanded(flex: 200, child: _ThText('Descripción')),
          Expanded(flex: 160, child: _ThText('Dirección')),
          Expanded(flex: 90, child: _ThText('Fecha')),
          Expanded(flex: 80, child: _ThText('Estado')),
        ]),
      ),
      ...permisos.asMap().entries.map((e) {
        final p = e.value;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(border: Border(
            bottom: e.key < permisos.length - 1 ? const BorderSide(color: _T.s100) : BorderSide.none,
          )),
          child: Row(children: [
            Expanded(flex: 100, child: Text(p.nPermiso,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: _T.or7))),
            Expanded(flex: 110, child: Text(p.tipo, style: const TextStyle(fontSize: 12, color: _T.s800))),
            Expanded(flex: 200, child: Text(p.descripcion, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 160, child: Text(p.direccion, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 90, child: Text(p.fecha,
                style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 80, child: _EstadoBadge(estado: p.estado)),
          ]),
        );
      }),
    ]);
  }

  Widget _transitoTable() {
    if (transito.isEmpty) return const _EmptyState();
    return Column(children: [
      Container(
        color: _T.s50,
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
        child: const Row(children: [
          Expanded(flex: 100, child: _ThText('N° Decreto')),
          Expanded(flex: 100, child: _ThText('Tipo')),
          Expanded(flex: 200, child: _ThText('Dirección')),
          Expanded(flex: 200, child: _ThText('Motivo')),
          Expanded(flex: 90, child: _ThText('Desde')),
          Expanded(flex: 90, child: _ThText('Hasta')),
        ]),
      ),
      ...transito.asMap().entries.map((e) {
        final t = e.value;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(border: Border(
            bottom: e.key < transito.length - 1 ? const BorderSide(color: _T.s100) : BorderSide.none,
          )),
          child: Row(children: [
            Expanded(flex: 100, child: Text(t.nDecreto,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: _T.or7))),
            Expanded(flex: 100, child: Text(t.tipo, style: const TextStyle(fontSize: 12, color: _T.s800))),
            Expanded(flex: 200, child: Text(t.direccion, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _T.s800))),
            Expanded(flex: 200, child: Text(t.motivo, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 90, child: Text(t.fechaInicio,
                style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 90, child: Text(t.fechaFin,
                style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s700))),
          ]),
        );
      }),
    ]);
  }

  Widget _orgsTable() {
    if (orgs.isEmpty) return const _EmptyState();
    return Column(children: [
      Container(
        color: _T.s50,
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
        child: const Row(children: [
          Expanded(flex: 100, child: _ThText('N°')),
          Expanded(flex: 100, child: _ThText('Tipo')),
          Expanded(flex: 200, child: _ThText('Nombre')),
          Expanded(flex: 160, child: _ThText('Representante')),
          Expanded(flex: 100, child: _ThText('RUT Rep.')),
          Expanded(flex: 100, child: _ThText('Sector')),
        ]),
      ),
      ...orgs.asMap().entries.map((e) {
        final o = e.value;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(border: Border(
            bottom: e.key < orgs.length - 1 ? const BorderSide(color: _T.s100) : BorderSide.none,
          )),
          child: Row(children: [
            Expanded(flex: 100, child: Text(o.nPersonalidad,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: _T.or7))),
            Expanded(flex: 100, child: Text(o.tipo, style: const TextStyle(fontSize: 12, color: _T.s800))),
            Expanded(flex: 200, child: Text(o.nombre, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _T.s900))),
            Expanded(flex: 160, child: Text(o.representante, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _T.s700))),
            Expanded(flex: 100, child: Text(o.rutRep,
                style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s800))),
            Expanded(flex: 100, child: Text(o.sector, style: const TextStyle(fontSize: 11.5, color: _T.s700))),
          ]),
        );
      }),
    ]);
  }
}

class _ThText extends StatelessWidget {
  final String text;
  const _ThText(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: _T.s500),
      );
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  final String cls;
  const _TipoBadge({required this.tipo, required this.cls});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: _T.or2, borderRadius: BorderRadius.circular(5)),
        child: Text(tipo,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: _T.or7)),
      ),
      const SizedBox(height: 2),
      Text(cls, style: const TextStyle(fontSize: 10, color: _T.s500)),
    ]);
  }
}

class _GeoBadge extends StatelessWidget {
  final String confianza;
  const _GeoBadge({required this.confianza});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, dot) = switch (confianza) {
      'high' => ('Alta', _T.successBg, _T.successFg, _T.successDot),
      'med' => ('Media', _T.warningBg, _T.warningFg, _T.warningDot),
      'low' => ('Baja', _T.warningBg, _T.warningFg, _T.warningDot),
      _ => ('Fallo', _T.s100, _T.s600, _T.s400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final isActivo = estado.toLowerCase().contains('vigent') || estado.toLowerCase() == 'activo';
    final (bg, fg) = isActivo ? (_T.successBg, _T.successFg) : (_T.s100, _T.s600);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(estado, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: Text('No se encontraron registros', style: TextStyle(color: _T.s500))),
  );
}

class _DesktopPagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChange;
  const _DesktopPagination({required this.currentPage, required this.totalItems, required this.pageSize, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();
    final lastPage = ((totalItems - 1) ~/ pageSize);
    final page = currentPage.clamp(0, lastPage);
    final start = page * pageSize + 1;
    final end = ((page + 1) * pageSize) > totalItems ? totalItems : ((page + 1) * pageSize);
    return Row(children: [
      Text.rich(TextSpan(children: [
        const TextSpan(text: 'Mostrando ', style: TextStyle(fontSize: 12, color: _T.s600)),
        TextSpan(text: '$start–$end', style: const TextStyle(fontSize: 12, color: _T.s900, fontWeight: FontWeight.w700)),
        const TextSpan(text: ' de ', style: TextStyle(fontSize: 12, color: _T.s600)),
        TextSpan(text: '$totalItems', style: const TextStyle(fontSize: 12, color: _T.s900, fontWeight: FontWeight.w700)),
      ])),
      const Spacer(),
      _PageBtn(icon: LucideIcons.chevronLeft, enabled: page > 0, onTap: () => onPageChange(page - 1)),
      const SizedBox(width: 4),
      ..._pageButtons(page, lastPage),
      const SizedBox(width: 4),
      _PageBtn(icon: LucideIcons.chevronRight, enabled: page < lastPage, onTap: () => onPageChange(page + 1)),
    ]);
  }

  List<Widget> _pageButtons(int current, int lastPage) {
    final pages = <int>{0, lastPage};
    for (var i = current - 1; i <= current + 1; i++) {
      if (i >= 0 && i <= lastPage) pages.add(i);
    }
    final sorted = pages.toList()..sort();
    final widgets = <Widget>[];
    for (var i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      widgets.add(_PageNumBtn(num: p + 1, active: p == current, onTap: () => onPageChange(p)));
      if (i < sorted.length - 1 && sorted[i + 1] - p > 1) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('…', style: TextStyle(color: _T.s400)),
        ));
      }
      if (i < sorted.length - 1) widgets.add(const SizedBox(width: 4));
    }
    return widgets;
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PageBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : _T.s100,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _T.s200),
        ),
        child: Icon(icon, size: 14, color: enabled ? _T.s700 : _T.s300),
      ),
    );
  }
}

class _PageNumBtn extends StatelessWidget {
  final int num;
  final bool active;
  final VoidCallback onTap;
  const _PageNumBtn({required this.num, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _T.or6 : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: active ? _T.or6 : _T.s200),
        ),
        child: Text('$num', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? Colors.white : _T.s700)),
      ),
    );
  }
}

class _MapDetailPanel extends StatelessWidget {
  final DatoPatente rec;
  final VoidCallback onClose;
  const _MapDetailPanel({required this.rec, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      color: Colors.white,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: _T.s200)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
          child: Row(children: [
            const Icon(LucideIcons.mapPin, size: 15, color: _T.or6),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Registro seleccionado',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1, color: _T.s900)),
              const SizedBox(height: 3),
              Text('#${rec.nDecreto} · click otra fila para cambiar',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: _T.s500)),
            ])),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: _T.s100, borderRadius: BorderRadius.circular(6)),
                child: const Icon(LucideIcons.x, size: 12, color: _T.s600),
              ),
            ),
          ]),
        ),
        Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Mini-map placeholder
          _MiniMap(lat: rec.lat, lng: rec.lng, confianza: rec.confianza),
          // Detail card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _TipoBadge(tipo: 'COMER', cls: ''),
                const SizedBox(width: 8),
                _GeoBadge(confianza: rec.confianza),
                const Spacer(),
                Text('#${rec.nDecreto}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
              ]),
              const SizedBox(height: 8),
              Text(rec.razonSocial,
                  style: GoogleFonts.spaceGrotesk(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.2, color: _T.s900)),
              const SizedBox(height: 3),
              const Text('Datos sensibles',
                  style: TextStyle(fontSize: 11, color: _T.s500, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Container(height: 1, color: _T.s200),
              const SizedBox(height: 12),
              _MetaRow(label: 'RUT', value: rec.rut, mono: true, bold: true),
              const SizedBox(height: 7),
              _MetaRow(label: 'Giro', value: rec.giro.isEmpty ? '—' : rec.giro),
              const SizedBox(height: 7),
              _MetaRow(label: 'Dirección', value: rec.direccion),
              const SizedBox(height: 7),
              _MetaRow(label: 'Coords.', value: '${rec.lat.toStringAsFixed(4)}, ${rec.lng.toStringAsFixed(4)}', mono: true),
              const SizedBox(height: 7),
              _MetaRow(label: 'Fecha', value: rec.fechaDecreto, mono: true),
              const SizedBox(height: 7),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(width: 70, child: Text('Fuente',
                    style: TextStyle(fontSize: 11.5, color: _T.s500, fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(color: _T.or1, borderRadius: BorderRadius.circular(5)),
                  child: const Text('lotatransparente.cl ↗',
                      style: TextStyle(fontSize: 10.5, color: _T.or7, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _T.or6,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [BoxShadow(color: _T.or7.withValues(alpha: 0.3), blurRadius: 2, offset: const Offset(0, 1))],
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(LucideIcons.map, size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Abrir en mapa',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ]),
                  ),
                )),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: _T.s200),
                    ),
                    child: const Text('Decreto PDF',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.s700)),
                  ),
                ),
              ]),
            ]),
          ),
        ]))),
      ]),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool bold;
  const _MetaRow({required this.label, required this.value, this.mono = false, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 70, child: Text(label,
          style: const TextStyle(fontSize: 11.5, color: _T.s500, fontWeight: FontWeight.w600))),
      Expanded(child: Text(value, style: (mono
              ? GoogleFonts.jetBrainsMono(fontSize: 11.5, color: _T.s900, fontWeight: bold ? FontWeight.w600 : FontWeight.w500)
              : TextStyle(fontSize: 11.5, color: _T.s900, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)))),
    ]);
  }
}

class _MiniMap extends StatelessWidget {
  final double lat;
  final double lng;
  final String confianza;
  const _MiniMap({required this.lat, required this.lng, required this.confianza});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: const Color(0xFFE8EDF2),
      child: Stack(children: [
        // Grid placeholder background
        CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
        // Halo
        Align(
          alignment: const Alignment(0, -0.16),
          child: Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: _T.or6.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _T.or6, width: 1.5, style: BorderStyle.solid),
            ),
          ),
        ),
        // Pin
        Align(
          alignment: const Alignment(0, -0.40),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _T.or6,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: _T.s900.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(LucideIcons.mapPin, size: 14, color: Colors.white),
          ),
        ),
        // Zoom controls
        Positioned(
          top: 10, right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _T.s200),
              boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1))],
            ),
            child: Column(children: [
              _ZoomBtn(symbol: '+', divider: true),
              _ZoomBtn(symbol: '−'),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final String symbol;
  final bool divider;
  const _ZoomBtn({required this.symbol, this.divider = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: _T.s200)) : null,
      ),
      alignment: Alignment.center,
      child: Text(symbol, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.s700)),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x0A000000)..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (var x = 0.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT — Header + KPI strip + Segmented + Filter chips + Lista densa
// ════════════════════════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  final _ScrapingScreenState state;
  final ScrapingStatus status;
  final List<DatoPatente> patentes;
  final List<DatoPermiso> permisos;
  final List<DatoTransito> transito;
  final List<DatoOrganizacion> orgs;
  final bool loading;
  final bool hasError;
  const _MobileLayout({
    required this.state, required this.status,
    required this.patentes, required this.permisos,
    required this.transito, required this.orgs,
    required this.loading, required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCount = switch (state._activeSource) {
      'patentes' => patentes.length,
      'permisos' => permisos.length,
      'transito' => transito.length,
      _ => orgs.length,
    };

    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _MobileAppHeader(state: state, status: status),
        if (status.running) _ProgressStrip(status: status, onCancel: state._stopScraping),
        _MobileKpiStrip(state: state),
        _MobileSegmented(state: state),
        _MobileFilterBar(state: state, filteredCount: filteredCount, totalCount: state._activeCount),
        Expanded(
          child: Container(
            color: Colors.white,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(child: Text('Error al cargar datos del servidor',
                        style: TextStyle(color: _T.s500)))
                    : _MobileDataList(
                        state: state,
                        patentes: state._activeSource == 'patentes' ? state._paginate(patentes) : const [],
                        permisos: state._activeSource == 'permisos' ? state._paginate(permisos) : const [],
                        transito: state._activeSource == 'transito' ? state._paginate(transito) : const [],
                        orgs: state._activeSource == 'organizaciones' ? state._paginate(orgs) : const [],
                        totalFiltered: filteredCount,
                      ),
          ),
        ),
      ]),
    );
  }
}

class _MobileAppHeader extends StatelessWidget {
  final _ScrapingScreenState state;
  final ScrapingStatus status;
  const _MobileAppHeader({required this.state, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(LucideIcons.briefcase, size: 18, color: _T.or6),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Transparencia pública',
                style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.16, height: 1.1, color: _T.s900)),
            const SizedBox(height: 2),
            const Text('Ley 20.285 · lotatransparente.cl',
                style: TextStyle(fontSize: 9.5, color: _T.s500, letterSpacing: 0.3)),
          ])),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _T.s200),
              ),
              child: const Icon(LucideIcons.search, size: 14, color: _T.s700),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _T.s50,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _T.s200),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: _T.successBg, borderRadius: BorderRadius.circular(999)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                _Dot(color: _T.successDot, size: 5),
                SizedBox(width: 4),
                Text('Activo', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _T.successFg)),
              ]),
            ),
            const SizedBox(width: 6),
            Text('hoy · 03:00 AM',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _T.s600)),
            const Spacer(),
            if (status.running)
              InkWell(
                onTap: state._stopScraping,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _T.dangerFg, borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.stopCircle, size: 9, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Detener', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              )
            else
              InkWell(
                onTap: state._scrapeNow,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _T.or6, borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.refreshCw, size: 9, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Scrappear', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ),
            const SizedBox(width: 6),
            InkWell(
              onTap: state._scrapeHistorico,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _T.s200),
                ),
                child: const Text('Histórico',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _T.s700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MobileKpiStrip extends StatelessWidget {
  final _ScrapingScreenState state;
  const _MobileKpiStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final counts = {
      'patentes': state._srcPatentes.length,
      'permisos': state._srcPermisos.length,
      'transito': state._srcTransito.length,
      'organizaciones': state._srcOrgs.length,
    };
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _sources.map((s) {
          final isActive = state._activeSource == s.id;
          final count = counts[s.id] ?? 0;
          final hasData = count > 0;
          return GestureDetector(
            onTap: () => state._setSource(s.id),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
              decoration: BoxDecoration(
                color: isActive ? _T.or1 : _T.s50,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: isActive ? _T.or3 : _T.s200),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('$count',
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, height: 1,
                        color: hasData ? _T.or7 : _T.s400)),
                const SizedBox(height: 3),
                Text(s.short,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                        color: isActive ? _T.or7 : _T.s700)),
                const SizedBox(height: 1),
                Text(_subFor(s.id),
                    style: const TextStyle(fontSize: 8.5, color: _T.s500, letterSpacing: 0.3)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _subFor(String id) => switch (id) {
        'patentes' => 'comerciales',
        'permisos' => 'permisos',
        'transito' => 'tránsito',
        _ => 'sociales',
      };
}

class _MobileSegmented extends StatelessWidget {
  final _ScrapingScreenState state;
  const _MobileSegmented({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: _T.s100, borderRadius: BorderRadius.circular(8)),
        child: Row(children: _sources.map((s) {
          final on = state._activeSource == s.id;
          final count = switch (s.id) {
            'patentes' => state._srcPatentes.length,
            'permisos' => state._srcPermisos.length,
            'transito' => state._srcTransito.length,
            _ => state._srcOrgs.length,
          };
          return Expanded(child: GestureDetector(
            onTap: () => state._setSource(s.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              decoration: BoxDecoration(
                color: on ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: on ? const [BoxShadow(color: Color(0x12000000), blurRadius: 2, offset: Offset(0, 1))] : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text(s.short,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        color: on ? _T.or7 : _T.s500))),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: on ? _T.or2 : _T.s200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: on ? _T.or7 : _T.s500)),
                ),
              ]),
            ),
          ));
        }).toList()),
      ),
    );
  }
}

class _MobileFilterBar extends StatelessWidget {
  final _ScrapingScreenState state;
  final int filteredCount;
  final int totalCount;
  const _MobileFilterBar({required this.state, required this.filteredCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: _T.s50,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s200))),
      child: Row(children: [
        const Icon(LucideIcons.filter, size: 11, color: _T.s500),
        const SizedBox(width: 6),
        _Chip(
          label: '30 días',
          active: state._last30Days,
          onTap: state.toggleLast30Days,
        ),
        const SizedBox(width: 6),
        _Chip(label: 'Año ${state._year == 'all' ? 'Todos' : state._year}', onTap: () {}),
        const SizedBox(width: 6),
        _Chip(label: 'Mes ${state._month == 'all' ? 'Todos' : state._month}', onTap: () {}),
        const SizedBox(width: 6),
        _Chip(label: 'Geo ${state._geo == 'all' ? 'Todos' : state._geo}', onTap: () {}),
        const Spacer(),
        Text('$filteredCount/$totalCount',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _T.s500)),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active ? _T.or6 : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? _T.or6 : _T.s200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Colors.white : _T.s700)),
          if (!active) ...[
            const SizedBox(width: 3),
            const Icon(LucideIcons.chevronDown, size: 9, color: _T.s400),
          ],
        ]),
      ),
    );
  }
}

class _MobileDataList extends StatelessWidget {
  final _ScrapingScreenState state;
  final List<DatoPatente> patentes;
  final List<DatoPermiso> permisos;
  final List<DatoTransito> transito;
  final List<DatoOrganizacion> orgs;
  final int totalFiltered;
  const _MobileDataList({
    required this.state,
    required this.patentes, required this.permisos,
    required this.transito, required this.orgs,
    required this.totalFiltered,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverList(delegate: SliverChildBuilderDelegate(
        (context, i) {
          switch (state._activeSource) {
            case 'patentes':
              if (i >= patentes.length) return null;
              return _MobilePatenteRow(p: patentes[i]);
            case 'permisos':
              if (i >= permisos.length) return null;
              return _MobilePermisoRow(p: permisos[i]);
            case 'transito':
              if (i >= transito.length) return null;
              return _MobileTransitoRow(t: transito[i]);
            default:
              if (i >= orgs.length) return null;
              return _MobileOrgRow(o: orgs[i]);
          }
        },
        childCount: switch (state._activeSource) {
          'patentes' => patentes.length,
          'permisos' => permisos.length,
          'transito' => transito.length,
          _ => orgs.length,
        },
      )),
      SliverToBoxAdapter(
        child: _MobilePagination(
          currentPage: state._page,
          totalItems: totalFiltered,
          pageSize: _ScrapingScreenState._pageSize,
          onPageChange: state.setPage,
        ),
      ),
    ]);
  }
}

class _MobilePatenteRow extends StatelessWidget {
  final DatoPatente p;
  const _MobilePatenteRow({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s100))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#${p.nDecreto}',
              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: _T.or2, borderRadius: BorderRadius.circular(4)),
            child: const Text('COMER',
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: _T.or7)),
          ),
          const SizedBox(width: 6),
          Text(p.fechaDecreto,
              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: _T.s500)),
          const Spacer(),
          _GeoBadge(confianza: p.confianza),
        ]),
        const SizedBox(height: 5),
        Text(p.razonSocial, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: _T.s900)),
        const SizedBox(height: 5),
        Row(children: [
          Text(p.rut, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _T.s500)),
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: _T.s300, fontSize: 10)),
          const SizedBox(width: 6),
          const Icon(LucideIcons.mapPin, size: 9, color: _T.s400),
          const SizedBox(width: 4),
          Expanded(child: Text(p.direccion, overflow: TextOverflow.ellipsis, maxLines: 1,
              style: const TextStyle(fontSize: 10, color: _T.s700))),
        ]),
      ]),
    );
  }
}

class _MobilePermisoRow extends StatelessWidget {
  final DatoPermiso p;
  const _MobilePermisoRow({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s100))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(p.nPermiso,
              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
          const SizedBox(width: 6),
          Text(p.fecha,
              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: _T.s500)),
          const Spacer(),
          _EstadoBadge(estado: p.estado),
        ]),
        const SizedBox(height: 5),
        Text(p.descripcion, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.s900)),
        const SizedBox(height: 5),
        Text(p.direccion, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 10, color: _T.s700)),
      ]),
    );
  }
}

class _MobileTransitoRow extends StatelessWidget {
  final DatoTransito t;
  const _MobileTransitoRow({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s100))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(t.nDecreto,
              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
          const SizedBox(width: 6),
          Text('${t.fechaInicio} → ${t.fechaFin}',
              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: _T.s500)),
          const Spacer(),
          _EstadoBadge(estado: t.estado),
        ]),
        const SizedBox(height: 5),
        Text(t.motivo, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.s900)),
        const SizedBox(height: 5),
        Text(t.direccion, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 10, color: _T.s700)),
      ]),
    );
  }
}

class _MobileOrgRow extends StatelessWidget {
  final DatoOrganizacion o;
  const _MobileOrgRow({required this.o});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _T.s100))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(o.nPersonalidad,
              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.or7)),
          const SizedBox(width: 6),
          Text(o.tipo,
              style: const TextStyle(fontSize: 9.5, color: _T.s500)),
          const Spacer(),
          Text(o.sector, style: const TextStyle(fontSize: 10, color: _T.s600)),
        ]),
        const SizedBox(height: 5),
        Text(o.nombre, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.s900)),
        const SizedBox(height: 5),
        Text('Representante: ${o.representante}', overflow: TextOverflow.ellipsis, maxLines: 1,
            style: const TextStyle(fontSize: 10, color: _T.s700)),
      ]),
    );
  }
}

class _MobilePagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChange;
  const _MobilePagination({required this.currentPage, required this.totalItems, required this.pageSize, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();
    final lastPage = ((totalItems - 1) ~/ pageSize);
    final page = currentPage.clamp(0, lastPage);
    final start = page * pageSize + 1;
    final end = ((page + 1) * pageSize) > totalItems ? totalItems : ((page + 1) * pageSize);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(children: [
        Expanded(child: Text.rich(TextSpan(children: [
          const TextSpan(text: 'Mostrando ', style: TextStyle(fontSize: 10.5, color: _T.s500)),
          TextSpan(text: '$start–$end', style: const TextStyle(fontSize: 10.5, color: _T.s900, fontWeight: FontWeight.w700)),
          const TextSpan(text: ' de ', style: TextStyle(fontSize: 10.5, color: _T.s500)),
          TextSpan(text: '$totalItems', style: const TextStyle(fontSize: 10.5, color: _T.s900, fontWeight: FontWeight.w700)),
        ]))),
        _MPageBtn(icon: LucideIcons.chevronLeft, enabled: page > 0, onTap: () => onPageChange(page - 1)),
        const SizedBox(width: 4),
        _MPageNumBtn(num: page + 1, active: true, onTap: () {}),
        if (lastPage > page) ...[
          const SizedBox(width: 4),
          _MPageNumBtn(num: page + 2 > lastPage + 1 ? lastPage + 1 : page + 2, active: false,
              onTap: () => onPageChange(page + 1)),
        ],
        if (lastPage > page + 1) ...[
          const SizedBox(width: 4),
          const Text('…', style: TextStyle(color: _T.s400)),
          const SizedBox(width: 4),
          _MPageNumBtn(num: lastPage + 1, active: false, onTap: () => onPageChange(lastPage)),
        ],
        const SizedBox(width: 4),
        _MPageBtn(icon: LucideIcons.chevronRight, enabled: page < lastPage, onTap: () => onPageChange(page + 1)),
      ]),
    );
  }
}

class _MPageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _MPageBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _T.s200),
        ),
        child: Icon(icon, size: 11, color: enabled ? _T.s700 : _T.s400),
      ),
    );
  }
}

class _MPageNumBtn extends StatelessWidget {
  final int num;
  final bool active;
  final VoidCallback onTap;
  const _MPageNumBtn({required this.num, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _T.or6 : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? _T.or6 : _T.s200),
        ),
        child: Text('$num', style: TextStyle(
          fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          color: active ? Colors.white : _T.s700,
        )),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
