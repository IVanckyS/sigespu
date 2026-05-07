# VISOR SIGESPU — Implementación tipo SENAPRED Chile Preparado

## Contexto general

Agregar al mapa existente de SIGESPU Lota un visor de capas y amenazas inspirado en el
Visor Chile Preparado de SENAPRED. El mapa base ya existe usando `flutter_map` con tiles
CartoDB Voyager. El stack es Flutter + Riverpod + GoRouter (frontend) y Dart/Shelf +
PostgreSQL/PostGIS + Redis (backend), todo dockerizado.

**Lota no tiene amenaza volcánica.** Las capas a implementar son:

| Capa | Fuente | Tipo |
|---|---|---|
| Sismos recientes | USGS Earthquake API (GeoJSON) | Puntos dinámicos |
| Incendio Forestal | Capa estática/manual del director | Polígonos |
| Tsunami / Zona inundación | Capa subida por director (KMZ/SHP) | Polígonos |
| Capas SIGESPU existentes | PostGIS local | Puntos/polígonos |

---

## 1. Base de datos — Nuevas tablas

Crear nueva migración en `backend/db/migrations/`:

```sql
-- Capas personalizadas subidas por el director (KMZ, SHP, GeoJSON)
CREATE TABLE capas_personalizadas (
  id          SERIAL PRIMARY KEY,
  nombre      TEXT NOT NULL,
  descripcion TEXT,
  color       TEXT NOT NULL DEFAULT '#FF5722',
  opacidad    FLOAT NOT NULL DEFAULT 0.5,
  visible     BOOLEAN NOT NULL DEFAULT true,
  formato     TEXT NOT NULL CHECK (formato IN ('kmz', 'shp', 'geojson')),
  subido_por  INTEGER REFERENCES usuarios(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Geometrías parseadas de cada capa personalizada
CREATE TABLE geometrias_capa (
  id          SERIAL PRIMARY KEY,
  capa_id     INTEGER REFERENCES capas_personalizadas(id) ON DELETE CASCADE,
  nombre      TEXT,
  propiedades JSONB DEFAULT '{}',
  geom        GEOMETRY(GEOMETRY, 4326) NOT NULL
);
CREATE INDEX ON geometrias_capa USING GIST (geom);

-- Cache de sismos recientes de USGS (TTL de 5 minutos en lógica de negocio)
CREATE TABLE sismos_cache (
  usgs_id       TEXT PRIMARY KEY,
  magnitude     FLOAT NOT NULL,
  mag_type      TEXT,
  place         TEXT,
  time_utc      TIMESTAMPTZ NOT NULL,
  depth_km      FLOAT,
  alert         TEXT,    -- green/yellow/orange/red o NULL
  tsunami       INTEGER, -- 0 o 1
  url_usgs      TEXT,
  geom          GEOMETRY(POINT, 4326) NOT NULL,
  fetched_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON sismos_cache USING GIST (geom);
CREATE INDEX ON sismos_cache (time_utc DESC);
```

---

## 2. Backend Shelf — Nuevos endpoints

### 2.1 Sismos — Proxy con cache hacia USGS

**Archivo nuevo:** `backend/lib/src/routes/sismos_route.dart`

**Endpoint:** `GET /api/sismos`

**Query params aceptados:**

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `dias` | int | 7 | Cuántos días hacia atrás buscar (máx 30) |
| `minmagnitude` | double | 3.0 | Magnitud mínima |
| `maxradiuskm` | double | 500 | Radio en km desde Lota |

**Lógica:**
1. Revisar si `sismos_cache` tiene datos con `fetched_at` < 5 minutos → retornar cache.
2. Si el cache está vencido, llamar a la USGS API:

```
GET https://earthquake.usgs.gov/fdsnws/event/1/query
  ?format=geojson
  &starttime={hoy - dias}
  &endtime={hoy}
  &minmagnitude={minmagnitude}
  &latitude=-37.0894       ← coordenadas de Lota
  &longitude=-73.1580
  &maxradiuskm={maxradiuskm}
  &orderby=time
  &limit=200
```

