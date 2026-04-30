# CLAUDE.md — SIGESPU Lota
> Documento rector del proyecto. Fuente de verdad para todas las sesiones de Claude Code.
> Última actualización: abril 2026

---

## 1. Contexto del proyecto

**SIGESPU Lota** — Sistema de Información Geoespacial de Seguridad Pública.

Sistema operativo interno para la **Dirección de Seguridad Pública** de la **Ilustre Municipalidad de Lota**, Chile (Región del Biobío).

### Qué es

Un GIS (Sistema de Información Geoespacial) operativo con mapa como pantalla principal, donde los funcionarios municipales pueden:

- Ver capas de información geoespacial de la comuna (patentes, zonas de peligro, infraestructura, Plan Regulador)
- Agregar elementos al mapa en terreno (puntos con GPS, polígonos dibujados)
- Reportar incidentes de seguridad pública y emergencias urbanas
- Consultar datos scrapeados automáticamente desde lotatransparente.cl
- Exportar informes en PDF
- Trabajar offline en emergencias (sin conexión a internet)

### Qué NO es

- No es una bitácora de turnos (eso era Bitácora Municipal v1, proyecto anterior)
- No es una app ciudadana (uso interno exclusivo de funcionarios municipales)
- No es un portal de datos abiertos
- No es un sistema de despacho de emergencias (solo registro y visualización)

### Por qué existe

Es la **segunda iteración** de Bitácora Municipal v1, la cual fue descartada por no responder a las necesidades reales de la Dirección de Seguridad Pública. SIGESPU nace como replanteamiento completo con enfoque GIS operativo, inspirado en el Visor Chile Preparado y el Censo 2024 INE.

### Marco legal

- **Ley 20.285**: Transparencia y acceso a información pública (justifica el scraping de lotatransparente.cl)
- **Ley 21.719**: Protección de datos personales (justifica retención máxima 2 años, audit log, disociación en exports)
- **Ley 18.695**: Orgánica Constitucional de Municipalidades (marco institucional)
- **Ley 21.180**: Transformación digital del Estado
- **Ley 21.663**: Datos geoespaciales del Estado

---

## 2. Stack tecnológico

### Frontend (un solo proyecto Flutter)

| Capa | Tecnología | Versión | Justificación |
|---|---|---|---|
| Framework | Flutter | 3.27+ | Compila a Android, iOS y Web desde un solo código |
| Lenguaje | Dart | 3.x | Null-safe, mismo lenguaje que backend |
| Estado | Riverpod | 2.x | Reactivo, testeable, mejor que Provider/Bloc para este caso |
| Routing | go_router | latest | Declarativo, deep links, web URL support |
| Mapa | flutter_map | latest | Leaflet para Flutter, OSM gratis, sin restricciones |
| Heatmap | flutter_map_heatmap | latest | Plugin de mapa de calor sobre flutter_map |
| Tiles offline | flutter_map_tile_caching | latest | Cacheo de tiles MBTiles para modo offline |
| BD local | drift | latest | ORM tipado Dart, SQLite en móvil y web |
| HTTP | dio | latest | Interceptores para JWT refresh automático en 401 |
| Auth storage | flutter_secure_storage | latest | Keychain iOS / Keystore Android / Encrypted Web |
| Conectividad | connectivity_plus | latest | Detecta cambios online/offline |
| GPS | geolocator | latest | Ubicación nativa multiplataforma |
| Cámara | image_picker | latest | Fotos en terreno |
| Iconos | lucide_icons | latest | Consistente con la maqueta de validación |
| Charts | fl_chart | latest | Gráficos para vista Resumen |
| PDF | printing + pdf | latest | Generación y descarga de informes |

### Backend (Dart/Shelf)

| Capa | Tecnología | Versión | Justificación |
|---|---|---|---|
| Framework | shelf + shelf_router | latest | Liviano, sin magia, Dart nativo |
| BD | postgres (driver Dart) | latest | Cliente nativo PostgreSQL |
| Cache | redis (paquete Dart) | latest | Cliente nativo Redis |
| Auth | dart_jsonwebtoken | latest | JWT con claims custom |
| Hash | bcrypt | latest | Cost 12 para passwords |
| Modelos | freezed + json_serializable | latest | Inmutabilidad, serialización segura |
| Logs | logger | latest | Logs estructurados para audit trail |
| Cron | cron | latest | Scheduling del scraper worker |

### Scraper (worker Dart independiente)

| Capa | Tecnología | Justificación |
|---|---|---|
| HTTP + parsing | http + html | Fetch y parsing HTML estático de lotatransparente.cl |
| Geocoder | Nominatim (OSM) vía HTTP | Gratuito, respetando 1 req/s |
| PDF parsing | syncfusion_flutter_pdf (free tier) | Para planes oficiales PDF |
| Storage | postgres | Inserts directos a BD compartida |

