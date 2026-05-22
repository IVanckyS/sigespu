import 'package:flutter/material.dart';
// ignore: unnecessary_import — necesario para Clipboard en algunos targets.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import 'excel_saver.dart';
import 'solicitudes_provider.dart';
import 'users_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header card ────────────────────────────────────────────
        _UsersHeader(),
        // ── Tab bar ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: Column(children: [
            TabBar(
              controller: _tab,
              labelColor: AppTheme.orange600,
              unselectedLabelColor: AppTheme.stone500,
              indicatorColor: AppTheme.orange600,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                const Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.people_outline, size: 14),
                    SizedBox(width: 6),
                    Text('Usuarios'),
                  ]),
                ),
                Tab(
                  child: Consumer(builder: (_, ref, __) {
                    final count = ref.watch(solicitudesProvider).valueOrNull
                        ?.where((s) => s.estado == 'pendiente').length ?? 0;
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.inbox_outlined, size: 14),
                      const SizedBox(width: 6),
                      const Text('Solicitudes'),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.orange100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.orange700)),
                        ),
                      ],
                    ]);
                  }),
                ),
                const Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.key_outlined, size: 14),
                    SizedBox(width: 6),
                    Text('Roles y permisos'),
                  ]),
                ),
                const Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.history, size: 14),
                    SizedBox(width: 6),
                    Text('Bitácora'),
                  ]),
                ),
              ],
            ),
            Container(height: 1, color: AppTheme.stone200),
          ]),
        ),
        // ── Tab content ────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _UsuariosTab(),
              _SolicitudesTab(),
              _RolesTab(),
              _BitacoraTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab: Usuarios (CRUD) ──────────────────────────────────────────────────────

class _UsuariosTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = ref.watch(usersProvider.select((s) => s.hasValue));
    final hasError = ref.watch(usersProvider.select((s) => s.hasError));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final showSidebar = constraints.maxWidth >= 1100;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 24,
            isMobile ? 12 : 16,
            isMobile ? 12 : 24,
            isMobile ? 12 : 20,
          ),
          child: Column(children: [
            _UsersToolbar(
              onCreatePressed: () => _showCreateDialog(context),
              onExportPressed: () =>
                  _exportExcel(context, ref.read(usersFiltradosProvider)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: !hasData
                  ? (hasError
                      ? const Center(child: Text('Error al cargar usuarios'))
                      : const Center(child: CircularProgressIndicator()))
                  : isMobile
                      ? const _MobileUsersCardList()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(child: _UsersTableConsumer()),
                            if (showSidebar) ...[
                              const SizedBox(width: 18),
                              const SizedBox(
                                width: 280,
                                child: SingleChildScrollView(
                                  child: _UsersSidebarConsumer(),
                                ),
                              ),
                            ],
                          ],
                        ),
            ),
          ]),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _UserFormDialog(isEdit: false),
    );
  }

  Future<void> _exportExcel(
      BuildContext context, List<UsuarioItem> users) async {
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuarios para exportar.')),
      );
      return;
    }
    final bytes = usersToExcel(users);
    final filename =
        'usuarios_sigespu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = await platformSaveExcel(bytes, filename);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${users.length} usuarios exportados → $path'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.greenSuccess,
      ),
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _UsersToolbar extends ConsumerStatefulWidget {
  final VoidCallback onCreatePressed;
  final VoidCallback onExportPressed;
  const _UsersToolbar({
    required this.onCreatePressed,
    required this.onExportPressed,
  });

  @override
  ConsumerState<_UsersToolbar> createState() => _UsersToolbarState();
}