3. Parsear el GeoJSON de USGS. Estructura de cada feature:
```json
{
  "type": "Feature",
  "properties": {
    "mag": 4.2,
    "place": "150 km SW de Concepción",
    "time": 1746614400000,
    "magType": "mw",
    "alert": null,
    "tsunami": 0,
    "url": "https://earthquake.usgs.gov/earthquakes/eventpage/..."
  },
  "geometry": {
    "type": "Point",
    "coordinates": [-73.5, -37.8, 25.0]
  },
  "id": "us7000abcd"
}
```
- `coordinates[0]` = longitud, `coordinates[1]` = latitud, `coordinates[2]` = profundidad km.
- `time` es Unix timestamp en milisegundos.

4. Hacer upsert en `sismos_cache` con los datos parseados.
5. Retornar JSON propio (no re-exponer todo el GeoJSON de USGS):

```json
{
  "sismos": [
    {
      "id": "us7000abcd",
      "magnitude": 4.2,
      "magType": "mw",
      "place": "150 km SW de Concepción",
      "timeUtc": "2026-05-07T11:00:00Z",
      "depthKm": 25.0,
      "latitude": -37.8,
      "longitude": -73.5,
      "alert": null,
      "tsunami": 0,
      "urlUsgs": "https://earthquake.usgs.gov/..."
    }
  ],
  "total": 1,
  "generatedAt": "2026-05-07T11:05:00Z"
}
```

**Manejo de errores:** Si USGS no responde, retornar el cache aunque esté vencido con un
campo `"stale": true`. Si no hay cache tampoco, retornar 503 con mensaje descriptivo.

### 2.2 Capas personalizadas

**Archivo nuevo:** `backend/lib/src/routes/capas_route.dart`

#### `GET /api/capas`
- Retorna lista de capas con metadata (sin geometrías). Acceso: todos los roles.

#### `GET /api/capas/{id}/geometrias`
- Retorna GeoJSON `FeatureCollection` con todas las geometrías de la capa.
- Acceso: todos los roles.

#### `POST /api/capas/upload`
- **Solo director.**
- Recibe `multipart/form-data`:
  - `nombre` (string, requerido)
  - `descripcion` (string, opcional)
  - `color` (string hex, opcional, default `#FF5722`)
  - `archivo` (file, requerido)

**Procesamiento de archivos:**

**KMZ:**
- KMZ = archivo ZIP con un `.kml` adentro.
- Descomprimir en memoria usando el package `archive`.
- Parsear el XML del KML con el package `xml`.
- Extraer `<Placemark>` con sus `<Point>`, `<LineString>`, `<Polygon>`.
- Convertir coordenadas KML (lon,lat,alt separados por coma) a geometrías WKT para PostGIS.

**SHP:**
- Requiere `gdal-bin` instalado en el contenedor Docker del backend (ver sección 3).
- Guardar el archivo `.shp` recibido en `/tmp/upload_{uuid}.shp`.
- Ejecutar via `Process.run`:
  ```
  ogr2ogr -f GeoJSON /tmp/out_{uuid}.geojson /tmp/upload_{uuid}.shp
  ```
- Leer el GeoJSON resultante y hacer INSERT en `geometrias_capa`.
- Limpiar archivos temporales después.

**GeoJSON:**
- Parsear directamente como JSON, iterar features, INSERT directo.

Retorna `{ "id": 5, "nombre": "Zona tsunami norte", "totalGeometrias": 12 }`.

#### `PATCH /api/capas/{id}`
- **Solo director.**
- Permite editar: `nombre`, `descripcion`, `color`, `opacidad`, `visible`.

#### `DELETE /api/capas/{id}`
- **Solo director.**
- DELETE en `capas_personalizadas` (CASCADE elimina `geometrias_capa`).

