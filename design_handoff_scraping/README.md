# Handoff · Scraping / Transparencia Pública — SIGESPU Lota

> Implementación de **dos vistas** de la pestaña **Scraping**: escritorio (web) y móvil.
> Esta carpeta contiene las **referencias de diseño en HTML** (prototipos React/JSX) y este documento con las especificaciones exactas para reproducirlas en tu codebase.

---

## ⚠️ Léeme primero

1. **Los archivos `.jsx` y `.html` adjuntos son referencias de diseño**, no código de producción. No copies clases, estilos inline ni componentes uno a uno. Tu tarea es **reproducir el diseño en tu codebase actual** usando los componentes, librería de íconos, sistema de tipografía y patrones de estado que ya tienes.
2. **Usa TUS íconos nativos.** El prototipo usa un set propio (`window.Icons.*` definido en `icons.jsx`) para previsualizar — no es la librería final. En tu app reemplaza cada referencia por el ícono equivalente de la librería que ya uses (lucide-react, heroicons, material-symbols, react-icons, etc.). Más abajo hay una tabla de mapeo.
3. **Fidelidad: alta (hi-fi).** Los colores, espaciados, tamaños tipográficos y radios son finales. Respétalos al pixel cuando tu sistema de diseño lo permita; si tu app ya tiene tokens equivalentes, úsalos.
4. **Datos de ejemplo.** Las filas con razón social, RUT, etc. son fixtures. Conéctalos a tu API/store real.

---

## Tabla de contenido