class _UsersToolbarState extends ConsumerState<_UsersToolbar> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(usersSearchProvider);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rol = ref.watch(usersRolFilterProvider);
    final unidad = ref.watch(usersUnidadFilterProvider);
    final estado = ref.watch(usersEstadoFilterProvider);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 650) {
        return _buildMobileToolbar(rol, estado);
      }
      return _buildDesktopToolbar(rol, unidad, estado);
    });
  }

  Widget _buildMobileToolbar(String rol, String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 36,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) =>
                ref.read(usersSearchProvider.notifier).state = v,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Nombre, email, RUT, cargo…',
              hintStyle:
                  const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
              prefixIcon: const Icon(Icons.search,
                  size: 16, color: AppTheme.stone400),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.stone200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.stone200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppTheme.orange600, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _DropdownPill(
              value: rol,
              width: double.infinity,
              items: const [
                ('all', 'Todos los roles'),
                ('director', 'Director'),
                ('operativo', 'Operativo'),
                ('visitante', 'Visitante'),
              ],
              onChanged: (v) =>
                  ref.read(usersRolFilterProvider.notifier).state = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DropdownPill(
              value: estado,
              width: double.infinity,
              items: const [
                ('activos', 'Activos'),
                ('inactivos', 'Inactivos'),
                ('all', 'Todos'),
              ],
              onChanged: (v) =>
                  ref.read(usersEstadoFilterProvider.notifier).state = v,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: widget.onCreatePressed,
            icon: const Icon(Icons.person_add_outlined, size: 14),
            label: const Text('Crear',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildDesktopToolbar(String rol, String unidad, String estado) {
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
          _Field(
            label: 'Buscar',
            child: SizedBox(
              width: 260,
              height: 36,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(usersSearchProvider.notifier).state = v,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Nombre, email, RUT, cargo…',
                  hintStyle: const TextStyle(
                      fontSize: 12.5, color: AppTheme.stone400),
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
                    borderSide: const BorderSide(
                        color: AppTheme.orange600, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          _Field(
            label: 'Rol',
            child: _DropdownPill(
              value: rol,
              width: 160,
              items: const [
                ('all', 'Todos los roles'),
                ('director', 'Director'),
                ('operativo', 'Operativo'),
                ('visitante', 'Visitante'),
              ],
              onChanged: (v) =>
                  ref.read(usersRolFilterProvider.notifier).state = v,
            ),
          ),
          _Field(
            label: 'Unidad',
            child: _DropdownPill(
              value: unidad,
              width: 180,
              items: [
                const ('all', 'Todas las unidades'),
                ...kUnidadesDisponibles.map((u) => (u, u)),
              ],
              onChanged: (v) =>
                  ref.read(usersUnidadFilterProvider.notifier).state = v,
            ),
          ),
          _Field(
            label: 'Estado',
            child: _DropdownPill(
              value: estado,
              width: 130,
              items: const [
                ('activos', 'Activos'),
                ('inactivos', 'Inactivos'),
                ('all', 'Todos'),
              ],
              onChanged: (v) =>
                  ref.read(usersEstadoFilterProvider.notifier).state = v,
            ),
          ),
          _Field(
            label: 'Acciones',
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              OutlinedButton.icon(
                onPressed: widget.onExportPressed,
                icon: const Icon(Icons.table_chart_outlined, size: 14),
                label: const Text(
                  'Exportar Excel',
                  style: TextStyle(fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.stone700,
                  side: const BorderSide(color: AppTheme.stone200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: widget.onCreatePressed,
                icon: const Icon(Icons.person_add_outlined, size: 14),
                label: const Text(
                  'Crear usuario',
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

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

class _DropdownPill extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  final double width;

  const _DropdownPill({
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
          items: items.map((it) {
            final (v, l) = it;
            return DropdownMenuItem(
              value: v,
              child: Text(l, overflow: TextOverflow.ellipsis),
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

// ── Users Table ───────────────────────────────────────────────────────────────

class _UsersTableConsumer extends ConsumerWidget {
  const _UsersTableConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersFiltradosProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stone200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.stone50,
            border: Border(bottom: BorderSide(color: AppTheme.stone200)),
          ),
          child: const Row(children: [
            _Hcell('Nombre', flex: 4),
            _Hcell('Email', flex: 4),
            _Hcell('Unidad', flex: 3),
            _Hcell('Rol', flex: 2),
            _Hcell('Estado', flex: 2),
            _Hcell('Última sesión', flex: 2),
            _Hcell('Acciones', flex: 2),
          ]),
        ),
        // Body
        if (users.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Sin usuarios con los filtros actuales',
                style: TextStyle(color: AppTheme.stone500, fontSize: 13),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctx, i) {
                final u = users[i];
                return RepaintBoundary(
                  key: ValueKey('userrow_${u.id}'),
                  child: _UserRow(
                    user: u,
                    onEdit: () => _showEditDialog(context, ref, u),
                    onDelete: () => _showDeleteDialog(context, ref, u),
                    onToggleActivo: () =>
                        _showToggleDialog(context, ref, u),
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserFormDialog(isEdit: true, existing: u),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.redDanger, size: 22),
          SizedBox(width: 8),
          Text(
            'Eliminar usuario',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Eliminar a ${u.nombre} (${u.email})?',
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.stone700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.delete_forever_outlined,
                      size: 14, color: AppTheme.redDanger),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer. El usuario pierde '
                      'acceso de inmediato y queda registrado en bitácora.',
                      style: TextStyle(
                          fontSize: 11.5, color: AppTheme.redDanger),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete_outline, size: 14),
            label: const Text('Eliminar'),
            onPressed: () {
              ref.read(usersProvider.notifier).eliminar(u.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuario ${u.nombre} eliminado.'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showToggleDialog(
    BuildContext context,
    WidgetRef ref,
    UsuarioItem u,
  ) {
    final desactivar = u.activo;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(
            desactivar ? Icons.block_outlined : Icons.check_circle_outline,
            color: desactivar ? AppTheme.amberWarning : AppTheme.greenSuccess,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            desactivar ? 'Desactivar usuario' : 'Reactivar usuario',
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desactivar
                  ? '${u.nombre} no podrá iniciar sesión hasta que '
                      'lo reactives.'
                  : '${u.nombre} podrá volver a iniciar sesión con '
                      'sus credenciales.',
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.stone700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: desactivar
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: desactivar
                      ? const Color(0xFFFCD34D)
                      : const Color(0xFF86EFAC),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: desactivar
                        ? AppTheme.amberWarning
                        : AppTheme.greenSuccess,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      desactivar
                          ? 'Los datos del usuario y su historial se '
                              'conservan. La acción se registra en bitácora.'
                          : 'Las sesiones previas siguen revocadas. El '
                              'usuario debe iniciar sesión otra vez.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: desactivar
                            ? AppTheme.amberWarning
                            : AppTheme.greenSuccess,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: desactivar
                  ? AppTheme.amberWarning
                  : AppTheme.greenSuccess,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ref.read(usersProvider.notifier).toggleActivo(u.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    desactivar
                        ? '${u.nombre} desactivado.'
                        : '${u.nombre} reactivado.',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(desactivar ? 'Desactivar' : 'Reactivar'),
          ),
        ],
      ),
    );
  }
}

// ── Rol Pill & Estado Pill ────────────────────────────────────────────────────

class _RolPill extends StatelessWidget {
  final String rol;
  const _RolPill({required this.rol});

  @override
  Widget build(BuildContext context) {
    final (fg, bg, label) = switch (rol) {
      'director'  => (const Color(0xFF292524), const Color(0xFFE7E5E4), 'Director'),
      'operativo' => (AppTheme.orange700, AppTheme.orange100, 'Operativo'),
      _           => (AppTheme.stone500, AppTheme.stone100, 'Visitante'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.04)),
      ]),
    );
  }
}

class _EstadoPill extends StatelessWidget {
  final bool activo;
  const _EstadoPill({required this.activo});

  @override
  Widget build(BuildContext context) {
    final fg = activo ? AppTheme.greenSuccess : AppTheme.stone500;
    final bg = activo ? const Color(0xFFDCFCE7) : AppTheme.stone100;
    final label = activo ? 'Activo' : 'Inactivo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

// ── Cells & rows de la tabla ──────────────────────────────────────────────────

class _Hcell extends StatelessWidget {
  final String label;
  final int flex;
  const _Hcell(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          label,
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
  }
}

class _UserRow extends StatefulWidget {
  final UsuarioItem user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActivo;

  const _UserRow({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActivo,
  });

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hover = false;

  String _fmtUltimaSesion(DateTime? d) {
    if (d == null) return 'Sin sesiones aún';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'recién';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final isDirector = u.nivelAcceso == 'director';
    final initials = u.nombre
        .split(RegExp(r'\s+'))
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();
    final avatarColor = isDirector
        ? AppTheme.orange700
        : u.nivelAcceso == 'operativo'
            ? AppTheme.greenSuccess
            : AppTheme.stone500;

    final bg = u.esActual
        ? AppTheme.orange50
        : _hover
            ? const Color(0xFFFAFAF9)
            : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            left: BorderSide(
              color: u.esActual ? AppTheme.orange600 : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(color: AppTheme.stone100),
          ),
        ),
        child: Row(children: [
          // Nombre + avatar + tag "Tú"
          Expanded(
            flex: 4,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: avatarColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(
                            u.nombre,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.stone800,
                            ),
                          ),
                        ),
                        if (u.esActual) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.orange600,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'TÚ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ]),
                      if (u.cargo != null && u.cargo!.isNotEmpty)
                        Text(
                          u.cargo!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.stone500),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          // Email
          Expanded(
            flex: 4,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                u.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.stone600),
              ),
            ),
          ),
          // Unidad
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                u.unidad,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.stone500),
              ),
            ),
          ),
          // Rol
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RolPill(rol: u.nivelAcceso),
              ),
            ),
          ),
          // Estado
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _EstadoPill(activo: u.activo),
              ),
            ),
          ),
          // Última sesión
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                _fmtUltimaSesion(u.ultimaSesion),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.stone400),
              ),
            ),
          ),
          // Acciones
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: isDirector
                  ? const Text(
                      '—',
                      style: TextStyle(color: AppTheme.stone300),
                    )
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      _ActionBtn(
                        icon: Icons.edit_outlined,
                        color: AppTheme.stone500,
                        tooltip: 'Editar',
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(width: 2),
                      _ActionBtn(
                        icon: u.activo
                            ? Icons.toggle_on
                            : Icons.toggle_off_outlined,
                        color: u.activo
                            ? AppTheme.greenSuccess
                            : AppTheme.stone400,
                        tooltip: u.activo ? 'Desactivar' : 'Activar',
                        onTap: widget.onToggleActivo,
                      ),
                      const SizedBox(width: 2),
                      _ActionBtn(
                        icon: Icons.delete_outline,
                        color: u.esActual
                            ? AppTheme.stone300
                            : AppTheme.redDanger,
                        tooltip:
                            u.esActual ? 'No puedes borrarte' : 'Eliminar',
                        onTap: u.esActual ? null : widget.onDelete,
                      ),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: enabled ? color : color.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

const _kBitacoraReciente = [
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Aprobó solicitud de R. Sepúlveda', time: 'hace 2h'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Creó usuario inspector2@lota.cl', time: 'hace 5h'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Rechazó solicitud de C. Morales', time: 'ayer 16:30'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Editó rol de J. Pérez a Operativo', time: 'ayer 09:15'),
];

