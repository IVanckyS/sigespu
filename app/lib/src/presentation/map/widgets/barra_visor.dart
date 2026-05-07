import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/visor_provider.dart';
import '../../../config/theme.dart';

class BarraVisor extends ConsumerWidget {
  const BarraVisor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePanel = ref.watch(activePanelProvider);
    final selectedCapaId = ref.watch(selectedCapaIdProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2327),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VisorBtn(
            icon: Icons.list_alt,
            color: const Color(0xFF00897B),
            label: 'Capas',
            active: activePanel == VisorPanel.capas,
            onTap: () => _toggle(ref, VisorPanel.capas),
          ),
          _VisorBtn(
            icon: Icons.map_outlined,
            color: AppTheme.orange600,
            label: 'Mapa base',
            active: activePanel == VisorPanel.mapaBase,
            onTap: () => _toggle(ref, VisorPanel.mapaBase),
          ),
          _VisorBtn(
            icon: Icons.print_outlined,
            color: const Color(0xFF1E88E5),
            label: 'Imprimir',
            active: activePanel == VisorPanel.imprimir,
            onTap: () => _toggle(ref, VisorPanel.imprimir),
          ),
          _VisorBtn(
            icon: Icons.legend_toggle,
            color: const Color(0xFF757575),
            label: 'Leyenda',
            active: activePanel == VisorPanel.leyenda,
            onTap: () => _toggle(ref, VisorPanel.leyenda),
          ),
          if (selectedCapaId != null)
            _VisorBtn(
              icon: Icons.download_outlined,
              color: const Color(0xFF2E7D32),
              label: 'Descargar capa',
              active: false,
              onTap: () async {
                final url = await exportCapa(selectedCapaId);
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  void _toggle(WidgetRef ref, VisorPanel panel) {
    final current = ref.read(activePanelProvider);
    ref.read(activePanelProvider.notifier).state =
        current == panel ? VisorPanel.none : panel;
  }
}

class _VisorBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _VisorBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? color : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: active ? Colors.white : color),
          ),
        ),
      ),
    );
  }
}