### Base de datos

| Componente | Tecnología |
|---|---|
| Motor | PostgreSQL 16 |
| Extensión GIS | PostGIS 3.4 |
| Búsqueda fuzzy | pg_trgm |
| UUIDs | uuid-ossp |

### Infraestructura

| Ambiente | Stack |
|---|---|
| **Desarrollo local** | Docker Compose (postgres, redis, backend, nginx con SSL self-signed) |
| **Producción (Sprint 5+)** | Hetzner CX22 VPS + Ubuntu 24.04 + Docker Compose + Nginx + Let's Encrypt + Cloudflare Free |

### Tiles del mapa

- **Online**: CartoDB Voyager (`{s}.basemaps.cartocdn.com`) — gratis, sin Referer requerido, sin restricciones de dominio
- **Offline**: tiles MBTiles generados con tilemaker desde OSM de la zona de Lota, empaquetados en assets de la app

---

## 3. Estructura del repositorio (monorepo)

```
sigespu/
├── README.md                          # Inicio rápido
├── CLAUDE.md                          # Este archivo
├── docker-compose.yml                 # Stack desarrollo local
├── docker-compose.prod.yml            # Stack producción
├── .env.example                       # Variables de entorno (nunca commitear .env)
├── .gitignore
├── .editorconfig
│
├── backend/                           # API Dart/Shelf
│   ├── bin/server.dart                # Entry point
│   ├── lib/src/
│   │   ├── auth/                      # JWT, refresh rotation, blacklist
│   │   ├── database/                  # Pool Postgres, cliente Redis
│   │   ├── middleware/                # auth, rate_limit, logging, cors
│   │   ├── modules/
│   │   │   ├── capas/                 # Puntos de interés, zonas custom
│   │   │   ├── reportes/              # Reportes de seguridad
│   │   │   ├── zonas_peligro/         # Polígonos de peligro
│   │   │   ├── patentes/              # Datos scrapeados + fiscalización
│   │   │   ├── permisos_dom/          # Permisos de obras
│   │   │   ├── transito/              # Decretos de tránsito
│   │   │   ├── organizaciones/        # JJ.VV. y organizaciones sociales
│   │   │   ├── turnos/                # Módulo de turnos (de v1)
│   │   │   ├── sync/                  # Endpoint de sync offline
│   │   │   ├── heatmap/               # Generación dinámica de datos de calor
│   │   │   └── solicitudes/           # Solicitudes de acceso operativo
│   │   └── utils/
│   │       ├── rut_validator.dart     # Validador RUT chileno
│   │       └── geo_helpers.dart       # Helpers geoespaciales
│   ├── migrations/
│   │   ├── 001_initial_schema.sql     # Schema completo
│   │   └── 002_seed_director.sql      # Usuario director inicial
│   ├── test/
│   ├── Dockerfile
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── app/                               # Flutter: Android + iOS + Web
│   ├── lib/
│   │   ├── main.dart
│   │   └── src/
│   │       ├── config/
│   │       │   ├── theme.dart         # Paleta oficial
│   │       │   ├── router.dart        # go_router con rutas y guards
│   │       │   └── constants.dart     # URLs, timeouts, dominios permitidos
│   │       ├── core/
│   │       │   ├── errors/            # Tipos de error tipados
│   │       │   └── extensions/        # Dart extensions útiles
│   │       ├── data/
│   │       │   ├── local/             # Drift (SQLite)
│   │       │   │   ├── database.dart  # Definición de tablas Drift
│   │       │   │   └── daos/          # Data Access Objects por entidad
│   │       │   ├── remote/            # API client y repositories
│   │       │   │   ├── api_client.dart
│   │       │   │   └── repositories/
│   │       │   └── sync/              # Sync service offline
│   │       ├── domain/                # Entities + use cases
│   │       └── presentation/
│   │           ├── auth/              # Login, solicitud acceso
│   │           ├── map/               # Mapa principal (pantalla por defecto)
│   │           │   ├── map_screen.dart
│   │           │   ├── layers/        # Widgets por capa
│   │           │   ├── layer_toggle_sheet.dart
│   │           │   └── heatmap_overlay.dart
│   │           ├── resumen/           # Vista dashboard KPIs
│   │           ├── tabla/             # Vista tabla con filtros
│   │           ├── scraping/          # Vista datos scrapeados
│   │           ├── reportes/          # CRUD reportes
│   │           ├── solicitudes/       # Panel director: aprobar/rechazar
│   │           └── shared/            # Widgets reutilizables
│   ├── assets/
│   │   ├── tiles/                     # MBTiles de Lota (offline)
│   │   ├── plan_regulador/            # GeoJSON sectores S-X
│   │   └── icons/                     # SVG de tipos de elementos
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── scraper/                           # Worker Dart (Sprint 1)
│   ├── bin/scraper.dart
│   ├── lib/
│   │   ├── sources/
│   │   │   ├── patentes_mensuales.dart    # ig=164
│   │   │   ├── permisos_dom.dart          # ig=172
│   │   │   ├── decretos_transito.dart     # ig=269
│   │   │   ├── organizaciones.dart        # ig=351, 424
│   │   │   └── plan_emergencia_pdf.dart   # PDFs planes oficiales
│   │   ├── geocoder/
│   │   │   └── nominatim_client.dart
│   │   ├── normalizers/
│   │   │   └── direccion_lota.dart        # Normaliza direcciones locales
│   │   └── scheduler/
│   │       └── cron.dart                  # 03:00 AM diario
│   ├── Dockerfile
│   └── pubspec.yaml
│
├── shared/                            # Modelos compartidos (Dart package)
│   ├── pubspec.yaml
│   └── lib/src/models/                # DTOs compartidos backend ↔ app
│
├── qgis/                              # Trabajo GIS
│   ├── plan_regulador_lota.qgz        # Proyecto QGIS
│   └── exports/                       # GeoJSON de sectores
│
├── docs/
│   ├── arquitectura.md
│   ├── schema.md
│   ├── stack.md
│   ├── sync_protocol.md
│   └── despliegue.md
│
└── nginx/
    ├── Dockerfile
    └── conf/default.conf
```