const _kBitacoraFull = [
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Aprobó solicitud de R. Sepúlveda → Operativo', time: '2026-05-14 · 10:22'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Creó usuario inspector2@lota.cl (Visitante)', time: '2026-05-14 · 09:18'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Rechazó solicitud de C. Morales', time: '2026-05-13 · 16:30'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Editó rol de J. Pérez: Visitante → Operativo', time: '2026-05-13 · 09:15'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Eliminó usuario temporal@lota.cl', time: '2026-05-12 · 14:44'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Creó usuario msilva@lota.cl (Visitante)', time: '2026-05-12 · 11:02'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Aprobó solicitud de A. Fuentes → Operativo', time: '2026-05-11 · 17:33'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Suspendió usuario ex-inspector@lota.cl', time: '2026-05-10 · 08:50'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Creó usuario director@lota.cl (Director)', time: '2026-04-30 · 12:00'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Sistema inicializado — migración 002_seed', time: '2026-04-30 · 11:55'),
];

class _UsersSidebarConsumer extends ConsumerWidget {
  const _UsersSidebarConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider).valueOrNull ?? const <UsuarioItem>[];
    final solicitudes =
        ref.watch(solicitudesProvider).valueOrNull ?? const <Solicitud>[];
    final directors = users.where((u) => u.nivelAcceso == 'director').length;
    final operativos = users.where((u) => u.nivelAcceso == 'operativo').length;
    final visitantes = users.where((u) => u.nivelAcceso == 'visitante').length;
    final total = users.isEmpty ? 1 : users.length;
    final pending = solicitudes.where((s) => s.estado == 'pendiente').take(3).toList();

    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Distribución de roles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone700)),
          const SizedBox(height: 12),
          _RolBar(label: 'Director', count: directors, total: total, color: const Color(0xFF292524)),
          const SizedBox(height: 8),
          _RolBar(label: 'Operativo', count: operativos, total: total, color: AppTheme.orange600),
          const SizedBox(height: 8),
          _RolBar(label: 'Visitante', count: visitantes, total: total, color: AppTheme.stone400),
        ]),
      ),
      const SizedBox(height: 14),
      if (pending.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.stone200),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Solicitudes pendientes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: AppTheme.orange100, borderRadius: BorderRadius.circular(999)),
                child: Text('${pending.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.orange700)),
              ),
            ]),
            const SizedBox(height: 10),
            ...pending.map((s) => _SolicitudMiniCard(s: s)),
          ]),
        ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Actividad reciente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone700)),
          const SizedBox(height: 10),
          ..._kBitacoraReciente.map((e) => _BitacoraEntry(entry: e)),
        ]),
      ),
    ]);
  }
}

