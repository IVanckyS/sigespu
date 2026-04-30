# Map Interactivity + Auth Hardening — Design Spec

**Goal:** Implementar la interactividad completa del mapa (popups, modal de agregar, heatmap real, formulario de zona, Plan Regulador editable, atribución) y endurecer auth (registro, sin auto-relleno, admin@lota.cl).

**Architecture:** Dos subsistemas independientes en el mismo sprint. El mapa usa Riverpod en memoria (sin Drift aún — Sprint 3). Auth modifica `auth_screen.dart`, `auth_provider.dart` y el backend Dart/Shelf.

**Tech Stack:** Flutter 3.27+, Riverpod 2.x, flutter_map 6.x, flutter_map_heatmap ^3.0.0, Dart/Shelf backend.

---

## Plan 1 — Interactividad del mapa

### Archivos afectados

| Acción | Archivo |
|---|---|
| Modificar | `app/pubspec.yaml` — agregar `flutter_map_heatmap: ^3.0.0` |
| Modificar | `app/lib/src/presentation/map/map_screen.dart` — nuevos providers, orquestación |
| Modificar | `app/lib/src/presentation/map/layers/custom_markers.dart` — agregar `onTap` |
| Modificar | `app/lib/src/presentation/map/layers/plan_regulador_layer.dart` — `onTap` por polígono |
| Crear | `app/lib/src/presentation/map/widgets/add_element_modal.dart` |
| Crear | `app/lib/src/presentation/map/widgets/element_detail_sheet.dart` |
| Crear | `app/lib/src/presentation/map/widgets/zona_form_sheet.dart` |
| Crear | `app/lib/src/presentation/map/widgets/plan_regulador_sheet.dart` |

### 1.1 Providers en memoria

```dart
// En map_screen.dart (al tope, fuera de la clase)

// Elementos creados por el usuario en esta sesión
final userElementsProvider = StateProvider<List<ElementoMapa>>((ref) => []);

// Todos los elementos: seed + usuario
final allElementsProvider = Provider<List<ElementoMapa>>((ref) {
  return [...kElementosSeed, ...ref.watch(userElementsProvider)];
});

// Polígonos de zona dibujados (para renderizar en PolygonLayer)
final userPolygonsProvider = StateProvider<List<({List<LatLng> points, ElementoMapa zona})>>((ref) => []);

// Observaciones por sector del Plan Regulador (código → texto)
final planReguladorObsProvider = StateProvider<Map<String, String>>((ref) => {});

// Atribución de observaciones del Plan Regulador (código → "Nombre · HH:mm")
final planReguladorAttrProvider = StateProvider<Map<String, String>>((ref) => {});
```

Reemplazar todas las referencias a `kElementosSeed` en `MapScreen.build` por `ref.watch(allElementsProvider)`.

### 1.2 custom_markers.dart — agregar onTap

`CustomMarkers.buildMarker` recibe un parámetro `onTap: VoidCallback?`:

```dart
static Marker buildMarker({
  required LatLng point,
  required IconData icon,
  required Color color,
  bool isPending = false,
  VoidCallback? onTap,
}) {
  return Marker(
    point: point,
    width: 32, height: 40,
    child: GestureDetector(
      onTap: onTap,
      child: _MarkerWidget(icon: icon, color: color, isPending: isPending),
    ),
  );
}
```

En `map_screen.dart`, al construir marcadores, pasar:
```dart
onTap: () => _showElementDetail(context, e),
```

