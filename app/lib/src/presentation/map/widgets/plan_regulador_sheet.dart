import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../presentation/auth/auth_provider.dart';
import '../providers/map_providers.dart';

class PlanReguladorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> sector;
  const PlanReguladorSheet({super.key, required this.sector});

  @override
  ConsumerState<PlanReguladorSheet> createState() => _PlanReguladorSheetState();
}

class _PlanReguladorSheetState extends ConsumerState<PlanReguladorSheet> {
  late TextEditingController _obsCtrl;

  @override
  void initState() {
    super.initState();
    final obs = ref.read(planReguladorObsProvider);
    _obsCtrl = TextEditingController(text: obs[widget.sector['code']] ?? '');
  }

  @override
  void dispose() { _obsCtrl.dispose(); super.dispose(); }

  void _save() {
    final code = widget.sector['code'] as String;
    final auth = ref.read(authProvider);
    final nombre = auth.user?['nombre'] as String? ?? 'Funcionario';
    final hora = TimeOfDay.now().format(context);

    ref.read(planReguladorObsProvider.notifier).update((m) => {...m, code: _obsCtrl.text.trim()});
    ref.read(planReguladorAttrProvider.notifier).update((m) => {...m, code: '$nombre · $hora'});

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observación guardada'), backgroundColor: AppTheme.greenSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.sector['code'] as String;
    final name = widget.sector['name'] as String;
    final attr = ref.watch(planReguladorAttrProvider)[code];
    final hasEdit = ref.watch(planReguladorEditsProvider).containsKey(code);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.stone300, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 14),

        // Badge + título
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppTheme.amberWarning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: const Text('Plan Regulador',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.amberWarning)),
        ),
        const SizedBox(height: 8),
        Text('$code · $name',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
        const SizedBox(height: 4),
        const Text('Vigente desde 2002 · Fuente: MPR-4 Los Aromos, DOM',
            style: TextStyle(fontSize: 11.5, color: AppTheme.stone500)),

        const SizedBox(height: 14),
        const Divider(height: 1, color: AppTheme.stone100),
        const SizedBox(height: 14),

        const Text('OBSERVACIONES DEL FUNCIONARIO',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.stone500, letterSpacing: 0.06)),
        const SizedBox(height: 8),

        TextField(
          controller: _obsCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Agregar observación sobre este sector…',
            hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),

        if (attr != null) ...[
          const SizedBox(height: 6),
          Text('Editado por $attr', style: const TextStyle(fontSize: 11, color: AppTheme.stone400)),
        ],

        const SizedBox(height: 16),
        const Divider(height: 1, color: AppTheme.stone100),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Empezar desde cero: el polígono original se oculta mientras se
              // dibuja (vía hiddenCode en planReguladorPolygonsProvider) y los
              // vértices arrancan vacíos para evitar el "estiramiento" raro.
              ref.read(drawingTargetProvider.notifier).state = widget.sector['code'] as String;
              ref.read(drawingPointsProvider.notifier).state = [];
              ref.read(isDrawingModeProvider.notifier).state = true;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Re-dibujando ${widget.sector['code']} desde cero — toca el mapa para colocar vértices',
                  ),
                  backgroundColor: AppTheme.amberWarning,
                ),
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Re-dibujar sector desde cero'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.amberWarning,
              side: const BorderSide(color: AppTheme.amberWarning),
            ),
          ),
        ),
        if (hasEdit) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                ref.read(planReguladorEditsProvider.notifier).clearSector(code);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contorno original de $code restaurado'),
                    backgroundColor: AppTheme.stone700,
                  ),
                );
              },
              icon: const Icon(Icons.restore, size: 14),
              label: const Text('Restaurar contorno original'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.stone600),
            ),
          ),
        ],
        const SizedBox(height: 12),

        SizedBox(
            width: double.infinity,
            child: ElevatedButton(

            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberWarning, foregroundColor: Colors.white),
            child: const Text('Guardar observación'),
          )),
      ]),
    );
  }
}