class _RolBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _RolBar({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
        const Spacer(),
        Text('$count', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.stone700)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          backgroundColor: AppTheme.stone100,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}

class _SolicitudMiniCard extends ConsumerWidget {
  final Solicitud s;
  const _SolicitudMiniCard({required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = s.nombre.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.amberWarning)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.nombre, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          Text(s.cargo, style: const TextStyle(fontSize: 11, color: AppTheme.stone500), overflow: TextOverflow.ellipsis),
        ])),
        Column(children: [
          GestureDetector(
            onTap: () => ref.read(solicitudesProvider.notifier).resolver(s.id, 'aprobar'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.check, size: 12, color: AppTheme.greenSuccess),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => ref.read(solicitudesProvider.notifier).resolver(s.id, 'rechazar'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.close, size: 12, color: AppTheme.redDanger),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _BitacoraEntry extends StatelessWidget {
  final ({String initials, Color color, String action, String time}) entry;
  const _BitacoraEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(color: entry.color.withValues(alpha: 0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(entry.initials, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: entry.color)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.action, style: const TextStyle(fontSize: 11.5, color: AppTheme.stone700, height: 1.3)),
          const SizedBox(height: 2),
          Text(entry.time, style: const TextStyle(fontSize: 11, color: AppTheme.stone400)),
        ])),
      ]),
    );
  }
}

// ── Mobile card list (usuarios) ──────────────────────────────────────────────

