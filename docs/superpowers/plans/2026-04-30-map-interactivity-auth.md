# Map Interactivity + Auth Hardening — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar popups al tocar marcadores, modal de agregar con grilla completa, heatmap real, formulario al cerrar polígono, Plan Regulador interactivo, atribución de autor, y pantalla de auth con registro y sin auto-relleno.

**Architecture:** Plan 1 (mapa) usa Riverpod en memoria — nuevos elementos viven en `userElementsProvider` y se fusionan con `kElementosSeed` en `allElementsProvider`. Plan 2 (auth) agrega `register()` al `AuthNotifier` existente y una UI de toggle en `AuthScreen`. El backend ya tiene `/auth/register` implementado.

**Tech Stack:** Flutter 3.27+, Riverpod 2.x, flutter_map 6.x, flutter_map_heatmap ^0.5.0, geolocator 11.x, Dart/Shelf backend (ya completo para auth).

---

## Mapa de archivos

| Acción | Ruta |
|---|---|
| Modificar | `app/pubspec.yaml` |
| Modificar | `app/lib/src/presentation/map/map_screen.dart` |
| Modificar | `app/lib/src/presentation/map/layers/plan_regulador_layer.dart` |
| Crear | `app/lib/src/presentation/map/widgets/element_detail_sheet.dart` |
| Crear | `app/lib/src/presentation/map/widgets/zona_form_sheet.dart` |
| Crear | `app/lib/src/presentation/map/widgets/add_element_modal.dart` |
| Crear | `app/lib/src/presentation/map/widgets/plan_regulador_sheet.dart` |
| Modificar | `app/lib/src/presentation/auth/auth_screen.dart` |
| Modificar | `app/lib/src/presentation/auth/auth_provider.dart` |
| Modificar | `backend/migrations/002_seed_director.sql` |

---

## Task 1: Agregar flutter_map_heatmap a pubspec.yaml

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: Agregar dependencia**

En `app/pubspec.yaml`, dentro de `dependencies:`, agregar después de `flutter_map: ^6.1.0`:

```yaml
  flutter_map_heatmap: ^0.5.0
```

- [ ] **Step 2: Instalar**

```bash
cd app
flutter pub get
```

Resultado esperado: `Got dependencies!` sin errores. Si hay conflicto de versión con flutter_map v6, cambiar a `flutter_map_heatmap: ^0.4.0` y repetir.

- [ ] **Step 3: Verificar**

```bash
flutter analyze --no-pub 2>&1 | grep -i error
```

Resultado esperado: sin líneas de error.

- [ ] **Step 4: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock
git commit -m "chore: agregar flutter_map_heatmap para capa de calor"
```

---

## Task 2: Nuevos providers en map_screen.dart

**Files:**
- Modify: `app/lib/src/presentation/map/map_screen.dart` (líneas 1–26, solo el bloque de providers)

- [ ] **Step 1: Reemplazar el bloque de providers existente**

En `map_screen.dart`, el bloque de providers actual (líneas 14–24) es:

```dart
final activeLayersProvider = StateProvider<Set<String>>((ref) => { ... });
final isDrawingModeProvider = StateProvider<bool>((ref) => false);
final drawingPointsProvider = StateProvider<List<LatLng>>((ref) => []);
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final dangerFilterProvider = StateProvider<String>((ref) => 'all');
final heatmapOnProvider = StateProvider<bool>((ref) => false);
final dateRangeProvider = StateProvider<String>((ref) => '30');
```

Agregar **después** de `dateRangeProvider` los siguientes 4 providers:

```dart
// Elementos creados por el usuario en esta sesión (en memoria)
final userElementsProvider = StateProvider<List<ElementoMapa>>((ref) => []);

// Todos los elementos: seed + usuario
final allElementsProvider = Provider<List<ElementoMapa>>((ref) {
  return [...kElementosSeed, ...ref.watch(userElementsProvider)];
});

// Polígonos dibujados por el usuario con su zona asociada
final userPolygonsProvider =
    StateProvider<List<({List<LatLng> points, ElementoMapa zona})>>((ref) => []);

// Observaciones de funcionarios por sector del Plan Regulador
// key = código sector (ej: 'S-2'), value = texto
final planReguladorObsProvider = StateProvider<Map<String, String>>((ref) => {});

