# SIGESPU Lota

Sistema de Información Geoespacial de Seguridad Pública desarrollado para la Dirección de Seguridad Pública de la Municipalidad de Lota. Es una herramienta interna de uso exclusivo para funcionarios municipales.

La idea central es simple: un mapa donde se concentra todo lo relevante para el trabajo diario de la dirección. Desde ese mapa se pueden ver zonas de peligro, puntos de infraestructura, patentes comerciales scrapeadas desde el portal de transparencia, permisos de obras y reportes de incidentes. Todo en un solo lugar, con la posibilidad de agregar elementos en terreno desde el celular aunque no haya señal.

---

## Qué hace cada pantalla

**Mapa** — Es la pantalla principal. Muestra las capas activadas sobre un mapa de la comuna (CartoDB Voyager sobre OpenStreetMap). Desde el panel lateral se activan o desactivan capas: Plan Regulador, zonas de peligro, patentes comerciales, centros de acopio, cámaras, etc. El botón flotante permite agregar un nuevo elemento en la posición actual o en un punto elegido manualmente.

**Resumen** — Dashboard con indicadores: cantidad de reportes por tipo, zonas activas, actividades del mes. Pensado para el director, para tener una vista rápida del estado de la comuna sin necesidad de navegar por el mapa.

**Tabla** — Vista de listado con filtros para consultar registros específicos. Permite buscar por tipo, fecha o sector, y ver el detalle de cualquier elemento con su ubicación en un minimapa.

**Scraping** — Muestra los datos extraídos automáticamente desde lotatransparente.cl: patentes comerciales mensuales, permisos de la Dirección de Obras, decretos de tránsito y organizaciones sociales. Cada registro tiene su ubicación en el mapa. Los usuarios con rol operativo pueden corregir la ubicación si el geocoding automático fue impreciso.

**Actividades** — Tablero kanban con las actividades municipales organizadas por estado (Planificado, En curso, Completado, Archivado). Cada tarjeta tiene el tipo de actividad, fechas y participantes.

**Usuarios** — Solo visible para el director. Muestra la lista de funcionarios registrados y las solicitudes de acceso operativo pendientes de aprobación.

---

## Acceso y roles

El registro está restringido a correos con dominio `@lota.cl` o `@munilota.cl`. Cualquier otro dominio es rechazado en el registro.

Todo nuevo usuario entra con nivel **visitante**: puede ver el mapa y consultar datos, pero no puede agregar ni modificar nada. Para solicitar acceso operativo, hay un botón en el perfil que abre un formulario donde el funcionario indica su cargo y dependencia. El director recibe la solicitud en la pantalla de Usuarios y puede aprobarla o rechazarla.

Los niveles son:

- **Visitante** — lectura completa, sin escritura
- **Operativo** — puede agregar elementos al mapa, crear reportes, dibujar zonas, corregir ubicaciones del scraping
- **Director** — todo lo anterior más gestión de usuarios y acceso a estadísticas completas

---

## Modo offline

La aplicación está pensada para funcionar en terreno, donde la señal de celular puede ser inestable. Las capas críticas (centros de acopio, sedes comunitarias, zonas de peligro, Plan Regulador, patentes del último año) se guardan localmente usando SQLite a través de Drift.

Cuando un operativo crea un reporte sin conexión, el registro se guarda localmente y aparece en el mapa inmediatamente. En cuanto el dispositivo recupera conexión, el servicio de sincronización lo sube al servidor automáticamente. Si falla el primer intento, reintenta con backoff exponencial (1s, 5s, 30s, 5 min). Si falla tres veces, el registro queda marcado como error de sync y se le notifica al usuario.

---

## Scraper

El scraper es un proceso separado que corre en segundo plano y actualiza la base de datos cada noche a las 03:00. Extrae datos de lotatransparente.cl (el portal de transparencia municipal), los normaliza y los geocodifica usando Nominatim de OpenStreetMap.

La normalización de direcciones tiene reglas específicas para Lota porque la nomenclatura local es atípica: "P.A. Cerda" se expande a "Pedro Aguirre Cerda", las referencias a pabellones históricos mineros se descartan porque no tienen coordenadas válidas, etc. Los registros que no se pueden geocodificar van a una bandeja de revisión manual.

El geocoding respeta el límite de 1 petición por segundo que exige Nominatim, y cachea los resultados en Redis por 30 días para no repetir consultas.

---

## Levantar el proyecto en desarrollo

Requisitos: Docker, Docker Compose, Flutter SDK 3.27+.

```bash
# Levantar base de datos, Redis, backend y scraper
docker compose up -d --build

# En otra terminal, correr la app Flutter
cd app
flutter pub get
flutter run -d chrome   # web
flutter run             # emulador o dispositivo conectado
```

El backend queda disponible en `http://localhost:8080`. La app Flutter toma esa URL por defecto en desarrollo, configurada en `app/lib/src/config/constants.dart`.

Si modificas modelos en `shared/` o tablas de la base de datos local en `app/lib/src/data/local/`, hay que regenerar los archivos generados por `build_runner`:

```bash
# En shared/
dart run build_runner build -d

# En app/
dart run build_runner build -d
```

---

## Deploy

El sistema usa tres servicios para producción:

- **Railway** — backend Dart + PostgreSQL + Redis. El archivo `railway.json` en la raíz configura el build automáticamente desde el Dockerfile del backend.
- **Cloudflare Pages** — app Flutter compilada para web. El workflow `.github/workflows/deploy-web.yml` la construye y despliega en cada push a `main`.
- **Firebase App Distribution** — APK Android para distribución a testers. El workflow `.github/workflows/android.yml` lo construye y lo distribuye automáticamente.

Las variables de entorno necesarias están documentadas en `.env.example`. Para producción, crea un archivo `.env.production` basándote en ese template (nunca se commitea).