class _MobileUsersCardList extends ConsumerWidget {
  const _MobileUsersCardList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersFiltradosProvider);
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'Sin usuarios con los filtros actuales',
          style: TextStyle(color: AppTheme.stone500, fontSize: 13),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final u = users[i];
        return _MobileUserCard(
          user: u,
          onEdit: () => _showEditDialog(context, ref, u),
          onDelete: () => _showDeleteDialog(context, ref, u),
          onToggleActivo: () => _showToggleDialog(context, ref, u),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserFormDialog(isEdit: true, existing: u),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.redDanger, size: 22),
          SizedBox(width: 8),
          Text('Eliminar usuario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('¿Eliminar a ${u.nombre} (${u.email})?',
              style: const TextStyle(fontSize: 13, color: AppTheme.stone700)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.delete_forever_outlined, size: 14, color: AppTheme.redDanger),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta acción no se puede deshacer. El usuario pierde acceso de inmediato y queda registrado en bitácora.',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.redDanger),
                ),
              ),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete_outline, size: 14),
            label: const Text('Eliminar'),
            onPressed: () {
              ref.read(usersProvider.notifier).eliminar(u.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario ${u.nombre} eliminado.'), duration: const Duration(seconds: 3)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showToggleDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    final desactivar = u.activo;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Icon(
            desactivar ? Icons.block_outlined : Icons.check_circle_outline,
            color: desactivar ? AppTheme.amberWarning : AppTheme.greenSuccess,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(desactivar ? 'Desactivar usuario' : 'Reactivar usuario',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            desactivar
                ? '${u.nombre} no podrá iniciar sesión hasta que lo reactives.'
                : '${u.nombre} podrá volver a iniciar sesión con sus credenciales.',
            style: const TextStyle(fontSize: 13, color: AppTheme.stone700),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: desactivar ? AppTheme.amberWarning : AppTheme.greenSuccess,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ref.read(usersProvider.notifier).toggleActivo(u.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(desactivar ? '${u.nombre} desactivado.' : '${u.nombre} reactivado.'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(desactivar ? 'Desactivar' : 'Reactivar'),
          ),
        ],
      ),
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  final UsuarioItem user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActivo;

  const _MobileUserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActivo,
  });

  @override
  Widget build(BuildContext context) {
    final u = user;
    final isDirector = u.nivelAcceso == 'director';
    final initials = u.nombre
        .split(RegExp(r'\s+'))
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();
    final avatarColor = isDirector
        ? AppTheme.orange700
        : u.nivelAcceso == 'operativo'
            ? AppTheme.greenSuccess
            : AppTheme.stone500;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: u.esActual ? AppTheme.orange50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: u.esActual ? AppTheme.orange100 : AppTheme.stone200,
          width: u.esActual ? 1.5 : 1,
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(initials,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: avatarColor)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(u.nombre,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stone900),
                    overflow: TextOverflow.ellipsis),
              ),
              if (u.esActual) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: AppTheme.orange600,
                      borderRadius: BorderRadius.circular(999)),
                  child: const Text('TÚ',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text(u.email,
                style: const TextStyle(fontSize: 12, color: AppTheme.stone500),
                overflow: TextOverflow.ellipsis),
            if (u.cargo != null && u.cargo!.isNotEmpty)
              Text(u.cargo!,
                  style:
                      const TextStyle(fontSize: 11.5, color: AppTheme.stone400),
                  overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              _RolPill(rol: u.nivelAcceso),
              const SizedBox(width: 6),
              _EstadoPill(activo: u.activo),
              const Spacer(),
              if (!isDirector) ...[
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: AppTheme.stone500,
                  tooltip: 'Editar',
                  onTap: onEdit,
                ),
                const SizedBox(width: 2),
                _ActionBtn(
                  icon: u.activo ? Icons.toggle_on : Icons.toggle_off_outlined,
                  color: u.activo ? AppTheme.greenSuccess : AppTheme.stone400,
                  tooltip: u.activo ? 'Desactivar' : 'Activar',
                  onTap: onToggleActivo,
                ),
                const SizedBox(width: 2),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: u.esActual ? AppTheme.stone300 : AppTheme.redDanger,
                  tooltip: u.esActual ? 'No puedes borrarte' : 'Eliminar',
                  onTap: u.esActual ? null : onDelete,
                ),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ── Tab: Solicitudes (card layout) ───────────────────────────────────────────

class _SolicitudesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Solicitudes de acceso operativo — pendientes y procesadas.',
          style: TextStyle(fontSize: 13, color: AppTheme.stone500),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: solicitudesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (solicitudes) => solicitudes.isEmpty
                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_outlined, size: 48, color: AppTheme.stone300),
                    SizedBox(height: 12),
                    Text('No hay solicitudes.', style: TextStyle(fontSize: 14, color: AppTheme.stone400)),
                  ]))
                : ListView.separated(
                    itemCount: solicitudes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _SolicitudCard(
                      s: solicitudes[i],
                      onAprobar: () => _resolver(context, ref, solicitudes[i].id, 'aprobar'),
                      onRechazar: () => _resolver(context, ref, solicitudes[i].id, 'rechazar'),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }

  Future<void> _resolver(BuildContext context, WidgetRef ref, String id, String accion) async {
    try {
      await ref.read(solicitudesProvider.notifier).resolver(id, accion);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(accion == 'aprobar'
              ? 'Solicitud aprobada — usuario promovido a Operativo'
              : 'Solicitud rechazada'),
          backgroundColor: accion == 'aprobar' ? AppTheme.greenSuccess : AppTheme.stone700,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.redDanger,
        ));
      }
    }
  }
}

class _SolicitudCard extends StatelessWidget {
  final Solicitud s;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _SolicitudCard({required this.s, required this.onAprobar, required this.onRechazar});