// Atribución de observaciones del Plan Regulador
// key = código sector, value = "Nombre · HH:mm"
final planReguladorAttrProvider = StateProvider<Map<String, String>>((ref) => {});
```

- [ ] **Step 2: Actualizar la referencia a kElementosSeed en MapScreen.build**

En `MapScreen.build`, la línea:
```dart
final elementos = kElementosSeed.where((e) {
```
Cambiar a:
```dart
final elementos = ref.watch(allElementsProvider).where((e) {
```

- [ ] **Step 3: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep -E "error|warning" | grep -v "^$"
```

Resultado esperado: sin errores.

- [ ] **Step 4: Commit**

```bash
git add app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: agregar providers en memoria para elementos y polígonos de usuario"
```

---

## Task 3: ElementDetailSheet — popup al tocar marcador

**Files:**
- Create: `app/lib/src/presentation/map/widgets/element_detail_sheet.dart`

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';

class ElementDetailSheet extends StatelessWidget {
  final ElementoMapa elemento;
  final bool isPending;

  const ElementDetailSheet({
    super.key,
    required this.elemento,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final tipoColor = colorParaTipo(elemento.tipo);
    final tipoLabel = nombreParaTipo(elemento.tipo);
    final estadoColor = colorParaEstado(elemento.estado);
    final estadoBg = bgParaEstado(elemento.estado);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.stone300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges de tipo y estado
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tipoColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(tipoLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tipoColor)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(_labelEstado(elemento.estado),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: estadoColor)),
                  ),
                  if (isPending) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.orange100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Pendiente sync',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.orange700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),

                // Nombre
                Text(elemento.nombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
                const SizedBox(height: 4),
                Text('${elemento.direccion} · ${elemento.sector}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.stone500)),

                // Campos condicionales
                if (elemento.tipo == 'zona_peligro') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Row(children: [
                    _InfoChip(
                      label: 'Nivel ${elemento.nivel ?? '?'} · ${_nivelLabel(elemento.nivel)}',
                      bg: AppTheme.redDanger.withValues(alpha: 0.1),
                      fg: AppTheme.redDanger,
                    ),
                    const SizedBox(width: 6),
                    if (elemento.tipoPeligro != null)
                      _InfoChip(
                        label: _tipoPeligroLabel(elemento.tipoPeligro!),
                        bg: AppTheme.stone100,
                        fg: AppTheme.stone700,
                      ),
                  ]),
                  if (elemento.horario != null) ...[
                    const SizedBox(height: 6),
                    Text('Horario crítico: ${elemento.horario}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600)),
                  ],
                ],

                if (elemento.rut != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Text('RUT: ${elemento.rut}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                  if (elemento.giro != null)
                    Text('Giro: ${elemento.giro}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600)),
                ],

                if (elemento.capacidad != null) ...[
                  const SizedBox(height: 8),
                  Text('Capacidad: ${elemento.capacidad} personas',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                ],

                if (elemento.notas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(elemento.notas,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.stone600, fontStyle: FontStyle.italic)),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.stone100),
                const SizedBox(height: 10),

                // Atribución
                Text('Registrado por ${elemento.by} · ${_formatFecha(elemento.fecha)}',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.stone400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelEstado(String e) {
    const m = {'activo': 'Activo', 'en_revision': 'En revisión', 'cerrado': 'Cerrado', 'vigente': 'Vigente', 'vencido': 'Vencido'};
    return m[e] ?? e;
  }

  String _nivelLabel(int? n) {
    const l = ['', 'Muy bajo', 'Bajo', 'Medio', 'Alto', 'Crítico'];
    if (n == null || n < 1 || n > 5) return 'Sin nivel';
    return l[n];
  }

  String _tipoPeligroLabel(String t) {
    const m = {
      'drogas': 'Tráfico drogas', 'robos': 'Robos', 'vivienda_ilegal': 'Vivienda ilegal',
      'vandalismo': 'Vandalismo', 'riña': 'Riñas', 'sin_iluminacion': 'Sin iluminación',
      'accidentes': 'Accidentes', 'microbasural': 'Microbasural', 'otro': 'Otro',
    };
    return m[t] ?? t;
  }

  String _formatFecha(String f) {
    final d = DateTime.tryParse(f);
    if (d == null) return f;
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _InfoChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
  );
}
```

- [ ] **Step 2: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep error
```

Resultado esperado: sin errores.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/map/widgets/element_detail_sheet.dart
git commit -m "feat: crear ElementDetailSheet para popup de marcadores"
```

---

## Task 4: Conectar onTap de marcadores → ElementDetailSheet

**Files:**
- Modify: `app/lib/src/presentation/map/map_screen.dart`

- [ ] **Step 1: Agregar import del sheet**

Al tope de `map_screen.dart`, agregar:
```dart
import 'widgets/element_detail_sheet.dart';
```

- [ ] **Step 2: Reemplazar construcción de markers en MapScreen.build**

El bloque actual:
```dart
final List<Marker> markers = elementos.map((e) => CustomMarkers.buildMarker(
  point: e.latLng,
  icon: CustomMarkers.getIconForTipo(e.tipo),
  color: CustomMarkers.getColorForTipo(e.tipo),
)).toList();
```

Reemplazar por (añade `onTap` y `isPending`):
```dart
final userElements = ref.watch(userElementsProvider);
final List<Marker> markers = elementos.map((e) {
  final isPending = userElements.any((u) => u.id == e.id);
  return CustomMarkers.buildMarker(
    point: e.latLng,
    icon: CustomMarkers.getIconForTipo(e.tipo),
    color: CustomMarkers.getColorForTipo(e.tipo),
    isPending: isPending,
    onTap: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ElementDetailSheet(elemento: e, isPending: isPending),
    ),
  );
}).toList();
```

- [ ] **Step 3: Verificar en el navegador**

Levantar la app (`flutter run -d edge`), activar una capa, tocar un marcador en el mapa. Debe aparecer un bottom sheet con la información del elemento. Tocar fuera cierra el sheet.

- [ ] **Step 4: Commit**

```bash
git add app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: popups al tocar marcadores en el mapa"
```

---

## Task 5: HeatMapLayer real

**Files:**
- Modify: `app/lib/src/presentation/map/map_screen.dart`

- [ ] **Step 1: Agregar import**

Al tope de `map_screen.dart`:
```dart
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
```

- [ ] **Step 2: Agregar leer heatmapOn y allElements**

En `MapScreen.build`, ya tienes `final heatmapOn = ref.watch(heatmapOnProvider);`. Asegúrate de tener también:
```dart
final allElems = ref.watch(allElementsProvider);
```
(Si ya lees `allElementsProvider` para `elementos`, reutiliza la misma variable.)

- [ ] **Step 3: Insertar HeatMapLayer en el mapa**

Dentro del bloque `children:` del `FlutterMap`, **después** del `TileLayer` y **antes** del `PolygonLayer`, agregar:

```dart
if (heatmapOn)
  HeatMapLayer(
    heatMapDataList: allElems
        .where((e) => e.tipo.startsWith('reporte_') || e.tipo == 'zona_peligro')
        .map((e) => WeightedLatLng(
              e.latLng,
              e.tipo == 'zona_peligro' ? ((e.nivel ?? 3) * 0.2).clamp(0.2, 1.0) : 0.7,
            ))
        .toList(),
    heatMapOptions: HeatMapOptions(
      radius: 35,
      blurFactor: 0.25,
      gradient: const {
        0.2: Color(0xFFFED7AA),
        0.4: Color(0xFFFB923C),
        0.6: Color(0xFFEA580C),
        0.8: Color(0xFFC2410C),
        1.0: Color(0xFF7C2D12),
      },
    ),
  ),
```

- [ ] **Step 4: Verificar en el navegador**

Activar el switch "Densidad de reportes" en el sidebar. Debe aparecer un mapa de calor naranja sobre las zonas con reportes y zonas de peligro. Desactivar limpia la capa.

- [ ] **Step 5: Commit**

```bash
git add app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: implementar mapa de calor con flutter_map_heatmap"
```

---

## Task 6: ZonaFormSheet — formulario al cerrar polígono

**Files:**
- Create: `app/lib/src/presentation/map/widgets/zona_form_sheet.dart`

- [ ] **Step 1: Crear el archivo**

```dart
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
                value: _tipoPeligro,
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
                value: _horario,
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
```

- [ ] **Step 2: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep error
```

Resultado esperado: sin errores.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/map/widgets/zona_form_sheet.dart
git commit -m "feat: crear ZonaFormSheet para guardar zonas dibujadas"
```

---

## Task 7: Conectar ZonaFormSheet al flujo de dibujo + renderizar polígonos

**Files:**
- Modify: `app/lib/src/presentation/map/map_screen.dart`

- [ ] **Step 1: Agregar import del sheet**

Al tope de `map_screen.dart`:
```dart
import 'widgets/zona_form_sheet.dart';
```

- [ ] **Step 2: Reemplazar _showGuardarZona**

El método actual en `MapScreen`:
```dart
void _showGuardarZona(BuildContext context, WidgetRef ref, List<LatLng> points) {
  ref.read(isDrawingModeProvider.notifier).state = false;
  ref.read(drawingPointsProvider.notifier).state = [];
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Zona guardada con ${points.length} puntos'),
      backgroundColor: AppTheme.greenSuccess,
    ),
  );
}
```

Reemplazar por:
```dart
void _showGuardarZona(BuildContext context, WidgetRef ref, List<LatLng> points) {
  ref.read(isDrawingModeProvider.notifier).state = false;
  ref.read(drawingPointsProvider.notifier).state = [];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ZonaFormSheet(points: points),
  );
}
```

- [ ] **Step 3: Agregar leer userPolygons en MapScreen.build**

En `MapScreen.build`, agregar:
```dart
final userPolygons = ref.watch(userPolygonsProvider);
```

- [ ] **Step 4: Renderizar polígonos de usuario en el mapa**

Dentro del bloque `children:` del `FlutterMap`, **después** del `PolygonLayer` del modo dibujo (línea ~117), agregar:
```dart
if (userPolygons.isNotEmpty)
  PolygonLayer(
    polygons: userPolygons.map((p) => Polygon(
      points: p.points,
      color: AppTheme.redDanger.withValues(alpha: 0.2),
      borderColor: AppTheme.redDanger,
      borderStrokeWidth: 2,
    )).toList(),
  ),
```

- [ ] **Step 5: Verificar en el navegador**

1. Activar modo dibujo (ícono lápiz).
2. Tocar el mapa 4+ veces para crear vértices.
3. Presionar "Cerrar figura" — debe aparecer el bottom sheet `ZonaFormSheet`.
4. Completar el formulario y presionar "Guardar zona".
5. El polígono debe aparecer en el mapa en rojo semitransparente.
6. Tocar el marcador del centroide debe mostrar el `ElementDetailSheet`.

- [ ] **Step 6: Commit**

```bash
git add app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: conectar ZonaFormSheet al flujo de dibujo y renderizar polígonos"
```

---

## Task 8: AddElementModal — grilla de tipos

**Files:**
- Create: `app/lib/src/presentation/map/widgets/add_element_modal.dart`

- [ ] **Step 1: Crear el archivo (parte 1: grilla de tipos)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../../../presentation/auth/auth_provider.dart';
import '../map_screen.dart';

class AddElementModal extends ConsumerStatefulWidget {
  const AddElementModal({super.key});

  @override
  ConsumerState<AddElementModal> createState() => _AddElementModalState();
}

class _AddElementModalState extends ConsumerState<AddElementModal> {
  String? _selectedType;
  double _lat = AppConstants.lotaCenter.latitude;
  double _lng = AppConstants.lotaCenter.longitude;
  bool _gpsLoading = true;

  // Controladores de formulario
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _giroCtrl = TextEditingController();
  int _nivel = 3;
  String _tipoPeligro = 'robos';
  String _horario = '24/7';

  final _formKey = GlobalKey<FormState>();

  static const _tiposPeligro = [
    ('drogas', 'Tráfico drogas'), ('robos', 'Robos'), ('vivienda_ilegal', 'Vivienda ilegal'),
    ('vandalismo', 'Vandalismo'), ('riña', 'Riñas'), ('sin_iluminacion', 'Sin iluminación'),
    ('microbasural', 'Microbasural'), ('otro', 'Otro'),
  ];
  static const _horarios = ['24/7', 'Nocturno (22:00-06:00)', 'Tarde/Noche', 'Fines de semana', 'Días hábiles'];

  static const _grupos = [
    ('Infraestructura comunitaria', <String>['centro_acopio', 'sede_comunitaria', 'infraestructura']),
    ('Seguridad pública', <String>['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente']),
    ('Incidentes urbanos', <String>['arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando', 'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural']),
    ('Cobertura y fiscalización', <String>['patente', 'luminaria', 'camara_cctv']),
  ];

  @override
  void initState() {
    super.initState();
    _captureGPS();
  }

  Future<void> _captureGPS() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      if (mounted) setState(() { _lat = pos.latitude; _lng = pos.longitude; _gpsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _gpsLoading = false);
      // fallback a lotaCenter ya está en _lat/_lng
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _direccionCtrl.dispose(); _notasCtrl.dispose();
    _capacidadCtrl.dispose(); _rutCtrl.dispose(); _giroCtrl.dispose();
    super.dispose();
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
      child: _selectedType == null ? _buildTypeGrid() : _buildForm(),
    );
  }

  Widget _buildTypeGrid() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.stone300, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 14),
        const Text('Agregar elemento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
        const SizedBox(height: 4),
        const Text('Selecciona el tipo. El GPS capturará tu ubicación.',
            style: TextStyle(fontSize: 12.5, color: AppTheme.stone500)),
        const SizedBox(height: 16),
        ..._grupos.map((grupo) {
          final (titulo, tipos) = grupo;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo.toUpperCase(),
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.stone500, letterSpacing: 0.06)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: tipos.map((tipo) {
              final color = CustomMarkers.getColorForTipo(tipo);
              final icon = CustomMarkers.getIconForTipo(tipo);
              final nombre = nombreParaTipo(tipo);
              return GestureDetector(
                onTap: () => setState(() => _selectedType = tipo),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.stone50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.stone200),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(nombre, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppTheme.stone800),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
          ]);
        }),
      ]),
    );
  }
```

- [ ] **Step 2: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep error
```

Resultado esperado: sin errores.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/map/widgets/add_element_modal.dart
git commit -m "feat: AddElementModal - grilla de tipos con 4 grupos"
```

---

## Task 9: AddElementModal — formulario dinámico y guardar

**Files:**
- Modify: `app/lib/src/presentation/map/widgets/add_element_modal.dart`

- [ ] **Step 1: Agregar _buildForm() y _save() al final de _AddElementModalState**

Dentro de `_AddElementModalState`, **después** de `_buildTypeGrid()`, agregar:

```dart
  Widget _buildForm() {
    final tipo = _selectedType!;
    final color = CustomMarkers.getColorForTipo(tipo);
    final icon = CustomMarkers.getIconForTipo(tipo);
    final nombre = nombreParaTipo(tipo);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.stone300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),

          // Header con botón volver
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _selectedType = null),
              child: const Icon(Icons.arrow_back, size: 20, color: AppTheme.stone600),
            ),
            const SizedBox(width: 10),
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16)),
            const SizedBox(width: 8),
            Text('Nuevo: $nombre', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
          ]),
          const SizedBox(height: 14),

          // Bloque GPS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.stone50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.stone200)),
            child: Row(children: [
              const Icon(Icons.location_pin, color: AppTheme.orange600, size: 20),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('UBICACIÓN CAPTURADA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.stone500, letterSpacing: 0.04)),
                const SizedBox(height: 2),
                _gpsLoading
                    ? const Text('Obteniendo ubicación…', style: TextStyle(fontSize: 12, color: AppTheme.stone500))
                    : Text('${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.stone800)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Nombre
          TextFormField(
            controller: _nombreCtrl,
            decoration: InputDecoration(labelText: 'Nombre / Descripción *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 10),

          // Dirección
          TextFormField(
            controller: _direccionCtrl,
            decoration: InputDecoration(labelText: 'Dirección *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 10),

          // Campos condicionales: zona_peligro
          if (tipo == 'zona_peligro') ...[
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _tipoPeligro,
                decoration: InputDecoration(labelText: 'Tipo de peligro',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                items: _tiposPeligro.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2, style: const TextStyle(fontSize: 12.5)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _tipoPeligro = v); },
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(
                value: _horario,
                decoration: InputDecoration(labelText: 'Horario crítico',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                items: _horarios.map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 12.5)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _horario = v); },
              )),
            ]),
            const SizedBox(height: 10),
            const Text('Nivel de riesgo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600)),
            const SizedBox(height: 6),
            Row(children: List.generate(5, (i) {
              final n = i + 1; final active = _nivel == n;
              return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                onTap: () => setState(() => _nivel = n),
                child: AnimatedContainer(duration: const Duration(milliseconds: 120),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.redDanger : AppTheme.stone100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? AppTheme.redDanger : AppTheme.stone200),
                  ),
                  child: Center(child: Text('$n', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                      color: active ? Colors.white : AppTheme.stone600)))),
              ));
            })),
            const SizedBox(height: 10),
          ],

          // Campos condicionales: centro_acopio
          if (tipo == 'centro_acopio') ...[
            TextFormField(
              controller: _capacidadCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Capacidad (personas)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
            ),
            const SizedBox(height: 10),
          ],

          // Campos condicionales: patente
          if (tipo == 'patente') ...[
            Row(children: [
              Expanded(child: TextFormField(controller: _rutCtrl,
                decoration: InputDecoration(labelText: 'RUT',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true))),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(controller: _giroCtrl,
                decoration: InputDecoration(labelText: 'Giro comercial',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true))),
            ]),
            const SizedBox(height: 10),
          ],

          // Notas
          TextFormField(
            controller: _notasCtrl, maxLines: 2,
            decoration: InputDecoration(labelText: 'Notas / Observaciones',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
          ),
          const SizedBox(height: 20),

          // Botones
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange600, foregroundColor: Colors.white),
              child: const Text('Guardar'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider);
    final tipo = _selectedType!;

    final nuevo = ElementoMapa(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      tipo: tipo,
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      sector: 'Centro',
      lat: _lat,
      lng: _lng,
      estado: 'activo',
      fecha: DateTime.now().toIso8601String().substring(0, 10),
      by: auth.user?['nombre'] as String? ?? 'Funcionario',
      notas: _notasCtrl.text.trim(),
      nivel: tipo == 'zona_peligro' ? _nivel : null,
      tipoPeligro: tipo == 'zona_peligro' ? _tipoPeligro : null,
      horario: tipo == 'zona_peligro' ? _horario : null,
      capacidad: tipo == 'centro_acopio' && _capacidadCtrl.text.isNotEmpty
          ? int.tryParse(_capacidadCtrl.text) : null,
      rut: tipo == 'patente' && _rutCtrl.text.isNotEmpty ? _rutCtrl.text.trim() : null,
      giro: tipo == 'patente' && _giroCtrl.text.isNotEmpty ? _giroCtrl.text.trim() : null,
    );

    ref.read(userElementsProvider.notifier).update((s) => [...s, nuevo]);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${nombreParaTipo(nuevo.tipo)} registrado'), backgroundColor: AppTheme.greenSuccess),
    );
  }
}
```

- [ ] **Step 2: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep error
```

Resultado esperado: sin errores.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/map/widgets/add_element_modal.dart
git commit -m "feat: AddElementModal - formulario dinámico por tipo y lógica de guardado"
```

---

## Task 10: Conectar AddElementModal al FAB

**Files:**
- Modify: `app/lib/src/presentation/map/map_screen.dart`

- [ ] **Step 1: Agregar import**

Al tope de `map_screen.dart`:
```dart
import 'widgets/add_element_modal.dart';
```

- [ ] **Step 2: Reemplazar _showAddModal en _FabGroup**

El método actual:
```dart
void _showAddModal(BuildContext ctx, WidgetRef r) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: ...,
    builder: (_) => Padding(
      padding: ...,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Agregar elemento', ...),
        ...
      ]),
    ),
  );
}
```

Reemplazar **todo el método** por:
```dart
void _showAddModal(BuildContext ctx, WidgetRef r) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddElementModal(),
  );
}
```

- [ ] **Step 3: Verificar en el navegador**

Presionar el FAB naranja ("+"). Debe aparecer el `AddElementModal` con la grilla de 4 grupos y múltiples tipos. Seleccionar un tipo → debe aparecer el formulario con el bloque GPS y los campos correctos para el tipo elegido. Presionar "← atrás" (flecha) vuelve a la grilla.

- [ ] **Step 4: Commit**

```bash
git add app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: conectar FAB al AddElementModal completo"
```

---

## Task 11: Plan Regulador interactivo

**Files:**
- Modify: `app/lib/src/presentation/map/layers/plan_regulador_layer.dart`
- Create: `app/lib/src/presentation/map/widgets/plan_regulador_sheet.dart`
- Modify: `app/lib/src/presentation/map/map_screen.dart`

- [ ] **Step 1: Agregar buildCentroidMarkers a PlanReguladorLayer**

En `plan_regulador_layer.dart`, agregar después del método `buildPolygons()`:

```dart
// Datos de sectores con nombre y coords (reflejando buildPolygons)
static const _sectores = [
  {'code': 'S-2', 'name': 'Residencial Los Aromos',
   'coords': [[-37.0850,-73.1690],[-37.0820,-73.1670],[-37.0820,-73.1620],[-37.0850,-73.1610],[-37.0870,-73.1640],[-37.0850,-73.1690]]},
  {'code': 'S-3', 'name': 'Mixto Los Aromos',
   'coords': [[-37.0820,-73.1620],[-37.0820,-73.1670],[-37.0790,-73.1660],[-37.0785,-73.1615],[-37.0820,-73.1620]]},
  {'code': 'S-4', 'name': 'Equipamiento',
   'coords': [[-37.0785,-73.1615],[-37.0790,-73.1660],[-37.0760,-73.1655],[-37.0755,-73.1610],[-37.0785,-73.1615]]},
  {'code': 'S-5', 'name': 'Vivienda Periférica',
   'coords': [[-37.0755,-73.1610],[-37.0760,-73.1655],[-37.0720,-73.1640],[-37.0715,-73.1600],[-37.0755,-73.1610]]},
  {'code': 'Centro', 'name': 'Centro Histórico Lota',
   'coords': [[-37.1010,-73.1570],[-37.0980,-73.1530],[-37.0950,-73.1560],[-37.0970,-73.1600],[-37.1010,-73.1570]]},
];

static List<Marker> buildCentroidMarkers(
    void Function(Map<String, dynamic> sector) onTap) {
  return _sectores.map((s) {
    final coords = s['coords'] as List;
    final lat = coords.map((c) => (c as List)[0] as double).reduce((a, b) => a + b) / coords.length;
    final lng = coords.map((c) => (c as List)[1] as double).reduce((a, b) => a + b) / coords.length;
    return Marker(
      point: LatLng(lat, lng),
      width: 80, height: 80,
      child: GestureDetector(
        onTap: () => onTap(s),
        child: const SizedBox(width: 80, height: 80), // transparente
      ),
    );
  }).toList();
}
```

- [ ] **Step 2: Crear PlanReguladorSheet**

Crear `app/lib/src/presentation/map/widgets/plan_regulador_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../presentation/auth/auth_provider.dart';
import '../map_screen.dart';

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
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberWarning, foregroundColor: Colors.white),
            child: const Text('Guardar observación'),
          )),
      ]),
    );
  }
}
```

- [ ] **Step 3: Conectar en map_screen.dart**

Agregar imports:
```dart
import 'widgets/plan_regulador_sheet.dart';
```

En `MapScreen.build`, dentro del bloque `children:` del `FlutterMap`, después del `PolygonLayer` del Plan Regulador:

```dart
if (activeLayers.contains('plan_regulador'))
  MarkerLayer(
    markers: PlanReguladorLayer.buildCentroidMarkers(
      (sector) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PlanReguladorSheet(sector: sector),
      ),
    ),
  ),
```

- [ ] **Step 4: Verificar en el navegador**

Activar capa "Plan Regulador". Tocar dentro de un sector coloreado → debe aparecer el `PlanReguladorSheet` con el código y nombre correcto. Escribir una observación y presionar "Guardar" → snackbar verde. Volver a tocar el sector → debe mostrar la observación guardada y la atribución "Funcionario · HH:mm".

- [ ] **Step 5: Commit**

```bash
git add app/lib/src/presentation/map/layers/plan_regulador_layer.dart \
        app/lib/src/presentation/map/widgets/plan_regulador_sheet.dart \
        app/lib/src/presentation/map/map_screen.dart
git commit -m "feat: Plan Regulador interactivo con PlanReguladorSheet editable"
```

---

## Task 12: auth_provider.dart — agregar método register()

**Files:**
- Modify: `app/lib/src/presentation/auth/auth_provider.dart`

- [ ] **Step 1: Agregar método register() en AuthNotifier**

Después del método `login(...)` y antes de `logout()`, agregar:

```dart
Future<bool> register(String nombre, String email, String password) async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
      state = state.copyWith(isAuthenticated: true, isLoading: false, user: data['user']);
      return true;
    } else {
      final data = jsonDecode(response.body);
      state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error al registrarse');
      return false;
    }
  } catch (e) {
    state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
    return false;
  }
}
```

- [ ] **Step 2: Verificar análisis**

```bash
flutter analyze --no-pub 2>&1 | grep error
```

Resultado esperado: sin errores.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/auth/auth_provider.dart
git commit -m "feat: agregar método register() en AuthNotifier"
```

---

## Task 13: auth_screen.dart — sin auto-relleno + toggle de registro

**Files:**
- Modify: `app/lib/src/presentation/auth/auth_screen.dart`

- [ ] **Step 1: Reemplazar auth_screen.dart completo**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // Controladores sin auto-relleno
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  static const _allowedDomains = ['lota.cl', 'munilota.cl'];

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _nombreCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (!val.contains('@')) return 'Correo inválido';
    final domain = val.split('@').last;
    if (_isRegisterMode && !_allowedDomains.contains(domain)) {
      return 'Solo correos @lota.cl o @munilota.cl';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegisterMode) {
      ref.read(authProvider.notifier).register(
        _nombreCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } else {
      ref.read(authProvider.notifier).login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isAuthenticated) context.go('/map');
    });

    return Scaffold(
      backgroundColor: AppTheme.stone100,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: AppTheme.blue800, shape: BoxShape.circle),
                  child: const Icon(Icons.shield, color: AppTheme.orange600, size: 36),
                ),
                const SizedBox(height: 20),
                const Text('SIGESPU Lota',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.stone900, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                const Text('Ilustre Municipalidad de Lota',
                    style: TextStyle(fontSize: 12, color: AppTheme.stone400, letterSpacing: 0.06)),
                const SizedBox(height: 28),

                // Título del modo actual
                Text(_isRegisterMode ? 'Crear cuenta municipal' : 'Iniciar sesión',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
                const SizedBox(height: 20),

                // Error
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.redDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.redDanger.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppTheme.redDanger, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(authState.error!,
                          style: const TextStyle(color: AppTheme.redDanger, fontSize: 13))),
                    ]),
                  ),

                // Campo nombre (solo registro)
                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                ],

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo institucional',
                    hintText: _isRegisterMode ? 'funcionario@munilota.cl' : null,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),

                // Confirmar password (solo registro)
                if (_isRegisterMode) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v != _passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
                  ),
                ],

                const SizedBox(height: 24),

                // Aviso de registro
                if (_isRegisterMode)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.orange100),
                    ),
                    child: const Text(
                      'Tu cuenta iniciará en modo Visitante (solo lectura). Para acceso operativo, solicítalo desde la app una vez dentro.',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.orange700),
                    ),
                  ),

                // Botón principal
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión',
                            style: const TextStyle(fontSize: 15)),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle login/registro
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_isRegisterMode ? '¿Ya tienes cuenta?' : '¿Primera vez?',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone500)),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _formKey.currentState?.reset();
                      _emailCtrl.clear(); _passwordCtrl.clear();
                      _nombreCtrl.clear(); _confirmCtrl.clear();
                    }),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(
                      _isRegisterMode ? 'Inicia sesión' : 'Regístrate con tu correo municipal',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.orange600, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar en el navegador**

1. La pantalla de login debe aparecer **vacía** (sin director@lota.cl ni contraseña pre-rellena).
2. Presionar "Regístrate con tu correo municipal" → aparece el formulario de registro con campo "Nombre completo" y "Confirmar contraseña".
3. Intentar registrar con `test@gmail.com` → error "Solo correos @lota.cl o @munilota.cl".
4. Presionar "¿Ya tienes cuenta? Inicia sesión" → vuelve al login vacío.

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/auth/auth_screen.dart
git commit -m "feat: auth sin auto-relleno y formulario de registro con validación de dominio"
```

---

## Task 14: Seed — agregar admin@lota.cl

**Files:**
- Modify: `backend/migrations/002_seed_director.sql`

- [ ] **Step 1: Agregar seed de admin**

En `backend/migrations/002_seed_director.sql`, agregar después del INSERT existente:

```sql
INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'admin@lota.cl',
  'Administrador del Sistema',
  '$2a$12$Vz7RTvLmIubAynwgWt8gjezaNiui8j21dLkxxt6BMXZjuZQY17QES',
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
```

(El hash `$2a$12$Vz7RTvLmIubAyn...` es el bcrypt de `'Admin2026!'` con cost 12 — mismo que el director existente.)

- [ ] **Step 2: Re-ejecutar la migración en Docker**

```bash
docker compose exec postgres psql -U sigespu -d sigespu_db -f /docker-entrypoint-initdb.d/002_seed_director.sql
```

Si no está montado el archivo en el contenedor, copiar y ejecutar directamente:

```bash
docker compose exec -T postgres psql -U sigespu -d sigespu_db < backend/migrations/002_seed_director.sql
```

Resultado esperado: `INSERT 0 1` (o `INSERT 0 0` si ya existía el row — `ON CONFLICT DO NOTHING`).

- [ ] **Step 3: Verificar login con admin@lota.cl**

En la app, iniciar sesión con `admin@lota.cl` / `Admin2026!`. Debe redirigir al mapa correctamente.

- [ ] **Step 4: Commit**

```bash
git add backend/migrations/002_seed_director.sql
git commit -m "feat: agregar seed admin@lota.cl con nivel director"
```

---

## Self-review

### Cobertura del spec

| Requisito | Tarea |
|---|---|
| Providers en memoria (userElements, allElements, userPolygons) | Task 2 |
| Popup al tocar marcador | Task 3 + Task 4 |
| Heatmap real con flutter_map_heatmap | Task 1 + Task 5 |
| Formulario al cerrar polígono | Task 6 + Task 7 |
| Modal agregar con grilla de tipos | Task 8 |
| Modal agregar con formularios dinámicos | Task 9 |
| Guardar elemento con atribución (by + fecha) | Task 9 (_save) |
| FAB conectado al modal completo | Task 10 |
| Plan Regulador tap por sector | Task 11 |
| Plan Regulador con edición de observaciones | Task 11 |
| Atribución en Plan Regulador | Task 11 (planReguladorAttrProvider) |
| auth sin auto-relleno | Task 13 |
| Formulario de registro con validación @lota.cl | Task 13 |
| register() en AuthNotifier | Task 12 |
| admin@lota.cl seed | Task 14 |

### Tipos consistentes en todo el plan

- `ElementoMapa.notas` es `required String notas` — todos los `ElementoMapa(...)` en Tasks 6 y 9 pasan `notas: _notasCtrl.text.trim()` (puede ser `''`, nunca null). ✓
- `userPolygonsProvider` tipo: `StateProvider<List<({List<LatLng> points, ElementoMapa zona})>>` — usado en Tasks 2, 6, 7 con records `(points: ..., zona: ...)`. ✓
- `planReguladorAttrProvider` definido en Task 2, usado en Task 11. ✓
- `CustomMarkers.getColorForTipo` y `CustomMarkers.getIconForTipo` — llamados en Task 8 desde `AddElementModal` que importa `custom_markers.dart`. ✓
- `authProvider.state.user?['nombre']` tipo `Object?` — cast explícito a `String?` con `as String?` en Tasks 6, 9, 11. ✓