---

## 4. Modelo de acceso y roles

### Dominios de email permitidos

Solo pueden registrarse usuarios con estos dominios institucionales:

```dart
const allowedDomains = ['lota.cl', 'munilota.cl'];
```

Cualquier otro dominio → rechazar en `POST /auth/register` con:
```json
{ "error": "Solo funcionarios municipales de Lota pueden registrarse" }
```

### Tres niveles de acceso

| Nivel | `nivel_acceso` | Quién | Capacidades |
|---|---|---|---|
| **Visitante municipal** | `visitante` | Cualquier @lota.cl o @munilota.cl que se registra | Ver mapa, ver capas, descargar PDF. Solo lectura |
| **Operativo** | `operativo` | Visitante aprobado por el Director | Todo lo anterior + agregar elementos al mapa, crear reportes, dibujar zonas |
| **Director** | `director` | Asignado por seed/migración, nunca por API | Todo + aprobar/rechazar solicitudes, gestionar usuarios |

### Flujo de solicitud de acceso operativo

```
Registro con @lota.cl o @munilota.cl
        ↓
Usuario entra como Visitante (lectura)
        ↓
Banner: "Solicitar acceso operativo"
        ↓ (requiere: nombre, cargo, dirección de dependencia municipal)
POST /auth/solicitar-acceso
        ↓
Banner cambia a: "Solicitud en revisión" (botón deshabilitado para siempre)
        ↓
Director ve lista en GET /auth/solicitudes
        ↓
PUT /auth/solicitudes/:id → { accion: "aprobar" | "rechazar" }
        ↓ (si aprueba)
nivel_acceso cambia a 'operativo' en tabla usuarios
        ↓
Usuario recibe notificación en app
```

**Regla crítica**: la solicitud es una sola vez por cuenta. Si ya existe una solicitud (en cualquier estado), el endpoint devuelve error. Si fue rechazada, el funcionario debe contactar al Director directamente.

### Seed inicial obligatorio

En `migrations/002_seed_director.sql`:

```sql
INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'director@lota.cl',
  'Director Seguridad Pública',
  '$2b$12$...', -- bcrypt de 'Admin2026!', cost 12
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
```

El usuario director NO puede ser degradado ni eliminado desde la API.

---

## 5. Schema de base de datos

### Convenciones generales

- PK siempre `UUID DEFAULT uuid_generate_v4()`
- `created_at TIMESTAMPTZ DEFAULT NOW()` en todas las tablas
- `updated_at TIMESTAMPTZ` con trigger automático donde aplique
- Índices `GIST` en todas las columnas de tipo `geometry`
- FK con `ON DELETE CASCADE` solo donde la entidad hija no tiene sentido sin la padre
- `ON DELETE SET NULL` para referencias auditables (no se borra el historial)

### Tablas principales

#### `usuarios`
```sql
id, email, nombre, password_hash,
nivel_acceso TEXT CHECK IN ('visitante','operativo','director'),
solicitud_operativo TEXT CHECK IN ('pendiente','aprobada','rechazada') DEFAULT NULL,
solicitud_fecha, solicitud_cargo, solicitud_direccion_municipal,
solicitud_revisada_por UUID REFERENCES usuarios(id),
solicitud_revisada_at,
activo BOOLEAN DEFAULT true,
created_at, updated_at
```

