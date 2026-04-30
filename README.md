# SIGESPU Lota - Sistema de Información Geoespacial de Seguridad Pública

SIGESPU es la plataforma integral de seguridad pública desarrollada para la **Ilustre Municipalidad de Lota**. Su objetivo es centralizar, analizar y gestionar información territorial y de seguridad, permitiendo una coordinación efectiva entre los funcionarios municipales, directores y operarios en terreno.

---

## 🏗 Arquitectura del Sistema

El proyecto está estructurado como un **Monorepo Dart/Flutter**, dividiendo responsabilidades en cuatro módulos principales:

1. **`app/` (Frontend Flutter):** Aplicación multiplataforma (Móvil y Web) utilizada por los funcionarios. Construida con **Flutter**, **Riverpod** (estado) y **GoRouter** (navegación).
2. **`backend/` (API REST Dart):** Servidor HTTP construido con **Shelf**. Gestiona la autenticación, la base de datos central y sirve como puente seguro para la aplicación.
3. **`scraper/` (Worker Dart):** Proceso en segundo plano que extrae automáticamente datos públicos (Patentes, Permisos DOM) desde portales de transparencia, los geocodifica usando **Nominatim** y los inyecta en la base de datos.
4. **`shared/` (Paquete Dart):** Contiene los **Modelos de Datos** (DTOs) compartidos entre el frontend, el backend y el scraper, garantizando consistencia y tipado fuerte (usando `freezed` y `json_serializable`).

---

## 🔌 Infraestructura y Base de Datos

La infraestructura está completamente dockerizada para garantizar consistencia entre desarrollo y producción.

*   **PostgreSQL + PostGIS:** Base de datos principal. Utilizamos PostGIS para el almacenamiento y consulta eficiente de datos geoespaciales (puntos, polígonos, líneas).
*   **Redis:** Utilizado para caché rápido, *Rate Limiting* (protección contra abusos en la API) y almacenamiento de *Refresh Tokens* revocados (Blacklist).
*   **Nginx:** Proxy inverso configurado con estrictas políticas de seguridad (Headers de seguridad, protección Slowloris, límites de body).

### Esquema Geoespacial
El sistema maneica múltiples capas de información, almacenadas con el tipo de dato `GEOMETRY` de PostGIS:
*   `sectores_plan_regulador` (Polígonos)
*   `puntos_interes` (Puntos: Cámaras, Sedes, Luminarias)
*   `reportes_seguridad` (Puntos: Robos, Vandalismo)
*   `zonas_peligro` (Polígonos: Áreas de riesgo)
*   `patentes_comerciales` (Puntos extraídos vía Scraper)

---

## 🔐 Autenticación y Seguridad

El sistema utiliza autenticación basada en **JWT (JSON Web Tokens)** con rotación de *Refresh Tokens*:

1.  **Registro Restringido:** Solo se permiten correos con dominios `@lota.cl` o `@munilota.cl`. Todo nuevo usuario entra con nivel `visitante`.
2.  **Jerarquía de Roles:** 
    *   `visitante`: Acceso de solo lectura a datos públicos.
    *   `operativo`: Puede crear reportes, zonas de peligro y actualizar patentes. (Requiere aprobación del Director).
    *   `director`: Acceso total, aprueba solicitudes de nivel operativo.
3.  **Protección:** Las contraseñas se hashean con **Bcrypt** (costo 12). La API cuenta con *Rate Limiting* (20 req/min para Auth, 100 req/min general) gestionado en memoria por Redis.

---

## 📱 Frontend (App) y Modo Offline (Drift)

La aplicación está diseñada para funcionar en **terreno**, donde la conectividad a internet (4G/3G) puede ser inestable. Para resolver esto, implementamos una robusta arquitectura **Offline-First**.

### ¿Cómo funciona el Modo Offline?