donde `_showElementDetail` es una función libre que llama:
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => ElementDetailSheet(elemento: e),
);
```

### 1.3 ElementDetailSheet

`app/lib/src/presentation/map/widgets/element_detail_sheet.dart`

Widget `ElementDetailSheet extends StatelessWidget` con parámetro `final ElementoMapa elemento`.

Estructura visual (bottom sheet redondeado, drag handle arriba):
```
┌──────────────────────────────────┐
│  ▬  (drag handle)                │
│  [Badge tipo]    [Badge estado]  │
│  Nombre del elemento             │  ← fontWeight w700, 16px
│  Dirección · Sector              │  ← stone600
│  ─────────────────────────────── │
│  [campos condicionales por tipo] │
│  ─────────────────────────────── │
│  Registrado por Nombre · fecha   │  ← stone500, 11px
│  [si isPending] ● Pendiente sync │
└──────────────────────────────────┘
```

Campos condicionales:
- `zona_peligro`: fila "Nivel N · Label" + "Tipo peligro" + "Horario crítico" si existe
- `patente`: "RUT: X · Giro: Y"
- `centro_acopio` / `sede_comunitaria`: "Capacidad: N personas" si existe
- todos: `notas` si existe (texto stone600, italic)

El badge de `isPending` (elemento en `userElementsProvider`) se determina comparando si el elemento **no** está en `kElementosSeed`:

```dart
final isPending = !kElementosSeed.any((s) => s.id == elemento.id);
```

### 1.4 HeatMapLayer

En `map_screen.dart`, importar `flutter_map_heatmap`.

Cuando `heatmapOn == true`, insertar entre `TileLayer` y `PolygonLayer`:

```dart
if (heatmapOn)
  HeatMapLayer(
    heatMapDataList: allElements
        .where((e) => e.tipo.startsWith('reporte_') || e.tipo == 'zona_peligro')
        .map((e) => WeightedLatLng(
              LatLng(e.lat, e.lng),
              e.tipo == 'zona_peligro' ? (e.nivel ?? 3) * 0.2 : 0.7,
            ))
        .toList(),
    heatMapOptions: HeatMapOptions(
      radius: 35,
      blurFactor: 0.25,
      gradient: {
        0.2: Colors.orange.shade100,
        0.4: const Color(0xFFFB923C),
        0.6: const Color(0xFFEA580C),
        0.8: const Color(0xFFC2410C),
        1.0: const Color(0xFF7C2D12),
      },
    ),
  ),
```

### 1.5 AddElementModal — grilla de tipos + formulario dinámico

`app/lib/src/presentation/map/widgets/add_element_modal.dart`

`AddElementModal extends ConsumerStatefulWidget`. Estado: `String? _selectedType`, campos del formulario.

**Paso 1 — Grilla de tipos** (cuando `_selectedType == null`):

4 grupos según la maqueta:
```dart
const _groups = [
  ('Infraestructura comunitaria', ['centro_acopio', 'sede_comunitaria', 'infraestructura']),
  ('Seguridad pública', ['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente']),
  ('Incidentes urbanos', ['arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando', 'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural']),
  ('Cobertura y fiscalización', ['patente', 'luminaria', 'camara_cctv']),
];
```

Cada tipo: card 80×80 con ícono coloreado + nombre. Al tocar → `setState(() => _selectedType = tipo)` y el título del sheet cambia a "Nuevo: [nombre tipo]".

**Paso 2 — Formulario dinámico** (cuando `_selectedType != null`):

Campos base (todos los tipos):
- Bloque GPS: ícono pin + coordenadas actuales. En `initState` llamar `Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then(...)` y actualizar `_currentLat/_currentLng`. Fallback si falla o no hay permiso: `AppConstants.lotaCenter.latitude / longitude`. Mostrar "Obteniendo ubicación…" mientras se carga.
- `nombre` TextField — "Nombre / Descripción"
- `nombre` TextField — "Nombre / Descripción"
- `direccion` TextField — "Dirección"
- `notas` TextField multilínea — "Notas / Observaciones"

Campos condicionales:
- `zona_peligro`: Dropdown tipo_peligro (drogas/robos/vivienda_ilegal/vandalismo/riña/sin_iluminacion/otro), Row de 5 botones nivel 1-5, Dropdown horario_critico (24/7 / Nocturno / Tarde-Noche / Fines de semana)
- `centro_acopio`: TextField `capacidad` numérico
- `patente`: TextField `rut`, TextField `giro`

**Guardar:**

```dart
void _save(WidgetRef ref, AuthState auth) {
  final nombre = _nombreCtrl.text.trim();
  final direccion = _direccionCtrl.text.trim();
  if (nombre.isEmpty || direccion.isEmpty) { /* show error */ return; }

  final nuevo = ElementoMapa(
    id: 'user-${DateTime.now().millisecondsSinceEpoch}',
    tipo: _selectedType!,
    nombre: nombre,
    direccion: direccion,
    sector: 'Centro', // TODO: inferir por coordenada en Sprint 3
    lat: _currentLat,
    lng: _currentLng,
    estado: 'activo',
    fecha: DateTime.now().toIso8601String().substring(0, 10),
    by: auth.user?['nombre'] ?? 'Funcionario',
    notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    nivel: _nivel,
    tipoPeligro: _tipoPeligro,
    horario: _horario,
    capacidad: _capacidad,
    rut: _rut,
    giro: _giro,
  );

  ref.read(userElementsProvider.notifier).update((s) => [...s, nuevo]);
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${nombreParaTipo(nuevo.tipo)} registrado'), backgroundColor: AppTheme.greenSuccess),
  );
}
```

El botón "Atrás" (cuando `_selectedType != null`) vuelve a la grilla con `setState(() => _selectedType = null)`.

### 1.6 ZonaFormSheet — formulario al cerrar polígono

`app/lib/src/presentation/map/widgets/zona_form_sheet.dart`

`ZonaFormSheet extends ConsumerStatefulWidget` con parámetro `final List<LatLng> points`.

Campos:
- `nombre` TextField *
- Dropdown `tipoPeligro` (mismos valores que AddElementModal)
- Row de 5 botones nivel 1-5 (estado inicial: 3)
- Dropdown `horario` (24/7 / Nocturno / Tarde-Noche / Fines de semana)
- `notas` TextField multilínea

Al guardar:
1. Calcular centroide: `lat = points.map((p) => p.latitude).average`, `lng = points.map((p) => p.longitude).average`
2. Crear `ElementoMapa` con `tipo='zona_peligro'` + los campos del form + atribución
3. `ref.read(userElementsProvider.notifier).update((s) => [...s, zona])`
4. `ref.read(userPolygonsProvider.notifier).update((s) => [...s, (points: points, zona: zona)])`
5. Cerrar sheet. Snackbar verde.

En `map_screen.dart`, `_showGuardarZona` reemplaza el Snackbar por:
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => ZonaFormSheet(points: points),
);
```