#### `refresh_tokens`
```sql
id, usuario_id, token_hash, familia UUID,
expira_en, revocado BOOLEAN DEFAULT false, created_at
```
Familia + reuse detection: si se detecta reuso de refresh token, se revocan TODOS los tokens de esa familia.

#### `sectores_plan_regulador`
```sql
id, codigo ('S-2','S-3','S-4','S-5','Centro'), nombre, sector_padre,
geom GEOMETRY(POLYGON,4326),
usos_permitidos JSONB, usos_prohibidos JSONB,
fuente TEXT, vigente BOOLEAN DEFAULT true, created_at
-- INDEX GIST en geom
```

#### `puntos_interes`
```sql
id, tipo TEXT CHECK IN (
  'centro_acopio','sede_comunitaria','infraestructura',
  'luminaria','camara_cctv',
  'arbol_caido','poste_caido','sector_sin_luz','cable_colgando',
  'semaforo_dañado','socavon','fuga_agua','microbasural','otro'
),
nombre, descripcion, direccion,
geom GEOMETRY(POINT,4326),
metadata JSONB,           -- capacidad, teléfono, etc. según tipo
estado TEXT DEFAULT 'activo',
origen TEXT DEFAULT 'manual',  -- manual | scraping | importacion
fuente_origen TEXT,
created_by UUID REFERENCES usuarios(id),
created_at, updated_at
-- INDEX GIST en geom, INDEX en tipo, INDEX en estado
```

#### `reportes_seguridad`
```sql
id, tipo TEXT CHECK IN (
  'robo','vandalismo','accidente','violencia',
  'drogas','riña','emergencia_medica','incendio','otro'
),
geom GEOMETRY(POINT,4326),
direccion, descripcion, severidad INT CHECK (1-5),
fecha_evento TIMESTAMPTZ,
fotos TEXT[] DEFAULT '{}',
estado TEXT DEFAULT 'reportado',  -- reportado|verificado|derivado|cerrado|falso
derivado_a TEXT,
reportado_por UUID REFERENCES usuarios(id),
verificado_por UUID REFERENCES usuarios(id),
created_at, updated_at
-- INDEX GIST en geom, INDEX en fecha_evento, INDEX en tipo
```

#### `zonas_peligro`
```sql
id, nombre,
geom GEOMETRY(POLYGON,4326),
nivel_riesgo INT CHECK (1-5),
tipo_riesgo TEXT CHECK IN (
  'drogas','robos','vivienda_ilegal','vandalismo',
  'riña','sin_iluminacion','accidentes','microbasural','otro'
),
descripcion, horario_critico TEXT,
vigente_desde DATE, vigente_hasta DATE,
created_by UUID REFERENCES usuarios(id),
created_at, updated_at
-- INDEX GIST en geom
```

#### `zonas_personalizadas`
```sql
id, nombre, categoria TEXT, color_hex TEXT,
nivel INT CHECK (1-5), descripcion, vigencia DATE,
geom GEOMETRY(POLYGON,4326),
created_by UUID REFERENCES usuarios(id), created_at
-- INDEX GIST en geom
```

#### `patentes_comerciales` (scraping)
```sql
id, numero_decreto INT, fecha_decreto DATE, fecha_publicacion DATE,
tipo_patente TEXT, rut TEXT, razon_social TEXT, giro TEXT,
direccion_raw TEXT, direccion_normalizada TEXT,
geom GEOMETRY(POINT,4326),
geocoding_confianza TEXT CHECK IN ('alta','media','baja','fallo'),
estado_inferido TEXT DEFAULT 'vigente_esperado',
ultima_verificacion_terreno DATE,
verificado_por UUID REFERENCES usuarios(id),
observaciones TEXT,
url_fuente TEXT, scraped_at TIMESTAMPTZ, raw_data JSONB,
created_at, updated_at
UNIQUE(numero_decreto, fecha_decreto)
-- INDEX GIST en geom, GIN en direccion_normalizada (pg_trgm)
```

#### `permisos_dom` (scraping)
```sql
id, numero_permiso TEXT, tipo TEXT, descripcion TEXT,
direccion_raw TEXT, geom GEOMETRY(POINT,4326),
fecha_otorgamiento DATE, estado TEXT,
url_fuente TEXT, scraped_at TIMESTAMPTZ, raw_data JSONB
-- INDEX GIST en geom
```

#### `decretos_transito` (scraping)
```sql
id, numero_decreto TEXT, tipo TEXT, descripcion TEXT,
direccion_afectada TEXT,
fecha_inicio DATE, fecha_fin DATE, estado TEXT,
url_fuente TEXT, scraped_at TIMESTAMPTZ
```

#### `organizaciones_sociales` (scraping)
```sql
id, numero_personalidad TEXT, tipo TEXT, nombre TEXT,
direccion TEXT, geom GEOMETRY(POINT,4326),
representante TEXT, rut_representante TEXT,
vigencia_hasta DATE, sector TEXT,
url_fuente TEXT, scraped_at TIMESTAMPTZ
-- INDEX GIST en geom
```