  @override
  Widget build(BuildContext context) {
    final isPending = s.estado == 'pendiente';
    final initials = s.nombre.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();

    final (stateFg, stateBg, stateLabel) = switch (s.estado) {
      'aprobada'  => (AppTheme.greenSuccess, const Color(0xFFDCFCE7), 'Aprobada'),
      'rechazada' => (AppTheme.redDanger, const Color(0xFFFEE2E2), 'Rechazada'),
      _           => (AppTheme.amberWarning, const Color(0xFFFEF3C7), 'Pendiente'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFBF5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPending ? AppTheme.orange100 : AppTheme.stone200),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isPending ? const Color(0xFFFEF3C7) : AppTheme.stone100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(initials, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isPending ? AppTheme.amberWarning : AppTheme.stone500,
          )),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(s.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(stateLabel,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: stateFg)),
            ),
          ]),
          const SizedBox(height: 3),
          Text('${s.cargo} · ${s.direccion}',
            style: const TextStyle(fontSize: 12.5, color: AppTheme.stone500)),
          const SizedBox(height: 2),
          Text(s.email, style: const TextStyle(fontSize: 12, color: AppTheme.stone400)),
          const SizedBox(height: 2),
          Text(
            s.fecha.length >= 10 ? s.fecha.substring(0, 10) : s.fecha,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.stone400),
          ),
        ])),
        if (isPending) ...[
          const SizedBox(width: 12),
          Column(children: [
            ElevatedButton.icon(
              onPressed: onAprobar,
              icon: const Icon(Icons.check, size: 13),
              label: const Text('Aprobar', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenSuccess,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onRechazar,
              icon: const Icon(Icons.close, size: 13),
              label: const Text('Rechazar', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.redDanger,
                side: const BorderSide(color: AppTheme.redDanger),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ── Form dialog (crear / editar) ─────────────────────────────────────────────

class _UserFormDialog extends ConsumerStatefulWidget {
  final bool isEdit;
  final UsuarioItem? existing;

  const _UserFormDialog({required this.isEdit, this.existing});

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _emailCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();

  String _rol = 'operativo';
  // Siempre se sobreescribe en initState; el valor inicial no importa
  // mientras sea un elemento válido de kUnidadesDisponibles.
  late String _unidad;
  bool _showPassword = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    if (u != null) {
      _emailCtrl.text = u.email;
      _nombreCtrl.text = u.nombre;
      _cargoCtrl.text = u.cargo ?? '';
      _rutCtrl.text = u.rut ?? '';
      _rol = u.nivelAcceso;
      _unidad = kUnidadesDisponibles.contains(u.unidad)
          ? u.unidad
          : kUnidadesDisponibles.first;
    } else {
      // En "crear" arrancamos con la primera unidad de la lista.
      _unidad = kUnidadesDisponibles.first;
      _passwordCtrl.text = generarPasswordSegura();
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    _cargoCtrl.dispose();
    _rutCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final email = _emailCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();

    if (nombre.isEmpty) {
      setState(() {
        _error = 'El nombre es obligatorio.';
        _saving = false;
      });
      return;
    }

    if (widget.isEdit) {
      final pw = _passwordCtrl.text;
      if (pw.isNotEmpty && pw.length < 8) {
        setState(() {
          _error = 'La nueva contraseña debe tener al menos 8 caracteres.';
          _saving = false;
        });
        return;
      }
      await ref.read(usersProvider.notifier).editar(
            widget.existing!.id,
            nombre: nombre,
            rol: _rol,
            unidad: _unidad,
            cargo: _cargoCtrl.text.trim().isEmpty
                ? null
                : _cargoCtrl.text.trim(),
            rut: _rutCtrl.text.trim().isEmpty ? null : _rutCtrl.text.trim(),
            nuevaPassword: pw.isEmpty ? null : pw,
          );
      if (mounted) Navigator.pop(context);
      return;
    }

    final res = await ref.read(usersProvider.notifier).crear(
          email: email,
          nombre: nombre,
          password: _passwordCtrl.text,
          rol: _rol,
          unidad: _unidad,
          cargo: _cargoCtrl.text.trim().isEmpty
              ? null
              : _cargoCtrl.text.trim(),
          rut: _rutCtrl.text.trim().isEmpty ? null : _rutCtrl.text.trim(),
        );

    if (!res.ok) {
      setState(() {
        _error = res.error;
        _saving = false;
      });
      return;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario $email creado correctamente.'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(children: [
        Icon(
          widget.isEdit ? Icons.edit_outlined : Icons.person_add_outlined,
          size: 18,
          color: AppTheme.orange600,
        ),
        const SizedBox(width: 8),
        Text(
          widget.isEdit ? 'Editar usuario' : 'Crear usuario',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ]),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width < 500
            ? MediaQuery.sizeOf(context).width - 80
            : 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              TextField(
                controller: _emailCtrl,
                readOnly: widget.isEdit,
                decoration: InputDecoration(
                  labelText: 'Email institucional *',
                  hintText: 'funcionario@lota.cl',
                  helperText: widget.isEdit
                      ? 'El email no se puede cambiar'
                      : 'Solo @lota.cl o @munilota.cl',
                  prefixIcon: const Icon(Icons.alternate_email, size: 16),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Nombre
              TextField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: Icon(Icons.person_outline, size: 16),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Contraseña: obligatoria en crear, opcional en editar
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: widget.isEdit
                      ? 'Nueva contraseña (opcional)'
                      : 'Contraseña inicial *',
                  helperText: widget.isEdit
                      ? 'Deja vacío para no cambiar la contraseña actual.'
                      : 'Mínimo 8 caracteres. Comparte esta clave al usuario.',
                  prefixIcon: const Icon(Icons.lock_outline, size: 16),
                  isDense: true,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        tooltip: _showPassword ? 'Ocultar' : 'Ver',
                        splashRadius: 16,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () => setState(
                            () => _passwordCtrl.text = generarPasswordSegura()),
                        tooltip: 'Generar nueva',
                        splashRadius: 16,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: _passwordCtrl.text));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contraseña copiada'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copiar',
                        splashRadius: 16,
                      ),
                    ],
                  ),
                ),
                style: const TextStyle(
                    fontSize: 13,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
              const SizedBox(height: 12),

              // Rol + Unidad (responsive: stack on narrow)
              LayoutBuilder(builder: (context, c) {
                final narrow = c.maxWidth < 380;
                final rolField = DropdownButtonFormField<String>(
                  initialValue: _rol,
                  decoration: const InputDecoration(
                    labelText: 'Rol *',
                    prefixIcon: Icon(Icons.key_outlined, size: 16),
                    isDense: true,
                  ),
                  isExpanded: true,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.stone800),
                  items: const [
                    DropdownMenuItem(
                        value: 'visitante', child: Text('Visitante')),
                    DropdownMenuItem(
                        value: 'operativo', child: Text('Operativo')),
                    DropdownMenuItem(
                        value: 'director', child: Text('Director')),
                  ],
                  onChanged: (v) => setState(() => _rol = v ?? _rol),
                );
                final unidadField = DropdownButtonFormField<String>(
                  initialValue: _unidad,
                  decoration: const InputDecoration(
                    labelText: 'Unidad *',
                    prefixIcon: Icon(Icons.business_outlined, size: 16),
                    isDense: true,
                  ),
                  isExpanded: true,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.stone800),
                  items: kUnidadesDisponibles
                      .map((u) =>
                          DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unidad = v ?? _unidad),
                );
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      rolField,
                      const SizedBox(height: 12),
                      unidadField,
                    ],
                  );
                }
                return Row(children: [
                  Expanded(child: rolField),
                  const SizedBox(width: 10),
                  Expanded(child: unidadField),
                ]);
              }),
              const SizedBox(height: 12),

              // Cargo + RUT (responsive: stack on narrow)
              LayoutBuilder(builder: (context, c) {
                final narrow = c.maxWidth < 380;
                final cargoField = TextField(
                  controller: _cargoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    hintText: 'Inspector, Coord., etc.',
                    prefixIcon: Icon(Icons.badge_outlined, size: 16),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                );
                final rutField = TextField(
                  controller: _rutCtrl,
                  decoration: const InputDecoration(
                    labelText: 'RUT',
                    hintText: '12.345.678-9',
                    prefixIcon: Icon(Icons.fingerprint_outlined, size: 16),
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()]),
                );
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cargoField,
                      const SizedBox(height: 12),
                      rutField,
                    ],
                  );
                }
                return Row(children: [
                  Expanded(child: cargoField),
                  const SizedBox(width: 10),
                  Expanded(child: rutField),
                ]);
              }),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppTheme.redDanger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.redDanger),
                      ),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.orange600,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _saving ? null : _onSave,
          icon: _saving
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Icon(
                  widget.isEdit ? Icons.save_outlined : Icons.check,
                  size: 14,
                ),
          label: Text(widget.isEdit ? 'Guardar cambios' : 'Crear usuario'),
        ),
      ],
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _UsersHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos `select` para que el header solo se reconstruya cuando cambian
    // los conteos, no en cada keystroke de búsqueda o filtro.
    final counts = ref.watch(
      usersProvider.select((async) {
        final list = async.valueOrNull ?? const <UsuarioItem>[];
        final activos = list.where((u) => u.activo).length;
        return (
          activos: activos,
          total: list.length,
          roles: list.map((u) => u.nivelAcceso).toSet().length,
        );
      }),
    );
    final pendientes = ref.watch(
      solicitudesProvider.select(
        (async) => (async.valueOrNull ?? const [])
            .where((s) => s.estado == 'pendiente')
            .length,
      ),
    );
    final activos = counts.activos;
    final total = counts.total;
    final rolesActivos = counts.roles;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C1917), Color(0xFF44403C), Color(0xFF9A3412)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(children: [
        const Positioned(
          right: 0, top: 0, bottom: 0,
          child: Center(
            child: Opacity(
              opacity: 0.13,
              child: Icon(Icons.shield_outlined, size: 110, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 24, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_outlined, size: 11, color: Color(0xFFFED7AA)),
              SizedBox(width: 6),
              Flexible(child: Text(
                'ADMINISTRACIÓN · ACCESO AL SISTEMA',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600,
                  letterSpacing: 0.6, color: Color(0xCCFFFFFF)),
              )),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestión de usuarios',
            style: AppTheme.displayFont(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 3),
          const Text(
            'Roles, credenciales y permisos del personal SIGESPU.',
            style: TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), height: 1.4),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _HeaderStat(value: '$activos', label: 'Usuarios activos'),
              const SizedBox(width: 28),
              _HeaderStat(value: '$total', label: 'Total registrados'),
              const SizedBox(width: 28),
              _HeaderStat(value: '$rolesActivos', label: 'Roles en uso'),
              const SizedBox(width: 28),
              _HeaderStat(
                value: '$pendientes',
                label: 'Solicitudes pendientes',
                highlight: pendientes > 0,
                badge: pendientes > 0 ? 'nuevas' : null,
              ),
            ]),
          ),
        ]),
        ),
      ]),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;
  final String? badge;

  const _HeaderStat({
    required this.value,
    required this.label,
    this.highlight = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(
          value,
          style: AppTheme.displayFont(
            fontSize: 28,
            color: highlight ? const Color(0xFFFED7AA) : Colors.white,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.orange600,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(badge!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF), letterSpacing: 0.03)),
    ]);
  }
}