1. [Tokens de diseño](#1-tokens-de-diseño)
2. [Mapeo de íconos (reemplazar con los tuyos)](#2-mapeo-de-íconos-reemplazar-con-los-tuyos)
3. [Vista 1 · Web — Sidebar + KPIs + Tabla + Mapa](#3-vista-1--web-sidebar--kpis--tabla--mapa)
4. [Vista 2 · Móvil — KPI strip + Lista densa](#4-vista-2--móvil-kpi-strip--lista-densa)
5. [Modelo de datos](#5-modelo-de-datos)
6. [Estados e interacciones](#6-estados-e-interacciones)
7. [Lista de archivos en este bundle](#7-lista-de-archivos-en-este-bundle)

---

## 1. Tokens de diseño

Todo el sistema vive sobre `tokens.css`. Si tu app ya tiene tokens equivalentes, mapéalos. Si no, define éstos.

### Color — Marca (rust / orange)
| Token  | Hex     | Uso                                                  |
| ------ | ------- | ---------------------------------------------------- |
| `--or5` | `#F97316` | gradiente, fill secundario                          |
| `--or6` | `#EA580C` | **primario** (botones, pills activas, pin de mapa) |
| `--or7` | `#C2410C` | hover, texto sobre fondo claro                      |
| `--or1` | `#FFF7ED` | fondo de selección, fondos suaves                  |
| `--or2` | `#FFEDD5` | badges, fill de progreso                             |
| `--or3` | `#FED7AA` | bordes de pills naranja                              |

### Color — Neutros (stone)
| Token  | Hex     |
| ------ | ------- |
| `--s50`  | `#FAFAF9` |
| `--s100` | `#F5F5F4` |
| `--s200` | `#E7E5E4` |
| `--s300` | `#D6D3D1` |
| `--s400` | `#A8A29E` |
| `--s500` | `#78716C` |
| `--s600` | `#57534E` |
| `--s700` | `#44403C` |
| `--s800` | `#292524` |
| `--s900` | `#1C1917` |

### Color — Semántico
| Estado  | bg       | fg       | dot      |
| ------- | -------- | -------- | -------- |
| success | `#DCFCE7`| `#15803D`| `#16A34A`|
| warning | `#FEF3C7`| `#92400E`| `#CA8A04`|
| danger  | `#FEE2E2`| `#B91C1C`| `#B91C1C`|
| neutral | `#F5F5F4`| `#57534E`| `#A8A29E`|

### Tipografía
| Variable  | Familia                | Uso                                        |
| --------- | ---------------------- | ------------------------------------------ |
| `--fui`   | Inter, system-ui       | UI por defecto                             |
| `--fdis`  | Space Grotesk          | display (títulos, números KPI, hero)       |
| `--fmono` | JetBrains Mono         | RUT, decretos (#NNNNNN), fechas, coords    |

### Radii / sombras
| Token       | Valor                                                                  |
| ----------- | ---------------------------------------------------------------------- |
| `--rsm`     | `6px`                                                                  |
| `--rmd`     | `8px`                                                                  |
| `--rlg`     | `12px`                                                                 |
| `--rxl`     | `16px`                                                                 |
| `--rpill`   | `999px`                                                                |
| `--shsm`    | `0 1px 3px rgba(0,0,0,.07), 0 1px 2px rgba(0,0,0,.04)`                  |
| `--shmd`    | `0 4px 6px -1px rgba(0,0,0,.08), 0 2px 4px -1px rgba(0,0,0,.04)`        |

---

## 2. Mapeo de íconos (reemplazar con los tuyos)

> **No uses los SVG del prototipo.** Sustituye cada uno por el equivalente de la librería que ya tiene tu app. Tamaños sugeridos al lado.

| Slot semántico                  | Lucide          | Heroicons                  | Material Symbols     | Tamaño |
| ------------------------------- | --------------- | -------------------------- | -------------------- | ------ |
| Pestaña Scraping (módulo)       | `briefcase`     | `briefcase`                | `work`               | 16–18  |
| Buscador                        | `search`        | `magnifying-glass`         | `search`             | 13–14  |
| Refrescar / Re-scrapear         | `refresh-cw`    | `arrow-path`               | `refresh`            | 12–14  |
| Histórico / reloj               | `clock`         | `clock`                    | `schedule`           | 12–14  |
| Punto en mapa                   | `map-pin`       | `map-pin`                  | `location_on`        | 11–15  |
| Abrir mapa completo             | `map`           | `map`                      | `map`                | 12     |
| Filtros                         | `filter` o `sliders-horizontal` | `funnel`     | `tune`               | 11–13  |
| Chevron abajo (dropdown)        | `chevron-down`  | `chevron-down`             | `expand_more`        | 9–11   |
| Chevron derecha (next, pagin.)  | `chevron-right` | `chevron-right`            | `chevron_right`      | 11–14  |
| Descargar CSV                   | `download`      | `arrow-down-tray`          | `download`           | 12     |
| Alerta (banner amarillo)        | `alert-triangle`| `exclamation-triangle`     | `warning`            | 11–15  |
| Cerrar panel                    | `x`             | `x-mark`                   | `close`              | 12     |
| Más opciones (kebab)            | `more-horizontal` | `ellipsis-horizontal`    | `more_horiz`         | 13     |
| Notificaciones (topbar)         | `bell`          | `bell`                     | `notifications`      | 15     |
| Tabs del menú principal         | `map`, `layout-dashboard`, `table`, `briefcase`, `users`, `trello` | — | — | 13 |

---

## 3. Vista 1 · Web — Sidebar + KPIs + Tabla + Mapa

**Nombre interno:** `02 · Web · sidebar + KPIs + tabla`
**Viewport de diseño:** 1440 × 920
**Archivo de referencia:** `scraping-v2-web.jsx` → componente `ScrapingWebV2`

### 3.1 Layout general (top → bottom)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TopBar global (60 px)                                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Sub-header de la vista (alto ~60 px)                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  Progress strip (alto ~38 px) ← barra de carga del scraper                  │
├──────────────┬────────────────────────────────────────────────┬─────────────┤
│              │                                                │             │
│  Sidebar     │              Main pane                         │ Map panel   │
│  248 px      │              flex:1                            │  340 px     │
│  bg s50      │              padding 18 24                     │  bg white   │
│              │                                                │             │
└──────────────┴────────────────────────────────────────────────┴─────────────┘
```

- Layout exterior: `display:flex; flex-direction:column; height:100%`.
- La zona "3 columnas" es `flex:1; display:flex; overflow:hidden`.
- El **Main pane** es el único contenedor con `overflow:auto`.

### 3.2 Sub-header

- Fondo `white`, borde inferior `1px solid var(--s200)`, padding `14px 28px`.
- Izquierda: ícono **briefcase** (18 px, color `#EA580C`) + bloque de título.
  - Título: `font-family: var(--fdis); font-size: 17px; font-weight: 700; letter-spacing: -.01em; line-height: 1;` → `"Transparencia pública"`
  - Subtítulo: `font-size: 10.5px; color: var(--s500); margin-top: 3px;` → `"Ley 20.285 · lotatransparente.cl · 500 registros sincronizados"`
- Derecha (en orden):
  1. **Pill "Scrappeando · 327/500"** — fondo `var(--or1)`, borde `1px solid var(--or3)`, color `var(--or7)`, radius `999px`, padding `5px 10px`, `font-size: 11px; font-weight: 600`. Con un dot animado de 7×7 `background:#EA580C; border-radius:50%` que parpadea (`opacity 1 → .3 → 1` en `1.4s ease-in-out infinite`).
  2. **Botón "Histórico"** — fondo blanco, borde `1px solid var(--s200)`, ícono **clock** + label. Padding `7px 12px`, radius `8px`.

### 3.3 Progress strip (NUEVO)

> Justo bajo el sub-header, **antes** de las 3 columnas.

- Fondo `white`, borde inferior `1px solid var(--s200)`, padding `9px 28px 0`.
- **Fila superior** (`flex; align-items:center; gap:10px; font-size:11.5px; color:var(--s700)`):
  - Spinner: círculo 14×14, borde `2px solid var(--or2)`, `border-top-color: #EA580C`, animación `rotate 360deg / .9s linear infinite`.
  - Texto: `"Scrappeando patentes comerciales"` (la palabra "Scrappeando" en `font-weight: 700; color: var(--s900)`).
  - Separador `·` color `var(--s400)`.
  - Contador `327/500` en `var(--fmono)`, `font-weight: 600; color: var(--s900)`.
  - Pill `65%`: fondo `var(--or2)`, color `var(--or7)`, radius `999px`, padding `1px 7px`, `font-size: 10.5; font-weight: 700; font-family: var(--fmono)`.
  - Separador `·`.
  - ETA `~38 s restantes` color `var(--s500)`.
  - Spacer (`flex:1`).
  - Botón **"Cancelar"** — transparente, borde `1px solid var(--s200)`, color `var(--s600)`, radius `6px`, padding `3px 10px`, `font-size: 11; font-weight: 600`.
- **Barra de progreso** (debajo, margin-top: 7px):
  - Track: `height: 3px; background: var(--s100); border-radius: 2px; overflow:hidden`.
  - Fill: `width: {pct}%; height:100%; background: linear-gradient(90deg, #F97316, #EA580C); border-radius: 2px; box-shadow: 0 0 8px rgba(234,88,12,.4)`.

**Animación:** cuando `pct` cambia, transition `width .4s ease-out`.

**Visibilidad:** mostrar sólo cuando hay scrape corriendo (`scrape.status === 'running'`). En estado idle ocultar la franja entera (no dejar espacio vacío).

### 3.4 Sidebar (248 px)

Background `var(--s50)`, padding `18px 14px`, overflow auto, `display:flex; flex-direction:column; gap:14px`.

#### a) Sección "Fuentes"
- Caption: `font-size: 9.5; letter-spacing: .09em; text-transform: uppercase; font-weight: 700; color: var(--s500); margin-bottom: 8px;` → `"Fuentes"`
- Lista de 4 cards (gap 6 px). Cada card:
  - Background: `var(--or1)` si activa, `white` si no.
  - Borde: `1px solid var(--or3)` activa, `1px solid var(--s200)` inactiva.
  - **Borde izquierdo grueso** (acento): `3px solid #EA580C` activa, `3px solid var(--s300)` inactiva.
  - Radius `10px`, padding `11px 13px`, cursor pointer, hover sube `--s700` (sin shadow).
  - Fila 1: label (font-size 12.5; font-weight 600) + spacer + número (`var(--fdis)`, 17 px, 700) en `var(--or7)` (activa) o `var(--s400)` (inactiva).
  - Fila 2: `font-size: 10.5; color: var(--s500); font-family: var(--fmono)` con dot 5×5 (verde `#16A34A` activa, gris `#A8A29E` inactiva) + `"ig {ig}"` + `·` + hora de última extracción (`HH:MM`).

#### b) Sección "Filtros"
- Card blanca, borde `1px solid var(--s200)`, radius 10, padding `12px 13px`.
- Caption igual al anterior → `"Filtros"`.
- 4 filas (gap 8 px), cada una:
  - padding `7px 10px`, radius `7px`, border `1px solid var(--s200)`.
  - **El filtro activo** (Rango temporal = "Últimos 30 días") va con fondo `var(--or1)`, borde `var(--or3)`, texto en `var(--or7)`.
  - Etiqueta a la izquierda: `font-size: 10.5; color: var(--s500); font-weight: 600`.
  - Valor a la derecha: `font-weight: 600`, color según estado + `chevron-down` 10 px.

Filas: `Rango temporal: Últimos 30 días` (activo), `Año: Todos`, `Mes: Todos`, `Geocoding: Todos`.

#### c) Nota explicativa
- Card blanca, **borde dashed** `1px dashed var(--s300)`, radius 10, padding `12px 13px`.
- Título en `font-weight: 700; color: var(--s900); margin-bottom: 4px;` → `"Sobre el scraping"`.
- Cuerpo: `font-size: 11.2; color: var(--s600); line-height: 1.45` con strong en `03:00 AM`.

### 3.5 Main pane

Padding `18px 24px`, flex column, overflow auto.

#### a) Header inline
- `display:flex; align-items:flex-end; gap:14px; margin-bottom:14px;`
- Izquierda: H2 + pill de cuenta.
  - H2: `var(--fdis)`, 22 px, 700, letter-spacing `-.015em`, color `var(--s900)` → `"Patentes comerciales"`.
  - Pill: fondo `var(--or2)`, color `var(--or7)`, radius pill, padding `2px 8px`, `font-size: 11; font-weight: 700` → `"500"`.
  - Fila de meta (debajo, `font-size: 11; color: var(--s500); gap: 14px;`):
    - `"Fuente"` + pill enlace (`var(--or1)`/`var(--or7)`, padding `1px 7px`, font 10.5) → `"lotatransparente.cl ↗"`.
    - `"ig"` + `164` en `var(--fmono); color: var(--s800); font-weight: 700`.
    - `"Última extracción"` + `2026-04-24 · 03:02` en `var(--fmono); color: var(--s800); font-weight: 700`.
- Spacer.
- Buscador (220 px de ancho): input con padding `7px 12px 7px 32px`, borde `1px solid var(--s200)`, radius 7, font 12. Ícono **search** 13 px en `position:absolute; left:11; top:8`. Placeholder: `"Buscar razón social, RUT…"`.
- Botón **"CSV"** — fondo blanco, borde, padding `7px 12px`, radius 7, font 12 600, ícono **download** 12 px.

#### b) KPI strip (3 cards iguales)
- Grid `repeat(3, 1fr); gap: 10px; margin-bottom: 14px`.
- Cada card: border `1px solid var(--s200)`, radius 10, padding `10px 12px`.

| Card               | bg          | color valor | label             | valor | sub                       |
| ------------------ | ----------- | ----------- | ----------------- | ----- | ------------------------- |
| Mostrando          | `--or1`     | `--or7`     | MOSTRANDO         | 500   | de 500 registros          |
| Geocoding alto     | `#F0FDF4`   | `#15803D`   | GEOCODING ALTO    | 428   | 85,6 % del total          |
| Fallos geocoding   | `#FEFCE8`   | `#92400E`   | FALLOS GEOCODING  | 72    | requieren revisión        |

- Label: `font-size: 9.5; font-weight: 700; letter-spacing: .07em; text-transform: uppercase; color: var(--s500);`
- Valor: `var(--fdis); font-size: 22; font-weight: 700; line-height: 1.1; margin-top: 2px;`
- Sub: `font-size: 10.5; color: var(--s500); margin-top: 1px;`

#### c) Tabla (compacta — 7 columnas porque hay panel lateral)

Container: fondo blanco, borde `1px solid var(--s200)`, radius 12, overflow hidden.

Grid columns: `0.75fr 0.9fr 1.1fr 1.85fr 1.4fr 0.7fr 40px`

**Header row** (`padding: 11px 16px; background: var(--s50); border-bottom: 1px solid var(--s200); font: 10/700 .08em uppercase; color: var(--s500)`):
1. N° decreto
2. Fecha
3. Tipo
4. Razón social
5. Dirección
6. Geocoding
7. (vacío — chevron/menú)

**Filas** (`padding: 12px 16px; border-bottom: 1px solid var(--s100); font-size: 12.5; align-items: center`):
- Fila seleccionada (focused): `background: var(--or1); border-left: 3px solid #EA580C; padding-left: 13px;`
- Resto: fondo transparente, `border-left: 3px solid transparent`.

Por columna:
1. `#XXXXXX` en `var(--fmono); font-size: 12; font-weight: 600; color: var(--or7)`.
2. `YYYY-MM-DD` en `var(--fmono); font-size: 11.5; color: var(--s700)`.
3. Badge "Tipo": dos líneas en columna —
   - Línea 1: pill `var(--or2)/var(--or7)`, padding `2px 8px`, radius 5, font 10/700, letter-spacing `.04em` → `"COMER"`.
   - Línea 2: `font-size: 10; color: var(--s500)` → `"Datos sensibles"`.
4. Razón social, color `var(--s900)`, font-weight 600 si focused / 500 normal, single-line con `text-overflow: ellipsis`.
5. Dirección con ícono **map-pin** 11 px (color `--s400`) inline + texto en `var(--s800)`, font 11.5.
6. Badge geocoding (ver abajo).
7. Si focused: ícono **chevron-right** 14 px en `#EA580C`. Si no: botón 26×26 redondo con ícono **more-horizontal** (kebab) 13 px en `#78716C`.

**Badge geocoding** (pill 999 px, padding `3px 9px`, font 10.5/700, dot 5×5):

| Nivel | bg        | color     | dot       |
| ----- | --------- | --------- | --------- |
| Alta  | `#DCFCE7` | `#15803D` | `#16A34A` |
| Media | `#FEF3C7` | `#92400E` | `#CA8A04` |
| Fallo | `#F5F5F4` | `#57534E` | `#A8A29E` |

#### d) Paginación
- `display:flex; justify-content:space-between; padding: 14px 4px 0; font-size: 12; color: var(--s600)`.
- Izquierda: `"Mostrando 1–20 de 500"` (números en `color: var(--s900); font-weight: 700`).
- Derecha: grupo de botones `gap: 4px`:
  - Botón 32×32 chevron-left (color `--s400`, deshabilitado en pág 1).
  - Botón página activa: 32×32, padding `0 10px`, radius 7, **fondo `#EA580C`, color blanco**, font 12/600.
  - Botón página inactiva: igual pero fondo blanco, borde `1px solid var(--s200)`, color `--s700`.
  - `…` color `--s400`.
  - Última página (25), chevron-right.

### 3.6 Map panel (derecha, 340 px) — NUEVO

> Aparece cuando hay una fila seleccionada en la tabla. Cierra con la X o con click en otra fila.

Container: `width: 340px; border-left: 1px solid var(--s200); background: white; display:flex; flex-direction:column; flex-shrink:0; overflow:hidden`.

#### a) Header del panel
- Padding `14px 16px`, borde inferior `1px solid var(--s200)`.
- Ícono **map-pin** 15 px en `#EA580C`.
- Título: `var(--fdis); font-size: 13.5; font-weight: 700; line-height: 1;` → `"Registro seleccionado"`.
- Subtítulo (font-size 10.5, var(--s500), var(--fmono), margin-top 3): `"#XXXXXX · click otra fila para cambiar"`.
- Spacer + botón cerrar 24×24, radius 6, fondo `var(--s100)`, ícono **x** 12 px.

#### b) Mini-mapa (220 px de alto)

> **No uses la implementación SVG del prototipo.** Usa el componente de mapa que ya tienes (Leaflet, Mapbox GL, Google Maps, etc.) configurado para el sector de Lota.

Si necesitas placeholder mientras se carga, usa fondo `#e8edf2` con grid de 32 px (líneas `rgba(0,0,0,.04)`).

Pines:
- **Pin seleccionado** (centro, ~50% / 42%): marker tipo "teardrop" 36×36, color `#EA580C`, borde blanco 3px, sombra `0 4px 12px rgba(28,25,23,.35)`. Halo: círculo 84×84 detrás, fondo `rgba(234,88,12,.15)`, borde dashed `1.5px #EA580C`.
- **Pines contextuales** (otros registros visibles): 12×12, opacity .55, sin halo. Color por geocoding (verde `#15803D` alta, rojo apagado `#9A3412` fallo).

Controles de zoom (top-right, top 10, right 10):
- Card 26×52 (dos botones apilados), fondo blanco, borde `1px solid var(--s200)`, radius 7, shadow `0 1px 3px rgba(0,0,0,.08)`.
- Cada botón 26×26, separador entre ambos.

#### c) Tarjeta de detalle

Padding `14px 16px`.

- **Fila top** (gap 8, margin-bottom 8):
  - Badge "COMER" (ver tabla).
  - Badge geocoding (Alta/Media/Fallo, mismo estilo que en la tabla).
  - Spacer.
  - `#XXXXXX` en `var(--fmono); font-size: 10.5; color: var(--or7); font-weight: 700`.
- **Razón social**: `var(--fdis); font-size: 14.5; font-weight: 700; color: var(--s900); line-height: 1.2`.
- **Subtítulo cls**: `font-size: 11; color: var(--s500); font-style: italic; margin-top: 3px` → `"Datos sensibles"`.
- **Tabla de metadata** (margin-top 12, padding-top 12, border-top `1px dashed var(--s200)`):
  - Grid `auto 1fr; gap: 7px 12px; font-size: 11.5`.
  - Labels (col izq): `color: var(--s500); font-weight: 600`. → `RUT`, `Giro`, `Dirección`, `Coords.`, `Fecha`, `Fuente`.
  - Valores: `color: var(--s900)`. RUT, coords y fecha en `var(--fmono)`. Fuente como pill enlace (`var(--or1)`/`var(--or7)`).
- **Acciones** (margin-top 14, gap 6):
  - Primario "Abrir en mapa": `flex:1`, padding 8, radius 7, font 12/600, fondo `#EA580C`, color blanco, ícono **map** 12 px, shadow `0 1px 2px rgba(194,65,12,.3)`.
  - Secundario "Decreto PDF": padding `8px 12px`, radius 7, font 12/600, fondo blanco, borde `1px solid var(--s200)`, color `--s700`.

---

## 4. Vista 2 · Móvil — KPI strip + Lista densa

**Nombre interno:** `04 · Móvil · KPI strip + lista densa`
**Viewport de diseño:** 402 × 874 (iPhone 14 Pro lógico)
**Archivo de referencia:** `scraping-v2-mobile.jsx` → componente `ScrapingMobileV2`

### 4.1 Layout (top → bottom, vertical stack)

```
┌──────────────────────────────┐
│ Status bar OS (≈26 px)       │  ← lo provee el dispositivo
├──────────────────────────────┤
│ App header (alto ≈92 px)     │  ícono + título + status row interno
├──────────────────────────────┤
│ KPI strip horizontal (≈64 px)│  scroll horizontal de 4 cards
├──────────────────────────────┤
│ Segmented control fuentes    │  4 pestañas en una pill
│ (≈58 px)                     │
├──────────────────────────────┤
│ Filter bar (≈42 px)          │  filtros tipo chip
├──────────────────────────────┤
│                              │
│ Lista densa (flex:1, scroll) │  ← área principal, scroll vertical
│                              │
├──────────────────────────────┤
│ Footer paginación (52 px)    │  dentro del scroll, al final
├──────────────────────────────┤
│ Tab bar OS app (≈70 px)      │  ← bottom nav del sistema
└──────────────────────────────┘
```

Container: `display:flex; flex-direction:column; height:100%`. La lista densa es el único `overflow:auto`.

### 4.2 App header (fondo blanco)

Padding `10px 14px 12px`, borde inferior `1px solid var(--s200)`.

- **Fila 1** (gap 10):
  - Ícono **briefcase** 18 px en `#EA580C`.
  - Bloque texto (flex:1):
    - `var(--fdis); 16px; 700; letter-spacing -.01em; line-height 1.1; color var(--s900)` → `"Transparencia pública"`.
    - `font-size: 9.5; color: var(--s500); margin-top: 2; letter-spacing: .03em;` → `"Ley 20.285 · lotatransparente.cl"`.
  - Botón ícono **search** 32×32 (tu componente MIconBtn).
- **Fila 2 — Status row inline** (margin-top 10):
  - Container: `background: var(--s50); border: 1px solid var(--s200); border-radius: 9px; padding: 7px 10px; display:flex; align-items:center; gap:6px`.
  - Pill "Activo": fondo `#DCFCE7`, color `#15803D`, padding `2px 7px`, radius 999, font 9.5/700, dot 5×5 `#16A34A`.
  - Texto `"hoy · 03:00 AM"` en `font-size: 10; color: var(--s600); font-family: var(--fmono)`.
  - Spacer.
  - **Botón primario "Scrappear"**: padding `4px 8px`, radius 6, font 10/600, fondo `#EA580C`, color blanco, ícono **refresh-cw** 9 px.
  - Botón "Histórico": padding `4px 8px`, radius 6, font 10/600, fondo blanco, borde `1px solid var(--s200)`, color `--s700`.

### 4.3 KPI strip horizontal

`display:flex; gap:8px; padding:10px 14px; background:white; overflow-x:auto; border-bottom: 1px solid var(--s200)`.

4 cards (`min-width: 78px; flex-shrink: 0; border-radius: 9px; padding: 7px 9px`):

| Card     | bg        | bd        | valor color | label color | sub        |
| -------- | --------- | --------- | ----------- | ----------- | ---------- |
| Patentes | `--or1`   | `--or3`   | `--or7`     | `--or7`     | comerciales|
| DOM      | `--s50`   | `--s200`  | `--s400`    | `--s700`    | permisos   |
| Decretos | `--s50`   | `--s200`  | `--s400`    | `--s700`    | tránsito   |
| Org.     | `--s50`   | `--s200`  | `--s400`    | `--s700`    | sociales   |

- Valor: `var(--fdis); 18px; 700; line-height: 1`.
- Label: `font-size: 9.5; font-weight: 700; margin-top: 3px`.
- Sub: `font-size: 8.5; color: var(--s500); margin-top: 1; letter-spacing: .03em`.

> Sólo "Patentes" tiene la fuente activa (color naranja). Las otras 3 quedan en gris claro porque tienen 0 registros (estado actual del scraper).

### 4.4 Segmented control de fuentes

Card padre: fondo blanco, padding `10px 14px`, borde inferior `1px solid var(--s200)`.

Segmented: `background: var(--s100); border-radius: 8px; padding: 3px; display: grid; grid-template-columns: repeat(4, 1fr)`.

Cada segmento:
- Padding `7px 4px`, text-align center, font-size 10.5.
- **Activo**: `font-weight: 700; color: var(--or7); background: white; border-radius: 6px; box-shadow: 0 1px 2px rgba(0,0,0,.07)`.
- **Inactivo**: `font-weight: 500; color: var(--s500); background: transparent`.
- Cada uno con label corto + mini badge a la derecha (`font-size: 8.5; padding: 0 5px; border-radius: 999; font-weight: 700`):
  - Activo: badge `var(--or2)/var(--or7)`.
  - Inactivo: badge `var(--s200)/var(--s500)`.

Labels: `Patentes`(500), `DOM`(0), `Decretos`(0), `Org.`(0).

### 4.5 Filter bar (chips)

Container: `background: var(--s50); padding: 8px 14px; border-bottom: 1px solid var(--s200); display:flex; align-items:center; gap:6px; overflow-x:auto`.

- Primer elemento: ícono **filter** 11 px en `#78716C`.
- Chip activo (`"30 días"`): **filled** — fondo `#EA580C`, color blanco, borde `1px solid #EA580C`, padding `3px 8px`, radius 999, font 10/600, sin chevron.
- Chips inactivos (`"Año Todos"`, `"Mes Todos"`, `"Geo Todos"`): fondo blanco, borde `1px solid var(--s200)`, color `--s700`, mismo padding y radius, con ícono **chevron-down** 9 px al final.
- Lado derecho (margin-left auto): `"500/500"` en `font-size: 10; color: var(--s500); font-family: var(--fmono)`.

### 4.6 Lista densa (rows)

`flex:1; overflow:auto; background:white`.

Cada fila: padding `10px 14px`, borde inferior `1px solid var(--s100)`, `display:flex; flex-direction:column; gap:5px`.

**Fila 1** (gap 6):
- `#XXXXXX` en `var(--fmono); 10.5; 700; color var(--or7)`.
- Pill `COMER`: padding `1px 5px`, radius 4, fondo `var(--or2)`, color `var(--or7)`, font 8.5/700, letter-spacing .04em.
- Fecha `YYYY-MM-DD` en `var(--fmono); 9.5; color var(--s500)`.
- Spacer.
- Mini geocoding chip — same colores, padding `1px 6px`, radius 999, font 9/700, dot 4×4.

**Fila 2 — Razón social**: `font-size: 12; font-weight: 600; color: var(--s900); line-height: 1.25; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;`

**Fila 3 — Dirección + RUT** (`font-size: 10; color: var(--s600); gap: 6; align-items: center`):
- RUT en `var(--fmono); color: var(--s500)`.
- Separador `·` en `--s300`.
- Ícono **map-pin** 9 px en `--s400`.
- Dirección, color `--s700`, single-line con ellipsis.

### 4.7 Footer paginación (dentro del scroll)

Padding `12px 14px; display:flex; align-items:center; gap:6px; font-size:10.5; color:var(--s500)`.

- Izquierda: `"Mostrando 1–20 de 500"` (números en `--s900; font-weight: 700`).
- Spacer.
- Botón chevron-left 28×28, radius 6, borde `1px solid var(--s200)`, color `--s400`.
- Botón página activa 28×28+, fondo `#EA580C`, color blanco, font 11/700, radius 6.
- Botón página inactiva 28×28+, borde `1px solid var(--s200)`, fondo blanco, color `--s700`.
- `…` color `--s400; padding: 0 2px`.
- Última página (25).
- Botón chevron-right 28×28.

---

## 5. Modelo de datos

### Fuente (source)
```ts
type ScrapingSource = {
  id: 'patentes' | 'permisos' | 'decretos' | 'organizaciones';
  label: string;       // "Patentes comerciales"
  short: string;       // "Patentes" (móvil)
  count: number;       // total de registros
  active: boolean;     // si está sincronizada y con datos
  source: string;      // "lotatransparente.cl"
  ig: string;          // ID interno de la fuente, ej "164"
  last: string;        // ISO "2026-04-24 03:02"
};
```

### Registro de patente (la lista actual)
```ts
type Patente = {
  dec: string;         // "#203217"
  fecha: string;       // "YYYY-MM-DD"
  tipo: 'COMER' | 'MEF' | 'Alcoholes' | 'Profesional';
  cls: string;         // "Datos sensibles"
  rut: string;         // "77.412.890-3"
  rs: string;          // razón social
  giro: string;        // descripción del giro
  dir: string;         // dirección normalizada
  geo: 'Alta' | 'Media' | 'Fallo';
  coords?: { lat: number; lng: number };
};
```

### Estado del scraper
```ts
type ScrapeStatus = {
  status: 'idle' | 'running' | 'error';
  done: number;        // progreso actual
  total: number;       // objetivo
  pct: number;         // 0–100
  eta: string;         // "~38 s restantes"
  startedAt: string;
  source: ScrapingSource['id'];
};
```

---

## 6. Estados e interacciones

### Web

| Acción del usuario                            | Resultado                                                                          |
| --------------------------------------------- | ---------------------------------------------------------------------------------- |
| Click en card de fuente del sidebar           | Cambia el dataset principal a esa fuente. Actualiza KPI strip, tabla y header.    |
| Click en filtro del sidebar                   | Abre popover/dropdown. Cambia el filtro y reactiva el query.                       |
| Click en fila de la tabla                     | Marca esa fila como `focused`. Si el panel de mapa está oculto, ábrelo. Centra el mapa en sus coords. |
| Click en X del panel mapa                     | Cierra el panel. La tabla pasa a **modo full** (9 columnas, agrega RUT + Giro).   |
| Click "Scrappear" / pill "Scrappeando"        | Si idle: dispara scrape, cambia pill a "Scrappeando", muestra progress strip. Si running: abre dialog para cancelar. |
| Click "Cancelar" en progress strip            | Aborta el scrape (con confirm). Vuelve a idle, oculta progress strip.              |
| Click "Histórico"                             | Modal/drawer con historial de ejecuciones del scraper.                             |
| Click "CSV"                                   | Descarga los registros filtrados.                                                  |
| Click "Abrir en mapa" del panel               | Navega a la vista Mapa global con el registro pre-seleccionado.                    |

### Móvil

| Acción                                  | Resultado                                                                  |
| --------------------------------------- | -------------------------------------------------------------------------- |
| Tap en card KPI                         | Cambia la fuente activa (mismo efecto que el segmented).                    |
| Tap en segmento de fuente               | Cambia la fuente, actualiza lista y KPIs.                                   |
| Tap en chip de filtro                   | Bottom sheet con opciones del filtro.                                       |
| Tap en chip activo "30 días"            | Vuelve a "Todos" (desactiva el filtro).                                     |
| Tap en fila de la lista                 | Push a pantalla detalle (no incluida acá — abre modal o nav stack).        |
| Tap "Scrappear"                         | Inicia scrape. Aparece mini progress (puede ser en una snackbar) en lugar del progress strip de web. |
| Swipe horizontal en KPI strip / filter bar | Scroll horizontal nativo.                                                |

### Animaciones

| Elemento                       | Animación                                                                  |
| ------------------------------ | -------------------------------------------------------------------------- |
| Dot del pill "Scrappeando"     | `opacity 1 → .3 → 1; 1.4s ease-in-out infinite`                            |
| Spinner del progress strip     | `rotate 360deg; .9s linear infinite`                                       |
| Fill de la barra de progreso   | `width 0 → pct%; .4s ease-out`                                             |
| Fila seleccionada en tabla     | `background-color`, `border-left-color`, `padding-left` con `transition: 120ms ease-out` |
| Apertura del panel de mapa     | Slide desde la derecha, `transform: translateX(100% → 0); .25s ease-out` + fade del backdrop |

---

## 7. Lista de archivos en este bundle

| Archivo                          | Contenido                                                                |
| -------------------------------- | ------------------------------------------------------------------------ |
| `Scraping Web y Movil.html`      | Host HTML del canvas (entrypoint del prototipo).                         |
| `scraping-v2-data.jsx`           | Fixtures de datos (12 patentes de ejemplo + 4 fuentes).                  |
| `scraping-v2-web.jsx`            | Vista web V2 + V1. **Referirse a `ScrapingWebV2`** para este handoff.   |
| `scraping-v2-mobile.jsx`         | Vista móvil V2 + V1. **Referirse a `ScrapingMobileV2`** para este handoff. |
| `app-shell.jsx`                  | `TopBar` global de la app (referencia, no obligatorio recrear).         |
| `mobile-chrome.jsx`              | `MobileFrame`, `MStatusBar`, `MAppHeader`, `MBottomBar`, `MIconBtn`.    |
| `tokens.css`                     | Tokens CSS (colores, tipografía, radii, sombras).                       |
| `icons.jsx`                      | Set de íconos del prototipo. **NO usar en producción** — sólo referencia para mapear nombres. |

---

## Recordatorios finales

- **No** copies los SVG inline de `icons.jsx`. Usa la librería de íconos de tu app.
- **No** copies los estilos inline `style={{ ... }}` literalmente. Tradúcelos al sistema de tu app (Tailwind, CSS modules, styled-components, etc.).
- **Sí** respeta los valores: hex codes, tamaños (px), pesos, letter-spacing, radii, gaps.
- **Sí** considera estados loading/empty/error para todos los datos asíncronos (no están dibujados pero deben existir).
- **Sí** prueba en breakpoints reales: la vista web está hecha para ≥1280 px (sidebar 248 + main fluido + panel 340). Por debajo de 1280, considera colapsar el sidebar a un toggle.
