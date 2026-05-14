-- backend/migrations/005_sistema_layers.sql
-- Marca capas como capas base del sistema (tsunami, incendio forestal)
ALTER TABLE capas_personalizadas
  ADD COLUMN tipo_sistema TEXT DEFAULT NULL
  CHECK (tipo_sistema IN ('zona_tsunami', 'zona_incendio_forestal'));