// ── Tab stubs ─────────────────────────────────────────────────────────────────

class _RolesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Capacidades por rol en el sistema SIGESPU.',
          style: TextStyle(fontSize: 13, color: AppTheme.stone500)),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 500;
          if (wide) {
            return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _RolCard(rol: 'Visitante', color: AppTheme.stone500, bg: AppTheme.stone100)),
              SizedBox(width: 14),
              Expanded(child: _RolCard(rol: 'Operativo', color: AppTheme.orange700, bg: AppTheme.orange100)),
              SizedBox(width: 14),
              Expanded(child: _RolCard(rol: 'Director', color: Color(0xFF292524), bg: Color(0xFFE7E5E4))),
            ]);
          }
          return const Column(children: [
            _RolCard(rol: 'Visitante', color: AppTheme.stone500, bg: AppTheme.stone100),
            SizedBox(height: 14),
            _RolCard(rol: 'Operativo', color: AppTheme.orange700, bg: AppTheme.orange100),
            SizedBox(height: 14),
            _RolCard(rol: 'Director', color: Color(0xFF292524), bg: Color(0xFFE7E5E4)),
          ]);
        }),
      ]),
    );
  }
}

const _kPermisos = [
  (label: 'Ver mapa y capas',          visitante: true,  operativo: true,  director: true),
  (label: 'Exportar PDF',              visitante: true,  operativo: true,  director: true),
  (label: 'Crear reportes',            visitante: false, operativo: true,  director: true),
  (label: 'Agregar elementos al mapa', visitante: false, operativo: true,  director: true),
  (label: 'Dibujar zonas de peligro',  visitante: false, operativo: true,  director: true),
  (label: 'Verificar en terreno',      visitante: false, operativo: true,  director: true),
  (label: 'Aprobar solicitudes',       visitante: false, operativo: false, director: true),
  (label: 'Gestionar usuarios',        visitante: false, operativo: false, director: true),
  (label: 'Ver bitácora completa',     visitante: false, operativo: false, director: true),
];

