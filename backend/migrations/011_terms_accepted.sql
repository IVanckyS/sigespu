-- 011_terms_accepted.sql
-- Registra la fecha y hora en que el usuario aceptó los TU y PP.
-- NULL significa usuario creado antes de la implementación de este feature.
ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ DEFAULT NULL;

COMMENT ON COLUMN usuarios.terms_accepted_at IS
  'Fecha/hora UTC de aceptación de Términos de Uso y Política de Privacidad. NULL = cuenta anterior al feature legal.';
