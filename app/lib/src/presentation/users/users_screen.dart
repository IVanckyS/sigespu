import 'package:flutter/material.dart';
import '../../config/theme.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Usuarios',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.stone900),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.stone200),
              ),
              child: ListView(
                children: [
                  DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith((states) => AppTheme.stone50),
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Nivel de Acceso')),
                      DataColumn(label: Text('Estado de Solicitud')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: [
                      _buildUserRow('Director Seguridad Pública', 'director@lota.cl', 'director', '', false),
                      _buildUserRow('Operario Central', 'operador@lota.cl', 'operativo', 'aprobada', false),
                      _buildUserRow('Funcionario Terreno', 'terreno@lota.cl', 'visitante', 'pendiente', true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(String nombre, String email, String nivel, String estadoReq, bool isPending) {
    return DataRow(
      cells: [
        DataCell(Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(email)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.blue800.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(nivel.toUpperCase(), style: const TextStyle(color: AppTheme.blue800, fontSize: 11, fontWeight: FontWeight.bold)),
        )),
        DataCell(isPending 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amberWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('PENDIENTE', style: TextStyle(color: AppTheme.amberWarning, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : Text(estadoReq.toUpperCase(), style: const TextStyle(color: AppTheme.stone500, fontSize: 11))),
        DataCell(isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check_circle, color: AppTheme.greenSuccess), onPressed: () {}, tooltip: 'Aprobar'),
                  IconButton(icon: const Icon(Icons.cancel, color: AppTheme.redDanger), onPressed: () {}, tooltip: 'Rechazar'),
                ],
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
