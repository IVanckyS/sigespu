-- Migration 009: Índices faltantes en decretos_transito y permisos_dom
-- Detectados en auditoría de producción 2026-05-22.
-- Estas tablas tenían full-scans en cada query del scraping_route.

-- decretos_transito: sin ningún índice previo
CREATE INDEX IF NOT EXISTS idx_decretos_transito_fecha_inicio
  ON decretos_transito (fecha_inicio DESC);

CREATE INDEX IF NOT EXISTS idx_decretos_transito_estado
  ON decretos_transito (estado);

CREATE INDEX IF NOT EXISTS idx_decretos_transito_tipo
  ON decretos_transito (tipo);

-- permisos_dom: tenía solo GIST en geom, faltaban índices de filtrado
CREATE INDEX IF NOT EXISTS idx_permisos_dom_fecha_otorgamiento
  ON permisos_dom (fecha_otorgamiento DESC NULLS LAST);

CREATE INDEX IF NOT EXISTS idx_permisos_dom_tipo
  ON permisos_dom (tipo);

CREATE INDEX IF NOT EXISTS idx_permisos_dom_estado
  ON permisos_dom (estado);