Los polígonos del usuario se renderizan en `PolygonLayer` adicional:
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

### 1.7 Plan Regulador interactivo

**`plan_regulador_layer.dart`** — cambiar retorno de `List<Polygon>` a un widget `PlanReguladorLayerWidget extends StatelessWidget` que acepta `onSectorTap: void Function(Map<String, dynamic> sector)`.

Internamente usa `GestureDetector` sobre cada polígono, pero `flutter_map` v6 no soporta `onTap` por `Polygon` directamente. La solución: un `PolygonLayer` normal (no interactivo) + un `MarkerLayer` con marcadores transparentes en el centroide de cada sector para capturar taps.

Cada "marcador centroide" es un `Marker` con `child: GestureDetector(onTap: () => onSectorTap(sector), child: const SizedBox(width: 80, height: 80))`.

**`plan_regulador_sheet.dart`** — `PlanReguladorSheet extends ConsumerStatefulWidget` con parámetro `final Map<String, dynamic> sector`.

```
┌──────────────────────────────────┐
│  ▬                               │
│  [Badge ambar] Plan Regulador    │
│  S-2 · Residencial Los Aromos    │
│  ─────────────────────────────── │
│  Vigente desde: 2002             │
│  Fuente: MPR-4 Los Aromos, DOM   │
│  ─────────────────────────────── │
│  OBSERVACIONES DEL FUNCIONARIO   │
│  [TextField multilínea]          │
│  ─────────────────────────────── │
│  [si hay obs] Editado por X · hh:mm  │
│  [Guardar observación]           │
└──────────────────────────────────┘
```

Al guardar: `ref.read(planReguladorObsProvider.notifier).update((m) => {...m, sector['code']: texto})` + registro de atribución en un `planReguladorAttrProvider: StateProvider<Map<String, String>>` (key = código, value = "Nombre · HH:mm").

---

## Plan 2 — Auth & Roles

### Archivos afectados

| Acción | Archivo |
|---|---|
| Modificar | `app/lib/src/presentation/auth/auth_screen.dart` |
| Modificar | `app/lib/src/presentation/auth/auth_provider.dart` |
| Modificar | `backend/migrations/002_seed_director.sql` |
| Modificar | `backend/lib/src/auth/` — agregar handler de registro |