class _RolCard extends StatelessWidget {
  final String rol;
  final Color color;
  final Color bg;
  const _RolCard({required this.rol, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    final perms = _kPermisos.map((p) => switch (rol) {
      'Operativo' => p.operativo,
      'Director'  => p.director,
      _           => p.visitante,
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stone200),
      ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(rol.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.04)),
            ]),
          ),
          const SizedBox(height: 16),
          ..._kPermisos.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(
                perms[e.key] ? Icons.check_circle : Icons.cancel_outlined,
                size: 16,
                color: perms[e.key] ? AppTheme.greenSuccess : AppTheme.stone300,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value.label,
                style: TextStyle(fontSize: 12.5, color: perms[e.key] ? AppTheme.stone700 : AppTheme.stone400),
              )),
            ]),
          )),
        ]),
    );
  }
}

class _BitacoraTab extends StatelessWidget {
  // TODO(sprint-5): conectar a GET /audit-log
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Flexible(child: Text('Registro de acciones administrativas.',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppTheme.stone500))),
          SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.stone100,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.info_outline, size: 13, color: AppTheme.stone400),
                SizedBox(width: 6),
                Text('Datos de demo · Ley 21.719',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.stone500)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: ListView.separated(
              itemCount: _kBitacoraFull.length,
              separatorBuilder: (_, __) => Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 1,
                color: AppTheme.stone100,
              ),
              itemBuilder: (_, i) {
                final e = _kBitacoraFull[i];
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: e.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(e.initials,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: e.color)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.action,
                      style: const TextStyle(fontSize: 13, color: AppTheme.stone800, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(e.time,
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.stone400)),
                  ])),
                ]);
              },
            ),
          ),
        ),
      ]),
    );
  }
}