#### `verificaciones_terreno`
```sql
id, entidad_tipo TEXT, entidad_id UUID,
verificado_por UUID REFERENCES usuarios(id),
fecha_verificacion TIMESTAMPTZ DEFAULT NOW(),
geom_verificacion GEOMETRY(POINT,4326),
estado_reportado TEXT, observaciones TEXT, fotos TEXT[]
-- INDEX en (entidad_tipo, entidad_id)
```

#### `turnos`
```sql
id, usuario_id UUID REFERENCES usuarios(id),
inicio TIMESTAMPTZ, fin TIMESTAMPTZ,
geom_inicio GEOMETRY(POINT,4326), geom_fin GEOMETRY(POINT,4326),
ruta GEOMETRY(LINESTRING,4326),
estado TEXT DEFAULT 'en_curso',  -- en_curso|finalizado|cancelado
observaciones TEXT, created_at
-- INDEX GIST en ruta
```

#### `sync_log`
```sql
id, usuario_id UUID REFERENCES usuarios(id),
entidad TEXT, accion TEXT,  -- create|update|delete
entidad_id UUID, payload JSONB,
client_timestamp TIMESTAMPTZ, server_timestamp TIMESTAMPTZ DEFAULT NOW(),
conflict_resolution TEXT  -- null|last_write_wins|server_wins
```

#### `audit_log`
```sql
id, usuario_id UUID REFERENCES usuarios(id),
accion TEXT, entidad TEXT, entidad_id UUID,
ip_address TEXT, user_agent TEXT,
payload_antes JSONB, payload_despues JSONB,
created_at TIMESTAMPTZ DEFAULT NOW()
```
Requerido por Ley 21.719. Retención máxima 2 años con purga automática.

---

## 6. Autenticación y seguridad

### JWT

- **Access token**: 15 minutos de TTL, almacenado en memoria (Riverpod state, nunca localStorage)
- **Refresh token**: 7 días de TTL, almacenado en `flutter_secure_storage`
- **Refresh rotation**: cada uso del refresh genera un nuevo par, el anterior se invalida
- **Reuse detection**: si se detecta uso de refresh token ya rotado → revocación de toda la familia → logout forzado
- **Blacklist**: access tokens revocados en Redis con TTL igual al tiempo restante
- **Claims mínimos**: solo `user_id`, `nivel_acceso`, `iat`, `exp`

### Bcrypt

- Cost: 12
- Nunca menos de 12 en producción

### Rate limiting (Redis)

- Endpoints generales: 100 req/min por IP
- Endpoints `/auth/*`: 20 req/min por IP
- Endpoint `/auth/login`: 5 intentos fallidos → lock progresivo (5 min, 30 min, 24h)
- Implementado con contador en Redis, key: `ratelimit:{ip}:{endpoint}`

### Nginx hardening (producción)

```nginx
# Headers de seguridad obligatorios
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin
Content-Security-Policy: default-src 'self'; ...

# Protección contra Slowloris
client_body_timeout 10;
client_header_timeout 10;
keepalive_timeout 5 5;
send_timeout 10;

# Tamaño máximo de body (evita uploads abusivos)
client_max_body_size 10m;
```

### Anti-DDoS (producción)

- **Cloudflare Free**: DDoS L7, CDN, DNS proxy
- **fail2ban** en VPS: bloqueo automático de IPs abusivas
- **Nginx rate limiting**: `limit_req_zone` por IP

---

## 7. Fuentes de scraping

| Fuente | URL | `ig` | Frecuencia | Tablas destino |
|---|---|---|---|---|
| Patentes comerciales mensuales | lotatransparente.cl | 164 | Diaria 03:00 | `patentes_comerciales` |
| Patentes por categoría semestral | lotatransparente.cl | 103 | Semanal | `patentes_comerciales` |
| Permisos Dirección de Obras | lotatransparente.cl | 172 | Diaria 03:10 | `permisos_dom` |
| Decretos de tránsito | lotatransparente.cl | 269 | Diaria 03:20 | `decretos_transito` |
| Organizaciones sociales vigentes | lotatransparente.cl | 351 | Semanal | `organizaciones_sociales` |
| Organizaciones sociales + registro | lotatransparente.cl | 424 | Semanal | `organizaciones_sociales` |
| Plan Comunal de Emergencia (PDF) | lotatransparente.cl | 385 | Manual inicial | `puntos_interes` |
| Comodatos municipales | lotatransparente.cl | 236 | Semanal | `puntos_interes` |

### Reglas del scraper

