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
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesProvider);
    final pendingCount = solicitudesAsync.valueOrNull
            ?.where((s) => s.estado == 'pendiente')
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.stone900),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      size: 18, color: AppTheme.stone500),
                  onPressed: () {
                    ref.invalidate(usersProvider);
                    ref.invalidate(solicitudesProvider);
                  },
                ),
              ]),
              const SizedBox(height: 4),
              const Text(
                'Gestión de accesos al sistema SIGESPU.',
                style: TextStyle(fontSize: 13, color: AppTheme.stone500),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tab,
                labelColor: AppTheme.orange600,
                unselectedLabelColor: AppTheme.stone500,
                indicatorColor: AppTheme.orange600,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(text: 'Usuarios'),
                  Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Solicitudes'),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.orange100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.orange700),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppTheme.stone200),
        // ── Tab content ───────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _UsuariosTab(),
              _SolicitudesTab(),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Crear usuario',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Expanded(
          child: usersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (users) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.stone200),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(AppTheme.stone50),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Rol')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: users
                          .map((u) => _buildRow(context, ref, u))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref, UsuarioItem u) {
    final isDirector = u.nivelAcceso == 'director';
    final rolColor = isDirector
        ? AppTheme.blue800
        : u.nivelAcceso == 'operativo'
            ? AppTheme.orange600
            : AppTheme.stone500;

    return DataRow(cells: [
      DataCell(Text(u.nombre,
          style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(u.email,
          style: const TextStyle(fontSize: 12, color: AppTheme.stone600))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: rolColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          u.nivelAcceso.toUpperCase(),
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: rolColor),
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: u.activo
              ? AppTheme.greenSuccess.withValues(alpha: 0.1)
              : AppTheme.stone200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          u.activo ? 'Activo' : 'Inactivo',
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: u.activo ? AppTheme.greenSuccess : AppTheme.stone500),
        ),
      )),
      DataCell(isDirector
          ? const Text('—', style: TextStyle(color: AppTheme.stone400))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppTheme.stone500),
                tooltip: 'Editar',
                onPressed: () => _showEditDialog(context, ref, u),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.redDanger),
                tooltip: 'Eliminar',
                onPressed: () => _showDeleteDialog(context, ref, u),
              ),
            ])),
    ]);
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

  void _showEditDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        title: 'Editar usuario',
        initialNombre: u.nombre,
        initialRol: u.nivelAcceso,
        emailReadOnly: true,
        initialEmail: u.email,
        onSave: (_, nombre, rol) =>
            ref.read(usersProvider.notifier).editar(u.id, nombre, rol),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UsuarioItem u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
            '¿Eliminar a ${u.nombre}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.redDanger,
                foregroundColor: Colors.white),
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
