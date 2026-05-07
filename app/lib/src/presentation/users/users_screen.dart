import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import 'solicitudes_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Gestión de Usuarios',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.stone900),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: AppTheme.stone500),
                tooltip: 'Actualizar',
                onPressed: () => ref.invalidate(solicitudesProvider),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Solicitudes de acceso operativo pendientes y procesadas.',
            style: TextStyle(fontSize: 13, color: AppTheme.stone500),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: solicitudesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: AppTheme.stone400),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar solicitudes\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.stone500, fontSize: 13),
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
                          Icon(Icons.inbox_outlined, size: 48, color: AppTheme.stone300),
                          SizedBox(height: 12),
                          Text(
                            'No hay solicitudes registradas.',
                            style: TextStyle(fontSize: 14, color: AppTheme.stone400),
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
                      onPressed: () => _resolver(context, ref, s.id, 'aprobar'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppTheme.redDanger, size: 22),
                      tooltip: 'Rechazar',
                      onPressed: () => _resolver(context, ref, s.id, 'rechazar'),
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