- **User-Agent obligatorio**: `SigespuLota/1.0 (+contacto@munilota.cl)`
- **Rate**: máximo 1 req/s (Nominatim) y 2 req/s (lotatransparente.cl)
- **Cache en Redis**: snapshot anterior de cada fuente, comparar diff antes de insertar
- **Tolerancia a fallos**: si falla una fuente, las demás continúan. Alerta al admin si falla 3 días seguidos
- **Geocoding**: Nominatim público con cache en Redis 30 días. Tasa de fallo esperada ~20-30% para direcciones locales atípicas
- **Bandeja de no ubicadas**: patentes sin geocoding van a tabla temporal para revisión manual por funcionario operativo
- **Justificación legal**: Ley 20.285 obliga a publicar esta información. El scraping es acceso a datos de publicación obligatoria

### Normalización de direcciones de Lota

Lota tiene nomenclatura de calle atípica. El normalizer en `scraper/lib/normalizers/direccion_lota.dart` debe manejar:

```
"P.A. Cerda 808" → "Pedro Aguirre Cerda 808, Lota"
"Pabellón 4 S/N" → null (sin geocoding posible, va a bandeja)
"Pob. G. Mistral" → "Población Gabriela Mistral, Lota"
"Vista Hermosa 1199" → "Vista Hermosa 1199, Lota, Chile"
"S-1 Polvorín" → null (sector sin dirección, va a bandeja)
```

---

## 8. Mapa y capas

### Proveedor de tiles

**CartoDB Voyager** — No requiere API key, no requiere Referer, gratis hasta 75.000 map views/mes:

```dart
TileLayer(
  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
  subdomains: ['a', 'b', 'c', 'd'],
  maxZoom: 19,
  userAgentPackageName: 'cl.lota.sigespu',
)
```

### Centro y zoom por defecto

```dart
const LatLng LOTA_CENTER = LatLng(-37.0896, -73.1584);
const double LOTA_ZOOM = 14;
```

### Capas del sistema (toggleables)

| Capa | Key | Color | Tabla fuente |
|---|---|---|---|
| Centros de acopio | `centro_acopio` | #EA580C | `puntos_interes` |
| Sedes comunitarias | `sede_comunitaria` | #16A34A | `puntos_interes` |
| Zonas de peligro | `zona_peligro` | #B91C1C | `zonas_peligro` |
| Reportes seguridad | `reporte` | #EF4444 | `reportes_seguridad` |
| Patentes comerciales | `patente` | #D97706 | `patentes_comerciales` |
| Infraestructura pública | `infraestructura` | #1E3A8A | `puntos_interes` |
| Plan Regulador | `plan_regulador` | #CA8A04 | `sectores_plan_regulador` (GeoJSON local) |
| Permisos obras | `permiso_dom` | #2563EB | `permisos_dom` |
| Decretos tránsito | `decreto_transito` | #7C3AED | `decretos_transito` |
| Organizaciones sociales | `organizacion` | #059669 | `organizaciones_sociales` |
| Incidentes urbanos | `incidente_urbano` | #92400E | `puntos_interes` |
| Zonas personalizadas | `zona_custom` | variable | `zonas_personalizadas` |

### Mapa de calor

- Fuente de datos: `reportes_seguridad` + `zonas_peligro`
- Peso por nivel de riesgo/severidad (1-5 normalizado a 0.2-1.0)
- Filtrable por tipo y rango de fechas
- Endpoint: `GET /api/heatmap?desde=&hasta=&tipo=`
- Responde array de `[lat, lng, peso]`

### Tipos de elementos para agregar

Agrupados en 4 categorías con íconos del catálogo Lucide:

**Infraestructura comunitaria**: `centro_acopio`, `sede_comunitaria`, `infraestructura`

**Seguridad pública**: `zona_peligro`, `reporte_robo`, `reporte_vandalismo`, `reporte_accidente`

**Incidentes urbanos**: `arbol_caido`, `poste_caido`, `sector_sin_luz`, `cable_colgando`, `semaforo_dañado`, `socavon`, `fuga_agua`, `microbasural`

**Fiscalización y cobertura**: `patente`, `luminaria`, `camara_cctv`

### Sugerencias inteligentes al agregar

Cuando el funcionario abre el modal de agregar, se hace una query de proximidad (radio 5-50m según tipo) contra la BD local (Drift) buscando coincidencias:

- Tipo `patente` → busca en `patentes_comerciales` cercanas
- Tipo `zona_peligro` → busca en `zonas_peligro` cercanas
- Si hay match → card de sugerencia no intrusiva con datos pre-cargados
- Funcionario puede "Usar datos" o "Descartar"
- Si usa datos → se crea `verificacion_terreno` vinculada

---

## 9. Offline-first

### Estrategia

