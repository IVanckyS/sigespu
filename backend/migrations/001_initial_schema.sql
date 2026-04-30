CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  nivel_acceso TEXT CHECK (nivel_acceso IN ('visitante','operativo','director')) NOT NULL,
  solicitud_operativo TEXT CHECK (solicitud_operativo IN ('pendiente','aprobada','rechazada')) DEFAULT NULL,
  solicitud_fecha TIMESTAMPTZ,
  solicitud_cargo TEXT,
  solicitud_direccion_municipal TEXT,
  solicitud_revisada_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  solicitud_revisada_at TIMESTAMPTZ,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL,
  familia UUID NOT NULL,
  expira_en TIMESTAMPTZ NOT NULL,
  revocado BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sectores_plan_regulador (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo TEXT CHECK (codigo IN ('S-2','S-3','S-4','S-5','Centro')),
  nombre TEXT,
  sector_padre TEXT,
  geom GEOMETRY(POLYGON,4326),
  usos_permitidos JSONB,
  usos_prohibidos JSONB,
  fuente TEXT,
  vigente BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_sectores_plan_regulador_geom ON sectores_plan_regulador USING GIST (geom);

CREATE TABLE puntos_interes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT CHECK (tipo IN (
    'centro_acopio','sede_comunitaria','infraestructura',
    'luminaria','camara_cctv',
    'arbol_caido','poste_caido','sector_sin_luz','cable_colgando',
    'semaforo_dañado','socavon','fuga_agua','microbasural','otro'
  )),
  nombre TEXT,
  descripcion TEXT,
  direccion TEXT,
  geom GEOMETRY(POINT,4326),
  metadata JSONB,
  estado TEXT DEFAULT 'activo',
  origen TEXT DEFAULT 'manual',
  fuente_origen TEXT,
  created_by UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
CREATE INDEX idx_puntos_interes_geom ON puntos_interes USING GIST (geom);
CREATE INDEX idx_puntos_interes_tipo ON puntos_interes (tipo);
CREATE INDEX idx_puntos_interes_estado ON puntos_interes (estado);

CREATE TABLE reportes_seguridad (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT CHECK (tipo IN (
    'robo','vandalismo','accidente','violencia',
    'drogas','riña','emergencia_medica','incendio','otro'
  )),
  geom GEOMETRY(POINT,4326),
  direccion TEXT,
  descripcion TEXT,
  severidad INT CHECK (severidad BETWEEN 1 AND 5),
  fecha_evento TIMESTAMPTZ,
  fotos TEXT[] DEFAULT '{}',
  estado TEXT DEFAULT 'reportado',
  derivado_a TEXT,
  reportado_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  verificado_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
CREATE INDEX idx_reportes_seguridad_geom ON reportes_seguridad USING GIST (geom);
CREATE INDEX idx_reportes_seguridad_fecha_evento ON reportes_seguridad (fecha_evento);
CREATE INDEX idx_reportes_seguridad_tipo ON reportes_seguridad (tipo);

CREATE TABLE zonas_peligro (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT,
  geom GEOMETRY(POLYGON,4326),
  nivel_riesgo INT CHECK (nivel_riesgo BETWEEN 1 AND 5),
  tipo_riesgo TEXT CHECK (tipo_riesgo IN (
    'drogas','robos','vivienda_ilegal','vandalismo',
    'riña','sin_iluminacion','accidentes','microbasural','otro'
  )),
  descripcion TEXT,
  horario_critico TEXT,
  vigente_desde DATE,
  vigente_hasta DATE,
  created_by UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
CREATE INDEX idx_zonas_peligro_geom ON zonas_peligro USING GIST (geom);

CREATE TABLE zonas_personalizadas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT,
  categoria TEXT,
  color_hex TEXT,
  nivel INT CHECK (nivel BETWEEN 1 AND 5),
  descripcion TEXT,
  vigencia DATE,
  geom GEOMETRY(POLYGON,4326),
  created_by UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_zonas_personalizadas_geom ON zonas_personalizadas USING GIST (geom);

CREATE TABLE patentes_comerciales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_decreto INT,
  fecha_decreto DATE,
  fecha_publicacion DATE,
  tipo_patente TEXT,
  rut TEXT,
  razon_social TEXT,
  giro TEXT,
  direccion_raw TEXT,
  direccion_normalizada TEXT,
  geom GEOMETRY(POINT,4326),
  geocoding_confianza TEXT CHECK (geocoding_confianza IN ('alta','media','baja','fallo')),
  estado_inferido TEXT DEFAULT 'vigente_esperado',
  ultima_verificacion_terreno DATE,
  verificado_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  observaciones TEXT,
  url_fuente TEXT,
  scraped_at TIMESTAMPTZ,
  raw_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE(numero_decreto, fecha_decreto)
);
CREATE INDEX idx_patentes_comerciales_geom ON patentes_comerciales USING GIST (geom);
CREATE INDEX idx_patentes_comerciales_direccion ON patentes_comerciales USING GIN (direccion_normalizada gin_trgm_ops);

CREATE TABLE permisos_dom (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_permiso TEXT,
  tipo TEXT,
  descripcion TEXT,
  direccion_raw TEXT,
  geom GEOMETRY(POINT,4326),
  fecha_otorgamiento DATE,
  estado TEXT,
  url_fuente TEXT,
  scraped_at TIMESTAMPTZ,
  raw_data JSONB
);
CREATE INDEX idx_permisos_dom_geom ON permisos_dom USING GIST (geom);

CREATE TABLE decretos_transito (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_decreto TEXT,
  tipo TEXT,
  descripcion TEXT,
  direccion_afectada TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  estado TEXT,
  url_fuente TEXT,
  scraped_at TIMESTAMPTZ
);

CREATE TABLE organizaciones_sociales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_personalidad TEXT,
  tipo TEXT,
  nombre TEXT,
  direccion TEXT,
  geom GEOMETRY(POINT,4326),
  representante TEXT,
  rut_representante TEXT,
  vigencia_hasta DATE,
  sector TEXT,
  url_fuente TEXT,
  scraped_at TIMESTAMPTZ
);
CREATE INDEX idx_organizaciones_sociales_geom ON organizaciones_sociales USING GIST (geom);

CREATE TABLE verificaciones_terreno (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entidad_tipo TEXT,
  entidad_id UUID,
  verificado_por UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  fecha_verificacion TIMESTAMPTZ DEFAULT NOW(),
  geom_verificacion GEOMETRY(POINT,4326),
  estado_reportado TEXT,
  observaciones TEXT,
  fotos TEXT[]
);
CREATE INDEX idx_verificaciones_terreno_entidad ON verificaciones_terreno (entidad_tipo, entidad_id);

CREATE TABLE turnos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  inicio TIMESTAMPTZ,
  fin TIMESTAMPTZ,
  geom_inicio GEOMETRY(POINT,4326),
  geom_fin GEOMETRY(POINT,4326),
  ruta GEOMETRY(LINESTRING,4326),
  estado TEXT DEFAULT 'en_curso',
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_turnos_ruta ON turnos USING GIST (ruta);

CREATE TABLE sync_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  entidad TEXT,
  accion TEXT,
  entidad_id UUID,
  payload JSONB,
  client_timestamp TIMESTAMPTZ,
  server_timestamp TIMESTAMPTZ DEFAULT NOW(),
  conflict_resolution TEXT
);

CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  accion TEXT,
  entidad TEXT,
  entidad_id UUID,
  ip_address TEXT,
  user_agent TEXT,
  payload_antes JSONB,
  payload_despues JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
