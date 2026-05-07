-- backend/migrations/003_visor_tables.sql

CREATE TABLE capas_personalizadas (
  id          SERIAL PRIMARY KEY,
  nombre      TEXT NOT NULL,
  descripcion TEXT,
  color       TEXT NOT NULL DEFAULT '#FF5722',
  opacidad    FLOAT NOT NULL DEFAULT 0.5,
  visible     BOOLEAN NOT NULL DEFAULT true,
  formato     TEXT NOT NULL CHECK (formato IN ('kmz', 'shp', 'geojson')),
  subido_por  UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE geometrias_capa (
  id          SERIAL PRIMARY KEY,
  capa_id     INTEGER REFERENCES capas_personalizadas(id) ON DELETE CASCADE,
  nombre      TEXT,
  propiedades JSONB DEFAULT '{}',
  geom        GEOMETRY(GEOMETRY, 4326) NOT NULL
);
CREATE INDEX idx_geometrias_capa_geom ON geometrias_capa USING GIST (geom);

CREATE TABLE sismos_cache (
  usgs_id     TEXT PRIMARY KEY,
  magnitude   FLOAT NOT NULL,
  mag_type    TEXT,
  place       TEXT,
  time_utc    TIMESTAMPTZ NOT NULL,
  depth_km    FLOAT,
  alert       TEXT,
  tsunami     INTEGER,
  url_usgs    TEXT,
  geom        GEOMETRY(POINT, 4326) NOT NULL,
  fetched_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_sismos_cache_geom ON sismos_cache USING GIST (geom);
CREATE INDEX idx_sismos_cache_time ON sismos_cache (time_utc DESC);