### 2.3 Registrar rutas en el router principal

En `backend/lib/src/server.dart`, montar las nuevas rutas:
```dart
..mount('/api/sismos', sismosRouter)
..mount('/api/capas', capasRouter)
```

---

## 3. Docker — Agregar GDAL al backend

**Archivo:** `backend/Dockerfile`

Agregar después de instalar dependencias Dart:
```dockerfile
RUN apt-get update \
  && apt-get install -y --no-install-recommends gdal-bin \
  && rm -rf /var/lib/apt/lists/*
```

---

## 4. Shared — Nuevos modelos DTO

**Archivo:** `shared/lib/src/models/sismo_dto.dart`

```dart
@freezed
class SismoDto with _$SismoDto {
  const factory SismoDto({
    required String id,
    required double magnitude,
    String? magType,
    String? place,
    required DateTime timeUtc,
    double? depthKm,
    required double latitude,
    required double longitude,
    String? alert,   // 'green'|'yellow'|'orange'|'red'|null
    int? tsunami,    // 0 o 1
    String? urlUsgs,
  }) = _SismoDto;
  factory SismoDto.fromJson(Map<String, dynamic> json) => _$SismoDtoFromJson(json);
}
```

**Archivo:** `shared/lib/src/models/capa_personalizada_dto.dart`

```dart
@freezed
class CapaPersonalizadaDto with _$CapaPersonalizadaDto {
  const factory CapaPersonalizadaDto({
    required int id,
    required String nombre,
    String? descripcion,
    required String color,
    required double opacidad,
    required bool visible,
    required String formato,
    required DateTime createdAt,
  }) = _CapaPersonalizadaDto;
  factory CapaPersonalizadaDto.fromJson(Map<String, dynamic> json) =>
      _$CapaPersonalizadaDtoFromJson(json);
}
```

Ejecutar `dart run build_runner build -d` en `shared/` después de agregar los modelos.

---

## 5. Flutter — UI del Visor

### 5.1 Nuevos providers (Riverpod)

**Archivo:** `app/lib/src/features/mapa/providers/visor_provider.dart`

```dart
// Estado de visibilidad de cada capa
@riverpod
class CapasVisibilidadNotifier extends _$CapasVisibilidadNotifier {
  // Map<String, bool> donde la key es el ID de la capa
  // Capas nativas: 'sismos', 'incendio', 'tsunami', 'plan_regulador',
  //                'camaras', 'reportes', 'patentes'
  // Capas personalizadas: 'custom_${id}'
}

// Provider de sismos (llama a GET /api/sismos)
@riverpod
Future<List<SismoDto>> sismosRecientes(SismosRecientesRef ref) async { ... }

// Provider de capas personalizadas
@riverpod
Future<List<CapaPersonalizadaDto>> capasPersonalizadas(CapasPersonalizadasRef ref) async { ... }
```

### 5.2 Panel lateral "Lista de Capas"

**Archivo:** `app/lib/src/features/mapa/widgets/panel_capas.dart`

Widget `PanelCapas` que imita el diseño del SENAPRED:
- Fondo oscuro (`Color(0xFF1E2327)`) con borde redondeado y sombra.
- Header con título "Lista de capas" y botones minimizar/cerrar.
- Secciones colapsables por grupo:
  - **Amenazas** → Sismos, Incendio Forestal, Tsunami
  - **Infraestructura** → Cámaras, Sedes, Luminarias
  - **Seguridad** → Zonas de Peligro, Reportes
  - **Municipal** → Plan Regulador, Patentes Comerciales
  - **Capas Personalizadas** → cargadas desde `capasPersonalizadasProvider`
- Por cada capa: `Checkbox` + nombre + botón `⋯` (opciones: zoom a capa, ver leyenda).
- Si el rol es `director`, mostrar botón `+` en la sección "Capas Personalizadas"
  para disparar el flujo de subida.

