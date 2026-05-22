-- reset_and_migrate_008.sql
-- 1. Limpia todos los datos de scraping
-- 2. Aplica migration 008 (columnas nuevas / drops)

-- ── Limpiar datos ──────────────────────────────────────────────────────────
TRUNCATE TABLE patentes_comerciales   RESTART IDENTITY CASCADE;
TRUNCATE TABLE permisos_dom           RESTART IDENTITY CASCADE;
TRUNCATE TABLE decretos_transito      RESTART IDENTITY CASCADE;
TRUNCATE TABLE organizaciones_sociales RESTART IDENTITY CASCADE;

-- ── Migration 008 ──────────────────────────────────────────────────────────

ALTER TABLE patentes_comerciales
  ADD COLUMN IF NOT EXISTS numero_rol  INT,
  ADD COLUMN IF NOT EXISTS codigo_giro TEXT;

ALTER TABLE permisos_dom
  ADD COLUMN IF NOT EXISTS fecha_publicacion  DATE,
  ADD COLUMN IF NOT EXISTS tipo_acto          TEXT,
  ADD COLUMN IF NOT EXISTS denominacion_acto  TEXT;

ALTER TABLE organizaciones_sociales
  ADD COLUMN IF NOT EXISTS rol_municipalidad            TEXT,
  ADD COLUMN IF NOT EXISTS n_inscripcion_registro_civil TEXT,
  ADD COLUMN IF NOT EXISTS directiva                    TEXT,
  ADD COLUMN IF NOT EXISTS fecha_concesion              DATE,
  ADD COLUMN IF NOT EXISTS fecha_modificaciones         DATE,
  ADD COLUMN IF NOT EXISTS geocoding_confianza          TEXT
    CHECK (geocoding_confianza IN ('alta','media','baja','fallo')),
  ADD COLUMN IF NOT EXISTS raw_data                     JSONB;

ALTER TABLE organizaciones_sociales DROP COLUMN IF EXISTS rut_representante;
