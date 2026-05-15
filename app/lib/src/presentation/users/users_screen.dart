import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
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
    final usersAsync = ref.watch(usersProvider);
    final solicitudesAsync = ref.watch(solicitudesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // Toolbar
        _UsersToolbar(onCreatePressed: () => _showCreateDialog(context, ref)),
        const SizedBox(height: 14),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (users) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main table
                Expanded(child: _UsersTable(users: users)),
                const SizedBox(width: 18),
                // Sidebar
                SizedBox(
                  width: 280,
                  child: SingleChildScrollView(
                    child: _UsersSidebar(
                      users: users,
                      solicitudes: solicitudesAsync.valueOrNull ?? [],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        title: 'Crear usuario',
        onSave: (email, nombre, rol) =>
            ref.read(usersProvider.notifier).crear(email, nombre, rol),
      ),
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _UsersToolbar extends StatelessWidget {
  final VoidCallback onCreatePressed;
  const _UsersToolbar({required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 280,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, email o RUT…',
            hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
            prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.stone400),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.stone200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.stone200)),
            filled: true, fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 12.5),
        ),
      ),
      const SizedBox(width: 10),
      const _ToolbarDropdown(label: 'Rol', value: 'Todos'),
      const SizedBox(width: 8),
      const _ToolbarDropdown(label: 'Unidad', value: 'Todas'),
      const SizedBox(width: 8),
      const _ToolbarDropdown(label: 'Estado', value: 'Activos'),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 14),
        label: const Text('Exportar CSV', style: TextStyle(fontSize: 12.5)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.stone700,
          side: const BorderSide(color: AppTheme.stone200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 10),
      ElevatedButton.icon(
        onPressed: onCreatePressed,
        icon: const Icon(Icons.person_add_outlined, size: 14),
        label: const Text('Crear usuario', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.orange600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    ]);
  }
}

class _ToolbarDropdown extends StatelessWidget {
  final String label;
  final String value;
  const _ToolbarDropdown({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.stone200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: const TextStyle(fontSize: 10.5, color: AppTheme.stone400, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 12.5, color: AppTheme.stone800, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.stone500),
      ]),
    );
  }
}

// ── Users Table ───────────────────────────────────────────────────────────────

