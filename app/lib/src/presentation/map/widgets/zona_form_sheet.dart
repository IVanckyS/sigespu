import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../../../presentation/auth/auth_provider.dart';
import '../map_screen.dart';

class ZonaFormSheet extends ConsumerStatefulWidget {
  final List<LatLng> points;
  const ZonaFormSheet({super.key, required this.points});

  @override
  ConsumerState<ZonaFormSheet> createState() => _ZonaFormSheetState();
}

class _ZonaFormSheetState extends ConsumerState<ZonaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String _tipoPeligro = 'robos';
  int _nivel = 3;
  String _horario = '24/7';

  static const _tiposPeligro = [
    ('drogas', 'Tráfico drogas'), ('robos', 'Robos'), ('vivienda_ilegal', 'Vivienda ilegal'),
    ('vandalismo', 'Vandalismo'), ('riña', 'Riñas'), ('sin_iluminacion', 'Sin iluminación'),
    ('microbasural', 'Microbasural'), ('otro', 'Otro'),
  ];

  static const _horarios = ['24/7', 'Nocturno (22:00-06:00)', 'Tarde/Noche', 'Fines de semana', 'Días hábiles'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  LatLng get _centroid {
    final lat = widget.points.map((p) => p.latitude).reduce((a, b) => a + b) / widget.points.length;
    final lng = widget.points.map((p) => p.longitude).reduce((a, b) => a + b) / widget.points.length;
    return LatLng(lat, lng);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider);
    final centroid = _centroid;

    final zona = ElementoMapa(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      tipo: 'zona_peligro',
      nombre: _nombreCtrl.text.trim(),
      direccion: 'Coordenadas: ${centroid.latitude.toStringAsFixed(4)}, ${centroid.longitude.toStringAsFixed(4)}',
      sector: 'Centro',
      lat: centroid.latitude,
      lng: centroid.longitude,
      estado: 'activo',
      fecha: DateTime.now().toIso8601String().substring(0, 10),
      by: auth.user?['nombre'] as String? ?? 'Funcionario',
      notas: _notasCtrl.text.trim(),
      tipoPeligro: _tipoPeligro,
      nivel: _nivel,
      horario: _horario,
    );

    ref.read(userElementsProvider.notifier).update((s) => [...s, zona]);
    ref.read(userPolygonsProvider.notifier).update((s) => [...s, (points: widget.points, zona: zona)]);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zona de peligro guardada'), backgroundColor: AppTheme.greenSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.stone300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),

          const Text('Nueva zona de peligro',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
          Text('${widget.points.length} vértices dibujados',
              style: const TextStyle(fontSize: 12, color: AppTheme.stone500)),
          const SizedBox(height: 16),

          // Nombre
          TextFormField(
            controller: _nombreCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre de la zona *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          // Tipo de peligro + Horario
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _tipoPeligro,
                decoration: InputDecoration(
                  labelText: 'Tipo de peligro',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                items: _tiposPeligro.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2, style: const TextStyle(fontSize: 12.5)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _tipoPeligro = v); },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _horario,
                decoration: InputDecoration(
                  labelText: 'Horario crítico',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                items: _horarios.map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 12.5)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _horario = v); },
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Nivel de riesgo
          const Text('Nivel de riesgo',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.04)),
          const SizedBox(height: 6),
          Row(children: List.generate(5, (i) {
            final n = i + 1;
            final active = _nivel == n;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _nivel = n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.redDanger : AppTheme.stone100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? AppTheme.redDanger : AppTheme.stone200),
                  ),
                  child: Center(
                    child: Text('$n', style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14,
                      color: active ? Colors.white : AppTheme.stone600,
                    )),
                  ),
                ),
              ),
            );
          })),
          const SizedBox(height: 12),

          // Notas
          TextFormField(
            controller: _notasCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notas / Observaciones',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),

          // Botones
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redDanger, foregroundColor: Colors.white),
                child: const Text('Guardar zona'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