### 2.1 auth_screen.dart — sin auto-relleno, con registro

Remover las líneas:
```dart
final _emailController = TextEditingController(text: 'director@lota.cl');
final _passwordController = TextEditingController(text: 'Admin2026!');
```
Reemplazar por `TextEditingController()` vacíos.

Agregar estado: `bool _isRegisterMode = false`.

Toggle "¿Ya tienes cuenta? Inicia sesión / ¿Primera vez? Regístrate":
```dart
Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  Text(_isRegisterMode ? '¿Ya tienes cuenta?' : '¿Primera vez?',
    style: TextStyle(fontSize: 12.5, color: AppTheme.stone500)),
  const SizedBox(width: 4),
  TextButton(
    onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
    child: Text(_isRegisterMode ? 'Inicia sesión' : 'Regístrate con tu correo municipal',
      style: const TextStyle(fontSize: 12.5, color: AppTheme.orange600, fontWeight: FontWeight.w600)),
  ),
])
```

**Modo login** (igual que hoy pero sin auto-relleno):
- Email + Password + Botón "Iniciar sesión"

**Modo registro** (`_isRegisterMode == true`):
- `nombre` TextField — "Nombre completo"
- `email` TextField — "Correo institucional (@lota.cl o @munilota.cl)"
- `password` TextField obscure — "Contraseña"
- `confirmPassword` TextField obscure — "Confirmar contraseña"
- Validación cliente: `email.endsWith('@lota.cl') || email.endsWith('@munilota.cl')`, ambas contraseñas iguales, nombre no vacío
- Botón "Crear cuenta"
- Texto informativo: "Tu cuenta iniciará en modo **Visitante**. Para acceso operativo, solicítalo desde la app."

### 2.2 auth_provider.dart — método register()

```dart
Future<bool> register(String nombre, String email, String password) async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'email': email, 'password': password}),
    );
    if (response.statusCode == 201) {
      // Auto-login after register
      return login(email, password);
    } else {
      final data = jsonDecode(response.body);
      state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error al registrarse');
      return false;
    }
  } catch (e) {
    state = state.copyWith(isLoading: false, error: 'Error de conexión');
    return false;
  }
}
```

### 2.3 Backend — POST /auth/register

Crear handler en `backend/lib/src/auth/register_handler.dart`:

```dart
// POST /auth/register
// Body: { nombre, email, password }
// Validaciones:
//   - email termina en @lota.cl o @munilota.cl → 400 si no
//   - email no existe ya → 409 si existe
//   - password min 8 chars → 400 si no
// Crea usuario con nivel_acceso = 'visitante'
// Retorna 201 + { access_token, refresh_token, user }
```

El handler replica la lógica de login pero inserta en `usuarios` con `nivel_acceso = 'visitante'` y luego genera tokens.

### 2.4 Seed — admin@lota.cl

En `backend/migrations/002_seed_director.sql`, agregar junto al seed existente:

```sql
-- Cambiar director@lota.cl a admin@lota.cl o agregar admin separado
INSERT INTO usuarios (id, email, nombre, password_hash, nivel_acceso, activo, created_at)
VALUES (
  uuid_generate_v4(),
  'admin@lota.cl',
  'Administrador del Sistema',
  '$2b$12$...', -- bcrypt de 'Admin2026!', cost 12
  'director',
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
```

El `director@lota.cl` original permanece para no romper instalaciones existentes. La pantalla de auth muestra `admin@lota.cl` como cuenta de demostración si se quiere mostrar un botón de demo (opcional, sin auto-relleno automático).

---

## Decisiones de diseño registradas

| Decisión | Elección | Razón |
|---|---|---|
| Persistencia elementos nuevos | Riverpod en memoria | Sprint 3 tiene Drift — no duplicar trabajo |
| Popup marcadores | BottomSheet | Coherente con modal existente, mobile-friendly |
| Heatmap | flutter_map_heatmap ^3.0.0 | Plugin oficial para flutter_map v6 |
| Plan Regulador onTap | Marcador centroide invisible | flutter_map v6 no tiene Polygon.onTap nativo |
| Admin account | admin@lota.cl con nivel director | Sin cambio de schema, solo cambio de seed |
| Registro | Toggle en misma tarjeta | Sin nueva ruta, menos complejidad de router |
