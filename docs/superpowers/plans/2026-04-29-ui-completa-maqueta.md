# UI Completa según Maqueta — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implementar todas las pantallas de SIGESPU Lota tal como aparecen en la maqueta HTML aprobada, incluyendo datos seed, gráficos, filtros y navegación completa.

**Architecture:** Datos demo en `seed_data.dart` como constantes Dart. Todas las pantallas son StatefulWidget donde necesiten estado local (filtros, tabs). Se usa `fl_chart` para gráficos en ResumenScreen. No se modifica el backend.

**Tech Stack:** Flutter 3.27+, Riverpod 2.x, fl_chart 0.66, flutter_map 6.1, lucide_icons

---

## Archivos

| Acción | Archivo |
|---|---|
| Crear | `app/lib/src/data/seed_data.dart` |
| Modificar | `app/lib/src/presentation/shared/app_shell.dart` |
| Reescribir | `app/lib/src/presentation/map/map_screen.dart` |
| Reescribir | `app/lib/src/presentation/resumen/resumen_screen.dart` |
| Reescribir | `app/lib/src/presentation/tabla/tabla_screen.dart` |
| Reescribir | `app/lib/src/presentation/scraping/scraping_screen.dart` |

---

### Task 1: seed_data.dart
Crea archivo con todos los datos demo: ElementoMapa (30+ elementos), DatoPatente (15), DatoPermiso (8), DatoTransito (6), DatoOrganizacion (8).

### Task 2: app_shell.dart  
Agrega UserChip, ConnectivityStatus badge (online/offline), botón Exportar PDF, OfflineBanner debajo del AppBar.

### Task 3: map_screen.dart
Sidebar con secciones: capas (completo), filtros de peligro (chips), heatmap toggle, rango fechas (select). Info panel top-left, leyenda bottom-left, botón collapse sidebar. Todos los marcadores seed.

### Task 4: resumen_screen.dart
5 KPI cards, BarChart (reportes por tipo), lista sectores PR, LineChart (tendencia semanal), lista últimos reportes.

### Task 5: tabla_screen.dart
StatefulWidget con filtros (tipo, sector, estado, búsqueda), contador resultados, tabla sortable, todos los datos seed.

### Task 6: scraping_screen.dart
StatefulWidget con 4 tabs (Patentes, Permisos, Tránsito, Orgs), filtros por tab, tabla datos, meta bar, badges confianza geocoding.