- **Crítico siempre local**: centros de acopio, sedes comunitarias, infraestructura pública, zonas de peligro, Plan Regulador, patentes (últimos 12 meses). Todo en Drift (SQLite).
- **Tiles pre-descargados**: zona de Lota completa, zoom 10-17, ~80-150 MB, se cachean en primer login.
- **Reportes offline**: si no hay red al crear un reporte, va a cola local (`sync_queue` en Drift). Al volver la conexión, el `SyncService` lo sube automáticamente.
- **Datos frescos que requieren red**: scraping de patentes nuevas, alertas externas, estado de cámaras en tiempo real. Muestran timestamp "actualizado hace X horas" y badge de advertencia si están desactualizados.

### SyncService

- Detecta cambios de conectividad con `connectivity_plus`
- Al recuperar conexión: procesa cola de pendientes en orden FIFO
- Conflicto: gana `last_write_wins` por timestamp del servidor. Suficiente para este caso.
- Si un elemento pendiente falla al sincronizar: retry con backoff exponencial (1s, 5s, 30s, 5min)
- Elemento con 3 fallos consecutivos: queda marcado como "error de sync" y se notifica al usuario

### Endpoint de sync

```
POST /api/sync
Body: { elementos: [...], client_last_sync: timestamp }
Response: { 
  server_updates: [...],  // cambios del servidor más nuevos que client_last_sync
  accepted: [...],        // IDs aceptados sin conflicto
  conflicted: [...]       // IDs con conflicto (server_wins aplicado)
}
```

---

## 10. Paleta de colores y diseño

### Paleta oficial SIGESPU Lota

```dart
// Naranjo institucional SIGESPU
const orange600 = Color(0xFFEA580C);
const orange700 = Color(0xFFC2410C);
const orange100 = Color(0xFFFFEDD5);
const orange50  = Color(0xFFFFF7ED);

// Azul municipal
const blue800   = Color(0xFF1E3A8A);
const blue900   = Color(0xFF1E293B);

// Stone (grises neutros - base de la UI)
const stone900  = Color(0xFF1C1917);
const stone800  = Color(0xFF292524);
const stone700  = Color(0xFF44403C);
const stone600  = Color(0xFF57534E);
const stone500  = Color(0xFF78716C);
const stone400  = Color(0xFFA8A29E);
const stone300  = Color(0xFFD6D3D1);
const stone200  = Color(0xFFE7E5E4);
const stone100  = Color(0xFFF5F5F4);
const stone50   = Color(0xFFFAFAF9);

// Semánticos
const greenSuccess = Color(0xFF15803D);
const redDanger    = Color(0xFFB91C1C);
const amberWarning = Color(0xFFCA8A04);
```

### Referencia visual

La maqueta HTML en `docs/mockup/sigespu-lota-maqueta.html` es la referencia visual aprobada para la UX. No reproducirla exactamente en código Flutter, pero respetar la estructura: header con 4 modos (Mapa/Resumen/Tabla/Scraping), sidebar colapsable, FAB group flotante.

---

## 11. Convenciones de código

### Dart/Flutter

- **Null safety**: siempre. Nunca usar `!` sin justificación comentada.
- **Nomenclatura**: `camelCase` para variables y métodos, `PascalCase` para clases, `snake_case` para archivos.
- **Imports**: ordenar en 3 bloques separados por línea vacía: (1) dart:, (2) package:, (3) relativos.
- **Riverpod**: un provider por archivo. Nombre del archivo = nombre del provider en snake_case.
- **Freezed**: usar para todas las entidades de dominio y DTOs.
- **Métodos largos**: si supera 40 líneas, extraer a función/clase separada.
- **Comments**: solo cuando el código no es autoexplicativo. No comentar lo obvio.

### SQL

- **Nombres de tabla**: `snake_case`, plural.
- **Nombres de columna**: `snake_case`.
- **Índices**: prefijo `idx_` + nombre_tabla + columna(s).
- **Constraints**: prefijo `ck_` para check, `fk_` para foreign key, `uq_` para unique.

### Commits (Conventional Commits)

```
feat: agregar endpoint de solicitud de acceso operativo
fix: corregir geocoding de direcciones con pabellón
chore: actualizar dependencias Flutter
docs: actualizar CLAUDE.md con modelo de roles
test: agregar tests para refresh token reuse detection
refactor: extraer lógica de sync a SyncService
```

### Branches

```
main          # producción, protegida
develop       # integración, PR target
feat/*        # features nuevas
fix/*         # bugfixes
chore/*       # mantenimiento
```

---

## 12. Estado de sprints

| Sprint | Estado | Descripción |
|---|---|---|
| Sprint 0 | 🔄 En progreso | Repo, Docker, auth, schema BD |
| Sprint 1 | ⏳ Pendiente | Scraper patentes + geocoder |
| Sprint 2 | ⏳ Pendiente | App Flutter base + mapa + capas |
| Sprint 3 | ⏳ Pendiente | Reportes, zonas, offline sync |
| Sprint 4 | ⏳ Pendiente | App móvil nativa + cámara |
| Sprint 5 | ⏳ Pendiente | Hardening + despliegue VPS |

