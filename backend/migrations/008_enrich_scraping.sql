-- Migration 008: Enrich scraping tables with real column data from lotatransparente.cl
-- Run after 007 (if it exists) or after the initial schema.

-- patentes_comerciales: add numero_rol and codigo_giro
-- (fecha_publicacion column already exists from initial schema)
ALTER TABLE patentes_comerciales
  ADD COLUMN IF NOT EXISTS numero_rol INT,
  ADD COLUMN IF NOT EXISTS codigo_giro TEXT;

-- permisos_dom: add new columns surfaced from ig=172 real table structure
ALTER TABLE permisos_dom
  ADD COLUMN IF NOT EXISTS fecha_publicacion DATE,
  ADD COLUMN IF NOT EXISTS tipo_acto TEXT,
  ADD COLUMN IF NOT EXISTS denominacion_acto TEXT;

-- organizaciones_sociales: enrich with all real fields from ig=351 table
ALTER TABLE organizaciones_sociales
  ADD COLUMN IF NOT EXISTS rol_municipalidad TEXT,
  ADD COLUMN IF NOT EXISTS n_inscripcion_registro_civil TEXT,
  ADD COLUMN IF NOT EXISTS directiva TEXT,
  ADD COLUMN IF NOT EXISTS fecha_concesion DATE,
  ADD COLUMN IF NOT EXISTS fecha_modificaciones DATE,
  ADD COLUMN IF NOT EXISTS geocoding_confianza TEXT CHECK (geocoding_confianza IN ('alta','media','baja','fallo')),
  ADD COLUMN IF NOT EXISTS raw_data JSONB;

-- rut_representante does not exist in the source data (ig=351 has no RUT column)
ALTER TABLE organizaciones_sociales DROP COLUMN IF EXISTS rut_representante;