### 5.3 Panel "Galería de Mapas Base"

**Archivo:** `app/lib/src/features/mapa/widgets/panel_mapa_base.dart`

Widget con miniaturas para cambiar el tile layer del `flutter_map`:

| Nombre | URL tiles |
|---|---|
| CartoDB Voyager (actual) | `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png` |
| OpenStreetMap | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |
| Satélite (Esri) | `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}` |

Mostrar un checkmark sobre la miniatura activa. Cambiar el provider del tile layer al seleccionar.

### 5.4 Panel "Leyenda"

**Archivo:** `app/lib/src/features/mapa/widgets/panel_leyenda.dart`

Muestra la simbología de las capas **actualmente visibles**. Se actualiza reactivamente
via Riverpod cuando cambia `capasVisibilidadNotifier`.

Leyenda de sismos (por magnitud):
- 🔴 Mayor a 6.0 — Rojo
- 🟠 5.0 – 5.9 — Naranja
- 🟡 4.0 – 4.9 — Amarillo
- 🟢 Menor a 4.0 — Verde

Leyenda de capas personalizadas: mostrar un cuadro con el color de la capa.

### 5.5 Panel "Imprimir"

**Archivo:** `app/lib/src/features/mapa/widgets/panel_imprimir.dart`

Panel simple con:
- Campo de texto "Título del mapa"
- Selector de diseño: Letter / A4
- Selector de formato: JPG / PDF
- Botón "Imprimir" → capturar el widget del mapa con `RepaintBoundary` y `RenderRepaintBoundary`,
  exportar con el package `printing` o `screenshot`.

### 5.6 Barra inferior de íconos

**Archivo:** `app/lib/src/features/mapa/widgets/barra_visor.dart`

Barra flotante en la parte inferior del mapa con íconos circulares de colores distintos,
igual al diseño SENAPRED:

| Ícono | Color | Acción |
|---|---|---|
| `list` | Teal | Abrir/cerrar PanelCapas |
| `layers` | Verde | Capas activas (badge con conteo) |
| `map` | Naranja | Abrir PanelMapaBase |
| `print` | Azul | Abrir PanelImprimir |
| `info` | Gris | Abrir PanelAcercaDe |
| `download` | Verde oscuro | Descargar capa activa |
| `help` | Azul oscuro | Ayuda |

Navegación entre paneles con flechas `<` `>` para los paneles activos.

### 5.7 Capas en flutter_map

**Archivo:** `app/lib/src/features/mapa/widgets/mapa_widget.dart`

Dentro del `FlutterMap`, agregar capas condicionalmente según `capasVisibilidadNotifier`:

**Capa de Sismos:**
```dart
// Usar MarkerLayer con CircleAvatar
// Color del marcador según magnitud:
// mag >= 6.0 → Rojo, 5.0-5.9 → Naranja, 4.0-4.9 → Amarillo, < 4.0 → Verde
// Tamaño del marcador proporcional a la magnitud: radius = mag * 4
```

**Capas personalizadas:**
```dart
// Iterar geometrias_capa y pintar según tipo:
// Point → MarkerLayer
// LineString → PolylineLayer (color de la capa)
// Polygon → PolygonLayer (color de la capa con opacidad configurada)
```

### 5.8 Popups al tocar el mapa

Al hacer tap sobre un marcador de sismo, mostrar un `showModalBottomSheet` o popup con:
- Título: "Sismo M{mag} {magType}"
- Lugar: `place`
- Fecha/hora: `timeUtc` formateado a hora local chilena
- Profundidad: `{depthKm} km`
- Alerta PAGER: badge de color si `alert != null`
- Indicador de tsunami: ⚠️ si `tsunami == 1`
- Link "Ver en USGS" que abre `urlUsgs`

Al hacer tap sobre una geometría de capa personalizada, mostrar popup con:
- Nombre de la capa
- `nombre` del feature si existe
- Propiedades del JSONB en formato clave: valor

