INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'director@lota.cl',
  'Director Seguridad Pública',
  '$2a$12$REEMPLAZAR_CON_HASH_BCRYPT_REAL_VER_DOCS', -- REEMPLAZAR: genera con BCrypt.hashpw('TuPasswordSeguro', BCrypt.gensalt(logRounds: 12))
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;

INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'admin@lota.cl',
  'Administrador del Sistema',
  '$2a$12$REEMPLAZAR_CON_HASH_BCRYPT_REAL_VER_DOCS', -- REEMPLAZAR: genera con BCrypt.hashpw('TuPasswordSeguro', BCrypt.gensalt(logRounds: 12))
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