1.  **Drift (SQLite):** Utilizamos Drift para mantener una réplica local de las tablas principales (`PuntosInteresLocal`, `ZonasPeligroLocal`, `ReportesSeguridadLocal`, `PatentesComercialesLocal`).
2.  **DAOs (Data Access Objects):** 
    *   Los DAOs (ej. `ReportesDao`, `ZonasDao`) son clases que abstraen la interacción con la base de datos local.
    *   Cuando un operario crea un "Nuevo Reporte" en el mapa, la interfaz llama al método `crearReporte()` del DAO.
3.  **Cola de Sincronización (`SyncQueueTable`):**
    *   El DAO guarda el registro en la tabla local de reportes para que el usuario lo vea inmediatamente en su mapa.
    *   Al mismo tiempo, dentro de una *transacción segura*, el DAO inserta un registro en la `SyncQueueTable` indicando la entidad, la acción (`create`) y el payload en JSON.
4.  **SyncService (Sincronización en Background):**
    *   Un servicio en segundo plano escucha los cambios de conectividad usando `connectivity_plus`.
    *   En cuanto el dispositivo detecta conexión a Internet, el servicio lee la `SyncQueueTable` y procesa la cola FIFO, enviando los datos al Backend.
    *   Implementa reintentos y *backoff* en caso de fallos.

---

## 🗺️ Mapa y Capas Dinámicas

El núcleo visual de la aplicación es un mapa interactivo construido con `flutter_map` y mapas base de *CartoDB Voyager*.

*   **Capas (Layers):** A través del panel lateral, los usuarios pueden encender y apagar capas en tiempo real (Plan Regulador, Centros de Acopio, Patentes). El estado global es manejado ágilmente por **Riverpod**.
*   **Modo Dibujo:** Los operarios pueden presionar el ícono del "lápiz" para agregar vértices tocando el mapa. Al juntar 3 o más puntos, se forma un polígono que puede guardarse como una nueva **Zona de Peligro**, usando directamente los DAOs y el flujo offline.

---

## 🤖 Scraper y Geocoding

El componente `scraper/` es un proceso autónomo (`Worker`) que actualiza la base de datos municipal sin intervención humana.

*   **Fuentes:** Extrae datos de *lotatransparente.cl* (Patentes Mensuales, Permisos DOM, Decretos de Tránsito).
*   **Normalización:** Aplica reglas específicas de la comuna (ej. cambiar "P.A. Cerda" a "Pedro Aguirre Cerda", ignorar direcciones de pabellones antiguos).
*   **Geocoding Responsable:** Convierte las direcciones de texto en coordenadas (Lat/Lng) usando **Nominatim (OpenStreetMap)**. Implementa un estricto *Rate Limit* de **1 petición por segundo** para cumplir con los términos de uso del proveedor y evitar bloqueos.
*   **Scheduler:** Utiliza `cron` para ejecutarse automáticamente durante la madrugada (03:00 AM).

---

## 🚀 Despliegue Local y Desarrollo

### Requisitos Previos
*   [Docker](https://www.docker.com/) y Docker Compose.
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Versión >=3.19.0).
*   [Dart SDK](https://dart.dev/get-dart) (Incluido con Flutter).

### 1. Levantar la Infraestructura (Backend, BD, Redis, Scraper)
Desde la raíz del proyecto, ejecuta:
```bash
docker-compose up -d --build
```
Esto iniciará:
*   PostgreSQL (PostGIS) en el puerto `5432`.
*   Redis en el puerto `6379`.
*   API Backend en el puerto `8080`.
*   Scraper (Worker en segundo plano).
*   Nginx (Proxy inverso) en el puerto `80`.

### 2. Ejecutar la Aplicación (Frontend)
Abre una nueva terminal, entra al directorio de la app y ejecuta:
```bash
cd app
flutter pub get
flutter run
```
*(Puedes correrlo en el navegador con `flutter run -d chrome` o en un emulador Android/iOS).*

### 3. Generación de Código (Opcional/Desarrollo)
Si realizas cambios en los Modelos (`shared/`) o en la Base de Datos Local (`app/lib/src/data/local/`), debes regenerar los archivos autogenerados (`.g.dart`, `.freezed.dart`):

**Para Shared:**
```bash
cd shared
dart run build_runner build -d
```
**Para App:**
```bash
cd app
dart run build_runner build -d
```