### 5.9 Coordenadas en tiempo real

En la esquina inferior izquierda del mapa, mostrar las coordenadas del centro del mapa
(o del puntero si es web) en formato: `-73.158 -37.089 Grados`

Usar `MapController` y `onPositionChanged` del `FlutterMap`.

### 5.10 Flujo de subida de capa (solo director)

**Archivo:** `app/lib/src/features/mapa/screens/subir_capa_screen.dart`

1. Botón `+` en PanelCapas abre un `showModalBottomSheet`.
2. Formulario con: nombre (requerido), descripción (opcional), color (color picker).
3. Botón "Seleccionar archivo" usa `file_picker` para filtrar `.kmz`, `.shp`, `.geojson`.
   - Para SHP: advertir que debe subirse un `.zip` con el `.shp`, `.dbf` y `.prj` juntos.
4. Botón "Subir" envía `multipart/form-data` a `POST /api/capas/upload`.
5. Mostrar `LinearProgressIndicator` durante la subida.
6. Al completar: invalidar `capasPersonalizadasProvider` para refrescar el panel.

---

## 6. Packages Flutter a agregar

En `app/pubspec.yaml`:

```yaml
dependencies:
  file_picker: ^8.0.0        # Selección de archivos KMZ/SHP/GeoJSON
  printing: ^5.12.0          # Exportar mapa a PDF/imagen
  screenshot: ^3.0.0         # Capturar widget del mapa
  flutter_colorpicker: ^1.1.0 # Color picker para capas personalizadas
```

En `backend/pubspec.yaml`:

```yaml
dependencies:
  archive: ^3.6.0   # Descomprimir KMZ (es un ZIP)
  xml: ^6.5.0       # Parsear KML
```

---

## 7. Orden de implementación sugerido

1. Migración SQL (tablas `capas_personalizadas`, `geometrias_capa`, `sismos_cache`)
2. Modelos DTO en `shared/` + `build_runner`
3. Endpoint `GET /api/sismos` con proxy USGS + cache PostgreSQL
4. Endpoint `GET /api/capas` y `GET /api/capas/{id}/geometrias`
5. Endpoint `POST /api/capas/upload` (primero KMZ, luego SHP)
6. Agregar GDAL al Dockerfile del backend
7. Providers Riverpod (`capasVisibilidad`, `sismosRecientes`, `capasPersonalizadas`)
8. `BarraVisor` con íconos y apertura de paneles
9. `PanelCapas` con checkboxes y secciones colapsables
10. `PanelMapaBase` con 3 tile layers
11. Capa de sismos en `flutter_map` con colores por magnitud
12. Popups de sismos y geometrías personalizadas
13. Capas personalizadas en `flutter_map` (Point/Line/Polygon)
14. `PanelLeyenda` reactivo
15. `PanelImprimir`
16. Flujo de subida de capa (director)
17. Coordenadas en tiempo real

---

## 8. Notas importantes

- **USGS no requiere API key ni autenticación.** Es REST puro.
- **Rate limiting USGS:** No hay límite documentado para uso normal, pero cachear en
  PostgreSQL es obligatorio para no saturar. TTL de 5 minutos es suficiente.
- **Lota coordinates:** latitude `-37.0894`, longitude `-73.1580`.
- **Radio de búsqueda sugerido:** 500 km cubre la zona sísmica del Biobío y zonas aledañas.
- **Los tiles de Esri (satélite) son gratuitos** para uso no comercial sin token.
- **`flutter_map` ya está en el proyecto.** No agregar versiones incompatibles.
- **Respetar el sistema de roles JWT existente** en todos los endpoints nuevos.
  Usar el middleware de autenticación ya implementado en el backend.
- **El package `archive` de Dart** soporta ZIP nativo sin dependencias nativas,
  ideal para descomprimir KMZ en memoria sin escribir a disco.