class _UsersTable extends ConsumerWidget {
  final List<UsuarioItem> users;
  const _UsersTable({required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
          headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.04),
          dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
          columnSpacing: 16,
          horizontalMargin: 14,
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Unidad')),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Última sesión')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: users.map((u) => _buildRow(context, ref, u)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref, UsuarioItem u) {
    final isDirector = u.nivelAcceso == 'director';
    final initials = u.nombre.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
    final avatarColor = isDirector
        ? AppTheme.orange700
        : u.nivelAcceso == 'operativo'
            ? AppTheme.greenSuccess
            : AppTheme.stone500;

    return DataRow(cells: [
      DataCell(Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: avatarColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(initials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: avatarColor)),
        ),
        const SizedBox(width: 10),
        Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
      ])),
      DataCell(Text(u.email, style: const TextStyle(fontSize: 12, color: AppTheme.stone600))),
      DataCell(Text(
        isDirector ? 'Dir. Seguridad Pública' : u.nivelAcceso == 'operativo' ? 'Inspección' : 'Municipal',
        style: const TextStyle(fontSize: 12, color: AppTheme.stone500),
      )),
      DataCell(_RolPill(rol: u.nivelAcceso)),
      DataCell(_EstadoPill(activo: u.activo)),
      DataCell(Text(
        isDirector ? 'hace 1h' : u.activo ? 'hace 3h' : 'hace 2 semanas',
        style: const TextStyle(fontSize: 12, color: AppTheme.stone400),
      )),
      DataCell(isDirector
          ? const Text('—', style: TextStyle(color: AppTheme.stone300))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.stone500),
                tooltip: 'Editar',
                onPressed: () => _showEditDialog(context, ref, u),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.redDanger),
                tooltip: 'Eliminar',
                onPressed: () => _showDeleteDialog(context, ref, u),
              ),
            ])),
    ]);
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        title: 'Editar usuario',
        initialNombre: u.nombre,
        initialRol: u.nivelAcceso,
        emailReadOnly: true,
        initialEmail: u.email,
        onSave: (_, nombre, rol) => ref.read(usersProvider.notifier).editar(u.id, nombre, rol),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${u.nombre}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redDanger, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(usersProvider.notifier).eliminar(u.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
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

// ── Sidebar ───────────────────────────────────────────────────────────────────

const _kBitacoraReciente = [
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Aprobó solicitud de R. Sepúlveda', time: 'hace 2h'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Creó usuario inspector2@lota.cl', time: 'hace 5h'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Rechazó solicitud de C. Morales', time: 'ayer 16:30'),
  (initials: 'DS', color: Color(0xFF9A3412), action: 'Editó rol de J. Pérez a Operativo', time: 'ayer 09:15'),
];

class _UsersSidebar extends ConsumerWidget {
  final List<UsuarioItem> users;
  final List<Solicitud> solicitudes;

  const _UsersSidebar({required this.users, required this.solicitudes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

// ── Tab: Solicitudes (existing logic) ────────────────────────────────────────

class _SolicitudesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitudes de acceso operativo pendientes y procesadas.',
            style: TextStyle(fontSize: 13, color: AppTheme.stone500),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: solicitudesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 40, color: AppTheme.stone400),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar solicitudes\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.stone500, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(solicitudesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (solicitudes) => solicitudes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: AppTheme.stone300),
                          SizedBox(height: 12),
                          Text(
                            'No hay solicitudes registradas.',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.stone400),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.stone200),
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith(
                              (_) => AppTheme.stone50),
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Cargo')),
                            DataColumn(label: Text('Dependencia')),
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: solicitudes
                              .map((s) => _buildRow(context, ref, s))
                              .toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref, Solicitud s) {
    final isPending = s.estado == 'pendiente';

    Color estadoBg;
    Color estadoFg;
    switch (s.estado) {
      case 'pendiente':
        estadoBg = AppTheme.amberWarning.withValues(alpha: 0.12);
        estadoFg = AppTheme.amberWarning;
      case 'aprobada':
        estadoBg = AppTheme.greenSuccess.withValues(alpha: 0.12);
        estadoFg = AppTheme.greenSuccess;
      default:
        estadoBg = AppTheme.redDanger.withValues(alpha: 0.10);
        estadoFg = AppTheme.redDanger;
    }

    return DataRow(
      cells: [
        DataCell(Text(s.nombre,
            style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(s.email,
            style: const TextStyle(fontSize: 12, color: AppTheme.stone600))),
        DataCell(Text(s.cargo, style: const TextStyle(fontSize: 12))),
        DataCell(Text(s.direccion,
            style: const TextStyle(fontSize: 12, color: AppTheme.stone600))),
        DataCell(Text(
          s.fecha.length >= 10 ? s.fecha.substring(0, 10) : s.fecha,
          style: const TextStyle(fontSize: 12, color: AppTheme.stone500),
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: estadoBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              s.estado.toUpperCase(),
              style: TextStyle(
                  color: estadoFg,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          isPending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          color: AppTheme.greenSuccess, size: 22),
                      tooltip: 'Aprobar',
                      onPressed: () =>
                          _resolver(context, ref, s.id, 'aprobar'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppTheme.redDanger, size: 22),
                      tooltip: 'Rechazar',
                      onPressed: () =>
                          _resolver(context, ref, s.id, 'rechazar'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _resolver(
      BuildContext context, WidgetRef ref, String id, String accion) async {
    try {
      await ref.read(solicitudesProvider.notifier).resolver(id, accion);
      if (context.mounted) {
        final msg = accion == 'aprobar'
            ? 'Solicitud aprobada — usuario promovido a Operativo'
            : 'Solicitud rechazada';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor:
                accion == 'aprobar' ? AppTheme.greenSuccess : AppTheme.stone700,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.redDanger,
          ),
        );
      }
    }
  }
}

// ── Form dialog (create / edit) ───────────────────────────────────────────────

class _UserFormDialog extends StatefulWidget {
  final String title;
  final String? initialEmail;
  final String? initialNombre;
  final String? initialRol;
  final bool emailReadOnly;
  final Future<void> Function(String email, String nombre, String rol) onSave;

  const _UserFormDialog({
    required this.title,
    required this.onSave,
    this.initialEmail,
    this.initialNombre,
    this.initialRol,
    this.emailReadOnly = false,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _emailCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  String _rol = 'visitante';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? '';
    _nombreCtrl.text = widget.initialNombre ?? '';
    _rol = widget.initialRol ?? 'visitante';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _emailCtrl,
            readOnly: widget.emailReadOnly,
            decoration: const InputDecoration(
                labelText: 'Email', hintText: 'funcionario@lota.cl'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nombreCtrl,
            decoration:
                const InputDecoration(labelText: 'Nombre completo'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _rol,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: const [
              DropdownMenuItem(value: 'visitante', child: Text('Visitante')),
              DropdownMenuItem(
                  value: 'operativo', child: Text('Operativo')),
              DropdownMenuItem(
                  value: 'director', child: Text('Director')),
            ],
            onChanged: (v) => setState(() => _rol = v ?? _rol),
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white),
          onPressed: _saving
              ? null
              : () async {
                  if (_emailCtrl.text.trim().isEmpty ||
                      _nombreCtrl.text.trim().isEmpty) { return; }
                  setState(() => _saving = true);
                  await widget.onSave(
                      _emailCtrl.text.trim(),
                      _nombreCtrl.text.trim(),
                      _rol);
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _UsersHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider).valueOrNull ?? [];
    final solicitudes = ref.watch(solicitudesProvider).valueOrNull ?? [];
    final activos = users.where((u) => u.activo).length;
    final pendientes = solicitudes.where((s) => s.estado == 'pendiente').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_outlined, size: 11, color: Color(0xFFFED7AA)),
              SizedBox(width: 6),
              Text(
                'ADMINISTRACIÓN · ACCESO AL SISTEMA',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600,
                  letterSpacing: 0.6, color: Color(0xCCFFFFFF)),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Text(
            'Gestión de usuarios',
            style: AppTheme.displayFont(fontSize: 26, color: Colors.white),
          ),
          const SizedBox(height: 5),
          const Text(
            'Roles, credenciales y permisos del personal SIGESPU. Toda alta queda registrada en bitácora · Ley 19.628.',
            style: TextStyle(fontSize: 12.5, color: Color(0xBFFFFFFF), height: 1.5),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _HeaderStat(value: '$activos', label: 'Usuarios activos'),
              const SizedBox(width: 28),
              const _HeaderStat(value: '4', label: 'Roles'),
              const SizedBox(width: 28),
              _HeaderStat(
                value: '$pendientes',
                label: 'Solicitudes pendientes',
                highlight: pendientes > 0,
                badge: pendientes > 0 ? 'nuevas' : null,
              ),
              const SizedBox(width: 28),
              const _HeaderStat(value: '98%', label: 'Sesiones esta semana'),
            ]),
          ),
        ]),
      ]),
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
  Widget build(BuildContext context) => const Center(
    child: Text('Roles y permisos — próximamente', style: TextStyle(color: AppTheme.stone400)),
  );
}

class _BitacoraTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Bitácora — próximamente', style: TextStyle(color: AppTheme.stone400)),
  );
}
