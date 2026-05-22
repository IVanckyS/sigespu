# Handoff: SIGESPU Lota — Versión móvil

## Overview

Adaptación móvil del sistema **SIGESPU Lota** (Sistema de Gestión de Seguridad Pública Urbana) para la I. Municipalidad de Lota. Se diseñaron las **5 vistas principales** del sistema web — Resumen, Tabla, Scraping, Usuarios y Actividades — más una pantalla auxiliar que muestra el menú de cuenta abierto.

El objetivo es que toda la información y funcionalidad del escritorio quepa cómodamente en un teléfono (390–402 px de ancho), sin tablas apretadas, sin filtros amontonados, y sin perder ningún campo de datos.

## About the Design Files

Los archivos en `source/` son **referencias de diseño en HTML + React/JSX inline** (transpilado en navegador con Babel standalone). No son código de producción. La tarea es **recrear estos diseños en el entorno existente del codebase** — React Native, Flutter, SwiftUI, Jetpack Compose, o lo que use la app móvil de SIGESPU — siguiendo los patrones y librerías ya establecidos.

Si no hay codebase móvil aún, la recomendación es **React Native + Expo** (alineado con el stack web React que ya parece usar el sistema, y permite compartir tipos/lógica de modelo). La paleta y tipografía descritas abajo son fáciles de portar a NativeWind / Tamagui / cualquier sistema de tokens.

## Fidelity

**High-fidelity (hifi)**. Los mocks están pixel-perfect con colores finales, tipografía, espaciado, iconografía SVG y estados de cada componente. Recrear pixel a pixel pero **respetando los componentes nativos del codebase destino** (por ejemplo: si ya hay un `<Button>` propio, úsalo en lugar de recrear el botón desde cero).

## Screens / Views

### 0 · Chrome global (presente en todas las vistas)

