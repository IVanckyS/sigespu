-- backend/migrations/006_actividades_municipales.sql

CREATE TABLE actividades_municipales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT CHECK (tipo IN ('reunion', 'operativo', 'evento', 'capacitacion')) NOT NULL,
  estado TEXT CHECK (estado IN ('planificado', 'enCurso', 'completado', 'archivado')) NOT NULL,
  titulo TEXT NOT NULL,
  descripcion TEXT,
  fecha_inicio TIMESTAMPTZ NOT NULL,
  fecha_fin TIMESTAMPTZ,
  participante_ids TEXT[] DEFAULT '{}',
  lat FLOAT,
  lng FLOAT,
  direccion TEXT,
  sector TEXT,
  direccion_municipal TEXT,
  presupuesto_estimado FLOAT DEFAULT 0,
  acta JSONB,
  creado_por TEXT,
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ
);

CREATE INDEX idx_actividades_municipales_fecha ON actividades_municipales (fecha_inicio);
CREATE INDEX idx_actividades_municipales_estado ON actividades_municipales (estado);