---

## 13. Decisiones de arquitectura (registro de ADRs)

### ADR-001: Flutter Web + Flutter Mobile = mismo código

**Decisión**: usar Flutter para web y móvil desde el mismo codebase.

**Razones**: un solo lenguaje (Dart), un solo set de modelos compartidos con el backend, la mitad del trabajo de UI, la mitad de la mantención.

**Trade-off**: el bundle web de Flutter pesa más que un sitio en React/Astro. Para uso interno municipal con ~50 usuarios concurrentes, es completamente aceptable.

### ADR-002: Dart/Shelf en backend

**Decisión**: backend en Dart/Shelf en lugar de Node.js, Go, o Python.

**Razones**: mismo lenguaje que el frontend (reutilización de modelos con el paquete `shared/`), equipo de desarrollo de una sola persona, overhead mínimo de Shelf, suficiente performance para la escala del proyecto.

### ADR-003: PostgreSQL + PostGIS en lugar de MongoDB o SQLite

**Decisión**: PostgreSQL con extensión PostGIS como única fuente de verdad.

**Razones**: consultas geoespaciales nativas (`ST_DWithin`, `ST_Distance`, heatmap clustering), ACID, joins eficientes, extensión `pg_trgm` para búsqueda fuzzy de direcciones.

### ADR-004: CartoDB Voyager en lugar de Google Maps

**Decisión**: tiles de CartoDB Voyager sobre OpenStreetMap.

**Razones**: completamente gratuito, sin API key, sin restricciones de dominio o Referer, funciona desde `file://` y `localhost`, 75.000 map views/mes gratis. Google Maps cobra por carga de mapa y tiene restricciones en su SDK Flutter para offline.

### ADR-005: Drift (SQLite) para offline en lugar de ObjectBox o Hive

**Decisión**: Drift como ORM local para el modo offline.

**Razones**: soporte nativo para Flutter Web y móvil desde el mismo paquete, migraciones tipadas, queries SQL directas cuando es necesario, bien mantenido por la comunidad Flutter.

### ADR-006: Monorepo con carpetas

**Decisión**: un solo repositorio con carpetas `backend/`, `app/`, `scraper/`, `shared/`.

**Razones**: el paquete `shared/` puede ser importado por `backend/` y `app/` como dependencia local sin publicar a pub.dev. Simplifica la gestión de cambios que afectan múltiples capas.

### ADR-007: Scraping de lotatransparente.cl

**Decisión**: scraping de datos públicos en lugar de esperar API oficial o acceso a base de datos municipal.

**Razones**: lotatransparente.cl es HTML estático (no JS rendering), sin anti-bot, URLs predecibles. La Ley 20.285 obliga al municipio a publicar esta información, por lo que es acceso legítimo a datos de publicación obligatoria.

---

## 14. Información de contexto (Lota)

- **Coordenadas centro**: -37.0896, -73.1584
- **Zoom recomendado**: 14 para vista comunal, 17 para terreno
- **Sectores Plan Regulador relevantes**: S-2 (Residencial Los Aromos), S-3 (Mixto Los Aromos), S-4 (Equipamiento), S-5 (Vivienda Periférica), Centro Histórico
- **Fuente oficial del Plan Regulador**: MPR-4 Los Aromos, Dirección de Obras Municipales, 2002
- **Portal de transparencia**: https://www.lotatransparente.cl
- **Sitio municipal**: https://lota.cl
- **Dirección Municipalidad**: Pedro Aguirre Cerda 302, Lota
- **Dependencia cliente**: Dirección de Seguridad Pública

### Abreviaciones locales frecuentes en direcciones

```
P.A. Cerda / P.A.C. → Pedro Aguirre Cerda
Pob. G. Mistral      → Población Gabriela Mistral
Mon. Fuenzalida      → Monseñor Fuenzalida
Pabellón N           → Pabellón [N] (sector histórico minero)
Lota Alto            → sector alto de la ciudad
```

---

## 15. Instrucciones para Claude Code

**Antes de escribir cualquier código:**
1. Lista los archivos que vas a crear/modificar
2. Explica brevemente el propósito de cada cambio
3. Espera confirmación

**Nunca:**
- Crear archivos fuera de la estructura definida en §3
- Agregar dependencias no listadas en §2 sin preguntar
- Usar `dynamic` en Dart sin comentar por qué
- Hardcodear URLs, credenciales o IPs

**Siempre:**
- Usar `freezed` + `json_serializable` para modelos
- Agregar `// TODO(sprint-N):` cuando algo queda pendiente para otro sprint
- Seguir las convenciones de commits del §11
- Actualizar este CLAUDE.md si tomas una decisión de arquitectura nueva (agregar en §13)