**Header (`AppTopBar`)** — alto 50 px aprox.
- Crest SIGESPU (28×28, ink #1C1917 + acento #EA580C)
- Título "SIGESPU Lota" 14.5 px / 700 + pill "● En línea" (verde #16A34A / bg #DCFCE7)
- Subtítulo "I. Municipalidad de Lota" 10.5 px / #78716C
- Botón contextual de **export** (varía por vista — ver detalle por pantalla)
- Avatar circular 34×34, fondo #EA580C, iniciales "AD" blancas, indicador de chevron en esquina indicando que es desplegable
- Borde inferior 1 px #1C19170D

**Bottom tab bar (`BottomTabs`)** — alto 70 px (incluye safe-area 22 px iOS).
- Exactamente **5 botones**, glassmorph blur, distribuidos uniformemente
- Items: `Mapa`, `Resumen`, `Tabla`, `Scraping`, `Actividad`
- Cada item: icono 22 px arriba, label 10 px / 500 abajo (700 si activo)
- Estado activo: color #EA580C (orange). Inactivo: #78716C
- Badge numérico (#EA580C / texto blanco, 9 px) sobre el icono cuando hay items pendientes (ej: Actividad muestra 12)

**Avatar menu (`AvatarMenu`)** — popover anclado al avatar, ancho 280 px.
- Backdrop oscuro 30% opacidad cubriendo toda la pantalla
- Tarjeta blanca con sombra 0 16 40 / 22%, radius 14 px, flecha 14×14 rotada 45° apuntando al avatar
- Encabezado con avatar grande (40×40) + nombre + rol + unidad
- 4 items: **Mi perfil** · **Gestión de usuarios** (con contador 4) · **Bitácora del sistema** · **Configuración**
- Cada item: icono 28×28 en cuadrado redondeado (bg #F3F4F6, fg #44403C) + título 12.5 px / 600 + subtítulo 10.5 px / #78716C + chevron derecho
- Item activo: bg #FFF4EC, icono cuadrado con bg #EA580C / fg blanco, título color #EA580C
- Separador inferior + acción **Cerrar sesión** en rojo (#DC2626) con bg #FEE2E2

---

### 1 · Resumen (`ScreenResumen`)

**Propósito**: dashboard ejecutivo con indicadores clave del departamento de Seguridad Pública.

**Export del header**: "Exportar PDF" — el subtítulo del tooltip dice "Resumen operativo".

**Layout** (scroll vertical, padding 14 px lateral, bottom 100 px para tab bar):

1. **Hero card** (radius 18, gradient `135deg, #EA580C → #C2410C`, padding 14, sombra naranja)
   - Pill kicker "VISTA · RESUMEN OPERATIVO" con icono grid, bg `rgba(255,255,255,0.18)`
   - Título 22 px / 700 / -0.4 letter-spacing: "Dirección de Seguridad Pública"
   - Subtítulo 11.5 / 0.85 opacity: "Indicadores clave y últimos registros · Actualizado: 17 may 2026, 11:05"
   - Stats inline (grid 4 columnas, gap 6): `8 Reportes`, `5 Zonas activas`, `15 Patentes (mes)`, `3 C. acopio`
   - Adorno esquina superior derecha: grid 6 cuadrados blancos opacidad 0.5

2. **Sección Indicadores** (título 13.5 / 700 + label "últimos 30 días")
   - Grid 2×2 de KPI cards (radius 14, border #1C19170D, padding 12):
     - **Reportes este mes** · 8 · `↗ +12% vs mes anterior` (rojo) · icono pin / chip naranja claro
     - **Zonas de peligro activas** · 5 · `↗ 3 nuevas esta semana` (rojo) · icono warn / chip rojo claro
     - **Patentes nuevas (mes)** · 15 · `↗ scraping · hace 3h` (verde) · icono store / chip verde claro
     - **Centros de acopio** · 3 · `↗ Listos para emergencias` (verde) · icono house / chip azul claro
   - KPI extra full-width: **Sedes comunitarias** · 3 · `↗ Activas e identificadas` · icono people / chip lila

3. **Reportes por tipo** (card con donut SVG + leyenda al lado)
   - Donut 130 px, stroke 18, anillo base #F3F4F6
   - Segmentos: Vandalismo 40% #A855F7, Robo 40% #DC2626, Accidente 20% #F97316
   - Centro: "Total" 11 px / #78716C arriba, "5" 20 px / 700 abajo
   - Leyenda lateral: 3 filas con dot color + label 12 / 500 + count 12 / 700 + porcentaje a la derecha

4. **Zonas por sector** (card con lista, padding 4)
   - 5 filas separadas por hairline #1C19170D
   - Cada fila: badge de sector (S-2/S-3/S-4/S-5/Centro, colores ver Design Tokens) + nombre 12.5 / 600 + meta 10.5 / #78716C + barra de progreso a la derecha (56×6 px, bg #F3F4F6, fill #EA580C)
   - Datos:
     - S-2 Residencial Los Aromos · 2 zonas · 3 reportes · 60%
     - S-3 Mixto Los Aromos · 1 zona · 2 reportes · 40%
     - S-4 Equipamiento · 0 zonas · 0 reportes · 0%
     - S-5 Vivienda Periférica · 2 zonas · 1 reporte · 30%
     - Centro Centro Histórico Lota · 2 zonas · 5 reportes · 100%

---

### 2 · Tabla (`ScreenTabla`)

**Propósito**: explorador completo de todos los elementos georreferenciados del sistema (reportes de incidentes, zonas, infraestructura). La tabla de escritorio se convierte en **stream de cards verticales** + popup de detalle al tocar.

**Export del header**: "Exportar PDF" / subtítulo "Tabla · 7 registros filtrados" (debe reflejar el filtro activo dinámicamente).

**Layout**:

1. **Hero card** variante `dark` (gradient #1C1917 → #292524, adorno de líneas blancas)
   - Kicker "VISTA · REGISTRO DE ELEMENTOS" con icono table
   - Título "Tabla de datos"
   - Subtítulo "Todos los elementos georreferenciados. Filtrable por tipo, sector y estado."
   - Stats: `33 Total registros`, `4 Sectores`, `27 Activos`, `0 Esta semana`

2. **Search bar + acciones** (fila de 3)
   - Input 40 px altura, radius 11, icono search izquierda, placeholder "Nombre, dirección, RUT…"
   - Botón cuadrado 40×40 con icono filter + dot naranja arriba derecha indicando filtros activos
   - Botón cuadrado 40×40 con icono sortDn

3. **Chips de filtros activos** (scroll horizontal)
   - 5 chips: `Tipo: Todos`, `Sector: Todos`, `Estado: Todos`, `Fecha: Cualquiera`, `Registrado: Todos`
   - Cada chip: bg blanco, border #1C19170D, "Key:" en gris + "Value" en ink, chevron abajo

4. **Pills de categoría** (scroll horizontal)
   - 5 pills: `● Total 33` (activo, border negro), `● Zonas peligro 5` (dot rojo), `● Patentes 5` (dot naranja), `● Infra. 9` (dot azul), `● Otros 14` (dot gris)

5. **Indicador de resultado** + ordenamiento
   - "Mostrando **7** de 33" izquierda
   - "Fecha ↓" derecha (indica orden actual)

6. **Stream de cards de registros** — 7 cards en este mock, padding 11 px:
   - Fila 1: type badge + sector badge + status badge (a la derecha)
   - Fila 2: nombre del registro 13.5 / 600 / -0.1 letter-spacing
   - Fila 3: icono pin + dirección 11.5 / #78716C
   - Fila 4: icono calendar + fecha · separador · avatar 18×18 con iniciales + nombre del registrador
   - El primer card está **seleccionado**: bg #FFF8F2, border #F9D2BA, barra izquierda 3 px naranja
   - Datos (orden por fecha desc):
     1. Vandalismo · S-3 · "Daño paradero" · Vista Hermosa 1050 · 2026-04-23 · Activo · PC P. Castro
     2. Árbol caído · S-2 · "Árbol caído sobre calzada" · Los Aromos 380 · 2026-04-23 · Activo · RS R. Sepúlveda
     3. Robo · Centro · "Robo con intimidación" · Carlos Cousiño 340 · 2026-04-22 · Activo · RS R. Sepúlveda
     4. Poste caído · S-5 · "Poste eléctrico inclinado" · Monseñor Fuenzalida 1020 · 2026-04-22 · Activo · CM C. Muñoz
     5. Robo · S-2 · "Robo en vivienda" · Los Aromos 512 · 2026-04-21 · En revisión · RS R. Sepúlveda
     6. Cable colgando · Centro · "Cable telefónico colgando" · Matta esq. Caupolicán · 2026-04-21 · Activo · RS R. Sepúlveda
     7. Accidente · Centro · "Colisión vehicular" · Av. Pedro Aguirre Cerda 850 · 2026-04-20 · Cerrado · CM C. Muñoz

7. **BottomSheet popup** (se abre al tocar cualquier card)
   - Backdrop oscuro 45% + blur 2 px sobre toda la pantalla
   - Sheet anclado abajo, radius superior 22 px, sombra grande, altura 510 px
   - Handle drag 38×4 #1C19170D centrado arriba
   - Header del sheet: type badge + sector badge + botón cerrar (cuadrado 30×30)
   - Mini-mapa SVG ilustrativo 150 px alto + botón "Abrir en mapa" flotante arriba derecha
   - Contenido scrolleable:
     - Título 16 / 700 / -0.2 ls + ID #R-2026-0423
     - Status badge Activo
     - Grid de datos (col labels 92 px / 1fr): Dirección, Coordenadas, Sector (con badge + nombre), Fecha + hora, Registrado por (avatar + nombre + cargo)
     - Acciones: 2 botones full-width (`Ver en mapa` outline · `Editar registro` solid naranja)

---

### 3 · Scraping (`ScreenScraping`)

**Propósito**: visualizar y disparar el scraper de datos de transparencia pública desde `lotatransparente.cl` (Ley 20.285) — patentes, permisos DOM, decretos de tránsito, organizaciones sociales.

**Export del header**: "Exportar PDF" / subtítulo "Scraping · 15 patentes" (debe reflejar dataset + filtros).

**Layout**:

1. **Hero card** naranja con kicker "FUENTE · LOTATRANSPARENTE.CL" + adorno download.
   - Título "Datos de Transparencia Pública"
   - Subtítulo "Ley 20.285 · Patentes, permisos, decretos y organizaciones"
   - Stats: `15 Patentes`, `8 Permisos`, `6 Tránsito`, `8 Orgs.`

2. **Meta de la fuente**: "🕐 Última extracción: hace 3h · ● Operativo (verde)"

3. **Sub-tabs de dataset** (scroll horizontal)
   - 4 pills: `Patentes comerciales 15` (activo, fondo negro) · `Permisos DOM 8` · `Decretos tránsito 6` · `Organizaciones 8`
   - Activo: bg #1C1917 / color blanco / contador en pill semi-transparente
   - Inactivo: bg blanco / border #1C19170D / color #44403C

4. **Filtros en grid** (3 columnas)
   - Cards de 7 px padding con label uppercase 9.5 / 700 / spacing 0.4 arriba + valor 12 / 600 + chevron abajo
   - `AÑO: Todos` · `MES: Todos` · `GEOCODING: Todos`

5. **Search bar** completa 40 px, placeholder "Razón social, RUT, dirección…"

6. **Banner de resultados** (bg #FFF4EC, border #F9D2BA, radius 10, padding 8/12)
   - Círculo 22×22 naranja con check + "Resultados: **15** de **15**"

7. **Acciones del scraper** (2 botones full-width)
   - `🔄 Scrapear ahora` (solid naranja)
   - `☁ Scrapear todo` (outline naranja)

8. **Stream de cards de registros** (6 visibles, primer seleccionado)
   - Fila 1: número decreto 13 / 700 / naranja (ej. `#1852`) + fecha 11 / gris + geocoding pill (Alta/Media/Baja con colores semánticos verde/amarillo/rojo)
   - Razón social 13 / 700 / -0.1 ls
   - Giro 11.5 / #44403C
   - Footer: tipo en pill gris + RUT + dirección con pin

9. **BottomSheet popup** (se abre al tocar)
   - Header con pill "Patente comercial" + pill "Geocoding: Alta" + cerrar
   - Mini-mapa + botón "Editar ubicación" flotante
   - Datos completos: # Decreto, Fecha, RUT, Dirección, Coordenadas, Fuente
   - Acciones: `Ver en mapa` + `Editar ubicación`

---

### 4 · Usuarios (`ScreenUsuarios`)

**Acceso**: este screen **no está en el bottom tab bar**. Se accede tocando el avatar arriba → menú → "Gestión de usuarios". Ver pantalla 5 para el flujo.

**Export del header**: "Exportar Excel" / subtítulo "Usuarios · 4 activos".

**Layout**:

1. **Hero card** variante `maroon` (gradient #1C1917 → #7C2D12, adorno escudo).
   - Kicker "ADMINISTRACIÓN · ACCESO AL SISTEMA" con icono shield
   - Título "Gestión de usuarios"
   - Subtítulo "Roles, credenciales y permisos del personal SIGESPU."
   - Stats: `4 Activos`, `4 Registrados`, `3 Roles en uso`, `0 Solicitudes`

2. **Sub-tabs** (scroll horizontal) — 4 pills: `Usuarios` (activo, bg naranja claro, border naranja) · `Solicitudes` · `Roles` · `Bitácora`

3. **Search + filter**: input 40 px "Nombre, email, RUT…" + botón filter cuadrado

4. **Chips de filtros**: `Rol: Todos los roles`, `Unidad: Todas`, `Estado: Activos`

5. **Acción principal**: botón full-width naranja "+ Crear usuario"

6. **Stream de user cards** (4 cards)
   - Layout: avatar circular 38×38 con iniciales/color + nombre + cargo + email + menú vertical
   - Pills bajo el header: Rol (DIRECTOR/OPERATIVO/VISITANTE — colores propios) + Estado (Activo) + Unidad (gris)
   - Footer: última sesión + acciones (editar / toggle / eliminar) — solo si no eres tú
   - Datos:
     - **AD Administrador del Sistema** [TÚ] · admin@lota.cl · Dir. Seguridad Pública · DIRECTOR · Activo · hace 25 min
     - **DS Director Seguridad Pública** · Director · director@lota.cl · DIRECTOR · Activo · Sin sesiones aún
     - **JP Juan Pérez** · Inspector municipal · inspector1@lota.cl · OPERATIVO · Activo · Sin sesiones aún
     - **MS María Silva** · msilva@lota.cl · Municipal · VISITANTE · Activo · Sin sesiones aún

7. **Distribución de roles** (card con barras horizontales)
   - Director 2 / 50% (bar #1C1917)
   - Operativo 1 / 25% (bar #EA580C)
   - Visitante 1 / 25% (bar #7C3AED)

8. **Actividad reciente** (card con lista, 3 entradas)
   - Avatar pequeño + acción + timestamp
   - "DS Aprobó solicitud de R. Sepúlveda · hace 2h"
   - "DS Creó usuario inspector2@lota.cl · hace 5h"
   - "DS Rechazó solicitud de C. Morales · ayer 16:30"

---

### 5 · Menú de cuenta (composición demo)

Esta pantalla muestra **ScreenResumen + AvatarMenu abierto** como demo del flujo de acceso. No es una pantalla nueva — es el estado de cualquier pantalla con el menú del avatar desplegado.

**Implementación**: tap en avatar → render del componente `AvatarMenu` sobre la pantalla actual (no navega — overlay). Item "Gestión de usuarios" navega a la pantalla 4. Item "Mi perfil" / "Bitácora" / "Configuración" navegan a sus respectivas vistas (a definir si están fuera del scope de este handoff). "Cerrar sesión" abre confirmación + logout.

---

### 6 · Actividades (`ScreenActividades`)

**Propósito**: ver y gestionar el tablero kanban de actividades municipales (reuniones, operativos, capacitaciones, eventos).

**Export del header**: "Exportar JSON" / subtítulo "Actividades · 12 totales".

**Estrategia de adaptación**: el kanban de 4 columnas horizontales del escritorio se convierte en **segmented control** + stream vertical de la columna activa + **peek horizontal scrolleable** de las otras columnas.

**Layout**:

1. **Hero card** dark con kicker "TABLERO KANBAN" + adorno de barras verticales.
   - Título "Actividades municipales"
   - Subtítulo "12 actividades · 4 estados"
   - **Mini-stats grid 4×1** de los estados: cada uno con dot color + label uppercase + count grande
     - Planificado 4 (#2563EB) · En curso 3 (#EA580C) · Completado 3 (#16A34A) · Archivado 2 (#6B7280)

2. **Search + filter**: "Buscar actividades…" + botón filter

3. **Chips de filtros**: `Tipo: Todos`, `Depto.: Todos`, `Fecha: Cualquiera`

4. **Segmented control** (bg #F1ECE3, padding 4, grid 4×1, gap 4)
   - 4 segmentos, primero activo (bg blanco + sombra)
   - Cada uno: dot color + label 11.5 / 700 + count "X act." abajo

5. **Header de columna activa** (Planificado en este mock)
   - dot color + nombre + contador + botón "+ Nueva" (naranja, 32 px alto)

6. **Stream vertical de cards** (4 cards Planificado en mock):
   - Type badge + sector badge derecha
   - Título 13 / 600 / -0.1 ls (puede ser largo, 2 líneas)
   - Footer 3 metas: calendar + fecha, clock + hora, people + N part.
   - Linea extra: pin + dirección (italic + gris si "Sin ubicación")
   - Barra izquierda 3 px color de la columna
   - Datos Planificado:
     - Reunión · S-2 · "Mesa territorial Lota Bajo · Comerciantes Pedro Aguirre Cerda" · 18 may 09:00 · 0 part. · Pedro Aguirre Cerda 302, Lota Bajo
     - Capacitación · S-3 · "Capacitación inspectores · Uso de SIGESPU móvil" · 20 may 10:00 · 0 part. · Edificio Consistorial · Sala Cuncos
     - Operativo · S-4 · "Operativo conjunto Carabineros · Sector Plaza de Armas" · 22 may 22:00 · 0 part. · Sin ubicación
     - Evento · Centro · "Feria del Adulto Mayor · Plaza Matías Cousiño" · 2 jun 10:00 · 0 part. · Plaza Matías Cousiño, Lota Alto
   - Botón "+ Agregar actividad" dashed al final

7. **"Otros estados"** (scroll horizontal carrusel)
   - 3 mini-columnas 260×auto, cada una con bg semántico (#FFF4EC en curso, #DCFCE7 completado, #F3F4F6 archivado)
   - Header con dot + label uppercase + count + botón "+"
   - 2 mini-cards visibles por columna + "+ N más" si hay más

## Interactions & Behavior

### Navegación
- **Bottom tabs**: tap → navega a la vista correspondiente. Estado activo persiste en la barra. Badge en Actividad debe pollear el conteo de items "En curso + Planificado".
- **Avatar**: tap → abre `AvatarMenu` con animación slide-down + fade backdrop in (~180 ms cubic-bezier(.2,.7,.3,1))
- **AvatarMenu items**: tap → cierra menú + navega. "Cerrar sesión" → confirm dialog → logout.
- **Export button (header)**: tap → genera el archivo del tipo correspondiente (PDF/Excel/JSON) con los filtros actuales aplicados. Debe mostrar loading state durante la generación.

### Tabla / Scraping
- **Tap en card de fila**: abre `BottomSheet` con detalle + mapa. Animación slide-up 220 ms.
- **Tap en backdrop / botón close / drag-down**: cierra el sheet.
- **Botón "Ver en mapa" dentro del sheet**: navega a `Mapa` con el pin centrado.
- **Botón "Editar registro" / "Editar ubicación"**: abre formulario de edición full-screen.
- **Filter button**: abre sheet inferior con todos los filtros (mismo patrón que el detalle).
- **Pills de categoría / sub-tabs**: tap → filtra la lista + actualiza contador.

### Resumen
- **Donut chart**: tap en segmento → filtra Tabla por ese tipo.
- **Lista de sectores**: tap en fila → navega a Tabla pre-filtrada por ese sector.
- **KPI cards**: tap → navega a la vista detallada correspondiente (Reportes → Tabla filtrada, Patentes → Scraping, etc).

### Actividades
- **Segmented control**: tap en segmento → cambia la columna activa con cross-fade 150 ms.
- **Tap en card de actividad**: abre detalle (BottomSheet o full-screen — a decidir según el ecosistema móvil).
- **Carrusel "Otros estados"**: swipe horizontal. Tap en una mini-columna → cambia el segmented control a esa columna.

### Usuarios
- **Tap en user card (menú vertical "⋮")**: muestra action sheet (Editar, Cambiar contraseña, Desactivar, Eliminar).
- **Botones inline editar / toggle / eliminar**: acciones directas (toggle hace switch optimista, los otros abren confirmación o formulario).

### Animaciones globales
- **Press feedback**: scale 0.97 + opacity 0.85 en todos los botones/cards interactivos (~80 ms).
- **Hairline borders**: en pantallas Retina usar `0.5 px` reales (no 1 px CSS).
- **Status pill dot**: pulse sutil de 1.0→1.4 escala en items "En curso" cada 2s (opcional).

## State Management

### Estado global
- `currentUser` — usuario logueado (rol, unidad, permisos)
- `activeTab` — id de la tab inferior activa (mapa | resumen | tabla | scraping | actividades)
- `accountMenuOpen` — bool, controla el AvatarMenu
- `unreadActivityCount` — número en el badge de la tab Actividad (polling cada 60s o websocket)

### Por pantalla

**Tabla** y **Scraping** comparten estructura:
```
{
  filters: { tipo, sector, estado, fecha, registrado, search, dataset (solo scraping), año, mes, geocoding },
  sort: { field, direction },
  records: [...],
  loading: bool,
  selectedRecordId: string | null,  // controla BottomSheet
  page: number,
}
```

**Resumen**:
```
{
  kpis: {...},
  reportTypesBreakdown: [{label, value, color, count}],
  sectorsBreakdown: [{code, name, meta, pct}],
  lastUpdated: timestamp,
}
```

**Actividades**:
```
{
  filters: { tipo, depto, fecha, search },
  activeColumn: 'planificado' | 'en-curso' | 'completado' | 'archivado',
  columns: { [columnId]: { count, cards: [...] } },
}
```

**Usuarios**:
```
{
  filters: { rol, unidad, estado, search },
  subtab: 'usuarios' | 'solicitudes' | 'roles' | 'bitacora',
  users: [...],
  roleDistribution: [...],
  recentActivity: [...],
}
```

### Fetching
Toda data viene del backend SIGESPU existente. Endpoints sugeridos (a confirmar con el backend):
- `GET /api/v1/dashboard/summary` (Resumen)
- `GET /api/v1/records?type=...&sector=...&...` (Tabla)
- `GET /api/v1/scraping/{dataset}?...` (Scraping)
- `POST /api/v1/scraping/run` y `POST /api/v1/scraping/run-all` (acciones scraper)
- `GET /api/v1/users` + sub-recursos (Usuarios)
- `GET /api/v1/activities?status=...` (Actividades)
- `GET /api/v1/exports/{view}.pdf?filters=...` (export contextual)

## Design Tokens

Todos los valores están centralizados en `source/screens/common.jsx` bajo el objeto `SG`. Replicalos como tokens en tu sistema de diseño.

### Colors

```
Page bg:           #FAF7F2   (warm off-white)
Surface (card):    #FFFFFF
Border (hairline): rgba(28,25,23,0.08)   ≈ #1C19170D
Border strong:     rgba(28,25,23,0.14)   ≈ #1C191724

Ink (primary):     #1C1917
Ink-2 (secondary): #44403C
Ink-3 (tertiary):  #78716C
Ink-4 (disabled):  #A8A29E

Brand orange:      #EA580C   (primary action, active states, hero gradient start)
Brand orange deep: #C2410C   (hero gradient end)
Brand orange soft: #FFF4EC   (active backgrounds)

Success green:     #16A34A   (status: Activo, En línea, geo: Alta)
Success soft:      #DCFCE7
Success ink:       #166534

Warning yellow:    #CA8A04   (status: En revisión, geo: Media)
Warning soft:      #FEF3C7
Warning ink:       #92400E

Danger red:        #DC2626   (logout, delete, +12% trend negativo, geo: Baja)
Danger soft:       #FEE2E2
Danger ink:        #991B1B

Neutral gray:      #6B7280
Neutral soft:      #F3F4F6
```

### Sector badges

| Code   | bg        | fg        |
|--------|-----------|-----------|
| S-2    | #DCFCE7   | #166534   |
| S-3    | #FEF3C7   | #854D0E   |
| S-4    | #FFEDD5   | #9A3412   |
| S-5    | #FCE7F3   | #9D174D   |
| Centro | #F5F0E6   | #78350F   |

### Type badges (tipos de reporte / actividad)

| Type            | bg        | fg        |
|-----------------|-----------|-----------|
| Vandalismo      | #F3E8FF   | #6B21A8   |
| Robo            | #FEE2E2   | #991B1B   |
| Árbol caído     | #DCFCE7   | #166534   |
| Poste caído     | #FFEDD5   | #9A3412   |
| Cable colgando  | #FEF3C7   | #854D0E   |
| Accidente       | #FFEDD5   | #9A3412   |
| Reunión         | #EDE9FE   | #5B21B6   |
| Operativo       | #FFEDD5   | #9A3412   |
| Capacitación    | #CCFBF1   | #115E59   |
| Evento          | #DCFCE7   | #166534   |

### Role pills

| Role      | bg        | fg        |
|-----------|-----------|-----------|
| DIRECTOR  | #FFF4EC   | #EA580C   |
| OPERATIVO | #FEF3C7   | #92400E   |
| VISITANTE | #EDE9FE   | #5B21B6   |

### Status pills

| Status      | bg        | fg        |
|-------------|-----------|-----------|
| Activo      | #DCFCE7   | #166534   |
| En revisión | #FEF3C7   | #92400E   |
| Cerrado     | #F3F4F6   | #44403C   |

### Typography

- **Font stack**: `-apple-system, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif`
- **Display stack** (números grandes, títulos): `-apple-system, "SF Pro Display", "Helvetica Neue", system-ui, sans-serif`

**Scale (tamaños usados)**:
| Token     | Size | Line height | Weight | Letter spacing | Uso                              |
|-----------|------|-------------|--------|----------------|----------------------------------|
| display-l | 24   | 1.0         | 700    | -0.5           | KPI value grande                 |
| display-m | 22   | 1.15        | 700    | -0.4           | Hero title                       |
| display-s | 20   | 1.1         | 700    | -0.5           | Donut center, kanban stats       |
| heading   | 16   | 1.2         | 700    | -0.2           | Bottom-sheet title               |
| title-m   | 14.5 | 1.2         | 700    | -0.1           | AppTopBar nombre app             |
| title-s   | 13.5 | 1.3         | 600/700| -0.1           | Card title (registro), section h |
| body      | 12.5 | 1.4         | 500/600| 0              | Buttons, chips, search           |
| body-s    | 12   | 1.3         | 500/600| 0              | Card subtitle, sheet data values |
| label     | 11.5 | 1.4         | 500/600| 0              | Subtítulos hero, sector name     |
| label-s   | 10.5 | 1.25        | 500/700| 0              | KPI label, metadata, stats lbl   |
| caption   | 10   | 1.2         | 600/700| 0              | Bottom tab label                 |
| micro     | 9.5  | 1.0         | 700    | 0.4 (upper)    | Filter section label uppercase   |
| badge     | 10.5 | 1.5         | 600    | 0              | Pills (sector, type, status)     |

### Spacing

Padding lateral de scroll: **14 px** uniforme.
Gaps internos típicos: **6, 8, 10, 12, 14, 18 px**.
Bottom padding del scroll para clear tabs: **100 px**.

### Radius

```
sm: 8 px        (botones cuadrados pequeños)
md: 10–11 px    (buttons, inputs, chips de filtro)
lg: 12 px       (cards de registros, columns)
xl: 14 px       (cards principales con sombra)
xxl: 18 px      (hero card)
sheet: 22 px    (top de BottomSheet)
pill: 9999 px   (badges, pills, segmented items)
```

### Shadows

```
shadow-sm:  0 1px 2px rgba(28,25,23,0.04), 0 1px 1px rgba(28,25,23,0.03)
shadow:     0 1px 3px rgba(28,25,23,0.06), 0 4px 12px rgba(28,25,23,0.04)
hero:       0 8px 20px rgba(234,88,12,0.18)   (solo hero naranja)
sheet:      0 -10px 30px rgba(0,0,0,0.18)     (BottomSheet)
menu:       0 16px 40px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.04)
```

### Status bar

- Sistema operativo (no del diseño) — usar safe-area-inset-top.
- Color del status bar text: oscuro sobre fondos claros, claro sobre el hero naranja (transitions cuando se hace scroll si quieres pulir).

## Assets

**Cero assets externos.** Todo el iconografía es **SVG inline** definido en `screens/common.jsx` bajo el componente `Icon` (función `Icon({name, size, color, strokeWidth})`). Lista completa de iconos:

`home, map, grid, table, download, users, kanban, search, filter, pin, warn, store, house, people, calendar, clock, bell, plus, chev, chevDn, close, menu, arrowUp, arrowDn, arrowSm, arrowSmDn, shield, logout, refresh, cloud, edit, trash, toggleOn, pencil, dot, flask, bolt, moreH, moreV, check, sortDn, pdf, eye`

Todos son stroke-based en viewBox 0 0 24 24, strokeWidth default 1.6, round caps/joins.

**Logo / Crest**: definido inline en componente `LotaCrest` — escudo cuadrado dark con onda naranja + círculo blanco arriba derecha. Si la municipalidad tiene un escudo oficial, **sustituirlo** por el SVG real.

**Mapa**: ilustración SVG placeholder en `tabla.jsx` función `MiniMap`. En producción **reemplazar por mapa real** (MapKit en iOS, Google Maps / Mapbox en Android, o tile provider OSM si la app móvil ya usa uno).

## Files

```
source/
├── index.html                  ← entrada, monta el design canvas con todas las pantallas
├── design-canvas.jsx           ← starter component (presentación lado a lado, NO requerido en producción)
├── ios-frame.jsx               ← starter component (marco iPhone, NO requerido en producción)
└── screens/
    ├── common.jsx              ← tokens (SG), iconos, Hero, BottomTabs, AppTopBar, AvatarMenu, BottomSheet, Pill, *Badge — FUNDAMENTAL
    ├── resumen.jsx             ← ScreenResumen + Donut chart SVG
    ├── tabla.jsx               ← ScreenTabla + RecordCard + MiniMap
    ├── scraping.jsx            ← ScreenScraping + ScrapeRow
    ├── usuarios.jsx            ← ScreenUsuarios + UserCard
    └── actividades.jsx         ← ScreenActividades + ActivityCard + MiniActivityCard
```

**Lo importante para portar**: `common.jsx` define el sistema. Las pantallas son ensamblajes de esos primitivos. Empieza migrando los tokens (SG) a tu sistema de diseño, luego los componentes base (Pill, Hero, Card, BottomSheet, AppTopBar, BottomTabs), y al final compón las pantallas.

## Notas finales

- Las **5 pantallas web originales del usuario** se mapearon así: Mapa (no incluida porque no estaba en los mocks de origen, vive como tab 1 placeholder) · Resumen · Tabla · Scraping · Usuarios · Actividades. La pantalla 5 del handoff es una composición demo del menú abierto, no es una vista independiente.
- **Usuarios sale del bottom tab bar** para mantenerlo en 5 ítems operativos. Vive en el avatar menu junto a Bitácora y Configuración (vistas a definir).
- El botón **Exportar contextual** del header debe regenerar el archivo según los filtros actuales — esto es explícito en el feedback del cliente: "el botón de pdf siempre es en la parte de arriba pq va cambiando sus propiedades dependiendo de la vista que esté tomando en cuenta los filtros".
- Los **BottomSheets de detalle** en Tabla y Scraping muestran info de ubicación + mapa, replicando el side-drawer del escritorio. Es una pieza clave del feedback del cliente.
