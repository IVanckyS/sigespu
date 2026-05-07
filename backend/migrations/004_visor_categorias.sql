-- backend/migrations/004_visor_categorias.sql
ALTER TABLE capas_personalizadas 
ADD COLUMN categoria TEXT NOT NULL DEFAULT 'Personalizadas';
